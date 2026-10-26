package api

import (
	"context"
	"errors"

	"github.com/jackc/pgx/v5"
)

const (
	maxCategories        = 50
	defaultCategoryColor = 0x5D6B82
)

// groupCategories lists the built-in categories, then the group's own, with
// whether the group hides each.
func groupCategories(ctx context.Context, q querier, groupID string) ([]Category, error) {
	rows, err := q.Query(ctx, `
		select c.id, c.name, c.emoji, c.color, c.group_id is null,
		       exists (select 1 from group_hidden_categories h where h.group_id = $1 and h.category_id = c.id)
		from categories c
		where c.group_id is null or c.group_id = $1
		order by c.group_id nulls first, c.position, c.created_at, c.id`, groupID)
	if err != nil {
		return nil, err
	}
	out := []Category{}
	var c Category
	_, err = pgx.ForEachRow(rows, []any{&c.Id, &c.Name, &c.Emoji, &c.Color, &c.BuiltIn, &c.Hidden}, func() error {
		out = append(out, c)
		c = Category{}
		return nil
	})
	return out, err
}

// groupCategory finds a category the group can use, locked for a change.
func groupCategory(ctx context.Context, q querier, groupID, id string) (*Category, error) {
	var c Category
	err := q.QueryRow(ctx, `
		select c.id, c.name, c.emoji, c.color, c.group_id is null,
		       exists (select 1 from group_hidden_categories h where h.group_id = $1 and h.category_id = c.id)
		from categories c
		where c.id = $2 and (c.group_id is null or c.group_id = $1)`, groupID, id).
		Scan(&c.Id, &c.Name, &c.Emoji, &c.Color, &c.BuiltIn, &c.Hidden)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, errNotFound
	}
	if err != nil {
		return nil, err
	}
	return &c, nil
}

// checkCategoryNameFree refuses a name another of the group's own categories uses.
func checkCategoryNameFree(ctx context.Context, q querier, groupID, name, except string) error {
	var taken bool
	err := q.QueryRow(ctx, `
		select exists (select 1 from categories where group_id = $1 and lower(name) = lower($2) and id <> $3)`,
		groupID, name, except).Scan(&taken)
	if err != nil {
		return err
	}
	if taken {
		return conflict("duplicate_name")
	}
	return nil
}

func categoryEmoji(e string) (string, error) {
	v, err := cleanEmoji(&e)
	if err != nil {
		return "", err
	}
	if v == nil {
		return "", badRequest("invalid_emoji")
	}
	return *v, nil
}

func (s *Server) AddCategory(ctx context.Context, req AddCategoryRequestObject) (AddCategoryResponseObject, error) {
	name, err := cleanName(req.Body.Name)
	if err != nil {
		return nil, err
	}
	emoji, err := categoryEmoji(req.Body.Emoji)
	if err != nil {
		return nil, err
	}
	if err := validColor(req.Body.Color); err != nil {
		return nil, err
	}
	color := defaultCategoryColor
	if req.Body.Color != nil {
		color = *req.Body.Color
	}
	out := Category{Name: &name, Emoji: emoji, Color: color}
	err = pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		var count int
		if err := tx.QueryRow(ctx, `select count(*) from categories where group_id = $1`, g.id).Scan(&count); err != nil {
			return err
		}
		if count >= maxCategories {
			return badRequest("too_many_categories")
		}
		if err := checkCategoryNameFree(ctx, tx, g.id, name, ""); err != nil {
			return err
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		err = tx.QueryRow(ctx, `
			insert into categories (id, group_id, name, emoji, color, position, created_at)
			values (gen_random_uuid()::text, $1, $2, $3, $4, $5, clock_timestamp()) returning id`,
			g.id, name, emoji, color, count).Scan(&out.Id)
		if err != nil {
			return err
		}
		return logActivity(ctx, tx, g.id, who, "category.added", nil, map[string]any{"name": name, "emoji": emoji})
	})
	if err != nil {
		return nil, err
	}
	return AddCategory201JSONResponse(out), nil
}

func (s *Server) UpdateCategory(ctx context.Context, req UpdateCategoryRequestObject) (UpdateCategoryResponseObject, error) {
	in := req.Body
	var name *string
	if in.Name != nil {
		n, err := cleanName(*in.Name)
		if err != nil {
			return nil, err
		}
		name = &n
	}
	var emoji *string
	if in.Emoji != nil {
		e, err := categoryEmoji(*in.Emoji)
		if err != nil {
			return nil, err
		}
		emoji = &e
	}
	if err := validColor(in.Color); err != nil {
		return nil, err
	}
	var out Category
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		c, err := groupCategory(ctx, tx, g.id, req.CategoryId)
		if err != nil {
			return err
		}
		if c.BuiltIn && (name != nil || emoji != nil || in.Color != nil) {
			return badRequest("builtin_category")
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		if !c.BuiltIn {
			if name != nil {
				if err := checkCategoryNameFree(ctx, tx, g.id, *name, c.Id); err != nil {
					return err
				}
			}
			err = tx.QueryRow(ctx, `
				update categories set name = coalesce($2, name), emoji = coalesce($3, emoji), color = coalesce($4, color)
				where id = $1 returning name, emoji, color`, c.Id, name, emoji, in.Color).
				Scan(&c.Name, &c.Emoji, &c.Color)
			if err != nil {
				return err
			}
		}
		if in.Hidden != nil && *in.Hidden != c.Hidden {
			if *in.Hidden {
				_, err = tx.Exec(ctx, `insert into group_hidden_categories (group_id, category_id) values ($1, $2)`, g.id, c.Id)
			} else {
				_, err = tx.Exec(ctx, `delete from group_hidden_categories where group_id = $1 and category_id = $2`, g.id, c.Id)
			}
			if err != nil {
				return err
			}
			c.Hidden = *in.Hidden
		}
		payload := map[string]any{"id": c.Id, "emoji": c.Emoji}
		if c.Name != nil {
			payload["name"] = *c.Name
		}
		if err := logActivity(ctx, tx, g.id, who, "category.updated", nil, payload); err != nil {
			return err
		}
		out = *c
		return nil
	})
	if err != nil {
		return nil, err
	}
	return UpdateCategory200JSONResponse(out), nil
}

func (s *Server) DeleteCategory(ctx context.Context, req DeleteCategoryRequestObject) (DeleteCategoryResponseObject, error) {
	err := pgx.BeginFunc(ctx, s.db, func(tx pgx.Tx) error {
		g, err := s.groupByToken(ctx, tx, req.Token, true)
		if err != nil {
			return err
		}
		c, err := groupCategory(ctx, tx, g.id, req.CategoryId)
		if err != nil {
			return err
		}
		if c.BuiltIn {
			return badRequest("builtin_category")
		}
		who, err := actor(ctx, tx, g, req.Params.XBalnanaMember)
		if err != nil {
			return err
		}
		// Bump its expenses' versions so copies kept on devices update too.
		_, err = tx.Exec(ctx, `
			update expenses set category_id = null, version = version + 1, updated_at = now()
			where group_id = $1 and category_id = $2`, g.id, c.Id)
		if err != nil {
			return err
		}
		if _, err := tx.Exec(ctx, `delete from categories where id = $1`, c.Id); err != nil {
			return err
		}
		return logActivity(ctx, tx, g.id, who, "category.deleted", nil, map[string]any{"name": *c.Name, "emoji": c.Emoji})
	})
	if err != nil {
		return nil, err
	}
	return DeleteCategory204Response{}, nil
}
