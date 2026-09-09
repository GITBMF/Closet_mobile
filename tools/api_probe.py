"""Sonde le backend ClosET en direct, pour vérifier ce que renvoient vraiment
les endpoints avant d'écrire le code qui les consomme.

La spec OpenAPI décrit les formes attendues ; seule une requête réelle dit ce
que l'instance déployée répond (champs facultatifs absents, pagination, casse
des énumérations).

Usage :
    py tools/api_probe.py get /geo/regions
    py tools/api_probe.py get /pieces --params limit=2
    py tools/api_probe.py post /auth/login --json email=a@b.c password=xxx
    py tools/api_probe.py get /me --token <jwt>
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.stderr.reconfigure(encoding="utf-8", errors="replace")

BASE = "https://closet-backend-be8g.onrender.com/api/v1"


def paires(valeurs: list[str] | None) -> dict[str, str]:
    resultat: dict[str, str] = {}
    for brut in valeurs or []:
        cle, _, valeur = brut.partition("=")
        resultat[cle] = valeur
    return resultat


def main() -> int:
    parseur = argparse.ArgumentParser()
    parseur.add_argument("methode", choices=["get", "post", "patch", "delete"])
    parseur.add_argument("chemin", help="chemin relatif, ex. /geo/regions")
    parseur.add_argument("--params", nargs="*", help="cle=valeur de query string")
    parseur.add_argument("--json", nargs="*", help="cle=valeur du corps JSON")
    parseur.add_argument("--token", help="jeton Bearer")
    parseur.add_argument("--timeout", type=int, default=120)
    parseur.add_argument("--brut", action="store_true", help="ne pas tronquer")
    args = parseur.parse_args()

    url = BASE + args.chemin
    if args.params:
        url += "?" + urllib.parse.urlencode(paires(args.params))

    corps = None
    entetes = {"Accept": "application/json"}
    if args.json is not None:
        corps = json.dumps(paires(args.json)).encode()
        entetes["Content-Type"] = "application/json"
    if args.token:
        entetes["Authorization"] = f"Bearer {args.token}"

    requete = urllib.request.Request(
        url, data=corps, headers=entetes, method=args.methode.upper()
    )

    try:
        with urllib.request.urlopen(requete, timeout=args.timeout) as reponse:
            statut = reponse.status
            texte = reponse.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as erreur:
        statut = erreur.code
        texte = erreur.read().decode("utf-8", "replace")
    except Exception as erreur:  # noqa: BLE001 - la sonde doit tout rapporter
        print(f"ECHEC RESEAU: {type(erreur).__name__}: {erreur}")
        return 1

    print(f"HTTP {statut}  {args.methode.upper()} {url}")
    try:
        charge = json.loads(texte)
    except json.JSONDecodeError:
        print(texte[:2000])
        return 0

    rendu = json.dumps(charge, indent=2, ensure_ascii=False)
    print(rendu if args.brut else rendu[:6000])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
