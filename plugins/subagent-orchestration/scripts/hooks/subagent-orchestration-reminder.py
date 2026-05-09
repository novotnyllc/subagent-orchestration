#!/usr/bin/env python3
import json
import re
import sys


def prompt_from_stdin(raw: str) -> str:
    if not raw.strip():
        return ""
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        return raw

    if isinstance(payload, dict):
        for field in ("prompt", "message", "input", "text"):
            value = payload.get(field)
            if isinstance(value, str) and value.strip():
                return value
    return raw


prompt = prompt_from_stdin(sys.stdin.read())
if not prompt.strip():
    sys.exit(0)

pattern = re.compile(
    r"\b(sub-?agents?|multi_agent_v2|parallel agents?|delegate|delegation|"
    r"orchestrat\w*|swarm|lead agents?|leaf agents?)\b",
    re.IGNORECASE,
)

if pattern.search(prompt):
    print(
        "Subagent orchestration is available. Use the subagent-orchestration "
        "skill for multi_agent_v2 spawn plans, root-thread/lead/leaf roles, "
        "reasoning_effort choices, wait/list/close handling, and concise "
        "integration summaries."
    )
