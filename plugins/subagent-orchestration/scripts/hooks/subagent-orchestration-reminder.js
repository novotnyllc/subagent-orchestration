#!/usr/bin/env node

let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", chunk => {
  raw += chunk;
});

process.stdin.on("end", () => {
  let prompt = raw;

  if (raw.trim()) {
    try {
      const payload = JSON.parse(raw);
      for (const field of ["prompt", "message", "input", "text"]) {
        if (typeof payload?.[field] === "string" && payload[field].trim()) {
          prompt = payload[field];
          break;
        }
      }
    } catch {
      prompt = raw;
    }
  }

  if (!prompt.trim()) {
    return;
  }

  const pattern = /\b(sub-?agents?|multi_agent_v2|parallel agents?|delegate|delegation|orchestrat\w*|swarm|lead agents?|leaf agents?)\b/i;
  if (pattern.test(prompt)) {
    console.log(
      "Subagent orchestration is available. Use the subagent-orchestration skill for multi_agent_v2 spawn plans, root-thread/lead/leaf roles, reasoning_effort choices, wait/list/close handling, and concise integration summaries."
    );
  }
});
