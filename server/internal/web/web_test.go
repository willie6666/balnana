package web

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"testing/fstest"
)

func TestSPAFallback(t *testing.T) {
	dir := t.TempDir()
	must(t, os.WriteFile(filepath.Join(dir, "index.html"), []byte("<html>app</html>"), 0o644))
	must(t, os.WriteFile(filepath.Join(dir, "main.dart.js"), []byte("js"), 0o644))
	must(t, os.WriteFile(filepath.Join(dir, ".secret"), []byte("x"), 0o644))
	h := Handler(dir)

	cases := []struct {
		path   string
		status int
		body   string
	}{
		{"/", 200, "<html>app</html>"},
		{"/g/abc123", 200, "<html>app</html>"},
		{"/settings/server", 200, "<html>app</html>"},
		{"/main.dart.js", 200, "js"},
		{"/missing.js", 404, ""},
		{"/.secret", 404, ""},
	}
	for _, c := range cases {
		rec := httptest.NewRecorder()
		h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, c.path, nil))
		if rec.Code != c.status {
			t.Errorf("%s: status %d, want %d", c.path, rec.Code, c.status)
		}
		if c.body != "" && rec.Body.String() != c.body {
			t.Errorf("%s: body %q", c.path, rec.Body.String())
		}
	}
}

func TestNoBuild(t *testing.T) {
	rec := httptest.NewRecorder()
	Handler(t.TempDir()).ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/", nil))
	if rec.Code != http.StatusNotFound {
		t.Fatalf("status %d", rec.Code)
	}
}

func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}

// Files without a modification time, as embedded ones are, carry an ETag, so
// a browser that has them is answered 304 instead of downloading them again.
func TestEmbeddedETag(t *testing.T) {
	h := serve(fstest.MapFS{
		"index.html":   {Data: []byte("<html>app</html>")},
		"main.dart.js": {Data: []byte("js")},
	}, true)
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, "/main.dart.js", nil))
	tag := rec.Header().Get("ETag")
	if rec.Code != 200 || tag == "" {
		t.Fatalf("status %d, etag %q", rec.Code, tag)
	}
	req := httptest.NewRequest(http.MethodGet, "/main.dart.js", nil)
	req.Header.Set("If-None-Match", tag)
	rec = httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusNotModified {
		t.Fatalf("revalidation: status %d", rec.Code)
	}
}
