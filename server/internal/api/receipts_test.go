package api

import (
	"bytes"
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"hash/crc32"
	"image"
	"image/color"
	"image/jpeg"
	"image/png"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"
	"time"
)

// halves is a w×h picture, red on the left half and blue on the right.
func halves(w, h int) image.Image {
	img := image.NewRGBA(image.Rect(0, 0, w, h))
	for y := range h {
		for x := range w {
			c := color.RGBA{R: 255, A: 255}
			if x >= w/2 {
				c = color.RGBA{B: 255, A: 255}
			}
			img.SetRGBA(x, y, c)
		}
	}
	return img
}

func pngBytes(t *testing.T, img image.Image) []byte {
	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		t.Fatal(err)
	}
	return buf.Bytes()
}

// jpegWithOrientation is a JPEG of img carrying an EXIF orientation tag.
func jpegWithOrientation(t *testing.T, img image.Image, orientation uint16) []byte {
	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: 95}); err != nil {
		t.Fatal(err)
	}
	tiff := []byte("MM\x00\x2a\x00\x00\x00\x08\x00\x01")
	tiff = binary.BigEndian.AppendUint16(tiff, 0x0112)
	tiff = binary.BigEndian.AppendUint16(tiff, 3) // SHORT
	tiff = binary.BigEndian.AppendUint32(tiff, 1)
	tiff = binary.BigEndian.AppendUint16(tiff, orientation)
	tiff = append(tiff, 0, 0, 0, 0, 0, 0)
	app1 := append([]byte("Exif\x00\x00"), tiff...)
	seg := []byte{0xff, 0xe1}
	seg = binary.BigEndian.AppendUint16(seg, uint16(len(app1)+2))
	seg = append(seg, app1...)
	raw := buf.Bytes()
	return append(append(append([]byte{}, raw[:2]...), seg...), raw[2:]...)
}

func (c *client) upload(path, contentType string, body []byte) *httptest.ResponseRecorder {
	req := httptest.NewRequest("PUT", BasePath+path, bytes.NewReader(body))
	req.Header.Set("Content-Type", contentType)
	if c.member != "" {
		req.Header.Set("X-Balnana-Member", c.member)
	}
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, req)
	return rec
}

func (c *client) receipt(path string) image.Image {
	c.t.Helper()
	rec := httptest.NewRecorder()
	c.h.ServeHTTP(rec, httptest.NewRequest("GET", BasePath+path, nil))
	if rec.Code != http.StatusOK || rec.Header().Get("Content-Type") != "image/jpeg" {
		c.t.Fatalf("GET %s: %d %s", path, rec.Code, rec.Header().Get("Content-Type"))
	}
	img, err := jpeg.Decode(rec.Body)
	if err != nil {
		c.t.Fatal(err)
	}
	return img
}

func reddish(c color.Color) bool {
	r, _, b, _ := c.RGBA()
	return r > 0xc000 && b < 0x4000
}

