# Subagent Orchestration

`subagent-orchestration` is a Codex marketplace plugin from Claire Novotny LLC for using Codex `multi_agent_v2` subagents without turning the root thread into a cluttered working context.

It packages:

- a `subagent-orchestration` skill
- a prompt-gated hook that reminds Codex when subagent delegation is relevant
- bundled agent definitions for mapper, debugger, reviewer, test, docs, browser, lead, and planner roles
- marketplace metadata under `.agents/plugins/marketplace.json`

This plugin targets `multi_agent_v2` only. In the local Codex build used to create the package, `multi_agent_v2` is listed as `under development` and disabled by default, so validation sessions should enable it explicitly.

## Layout

```text
.agents/plugins/marketplace.json
plugins/subagent-orchestration/
  .codex-plugin/plugin.json
  hooks.json
  skills/subagent-orchestration/SKILL.md
  scripts/hooks/subagent-orchestration-reminder.ps1
  scripts/validate-plugin.ps1
  agents/*.toml
  assets/icon.svg
```

## Local Development

Validate the package from the repository root:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\plugins\subagent-orchestration\scripts\validate-plugin.ps1
```

Add this checkout as a local marketplace:

```powershell
codex plugin marketplace add . --enable multi_agent_v2
```

For a GitHub marketplace install after publication:

```powershell
codex plugin marketplace add novotnyllc/subagent-orchestration
```

When starting a session that should use these examples, enable `multi_agent_v2`:

```powershell
codex --enable multi_agent_v2
```

## Usage

Invoke the skill when a task needs delegated work:

```text
Use subagent-orchestration to split this debugging task into lead and leaf agents.
```

The root thread should stay the user-facing integrator. Use:

- `agent_organizer` for short-lived spawn planning
- `implementation_lead` or `investigation_lead` for bounded branches
- leaf roles like `code_mapper`, `debugger`, `reviewer`, `test_automator`, `docs_researcher`, and `browser_debugger` for narrow work

## Runtime Notes

Current local checks found:

- `multi_agent_v2` exists but is disabled by default in this build.
- `UserPromptSubmit` hook shape is supported by installed plugins.
- Local marketplace add succeeds with `codex plugin marketplace add . --enable multi_agent_v2`.
- Agent files are packaged at plugin level and may need a fresh `--enable multi_agent_v2` session for direct spawn validation.

If agent TOMLs are not auto-discovered by the current runtime, copy the desired files from `plugins/subagent-orchestration/agents/` into either repo-local `.codex/agents/` or user-level `<codex-home>/agents/`.
