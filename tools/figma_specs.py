"""Lecture du dump Figma local `design/figma_specs.json`.

Le fichier est une réponse brute de l'API REST Figma `GET /v1/files/:key`.
Il remplace les outils MCP Dev Mode, inaccessibles avec le siège Figma actuel
(voir docs/audit-code-existant.md, section « Accès Figma »).

Usage :
    py tools/figma_specs.py info
    py tools/figma_specs.py pages
    py tools/figma_specs.py frames [--page <id>]
    py tools/figma_specs.py tree <nodeId> [--depth N]
    py tools/figma_specs.py context <nodeId>
    py tools/figma_specs.py text <nodeId>
    py tools/figma_specs.py digest <nodeId> [<nodeId> ...]
    py tools/figma_specs.py find <motif>

L'option `--out <fichier>` se place avant la sous-commande :
    py tools/figma_specs.py --out design/figma_context.txt context 11:30 14:1281
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from collections import Counter

SPECS = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                     "design", "figma_specs.json")

# ── Chargement et indexation ─────────────────────────────────────────────


def charger():
    with open(SPECS, "r", encoding="utf-8") as f:
        return json.load(f)


def indexer(document):
    """Retourne (par_id, parent_de) pour tout l'arbre."""
    par_id, parent_de = {}, {}
    pile = [(document, None)]
    while pile:
        noeud, parent = pile.pop()
        nid = noeud.get("id")
        if nid:
            par_id[nid] = noeud
            parent_de[nid] = parent
        for enfant in noeud.get("children", []) or []:
            pile.append((enfant, nid))
    return par_id, parent_de


# ── Utilitaires de formatage ─────────────────────────────────────────────


def hexa(couleur, opacite=None):
    r = round(couleur.get("r", 0) * 255)
    g = round(couleur.get("g", 0) * 255)
    b = round(couleur.get("b", 0) * 255)
    a = couleur.get("a", 1)
    if opacite is not None:
        a *= opacite
    if a >= 0.999:
        return f"#{r:02X}{g:02X}{b:02X}"
    return f"#{r:02X}{g:02X}{b:02X} @{a:.2f}"


def boite(noeud):
    b = noeud.get("absoluteBoundingBox") or {}
    if not b:
        return ""
    return (f' x="{round(b.get("x", 0))}" y="{round(b.get("y", 0))}"'
            f' width="{round(b.get("width", 0))}" height="{round(b.get("height", 0))}"')


def balise(noeud):
    return (noeud.get("type") or "NODE").lower()


# ── Commandes ────────────────────────────────────────────────────────────


def cmd_info(doc, _args):
    print(f"nom          : {doc.get('name')}")
    print(f"version      : {doc.get('version')}")
    print(f"lastModified : {doc.get('lastModified')}")
    print(f"role         : {doc.get('role')}")
    print(f"editorType   : {doc.get('editorType')}")
    styles = doc.get("styles") or {}
    print(f"styles       : {len(styles)} styles nommés")
    par_id, _ = indexer(doc["document"])
    print(f"noeuds       : {len(par_id)}")
    types = Counter(n.get("type") for n in par_id.values())
    print("types        : " + ", ".join(f"{t}={c}" for t, c in types.most_common()))


def cmd_pages(doc, _args):
    for canvas in doc["document"].get("children", []):
        enfants = canvas.get("children", []) or []
        print(f"{canvas['id']:>10}  {canvas.get('name'):<28} {len(enfants)} frames de 1er niveau")


def cmd_frames(doc, args):
    for canvas in doc["document"].get("children", []):
        if args.page and canvas["id"] != args.page:
            continue
        print(f"\n=== {canvas['id']} — {canvas.get('name')} ===")
        for enfant in canvas.get("children", []) or []:
            b = enfant.get("absoluteBoundingBox") or {}
            taille = (f'{round(b.get("width", 0))}x{round(b.get("height", 0))}'
                      if b else "-")
            print(f"{enfant['id']:>12}  {taille:>10}  {enfant.get('type'):<10} "
                  f"{enfant.get('name')}")


def cmd_tree(doc, args):
    par_id, _ = indexer(doc["document"])
    racine = par_id.get(args.nodeId)
    if racine is None:
        sys.exit(f"noeud {args.nodeId} introuvable")

    def descendre(noeud, niveau):
        if niveau > args.depth:
            return
        marge = "  " * niveau
        enfants = noeud.get("children", []) or []
        nom = (noeud.get("name") or "").replace('"', "'")
        entete = f'{marge}<{balise(noeud)} id="{noeud["id"]}" name="{nom}"{boite(noeud)}'
        if noeud.get("type") == "TEXT":
            contenu = (noeud.get("characters") or "").replace("\n", "\\n")
            entete += f' characters="{contenu}"'
        if not enfants or niveau == args.depth:
            suffixe = " />" if not enfants else f"> ... {len(enfants)} enfants"
            print(entete + suffixe)
            return
        print(entete + ">")
        for enfant in enfants:
            descendre(enfant, niveau + 1)
        print(f"{marge}</{balise(noeud)}>")

    descendre(racine, 0)