func TestReceipts(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	ana := g.Members[0].Id
	base := "/g/" + g.Token
	var e Expense
	c.must(201, "POST", base+"/expenses", ExpenseInput{Title: "Lunch", Amount: "10",
		OccurredAt: mustTime(t, "2026-10-23T10:00:00Z"), Payers: []PayerInput{{MemberId: ana, Amount: "10"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: ana}}}, &e)
	if e.HasReceipt {
		t.Fatal("a new expense has no receipt")
	}
	path := base + "/expenses/" + e.Id + "/receipt"
	c.errorCode(404, "GET", path, nil)

	// A big PNG is made smaller.
	c.member = ana
	rec := c.upload(path, "image/png", pngBytes(t, halves(3000, 1000)))
	if rec.Code != http.StatusOK {
		t.Fatalf("upload: %d %s", rec.Code, rec.Body)
	}
	var after Expense
	c.must(200, "GET", base+"/expenses/"+e.Id, nil, &after)
	if !after.HasReceipt || after.Version != e.Version {
		t.Fatalf("after upload: hasReceipt %v, version %d -> %d", after.HasReceipt, e.Version, after.Version)
	}
	if b := c.receipt(path).Bounds(); b.Dx() != 2048 || b.Dy() != 682 {
		t.Fatalf("size %v", b)
	}

	// Transparent parts turn white.
	rec = c.upload(path, "image/png", pngBytes(t, image.NewNRGBA(image.Rect(0, 0, 4, 4))))
	if rec.Code != http.StatusOK {
		t.Fatalf("upload: %d %s", rec.Code, rec.Body)
	}
	if r, g, b, _ := c.receipt(path).At(2, 2).RGBA(); r < 0xf000 || g < 0xf000 || b < 0xf000 {
		t.Fatalf("transparent became %x %x %x", r, g, b)
	}

	// A photo taken with the phone on its side is stood up, red on top.
	rec = c.upload(path, "image/jpeg", jpegWithOrientation(t, halves(40, 20), 6))
	if rec.Code != http.StatusOK {
		t.Fatalf("upload: %d %s", rec.Code, rec.Body)
	}
	img := c.receipt(path)
	if b := img.Bounds(); b.Dx() != 20 || b.Dy() != 40 {
		t.Fatalf("size %v", b)
	}
	if !reddish(img.At(10, 5)) || reddish(img.At(10, 35)) {
		t.Fatal("not turned upright")
	}

	var acts ActivityPage
	c.must(200, "GET", base+"/activity?limit=1", nil, &acts)
	if a := acts.Items[0]; a.Action != "receipt.added" || a.Payload["title"] != "Lunch" || *a.ActorMemberId != ana {
		t.Fatalf("activity %+v", a)
	}

	// What is not a picture stays out.
	if rec := c.upload(path, "image/png", []byte("not a picture")); rec.Code != 415 {
		t.Fatalf("garbage: %d", rec.Code)
	}
	if rec := c.upload(path, "text/plain", pngBytes(t, halves(4, 4))); rec.Code != 415 {
		t.Fatalf("text: %d", rec.Code)
	}
	if rec := c.upload(path, "image/png", make([]byte, maxReceiptBody+1)); rec.Code != 413 {
		t.Fatalf("too big: %d", rec.Code)
	}
	// A small file claiming to be an enormous picture is not decoded.
	bomb := pngBytes(t, halves(4, 4))
	binary.BigEndian.PutUint32(bomb[16:], 100_000)
	binary.BigEndian.PutUint32(bomb[20:], 100_000)
	binary.BigEndian.PutUint32(bomb[29:], crc32.ChecksumIEEE(bomb[12:29]))
	if rec := c.upload(path, "image/png", bomb); rec.Code != 415 {
		t.Fatalf("bomb: %d", rec.Code)
	}
	if rec := c.upload(base+"/expenses/00000000-0000-0000-0000-000000000000/receipt", "image/png",
		pngBytes(t, halves(4, 4))); rec.Code != 404 {
		t.Fatalf("no such expense: %d", rec.Code)
	}

	c.must(204, "DELETE", path, nil, nil)
	c.must(204, "DELETE", path, nil, nil)
	c.errorCode(404, "GET", path, nil)
	c.must(200, "GET", base+"/expenses/"+e.Id, nil, &after)
	if after.HasReceipt {
		t.Fatal("still has a receipt")
	}
	c.must(200, "GET", base+"/activity?limit=2", nil, &acts)
	if acts.Items[0].Action != "receipt.removed" || acts.Items[1].Action != "receipt.added" {
		t.Fatalf("removing twice logs once: %s, %s", acts.Items[0].Action, acts.Items[1].Action)
	}
}

func TestJpegOrientation(t *testing.T) {
	for _, raw := range [][]byte{nil, {0xff, 0xd8}, {0xff, 0xd8, 0xff, 0xe1, 0xff, 0xff}, []byte("hello world")} {
		if got := jpegOrientation(raw); got != 1 {
			t.Errorf("%q: %d", raw, got)
		}
	}
}

// watchedReceipt detects even the first attempted body read. Rejected requests
// must leave it untouched, before either DecodeConfig or Decode can run.
type watchedReceipt struct {
	io.Reader
	reads  atomic.Int32
	before func()
}

func (r *watchedReceipt) Read(p []byte) (int, error) {
	if r.reads.Add(1) == 1 && r.before != nil {
		r.before()
	}
	return r.Reader.Read(p)
}
func (*watchedReceipt) Close() error { return nil }

func receiptExpense(c *client, g Group) Expense {
	c.t.Helper()
	var e Expense
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{Title: "Lunch", Amount: "10",
		OccurredAt:  mustTime(c.t, "2026-01-01T00:00:00Z"),
		Payers:      []PayerInput{{MemberId: g.Members[0].Id, Amount: "10"}},
		SplitMethod: "equal", Splits: []Share{{MemberId: g.Members[1].Id}}}, &e)
	return e
}

