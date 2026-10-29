package api

import (
	"bytes"
	"context"
	"encoding/binary"
	"errors"
	"image"
	"image/jpeg"
	_ "image/png" // decoders for image.Decode
	"io"
	"mime"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"
	"golang.org/x/image/draw"
	_ "golang.org/x/image/webp"
)

const (
	// receiptSide is the longest side of a stored receipt, in pixels: enough
	// to read the small print, small enough to keep the database lean.
	receiptSide = 2048
	// maxReceiptPixels stops images that are tiny files but huge pictures.
	maxReceiptPixels    = 16_000_000
	maxReceiptDimension = 16_384
	receiptQuality      = 82
)

// receiptReadTime is how long an upload may take to send its photo. The
// server has no overall read timeout, as event streams stay open.
var receiptReadTime = 2 * time.Minute

// receiptWait is how long a sent photo may wait for its turn to be
// converted before the upload is turned away as busy.
var receiptWait = 30 * time.Second

// receiptConnKey carries the upload's connection, for its read deadline.
type receiptConnKey struct{}

// One conversion at a time bounds the decoded frame (up to 8 bytes per
// pixel), resize buffers and the optional orientation copy across all server
// instances in this process. Acquire after reading the body, so an upload
// that sends slowly keeps no one else waiting.
var receiptWorkers = make(chan struct{}, 1)

var errBadImage = &apiError{status: http.StatusUnsupportedMediaType, code: "bad_image"}

func (s *Server) GetReceipt(ctx context.Context, req GetReceiptRequestObject) (GetReceiptResponseObject, error) {
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	if !validUUID(req.ExpenseId) {
		return nil, errNotFound
	}
	var data []byte
	err = s.db.QueryRow(ctx, `
		select r.data from receipts r join expenses e on e.id = r.expense_id
		where r.expense_id = $1 and e.group_id = $2`, req.ExpenseId, g.id).Scan(&data)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	return GetReceipt200ImagejpegResponse{Body: bytes.NewReader(data), ContentLength: int64(len(data))}, nil
}

func (s *Server) PutReceipt(ctx context.Context, req PutReceiptRequestObject) (PutReceiptResponseObject, error) {
	if !validUUID(req.ExpenseId) {
		return nil, errNotFound
	}
	// Authorize and check the target without taking a write lock while the
	// caller uploads or the decoder works. Recheck both in the final transaction.
	g, err := s.groupByToken(ctx, s.db, req.Token, false)
	if err != nil {
		return nil, err
	}
	var exists bool
	if err := s.db.QueryRow(ctx, `select exists (select 1 from expenses
		where id = $1 and group_id = $2 and deleted_at is null)`, req.ExpenseId, g.id).Scan(&exists); err != nil {
		return nil, err
	}
	if !exists {
		return nil, errNotFound
	}
	if t, _, err := mime.ParseMediaType(req.ContentType); err != nil || !strings.HasPrefix(t, "image/") {
		return nil, errBadImage
	}
	if rc, ok := ctx.Value(receiptConnKey{}).(*http.ResponseController); ok {
		_ = rc.SetReadDeadline(time.Now().Add(receiptReadTime))
	}
	raw, err := io.ReadAll(io.LimitReader(req.Body, maxReceiptBody+1))
	if err != nil {
		var tooBig *http.MaxBytesError
		if errors.As(err, &tooBig) {
			return nil, &apiError{status: http.StatusRequestEntityTooLarge, code: "too_large"}
		}
		if errors.Is(err, os.ErrDeadlineExceeded) {
			return nil, &apiError{status: http.StatusRequestTimeout, code: "timeout"}
		}
		return nil, err
	}
	if len(raw) > maxReceiptBody {
		return nil, &apiError{status: http.StatusRequestEntityTooLarge, code: "too_large"}
	}
	wait := time.NewTimer(receiptWait)
	defer wait.Stop()
	select {
	case receiptWorkers <- struct{}{}:
	case <-wait.C:
		return nil, &apiError{status: http.StatusServiceUnavailable, code: "busy"}
	case <-ctx.Done():
		return nil, ctx.Err()
	}
	data, err := func() ([]byte, error) {
		defer func() { <-receiptWorkers }()
		return receiptJPEG(raw)
	}()
	if err != nil {
		return nil, err
	}

	var out Expense
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		kind, _, deleted, title, err := lockExpense(ctx, tx, g, req.ExpenseId)
		if err != nil {
			return err
		}
		if deleted {
			return errNotFound
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		_, err = tx.Exec(ctx, `
			insert into receipts (expense_id, data) values ($1, $2)
			on conflict (expense_id) do update set data = excluded.data, created_at = now()`, req.ExpenseId, data)
		if err != nil {
			return err
		}
		payload := map[string]any{"title": title, "kind": kind}
		if err := logActivity(ctx, tx, g.id, who, "receipt.added", &req.ExpenseId, payload); err != nil {
			return err
		}
		out, err = loadExpense(ctx, tx, g, req.ExpenseId)
		return err
	})
	if err != nil {
		return nil, err
	}
	return PutReceipt200JSONResponse(out), nil
}