def _parcourir(noeud):
    pile = [noeud]
    while pile:
        courant = pile.pop()
        yield courant
        for enfant in courant.get("children", []) or []:
            pile.append(enfant)


def cmd_context(doc, args):
    par_id, _ = indexer(doc["document"])
    for nid in args.nodeIds:
        racine = par_id.get(nid)
        if racine is None:
            print(f"\n# {nid} — INTROUVABLE\n")
            continue
        _contexte(racine)
        print("\n" + "-" * 78)


def _contexte(racine):
    b = racine.get("absoluteBoundingBox") or {}
    print(f"\n{'=' * 70}")
    print(f"# {racine.get('name')}  ({racine['id']})")
    print(f"type   : {racine.get('type')}")
    print(f"taille : {round(b.get('width', 0))} x {round(b.get('height', 0))}")

    remplissages, traits, rayons, polices, epaisseurs, effets = (
        Counter(), Counter(), Counter(), Counter(), Counter(), Counter())
    espacements, paddings = Counter(), Counter()
    total = 0

    for noeud in _parcourir(racine):
        total += 1
        for f in noeud.get("fills") or []:
            if f.get("visible") is False:
                continue
            if f.get("type") == "SOLID":
                remplissages[hexa(f["color"], f.get("opacity"))] += 1
            elif f.get("type", "").startswith("GRADIENT"):
                arrets = " -> ".join(hexa(s["color"]) for s in f.get("gradientStops", []))
                remplissages[f'{f["type"]}({arrets})'] += 1
            elif f.get("type") == "IMAGE":
                remplissages["IMAGE"] += 1
        for s in noeud.get("strokes") or []:
            if s.get("type") == "SOLID":
                traits[hexa(s["color"], s.get("opacity"))] += 1
        if noeud.get("strokeWeight"):
            epaisseurs[round(noeud["strokeWeight"], 2)] += 1
        if noeud.get("cornerRadius") is not None:
            rayons[round(noeud["cornerRadius"], 2)] += 1
        for r in noeud.get("rectangleCornerRadii") or []:
            rayons[round(r, 2)] += 1
        for e in noeud.get("effects") or []:
            if e.get("visible") is False:
                continue
            desc = e.get("type", "?")
            if e.get("radius") is not None:
                desc += f" r={round(e['radius'], 1)}"
            if e.get("color"):
                desc += f" {hexa(e['color'])}"
            if e.get("offset"):
                desc += f" dx={round(e['offset'].get('x', 0), 1)} dy={round(e['offset'].get('y', 0), 1)}"
            effets[desc] += 1
        if noeud.get("itemSpacing"):
            espacements[round(noeud["itemSpacing"], 2)] += 1
        for cle in ("paddingLeft", "paddingRight", "paddingTop", "paddingBottom"):
            if noeud.get(cle):
                paddings[round(noeud[cle], 2)] += 1
        st = noeud.get("style")
        if st:
            polices[(st.get("fontFamily"), st.get("fontWeight"),
                     round(st.get("fontSize", 0), 2),
                     round(st.get("lineHeightPx", 0), 1),
                     round(st.get("letterSpacing", 0), 2))] += 1

    print(f"calques: {total}\n")

    def bloc(titre, compteur, formateur=str):
        if not compteur:
            return
        print(f"## {titre}")
        for cle, n in compteur.most_common():
            print(f"  {formateur(cle):<58} x{n}")
        print()

    bloc("Remplissages", remplissages)
    bloc("Traits (couleur)", traits)
    bloc("Traits (épaisseur)", epaisseurs)
    bloc("Rayons d'arrondi", rayons)
    bloc("Effets / ombres", effets)
    bloc("itemSpacing (auto-layout)", espacements)
    bloc("Paddings (auto-layout)", paddings)
    bloc("Typographies (famille, poids, taille, interligne, letterSpacing)",
         polices, lambda k: f"{k[0]} {k[1]} / {k[2]}pt / lh {k[3]} / ls {k[4]}")


