## Final Prompt
<taskname="Agent Optimization"/>
<task>
Design a bounded optimization pass over the bundled subagent-orchestration agents in `plugins/subagent-orchestration/agents/*.toml`. Do not implement the edits unless explicitly asked later. Return an actionable plan for minimizing token use and improving prompt adherence while preserving or improving result quality. The plan must include: metric/rubric, exact files in scope, first-pass concrete edits, validation command, and scoreboard scaffold.

Respect the repo/user constraint that implementation plans/specs/reports intended for humans should use the `$html-artifacts` skill and be polished HTML artifacts rather than Markdown, if tool access is available to the next model. If the next model only answers in text, still structure the plan clearly.
</task>

<architecture>
- `plugins/subagent-orchestration/agents/*.toml`: 11 provided Codex agent definitions. Each has `name`, `description`, `model`, `model_reasoning_effort`, `sandbox_mode`, `nickname_candidates`, and `developer_instructions`. These are the primary optimization targets.
- `plugins/subagent-orchestration/scripts/validate-plugin.js`: repo validation and CI gate. It requires every agent TOML to use exactly `model = "gpt-5.5"`, requires effort in `low|medium|high|xhigh`, and enforces that every skill `spawn_agent` example uses the same `reasoning_effort` as that agent’s default. Changing model values or default efforts therefore requires coordinated validator/skill updates and is higher risk.
- `.github/workflows/validate.yml`: CI runs `node plugins/subagent-orchestration/scripts/validate-plugin.js`.
- `plugins/subagent-orchestration/skills/**/SKILL.md`: orchestration workflows and spawn examples. These reference shipped `agent_type` names and reasoning efforts; include them when evaluating whether effort defaults or caller guidance should change.
- `plugins/subagent-orchestration/skills/rp-reminder-v2/SKILL.md` and `plugins/subagent-orchestration/scripts/hooks/subagent-orchestration-reminder.js`: existing reminder surfaces for multi-agent usage, useful for consistency if adding commit-as-you-go guidance.
- `plugins/subagent-orchestration/.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`, `plugins/subagent-orchestration/hooks.json`, and `README.md`: package metadata and public positioning; included for validation and scope awareness.
</architecture>

<selected_context>
.agents/plugins/marketplace.json: Marketplace entry for local plugin source and policy metadata.
.github/workflows/validate.yml: CI validation command; runs the same Node validator.
README.md: Repo/package overview.
plugins/subagent-orchestration/.codex-plugin/plugin.json: Plugin manifest with skills/hooks/interface metadata.
plugins/subagent-orchestration/hooks.json: UserPromptSubmit hook command wired to Node reminder script.
plugins/subagent-orchestration/scripts/hooks/subagent-orchestration-reminder.js: Prompt-gated reminder text for subagent orchestration.
plugins/subagent-orchestration/scripts/validate-plugin.js: Full validator implementation; critical constraints for model, effort, required fields, known agent types, `fork_turns:"none"`, and skill example effort matching.
plugins/subagent-orchestration/agents/agent-organizer.toml: read-only decomposition consultant; medium effort; currently returns delegation plan fields.
plugins/subagent-orchestration/agents/browser-debugger.toml: workspace-write browser/UI investigator; medium effort; needs evidence discipline and edit/commit safeguards if assigned writes.
plugins/subagent-orchestration/agents/code-mapper.toml: read-only mapper; low effort; needs concise file/line evidence discipline.
plugins/subagent-orchestration/agents/debugger.toml: read-only root-cause investigator; high effort; may be a candidate for tighter evidence/output budget guidance.
plugins/subagent-orchestration/agents/docs-researcher.toml: read-only official-doc researcher; low effort; needs concise citations/version discipline.
plugins/subagent-orchestration/agents/implementation-engineer.toml: workspace-write low-overhead implementer; low effort; primary candidate for commit-as-you-go reminders and ownership/validation safeguards.
plugins/subagent-orchestration/agents/implementation-lead.toml: workspace-write branch-level implementer; high effort; can spawn children; primary candidate for commit-as-you-go, no raw transcripts, explicit ownership, validation, integration summary.
plugins/subagent-orchestration/agents/investigation-lead.toml: workspace-write but diagnostic; high effort; already says only assigned investigation/report artifact, no source changes.
plugins/subagent-orchestration/agents/reviewer.toml: read-only PR-style reviewer; high effort; needs concise findings and no bloat.
plugins/subagent-orchestration/agents/test-automator.toml: workspace-write test implementer; medium effort; primary candidate for commit-as-you-go and scope/validation safeguards.
plugins/subagent-orchestration/agents/workflow-orchestrator.toml: workspace-write planner; xhigh effort; already limited to planning/review artifacts, no implementation files; likely candidate for stricter output budgets/artifact boundaries.
plugins/subagent-orchestration/skills/**/SKILL.md and `agents/openai.yaml`: All shipped skills included full to inspect spawn examples, effort guidance, and role selection tables before recommending any effort/default changes.
</selected_context>

