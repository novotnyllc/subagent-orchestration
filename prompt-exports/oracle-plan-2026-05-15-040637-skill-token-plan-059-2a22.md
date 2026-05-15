## Final Prompt
<taskname="Skill Token Plan"/>
<task>
Design a bounded token-minimization optimization pass for `plugins/subagent-orchestration/skills/**/SKILL.md` after rebasing onto `origin/main`. Do not implement code or content edits unless explicitly asked later. Return an actionable plan that uses the fewest prompt tokens while preserving prompt adherence and result quality.

The plan must include:
- Metric/rubric for judging token reduction, prompt adherence, quality preservation, validation consistency, and risk.
- Exact files to edit and files to treat as references only.
- First-pass concrete edits by file/pattern.
- Validation command.
- Scoreboard scaffold.
- Risks and stop criteria.

If tool/write access is available, respect the user constraint that implementation plans/specs/reports intended for humans should use the `$html-artifacts` skill and be delivered as a polished standalone HTML artifact rather than Markdown. The user supplied the html-artifacts skill text: create a self-contained `.html` file in the workspace, with semantic sections, responsive layout, tables/diagrams where useful, source/context notes, and export/copy affordances when beneficial. If the next model only answers in text, still structure the plan clearly.
</task>

<architecture>
- `plugins/subagent-orchestration/skills/*/SKILL.md`: bundled skills and the primary optimization targets. Most `rp-*-v2` skills are RepoPrompt-managed (`repoprompt_managed: true`, version 61, variant `mcp`), so direct edits may be overwritten by regeneration. The main `skills/subagent-orchestration/SKILL.md` is not RepoPrompt-managed and is the safest direct-edit candidate.
- `plugins/subagent-orchestration/skills/*/agents/openai.yaml`: tiny per-skill agent metadata; selected for completeness but not expected to need edits.
- `plugins/subagent-orchestration/scripts/validate-plugin.js`: validation gate. It requires the main subagent-orchestration skill frontmatter name/description shape and required terms: `multi_agent_v2`, `spawn_agent`, `send_message`, `followup_task`, `wait_agent`, `list_agents`, `close_agent`. It scans every skill `SKILL.md` for JSON `spawn_agent` examples and requires valid `agent_type`, matching `reasoning_effort`, and `fork_turns:"none"`.
- `.github/workflows/validate.yml`: CI runs `node plugins/subagent-orchestration/scripts/validate-plugin.js`.
- `plugins/subagent-orchestration/agents/*.toml`: reference only for valid agent names/default efforts. All currently use `gpt-5.5`; defaults are `code_mapper` low, `docs_researcher` low, `implementation_engineer` low, `test_automator` medium, `agent_organizer` medium, `browser_debugger` medium, `debugger` high, `implementation_lead` high, `investigation_lead` high, `reviewer` high, `workflow_orchestrator` xhigh.
- Plugin metadata (`.codex-plugin/plugin.json`, `hooks.json`, `.agents/plugins/marketplace.json`, README) is selected for package/validation context, not likely edit scope.
</architecture>

