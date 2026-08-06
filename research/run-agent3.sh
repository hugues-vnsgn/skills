#!/bin/bash
cd /Users/hugues_mini/Codes/skills
echo "=== Research agent 3 (agent3-publishing) starting ==="
claude -p "$(cat research/prompts/agent3-publishing.md)"   --allowedTools "WebFetch,WebSearch,Write,Read"   --permission-mode acceptEdits   --verbose 2>&1 | tee research/agent3-publishing.log
echo "=== agent 3 done (report: research/agent3-publishing.md) ==="
