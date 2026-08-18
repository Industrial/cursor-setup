---
name: id-workflow
description: >-
  Industrial Delivery (ID) mode-gated agent pipeline — ORIENT→RESEARCH→PLAN→EXECUTE→REVIEW→SHIP
  with write bans, Maestro tracking, and lane sizing. Use when user invokes /id, /id-*,
  mentions ID workflow, or wants structured guiderails instead of stacking /quality /skills /agent.
  Hermes: invoke as /id-workflow or ask to run Industrial Delivery.
---

# ID Workflow Skill

Canonical pack (Cursor slash commands): `.cursor/commands/id-workflow/` (PROTOCOL, lanes, modes, checklists).
This skill is the Hermes-readable summary so sessions without Cursor slash commands still get the rails.

## When to use

- User runs `/id` or `/id-<mode>` (Cursor) or asks for Industrial Delivery / ID workflow (Hermes)
- Multi-step work that needs research/plan gates before edits
- Replacing ad-hoc `/skills` `/quality` `/agent` stacks

## Mode machine

```
ORIENT → RESEARCH → PLAN → EXECUTE → REVIEW → SHIP
         ↑______________|         ↑____FAIL____|
```

| Mode | Writes | Advance when |
|------|--------|--------------|
| **ORIENT** | none | Ask sharp; skills+agent listed; lane set (`tiny\|normal\|heavy`) |
| **RESEARCH** | none | Enough context to plan |
| **PLAN** | Maestro/spec/plan only | Human approves plan |
| **EXECUTE** | contract-scoped code | Leaf done + evidence recorded |
| **REVIEW** | evidence notes only | Verdict PASS → SHIP; FAIL → EXECUTE |
| **SHIP** | git/gh only | Pushed / session-close complete |

## Hard rails (every turn)

1. Declare mode: first line `[ID:<MODE>]` then `lane:<tiny\|normal\|heavy>`.
2. **Write ban:** no code/config edits outside EXECUTE/SHIP. PLAN may write `.maestro/**`, `.cursor/plans/**`, specs only.
3. **Human gate:** do not EXECUTE until the user explicitly approves the plan (or says plan+implement).
4. Tracker = **Maestro only** (`tsk-` / `pln-`). No parallel story systems.
5. PLAN body = `/plan-hierarchically` (do not fork).
6. **No Maestro worktrees:** claim with CLI `--skip-worktree` only; stay on current branch. Never MCP `maestro_task_claim` (auto-creates worktrees).

## Lanes

| Lane | Path |
|------|------|
| **tiny** | ORIENT → brief RESEARCH optional → EXECUTE → REVIEW → SHIP |
| **normal** | Full pipeline; light Maestro task |
| **heavy** | Full pipeline + mission + execution overlay; human approve before EXECUTE |

## Agents

| Mode | Agent |
|------|-------|
| ORIENT / RESEARCH | researcher |
| PLAN | architect |
| EXECUTE | implementer |
| REVIEW / SHIP | reviewer |

Cursor rules: `.cursor/rules/agent-{researcher,architect,implementer,reviewer}.mdc`

## Mode files (read when entering a mode)

| Mode | Path |
|------|------|
| ORIENT | `.cursor/commands/id-workflow/modes/orient.md` |
| RESEARCH | `.cursor/commands/id-workflow/modes/research.md` |
| PLAN | `.cursor/commands/id-workflow/modes/plan.md` |
| EXECUTE | `.cursor/commands/id-workflow/modes/execute.md` |
| REVIEW | `.cursor/commands/id-workflow/modes/review.md` |
| SHIP | `.cursor/commands/id-workflow/modes/ship.md` |

Exit checklists: `.cursor/commands/id-workflow/checklists/`

## Hermes claim snippet

```bash
devenv shell -- maestro task claim <tsk-id> --agent <agent-id> --skip-worktree --tool hermes
```

## Related

- Protocol: `.cursor/commands/id-workflow/PROTOCOL.md`
- Rule summary: `.cursor/rules/id-workflow.mdc`
- Research cites: `.cursor/commands/id-workflow/RESEARCH.md`
