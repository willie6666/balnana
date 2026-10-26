package api

import (
	"errors"
	"log/slog"
	"mime"
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
			s.log.Debug("bad request", "path", maskPath(r.URL.Path), "err", err)
			var tooLarge *http.MaxBytesError
			if errors.As(err, &tooLarge) {
				writeError(w, http.StatusRequestEntityTooLarge, "too_large")
				return
			}
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
	h = s.sessions(h)
	h = checkBodies(h)
	h = rateLimit(s.cfg.RateLimit, s.cfg.TrustProxy, h)
	h = cors(s.cfg.CORSOrigins, h)
	h = securityHeaders(h)
	h = recoverer(s.log, h)
	h = logRequests(s.log, h)
	return h
}

// Request bodies are small JSON, except imported files.
const (
	maxBody       = 1 << 20
	maxImportBody = 16 << 20
)

// checkBodies limits the size of request bodies and, for the API, wants them
// to be JSON: a page on another site can post a plain-text form without
// asking first, but not JSON.
func checkBodies(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if !safeMethod(r.Method) && r.ContentLength != 0 && strings.HasPrefix(r.URL.Path, BasePath+"/") {
			if t, _, err := mime.ParseMediaType(r.Header.Get("Content-Type")); err != nil || t != "application/json" {
				writeError(w, http.StatusUnsupportedMediaType, "not_json")
				return
			}
		}
		limit := int64(maxBody)
		if r.URL.Path == BasePath+"/groups/import" {
			limit = maxImportBody
		}
		if r.ContentLength > limit {
			writeError(w, http.StatusRequestEntityTooLarge, "too_large")
			return
		}
		r.Body = http.MaxBytesReader(w, r.Body, limit)
		next.ServeHTTP(w, r)
	})
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

// Unwrap lets http.ResponseController flush event streams through it.
func (r *statusRecorder) Unwrap() http.ResponseWriter { return r.ResponseWriter }

func logRequests(log *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)
		log.Debug("request", "method", r.Method, "path", maskPath(r.URL.Path), "status", rec.status, "duration", time.Since(start))
	})
}

// Paths whose next part is a secret: a group token grants access to the
// group, an invitation token proves an email address.
var secretPaths = []string{"/g/", "/invite/", BasePath + "/g/", BasePath + "/auth/invites/"}

// maskPath hides the secrets in a path before it is logged.
func maskPath(path string) string {
	for _, prefix := range secretPaths {
		if rest, ok := strings.CutPrefix(path, prefix); ok {
			if _, after, found := strings.Cut(rest, "/"); found {
				return prefix + "<token>/" + after
			}
			return prefix + "<token>"
		}
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