<relationships>
- Validator walks `plugins/subagent-orchestration/agents/**/*.toml` -> checks required TOML fields -> requires `model === "gpt-5.5"` -> records each agent’s default `model_reasoning_effort`.
- Validator walks `plugins/subagent-orchestration/skills/**/SKILL.md` -> regex finds JSON `spawn_agent` blocks -> requires `agent_type` exists, `reasoning_effort` is present, matches that agent’s default, and `fork_turns:"none"` is present.
- Skill docs such as `rp-orchestrate-v2`, `rp-optimize-v2`, `rp-refactor-v2`, `rp-deep-plan-v2`, and `rp-investigate-v2` are downstream callers of these agent definitions and must remain consistent if defaults change.
- Writer-capable agents are those with `sandbox_mode = "workspace-write"`: `browser_debugger`, `implementation_engineer`, `implementation_lead`, `investigation_lead`, `test_automator`, `workflow_orchestrator`. Commit-as-you-go reminders should be targeted to writer-capable implementation/test/browser roles, with care for planner/diagnostic roles that should only write assigned artifacts.
- Read-only agents are `agent_organizer`, `code_mapper`, `debugger`, `docs_researcher`, `reviewer`; optimization should focus on concise outputs, evidence limits, scope discipline, and no-edit adherence.
</relationships>

<discovered_constraints>
- Current inventory: 11 agent TOMLs. Defaults are: `agent_organizer` medium, `browser_debugger` medium, `code_mapper` low, `debugger` high, `docs_researcher` low, `implementation_engineer` low, `implementation_lead` high, `investigation_lead` high, `reviewer` high, `test_automator` medium, `workflow_orchestrator` xhigh. All use `gpt-5.5`.
- Repo was clean at discovery time (`git status`: no changes).
- Validation command: `node plugins/subagent-orchestration/scripts/validate-plugin.js`.
- CI runs the same validation command.
- Safe first pass should probably avoid changing enforced model policy. Model tuning is effectively blocked by current validator unless the plan deliberately includes validator policy changes as a separate higher-risk track.
- Effort tuning is allowed by validator only if all skill spawn examples are updated to match the new agent default; this may be too broad for the first safe pass.
</discovered_constraints>

<plan_requirements>
The next response should produce an actionable bounded optimization setup, not code edits. Include:
- Metric/rubric: score token discipline, prompt adherence, quality preservation, role safety, validation consistency, commit hygiene for writer-capable agents.
- Exact files in scope: at minimum `plugins/subagent-orchestration/agents/*.toml`; include `plugins/subagent-orchestration/skills/**/SKILL.md` and `plugins/subagent-orchestration/scripts/validate-plugin.js` as constraint/reference files, and only modify validator/manifest if the plan explicitly accepts that risk.
- First-pass concrete edits: likely add concise output budget/anti-bloat language, no raw child transcripts/log dumps, evidence caps, scope boundaries, validation reporting, and commit-as-you-go reminders for writer-capable agents. Keep edits minimal and consistent across roles.
- Validation command: `node plugins/subagent-orchestration/scripts/validate-plugin.js`.
- Scoreboard scaffold: a table/template that can track each agent, current effort, proposed effort change or no-change, target behavior, token-risk reduction, prompt-adherence risk addressed, quality regression risk, files touched, validation status, and follow-up notes.
</plan_requirements>

