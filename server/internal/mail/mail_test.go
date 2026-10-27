package mail

import (
	"testing"

	"balnana/internal/config"
)

func TestPlaintextAllowed(t *testing.T) {
	for _, tc := range []struct {
		host  string
		allow bool
		want  bool
	}{
		{"localhost", false, true},
		{"127.0.0.1", false, true},
		{"::1", false, true},
		{"smtp.example.com", false, false},
		{"192.168.1.2", false, false},
		{"smtp.example.com", true, true},
	} {
		if got := plaintextAllowed(config.SMTP{Host: tc.host, AllowPlaintext: tc.allow}); got != tc.want {
			t.Errorf("%s allow=%v: %v", tc.host, tc.allow, got)
		}
	}
}