<selected_context>
`.github/workflows/validate.yml`: CI invokes the Node validator.
`.agents/plugins/marketplace.json`: marketplace entry and local source metadata.
`README.md`: plugin overview and listed skills/agents.
`plugins/subagent-orchestration/.codex-plugin/plugin.json`: plugin manifest listing skills, hooks, interface assets.
`plugins/subagent-orchestration/hooks.json`: UserPromptSubmit hook wiring.
`plugins/subagent-orchestration/scripts/hooks/subagent-orchestration-reminder.js`: reminder text for subagent orchestration usage.
`plugins/subagent-orchestration/scripts/validate-plugin.js`: full validator; critical constraints for skill frontmatter, required terms, agent fields, model policy, effort policy, and skill `spawn_agent` examples.
`plugins/subagent-orchestration/agents/*.toml`: all bundled agent definitions with default efforts and sandbox modes, needed for validating/reasoning about `spawn_agent` examples in skills.
`plugins/subagent-orchestration/skills/rp-build-v2/SKILL.md`: managed build workflow; contains repeated Workspace Verification, context_builder/oracle usage, and oracle export guidance.
`plugins/subagent-orchestration/skills/rp-deep-plan-v2/SKILL.md`: managed deep planning workflow; contains repeated Workspace Verification, multiple spawn examples, plan critique, oracle export handling, and cleanup guidance that currently suggests deleting exports.
`plugins/subagent-orchestration/skills/rp-investigate-v2/SKILL.md`: managed investigation workflow; contains Workspace Verification, scout/research agents, investigation_lead dispatch, oracle_send synthesis, and capability matrix.
`plugins/subagent-orchestration/skills/rp-optimize-v2/SKILL.md`: largest managed skill and primary hotspot; long Phase 1 scouting section, large context_builder template, setup/loop dispatches, scoreboard discipline, oracle stop criteria, cleanup/export text.
`plugins/subagent-orchestration/skills/rp-oracle-export-v2/SKILL.md`: managed oracle export bridge workflow; important because prompt exports are persistent GPT Pro/oracle bridges unless explicitly superseded by user direction.
`plugins/subagent-orchestration/skills/rp-orchestrate-v2/SKILL.md`: managed orchestration workflow; duplicates dispatch, parallelism, housekeeping, export cleanup, and role guidance also present elsewhere.
`plugins/subagent-orchestration/skills/rp-refactor-v2/SKILL.md`: managed refactor workflow; likely overlaps with orchestrate dispatch/parallel guidance.
`plugins/subagent-orchestration/skills/rp-reminder-v2/SKILL.md`: managed reminder workflow; compact reference for reminder behavior.
`plugins/subagent-orchestration/skills/rp-review-v2/SKILL.md`: managed review workflow; includes review-specific constraints that should not be removed.
`plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md`: non-managed main skill; safe direct-edit target. Contains broad multi_agent_v2 guidance, commit-as-you-go discipline, role table, five JSON examples, required receipt schema, and guardrails.
</selected_context>

<relationships>
- Validator reads `agents/**/*.toml` -> builds agent default effort map -> reads `skills/**/SKILL.md` -> regex-matches JSON `spawn_agent` examples -> checks each example’s `agent_type`, `reasoning_effort`, and `fork_turns:"none"`.
- Skill token optimization that changes or removes JSON examples can break validation if examples lose `agent_type`, matching `reasoning_effort`, or `fork_turns:"none"`.
- Repeated Workspace Verification appears across many managed `rp-*-v2` skills and is a major duplication hotspot, but it is also a required behavior pattern in those workflows.
- Housekeeping/export cleanup text appears in several skills. Do not recommend blanket deletion/purging of `prompt-exports/` or oracle exports: the user explicitly says these exports are persistent GPT Pro/oracle bridges unless explicitly superseded.
- `rp-orchestrate-v2` and `rp-refactor-v2` duplicate dispatch/parallel guidance; `subagent-orchestration/SKILL.md` contains canonical general multi-agent guidance that can potentially absorb/shared-reference some repeated text.
- Managed `rp-*-v2` skills may be regenerated, so first-pass planning should distinguish direct edits to managed generated files from safer changes to the source/generator/canonical shared skill. No generator/source file for these managed skills is selected or known from current context.
</relationships>

<hotspots_and_safeguards>
Token hotspots discovered:
1. `rp-optimize-v2/SKILL.md` is largest (~7.8k selected tokens); long Phase 1 scouting, context_builder template, loop/oracle/cleanup text, and role matrix.
2. Workspace Verification block is repeated across `rp-build-v2`, `rp-deep-plan-v2`, `rp-investigate-v2`, `rp-optimize-v2`, `rp-oracle-export-v2`, `rp-orchestrate-v2`, `rp-refactor-v2`, and `rp-review-v2`.
3. Housekeeping/agent cleanup/export cleanup is repeated across multiple skills.
4. `rp-orchestrate-v2` and `rp-refactor-v2` duplicate dispatch and parallel-agent guidance.
5. `skills/subagent-orchestration/SKILL.md` has multiple full JSON examples; likely can keep one read-only example and one writer/parallel example while compressing the others.

