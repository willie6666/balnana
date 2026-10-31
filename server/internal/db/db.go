// Package db opens the PostgreSQL pool and applies migrations.
package db

import (
	"context"
	"fmt"
	"log/slog"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
	"github.com/pressly/goose/v3/lock"

	"balnana/migrations"
)

// maxConns is the pool's size unless the URL sets pool_max_conns: enough that
// a long import leaves room for everything else.
const maxConns = 20

// statementTimeout ends a statement stuck for far longer than any request
// should take, unless the URL sets its own. Migrations run without it.
const statementTimeout = "60s"

// Open connects to PostgreSQL and verifies the connection.
func Open(ctx context.Context, url string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(url)
	if err != nil {
		return nil, fmt.Errorf("parse database url: %w", err)
	}
	if !strings.Contains(url, "pool_max_conns") {
		cfg.MaxConns = maxConns
	}
	if _, set := cfg.ConnConfig.RuntimeParams["statement_timeout"]; !set {
		cfg.ConnConfig.RuntimeParams["statement_timeout"] = statementTimeout
	}
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("connect to database: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("connect to database: %w", err)
	}
	return pool, nil
}

// Migrate brings the schema up to date with the embedded migrations. Servers
// starting together take turns, by a lock held on a connection of its own.
func Migrate(ctx context.Context, pool *pgxpool.Pool, log *slog.Logger) error {
	cfg := pool.Config()
	cfg.MinConns, cfg.MaxConns = 0, 2
	cfg.ConnConfig.RuntimeParams["statement_timeout"] = "0"
	conns, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return fmt.Errorf("connect to database: %w", err)
	}
	defer conns.Close()
	sqlDB := stdlib.OpenDBFromPool(conns)
	defer sqlDB.Close()

	locker, err := lock.NewPostgresSessionLocker()
	if err != nil {
		return fmt.Errorf("prepare migration lock: %w", err)
	}
	provider, err := goose.NewProvider(goose.DialectPostgres, sqlDB, migrations.FS, goose.WithSessionLocker(locker))
	if err != nil {
		return fmt.Errorf("load migrations: %w", err)
	}
	results, err := provider.Up(ctx)
	for _, r := range results {
		log.Info("migration applied", "version", r.Source.Version, "file", r.Source.Path, "duration", r.Duration)
	}
	if err != nil {
		return fmt.Errorf("apply migrations: %w", err)
	}
	version, err := provider.GetDBVersion(ctx)
	if err != nil {
		return fmt.Errorf("read schema version: %w", err)
	}
	log.Info("database schema ready", "version", version)
	return nil
}
