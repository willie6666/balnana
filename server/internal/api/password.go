package api

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"fmt"
	"strings"
	"unicode/utf8"

	"golang.org/x/crypto/argon2"
)

// argon2id settings from the OWASP password storage cheat sheet.
const (
	argonTime    = 2
	argonMemory  = 19 * 1024 // KiB
	argonThreads = 1
	argonKeyLen  = 32
	argonSaltLen = 16

	minPasswordLen = 8
	maxPasswordLen = 200
)

// hashSlots caps concurrent hashing: each one holds argonMemory, so a burst
// of sign-ins must not run the server out of memory.
var hashSlots = make(chan struct{}, 4)

func argonKey(password string, salt []byte, time, memory uint32, threads uint8) []byte {
	hashSlots <- struct{}{}
	defer func() { <-hashSlots }()
	return argon2.IDKey([]byte(password), salt, time, memory, threads, argonKeyLen)
}

// hashPassword returns the password's argon2id hash in the PHC string format.
func hashPassword(password string) string {
	salt := make([]byte, argonSaltLen)
	_, _ = rand.Read(salt)
	key := argonKey(password, salt, argonTime, argonMemory, argonThreads)
	b64 := base64.RawStdEncoding
	return fmt.Sprintf("$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version, argonMemory, argonTime, argonThreads, b64.EncodeToString(salt), b64.EncodeToString(key))
}

// checkPassword reports whether password matches a hash from hashPassword.
// Hashes made with older settings still verify.
func checkPassword(hash, password string) bool {
	parts := strings.Split(hash, "$")
	if len(parts) != 6 || parts[1] != "argon2id" {
		return false
	}
	var version int
	var memory, time uint32
	var threads uint8
	if _, err := fmt.Sscanf(parts[2], "v=%d", &version); err != nil || version != argon2.Version {
		return false
	}
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &memory, &time, &threads); err != nil {
		return false
	}
	b64 := base64.RawStdEncoding
	salt, err1 := b64.DecodeString(parts[4])
	want, err2 := b64.DecodeString(parts[5])
	if err1 != nil || err2 != nil || len(want) != argonKeyLen {
		return false
	}
	got := argonKey(password, salt, time, memory, threads)
	return subtle.ConstantTimeCompare(got, want) == 1
}

// dummyHash is checked against when an email is unknown, so a failed sign-in
// takes as long whether or not the account exists.
var dummyHash = hashPassword("balnana dummy password")

func validPassword(p string) error {
	n := utf8.RuneCountInString(p)
	if n < minPasswordLen || n > maxPasswordLen || !utf8.ValidString(p) {
		return badRequest("invalid_password")
	}
	return nil
}