Essential quality safeguards not to remove:
- Workspace binding/verification behavior.
- Subagent pre-spawn checklist and sibling-overlap warning.
- Commit-as-you-go discipline for repository-changing work.
- Required agent receipt schema.
- Role table/role correctness and exact default reasoning efforts.
- `fork_turns:"none"` in all JSON `spawn_agent` examples.
- `rp-review-v2` comparison scope and builder review behavior.
- Oracle export actual-task rules and persistent-bridge behavior.
- Investigation selection invariant and selected-context limits.
- Deep-plan user-involvement promise.
- Optimize measure-first, one-change-per-iteration, scoreboard, variance, oracle stop signal, and termination criteria.
</hotspots_and_safeguards>

<plan_guidance>
Produce a bounded optimization plan, not edits. Recommended framing:
- Metric/rubric: baseline token count per skill, post-pass token count, percent reduction, validator pass/fail, required behavior retained, JSON example validity, managed-file regeneration risk, and quality-regression risk.
- Exact edit scope: likely first-pass direct edits to `plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md`; planned/recommended edits to managed `rp-*-v2/SKILL.md` only if the user accepts regeneration risk or identifies the upstream generator/source. Treat `validate-plugin.js`, agent TOMLs, manifests, README, hooks as reference/validation files unless the plan explicitly calls out a higher-risk validator or packaging change.
- First-pass concrete edits: compress repeated prose, replace duplicate examples with one canonical shape plus role table references, shorten housekeeping text, remove raw-transcript/log-dump encouragement if any, cap examples and receipt fields, and turn repeated long guidance into concise checklists. For managed skills, propose pattern-level patches rather than assuming hand edits are durable.
- Validation command: `node plugins/subagent-orchestration/scripts/validate-plugin.js`.
- Scoreboard scaffold: include rows for each skill file, current token count, proposed token target, edit category, critical safeguards retained, validation concerns, managed/regeneration risk, expected token reduction, quality risk, and follow-up.
- Stop criterion: one safe pass that measurably reduces skill body tokens without removing critical workflow behavior or breaking validation.
- Because repo/user instructions require commits at end of implementation turns, any later implementation pass should validate and commit after successful changes. This discover pass does not implement.
</plan_guidance>

<ambiguities>
- Managed `rp-*-v2` skills say `repoprompt_managed:true`; without the upstream generator/source in context, direct edits may be overwritten. The plan should call this out and either limit first implementation to non-managed `subagent-orchestration/SKILL.md` or define a separate step to locate/update the generator.
- “Use the fewest tokens” should not mean deleting critical workflow safeguards. Treat token minimization as bounded by validation, prompt adherence, and output quality.
- The user explicitly says not to recommend deleting/purging oracle exports as cleanup. Only recommend keeping or pruning an export when it is explicitly superseded and the workflow/user direction allows it.
</ambiguities>

## Selection
- Files: 37 total (37 full)
- Total tokens: 43242 (Auto view)
- Token breakdown: full 43242

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
│       │   ├── agent-organizer.toml — 217 tokens (full)
│       │   ├── browser-debugger.toml — 299 tokens (full)
│       │   ├── code-mapper.toml — 235 tokens (full)
│       │   ├── debugger.toml — 245 tokens (full)
│       │   ├── docs-researcher.toml — 223 tokens (full)
│       │   ├── implementation-engineer.toml — 284 tokens (full)
│       │   ├── implementation-lead.toml — 297 tokens (full)
│       │   ├── investigation-lead.toml — 293 tokens (full)
│       │   ├── reviewer.toml — 234 tokens (full)
│       │   ├── test-automator.toml — 267 tokens (full)
│       │   └── workflow-orchestrator.toml — 284 tokens (full)
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
│       │       └── SKILL.md — 2,777 tokens (full)
│       └── hooks.json — 105 tokens (full)
└── README.md — 700 tokens (full)


---

## Generated Plan

## Chat Send ✅
- **Chat**: `skill-token-plan-0590AF` | **Mode**: plan

### Response
# Skill Token Plan

## 1. Summary