def cmd_text(doc, args):
    par_id, _ = indexer(doc["document"])
    racine = par_id.get(args.nodeId)
    if racine is None:
        sys.exit(f"noeud {args.nodeId} introuvable")
    lignes = []
    for noeud in _parcourir(racine):
        if noeud.get("type") == "TEXT":
            b = noeud.get("absoluteBoundingBox") or {}
            st = noeud.get("style") or {}
            lignes.append((
                round(b.get("y", 0)), round(b.get("x", 0)),
                (noeud.get("characters") or "").replace("\n", " / "),
                f"{st.get('fontFamily')} {st.get('fontWeight')}/{round(st.get('fontSize', 0), 1)}pt",
                noeud["id"],
            ))
    for y, x, contenu, style, nid in sorted(lignes):
        print(f"y={y:>5} x={x:>5}  {contenu[:70]:<70}  {style:<28} {nid}")


def cmd_styles(doc, args):
    """Détail calque par calque : fill, stroke, rayon, auto-layout, style de texte.

    Contrairement à `context` qui agrège des compteurs, cette vue dit *quel*
    calque porte *quelle* valeur — c'est ce qu'il faut pour reproduire un
    composant au pixel.
    """
    par_id, _ = indexer(doc["document"])
    racine = par_id.get(args.nodeId)
    if racine is None:
        sys.exit(f"noeud {args.nodeId} introuvable")

    def decrire(noeud, niveau):
        if niveau > args.depth:
            return
        marge = "  " * niveau
        bits = []
        for f in noeud.get("fills") or []:
            if f.get("visible") is False:
                continue
            if f.get("type") == "SOLID":
                bits.append(f"fill {hexa(f['color'], f.get('opacity'))}")
            elif f.get("type") == "IMAGE":
                bits.append("fill IMAGE")
            elif f.get("type", "").startswith("GRADIENT"):
                bits.append("fill " + f["type"])
        for s in noeud.get("strokes") or []:
            if s.get("type") == "SOLID":
                poids = noeud.get("strokeWeight")
                bits.append(f"stroke {hexa(s['color'], s.get('opacity'))}"
                            + (f" w{round(poids, 2)}" if poids else ""))
        if noeud.get("cornerRadius") is not None:
            bits.append(f"r{round(noeud['cornerRadius'], 2)}")
        elif noeud.get("rectangleCornerRadii"):
            bits.append("r" + "/".join(str(round(v, 2))
                                       for v in noeud["rectangleCornerRadii"]))
        if noeud.get("layoutMode"):
            bits.append(noeud["layoutMode"].lower())
        pads = [round(noeud.get(c) or 0, 2)
                for c in ("paddingTop", "paddingRight", "paddingBottom", "paddingLeft")]
        if any(pads):
            bits.append("pad " + "/".join(str(p) for p in pads))
        if noeud.get("itemSpacing"):
            bits.append(f"gap {round(noeud['itemSpacing'], 2)}")
        st = noeud.get("style")
        if st:
            bits.append(f"{st.get('fontFamily')} {st.get('fontWeight')}"
                        f"/{round(st.get('fontSize', 0), 1)}pt"
                        f" lh{round(st.get('lineHeightPx', 0), 1)}"
                        f" ls{round(st.get('letterSpacing', 0), 2)}")

        b = noeud.get("absoluteBoundingBox") or {}
        dim = (f'{round(b.get("width", 0))}x{round(b.get("height", 0))}' if b else "-")
        nom = (noeud.get("name") or "")[:34]
        contenu = ""
        if noeud.get("type") == "TEXT":
            contenu = ' "' + (noeud.get("characters") or "").replace("\n", " ")[:34] + '"'
        print(f"{marge}{noeud['id']:<14} {noeud.get('type', ''):<10} {dim:>10}  "
              f"{nom}{contenu}  |  {'  '.join(bits)}")
        for enfant in noeud.get("children", []) or []:
            decrire(enfant, niveau + 1)

    decrire(racine, 0)


def cmd_digest(doc, args):
    """Signature textuelle compacte de plusieurs frames, pour les comparer.

    Sert à trancher si deux frames homonymes sont des écrans distincts ou des
    variantes d'état du même écran.
    """
    par_id, _ = indexer(doc["document"])
    for nid in args.nodeIds:
        noeud = par_id.get(nid)
        if noeud is None:
            print(f"\n### {nid} — INTROUVABLE")
            continue
        b = noeud.get("absoluteBoundingBox") or {}
        textes = []
        for enfant in _parcourir(noeud):
            if enfant.get("type") == "TEXT":
                c = (enfant.get("characters") or "").strip().replace("\n", " ")
                if c:
                    y = round((enfant.get("absoluteBoundingBox") or {}).get("y", 0))
                    textes.append((y, c))
        ordonnes = [c for _, c in sorted(textes)]
        print(f"\n### {nid} — {noeud.get('name')} "
              f"[{round(b.get('width', 0))}x{round(b.get('height', 0))}] "
              f"{len(ordonnes)} textes")
        print("   " + " | ".join(ordonnes))


