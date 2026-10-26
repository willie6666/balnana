// Package api implements the HTTP API defined in api/openapi.yaml.
// api.gen.go is generated: run `go generate ./internal/api` after editing the spec.
package api

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/config"
	"balnana/internal/mail"
)

// Server implements StrictServerInterface.
type Server struct {
	cfg     *config.Config
	db      *pgxpool.Pool
	log     *slog.Logger
	version string
	mail    mail.Sender // nil when the server has no email
	oauth   map[string]*oauthProvider
	hub     *hub
}

var _ StrictServerInterface = (*Server)(nil)

func NewServer(cfg *config.Config, db *pgxpool.Pool, log *slog.Logger, version string) *Server {
	s := &Server{cfg: cfg, db: db, log: log, version: version, oauth: newOAuthProviders(cfg), hub: newHub()}
	if cfg.SMTP.Enabled() {
		m, err := mail.NewSMTP(cfg.SMTP)
		if err != nil {
			log.Error("email is off", "err", err) // config.Load checks the address first
		} else {
			s.mail = m
		}
	}
	return s
}

func (s *Server) GetServerInfo(ctx context.Context, _ GetServerInfoRequestObject) (GetServerInfoResponseObject, error) {
	accounts := s.cfg.AuthMode == config.AuthModeAccounts
	info := ServerInfo{
		Name:           "balnana",
		Version:        s.version,
		AuthMode:       ServerInfoAuthMode(s.cfg.AuthMode),
		Password:       accounts && s.cfg.Password,
		Signup:         ServerInfoSignup(s.cfg.Signup),
		Email:          s.mail != nil,
		OauthProviders: []OAuthProvider{},
		LinkGroups:     !accounts || s.cfg.LinkGroups,
		PublicUrl:      s.cfg.PublicURL.String(),
		SourceUrl:      s.cfg.SourceURL.String(),
	}
	if info.Password && s.cfg.Signup != config.SignupOpen {
		// The first account may always sign up, so a closed server can start.
		err := s.db.QueryRow(ctx, `select not exists (select 1 from users)`).Scan(&info.FirstAccount)
		if err != nil {
			return nil, err
		}
	}
	if accounts {
		for _, p := range s.cfg.OAuthProviders() {
			info.OauthProviders = append(info.OauthProviders, OAuthProvider{Id: p.ID, Name: p.Name})
		}
	}
	return GetServerInfo200JSONResponse(info), nil
}

// Healthz reports whether the server can reach its database.
func (s *Server) Healthz(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()
	if err := s.db.Ping(ctx); err != nil {
		s.log.Warn("health check failed", "err", err)
		writeJSON(w, http.StatusServiceUnavailable, map[string]string{"status": "unavailable"})
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

// writeError sends an Error body. code is a stable machine code the app translates.
func writeError(w http.ResponseWriter, status int, code string) {
	writeJSON(w, status, Error{Code: code})
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