Create a bounded, measurement-first token-minimization pass for `plugins/subagent-orchestration/skills/**/SKILL.md` after rebasing onto `origin/main`. The safe first pass should directly optimize the non-managed `skills/subagent-orchestration/SKILL.md`, then either update the upstream generator for `repoprompt_managed: true` `rp-*-v2` skills if found, or apply explicitly-risky managed-file edits only with a clear scoreboard entry. Preserve validator requirements, role/default-effort correctness, workflow invariants, and prompt adherence.

> HTML artifact note: the requested `$html-artifacts` delivery would normally create a standalone `.html` plan file, but this turn is text-only with no tool calls permitted. The plan below is structured so it can be converted directly into that artifact later.

---

## 2. Current-state analysis

### Relevant architecture

The optimization targets are all skill prompt files under:

```text
plugins/subagent-orchestration/skills/**/SKILL.md
```

They split into two ownership categories:

| Category | Files | Edit durability |
|---|---|---|
| Non-managed canonical skill | `plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md` | Safe direct-edit target |
| RepoPrompt-managed generated skills | `plugins/subagent-orchestration/skills/rp-*-v2/SKILL.md` | Direct edits may be overwritten unless generator/source is updated |

The managed files declare:

```yaml
repoprompt_managed: true
repoprompt_skills_version: 61
repoprompt_variant: mcp
```

No upstream generator/source is present in the selected context, so the plan must treat direct edits to managed files as a second-stage risk unless the implementer locates the generator after rebasing.

### Validation constraints

`plugins/subagent-orchestration/scripts/validate-plugin.js` is the hard validation gate. CI runs it via:

```bash
node plugins/subagent-orchestration/scripts/validate-plugin.js
```

It enforces:

- Main skill frontmatter shape for `skills/subagent-orchestration/SKILL.md`.
- Required terms in the main skill:
  - `multi_agent_v2`
  - `spawn_agent`
  - `send_message`
  - `followup_task`
  - `wait_agent`
  - `list_agents`
  - `close_agent`
- All `spawn_agent` JSON examples in every skill must include:
  - valid `agent_type`
  - matching `reasoning_effort`
  - `fork_turns: "none"`

Agent default efforts come from `plugins/subagent-orchestration/agents/*.toml` and must remain aligned.

### Main token hotspots

1. `rp-optimize-v2/SKILL.md`
   - Largest skill.
   - Long scouting table, setup templates, loop templates, role matrix, cleanup text.
2. Repeated Workspace Verification blocks across most `rp-*-v2` skills.
3. Repeated housekeeping / close-agent / export-cleanup guidance.
4. Repeated dispatch/parallelism guidance in:
   - `rp-orchestrate-v2`
   - `rp-refactor-v2`
   - `skills/subagent-orchestration/SKILL.md`
5. Multiple full JSON examples in `skills/subagent-orchestration/SKILL.md`.

### Reusable material

Reuse, do not duplicate:

- `skills/subagent-orchestration/SKILL.md` as the canonical multi-agent guidance source.
- Agent TOMLs as the source of truth for agent names and default efforts.
- `validate-plugin.js` as the structural validator.
- Existing workflow-specific invariants inside each `rp-*-v2` skill.

---

## 3. Design

### Optimization strategy

Use a targeted pass, not a broad refactor.

Rationale: the repo already has a simple file-based skill architecture and a validator. The highest-value change is prompt compression, not new runtime machinery. A broader abstraction system would add complexity and may not reduce actual prompt tokens unless the runtime supports includes/macros, which is not shown in the selected context.

### Metric and rubric

Create a scoreboard before edits and update it after each file/pattern change.

#### Required measurements

For each `SKILL.md`:

| Metric | Definition |
|---|---|
| Baseline token estimate | Token count before edits, measured consistently with one local script or tool |
| Post-pass token estimate | Token count after edits |
| Absolute token reduction | `baseline - post` |
| Percent reduction | `(baseline - post) / baseline * 100` |
| Validator result | Pass/fail for `validate-plugin.js` |
| Required terms retained | Especially for main skill |
| JSON example validity | Every `spawn_agent` block still validates |
| Managed-file risk | `none`, `low`, `high` |
| Quality risk | `low`, `medium`, `high` |

