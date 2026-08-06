#!/bin/bash
cd /Users/hugues_mini/Codes/skills
echo "=== Research agent 2 (agent2-compose-cocoapods) starting ==="
claude -p "$(cat research/prompts/agent2-compose-cocoapods.md)"   --allowedTools "WebFetch,WebSearch,Write,Read"   --permission-mode acceptEdits   --verbose 2>&1 | tee research/agent2-compose-cocoapods.log
echo "=== agent 2 done (report: research/agent2-compose-cocoapods.md) ==="