<ambiguities>
- “Best model and effort” conflicts with validator policy: changing `model` away from `gpt-5.5` will fail validation unless the validator policy is changed. Treat model policy changes as a separate risk decision, not a default first-pass edit.
- “Commit as they go” can mean actual `git commit` behavior, a reminder to make atomic commits when assigned, or a reporting/checkpoint discipline. The plan should phrase this carefully for writer-capable agents and avoid telling read-only agents to commit.
- Some workspace-write agents are planners/diagnostics (`investigation_lead`, `workflow_orchestrator`) and already restrict writes to artifacts. Commit guidance there should not imply source-code edits.
</ambiguities>

## Selection
- Files: 37 total (37 full)
- Total tokens: 42389 (Auto view)
- Token breakdown: full 42389

### Files
### Selected Files
/Users/claire/dev/subagent-orchestration/
├── .agents/
│   └── plugins/
│       └── marketplace.json — 108 tokens (full)
├── .github/
│   └── workflows/
│       └── validate.yml — 105 tokens (full)
├── plugins/
│   └── subagent-orchestration/
│       ├── .codex-plugin/
│       │   └── plugin.json — 524 tokens (full)
│       ├── agents/
│       │   ├── agent-organizer.toml — 161 tokens (full)
│       │   ├── browser-debugger.toml — 187 tokens (full)
│       │   ├── code-mapper.toml — 181 tokens (full)
│       │   ├── debugger.toml — 181 tokens (full)
│       │   ├── docs-researcher.toml — 161 tokens (full)
│       │   ├── implementation-engineer.toml — 179 tokens (full)
│       │   ├── implementation-lead.toml — 200 tokens (full)
│       │   ├── investigation-lead.toml — 214 tokens (full)
│       │   ├── reviewer.toml — 159 tokens (full)
│       │   ├── test-automator.toml — 181 tokens (full)
│       │   └── workflow-orchestrator.toml — 222 tokens (full)
│       ├── scripts/
│       │   ├── hooks/
│       │   │   └── subagent-orchestration-reminder.js — 257 tokens (full)
│       │   └── validate-plugin.js — 2,206 tokens (full)
│       ├── skills/
│       │   ├── rp-build-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 2,252 tokens (full)
│       │   ├── rp-deep-plan-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 4,601 tokens (full)
│       │   ├── rp-investigate-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 4,356 tokens (full)
│       │   ├── rp-optimize-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 7,771 tokens (full)
│       │   ├── rp-oracle-export-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 2,977 tokens (full)
│       │   ├── rp-orchestrate-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 4,765 tokens (full)
│       │   ├── rp-refactor-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 3,964 tokens (full)
│       │   ├── rp-reminder-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 10 tokens (full)
│       │   │   └── SKILL.md — 1,265 tokens (full)
│       │   ├── rp-review-v2/
│       │   │   ├── agents/
│       │   │   │   └── openai.yaml — 11 tokens (full)
│       │   │   └── SKILL.md — 1,533 tokens (full)
│       │   └── subagent-orchestration/
│       │       └── SKILL.md — 2,776 tokens (full)
│       └── hooks.json — 105 tokens (full)
└── README.md — 700 tokens (full)


---

## Generated Plan

## Chat Send ✅
- **Chat**: `agent-optimization-574679` | **Mode**: plan

### Response
# 1. Summary

Design a **targeted optimization pass** over `plugins/subagent-orchestration/agents/*.toml` only, preserving all current `model` and `model_reasoning_effort` defaults to avoid validator and skill-doc churn. The pass should tighten each bundled agent’s `developer_instructions` for lower token use, stronger role adherence, clearer evidence discipline, safer write boundaries, and better validation/commit receipts for writer-capable roles. Treat `plugins/subagent-orchestration/scripts/validate-plugin.js` and `plugins/subagent-orchestration/skills/**/SKILL.md` as constraints/reference surfaces unless a later, higher-risk phase intentionally changes model/effort policy.

