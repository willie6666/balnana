// Package migrations embeds the goose SQL migrations so the server binary can
// migrate its own database on startup.
package migrations

import "embed"

//go:embed *.sql
var FS embed.FS
