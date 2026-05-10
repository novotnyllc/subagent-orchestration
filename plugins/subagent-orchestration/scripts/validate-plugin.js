#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "../../..");
const pluginRoot = path.join(repoRoot, "plugins", "subagent-orchestration");
const errors = [];

function addError(message) {
  errors.push(message);
}

function existsFile(filePath) {
  try {
    return fs.statSync(filePath).isFile();
  } catch {
    return false;
  }
}

function existsDir(dirPath) {
  try {
    return fs.statSync(dirPath).isDirectory();
  } catch {
    return false;
  }
}

function requireFile(filePath) {
  if (!existsFile(filePath)) {
    addError(`Missing file: ${filePath}`);
  }
}

function readText(filePath) {
  return fs.readFileSync(filePath, "utf8");
}

function readJson(filePath) {
  requireFile(filePath);
  if (!existsFile(filePath)) {
    return null;
  }
  try {
    return JSON.parse(readText(filePath));
  } catch (error) {
    addError(`Invalid JSON: ${filePath} :: ${error.message}`);
    return null;
  }
}

function tomlString(content, fieldName) {
  const match = content.match(new RegExp(`^${fieldName}\\s*=\\s*"([^"]+)"`, "m"));
  return match?.[1] ?? null;
}

function hasTomlField(content, fieldName) {
  return new RegExp(`^${fieldName}\\s*=\\s*("""|"|'')`, "m").test(content);
}

function walkFiles(dirPath, predicate, results = []) {
  if (!existsDir(dirPath)) {
    return results;
  }
  for (const entry of fs.readdirSync(dirPath, { withFileTypes: true })) {
    const fullPath = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      walkFiles(fullPath, predicate, results);
    } else if (entry.isFile() && predicate(fullPath)) {
      results.push(fullPath);
    }
  }
  return results;
}

function lineAt(text, index) {
  return text.slice(0, index).split("\n").length;
}

const marketplacePath = path.join(repoRoot, ".agents", "plugins", "marketplace.json");
const pluginManifestPath = path.join(pluginRoot, ".codex-plugin", "plugin.json");
const hooksPath = path.join(pluginRoot, "hooks.json");
const skillPath = path.join(pluginRoot, "skills", "subagent-orchestration", "SKILL.md");
const hookScriptPath = path.join(pluginRoot, "scripts", "hooks", "subagent-orchestration-reminder.js");
const agentsPath = path.join(pluginRoot, "agents");
const iconPath = path.join(pluginRoot, "assets", "icon.svg");

const marketplace = readJson(marketplacePath);
if (marketplace) {
  if (marketplace.name !== "subagent-orchestration") addError("Marketplace name must be subagent-orchestration.");
  if (marketplace.interface?.displayName !== "Subagent Orchestration") addError("Marketplace interface.displayName must be Subagent Orchestration.");
  const entry = marketplace.plugins?.find(plugin => plugin.name === "subagent-orchestration");
  if (!entry) {
    addError("Marketplace missing subagent-orchestration entry.");
  } else {
    if (entry.source?.source !== "local") addError("Marketplace source.source must be local.");
    if (entry.source?.path !== "./plugins/subagent-orchestration") addError("Marketplace source.path must be ./plugins/subagent-orchestration.");
    if (!entry.policy?.installation) addError("Marketplace entry missing policy.installation.");
    if (!entry.policy?.authentication) addError("Marketplace entry missing policy.authentication.");
    if (!entry.category) addError("Marketplace entry missing category.");
  }
}