# 2. Current-state analysis

## Relevant architecture

The plugin defines 11 Codex agent roles under:

```text
plugins/subagent-orchestration/agents/*.toml
```

Each TOML owns:

- `name`
- `description`
- `model`
- `model_reasoning_effort`
- `sandbox_mode`
- `nickname_candidates`
- `developer_instructions`

The key mutation surface for this optimization pass is **only** `developer_instructions`.

## Validation and downstream constraints

`plugins/subagent-orchestration/scripts/validate-plugin.js` enforces:

- every agent TOML has required fields;
- every agent uses `model = "gpt-5.5"`;
- every `model_reasoning_effort` is one of `low|medium|high|xhigh`;
- every skill `spawn_agent` JSON example references a known `agent_type`;
- every skill example’s `reasoning_effort` matches that agent’s default;
- every example uses `fork_turns:"none"`.

CI runs:

```bash
node plugins/subagent-orchestration/scripts/validate-plugin.js
```

via `.github/workflows/validate.yml`.

## Current agent groups

### Read-only agents

- `agent_organizer.toml`
- `code-mapper.toml`
- `debugger.toml`
- `docs-researcher.toml`
- `reviewer.toml`

Optimization focus:

- concise outputs;
- file/line evidence caps;
- no edits;
- no transcript dumps;
- avoid broad exploration.

### Writer-capable agents

- `browser-debugger.toml`
- `implementation-engineer.toml`
- `implementation-lead.toml`
- `investigation-lead.toml`
- `test-automator.toml`
- `workflow-orchestrator.toml`

Optimization focus:

- explicit ownership;
- validation reporting;
- no unrelated edits;
- commit/checkpoint guidance only where appropriate;
- artifact-only write limits for planning/investigation roles.

## Blocking constraints

Do **not** change `model` or `model_reasoning_effort` in the first pass. Those values are coupled to the validator and skill examples. Changing them requires coordinated updates across:

```text
plugins/subagent-orchestration/scripts/validate-plugin.js
plugins/subagent-orchestration/skills/**/SKILL.md
plugins/subagent-orchestration/agents/*.toml
```

That is broader than necessary for the requested bounded optimization.

# 3. Design

## Recommended approach: targeted prompt edit, not broad refactor

Use a **targeted edit pass** over `developer_instructions` because the current architecture is already simple and validation-friendly. The goal is not to redesign the plugin, but to improve agent behavior through concise, role-specific instruction changes.

Avoid:

- new shared prompt files;
- validator policy changes;
- model changes;
- default effort changes;
- broad skill-doc rewrites.

## Metric / rubric

Score each agent before and after on a 0–5 scale.

| Category | Weight | Applies to | Target |
|---|---:|---|---|
| Token discipline | 25% | all agents | output shape is compact; no raw logs/transcripts; evidence is capped |
| Prompt adherence | 25% | all agents | stays within assigned role, scope, and file ownership |
| Quality preservation | 20% | all agents | still returns enough evidence/results for parent orchestration |
| Role safety | 15% | all agents | read-only agents do not edit; writer agents do not broaden scope |
| Validation consistency | 10% | all agents | validator still passes; no model/effort drift |
| Commit/checkpoint hygiene | 5% | writer-capable implementation/test/browser agents | atomic commit guidance when explicitly assigned or allowed |

Acceptance threshold:

- weighted score improves or stays equal for every agent;
- no category below 4 after edits;
- validator passes;
- no skill examples require updates in first pass.

## First-pass concrete edits

Apply concise instruction additions and trims inside each agent’s `developer_instructions`.

### Shared anti-bloat language for all agents

Add or integrate role-appropriate language equivalent to:

```text
Keep the receipt compact. Do not paste raw transcripts, full logs, or large code excerpts. Include only the evidence needed for the parent to verify the result.
```

### Read-only agents

#### `agent-organizer.toml`

Goal: reduce over-planning.

First-pass edits:

- state “max one page” or “compact bullets”;
- cap spawn plan to necessary agents only;
- require stop conditions and dependencies;
- explicitly say not to include generic workflow advice.

