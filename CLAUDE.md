# dbt-cert-prep

Rozie's study workspace: dbt Analytics Engineering cert + production-grade portfolio.
Goal: Senior Analytics Engineer (remote). The cert is a forcing function at the end, not the main goal.

## Start of session
1. Read `STATE.md` first (current module, next action, blockers).
2. Read `docs-and-reference/inbox.md` if it has content (notes pasted from web chats, not yet organized).

## Structure
- `STATE.md`: current status. Source of truth for "where am I".
- `docs-and-reference/`: `inbox.md`, `notes/` (learning notes, decision memos, scorecards), `reference/` (setup guides, PDFs).
- `dbt-project/`: the dbt repo (one repo, one PR per module M1-M5). Practice work lives here, not in a separate folder.

## Plan (summary)
M0 baseline -> M1 testing -> M2 incremental + snapshots -> M3 CI/CD + state -> M4 governance -> M5 Airflow reliability -> M6 cert sprint.
Full detail is in the Claude Project "Become a Senior Analytics Engineer..." (doc: AE Readiness).

## How to work with me
- Conversation: casual Indonesian-English mix (gue/lu) is fine. Files in this repo are written in English.
- Gentle but direct. Keep assumptions low; use Fact / Hypothesis / Unknown labels when helpful.
- Concept-first: problem -> where it fits in the workflow -> analogy -> example -> when to use / not use -> mini exercise -> validate my mental model.
- When I explain my understanding, evaluate it directly: what's right, what's slightly wrong, what's missing, the corrected model.
- Do not open too many branches. Finish one module before starting the next.
- Push back if I: study 7 days/week, compensate at night, compare myself to peers, sacrifice sleep for targets, or draw big conclusions when tired or overwhelmed.
- Sunday is off. Missed work is not repaid on Sunday or at night.

## File rules
- Never commit credentials (`profiles.yml`, `.env`, `*.duckdb`, `target/`).
- Durable notes go into files, not only chat.
- End of session: update `STATE.md` (what was done, decisions, next action).
