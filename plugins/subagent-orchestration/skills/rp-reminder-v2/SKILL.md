---
name: "rp-reminder-v2"
description: "Reminder to use RepoPrompt MCP tools"
repoprompt_managed: true
repoprompt_skills_version: 60
repoprompt_variant: mcp
---

# RepoPrompt Tools Reminder

Continue your current workflow using RepoPrompt MCP tools instead of built-in alternatives.

## File & Code

| Task | Use | Not |
|------|-----|-----|
| Search paths/content | `file_search` | grep, find, Glob |
| Read file (whole or sliced) | `read_file` | cat, head, Read |
| Directory tree | `get_file_tree` | ls, find |
| Signatures / overview | `get_code_structure` | reading whole files |
| Edit file | `apply_edits` | sed, Edit |
| Create / delete / move | `file_actions` | touch, rm, mv, Write |
| Git status / diff / log / blame | `git` | shelling out for analysis |

## Context & Planning

| Tool | Use for |
|------|---------|
| `manage_selection` | Curate the file set used by chat, builder, and exports. Refresh before each planning call. Modes: `full`, `slices`, `codemap_only`. |
| `workspace_context` | Snapshot current prompt + selection + token budget; also exports. |
| `prompt` | Read/set the shared prompt; list or select copy presets. |
| `context_builder` | Heavy discovery sub-agent — describe the task, it curates files + rewrites the prompt. `response_type`: `clarify` / `plan` / `question` / `review`. Pass `export_response:true` to hand the result to a child agent. |
| `ask_oracle` | Chat-mode reasoning over the current selection. Continue existing chats (`new_chat:false`) rather than opening new ones. Modes: `chat` / `plan` / `review`. |
| `oracle_chat_log` | Recover recent Oracle messages after compaction. |
| `ask_user` | Ask the user when ambiguity is load-bearing — don't guess at requirements. |

## Agent Delegation -- `multi_agent_v2`

Dispatch a sub-agent when a side investigation or delegated chunk of work would otherwise flood this session's context. Use shipped Codex agents directly, not RepoPrompt role labels. Always pass `fork_turns:"none"` because these agents read context from the first message. Always pass the listed `reasoning_effort`.

| Agent type | Reasoning | Use |
|------------|-----------|-----|
| `code_mapper` | `low` | Fast read-only probes, git archaeology, wiring lookups, narrow in-repo checks. One question per probe. |
| `docs_researcher` | `low` | External docs, library/API behavior, web research, standards. |
| `implementation_engineer` | `low` | Well-scoped implementation work from an existing plan. |
| `implementation_lead` | `high` | Complex implementation work, architecture-sensitive changes, or branch-level ownership. |
| `investigation_lead` | `high` | Multi-step root cause analysis and evidence gathering. |
| `test_automator` | `medium` | Focused test, benchmark, or verification work. |
| `browser_debugger` | `medium` | Browser/UI runtime debugging. |
| `workflow_orchestrator` | `xhigh` | Plan critique, dependency/risk analysis, coordination review. |

**Key operations:**
- Start: `spawn_agent` with `task_name`, `agent_type`, `reasoning_effort`, `fork_turns:"none"`, and a self-contained `message`.
- Wait/check: `wait_agent`, then `list_agents` for current status.
- Continue: `followup_task` with the target task name.
- Close: `close_agent` once you have recorded the result.

**Fan-out pattern:** call `spawn_agent` once per independent probe, then use `wait_agent` and `list_agents` until every spawned agent has returned. There is no detach flag in this workflow; `spawn_agent` already creates independent agents.

**Export handoff:** when `context_builder` or `ask_oracle` returns `oracle_export_path`, include that path inside the child agent's next `message` so it reads the export with `read_file`.

## Quick Reference

```json
// Search · Read · Edit · File ops
{"tool":"file_search","args":{"pattern":"keyword","mode":"auto"}}
{"tool":"read_file","args":{"path":"Root/file.swift","start_line":50,"limit":30}}
{"tool":"apply_edits","args":{"path":"Root/file.swift","search":"old","replace":"new"}}
{"tool":"file_actions","args":{"action":"create","path":"Root/new.swift","content":"..."}}

// Selection · Builder · Oracle
{"tool":"manage_selection","args":{"op":"add","paths":["Root/path/file.swift"]}}
{"tool":"context_builder","args":{"instructions":"<task>","response_type":"plan"}}
{"tool":"ask_oracle","args":{"message":"...","mode":"plan","new_chat":false}}

// Delegate · Fan-out · Steer · Cleanup
{"tool":"spawn_agent","args":{"task_name":"probe_x","agent_type":"code_mapper","reasoning_effort":"low","fork_turns":"none","message":"<question>"}}
{"tool":"wait_agent","args":{"timeout_ms":60000}}
{"tool":"list_agents","args":{}}
{"tool":"followup_task","args":{"target":"probe_x","message":"now do Y"}}
{"tool":"close_agent","args":{"target":"probe_x"}}
```

Continue with your task using these tools.