If no tokenizer is available, use byte/word counts as a consistent proxy, but record that proxy in the scoreboard.

#### Quality rubric

Score each changed skill from 0–2 in each category:

| Category | 0 | 1 | 2 |
|---|---|---|---|
| Token reduction | <5% | 5–15% | >15% |
| Prompt adherence | Lost required behavior | Minor ambiguity | All invariants retained |
| Quality preservation | Output likely worse | Some risk | Same or better |
| Validation consistency | Validator fails | Passes after adjustment | Passes first run |
| Risk | High unmanaged risk | Medium | Low |

Stop a file-level edit if total score would fall below 7/10 or any category is 0.

---

### Exact edit scope

#### Direct first-pass edit target

Edit:

```text
plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md
```

Why:

- Not marked RepoPrompt-managed.
- Contains repeated examples and broad prose.
- Validator directly checks this file, so edits must be careful but durable.

#### Conditional managed edit targets

Edit only after one of these is true:

1. The post-rebase repo contains the upstream generator/source for the managed skills and that source can be updated instead.
2. The user explicitly accepts direct edits to generated managed files.
3. The project policy confirms managed files are committed canonical outputs despite the frontmatter.

Conditional files:

```text
plugins/subagent-orchestration/skills/rp-build-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-deep-plan-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-investigate-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-optimize-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-oracle-export-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-orchestrate-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-refactor-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-reminder-v2/SKILL.md
plugins/subagent-orchestration/skills/rp-review-v2/SKILL.md
```

#### Reference-only files

Treat as reference/validation context only:

```text
plugins/subagent-orchestration/skills/*/agents/openai.yaml
plugins/subagent-orchestration/scripts/validate-plugin.js
plugins/subagent-orchestration/agents/*.toml
.github/workflows/validate.yml
plugins/subagent-orchestration/.codex-plugin/plugin.json
plugins/subagent-orchestration/hooks.json
plugins/subagent-orchestration/scripts/hooks/subagent-orchestration-reminder.js
.agents/plugins/marketplace.json
README.md
```

Do not edit these during the token-minimization pass unless validation reveals a pre-existing bug.

---

## 4. First-pass concrete edits by file/pattern

### A. `skills/subagent-orchestration/SKILL.md`

Goal: reduce tokens while preserving canonical multi-agent guidance.

Concrete edits:

1. **Compress “Operating Bias” and “Delegation Decision”**
   - Convert overlapping bullets into one checklist:
     - when to delegate
     - what stays local
     - when not to delegate
   - Preserve the root-thread responsibility rule.

2. **Merge “Before Spawning” and “Parallelization Strategy”**
   - Keep:
     - ownership boundaries
     - sibling-overlap warning
     - `fork_turns:"none"`
     - explicit `reasoning_effort`
     - no overlapping writer ownership
   - Remove repeated phrasing about not forwarding raw transcripts.

3. **Keep the role table, trim descriptions**
   - Preserve exact `agent_type` names and default efforts.
   - Shorten “Use” cells to one phrase each.

4. **Reduce JSON examples**
   - Keep only:
     - one read-only `code_mapper` example
     - one parallel writer/tester example pair
     - one reviewer example if needed to retain coverage
   - Remove or compress:
     - disposable organizer example
     - implementation lead example
   - Ensure every remaining `spawn_agent` JSON block includes valid:
     - `agent_type`
     - `reasoning_effort`
     - `fork_turns:"none"`

5. **Collapse “Coordination”, “Required Agent Receipt”, and “Guardrails”**
   - Make a single “Runtime discipline” checklist.
   - Preserve required terms:
     - `send_message`
     - `followup_task`
     - `wait_agent`
     - `list_agents`
     - `close_agent`

Expected reduction: 20–35% for this file with low durability risk.

---

### B. Managed `rp-*-v2` skills — pattern edits only after source/generator decision

#### Shared Workspace Verification block

Current repeated behavior must remain, but prose can shrink.

Pattern-level target:

- Replace long repeated explanation with a compact required step:
  - bind with `working_dirs`
  - if no match, list/switch workspace and retry
  - proceed only after success

Do not remove the requirement.

