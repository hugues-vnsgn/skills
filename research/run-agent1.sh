#!/bin/bash
cd /Users/hugues_mini/Codes/skills
echo "=== Research agent 1 (agent1-kmp-core) starting ==="
claude -p "$(cat research/prompts/agent1-kmp-core.md)"   --allowedTools "WebFetch,WebSearch,Write,Read"   --permission-mode acceptEdits   --verbose 2>&1 | tee research/agent1-kmp-core.log
echo "=== agent 1 done (report: research/agent1-kmp-core.md) ==="
