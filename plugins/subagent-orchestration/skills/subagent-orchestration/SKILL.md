---
name: subagent-orchestration
description: "Use for Codex multi_agent_v2 subagent delegation and orchestration: deciding when to spawn agents, maximizing safe parallelism, root-thread versus organizer/lead/leaf-agent patterns, reasoning_effort choices, custom agent_type roles, spawn prompt templates, wait/list/close handling, commit-as-you-go coordination, and keeping the main thread clean during long or parallel work."
---

# Subagent Orchestration

Use this skill when a task would benefit from Codex `multi_agent_v2` delegation. Target `multi_agent_v2` only; if that surface is not available, explain that this skill requires it instead of falling back to older `multi_agent` calls.

## Operating Bias

- Default to delegation whenever it would save root-thread context, unblock parallel progress, reduce uncertainty, or provide independent verification.
- Keep the root thread as the user-facing integrator, decision maker, conflict resolver, and final verifier.
- Use subagents for deep reading, implementation branches, debugging, docs/API lookup, browser reproduction, test work, review, and long-running commands.
- Do not delegate only to avoid a decision the root thread must make; delegate to gather evidence or execute bounded work.
- Do not forward raw child transcripts back to the root thread. Require concise receipts and integrate them yourself.

## Delegation Decision

Spawn one or more agents when any of these apply:

- The task naturally splits by file/module/feature/test surface.
- You need to inspect more than a few files or chase an uncertain call path.
- A command, benchmark, browser reproduction, or external-doc lookup may take time while other work can proceed.
- You need independent review before landing or after a risky change.
- Two or more work streams are independent enough to own different files.

Keep work local only when it is tiny, urgent for the next decision, or impossible to scope without first doing 1-2 root-thread checks.

## Before Spawning

1. Identify what must stay local: user communication, global plan, conflict resolution, final verification, and stop/go decisions.
2. Split all independent side work or bounded branch work into agents. Prefer more narrow agents over one broad agent when their work can run concurrently.
3. Assign explicit ownership: files/modules, read-only versus write access, done criteria, expected evidence, and compact return format.
4. Prevent collisions: never assign two writers to the same files unless one is explicitly read-only/reviewer or they are on isolated branches/worktrees.
5. Warn each parallel agent about sibling work that might overlap.
6. Pass `fork_turns:"none"` by default. These bundled agents are written to read all needed context from the first message.
7. Pass the listed `reasoning_effort` explicitly. The agent definitions also set matching defaults.
8. Prefer no `model` override unless the user requested one or the task clearly requires it.

## Parallelization Strategy

Aim for the maximum safe parallelism that preserves attribution and avoids merge conflicts:

- **Fan out mapping first.** Use several `code_mapper`, `docs_researcher`, `debugger`, or `test_automator` agents in parallel for independent questions.
- **Parallelize writers by ownership.** Concurrent implementation is safe only when each agent owns distinct files/modules or isolated branches/worktrees.
- **Serialize dependent writes.** If item B depends on item A's API/shape, finish and verify A before dispatching B.
- **Pipeline instead of idling.** While waiting for one agent, prepare the next brief, verify completed receipts, update the plan, or dispatch another independent agent.
- **Use leads for branches.** If a branch of work has internal subtasks, assign an `implementation_lead` or `investigation_lead` and let it spawn its own children.
- **Use reviewers as parallel safety checks.** A `reviewer` can inspect a completed patch while a separate agent handles unrelated work.

Every parallel dispatch brief must include:

> Another agent is concurrently working on `<sibling task>` in `<files/modules>`. Avoid modifying that area. If you discover an overlap or dependency, stop and report it instead of pushing through.

## Commit-as-You-Go Discipline

For repository-changing work, make commits at stable, verified checkpoints unless the user or repo instructions say not to commit.

- Tell writer agents whether they may commit. Default: **commit after tests pass for their owned change**.
- Keep commits small and attributable: one logical change per commit, with a clear message naming the agent/task when useful.
- Never commit broken tests, unresolved merge conflicts, secrets, generated junk, or unrelated formatting churn.
- Before committing, require `git status`, relevant tests/validation, and a summary of changed files.
- After committing, require the commit hash in the agent receipt.
- If several agents write in parallel, either give each an isolated branch/worktree or have them stop before commit and let the root thread integrate sequentially.

Suggested line for writer briefs:

> Commit your completed change after validation passes. Keep the commit focused on your owned files, include the commit hash in your receipt, and do not commit unrelated changes.

## Agent Types

Use custom `agent_type` only when available in the current runtime. Otherwise stop and report that the role is unavailable.

