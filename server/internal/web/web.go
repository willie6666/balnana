// Package web serves the Flutter web build.
//
// The Docker build copies `app/build/web` into dist/ before compiling, so the
// binary carries the web app. In development, BALNANA_WEB_DIR serves a build
// from disk instead.
package web

import (
	"crypto/sha256"
	"embed"
	"encoding/hex"
	"io/fs"
	"net/http"
	"os"
	"path"
	"strings"
	"sync"
)

//go:embed all:dist
var embedded embed.FS

// Handler serves static files and falls back to index.html for app routes
// such as /g/<token>, so deep links work on reload.
func Handler(dir string) http.Handler {
	if dir != "" {
		return serve(os.DirFS(dir), false)
	}
	files, _ := fs.Sub(embedded, "dist")
	return serve(files, true)
}

// serve serves files. With tagged, which files without modification times
// (embedded ones) need, each carries an ETag of its content.
func serve(files fs.FS, tagged bool) http.Handler {
	var etags *sync.Map // name to ETag
	if tagged {
		etags = &sync.Map{}
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
			// Embedded files carry no modification time, so without an ETag
			// browsers download the megabytes of the app again on every visit.
			if etags != nil {
				if tag := etag(files, name, etags); tag != "" {
					w.Header().Set("ETag", tag)
				}
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

// etag is the ETag of the embedded file name: a hash of its content, worked
// out once.
func etag(files fs.FS, name string, cache *sync.Map) string {
	if tag, ok := cache.Load(name); ok {
		return tag.(string)
	}
	data, err := fs.ReadFile(files, name)
	if err != nil {
		return ""
	}
	sum := sha256.Sum256(data)
	tag := `"` + hex.EncodeToString(sum[:16]) + `"`
	cache.Store(name, tag)
	return tag
}
