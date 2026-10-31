// Command balnana runs the Balnana server: API, web app and migrations.
//
//	balnana              start the server (configured by BALNANA_* env vars)
//	balnana healthcheck  exit 0 if the local server is healthy (for Docker)
//	balnana reset-admin  forget the administrator password and print a setup code
//	balnana version      print the version
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
	// Readers' time zones are looked up even in an image without tzdata.
	_ "time/tzdata"

	"github.com/jackc/pgx/v5/pgxpool"

	"balnana/internal/api"
	"balnana/internal/config"
	"balnana/internal/db"
	"balnana/internal/web"
)

// version is set at build time with -ldflags "-X main.version=...".
var version = "dev"

func main() {
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "healthcheck":
			os.Exit(healthcheck())
		case "reset-admin":
			if err := resetAdmin(); err != nil {
				fmt.Fprintln(os.Stderr, err)
				os.Exit(1)
			}
			return
		case "version":
			fmt.Println(version)
			return
		default:
			fmt.Fprintf(os.Stderr, "unknown command %q (expected healthcheck, reset-admin or version)\n", os.Args[1])
			os.Exit(2)
		}
	}
	if err := run(); err != nil {
		slog.Error("fatal", "err", err)
		os.Exit(1)
	}
}

func run() error {
	// Settings an administrator saved are checked once the database is up.
	cfg, err := config.Startup()
	if err != nil {
		return fmt.Errorf("invalid configuration:\n%w", err)
	}
	log := slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: cfg.LogLevel}))
	slog.SetDefault(log)

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := connect(ctx, log, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()
	if err := db.Migrate(ctx, pool, log); err != nil {
		return err
	}

	srv := api.NewServer(cfg, pool, log, version)
	if err := srv.LoadSettings(ctx); err != nil {
		return fmt.Errorf("invalid configuration:\n%w", err)
	}
	if err := srv.PrepareAdmin(ctx); err != nil {
		return err
	}
	if err := srv.NameIdentityIssuers(ctx); err != nil {
		return err
	}
	if cfg.Push {
		if err := srv.StartPush(ctx); err != nil {
			return err
		}
	}
	// Stops with ctx, which also ends open event streams so shutdown need
	// not wait for them.
	go srv.ListenForChanges(ctx)
	go srv.SweepExpired(ctx)
	go srv.RunRecurring(ctx)
	httpServer := &http.Server{
		Addr:              cfg.Listen,
		Handler:           api.NewHandler(srv, web.Handler(cfg.WebDir)),
		ReadHeaderTimeout: 10 * time.Second,
		IdleTimeout:       2 * time.Minute,
	}

	errc := make(chan error, 1)
	go func() {
		log.Info("balnana listening", "addr", cfg.Listen, "version", version)
		errc <- httpServer.ListenAndServe()
	}()

	select {
	case err := <-errc:
		return err
	case <-ctx.Done():
	}
	log.Info("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err = httpServer.Shutdown(shutdownCtx)
	srv.FinishPushes()
	srv.FinishMail()
	return err
}

// resetAdmin is for a lost administrator password: /admin then asks for a
// new one, with the code it prints.
func resetAdmin() error {
	cfg, err := config.Startup()
	if err != nil {
		return fmt.Errorf("invalid configuration:\n%w", err)
	}
	log := slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: cfg.LogLevel}))
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	pool, err := connect(ctx, log, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()
	if err := db.Migrate(ctx, pool, log); err != nil {
		return err
	}
	code, err := api.ResetAdmin(ctx, pool)
	if err != nil {
		return err
	}
	fmt.Printf("The administrator password is cleared and everyone is signed out of /admin.\n"+
		"Open /admin to set a new password, with this setup code: %s\n", code)
	return nil
}

// connect retries for a while: in docker compose the database may still be
// starting when the server comes up.
func connect(ctx context.Context, log *slog.Logger, url string) (*pgxpool.Pool, error) {
	deadline := time.Now().Add(60 * time.Second)
	for {
		pool, err := db.Open(ctx, url)
		if err == nil {
			return pool, nil
		}
		if time.Now().After(deadline) || ctx.Err() != nil {
			return nil, err
		}
		log.Warn("database not ready, retrying", "err", err)
		select {
		case <-time.After(2 * time.Second):
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}
}

func healthcheck() int {
	addr := os.Getenv("BALNANA_LISTEN")
	if addr == "" {
		addr = ":8080"
	}
	host, port, err := net.SplitHostPort(addr)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	if host == "" || host == "0.0.0.0" || host == "::" {
		host = "127.0.0.1"
	}
	client := &http.Client{Timeout: 3 * time.Second}
	resp, err := client.Get("http://" + net.JoinHostPort(host, port) + "/healthz")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		fmt.Fprintln(os.Stderr, errors.New(resp.Status))
		return 1
	}
	return 0
}
