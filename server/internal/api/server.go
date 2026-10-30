// Package api implements the HTTP API defined in api/openapi.yaml.
// api.gen.go is generated: run `go generate ./internal/api` after editing the spec.
package api

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/config"
	"balnana/internal/mail"
	"balnana/internal/push"
)

// Server implements StrictServerInterface.
type Server struct {
	settings atomic.Pointer[settings]
	db       *pgxpool.Pool
	log      *slog.Logger
	version  string
	hub      *hub
	push     push.Sender // nil when the server sends no push notifications
	vapid    string      // the public key push messages are signed with
	pushing  sync.WaitGroup
	creates  *buckets // groups created, by client
	invites  *buckets // invitations sent, by account
	signups  *buckets // password accounts made, by client
	emails   *buckets // address changes, by account
	guesses  *buckets // password guesses, by account
	devices  *buckets // push devices registered, by client
}

// settings are the configuration in force and what it sets up. An
// administrator can change them while the server runs (see admin.go), so
// handlers read them once per use through Server.conf and friends.
type settings struct {
	cfg   *config.Config
	mail  mail.Sender // nil when the server has no email
	oauth map[string]*oauthProvider
	play  *playClient // nil when the server sells nothing through Google Play
}

var _ StrictServerInterface = (*Server)(nil)

func NewServer(cfg *config.Config, db *pgxpool.Pool, log *slog.Logger, version string) *Server {
	s := &Server{
		db:      db,
		log:     log,
		version: version,
		hub:     newHub(),
		creates: newBuckets(createPerMinute, createBurst),
		invites: newBuckets(invitePerMinute, inviteBurst),
		signups: &buckets{perSecond: signupPerHour / 3600.0, burst: signupBurst, m: map[string]*bucket{}},
		emails:  &buckets{perSecond: emailChangePerHour / 3600.0, burst: emailChangeBurst, m: map[string]*bucket{}},
		guesses: &buckets{perSecond: guessPerHour / 3600.0, burst: guessBurst, m: map[string]*bucket{}},
		devices: &buckets{perSecond: devicePerDay / 86400.0, burst: deviceBurst, m: map[string]*bucket{}},
	}
	s.apply(cfg)
	return s
}

// apply puts cfg in force.
func (s *Server) apply(cfg *config.Config) {
	st := &settings{cfg: cfg, oauth: newOAuthProviders(cfg)}
	if cfg.SMTP.Enabled() {
		m, err := mail.NewSMTP(cfg.SMTP)
		if err != nil {
			s.log.Error("email is off", "err", err) // config.Load checks the address first
		} else {
			st.mail = m
		}
	}
	st.play = newPlayClient(cfg, strings.TrimSuffix(cfg.PublicURL.String(), "/")+playPath)
	s.settings.Store(st)
}

// conf is the configuration in force.
func (s *Server) conf() *config.Config { return s.settings.Load().cfg }

// mailer sends email; nil when the server has none.
func (s *Server) mailer() mail.Sender { return s.settings.Load().mail }

func (s *Server) GetServerInfo(ctx context.Context, _ GetServerInfoRequestObject) (GetServerInfoResponseObject, error) {
	st := s.settings.Load()
	cfg := st.cfg
	accounts := cfg.AuthMode == config.AuthModeAccounts
	info := ServerInfo{
		Name:             "balnana",
		Version:          s.version,
		AuthMode:         ServerInfoAuthMode(cfg.AuthMode),
		Password:         accounts && cfg.Password,
		Signup:           ServerInfoSignup(cfg.Signup),
		Email:            st.mail != nil,
		EmailRequired:    cfg.RequireEmail,
		VerifiedRequired: accounts && cfg.RequireVerified,
		OauthProviders:   []OAuthProvider{},
		LinkGroups:       !accounts || cfg.LinkGroups,
		Push:             s.push != nil,
		PublicUrl:        cfg.PublicURL.String(),
		SourceUrl:        cfg.SourceURL.String(),
	}
	if s.push != nil {
		info.VapidPublicKey = &s.vapid
	}
	if cfg.Billing {
		info.Billing = &ServerBilling{}
		if cfg.KofiURL != nil {
			kofi := cfg.KofiURL.String()
			info.Billing.KofiUrl = &kofi
		}
	}
	if cfg.PrivacyURL != nil {
		privacy := cfg.PrivacyURL.String()
		info.PrivacyUrl = &privacy
	}
	if cfg.MapStyle != "" {
		info.MapStyle = &cfg.MapStyle
	}
	if cfg.MapTiles != "" {
		info.MapTiles = &cfg.MapTiles
	}
	if cfg.MapStyle != "" || cfg.MapTiles != "" {
		info.MapAttribution = &cfg.MapAttribution
	}
	err := s.db.QueryRow(ctx, `select password_hash is null, setup_code is not null from admin`).
		Scan(&info.SetupRequired, &info.SetupCode)
	if err != nil {
		return nil, err
	}
	if info.Password && cfg.Signup != config.SignupOpen {
		// The first account may always sign up, so a closed server can start.
		err := s.db.QueryRow(ctx, `select not exists (select 1 from users)`).Scan(&info.FirstAccount)
		if err != nil {
			return nil, err
		}
	}
	if accounts {
		for _, p := range cfg.OAuthProviders() {
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
