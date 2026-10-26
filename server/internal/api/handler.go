package api

import (
	"log/slog"
	"net/http"
	"runtime/debug"
	"slices"
	"strings"
	"time"
)

const BasePath = "/api/v1"

// NewHandler wires the API, the health check and the web app into one handler.
func NewHandler(s *Server, web http.Handler) http.Handler {
	mux := http.NewServeMux()

	strict := NewStrictHandlerWithOptions(s, nil, StrictHTTPServerOptions{
		RequestErrorHandlerFunc: func(w http.ResponseWriter, r *http.Request, err error) {
			s.log.Debug("bad request", "path", r.URL.Path, "err", err)
			writeError(w, http.StatusBadRequest, "bad_request")
		},
		ResponseErrorHandlerFunc: func(w http.ResponseWriter, r *http.Request, err error) {
			writeHandlerError(s.log, w, r, err)
		},
	})
	HandlerWithOptions(strict, StdHTTPServerOptions{
		BaseURL:    BasePath,
		BaseRouter: mux,
		ErrorHandlerFunc: func(w http.ResponseWriter, r *http.Request, err error) {
			writeError(w, http.StatusBadRequest, "bad_request")
		},
	})
	mux.HandleFunc(BasePath+"/", func(w http.ResponseWriter, r *http.Request) {
		writeError(w, http.StatusNotFound, "not_found")
	})
	mux.HandleFunc("GET /healthz", s.Healthz)
	mux.Handle("/", web)

	var h http.Handler = mux
	h = cors(s.cfg.CORSOrigins, h)
	h = securityHeaders(h)
	h = recoverer(s.log, h)
	h = logRequests(s.log, h)
	return h
}

func securityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := w.Header()
		// Group URLs are secrets: never leak them through the Referer header.
		h.Set("Referrer-Policy", "no-referrer")
		h.Set("X-Content-Type-Options", "nosniff")
		if strings.HasPrefix(r.URL.Path, "/g/") {
			h.Set("X-Robots-Tag", "noindex, nofollow")
		}
		next.ServeHTTP(w, r)
	})
}

// cors lets web apps on other origins use the API (BALNANA_CORS_ORIGINS).
// The web app served by this server is same-origin and needs no CORS.
func cors(origins []string, next http.Handler) http.Handler {
	if len(origins) == 0 {
		return next
	}
	any := slices.Contains(origins, "*")
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin == "" || !strings.HasPrefix(r.URL.Path, BasePath+"/") || !(any || slices.Contains(origins, origin)) {
			next.ServeHTTP(w, r)
			return
		}
		h := w.Header()
		h.Add("Vary", "Origin")
		h.Set("Access-Control-Allow-Origin", origin)
		if r.Method == http.MethodOptions && r.Header.Get("Access-Control-Request-Method") != "" {
			h.Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE")
			h.Set("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Balnana-Member")
			h.Set("Access-Control-Max-Age", "600")
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(code int) {
	r.status = code
	r.ResponseWriter.WriteHeader(code)
}

func logRequests(log *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)
		log.Debug("request", "method", r.Method, "path", maskPath(r.URL.Path), "status", rec.status, "duration", time.Since(start))
	})
}

// maskPath hides group tokens: never log /g/ paths in full, the token grants
// access to the group.
func maskPath(path string) string {
	if strings.HasPrefix(path, "/g/") {
		return "/g/<token>"
	}
	if rest, ok := strings.CutPrefix(path, BasePath+"/g/"); ok {
		_, after, _ := strings.Cut(rest, "/")
		return BasePath + "/g/<token>/" + after
	}
	return path
}

func recoverer(log *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			if v := recover(); v != nil {
				if v == http.ErrAbortHandler {
					panic(v)
				}
				log.Error("panic", "value", v, "stack", string(debug.Stack()))
				writeError(w, http.StatusInternalServerError, "internal")
			}
		}()
		next.ServeHTTP(w, r)
	})
}
