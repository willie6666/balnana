package web

import (
	"bytes"
	"compress/gzip"
	"io"
	"io/fs"
	"mime"
	"net/http"
	"path"
	"strconv"
	"strings"
	"sync"
	"time"
)

// compressedExts are the extensions of build files that shrink under
// compression: main.dart.js and canvaskit.wasm, the bulk of the first load, to
// about a third. "" is assets/NOTICES. Images and woff fonts are compressed
// already.
var compressedExts = map[string]bool{
	".js": true, ".mjs": true, ".wasm": true, ".json": true, ".html": true,
	".css": true, ".svg": true, ".txt": true, ".ttf": true, ".otf": true,
	".map": true, ".symbols": true, ".frag": true, ".bin": true, "": true,
}

// minCompressSize is the size under which compressing is not worth a round of
// work for either end.
const minCompressSize = 1024

func compressible(name string, size int64) bool {
	return size >= minCompressSize && compressedExts[path.Ext(name)]
}

// accepts reports whether an Accept-Encoding header takes coding.
func accepts(header, coding string) bool {
	for part := range strings.SplitSeq(header, ",") {
		name, params, _ := strings.Cut(part, ";")
		if !strings.EqualFold(strings.TrimSpace(name), coding) {
			continue
		}
		for param := range strings.SplitSeq(params, ";") {
			k, v, _ := strings.Cut(param, "=")
			if strings.EqualFold(strings.TrimSpace(k), "q") {
				q, err := strconv.ParseFloat(strings.TrimSpace(v), 64)
				return err == nil && q > 0
			}
		}
		return true
	}
	return false
}

// compressor answers with files compressed. Brotli comes from a name.br file
// next to the original, made at build time by precompress.sh, since brotli at
// its best takes seconds for main.dart.js. Failing that, gzip is made the
// first time a file is asked for and kept. A file on disk that changes (a new
// build under BALNANA_WEB_DIR) is compressed again.
type compressor struct {
	gzipped sync.Map // name to *gzipEntry
}

type gzipEntry struct {
	once    sync.Once
	modTime time.Time
	size    int64

	body []byte // nil when gzip does not make the file smaller
	err  error
}

// serve answers with name compressed, if the browser takes a coding there is
// a smaller copy in, and reports whether it did. tag is the ETag of the plain
// file, or "".
func (c *compressor) serve(w http.ResponseWriter, r *http.Request, files fs.FS, name string, info fs.FileInfo, tag string) bool {
	if !compressible(name, info.Size()) {
		return false
	}
	// Any answer depends on the header, so caches must keep them apart.
	w.Header().Add("Vary", "Accept-Encoding")
	header := r.Header.Get("Accept-Encoding")
	if accepts(header, "br") {
		if f, ok := brotli(files, name, info); ok {
			defer f.Close()
			return c.send(w, r, files, name, info, tag, "br", f.(io.ReadSeeker))
		}
	}
	if accepts(header, "gzip") {
		if e := c.gzip(files, name, info); e.err == nil && e.body != nil {
			return c.send(w, r, files, name, info, tag, "gzip", bytes.NewReader(e.body))
		}
	}
	return false
}

func (c *compressor) send(w http.ResponseWriter, r *http.Request, files fs.FS, name string, info fs.FileInfo, tag, coding string, body io.ReadSeeker) bool {
	h := w.Header()
	if tag != "" {
		// The compressed bytes differ from the plain ones, so their tag must
		// too.
		h.Set("ETag", strings.TrimSuffix(tag, `"`)+"-"+coding+`"`)
	}
	h.Set("Content-Type", contentType(files, name))
	h.Set("Content-Encoding", coding)
	http.ServeContent(w, r, name, info.ModTime(), body)
	return true
}

// brotli opens name's prebuilt Brotli copy, if there is one that is smaller
// and no older than the file, so a build left without fresh copies falls back
// to gzip rather than serve the last one's.
func brotli(files fs.FS, name string, info fs.FileInfo) (fs.File, bool) {
	br, err := fs.Stat(files, name+".br")
	if err != nil || br.IsDir() || br.Size() >= info.Size() || br.ModTime().Before(info.ModTime()) {
		return nil, false
	}
	f, err := files.Open(name + ".br")
	if err != nil {
		return nil, false
	}
	if _, ok := f.(io.ReadSeeker); !ok {
		f.Close()
		return nil, false
	}
	return f, true
}

func (c *compressor) gzip(files fs.FS, name string, info fs.FileInfo) *gzipEntry {
	fresh := func() *gzipEntry { return &gzipEntry{modTime: info.ModTime(), size: info.Size()} }
	// LoadOrStore, so that the first visitors after a start share one
	// compression of the megabytes of main.dart.js.
	v, _ := c.gzipped.LoadOrStore(name, fresh())
	e := v.(*gzipEntry)
	if !e.modTime.Equal(info.ModTime()) || e.size != info.Size() {
		e = fresh()
		c.gzipped.Store(name, e)
	}
	e.once.Do(func() { e.compress(files, name) })
	return e
}

func (e *gzipEntry) compress(files fs.FS, name string) {
	data, err := fs.ReadFile(files, name)
	if err != nil {
		e.err = err
		return
	}
	var buf bytes.Buffer
	zw, _ := gzip.NewWriterLevel(&buf, gzip.BestCompression)
	if _, err := zw.Write(data); err != nil {
		e.err = err
		return
	}
	if err := zw.Close(); err != nil {
		e.err = err
		return
	}
	if buf.Len() < len(data) {
		e.body = buf.Bytes()
	}
}

// contentType is name's type as http.FileServer would give it: by extension,
// else by the start of its content.
func contentType(files fs.FS, name string) string {
	if t := mime.TypeByExtension(path.Ext(name)); t != "" {
		return t
	}
	f, err := files.Open(name)
	if err != nil {
		return "application/octet-stream"
	}
	defer f.Close()
	head := make([]byte, 512)
	n, _ := io.ReadFull(f, head)
	return http.DetectContentType(head[:n])
}