Applicable files:

```text
rp-build-v2
rp-deep-plan-v2
rp-investigate-v2
rp-optimize-v2
rp-oracle-export-v2
rp-orchestrate-v2
rp-refactor-v2
rp-review-v2
```

#### Shared housekeeping / agent cleanup text

Compress repeated cleanup into one short note:

- close agents when no longer useful
- keep heavier agents only if follow-up is likely
- do not blanket-delete `prompt-exports/`
- only delete explicitly superseded exports where workflow/user direction allows

Important: preserve persistent oracle/GPT Pro bridge behavior. Do not recommend purging exports by default.

#### Shared dispatch guidance

For `rp-orchestrate-v2` and `rp-refactor-v2`:

- Replace duplicated long dispatch-brief prose with a compact checklist:
  - scope
  - ownership
  - sibling warning
  - plan path
  - done criteria
  - no user meta-commentary forwarded

Keep role correctness and default efforts.

---

### C. `rp-optimize-v2/SKILL.md`

Largest conditional target.

Concrete compression patterns:

1. **Phase 1 scouting table**
   - Keep the five scout purposes.
   - Shorten each prompt to essentials.
   - Remove repeated examples where one JSON shape plus table is enough.

2. **Context builder setup template**
   - Keep required fields:
     - instrumentation strategy
     - baseline procedure
     - first-pass candidates
     - scoreboard scaffold
   - Shorten contextual prose.

3. **Optimization loop**
   - Preserve invariants:
     - one attributed change per iteration
     - same measurement command/sample count
     - append scoreboard rows
     - compare against variance
     - oracle stop signal
     - hard 5-loop cap
   - Compress verification bullets.

4. **Role summary matrix**
   - Remove if the preceding workflow already states ownership clearly, or reduce to one sentence.

Expected reduction: 25–40% for this file if managed edit is accepted.

---

### D. `rp-deep-plan-v2/SKILL.md`

Preserve:

- user involvement promise
- timeout behavior distinction
- plan-only rule
- critique agent constraints

Compress:

- repeated examples
- phase prose
- housekeeping/export cleanup
- anti-pattern list

Expected reduction: 15–25%.

---

### E. `rp-investigate-v2/SKILL.md`

Preserve:

- selection curation invariant
- investigation report structure
- investigation agent writes findings
- chat sees only selected files
- do not clear/set selection after context builder

Compress:

- role matrix
- repeated selection reminders
- report template comments

Expected reduction: 15–25%.

---

### F. `rp-orchestrate-v2/SKILL.md` and `rp-refactor-v2/SKILL.md`

Preserve:

- context_builder required steps
- sequential verification for dependent work
- sibling warnings for parallel work
- agent role/default effort mapping

Compress:

- dispatch brief guidance duplicated from main skill
- parallelism examples
- housekeeping

Expected reduction: 20–30%.

---

### G. `rp-build-v2`, `rp-review-v2`, `rp-oracle-export-v2`, `rp-reminder-v2`

Use lighter edits only.

Preserve:

- `rp-review-v2`: comparison-scope rules and `context_builder` review requirement.
- `rp-oracle-export-v2`: actual-task extraction and review/plan/question classification.
- `rp-build-v2`: context_builder-before-implementation rule.
- `rp-reminder-v2`: compact tool reference value.

Expected reduction:

- `rp-build-v2`: 10–20%
- `rp-review-v2`: 5–15%
- `rp-oracle-export-v2`: 10–20%
- `rp-reminder-v2`: 0–10%

---

## 5. Scoreboard scaffold

Create or update:

```text
prompt-exports/skill-token-minimization-scoreboard.md
```

Suggested scaffold:

