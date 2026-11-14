package web

import (
	"bytes"
	"compress/gzip"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"testing/fstest"
	"time"
)

// big is compressible content over minCompressSize.
func big(s string) []byte { return []byte(strings.Repeat(s, 2000)) }

func get(h http.Handler, path, acceptEncoding string, header ...string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(http.MethodGet, path, nil)
	if acceptEncoding != "" {
		req.Header.Set("Accept-Encoding", acceptEncoding)
	}
	for i := 0; i+1 < len(header); i += 2 {
		req.Header.Set(header[i], header[i+1])
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec
}

func gunzip(t *testing.T, b []byte) []byte {
	t.Helper()
	zr, err := gzip.NewReader(bytes.NewReader(b))
	if err != nil {
		t.Fatal(err)
	}
	out, err := io.ReadAll(zr)
	if err != nil {
		t.Fatal(err)
	}
	return out
}

// The megabytes of main.dart.js and canvaskit.wasm go out compressed to a
// browser that takes gzip, which on a slow phone network is the difference
// between the app opening and not.
func TestGzip(t *testing.T) {
	js, wasm := big("var a = 1;\n"), big("\x00asm\x01\x00\x00\x00")
	h := serve(fstest.MapFS{
		"index.html":               {Data: []byte("<html>app</html>")},
		"main.dart.js":             {Data: js},
		"canvaskit/canvaskit.wasm": {Data: wasm},
		"assets/NOTICES":           {Data: big("license text\n")},
		"icons/logo.png":           {Data: big("png")},
		"small.js":                 {Data: []byte("tiny")},
	}, true)

	for path, want := range map[string]struct {
		body []byte
		ct   string
	}{
		"/main.dart.js":             {js, "text/javascript; charset=utf-8"},
		"/canvaskit/canvaskit.wasm": {wasm, "application/wasm"},
		"/assets/NOTICES":           {big("license text\n"), "text/plain; charset=utf-8"},
	} {
		rec := get(h, path, "gzip, deflate, br")
		if rec.Code != 200 || rec.Header().Get("Content-Encoding") != "gzip" {
			t.Fatalf("%s: status %d, encoding %q", path, rec.Code, rec.Header().Get("Content-Encoding"))
		}
		if rec.Body.Len() >= len(want.body) {
			t.Errorf("%s: %d bytes compressed, %d plain", path, rec.Body.Len(), len(want.body))
		}
		if !bytes.Equal(gunzip(t, rec.Body.Bytes()), want.body) {
			t.Errorf("%s: decompressed body differs", path)
		}
		if got := rec.Header().Get("Content-Type"); got != want.ct {
			t.Errorf("%s: Content-Type %q, want %q", path, got, want.ct)
		}
		if rec.Header().Get("Vary") != "Accept-Encoding" || rec.Header().Get("Cache-Control") != "no-cache" {
			t.Errorf("%s: Vary %q, Cache-Control %q", path, rec.Header().Get("Vary"), rec.Header().Get("Cache-Control"))
		}
	}

	// Plain to a browser that does not take gzip, or refuses it with q=0,
	// still marked as varying so a proxy does not hand it the other one.
	for _, ae := range []string{"", "identity", "gzip;q=0", "br, gzip; q=0.0"} {
		rec := get(h, "/main.dart.js", ae)
		if rec.Header().Get("Content-Encoding") != "" || !bytes.Equal(rec.Body.Bytes(), js) {
			t.Errorf("Accept-Encoding %q: encoding %q", ae, rec.Header().Get("Content-Encoding"))
		}
		if rec.Header().Get("Vary") != "Accept-Encoding" {
			t.Errorf("Accept-Encoding %q: Vary %q", ae, rec.Header().Get("Vary"))
		}
	}
	if rec := get(h, "/main.dart.js", "GZIP;q=0.5"); rec.Header().Get("Content-Encoding") != "gzip" {
		t.Errorf("GZIP;q=0.5: not compressed")
	}

	// Images are compressed already, and small files are not worth it.
	for _, path := range []string{"/icons/logo.png", "/small.js"} {
		rec := get(h, path, "gzip")
		if rec.Code != 200 || rec.Header().Get("Content-Encoding") != "" || rec.Header().Get("Vary") != "" {
			t.Errorf("%s: status %d, encoding %q, vary %q", path, rec.Code, rec.Header().Get("Content-Encoding"), rec.Header().Get("Vary"))
		}
	}
}

// The compressed file has its own ETag, and a browser holding it is answered
// 304 like one holding the plain file.
func TestGzipETag(t *testing.T) {
	h := serve(fstest.MapFS{
		"index.html":   {Data: []byte("<html>app</html>")},
		"main.dart.js": {Data: big("var a = 1;\n")},
	}, true)
	plain := get(h, "/main.dart.js", "").Header().Get("ETag")
	gz := get(h, "/main.dart.js", "gzip").Header().Get("ETag")
	if plain == "" || gz == "" || plain == gz {
		t.Fatalf("plain ETag %q, gzip ETag %q", plain, gz)
	}
	rec := get(h, "/main.dart.js", "gzip", "If-None-Match", gz)
	if rec.Code != http.StatusNotModified || rec.Body.Len() != 0 || rec.Header().Get("Content-Encoding") != "" {
		t.Fatalf("revalidation: status %d, %d bytes, encoding %q", rec.Code, rec.Body.Len(), rec.Header().Get("Content-Encoding"))
	}
	// A browser holding the plain file that now takes gzip gets it in full.
	if rec := get(h, "/main.dart.js", "gzip", "If-None-Match", plain); rec.Code != 200 {
		t.Fatalf("plain tag, gzip: status %d", rec.Code)
	}
}

// A new build under BALNANA_WEB_DIR is compressed again, not served from the
// last one.
func TestGzipRebuild(t *testing.T) {
	dir := t.TempDir()
	must(t, os.WriteFile(filepath.Join(dir, "index.html"), []byte("<html>app</html>"), 0o644))
	js := filepath.Join(dir, "main.dart.js")
	must(t, os.WriteFile(js, big("old();\n"), 0o644))
	h := Handler(dir)
	if got := gunzip(t, get(h, "/main.dart.js", "gzip").Body.Bytes()); !bytes.Equal(got, big("old();\n")) {
		t.Fatal("first build: wrong body")
	}
	must(t, os.WriteFile(js, big("new();\n"), 0o644))
	later := time.Now().Add(time.Minute)
	must(t, os.Chtimes(js, later, later))
	if got := gunzip(t, get(h, "/main.dart.js", "gzip").Body.Bytes()); !bytes.Equal(got, big("new();\n")) {
		t.Fatal("rebuild: still serving the old build")
	}
}

func TestAccepts(t *testing.T) {
	for _, c := range []struct {
		header, coding string
		want           bool
	}{
		{"", "gzip", false},
		{"gzip", "gzip", true},
		{"gzip, deflate, br", "gzip", true},
		{"gzip, deflate, br", "br", true},
		{"br;q=1.0, gzip;q=0.8", "gzip", true},
		{"gzip;q=0", "gzip", false},
		{"gzip;q=0.000", "gzip", false},
		{"br;q=0, gzip", "br", false},
		{"x-gzip", "gzip", false},
		{"deflate, br, identity", "gzip", false},
		{"gzip, deflate", "br", false},
		{"*", "gzip", false},
	} {
		if got := accepts(c.header, c.coding); got != c.want {
			t.Errorf("accepts(%q, %q) = %v, want %v", c.header, c.coding, got, c.want)
		}
	}
}

// A browser that takes Brotli gets the copy precompress.sh made, which is
// smaller again than gzip; one that does not gets gzip as before.
func TestBrotli(t *testing.T) {
	js, notices := big("var a = 1;\n"), big("license text\n")
	built := time.Date(2026, 1, 1, 0, 0, 0, 0, time.UTC)
	h := serve(fstest.MapFS{
		"index.html": {Data: []byte("<html>app</html>")},
		// The server sends .br files as they are, so any bytes stand in.
		"main.dart.js":      {Data: js, ModTime: built},
		"main.dart.js.br":   {Data: []byte("brotli js"), ModTime: built},
		"assets/NOTICES":    {Data: notices, ModTime: built},
		"assets/NOTICES.br": {Data: []byte("brotli notices"), ModTime: built},
		// A copy no smaller than the file is no use.
		"big.js":    {Data: big("x"), ModTime: built},
		"big.js.br": {Data: big("xy"), ModTime: built},
		// A copy older than the file is from an earlier build.
		"stale.js":    {Data: big("new();\n"), ModTime: built},
		"stale.js.br": {Data: []byte("old"), ModTime: built.Add(-time.Minute)},
	}, true)

	for path, want := range map[string]struct{ body, ct string }{
		"/main.dart.js":   {"brotli js", "text/javascript; charset=utf-8"},
		"/assets/NOTICES": {"brotli notices", "text/plain; charset=utf-8"},
	} {
		rec := get(h, path, "gzip, deflate, br")
		if rec.Code != 200 || rec.Header().Get("Content-Encoding") != "br" || rec.Body.String() != want.body {
			t.Fatalf("%s: status %d, encoding %q, body %q", path, rec.Code, rec.Header().Get("Content-Encoding"), rec.Body.String())
		}
		if got := rec.Header().Get("Content-Type"); got != want.ct {
			t.Errorf("%s: Content-Type %q, want %q", path, got, want.ct)
		}
		if rec.Header().Get("Vary") != "Accept-Encoding" {
			t.Errorf("%s: Vary %q", path, rec.Header().Get("Vary"))
		}
	}

	for _, c := range []struct{ path, ae string }{
		{"/main.dart.js", "gzip, deflate"},
		{"/main.dart.js", "br;q=0, gzip"},
		{"/big.js", "br, gzip"},
		{"/stale.js", "br, gzip"},
	} {
		if rec := get(h, c.path, c.ae); rec.Header().Get("Content-Encoding") != "gzip" {
			t.Errorf("%s with %q: encoding %q, want gzip", c.path, c.ae, rec.Header().Get("Content-Encoding"))
		}
	}
	if rec := get(h, "/main.dart.js", "br"); rec.Header().Get("Content-Encoding") != "br" {
		t.Errorf("br alone: encoding %q", rec.Header().Get("Content-Encoding"))
	}

	// Each coding has its own ETag, and the Brotli one revalidates.
	gz := get(h, "/main.dart.js", "gzip").Header().Get("ETag")
	br := get(h, "/main.dart.js", "br").Header().Get("ETag")
	if !strings.HasSuffix(br, `-br"`) || br == gz {
		t.Fatalf("br ETag %q, gzip ETag %q", br, gz)
	}
	if rec := get(h, "/main.dart.js", "br", "If-None-Match", br); rec.Code != http.StatusNotModified {
		t.Fatalf("revalidation: status %d", rec.Code)
	}
	// HEAD carries the headers without the body.
	req := httptest.NewRequest(http.MethodHead, "/main.dart.js", nil)
	req.Header.Set("Accept-Encoding", "br")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != 200 || rec.Body.Len() != 0 || rec.Header().Get("Content-Encoding") != "br" {
		t.Fatalf("HEAD: status %d, %d bytes, encoding %q", rec.Code, rec.Body.Len(), rec.Header().Get("Content-Encoding"))
	}
}
