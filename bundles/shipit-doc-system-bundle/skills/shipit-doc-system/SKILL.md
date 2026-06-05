---
name: shipit-doc-system
description: >-
  Create, edit, classify, and validate quality documents for the Ship It
  Green infrastructure (server Bob): SOPs, Work Instructions (WI),
  Installation Qualifications (IQ), Operational Qualifications (OQ), and
  reference catalogues (REF). Use this skill WHENEVER the user is writing,
  updating, splitting, or reviewing any infra/QMS document, mentions an
  SOP/WI/IQ/OQ/REF, asks whether something is "a WI or an IQ", talks about
  qualification protocols, acceptance criteria, signature blocks, or a
  documentary system / système documentaire — even if they don't name the
  document type explicitly. Always classify the document and run the
  validator before considering the work done.
---

# Système documentaire — Infrastructure Ship It Green

This skill encodes the document conventions settled for the Ship It Green
infrastructure. Its job: every new or edited document comes out correctly
typed, correctly structured, and with instructions kept separate from
execution evidence.

## The one rule that matters

A **master document** (SOP, WI, REF) says what to do and stays stable.
The **proof** that a given execution was conform never lives in the master
document — it goes in a dated, signed **instance** of an IQ or OQ, archived
as a record. If a WI/SOP/REF contains a "Résultat constaté" column or a
signature block, it is wrong: extract that into an IQ/OQ.

## Document types

| Type | Rôle | Porte une preuve ? |
|------|------|--------------------|
| SOP  | Politique (*quoi* / *pourquoi*) | Non |
| WI   | Étapes d'une tâche (*comment*) | Non |
| REF  | Catalogue / donnée de référence | Non |
| IQ   | Qualification d'une **installation** ponctuelle | Oui (enregistrement) |
| OQ   | Qualification d'une **opération récurrente** ou conformité d'une **politique** | Oui (enregistrement) |

To classify a document, read `references/classification.md` — it has the
decision tree and the recurring traps (IQ buried in a WI; "IQ" used for a
recurring task that should be an OQ; qualification table inside an SOP;
missing version traceability; instance vs. template confusion).

## Numbering & linking

- `<TYPE>-INFRA-<NNN>_<Titre>.md`, one sequence per type.
- The link between a qualification and what it qualifies is the **`Qualifie`**
  field in the IQ/OQ header — *not* the number. An install IQ may reuse its
  WI's number for readability (`IQ-INFRA-001` ↔ `WI-INFRA-001`) but that is
  only a convenience.

## Templates → instances

`templates/` holds a blank for each type. To create a document, copy the
matching template and fill it. Key points:

- IQ/OQ templates are **master models** (versioned). A real execution is a
  **copy** named `..._<AAAA-MM-JJ>_<cible>.md`, frozen once signed.
- Every IQ/OQ instance must record **which version of the master document
  was followed** (the "Version de … suivie/revue" field) — without it the
  record is not auditable.

## Creating or editing a document

1. Classify it (`references/classification.md`).
2. Copy the matching file from `templates/`.
3. Fill it, keeping the separation rule above.
4. If it's a WI/SOP/REF that needs a qualification, create the paired IQ/OQ
   too and cross-link them via the `Qualifie` field and a `## Qualification`
   section.

## Always validate before finishing

Run the linter on the file(s) or the whole directory:

```bash
python3 scripts/validate.py <file-or-dir>
```

It checks each document against its type: master docs must not carry
evidence; IQ/OQ must carry criteria, a `Qualifie` link, a version-traceability
field, and signatures. Exit code is non-zero if any error is found. The
chapeau (`DOC-CHAPEAU`) is the one allowed exception — it hosts the
system-level review by design.

Fix every error before treating the work as done; warnings are advisory.