#### `code-mapper.toml`

Goal: make mapping cheaper and more actionable.

First-pass edits:

- cap to 3–5 key files/symbols unless asked otherwise;
- prefer file/line anchors over prose;
- report confidence gaps instead of chasing every branch;
- no large excerpts.

#### `debugger.toml`

Goal: prevent sprawling investigations.

First-pass edits:

- require top 1–2 likely causes first;
- separate reproduced evidence from hypothesis;
- cap logs to exact error strings and file anchors;
- include minimal fix direction, not full implementation plan.

#### `docs-researcher.toml`

Goal: concise external facts.

First-pass edits:

- cite 2–3 primary sources max unless asked;
- include version/date only when relevant;
- avoid tutorial-style explanations;
- return exact API/config only if directly actionable.

#### `reviewer.toml`

Goal: findings-first, no review bloat.

First-pass edits:

- cap findings unless critical issues exceed cap;
- require severity and file/line evidence;
- avoid positive-summary padding;
- no implementation rewrites.

### Writer-capable agents

#### `implementation-engineer.toml`

Goal: strong scope and validation discipline for low-effort execution.

First-pass edits:

- “own only assigned files/modules”;
- “stop and ask parent if scope expands”;
- require exact validation command and pass/fail;
- commit only when parent explicitly permits or repo instructions require it;
- if committing, report focused commit hash.

#### `implementation-lead.toml`

Goal: prevent child-agent transcript bloat and improve integration receipts.

First-pass edits:

- no raw child transcripts;
- summarize child results as decisions/evidence;
- keep write ownership explicit;
- commit stable validated checkpoints when assigned/allowed;
- receipt includes changed files, validation, commit hashes or reason none.

#### `test-automator.toml`

Goal: keep test work focused.

First-pass edits:

- only add tests for specified behavior;
- production changes require explicit justification;
- report test names and exact commands;
- commit focused test changes only when allowed.

#### `browser-debugger.toml`

Goal: evidence without bulky browser dumps.

First-pass edits:

- cap evidence to console/network/DOM facts needed for reproduction;
- include viewport and repro steps;
- edit only if explicitly assigned;
- if assigned to fix, validate browser behavior and report changed files.

#### `investigation-lead.toml`

Goal: preserve artifact-only write boundary.

First-pass edits:

- reinforce no source edits;
- write only assigned report/artifact;
- summarize spawned agents, not transcripts;
- include eliminated hypotheses to prevent repeat work.

Do **not** add commit-as-you-go source guidance here unless the assignment explicitly allows source edits.

#### `workflow-orchestrator.toml`

Goal: keep plans bounded.

First-pass edits:

- cap output to dependency graph, waves, checkpoints, risks;
- write only assigned planning/review artifacts;
- prefer fewer agents and clear ownership;
- no implementation file edits.

Do **not** add implementation commit guidance here.

# 4. File-by-file impact

## Primary modification files

### `plugins/subagent-orchestration/agents/agent-organizer.toml`

- Modify `developer_instructions`.
- Add compact-output and minimal-agent-plan guidance.
- No field/model/effort changes.

### `plugins/subagent-orchestration/agents/browser-debugger.toml`

- Modify `developer_instructions`.
- Add evidence caps, explicit edit boundary, validation receipt guidance.

### `plugins/subagent-orchestration/agents/code-mapper.toml`

- Modify `developer_instructions`.
- Add file/line cap and no-excerpt guidance.

### `plugins/subagent-orchestration/agents/debugger.toml`

- Modify `developer_instructions`.
- Add reproduced-vs-hypothesis structure and compact log guidance.

### `plugins/subagent-orchestration/agents/docs-researcher.toml`

- Modify `developer_instructions`.
- Add primary-source cap and version/date discipline.

### `plugins/subagent-orchestration/agents/implementation-engineer.toml`

- Modify `developer_instructions`.
- Add scope, validation, and conditional commit receipt guidance.

### `plugins/subagent-orchestration/agents/implementation-lead.toml`

- Modify `developer_instructions`.
- Add child-summary, checkpoint, validation, and commit-hash guidance.