func TestReceiptAuthorizationBeforeBody(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	register(c, "ana@example.test", "Ana")
	g := createGroup(c, "Ana", "Ben")
	other := createGroup(c, "Ana", "Ben")
	e := receiptExpense(c, g)
	foreign := receiptExpense(c, other)
	gone := receiptExpense(c, g)
	c.must(204, "DELETE", "/g/"+g.Token+"/expenses/"+gone.Id, nil, nil)
	outsider := c.another()
	register(outsider, "outsider@example.test", "Outsider")
	for _, tc := range []struct {
		name, token, id, bearer string
		status                  int
	}{
		{"anonymous", g.Token, e.Id, "", 401},
		{"nonmember", g.Token, e.Id, outsider.token, 403},
		{"missing group", "AAAAAAAAAAAAAAAAAAAAAA", e.Id, c.token, 404},
		{"invalid group", "bad", e.Id, c.token, 404},
		{"invalid expense", g.Token, "bad", c.token, 404},
		{"missing expense", g.Token, "00000000-0000-0000-0000-000000000000", c.token, 404},
		{"wrong group", g.Token, foreign.Id, c.token, 404},
		{"deleted expense", g.Token, gone.Id, c.token, 404},
	} {
		t.Run(tc.name, func(t *testing.T) {
			body := &watchedReceipt{Reader: bytes.NewReader([]byte("not a PNG"))}
			req := httptest.NewRequest("PUT", BasePath+"/g/"+tc.token+"/expenses/"+tc.id+"/receipt", body)
			req.Header.Set("Content-Type", "image/png")
			if tc.bearer != "" {
				req.Header.Set("Authorization", "Bearer "+tc.bearer)
			}
			rec := httptest.NewRecorder()
			c.h.ServeHTTP(rec, req)
			if rec.Code != tc.status || body.reads.Load() != 0 {
				t.Fatalf("status %d reads %d: %s", rec.Code, body.reads.Load(), rec.Body)
			}
		})
	}
}

func TestReceiptRechecksAfterProcessing(t *testing.T) {
	c := accountsClient(t, map[string]string{})
	register(c, "ana@example.test", "Ana")
	g := createGroup(c, "Ana", "Ben")
	base := "/g/" + g.Token
	c.must(200, "PATCH", base, GroupUpdate{LinkAccess: ptr(true)}, nil)
	raw := pngBytes(t, halves(4, 4))
	for _, change := range []string{"delete", "permissions", "rotate"} {
		t.Run(change, func(t *testing.T) {
			e := receiptExpense(c, g)
			body := &watchedReceipt{Reader: bytes.NewReader(raw), before: func() {
				// These writes complete while the upload is reading: no group write
				// lock is held during body reads or image processing.
				switch change {
				case "delete":
					c.must(204, "DELETE", base+"/expenses/"+e.Id, nil, nil)
				case "permissions":
					c.must(200, "PATCH", base, GroupUpdate{LinkAccess: ptr(false)}, nil)
				case "rotate":
					c.must(200, "POST", base+"/reset-link", nil, nil)
				}
			}}
			req := httptest.NewRequest("PUT", BasePath+base+"/expenses/"+e.Id+"/receipt", body)
			req.Header.Set("Content-Type", "image/png")
			rec := httptest.NewRecorder()
			c.h.ServeHTTP(rec, req)
			want := 404
			if change == "permissions" {
				want = 401
			}
			if rec.Code != want || body.reads.Load() == 0 {
				t.Fatalf("status %d reads %d: %s", rec.Code, body.reads.Load(), rec.Body)
			}
			if change == "permissions" {
				c.must(200, "PATCH", base, GroupUpdate{LinkAccess: ptr(true)}, nil)
			}
		})
	}
}

func TestReceiptProcessingBound(t *testing.T) {
	pool := testDB(t)
	s := NewServer(baseConfig(t, map[string]string{}), pool, slog.New(slog.DiscardHandler), "test")
	c := &client{t: t, h: NewHandler(s, http.NotFoundHandler())}
	g := createGroup(c, "Ana", "Ben")
	e := receiptExpense(c, g)
	started, release := make(chan struct{}), make(chan struct{})
	first := &watchedReceipt{Reader: bytes.NewReader(pngBytes(t, halves(4, 4))), before: func() { close(started); <-release }}
	done := make(chan error, 1)
	go func() {
		_, err := s.PutReceipt(context.Background(), PutReceiptRequestObject{Token: g.Token, ExpenseId: e.Id, ContentType: "image/png", Body: first})
		done <- err
	}()
	defer func() {
		close(release)
		if err := <-done; err != nil {
			t.Error(err)
		}
	}()
	select {
	case <-started:
	case <-time.After(5 * time.Second):
		t.Fatal("first upload never started")
	}
	second := &watchedReceipt{Reader: bytes.NewReader([]byte("not a PNG"))}
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()
	_, err := s.PutReceipt(ctx, PutReceiptRequestObject{Token: g.Token, ExpenseId: e.Id, ContentType: "image/png", Body: second})
	if !errors.Is(err, context.DeadlineExceeded) || second.reads.Load() != 0 {
		t.Fatalf("waiting upload read before a worker was free: reads=%d err=%v", second.reads.Load(), err)
	}
}

