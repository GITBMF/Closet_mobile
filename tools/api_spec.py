"""Résumé lisible de l'OpenAPI du backend ClosET.

Le backend n'est pas encore branché (voir docs/audit-code-existant.md) mais sa
spec sert de référence pour aligner modèles et mocks dès maintenant.

Usage :
    py tools/api_spec.py <chemin openapi.json> routes
    py tools/api_spec.py <chemin openapi.json> schema <NomDuSchema> [...]
    py tools/api_spec.py <chemin openapi.json> schemas
"""

from __future__ import annotations

import json
import sys


def charger(chemin):
    with open(chemin, "r", encoding="utf-8") as f:
        return json.load(f)


def type_de(prop):
    if "$ref" in prop:
        return prop["$ref"].rsplit("/", 1)[-1]
    if "anyOf" in prop:
        return " | ".join(type_de(p) for p in prop["anyOf"])
    if "allOf" in prop:
        return " & ".join(type_de(p) for p in prop["allOf"])
    t = prop.get("type", "?")
    if t == "array":
        return f"[{type_de(prop.get('items', {}))}]"
    fmt = prop.get("format")
    return f"{t}({fmt})" if fmt else t


def cmd_routes(spec, _args):
    for chemin, operations in sorted(spec.get("paths", {}).items()):
        for methode, op in operations.items():
            if methode not in ("get", "post", "put", "patch", "delete"):
                continue
            tags = ",".join(op.get("tags", []))
            corps = ""
            rb = op.get("requestBody", {})
            for mime, media in (rb.get("content") or {}).items():
                corps = f"  <- {type_de(media.get('schema', {}))}"
                break
            sortie = ""
            ok = (op.get("responses") or {}).get("200") or (op.get("responses") or {}).get("201")
            for mime, media in ((ok or {}).get("content") or {}).items():
                sortie = f"  -> {type_de(media.get('schema', {}))}"
                break
            securise = " [auth]" if op.get("security") else ""
            print(f"{methode.upper():<6} {chemin:<52} [{tags}]{securise}{corps}{sortie}")


def cmd_schemas(spec, _args):
    for nom in sorted((spec.get("components") or {}).get("schemas", {})):
        print(nom)


def cmd_schema(spec, args):
    schemas = (spec.get("components") or {}).get("schemas", {})
    for nom in args:
        s = schemas.get(nom)
        if s is None:
            print(f"\n## {nom} — INTROUVABLE")
            continue
        requis = set(s.get("required") or [])
        print(f"\n## {nom}  ({s.get('type', '?')})")
        if s.get("enum"):
            print(f"   enum: {s['enum']}")
        for champ, prop in (s.get("properties") or {}).items():
            marque = "*" if champ in requis else " "
            defaut = prop.get("default")
            suffixe = f"  = {defaut!r}" if defaut is not None else ""
            print(f"  {marque} {champ:<26} {type_de(prop):<34}{suffixe}")


COMMANDES = {"routes": cmd_routes, "schemas": cmd_schemas, "schema": cmd_schema}


def main():
    for flux in (sys.stdout, sys.stderr):
        try:
            flux.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    spec = charger(sys.argv[1])
    COMMANDES[sys.argv[2]](spec, sys.argv[3:])


if __name__ == "__main__":
    main()
