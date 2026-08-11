#!/usr/bin/env node
// Independent cross-check: parse every agents/openai.yaml with the `yaml` npm
// package and compare structure against what the Python/pyyaml pass produced.
const fs = require("fs");
const path = require("path");
const YAML = require("yaml");

const repo = process.argv[2] || "repo-copy";
const skillsRoot = path.join(repo, "skills");

const results = [];
for (const bucket of fs.readdirSync(skillsRoot).sort()) {
  const bdir = path.join(skillsRoot, bucket);
  if (!fs.statSync(bdir).isDirectory()) continue;
  for (const name of fs.readdirSync(bdir).sort()) {
    const sdir = path.join(bdir, name);
    if (!fs.existsSync(path.join(sdir, "SKILL.md"))) continue;
    const yamlPath = path.join(sdir, "agents", "openai.yaml");
    const entry = { bucket, skill: name, file: path.relative(repo, yamlPath) };
    if (!fs.existsSync(yamlPath)) {
      results.push({ ...entry, parsed: false, error: "file missing" });
      continue;
    }
    try {
      const doc = YAML.parse(fs.readFileSync(yamlPath, "utf8"));
      results.push({
        ...entry,
        parsed: true,
        display_name: doc?.interface?.display_name ?? null,
        short_description: doc?.interface?.short_description ?? null,
        allow_implicit_invocation:
          doc?.policy?.allow_implicit_invocation ?? null,
        topLevelKeys: Object.keys(doc || {}).sort(),
      });
    } catch (e) {
      results.push({ ...entry, parsed: false, error: String(e.message) });
    }
  }
}
console.log(JSON.stringify(results, null, 2));
