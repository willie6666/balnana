// Package web serves the Flutter web build.
//
// The Docker build copies `app/build/web` into dist/ before compiling, so the
// binary carries the web app. In development, BALNANA_WEB_DIR serves a build
// from disk instead.
package web

import (
	"embed"
	"io/fs"
	"net/http"
	"os"
	"path"
	"strings"
)

//go:embed all:dist
var embedded embed.FS

// Handler serves static files and falls back to index.html for app routes
// such as /g/<token>, so deep links work on reload.
func Handler(dir string) http.Handler {
	var files fs.FS
	if dir != "" {
		files = os.DirFS(dir)
	} else {
		files, _ = fs.Sub(embedded, "dist")
	}
	index, err := fs.ReadFile(files, "index.html")
	if err != nil {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			http.Error(w, "The Balnana web app is not part of this build. The API is at /api/v1.", http.StatusNotFound)
		})
	}

	fileServer := http.FileServerFS(files)
	serveIndex := func(w http.ResponseWriter) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		w.Header().Set("Cache-Control", "no-cache")
		_, _ = w.Write(index)
	}

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		name := strings.TrimPrefix(path.Clean(r.URL.Path), "/")
		if name == "" || name == "index.html" {
			serveIndex(w)
			return
		}
		if strings.HasPrefix(name, ".") || strings.Contains(name, "/.") {
			http.NotFound(w, r)
			return
		}
		if info, err := fs.Stat(files, name); err == nil && !info.IsDir() {
			// Flutter's bootstrap and service worker must be revalidated so
			// new releases are picked up; hashed assets can be cached.
			if name == "flutter_bootstrap.js" || name == "flutter_service_worker.js" || name == "version.json" {
				w.Header().Set("Cache-Control", "no-cache")
			}
			fileServer.ServeHTTP(w, r)
			return
		}
		// Unknown paths with an extension are missing files, not app routes.
		if path.Ext(name) != "" {
			http.NotFound(w, r)
			return
		}
		serveIndex(w)
	})
}
