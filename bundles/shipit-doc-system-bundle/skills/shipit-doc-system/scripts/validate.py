#!/usr/bin/env python3
"""Validate Ship It Green infrastructure docs against their type.

Usage:
    python3 validate.py <file-or-dir> [<file-or-dir> ...]

Type is detected from the document reference (the `Référence` row of the
header table), falling back to the filename prefix. The linter enforces
the separation between master documents (SOP/WI/REF — instructions, no
evidence) and qualification records (IQ/OQ — criteria, traceability,
signatures).

Exit code 0 if all files pass, 1 if any error is found.
"""
import re
import sys
import pathlib

MASTER = {"SOP", "WI", "REF"}             # must NOT capture evidence
QUALIF = {"IQ", "OQ"}                      # must capture evidence

EVIDENCE_MARKERS = ("résultat constaté", "## signatures", "| signature |")


def detect_type(text, path):
    m = re.search(r"^\|\s*Référence\s*\|\s*([A-Z]+)-", text, re.M | re.I)
    if m:
        return m.group(1).upper()
    name = path.name.upper()
    for t in ("DOC-CHAPEAU", "SOP", "WI", "IQ", "OQ", "REF"):
        if name.startswith(t):
            return "DOC" if t == "DOC-CHAPEAU" else t
    return "?"


def has_header_table(text):
    return bool(re.search(r"^\|\s*Référence\s*\|", text, re.M))


def lint(path):
    text = path.read_text(encoding="utf-8")
    low = text.lower()
    t = detect_type(text, path)
    errors, warnings = [], []

    if not has_header_table(text):
        errors.append("en-tête (tableau Référence/Version/...) manquant")

    if "## historique des révisions" not in low:
        warnings.append("section « Historique des révisions » absente")

    has_evidence = any(mark in low for mark in EVIDENCE_MARKERS)

    if t in QUALIF:
        # qualification records MUST carry evidence + traceability + sigs
        if "résultat constaté" not in low:
            errors.append("colonne « Résultat constaté » absente "
                          "(une qualification doit enregistrer un résultat)")
        if "## signatures" not in low and "| signature |" not in low:
            errors.append("bloc de signatures absent")
        if "conforme" not in low:
            errors.append("aucune notion de conformité (cases ☐ Conforme)")
        if not re.search(r"\|\s*qualifie\s*\|", low):
            errors.append("champ « Qualifie » absent de l'en-tête "
                          "(lien vers le document maître)")
        if not re.search(r"version de .* (suivie|revue)", low):
            errors.append("champ de traçabilité « Version de … suivie/revue »"
                          " absent (instance non auditable)")
        if "nommage d'une instance" not in low:
            warnings.append("note de nommage d'instance absente")

    elif t == "DOC":
        # The chapeau (index) is sui generis: it legitimately hosts the
        # system-level "Revue du système documentaire" record. Evidence
        # capture here is by design, not a leak — so it is allowed.
        if "## 5. matrice" not in low and "matrice de relations" not in low:
            warnings.append("matrice de relations absente du chapeau")

    elif t in MASTER:
        # master docs MUST NOT carry execution evidence
        if has_evidence:
            errors.append(
                "ce document maître contient une capture de preuve "
                "(résultat constaté / signatures) — extraire vers une IQ/OQ")
        if t in ("WI", "SOP") and not re.search(
                r"\b(IQ|OQ)-INFRA-\d+", text):
            warnings.append("aucune référence à une qualification (IQ/OQ) — "
                            "un WI/SOP devrait pointer vers sa qualification")
    else:
        warnings.append(f"type non reconnu ({t}) — vérifier le préfixe / "
                        "la référence")

    return t, errors, warnings


def collect(args):
    files = []
    for a in args:
        p = pathlib.Path(a)
        if p.is_dir():
            files += sorted(p.glob("*.md"))
        elif p.is_file():
            files.append(p)
        else:
            print(f"  ?? introuvable : {a}")
    return files


def main(argv):
    files = collect(argv or ["."])
    if not files:
        print("Aucun fichier .md à valider.")
        return 0
    n_err = 0
    for f in files:
        t, errors, warnings = lint(f)
        status = "ERREUR" if errors else ("WARN" if warnings else "OK")
        print(f"[{status:6}] {f.name}  ({t})")
        for e in errors:
            print(f"          ✘ {e}")
        for w in warnings:
            print(f"          ⚠ {w}")
        n_err += len(errors)
    print(f"\n{len(files)} fichier(s) — {n_err} erreur(s).")
    return 1 if n_err else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
