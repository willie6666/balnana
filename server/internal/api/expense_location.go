package api

import (
	"encoding/json"
	"errors"
	"strings"
)

// cleanLocation checks where an expense happened. A location with neither a
// name nor a point is none.
func cleanLocation(in Location) (*Location, error) {
	var out Location
	if in.Name != nil {
		name, ok := cleanText(*in.Name, 0, maxTitleLen)
		if !ok || strings.Contains(name, "\n") {
			return nil, badRequest("invalid_location")
		}
		if name != "" {
			out.Name = &name
		}
	}
	if p := in.Point; p != nil {
		// NaN fails both comparisons, so it is refused too.
		if !(p.Latitude >= -90 && p.Latitude <= 90 && p.Longitude >= -180 && p.Longitude <= 180) {
			return nil, badRequest("invalid_location")
		}
		out.Point = &GeoPoint{Latitude: p.Latitude, Longitude: p.Longitude}
	}
	if out.Name == nil && out.Point == nil {
		return nil, nil
	}
	return &out, nil
}

var errNoCoordinate = errors.New("a point needs both coordinates")

// UnmarshalJSON refuses a point missing a coordinate, which would otherwise
// be 0.
func (p *GeoPoint) UnmarshalJSON(b []byte) error {
	var in struct {
		Latitude  *float64 `json:"latitude"`
		Longitude *float64 `json:"longitude"`
	}
	if err := json.Unmarshal(b, &in); err != nil {
		return err
	}
	if in.Latitude == nil || in.Longitude == nil {
		return errNoCoordinate
	}
	p.Latitude, p.Longitude = *in.Latitude, *in.Longitude
	return nil
}

// locationColumns splits a location into its location_name, latitude and
// longitude columns.
func locationColumns(l *Location) (name *string, lat, lng *float64) {
	if l == nil {
		return nil, nil, nil
	}
	if l.Point != nil {
		lat, lng = &l.Point.Latitude, &l.Point.Longitude
	}
	return l.Name, lat, lng
}

// locationOf joins the location_name, latitude and longitude columns back
// into a location.
func locationOf(name *string, lat, lng *float64) *Location {
	if name == nil && lat == nil {
		return nil
	}
	l := &Location{Name: name}
	if lat != nil && lng != nil {
		l.Point = &GeoPoint{Latitude: *lat, Longitude: *lng}
	}
	return l
}
