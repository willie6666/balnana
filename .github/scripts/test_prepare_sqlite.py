import hashlib
from contextlib import redirect_stderr, redirect_stdout
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import importlib.util
from io import StringIO
from pathlib import Path
import tempfile
from threading import Thread
import unittest

spec = importlib.util.spec_from_file_location("prepare_sqlite", Path(__file__).with_name("prepare_sqlite.py"))
prepare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepare)


class DownloadTests(unittest.TestCase):
    library = b"verified-test-sqlite-library"
    expected = hashlib.sha256(library).hexdigest()

    def download(self, responses, target, attempts=3):
        class Handler(BaseHTTPRequestHandler):
            calls = 0

            def do_GET(self):
                status, body = responses[min(self.calls, len(responses) - 1)]
                type(self).calls += 1
                self.send_response(status)
                self.end_headers()
                self.wfile.write(body)

            def log_message(self, *_):
                pass

        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = Thread(target=server.serve_forever)
        thread.start()
        try:
            with redirect_stdout(StringIO()), redirect_stderr(StringIO()):
                prepare.download_verified(
                    f"http://127.0.0.1:{server.server_port}/sqlite.so", self.expected, target,
                    attempts=attempts, retry_delay=0,
                )
            return Handler.calls
        finally:
            server.shutdown()
            server.server_close()
            thread.join()

    def test_retries_unexpected_content_before_caching(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "libsqlite3.so"
            calls = self.download([(200, b"an error page instead of a library"), (200, self.library)], target)
            self.assertEqual(calls, 2)
            self.assertEqual(target.read_bytes(), self.library)
            self.assertEqual(list(Path(directory).glob("*.tmp")), [])

    def test_retries_http_error(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "libsqlite3.so"
            calls = self.download([(503, b"unavailable"), (200, self.library)], target)
            self.assertEqual(calls, 2)
            self.assertEqual(target.read_bytes(), self.library)

    def test_rejects_persistent_bad_content_and_preserves_existing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "libsqlite3.so"
            target.write_bytes(b"existing library")
            with self.assertRaises(RuntimeError):
                self.download([(200, b"incorrect content")], target, attempts=2)
            self.assertEqual(target.read_bytes(), b"existing library")
            self.assertEqual(list(Path(directory).glob("*.tmp")), [])


if __name__ == "__main__":
    unittest.main()
