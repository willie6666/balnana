package api

import (
	"bytes"
	"encoding/binary"
	"hash/crc32"
	"image"
	"image/color"
	"image/jpeg"
	"image/png"
	"net/http"
	"net/http/httptest"
	"testing"
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
