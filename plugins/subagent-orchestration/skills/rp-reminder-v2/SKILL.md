---
name: "rp-reminder-v2"
description: "Reminder to use RepoPrompt MCP tools"
repoprompt_managed: true
repoprompt_skills_version: 59
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

Dispatch a sub-agent when a side investigation or delegated chunk of work would otherwise flood this session's context. Use shipped agent types, not RepoPrompt role labels. Always pass `fork_turns:"none"` and the role's `reasoning_effort`; these agents are built to read the needed context from the first message.

| Agent type | Reasoning | Use for |
|------------|-----------|---------|
| `code_mapper` | `low` | Fast read-only probes: git archaeology, wiring maps, ownership maps, narrow lookups. One question per probe. |
| `docs_researcher` | `low` | Current official docs/API/library behavior checks. |
| `implementation_lead` | `high` | Bounded implementation branches and integrated changes. |
| `investigation_lead` | `high` | Complex diagnosis that may need focused child probes. |
| `test_automator` | `medium` | Focused regression tests, harness updates, and validation commands. |
| `reviewer` | `high` | PR-style review for correctness, regressions, security, and missing tests. |
| `browser_debugger` | `medium` | Browser/UI reproduction with console, network, DOM, and screenshot evidence. |
| `agent_organizer` | `medium` | Disposable delegation planning when task decomposition itself is unclear. |
| `workflow_orchestrator` | `high` | Multi-wave workflow planning with dependencies and wait points. |

**Key operations:** `spawn_agent` starts a child, `wait_agent` waits for mailbox updates, `list_agents` inspects live agents, `followup_task` steers an existing agent and triggers a turn, `send_message` sends a clarification without triggering a turn, and `close_agent` dismisses a completed agent.

**Fan-out pattern:** call `spawn_agent` once per independent probe, then use `wait_agent` and `list_agents` until every spawned agent has returned. There is no `detach` flag in this workflow; `spawn_agent` already creates independent agents.

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
{"tool":"wait_agent","args":{}}
{"tool":"list_agents","args":{}}
{"tool":"followup_task","args":{"target":"probe_x","message":"now do Y"}}
{"tool":"close_agent","args":{"target":"probe_x"}}
```

Continue with your task using these tools.