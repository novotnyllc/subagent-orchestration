# Skill Token Minimization Scoreboard

Updated: 2026-05-15T08:08:43.010Z

Measurement method: local Node.js proxy for every `plugins/subagent-orchestration/skills/**/SKILL.md`: UTF-8 byte count, regex word count (`/[A-Za-z0-9_]+/g`), and token proxy count (`/[A-Za-z0-9_]+|[^\sA-Za-z0-9_]/gu`). The token proxy is not a model tokenizer; it is a consistent local comparison metric.

Validation command: `node plugins/subagent-orchestration/scripts/validate-plugin.js`

## Results

| Skill file | Managed? | Baseline token proxy | Baseline words | Baseline bytes | Final token proxy | Final words | Final bytes | Δ token proxy | Δ % | Edit category | Safeguards retained | Validation | Risk/follow-up |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|---|---|---|
| `plugins/subagent-orchestration/skills/rp-build-v2/SKILL.md` | yes | 2060 | 1173 | 8582 | 2060 | 1173 | 8582 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-deep-plan-v2/SKILL.md` | yes | 4632 | 2584 | 17528 | 4632 | 2584 | 17528 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-investigate-v2/SKILL.md` | yes | 3906 | 2149 | 16596 | 3906 | 2149 | 16596 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-optimize-v2/SKILL.md` | yes | 6974 | 4221 | 29604 | 6974 | 4221 | 29604 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-oracle-export-v2/SKILL.md` | yes | 2842 | 1653 | 11344 | 2842 | 1653 | 11344 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-orchestrate-v2/SKILL.md` | yes | 4535 | 2559 | 18155 | 4535 | 2559 | 18155 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-refactor-v2/SKILL.md` | yes | 3618 | 2089 | 15104 | 3618 | 2089 | 15104 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-reminder-v2/SKILL.md` | yes | 1372 | 561 | 4820 | 1372 | 561 | 4820 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/rp-review-v2/SKILL.md` | yes | 1477 | 758 | 5840 | 1477 | 758 | 5840 | 0 | 0.0% | no edit in safe first pass | unchanged | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | managed rp-*-v2 skill left unchanged |
| `plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md` | no | 2294 | 1456 | 10580 | 1467 | 872 | 6811 | 827 | 36.1% | direct canonical compression | multi_agent_v2 and required tools retained; exact agent_type names/default efforts retained; valid spawn_agent JSON examples retain agent_type, matching reasoning_effort, fork_turns:"none"; delegation bias, parallel safety, commit discipline, receipt schema, guardrails retained | `node plugins/subagent-orchestration/scripts/validate-plugin.js` passed | low; monitor whether shorter prose is too terse for edge-case delegation |

## Edited Skill Reduction

- `plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md`: 2294 → 1467 token proxy (827 fewer, 36.1% reduction); words 1456 → 872; bytes 10580 → 6811.

## Safe First Pass Scope

- Edited only `plugins/subagent-orchestration/skills/subagent-orchestration/SKILL.md`.
- Did not edit managed `rp-*-v2` skills, validator, agent TOMLs, plugin metadata, hooks, README, or existing oracle exports.
- Safeguards retained: required validator terms, exact role/default-effort table, valid examples, delegation bias, parallel safety, commit discipline, required receipt schema, and guardrails.
