package web

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
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
