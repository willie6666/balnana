package api

import (
	"strings"
	"testing"
)

func TestGroupCategories(t *testing.T) {
	c := newClient(t)
	g := createGroup(c, "Ana", "Ben")
	other := createGroup(c, "Zed")
	ana := g.Members[0].Id
	if len(g.Categories) != 12 || g.Categories[0].Id != "food" || !g.Categories[0].BuiltIn {
		t.Fatalf("built-in categories: %+v", g.Categories)
	}

	var pets Category
	c.must(201, "POST", "/g/"+g.Token+"/categories", CategoryInput{Name: "Pets", Emoji: "🐶"}, &pets)
	if pets.BuiltIn || pets.Name == nil || *pets.Name != "Pets" || pets.Color != defaultCategoryColor {
		t.Fatalf("added: %+v", pets)
	}
	if code := c.errorCode(409, "POST", "/g/"+g.Token+"/categories", CategoryInput{Name: "pets", Emoji: "🐱"}); code != "duplicate_name" {
		t.Errorf("duplicate: %q", code)
	}
	if code := c.errorCode(400, "POST", "/g/"+g.Token+"/categories", CategoryInput{Name: "Bare", Emoji: " "}); code != "invalid_emoji" {
		t.Errorf("no emoji: %q", code)
	}

	// The category is the group's own: other groups cannot use it.
	in := ExpenseInput{
		Title:       "Vet",
		CategoryId:  &pets.Id,
		Amount:      "30.00",
		OccurredAt:  mustTime(t, "2026-10-01T10:00:00Z"),
		Payers:      []PayerInput{{MemberId: ana, Amount: "30.00"}},
		SplitMethod: "equal",
		Splits:      []Share{{MemberId: ana}},
	}
	var e Expense
	c.must(201, "POST", "/g/"+g.Token+"/expenses", in, &e)
	in.Payers = []PayerInput{{MemberId: other.Members[0].Id, Amount: "30.00"}}
	in.Splits = []Share{{MemberId: other.Members[0].Id}}
	if code := c.errorCode(400, "POST", "/g/"+other.Token+"/expenses", in); code != "invalid_category" {
		t.Errorf("other group: %q", code)
	}
	c.errorCode(404, "PATCH", "/g/"+other.Token+"/categories/"+pets.Id, CategoryUpdate{Hidden: ptr(true)})

	// Custom categories change; built-in ones only hide.
	var changed Category
	c.must(200, "PATCH", "/g/"+g.Token+"/categories/"+pets.Id, CategoryUpdate{Name: ptr("Animals"), Color: ptr(0x112233)}, &changed)
	if *changed.Name != "Animals" || changed.Emoji != "🐶" || changed.Color != 0x112233 {
		t.Errorf("changed: %+v", changed)
	}
	if code := c.errorCode(400, "PATCH", "/g/"+g.Token+"/categories/rent", CategoryUpdate{Name: ptr("Flat")}); code != "builtin_category" {
		t.Errorf("rename built-in: %q", code)
	}
	c.must(200, "PATCH", "/g/"+g.Token+"/categories/rent", CategoryUpdate{Hidden: ptr(true)}, nil)
	var got Group
	c.must(200, "GET", "/g/"+g.Token, nil, &got)
	hidden := map[string]bool{}
	for _, cat := range got.Categories {
		hidden[cat.Id] = cat.Hidden
	}
	if !hidden["rent"] || hidden["food"] || len(got.Categories) != 13 || got.Categories[12].Id != pets.Id {
		t.Errorf("after hiding: %+v", got.Categories)
	}
	c.must(200, "GET", "/g/"+other.Token, nil, &got)
	if len(got.Categories) != 12 || got.Categories[5].Hidden {
		t.Errorf("other group sees: %+v", got.Categories)
	}

	csv := get(t, c.h, BasePath+"/g/"+g.Token+"/export.csv", nil).Body.String()
	if !strings.Contains(csv, "Animals") {
		t.Errorf("export lacks the category name:\n%s", csv)
	}

	// Deleting it leaves its expenses without a category.
	if code := c.errorCode(400, "DELETE", "/g/"+g.Token+"/categories/food", nil); code != "builtin_category" {
		t.Errorf("delete built-in: %q", code)
	}
	c.must(204, "DELETE", "/g/"+g.Token+"/categories/"+pets.Id, nil, nil)
	var after Expense
	c.must(200, "GET", "/g/"+g.Token+"/expenses/"+e.Id, nil, &after)
	if after.CategoryId != nil || after.Version != e.Version+1 {
		t.Errorf("after delete: category %v, version %d", after.CategoryId, after.Version)
	}
}
