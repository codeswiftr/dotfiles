# User-level defaults for agentic tools (Claude/Codex/Cursor/Amp)

- Defer to the repo’s scoped `CLAUDE.md` + `AGENTS.md` (they override this file).
- Do NOT auto-commit. Only commit when explicitly requested by the user and never commit to `main`.
- Use Astral `uv` for Python dependencies (never `pip`).
- Prefer one active executor tool per task; use others only for review/research.
