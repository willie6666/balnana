package api

import (
	"errors"
	"log/slog"
	"net/http"

	"balnana/internal/domain"
)

// apiError is an error with an HTTP status and a stable machine code.
// Handlers return it; the strict handler's error hook writes it.
type apiError struct {
	status int
	code   string
	params map[string]any
}

func (e *apiError) Error() string { return e.code }

var errNotFound = &apiError{status: http.StatusNotFound, code: "not_found"}

func badRequest(code string) error { return &apiError{status: http.StatusBadRequest, code: code} }

func conflict(code string) error { return &apiError{status: http.StatusConflict, code: code} }

func forbidden(code string) error { return &apiError{status: http.StatusForbidden, code: code} }

// writeHandlerError turns an error returned by a handler into a response.
// Domain validation codes become 400s; anything unexpected is logged and
// hidden behind "internal".
func writeHandlerError(log *slog.Logger, w http.ResponseWriter, r *http.Request, err error) {
	var ae *apiError
	var dc domain.Code
	switch {
	case errors.As(err, &ae):
		body := Error{Code: ae.code}
		if ae.params != nil {
			body.Params = &ae.params
		}
		writeJSON(w, ae.status, body)
	case errors.As(err, &dc):
		writeError(w, http.StatusBadRequest, string(dc))
	default:
		log.Error("request failed", "method", r.Method, "path", maskPath(r.URL.Path), "err", err)
		writeError(w, http.StatusInternalServerError, "internal")
	}
}
