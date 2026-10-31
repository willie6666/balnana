package api

import (
	"context"
	"errors"
	"io"
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
			if errors.Is(err, errNoCoordinate) {
				writeError(w, http.StatusBadRequest, "invalid_location")
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
	mux.HandleFunc("POST "+BasePath+"/webhooks/kofi", s.KofiWebhook)
	mux.HandleFunc("POST "+BasePath+"/webhooks/play", s.PlayWebhook)
	mux.HandleFunc("GET /healthz", s.Healthz)
	mux.HandleFunc("GET /.well-known/assetlinks.json", s.assetLinks)
	mux.Handle("/", web)

	var h http.Handler = mux
	h = s.sessions(h)
	h = checkBodies(h)
	h = rateLimit(s.conf().RateLimit, s.conf().ProxyHeader, h)
	h = cors(s.conf().CORSOrigins, h)
	h = securityHeaders(h)
	h = recoverer(s.log, h)
	h = logRequests(s.log, h)
	return h
}

// Request bodies are small JSON, except imported files and receipt photos.
const (
	maxBody        = 1 << 20
	maxImportBody  = 16 << 20
	maxReceiptBody = 10 << 20
)

// bodyReadTime is how long a request may take to send its body. The server
// has no overall read timeout, as event streams stay open.
var bodyReadTime = 30 * time.Second

// deadlineBody lifts the read deadline once the body is in. The server goes
// on reading to notice a client leaving, and a deadline passing there would
// cancel a request still being worked on.
type deadlineBody struct {
	io.ReadCloser
	rc *http.ResponseController
}

func (b deadlineBody) Read(p []byte) (int, error) {
	n, err := b.ReadCloser.Read(p)
	if err == io.EOF {
		_ = b.rc.SetReadDeadline(time.Time{})
	}
	return n, err
}

// checkBodies limits the size of request bodies and, for the API, wants them
// to be JSON, or an image for a receipt: a page on another site can post a
// plain-text form without asking first, but not those.
func checkBodies(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		receipt := r.Method == http.MethodPut && strings.HasSuffix(r.URL.Path, "/receipt")
		if !safeMethod(r.Method) && r.ContentLength != 0 && strings.HasPrefix(r.URL.Path, BasePath+"/") {
			t, _, err := mime.ParseMediaType(r.Header.Get("Content-Type"))
			if receipt && err == nil && strings.HasPrefix(t, "image/") {
				// An image, as it should be.
			} else if r.URL.Path == kofiPath && err == nil && t == "application/x-www-form-urlencoded" {
				// Ko-fi posts a form, and its token shows it came from there.
			} else if err != nil || t != "application/json" {
				writeError(w, http.StatusUnsupportedMediaType, "not_json")
				return
			}
		}
		limit := int64(maxBody)
		switch {
		case r.URL.Path == BasePath+"/groups/import":
			limit = maxImportBody
		case receipt:
			limit = maxReceiptBody
		}
		if r.ContentLength > limit {
			writeError(w, http.StatusRequestEntityTooLarge, "too_large")
			return
		}
		r.Body = http.MaxBytesReader(w, r.Body, limit)
		rc := http.NewResponseController(w)
		if !safeMethod(r.Method) && r.ContentLength != 0 {
			_ = rc.SetReadDeadline(time.Now().Add(bodyReadTime))
			r.Body = deadlineBody{r.Body, rc}
		}
		if receipt {
			// PutReceipt gives the photo longer, once its turn comes.
			r = r.WithContext(context.WithValue(r.Context(), receiptConnKey{}, rc))
		}
		next.ServeHTTP(w, r)
	})
}

func securityHeaders(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := w.Header()
		// Group URLs are secrets: the Referer header carries only the origin,
		// never the path. Map tile servers ask for that much.
		h.Set("Referrer-Policy", "strict-origin")
		h.Set("X-Content-Type-Options", "nosniff")
		// No other site may show these pages in a frame and trick people
		// into clicking in them (the administrator's settings, say).
		h.Set("X-Frame-Options", "DENY")
		h.Set("Content-Security-Policy", "frame-ancestors 'none'")
		if strings.HasPrefix(r.URL.Path, "/g/") || r.URL.Path == "/admin" || strings.HasPrefix(r.URL.Path, "/admin/") {
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
		h.Set("Access-Control-Expose-Headers", "Retry-After, Content-Disposition")
		if r.Method == http.MethodOptions && r.Header.Get("Access-Control-Request-Method") != "" {
			h.Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE")
			h.Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Idempotency-Key, X-Balnana-Member, X-Balnana-Admin")
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
// group, an invitation token proves an email address, and a device token
// decides what a phone is told.
var secretPaths = []string{"/g/", "/invite/", BasePath + "/g/", BasePath + "/auth/invites/", BasePath + "/push/devices/"}

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