```md
# Skill Token Minimization Scoreboard

Baseline source: post-rebase `origin/main`
Measurement method: <tokenizer or proxy>
Validation command: `node plugins/subagent-orchestration/scripts/validate-plugin.js`

| Skill file | Managed? | Baseline tokens | Target tokens | Actual tokens | Δ tokens | Δ % | Edit category | Critical safeguards retained | JSON example risk | Validation result | Quality risk | Regeneration risk | Follow-up |
|---|---:|---:|---:|---:|---:|---:|---|---|---|---|---|---|---|
| skills/subagent-orchestration/SKILL.md | no | TBD | TBD | TBD | TBD | TBD | direct canonical compression | required terms, role table, receipt, commit discipline | low | TBD | low | none | TBD |
| skills/rp-optimize-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional generated-source compression | measure-first loop, scoreboard, one-change rule, oracle stop | medium | TBD | medium | high unless generator updated | TBD |
| skills/rp-orchestrate-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional duplicate dispatch compression | ownership, sibling warning, verification loop | medium | TBD | medium | high unless generator updated | TBD |
| skills/rp-refactor-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional duplicate dispatch compression | context_builder review+plan, sequential verification | medium | TBD | medium | high unless generator updated | TBD |
| skills/rp-deep-plan-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional phase prose compression | involvement promise, timeout semantics, plan-only | medium | TBD | medium | high unless generator updated | TBD |
| skills/rp-investigate-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional report/selection compression | selected-context invariant, report findings | medium | TBD | medium | high unless generator updated | TBD |
| skills/rp-oracle-export-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional classification compression | actual-task extraction, persistent export behavior | low | TBD | medium | high unless generator updated | TBD |
| skills/rp-build-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional workflow compression | context_builder before implementation | low | TBD | low-medium | high unless generator updated | TBD |
| skills/rp-review-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | conditional review prose compression | comparison scope, review builder requirement | low | TBD | low-medium | high unless generator updated | TBD |
| skills/rp-reminder-v2/SKILL.md | yes | TBD | TBD | TBD | TBD | TBD | minimal/no-op | tool mapping and agent role reminder | low | TBD | low | high unless generator updated | TBD |
```

---

## 6. Validation command

Run after each logical edit batch:

```bash
node plugins/subagent-orchestration/scripts/validate-plugin.js
```

Also run before the final commit.

Optional consistency checks for implementation pass:

```bash
git diff -- plugins/subagent-orchestration/skills
git status --short
```

If available, measure token/word deltas before and after every changed file using one consistent method.

---

## 7. Risks and migration

### Main risks

| Risk | Impact | Mitigation |
|---|---|---|
| Managed files are regenerated | Direct edits disappear later | Prefer generator/source edits; otherwise mark high regeneration risk |
| Validator fails due changed JSON examples | CI failure | Keep valid `spawn_agent` examples with matching effort and `fork_turns:"none"` |
| Token reduction removes critical workflow behavior | Lower prompt adherence | Use safeguard checklist per file |
| Oracle/export cleanup text becomes too aggressive | Loss of persistent GPT Pro bridge artifacts | State exports are kept unless explicitly superseded |
| Main skill loses required terms | Validator failure | Preserve exact required terms |
| Over-compression harms result quality | Worse subagent behavior | Stop when quality rubric drops below threshold |

### Stop criteria

Stop the pass when any is true:

1. `validate-plugin.js` fails and the failure is not a trivial example-format fix.
2. A required workflow invariant would need to be removed to meet token targets.
3. Managed-file edits cannot be made durably and the user has not approved direct generated-file edits.
4. A changed skill scores below 7/10 on the rubric.
5. Safe first-pass reduction is achieved:
   - main skill reduced by at least 20%, or
   - total skill token reduction reaches at least 10% without touching managed files, or
   - managed-source edits achieve at least 15% total reduction with validation passing.

---

## 8. File-by-file impact

### `plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md`

- **Change**: Compress canonical orchestration guidance, examples, coordination, and guardrails.
- **Why**: Safe direct-edit file; avoids managed regeneration risk.
- **Dependencies**: Must preserve validator-required terms and valid `spawn_agent` examples.

### `plugins/subagent-orchestration/skills/rp-optimize-v2/SKILL.md`

- **Change**: Conditional compression of scouting, setup, loop, and role-matrix prose.
- **Why**: Largest token hotspot.
- **Dependencies**: Locate/update generator or accept managed-file risk.

### `plugins/subagent-orchestration/skills/rp-orchestrate-v2/SKILL.md`