### `plugins/subagent-orchestration/agents/investigation-lead.toml`

- Modify `developer_instructions`.
- Reinforce report-only writes and no raw child transcripts.

### `plugins/subagent-orchestration/agents/reviewer.toml`

- Modify `developer_instructions`.
- Add severity/cap/no-padding guidance.

### `plugins/subagent-orchestration/agents/test-automator.toml`

- Modify `developer_instructions`.
- Add focused-test, validation, and conditional commit guidance.

### `plugins/subagent-orchestration/agents/workflow-orchestrator.toml`

- Modify `developer_instructions`.
- Add bounded-plan and artifact-only write guidance.

## Reference-only files

### `plugins/subagent-orchestration/scripts/validate-plugin.js`

- No first-pass edits.
- Used to confirm constraints and validate final package.

### `plugins/subagent-orchestration/skills/**/SKILL.md`

- No first-pass edits.
- Only modify in a later phase if changing default efforts or role guidance.

### `.github/workflows/validate.yml`

- No edits.
- Confirms CI uses the validator.

# 5. Risks and migration

## Main risk: over-tightening prompts

If instructions become too terse, agents may omit useful evidence. Mitigation: every role should still return enough verification data for the parent agent.

## Model/effort risk

Changing `model` or `model_reasoning_effort` is intentionally deferred. It would require validator and skill-example updates.

## Commit guidance ambiguity

Use conditional wording:

```text
Commit only when explicitly assigned, allowed by repo instructions, or requested by the parent.
```

Do not tell read-only, planner, or diagnostic roles to commit source changes.

# 6. Scoreboard scaffold

Use this table during implementation and review:

| Agent file | Current effort | Effort change | Target behavior | Token-risk reduction | Adherence risk addressed | Quality regression risk | Files touched | Validation status | Follow-up notes |
|---|---|---|---|---|---|---|---|---|---|
| `agent-organizer.toml` | medium | none | compact spawn plan | TBD | over-planning | low | TBD | TBD | TBD |
| `browser-debugger.toml` | medium | none | concise repro evidence | TBD | editing without assignment | medium | TBD | TBD | TBD |
| `code-mapper.toml` | low | none | short file/line map | TBD | broad exploration | low | TBD | TBD | TBD |
| `debugger.toml` | high | none | top causes + evidence | TBD | log dumping | medium | TBD | TBD | TBD |
| `docs-researcher.toml` | low | none | primary-source facts | TBD | tutorial bloat | low | TBD | TBD | TBD |
| `implementation-engineer.toml` | low | none | scoped execution receipt | TBD | scope creep | medium | TBD | TBD | TBD |
| `implementation-lead.toml` | high | none | integrated branch summary | TBD | child transcript bloat | medium | TBD | TBD | TBD |
| `investigation-lead.toml` | high | none | report-only diagnosis | TBD | source edits during investigation | low | TBD | TBD | TBD |
| `reviewer.toml` | high | none | findings-first review | TBD | non-actionable review prose | low | TBD | TBD | TBD |
| `test-automator.toml` | medium | none | focused tests + command evidence | TBD | production drift | medium | TBD | TBD | TBD |
| `workflow-orchestrator.toml` | xhigh | none | bounded execution plan | TBD | over-planning / source edits | low | TBD | TBD | TBD |

# 7. Validation command

Run from repository root:

```bash
node plugins/subagent-orchestration/scripts/validate-plugin.js
```

Expected result:

```text
subagent-orchestration plugin validation passed.
```

# 8. Implementation order

1. Baseline the scoreboard using current agent defaults and current validator result.
2. Edit only `developer_instructions` in the 11 agent TOML files.
3. Keep `model`, `model_reasoning_effort`, and `sandbox_mode` unchanged.
4. Run the validator.
5. Review each modified instruction block against the rubric.
6. Fill the scoreboard with before/after notes.
7. If validation passes and rubric scores improve, stop.
8. Defer effort/model tuning to a separate explicit phase only if needed.


> 💡 Continue this plan conversation with ask_oracle(chat_id: "agent-optimization-574679", new_chat: false)