#!/usr/bin/env python3
"""Validate exported test HTTP exchanges against PayPal's current official schemas.

Requires jsonschema. Run the fixture export and this script as documented in
README.md. No credentials or real payment requests are used.
"""
import argparse
import hashlib
import json
import re
import urllib.request
from pathlib import Path

from jsonschema import Draft202012Validator, FormatChecker

SCHEMAS = {
    "orders": "orders/v2",
    "payments": "payments/v2",
    "subscriptions": "subscriptions/v1",
    "webhooks": "webhooks/v1",
    "legacy": "deprecated/payments/v1",
}


def resolve(document, schema):
    if "$ref" in schema:
        node = document
        for part in schema["$ref"].removeprefix("#/").split("/"):
            node = node[part.replace("~1", "/").replace("~0", "~")]
        return node
    return schema


def validate(document, schema, value, label):
    root = {**schema, "components": document.get("components", {})}
    errors = sorted(
        Draft202012Validator(root, format_checker=FormatChecker()).iter_errors(value),
        key=lambda error: str(list(error.path)),
    )
    if errors:
        details = "\n".join(f"  {list(e.path)}: {e.message}" for e in errors)
        raise ValueError(f"{label}\n{details}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("exchanges", help="PAYPAL_CONTRACT_OUTPUT JSON from TestPayPalContractFixtures")
    parser.add_argument("--schema-dir", type=Path, help="Read cached official <name>.json schemas, downloading missing files")
    args = parser.parse_args()
    documents = []
    for name, path in SCHEMAS.items():
        url = f"https://developer.paypal.com/api/{path}/schema.json"
        cache = args.schema_dir / f"{name}.json" if args.schema_dir else None
        if cache and cache.exists():
            raw = cache.read_bytes()
        else:
            request = urllib.request.Request(url, headers={"User-Agent": "Balnana-PayPal-API-audit", "Accept": "application/json"})
            with urllib.request.urlopen(request, timeout=30) as response:
                raw = response.read()
            if cache:
                cache.parent.mkdir(parents=True, exist_ok=True)
                cache.write_bytes(raw)
        document = json.loads(raw)
        documents.append(document)
        canonical = json.dumps(document, sort_keys=True, separators=(",", ":")).encode()
        print(f"{name} {document['info']['version']} canonical-sha256={hashlib.sha256(canonical).hexdigest()}")

    covered = set()
    with open(args.exchanges) as stream:
        exchanges = json.load(stream)
    for exchange in exchanges:
        method = exchange["method"].lower()
        matches = []
        for document in documents:
            for template, operations in document["paths"].items():
                names = re.findall(r"\{([^}]+)\}", template)
                pattern = re.sub(r"\\\{[^}]+\\\}", r"([^/]+)", re.escape(template))
                match = re.fullmatch(pattern, exchange["path"])
                if match and method in operations:
                    matches.append((document, template, operations[method], dict(zip(names, match.groups()))))
        if len(matches) != 1:
            raise ValueError(f"Expected one official endpoint for {method} {exchange['path']}: {len(matches)}")
        document, template, operation, path_parameters = matches[0]
        label = f"{method.upper()} {template}"
        covered.add(label)
        headers = {key.lower(): values[0] for key, values in exchange["header"].items()}
        for parameter in operation.get("parameters", []):
            parameter = resolve(document, parameter)
            location = parameter["in"]
            source = {"path": path_parameters, "query": exchange["query"], "header": headers}.get(location)
            key = parameter["name"].lower() if location == "header" else parameter["name"]
            if source is not None and key in source:
                value = source[key]
                if isinstance(value, list):
                    value = value[0]
                validate(document, parameter["schema"], value, f"{label} {location} {key}")
            elif source is not None and parameter.get("required"):
                raise ValueError(f"{label}: missing required {location} {key}")
        if "requestBody" in operation:
            body = resolve(document, operation["requestBody"])
            if "body" in exchange:
                validate(document, body["content"]["application/json"]["schema"], exchange["body"], f"{label} request")
            elif body.get("required"):
                raise ValueError(f"{label}: missing request body")
        response = operation["responses"].get(str(exchange["status"]))
        if response is None:
            raise ValueError(f"{label}: undocumented HTTP status {exchange['status']}")
        response = resolve(document, response)
        if "application/json" in response.get("content", {}):
            validate(document, response["content"]["application/json"]["schema"], exchange["response"], f"{label} response")
    print(f"PASS: {len(exchanges)} exchanges, {len(covered)} REST operations; OAuth is verified separately by TestPayPalOAuthContract.")
    for label in sorted(covered):
        print(f"  {label}")


if __name__ == "__main__":
    main()