var receiptDecoderTests atomic.Uint32

func TestReceiptPixelBudget(t *testing.T) {
	// A registered probe decoder distinguishes rejecting dimensions at the
	// config stage from allocating/decoding the pixel frame.
	var decoded atomic.Int32
	magic := fmt.Sprintf("RECEIPT%08d", receiptDecoderTests.Add(1))
	image.RegisterFormat("receipt-budget", magic, func(r io.Reader) (image.Image, error) {
		decoded.Add(1)
		return image.NewRGBA(image.Rect(0, 0, 1, 1)), nil
	}, func(r io.Reader) (image.Config, error) {
		raw, _ := io.ReadAll(r)
		return image.Config{ColorModel: color.RGBA64Model, Width: int(binary.BigEndian.Uint32(raw[len(magic):])), Height: int(binary.BigEndian.Uint32(raw[len(magic)+4:]))}, nil
	})
	for _, tc := range []struct {
		w, h    int
		allowed bool
	}{
		{4000, 4000, true},
		{4001, 4000, false},
		{maxReceiptDimension + 1, 1, false},
		{1, maxReceiptDimension + 1, false},
		{100_000, 100_000, false},
		{0, 1, false},
	} {
		raw := binary.BigEndian.AppendUint32([]byte(magic), uint32(tc.w))
		raw = binary.BigEndian.AppendUint32(raw, uint32(tc.h))
		before := decoded.Load()
		_, err := receiptJPEG(raw)
		if tc.allowed {
			if err != nil || decoded.Load() != before+1 {
				t.Fatalf("allowed %dx%d: %v", tc.w, tc.h, err)
			}
		} else if err != errBadImage || decoded.Load() != before {
			t.Fatalf("decoded excessive %dx%d: %v", tc.w, tc.h, err)
		}
	}
}

// An upload that stops sending gives up its turn after receiptReadTime, so
// the uploads waiting behind it go ahead.
func TestReceiptSlowUploadTimesOut(t *testing.T) {
	old := receiptReadTime
	receiptReadTime = 300 * time.Millisecond
	t.Cleanup(func() { receiptReadTime = old })
	c := newClient(t)
	g := createGroup(c, "Ana")
	var e Expense
	c.must(201, "POST", "/g/"+g.Token+"/expenses", ExpenseInput{
		Title: "Lunch", Amount: "1", OccurredAt: mustTime(t, "2026-01-01T00:00:00Z"),
		Payers: []PayerInput{{MemberId: g.Members[0].Id, Amount: "1"}}, SplitMethod: "equal",
		Splits: []Share{{MemberId: g.Members[0].Id}},
	}, &e)
	srv := httptest.NewServer(c.h)
	defer srv.Close()
	url := srv.URL + BasePath + "/g/" + g.Token + "/expenses/" + e.Id + "/receipt"

	stalled, sender := io.Pipe()
	defer sender.Close()
	slow := make(chan int, 1)
	go func() {
		req, _ := http.NewRequest("PUT", url, stalled)
		req.Header.Set("Content-Type", "image/png")
		req.ContentLength = 1000
		res, err := http.DefaultClient.Do(req)
		if err != nil {
			slow <- 0
			return
		}
		res.Body.Close()
		slow <- res.StatusCode
	}()
	if _, err := sender.Write([]byte("\x89PNG")); err != nil { // then nothing more
		t.Fatal(err)
	}
	for deadline := time.Now().Add(5 * time.Second); len(receiptWorkers) == 0; time.Sleep(5 * time.Millisecond) {
		if time.Now().After(deadline) {
			t.Fatal("the stalled upload never took its turn")
		}
	}

	start := time.Now()
	req, _ := http.NewRequest("PUT", url, bytes.NewReader([]byte("not a PNG")))
	req.Header.Set("Content-Type", "image/png")
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	res.Body.Close()
	if res.StatusCode != http.StatusUnsupportedMediaType || time.Since(start) > 5*time.Second {
		t.Fatalf("waiting upload: status %d after %v", res.StatusCode, time.Since(start))
	}
	if status := <-slow; status != http.StatusRequestTimeout {
		t.Fatalf("stalled upload: status %d", status)
	}
}
