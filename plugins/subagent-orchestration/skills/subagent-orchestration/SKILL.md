---
name: subagent-orchestration
description: "Use for Codex multi_agent_v2 subagent orchestration: delegation decisions, spawn_agent prompts, custom agent_type roles, reasoning_effort choices, safe parallelism, wait/list/send/followup/close handling, commit discipline, receipts, and root-thread coordination."
---

# Subagent Orchestration

Use when Codex `multi_agent_v2` delegation can save context, run work in parallel, reduce uncertainty, or add independent verification. Target `multi_agent_v2` only; if unavailable, say this skill requires it rather than falling back to older `multi_agent` calls.

## Bias and Boundaries

Default to delegation for deep reading, uncertain call paths, implementation branches, debugging, docs/API lookup, browser reproduction, tests, review, or long-running commands. Keep local only if the next root decision needs 1-2 quick checks first.

The root thread remains user-facing integrator: plan owner, conflict resolver, final verifier, and stop/go decision maker. Do not delegate user-visible judgment or forward raw child transcripts; require compact receipts and synthesize them yourself.

## Spawn Checklist

Before each `spawn_agent` call:

1. Split independent work into narrow agents; use leads only for bounded branches with internal subtasks.
2. Assign ownership: files/modules, read-only vs write, allowed commits, done criteria, evidence, receipt shape.
3. Prevent collisions: never give two writers the same files without isolated branches/worktrees and an integration plan.
4. Warn parallel siblings: `Another agent is concurrently working on <task> in <files>. Avoid that area; stop and report overlap/dependencies.`
5. Use `fork_turns:"none"` by default; bundled agents read needed context from the first message.
6. Pass the matching `reasoning_effort` explicitly; avoid `model` overrides unless requested or clearly required.

## Parallel Safety

Maximize safe parallelism without losing attribution:

- Fan out read-only mapping/research/debug/test probes for independent questions.
- Parallelize writers only by distinct ownership or isolated branches/worktrees.
- Serialize dependent writes; finish and verify API/shape A before dispatching B.
- Pipeline while waiting: prepare briefs, verify receipts, update plans, or launch another independent agent.
- Reviewers may inspect completed patches while unrelated work continues.

## Commit Discipline

For repository-changing work, commit at stable verified checkpoints unless user/repo instructions prohibit it.

- Default writer brief: commit after owned validation passes; include hash in receipt.
- Keep commits focused and attributable; never commit broken tests, conflicts, secrets, generated junk, or unrelated formatting.
- Require `git status`, relevant validation, changed-file summary, and commit hash/reason-no-commit.
- If several writers run in parallel, isolate them or have them stop before commit so the root integrates sequentially.

## Agent Types

Use custom `agent_type` only when present; otherwise stop and report unavailable role. Exact names/default efforts:

| Agent type | Reasoning | Use |
|---|---|---|
| `code_mapper` | `low` | read-only tracing, wiring, ownership, call paths |
| `debugger` | `high` | root-cause failures, logs, stacks, broken tests |
| `reviewer` | `high` | findings-first review with file/line evidence |
| `test_automator` | `medium` | focused regression tests and validation |
| `docs_researcher` | `low` | current official docs/API behavior |
| `browser_debugger` | `medium` | UI reproduction with console/network/DOM evidence |
| `implementation_engineer` | `low` | scoped implementation from an existing plan |
| `implementation_lead` | `high` | bounded implementation branch; may spawn children |
| `investigation_lead` | `high` | complex diagnosis; may spawn probes |
| `agent_organizer` | `medium` | disposable decomposition/spawn-plan consultant |
| `workflow_orchestrator` | `xhigh` | multi-wave dependency planner/critic |

## Valid `spawn_agent` Examples

Read-only probe:

```json
{"tool":"spawn_agent","args":{"task_name":"map_auth_flow","agent_type":"code_mapper","reasoning_effort":"low","fork_turns":"none","message":"Read-only. Trace auth flow from entry to side-effect boundaries. Return ordered call path, key files/symbols, risky branches, and confidence gaps. Do not edit files."}}
```

Parallel non-overlapping writer/tester:

```json
{"tool":"spawn_agent","args":{"task_name":"auth_middleware_change","agent_type":"implementation_engineer","reasoning_effort":"low","fork_turns":"none","message":"Own only auth middleware files. Another agent is concurrently working on auth tests; avoid tests and stop if overlap appears. Implement the middleware change, run relevant validation, commit after tests pass, and return changed files, validation summary, commit hash, and risks."}}
```

```json
{"tool":"spawn_agent","args":{"task_name":"auth_tests_change","agent_type":"test_automator","reasoning_effort":"medium","fork_turns":"none","message":"Own only auth test files. Another agent is concurrently working on auth middleware; avoid middleware and stop if overlap appears. Add focused regression coverage, run relevant validation, commit after tests pass, and return changed files, validation summary, commit hash, and risks."}}
```

Patch review:

```json
{"tool":"spawn_agent","args":{"task_name":"review_patch","agent_type":"reviewer","reasoning_effort":"high","fork_turns":"none","message":"Review the current change for correctness, regressions, security, and missing tests. Findings first with file/line evidence. Do not edit files."}}
```

## Runtime Discipline

- Use `list_agents` for complex trees, `wait_agent` for mailbox updates, `send_message` for clarifications, `followup_task` for new work on an existing agent, and `close_agent` when a branch/probe is done.
- Track agent ownership, commit permission, landed commit hashes, unresolved dependencies, and which receipts are still missing.
- Close disposable organizers after their plan; do not let any lead own the whole conversation.

## Required Agent Receipt

Require lead and leaf agents to return:

- agents spawned and why, if any
- conclusion or patch summary
- changed files, if any
- exact validation commands and pass/fail status
- commit hash(es), or explicit reason no commit was made
- unresolved risks/conflicts
- exact next action needed from the parent

## Guardrails

Do not delegate urgent blocking work, user-visible decisions, or unscoped ownership. Do not spawn multiple writers for the same files without isolation. Do not optimize for parallelism at the cost of causality: performance experiments and risky behavior changes usually need one attributed change at a time. Do not let agents commit unrelated work or commit before validation.