// DeleteReceipt removes the photo. Doing it twice changes nothing.
func (s *Server) DeleteReceipt(ctx context.Context, req DeleteReceiptRequestObject) (DeleteReceiptResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) (err error) {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		kind, _, _, title, err := lockExpense(ctx, tx, g, req.ExpenseId)
		if err != nil {
			return err
		}
		tag, err := tx.Exec(ctx, `delete from receipts where expense_id = $1`, req.ExpenseId)
		if err != nil || tag.RowsAffected() == 0 {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		payload := map[string]any{"title": title, "kind": kind}
		return logActivity(ctx, tx, g.id, who, "receipt.removed", &req.ExpenseId, payload)
	})
	if err != nil {
		return nil, err
	}
	return DeleteReceipt204Response{}, nil
}

// receiptJPEG turns an uploaded photo into what is stored: upright, at most
// receiptSide pixels a side, and a fresh JPEG, so nothing of the original
// file but its pixels is kept.
func receiptJPEG(raw []byte) ([]byte, error) {
	cfg, _, err := image.DecodeConfig(bytes.NewReader(raw))
	if err != nil || cfg.Width <= 0 || cfg.Height <= 0 || cfg.Width > maxReceiptDimension || cfg.Height > maxReceiptDimension ||
		cfg.Width > maxReceiptPixels/cfg.Height {
		return nil, errBadImage
	}
	img, format, err := image.Decode(bytes.NewReader(raw))
	if err != nil {
		return nil, errBadImage
	}
	orientation := 1
	if format == "jpeg" {
		orientation = jpegOrientation(raw)
	}

	b := img.Bounds()
	w, h := b.Dx(), b.Dy()
	if long := max(w, h); long > receiptSide {
		w, h = max(1, w*receiptSide/long), max(1, h*receiptSide/long)
	}
	// JPEG has no transparency: see-through parts become white paper.
	small := image.NewRGBA(image.Rect(0, 0, w, h))
	draw.Draw(small, small.Bounds(), image.White, image.Point{}, draw.Src)
	// ApproxBiLinear avoids the full-height float64 intermediate allocated by
	// kernel scalers, keeping the working set bounded by the decoded frame and
	// the small output/orientation buffers.
	draw.ApproxBiLinear.Scale(small, small.Bounds(), img, b, draw.Over, nil)

	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, upright(small, orientation), &jpeg.Options{Quality: receiptQuality}); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// upright turns img by its EXIF orientation (1 to 8), so it shows the way the
// camera was held without anyone having to read the tag.
func upright(img *image.RGBA, orientation int) image.Image {
	if orientation < 2 || orientation > 8 {
		return img
	}
	b := img.Bounds()
	w, h := b.Dx(), b.Dy()
	ow, oh := w, h
	if orientation >= 5 {
		ow, oh = h, w
	}
	out := image.NewRGBA(image.Rect(0, 0, ow, oh))
	for y := range h {
		for x := range w {
			var nx, ny int
			switch orientation {
			case 2: // mirrored
				nx, ny = w-1-x, y
			case 3: // upside down
				nx, ny = w-1-x, h-1-y
			case 4: // upside down, mirrored
				nx, ny = x, h-1-y
			case 5: // transposed
				nx, ny = y, x
			case 6: // turned a quarter clockwise
				nx, ny = h-1-y, x
			case 7: // transversed
				nx, ny = h-1-y, w-1-x
			case 8: // turned a quarter counterclockwise
				nx, ny = y, w-1-x
			}
			out.SetRGBA(nx, ny, img.RGBAAt(b.Min.X+x, b.Min.Y+y))
		}
	}
	return out
}

// jpegOrientation reads the EXIF orientation tag of a JPEG, or 1 when it has
// none or it cannot be read.
func jpegOrientation(raw []byte) int {
	if len(raw) < 4 || raw[0] != 0xff || raw[1] != 0xd8 {
		return 1
	}
	for i := 2; i+4 <= len(raw); {
		if raw[i] != 0xff {
			return 1
		}
		marker := raw[i+1]
		if marker == 0xda || marker == 0xd9 { // the picture itself begins
			return 1
		}
		size := int(binary.BigEndian.Uint16(raw[i+2:]))
		if size < 2 || i+2+size > len(raw) {
			return 1
		}
		seg := raw[i+4 : i+2+size]
		if marker == 0xe1 && len(seg) > 6 && string(seg[:6]) == "Exif\x00\x00" {
			return tiffOrientation(seg[6:])
		}
		i += 2 + size
	}
	return 1
}

func tiffOrientation(t []byte) int {
	if len(t) < 8 {
		return 1
	}
	var order binary.ByteOrder
	switch string(t[:2]) {
	case "II":
		order = binary.LittleEndian
	case "MM":
		order = binary.BigEndian
	default:
		return 1
	}
	ifd := int(order.Uint32(t[4:]))
	if ifd < 8 || ifd+2 > len(t) {
		return 1
	}
	n := int(order.Uint16(t[ifd:]))
	for k := range n {
		e := ifd + 2 + 12*k
		if e+12 > len(t) {
			return 1
		}
		if order.Uint16(t[e:]) == 0x0112 { // Orientation, a SHORT
			if v := int(order.Uint16(t[e+8:])); v >= 1 && v <= 8 {
				return v
			}
			return 1
		}
	}
	return 1
}