const manifest = readJson(pluginManifestPath);
if (manifest) {
  for (const field of ["name", "version", "description", "author", "homepage", "repository", "license", "skills", "hooks", "interface"]) {
    if (!Object.hasOwn(manifest, field)) {
      addError(`Plugin manifest missing ${field}.`);
    }
  }
  if (manifest.name !== "subagent-orchestration") addError("Plugin manifest name mismatch.");
  if (manifest.skills !== "./skills/") addError("Plugin manifest skills must be ./skills/.");
  if (manifest.hooks !== "./hooks.json") addError("Plugin manifest hooks must be ./hooks.json.");
  for (const relative of [manifest.skills, manifest.hooks, manifest.interface?.composerIcon, manifest.interface?.logo]) {
    if (!relative) continue;
    const resolved = path.join(pluginRoot, relative.replace(/^\.\//, ""));
    if (!fs.existsSync(resolved)) {
      addError(`Manifest path does not exist: ${relative}`);
    }
  }
}

const hooks = readJson(hooksPath);
if (hooks) {
  if (!hooks.hooks?.UserPromptSubmit) addError("hooks.json must define UserPromptSubmit.");
  const hookText = readText(hooksPath);
  if (/\b(pwsh|powershell|python3|python)\b|\.ps1|\.py/i.test(hookText)) {
    addError("hooks.json hook command must use Node, not PowerShell or Python.");
  }
  if (!/\bnode\b.*subagent-orchestration-reminder\.js/i.test(hookText)) {
    addError("hooks.json must explicitly invoke Node for subagent-orchestration-reminder.js.");
  }
}

requireFile(skillPath);
if (existsFile(skillPath)) {
  const skill = readText(skillPath);
  if (!/^---\s*\nname:\s*subagent-orchestration\s*\ndescription:/s.test(skill)) {
    addError("Skill frontmatter missing name/description.");
  }
  for (const term of ["multi_agent_v2", "spawn_agent", "send_message", "followup_task", "wait_agent", "list_agents", "close_agent"]) {
    if (!skill.includes(term)) {
      addError(`Skill missing required term: ${term}`);
    }
  }
}

requireFile(hookScriptPath);
requireFile(iconPath);

if (!existsDir(agentsPath)) {
  addError(`Missing agents directory: ${agentsPath}`);
} else {
  const seen = new Set();
  const agentDefaultEfforts = new Map();
  const agentFiles = walkFiles(agentsPath, filePath => filePath.endsWith(".toml"));
  if (agentFiles.length < 10) {
    addError("Expected at least 10 bundled agent TOML files.");
  }

  for (const agentFile of agentFiles) {
    const content = readText(agentFile);
    const base = path.basename(agentFile);
    for (const field of ["name", "description", "developer_instructions", "model", "model_reasoning_effort", "sandbox_mode"]) {
      if (!hasTomlField(content, field)) {
        addError(`${base} missing ${field}.`);
      }
    }

    const name = tomlString(content, "name");
    if (!name) continue;
    if (seen.has(name)) {
      addError(`Duplicate agent name: ${name}`);
    } else {
      seen.add(name);
    }

    const model = tomlString(content, "model");
    if (model !== "gpt-5.5") {
      addError(`${base} must use model gpt-5.5.`);
    }

    const effort = tomlString(content, "model_reasoning_effort");
    if (!["low", "medium", "high", "xhigh"].includes(effort)) {
      addError(`${base} has invalid model_reasoning_effort: ${effort}`);
    } else {
      agentDefaultEfforts.set(name, effort);
    }
  }

  const skillFiles = walkFiles(path.join(pluginRoot, "skills"), filePath => path.basename(filePath) === "SKILL.md");
  for (const skillFile of skillFiles) {
    const skillName = path.basename(path.dirname(skillFile));
    if (skillName.includes("-cli")) {
      addError(`CLI skill is not allowed in this plugin: ${skillName}`);
    }

    const content = readText(skillFile);
    const spawnRegex = /\{\s*"tool"\s*:\s*"spawn_agent"\s*,\s*"args"\s*:\s*\{.*?\}\s*\}/gs;
    for (const match of content.matchAll(spawnRegex)) {
      const block = match[0];
      const line = lineAt(content, match.index ?? 0);
      const agentType = block.match(/"agent_type"\s*:\s*"([^"]+)"/)?.[1] ?? null;
      if (!agentType) {
        addError(`${skillName}:${line} spawn_agent call missing agent_type.`);
      } else if (!seen.has(agentType)) {
        addError(`${skillName}:${line} references unknown agent_type: ${agentType}`);
      }

      const reasoningEffort = block.match(/"reasoning_effort"\s*:\s*"([^"]+)"/)?.[1] ?? null;
      if (!reasoningEffort) {
        addError(`${skillName}:${line} spawn_agent call missing reasoning_effort.`);
      } else if (agentType && agentDefaultEfforts.has(agentType) && agentDefaultEfforts.get(agentType) !== reasoningEffort) {
        addError(`${skillName}:${line} uses ${agentType} with reasoning_effort '${reasoningEffort}' but agent default is '${agentDefaultEfforts.get(agentType)}'.`);
      }

      if (!/"fork_turns"\s*:\s*"none"/.test(block)) {
        addError(`${skillName}:${line} spawn_agent call must use fork_turns "none".`);
      }
    }
  }
}

if (errors.length > 0) {
  console.error(`Validation failed:\n - ${errors.join("\n - ")}`);
  process.exit(1);
}

console.log("subagent-orchestration plugin validation passed.");
