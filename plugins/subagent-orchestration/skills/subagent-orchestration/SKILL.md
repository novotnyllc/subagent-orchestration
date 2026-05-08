---
name: subagent-orchestration
description: Use for Codex multi_agent_v2 subagent delegation and orchestration: deciding when to spawn agents, root-thread versus organizer/lead/leaf-agent patterns, fork_turns choices, custom agent_type roles, spawn prompt templates, wait/list/close handling, and keeping the main thread clean during long or parallel work.
---

# Subagent Orchestration

Use this skill when a task would benefit from Codex `multi_agent_v2` delegation. Target `multi_agent_v2` only; if that surface is not available, explain that this skill requires it instead of falling back to older `multi_agent` calls.

## Mental Model

- Keep the root thread as the user-facing integrator, decision maker, and final verifier.
- Use an `agent_organizer` only as a short-lived planner when decomposition itself is hard.
- Use a lead agent for a bounded branch of work that may spawn its own children.
- Use leaf agents for narrow mapping, debugging, docs lookup, browser reproduction, review, or test work.
- Do not forward raw child transcripts back to the root thread. Return concise receipts.

## Before Spawning

1. Identify the immediate blocker that should stay local.
2. Split only independent side work or bounded branch work into agents.
3. Give each agent exact ownership, expected evidence, and a compact return format.
4. Choose `fork_turns` deliberately:
   - `"none"` for clean read-only probes with self-contained prompts.
   - `"3"` for tasks that need recent local context.
   - `"all"` only when the complete thread history is essential.
5. Prefer no `model` override unless the user requested one or the task clearly requires it.

## Agent Types

Use custom `agent_type` only when available in the current runtime. Otherwise stop and report that the role is unavailable.

| Agent type | Use |
|---|---|
| `code_mapper` | Read-only tracing, wiring maps, ownership maps, call paths. |
| `debugger` | Root-cause isolation from failures, logs, stack traces, or broken tests. |
| `reviewer` | PR-style review with findings first and file/line evidence. |
| `test_automator` | Add or repair focused regression tests and run validation. |
| `docs_researcher` | Current official docs/API/library behavior checks. |
| `browser_debugger` | Browser/UI reproduction with console, network, and DOM evidence. |
| `implementation_lead` | Own a bounded implementation branch and spawn children as needed. |
| `investigation_lead` | Own a complex diagnosis and spawn focused probes as needed. |
| `agent_organizer` | Disposable decomposition consultant that returns a spawn plan. |
| `workflow_orchestrator` | Multi-wave planner for complex work with dependencies and wait points. |

## Common Calls

Read-only probe:

```json
{"tool":"spawn_agent","args":{"task_name":"map_auth_flow","agent_type":"code_mapper","fork_turns":"none","message":"Read-only. Trace the auth flow from entry point to side-effect boundaries. Return ordered call path, key files/symbols, risky branches, and confidence gaps. Do not edit files."}}
```

Disposable organizer:

```json
{"tool":"spawn_agent","args":{"task_name":"organize_auth_work","agent_type":"agent_organizer","fork_turns":"3","message":"Design a minimal delegation plan for fixing the auth regression. Return task names, agent types, exact prompts, dependencies, and what stays local. Do not implement."}}
```

Lead implementation branch:

```json
{"tool":"spawn_agent","args":{"task_name":"lead_fix_auth_regression","agent_type":"implementation_lead","fork_turns":"3","message":"Own the auth regression fix end to end. You may spawn subagents for code mapping, docs lookup, test automation, or review. Keep write ownership to auth middleware and related tests. Return only integrated summary, changed files, verification, and unresolved risks."}}
```

Review current patch:

```json
{"tool":"spawn_agent","args":{"task_name":"review_patch","agent_type":"reviewer","fork_turns":"3","message":"Review the current change for correctness, regressions, security, and missing tests. Findings first with file/line evidence. Do not edit files."}}
```

## Coordination

- Use `list_agents` before waiting when the tree is complex.
- Use `wait_agent` for mailbox updates and integrate summaries, not transcripts.
- Use `send_message` for clarifications during a running task.
- Use `followup_task` when assigning a new task to an existing agent.
- Use `close_agent` after a branch or probe is no longer needed.

## Required Agent Receipt

Require lead and leaf agents to return:

- agents spawned and why, if any
- final conclusion or patch summary
- changed files, if any
- verification performed
- unresolved risks
- exact next action needed from the parent

## Guardrails

- Do not delegate urgent blocking work if the root thread needs it before doing anything else.
- Do not spawn multiple writers for the same files.
- Do not ask a lead agent to own the whole conversation.
- Do not keep an organizer agent alive after it returns a plan.
- Do not use subagents to avoid making user-visible decisions in the root thread.