def cmd_find(doc, args):
    par_id, _ = indexer(doc["document"])
    motif = args.motif.lower()
    for nid, noeud in par_id.items():
        nom = noeud.get("name") or ""
        if motif in nom.lower():
            b = noeud.get("absoluteBoundingBox") or {}
            taille = f'{round(b.get("width", 0))}x{round(b.get("height", 0))}' if b else "-"
            print(f"{nid:>14}  {noeud.get('type'):<12} {taille:>10}  {nom}")


def cmd_resume(doc, args):
    """Une ligne Markdown par frame : dominantes de couleur, typo et rayons.

    Sert à bâtir la table de cartographie ; le détail exhaustif reste
    accessible via `context`.
    """
    par_id, _ = indexer(doc["document"])
    for nid in args.nodeIds:
        racine = par_id.get(nid)
        if racine is None:
            print(f"| {nid} | INTROUVABLE | | | |")
            continue
        fills, polices, rayons = Counter(), Counter(), Counter()
        for noeud in _parcourir(racine):
            for f in noeud.get("fills") or []:
                if f.get("visible") is False:
                    continue
                if f.get("type") == "SOLID":
                    fills[hexa(f["color"], f.get("opacity"))] += 1
            if noeud.get("cornerRadius") is not None:
                rayons[round(noeud["cornerRadius"], 2)] += 1
            st = noeud.get("style")
            if st:
                polices[f'{st.get("fontFamily")} {st.get("fontWeight")}/'
                        f'{round(st.get("fontSize", 0))}'] += 1
        b = racine.get("absoluteBoundingBox") or {}
        c = ", ".join(f"{k}×{n}" for k, n in fills.most_common(5))
        t = ", ".join(f"{k}×{n}" for k, n in polices.most_common(4))
        r = ", ".join(str(k) for k, _ in rayons.most_common(4))
        print(f"| `{nid}` | {racine.get('name')} | "
              f"{round(b.get('width', 0))}×{round(b.get('height', 0))} | {c} | {t} | {r} |")


COMMANDES = {
    "info": cmd_info, "pages": cmd_pages, "frames": cmd_frames,
    "tree": cmd_tree, "context": cmd_context, "text": cmd_text, "find": cmd_find,
    "digest": cmd_digest, "resume": cmd_resume, "styles": cmd_styles,
}


def main():
    # La console Windows est en cp1252 : sans cela, tout caractère hors Latin-1
    # (flèches, tirets cadratins) fait planter l'écriture sur stdout. Et pour un
    # fichier, `--out` court-circuite le pipeline PowerShell, qui re-décoderait
    # l'UTF-8 en cp1252 et produirait du mojibake.
    for flux in (sys.stdout, sys.stderr):
        try:
            flux.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass

    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--out", help="écrit le résultat dans ce fichier, en UTF-8")
    sub = p.add_subparsers(dest="commande", required=True)
    sub.add_parser("info")
    sub.add_parser("pages")
    q = sub.add_parser("frames")
    q.add_argument("--page")
    q = sub.add_parser("tree")
    q.add_argument("nodeId")
    q.add_argument("--depth", type=int, default=3)
    q = sub.add_parser("context")
    q.add_argument("nodeIds", nargs="+")
    q = sub.add_parser("text")
    q.add_argument("nodeId")
    q = sub.add_parser("find")
    q.add_argument("motif")
    q = sub.add_parser("digest")
    q.add_argument("nodeIds", nargs="+")
    q = sub.add_parser("resume")
    q.add_argument("nodeIds", nargs="+")
    q = sub.add_parser("styles")
    q.add_argument("nodeId")
    q.add_argument("--depth", type=int, default=6)
    args = p.parse_args()

    if not os.path.exists(SPECS):
        sys.exit(f"dump introuvable : {SPECS}")

    doc = charger()
    if args.out:
        with open(args.out, "w", encoding="utf-8") as f:
            precedent, sys.stdout = sys.stdout, f
            try:
                COMMANDES[args.commande](doc, args)
            finally:
                sys.stdout = precedent
        print(f"écrit : {args.out}")
    else:
        COMMANDES[args.commande](doc, args)


if __name__ == "__main__":
    main()
