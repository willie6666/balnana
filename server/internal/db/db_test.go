package db

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"log/slog"
	"os"
	"testing"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// noDB skips a test without a database, unless REQUIRE_DB says one is expected.
func noDB(t *testing.T, format string, args ...any) {
	t.Helper()
	if os.Getenv("REQUIRE_DB") != "" {
		t.Fatalf(format, args...)
	}
	t.Skipf(format, args...)
}

// Servers starting together wait for each other's migrations.
func TestMigrateAtOnce(t *testing.T) {
	url := os.Getenv("DATABASE_URL")
	if url == "" {
		noDB(t, "DATABASE_URL not set")
	}
	ctx := context.Background()
	admin, err := pgx.Connect(ctx, url)
	if err != nil {
		noDB(t, "no database: %v", err)
	}
	b := make([]byte, 6)
	_, _ = rand.Read(b)
	name := "balnana_test_" + hex.EncodeToString(b)
	if _, err := admin.Exec(ctx, "create database "+name); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_, _ = admin.Exec(context.Background(), "drop database "+name+" with (force)")
		admin.Close(context.Background())
	})
	cfg, err := pgxpool.ParseConfig(url)
	if err != nil {
		t.Fatal(err)
	}
	cfg.ConnConfig.Database = name

	errs := make(chan error, 4)
	for range cap(errs) {
		go func() {
			pool, err := pgxpool.NewWithConfig(ctx, cfg)
			if err != nil {
				errs <- err
				return
			}
			defer pool.Close()
			errs <- Migrate(ctx, pool, slog.New(slog.DiscardHandler))
		}()
	}
	for range cap(errs) {
		if err := <-errs; err != nil {
			t.Error(err)
		}
	}
}