- **Change**: Conditional compression of dispatch/parallelism/export handoff prose.
- **Why**: Duplicates canonical main skill guidance.
- **Dependencies**: Preserve workflow-specific context_builder and verification loop.

### `plugins/subagent-orchestration/skills/rp-refactor-v2/SKILL.md`

- **Change**: Conditional compression of dispatch, steering, and verification guidance.
- **Why**: Overlaps with orchestrate and main skill.
- **Dependencies**: Preserve refactor-specific context_builder review + plan requirement.

### `plugins/subagent-orchestration/skills/rp-deep-plan-v2/SKILL.md`

- **Change**: Conditional compression of phase prose and examples.
- **Why**: Large workflow with repeated scaffolding.
- **Dependencies**: Preserve user involvement promise and timeout semantics.

### `plugins/subagent-orchestration/skills/rp-investigate-v2/SKILL.md`

- **Change**: Conditional compression of role matrix, report template, repeated selection reminders.
- **Why**: Reduces duplication while retaining investigation invariants.
- **Dependencies**: Preserve selected-context and report-writing behavior.

### `plugins/subagent-orchestration/skills/rp-oracle-export-v2/SKILL.md`

- **Change**: Conditional compression of export path/classification prose.
- **Why**: Moderate token reduction.
- **Dependencies**: Preserve actual-task extraction and persistent export handling.

### `plugins/subagent-orchestration/skills/rp-build-v2/SKILL.md`

- **Change**: Conditional light compression.
- **Why**: Smaller but contains repeated workspace/context-builder text.
- **Dependencies**: Preserve context_builder-before-implementation rule.

### `plugins/subagent-orchestration/skills/rp-review-v2/SKILL.md`

- **Change**: Conditional light compression.
- **Why**: Avoid over-editing review-specific guardrails.
- **Dependencies**: Preserve comparison-scope and code-review builder behavior.

### `plugins/subagent-orchestration/skills/rp-reminder-v2/SKILL.md`

- **Change**: Minimal or no edit.
- **Why**: Already compact and useful as a quick reference.
- **Dependencies**: None beyond validator example checks.

### Reference-only files

No planned edits:

```text
plugins/subagent-orchestration/scripts/validate-plugin.js
plugins/subagent-orchestration/agents/*.toml
plugins/subagent-orchestration/skills/*/agents/openai.yaml
.github/workflows/validate.yml
README.md
plugins/subagent-orchestration/.codex-plugin/plugin.json
plugins/subagent-orchestration/hooks.json
.agents/plugins/marketplace.json
```

---

## 9. Implementation order

1. **Rebase and inspect**
   - Rebase onto `origin/main`.
   - Confirm no unresolved conflicts.
   - Inspect whether managed skill generator/source files now exist.

2. **Measure baseline**
   - Count tokens or a consistent proxy for every `skills/**/SKILL.md`.
   - Create the scoreboard scaffold.
   - Run `node plugins/subagent-orchestration/scripts/validate-plugin.js`.

3. **Safe first pass**
   - Edit only `skills/subagent-orchestration/SKILL.md`.
   - Apply compression patterns above.
   - Re-measure this file.
   - Run validator.
   - Update scoreboard.

4. **Managed-source decision**
   - If generator/source exists, update that source and regenerate managed skills.
   - If no source exists, either stop after safe pass or proceed only if direct managed edits are accepted.

5. **Conditional managed pass**
   - Start with `rp-optimize-v2/SKILL.md`.
   - Then handle `rp-orchestrate-v2` and `rp-refactor-v2`.
   - Then apply lighter edits to remaining managed skills.
   - Validate after each batch.

6. **Final validation**
   - Run:
     ```bash
     node plugins/subagent-orchestration/scripts/validate-plugin.js
     ```
   - Confirm scoreboard is complete.
   - Confirm no critical safeguards were removed.

7. **Commit**
   - Commit the validated optimization pass with a focused message such as:
     ```text
     Optimize skill prompt token usage
     ```
   - Include the scoreboard if created as a tracked artifact and appropriate for the repo.


> 💡 Continue this plan conversation with ask_oracle(chat_id: "skill-token-plan-0590AF", new_chat: false)