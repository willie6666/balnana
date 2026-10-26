package api

import (
	"bytes"
	"context"
	"encoding/csv"
	"net/url"
	"strings"
	"time"

	"github.com/jackc/pgx/v5"

	"balnana/internal/domain"
)

// ExportCsv writes every live expense and payment of the group, oldest first,
// with one column per member holding what the entry did to their balance.
func (s *Server) ExportCsv(ctx context.Context, req ExportCsvRequestObject) (ExportCsvResponseObject, error) {
	offset := 0
	if req.Params.UtcOffset != nil {
		offset = *req.Params.UtcOffset
	}
	if offset < -840 || offset > 840 {
		return nil, badRequest("invalid_offset")
	}
	var out ExportCsv200TextcsvResponse
	err := pgx.BeginTxFunc(ctx, s.db, pgx.TxOptions{IsoLevel: pgx.RepeatableRead, AccessMode: pgx.ReadOnly},
		func(tx pgx.Tx) error {
			g, err := s.groupByToken(ctx, tx, req.Token, false)
			if err != nil {
				return err
			}
			out, err = exportCsv(ctx, tx, g, offset)
			return err
		})
	if err != nil {
		return nil, err
	}
	return out, nil
}

// exportCsv builds all columns and rows from the caller's database snapshot.
func exportCsv(ctx context.Context, q querier, g *group, offset int) (ExportCsv200TextcsvResponse, error) {
	members, err := groupMembers(ctx, q, g.id)
	if err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}

	// Paid counts up and shares count down, as in the balances.
	rows, err := q.Query(ctx, `
		select x.expense_id::text, x.member_id::text, sum(x.amount)::bigint from (
			select expense_id, member_id, amount from expense_payers
			union all
			select expense_id, member_id, -amount from expense_splits
		) x join expenses e on e.id = x.expense_id
		where e.group_id = $1 and e.deleted_at is null
		group by 1, 2`, g.id)
	if err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}
	nets := map[string]map[string]int64{}
	var eid, mid string
	var net int64
	_, err = pgx.ForEachRow(rows, []any{&eid, &mid, &net}, func() error {
		if nets[eid] == nil {
			nets[eid] = map[string]int64{}
		}
		nets[eid][mid] = net
		return nil
	})
	if err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}

	var buf bytes.Buffer
	buf.WriteString("\xef\xbb\xbf") // so spreadsheets read UTF-8
	w := csv.NewWriter(&buf)
	header := []string{"Date", "Title", "Category", "Type", "Amount", "Currency", "Note"}
	for _, m := range members {
		header = append(header, cellText(m.name))
	}
	if err := w.Write(header); err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}

	rows, err = q.Query(ctx, `
		select id::text, case when transaction_type = 'expense' then kind::text else transaction_type end, title, coalesce(category_id, ''), amount, occurred_at, coalesce(note, '')
		from expenses where group_id = $1 and deleted_at is null
		order by occurred_at, id`, g.id)
	if err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}
	zone := time.FixedZone("", offset*60)
	var kind, title, category, note string
	var amount int64
	var at time.Time
	_, err = pgx.ForEachRow(rows, []any{&eid, &kind, &title, &category, &amount, &at, &note}, func() error {
		record := []string{at.In(zone).Format(time.DateOnly), cellText(title), category, kind,
			domain.FormatAmount(amount, g.digits), g.currency, cellText(note)}
		for _, m := range members {
			record = append(record, domain.FormatAmount(nets[eid][m.id], g.digits))
		}
		return w.Write(record)
	})
	if err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}
	w.Flush()
	if err := w.Error(); err != nil {
		return ExportCsv200TextcsvResponse{}, err
	}
	return ExportCsv200TextcsvResponse{
		Body:          &buf,
		ContentLength: int64(buf.Len()),
		Headers:       ExportCsv200ResponseHeaders{ContentDisposition: attachment(g.name, ".csv")},
	}, nil
}

// cellText keeps text people typed from being read as a formula.
func cellText(s string) string {
	if s != "" && strings.ContainsRune("=+-@\t\r", rune(s[0])) {
		return "'" + s
	}
	return s
}

// attachment names a download after name: plain ASCII for old clients, and
// the name as typed for the rest.
func attachment(name, ext string) string {
	ascii := strings.Map(func(r rune) rune {
		switch {
		case r >= 'a' && r <= 'z', r >= 'A' && r <= 'Z', r >= '0' && r <= '9', r == '-', r == '_':
			return r
		case r == ' ':
			return '_'
		}
		return -1
	}, name)
	if strings.Trim(ascii, "_") == "" {
		ascii = "balnana"
	}
	return `attachment; filename="` + ascii + ext + `"; filename*=UTF-8''` + url.PathEscape(name+ext)
}