| Agent type | Reasoning | Use |
|---|---|---|
| `code_mapper` | `low` | Read-only tracing, wiring maps, ownership maps, call paths. |
| `debugger` | `high` | Root-cause isolation from failures, logs, stack traces, or broken tests. |
| `reviewer` | `high` | PR-style review with findings first and file/line evidence. |
| `test_automator` | `medium` | Add or repair focused regression tests and run validation. |
| `docs_researcher` | `low` | Current official docs/API/library behavior checks. |
| `browser_debugger` | `medium` | Browser/UI reproduction with console, network, and DOM evidence. |
| `implementation_engineer` | `low` | Execute a well-scoped implementation item from an existing plan. |
| `implementation_lead` | `high` | Own a bounded implementation branch and spawn children as needed. |
| `investigation_lead` | `high` | Own a complex diagnosis and spawn focused probes as needed. |
| `agent_organizer` | `medium` | Disposable decomposition consultant that returns a spawn plan. |
| `workflow_orchestrator` | `xhigh` | Multi-wave planner or plan critic for complex work with dependencies and wait points. |

## Common Calls

Read-only probe:

```json
{"tool":"spawn_agent","args":{"task_name":"map_auth_flow","agent_type":"code_mapper","reasoning_effort":"low","fork_turns":"none","message":"Read-only. Trace the auth flow from entry point to side-effect boundaries. Return ordered call path, key files/symbols, risky branches, and confidence gaps. Do not edit files."}}
```

Parallel writers with non-overlap warning:

```json
{"tool":"spawn_agent","args":{"task_name":"auth_middleware_change","agent_type":"implementation_engineer","reasoning_effort":"low","fork_turns":"none","message":"Own only auth middleware files. Another agent is concurrently working on auth tests; avoid modifying tests. Implement the middleware change, run relevant validation, commit after tests pass, and return changed files, command output summary, commit hash, and risks."}}
```

```json
{"tool":"spawn_agent","args":{"task_name":"auth_tests_change","agent_type":"test_automator","reasoning_effort":"medium","fork_turns":"none","message":"Own only auth test files. Another agent is concurrently working on auth middleware; avoid modifying middleware. Add focused regression coverage, run relevant validation, commit after tests pass, and return changed files, command output summary, commit hash, and risks."}}
```

Disposable organizer:

```json
{"tool":"spawn_agent","args":{"task_name":"organize_auth_work","agent_type":"agent_organizer","reasoning_effort":"medium","fork_turns":"none","message":"Design a minimal delegation plan for fixing the auth regression. Return independent work streams, dependencies, exact prompts, sibling-conflict warnings, commit checkpoints, and what stays local. Do not implement."}}
```

Lead implementation branch:

```json
{"tool":"spawn_agent","args":{"task_name":"lead_fix_auth_regression","agent_type":"implementation_lead","reasoning_effort":"high","fork_turns":"none","message":"Own the auth regression fix end to end. You may spawn subagents for code mapping, docs lookup, test automation, or review. Keep write ownership to auth middleware and related tests. Commit stable validated checkpoints. Return only integrated summary, agents spawned, changed files, verification, commit hashes, and unresolved risks."}}
```

Review current patch:

```json
{"tool":"spawn_agent","args":{"task_name":"review_patch","agent_type":"reviewer","reasoning_effort":"high","fork_turns":"none","message":"Review the current change for correctness, regressions, security, and missing tests. Findings first with file/line evidence. Do not edit files."}}
```

## Coordination

- Use `list_agents` before waiting when the tree is complex.
- Use `wait_agent` for mailbox updates and integrate summaries, not transcripts.
- Use `send_message` for clarifications during a running task.
- Use `followup_task` when assigning a new task to an existing agent.
- Use `close_agent` after a branch or probe is no longer needed.
- Track which agents own which files, which agents may commit, and which commit hashes have landed.

## Required Agent Receipt

Require lead and leaf agents to return:

- agents spawned and why, if any
- final conclusion or patch summary
- changed files, if any
- validation performed, with exact commands and pass/fail status
- commit hash(es), or explicit reason no commit was made
- unresolved risks or conflicts
- exact next action needed from the parent

## Guardrails

- Do not delegate urgent blocking work if the root thread needs it before doing anything else.
- Do not spawn multiple writers for the same files without isolated branches/worktrees and an integration plan.
- Do not optimize for parallelism at the cost of causality: performance experiments and risky behavior changes usually need one attributed change at a time.
- Do not ask a lead agent to own the whole conversation.
- Do not keep an organizer agent alive after it returns a plan.
- Do not use subagents to avoid making user-visible decisions in the root thread.
- Do not let agents commit unrelated work or commit before validation.
