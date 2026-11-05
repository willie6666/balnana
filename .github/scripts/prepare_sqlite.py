#!/usr/bin/env python3
"""Fetch the locked sqlite3 package's Linux test library with verified retries.

Run after flutter pub get. The package's build hook checks the SHA-256 again;
this only primes its documented shared download cache using a reliable HTTP client.
"""

import hashlib
from http.client import HTTPException
import json
import os
from pathlib import Path
import platform
import re
import sys
import tempfile
import time
from urllib.parse import urljoin, urlparse, unquote
from urllib.error import HTTPError
from urllib.request import Request, urlopen


def sha256_file(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def sqlite_asset(app):
    config = (app / ".dart_tool/package_config.json").resolve()
    packages = json.loads(config.read_text())["packages"]
    package = next(item for item in packages if item["name"] == "sqlite3")
    root = urlparse(urljoin(config.as_uri(), package["rootUri"]))
    if root.scheme != "file" or root.netloc not in ("", "localhost"):
        raise RuntimeError("sqlite3 must resolve to a local package after flutter pub get")
    hashes = (Path(unquote(root.path)) / "lib/src/hook/asset_hashes.dart").read_text()
    release = re.search(r"releaseTag\s*=\s*'([^']+)'", hashes)
    digest = re.search(r"'libsqlite3\.x64\.linux\.so'\s*:\s*'([0-9a-f]{64})'", hashes)
    if not release or not digest:
        raise RuntimeError("sqlite3 hook metadata changed; review the CI download helper")
    tag, expected = release.group(1), digest.group(1)
    if not re.fullmatch(r"sqlite3-[0-9A-Za-z.+-]+", tag):
        raise RuntimeError(f"Unexpected sqlite3 release tag: {tag}")
    url = f"https://github.com/simolus3/sqlite3.dart/releases/download/{tag}/libsqlite3.x64.linux.so"
    cache = app / f".dart_tool/hooks_runner/shared/sqlite3/build/download-{expected[:8]}/libsqlite3.so"
    return url, expected, cache


def download_verified(url, expected, target, attempts=4, retry_delay=2):
    target.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(attempts):
        temporary = None
        try:
            request = Request(url, headers={"User-Agent": "Balnana-CI-SQLite-prefetch", "Accept": "application/octet-stream"})
            with urlopen(request, timeout=45) as response, tempfile.NamedTemporaryFile(
                dir=target.parent, prefix="sqlite-", suffix=".tmp", delete=False
            ) as output:
                temporary = Path(output.name)
                for chunk in iter(lambda: response.read(128 * 1024), b""):
                    output.write(chunk)
            actual = sha256_file(temporary)
            if actual != expected:
                raise ValueError(f"SQLite SHA-256 mismatch: {actual}, expected {expected}")
            os.replace(temporary, target)
            print(f"Verified SQLite asset: {expected}")
            return
        except (OSError, ValueError, HTTPException) as error:
            if isinstance(error, HTTPError):
                error.close()
            print(f"SQLite download {attempt + 1}/{attempts} failed: {error}", file=sys.stderr)
            if attempt + 1 == attempts:
                raise RuntimeError("Could not download the verified SQLite native asset") from error
            time.sleep(retry_delay * 2**attempt)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)


def main():
    if sys.platform != "linux" or platform.machine().lower() not in ("x86_64", "amd64"):
        raise RuntimeError("This CI helper is for Linux x64 runners")
    app = Path(sys.argv[1] if len(sys.argv) > 1 else "app").resolve()
    url, expected, target = sqlite_asset(app)
    if target.exists() and sha256_file(target) == expected:
        print(f"Using verified SQLite asset: {expected}")
    else:
        download_verified(url, expected, target)


if __name__ == "__main__":
    main()
