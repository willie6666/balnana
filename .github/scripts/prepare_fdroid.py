#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-only
"""Prepare a dedicated Android build checkout for F-Droid's source scanner."""

import re
import shutil
from pathlib import Path
from tempfile import TemporaryDirectory
from zipfile import ZipFile

from prepare_sqlite import download_verified


# Match the SQLite version bundled by sqlite3 3.5.2 in app/pubspec.lock.
AMALGAMATION = "sqlite-amalgamation-3530400"
AMALGAMATION_URL = f"https://www.sqlite.org/2026/{AMALGAMATION}.zip"
AMALGAMATION_SHA256 = "1e71ddf93849c6a6ecf58b827c0692073d2dd7ee40196158068f7b29f422e87d"

SQLITE_HOOK = """hooks:
  user_defines:
    sqlite3:
      source: source
      path: .fdroid-build/sqlite3.c
"""


def main():
    app = Path(__file__).resolve().parents[2] / "app"
    packages = app / ".pub-cache" / "hosted" / "pub.dev"
    if not packages.is_dir():
        raise SystemExit("Run flutter pub get with PUB_CACHE set to app/.pub-cache first.")

    pubspec = app / "pubspec.yaml"
    contents = pubspec.read_text(encoding="utf-8")
    if re.search(r"^hooks\s*:", contents, re.MULTILINE) and not contents.endswith(SQLITE_HOOK):
        raise SystemExit("Merge the SQLite source setting into the existing pubspec hooks.")

    source_dir = app / ".fdroid-build"
    source_dir.mkdir(exist_ok=True)
    with TemporaryDirectory() as temporary:
        archive_path = Path(temporary) / f"{AMALGAMATION}.zip"
        download_verified(AMALGAMATION_URL, AMALGAMATION_SHA256, archive_path)
        with ZipFile(archive_path) as archive:
            for name in ("sqlite3.c", "sqlite3.h"):
                (source_dir / name).write_bytes(archive.read(f"{AMALGAMATION}/{name}"))

    if not contents.endswith(SQLITE_HOOK):
        pubspec.write_text(f"{contents.rstrip()}\n\n{SQLITE_HOOK}", encoding="utf-8")

    # Package demos and DevTools web bundles are outside the Android build.
    for package in packages.iterdir():
        for relative_path in ("example", "extension/devtools/build"):
            path = package / relative_path
            if path.is_dir():
                shutil.rmtree(path)


if __name__ == "__main__":
    main()
