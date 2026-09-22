#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const canonicalDir = path.join(root, ".agents", "skills");
const readmePath = path.join(root, "README.md");
const agentsPath = path.join(root, "AGENTS.md");
const codexManifestPath = path.join(root, "plugins", "minecraft-codex-skills", ".codex-plugin", "plugin.json");
const claudeManifestPath = path.join(root, "plugins", "minecraft-codex-skills", ".claude-plugin", "plugin.json");

const errors = [];

const canonical = fs.readdirSync(canonicalDir, { withFileTypes: true })
  .filter((entry) => entry.isDirectory() && fs.existsSync(path.join(canonicalDir, entry.name, "SKILL.md")))
  .map((entry) => entry.name)
  .sort();

function section(text, heading) {
  const start = text.indexOf(heading);
  if (start < 0) return null;
  const bodyStart = start + heading.length;
  const next = text.indexOf("\n## ", bodyStart);
  return text.slice(bodyStart, next < 0 ? undefined : next);
}

function compareSets(label, expected, actual) {
  const expectedSet = new Set(expected);
  const actualSet = new Set(actual);
  for (const item of expectedSet) {
    if (!actualSet.has(item)) errors.push(`${label}: missing ${item}`);
  }
  for (const item of actualSet) {
    if (!expectedSet.has(item)) errors.push(`${label}: unknown/stale entry ${item}`);
  }
  if (actual.length !== actualSet.size) errors.push(`${label}: duplicate skill entry`);
}

const readme = fs.readFileSync(readmePath, "utf8");
const included = section(readme, "## Included skills");
if (!included) {
  errors.push("README.md: missing Included skills section");
} else {
  const names = [...included.matchAll(/^\| \`([a-z0-9-]+)\` \|/gm)].map((match) => match[1]).sort();
  compareSets("README.md Included skills", canonical, names);
}

const routing = section(readme, "## Recommended routing");
if (!routing) {
  errors.push("README.md: missing Recommended routing section");
} else {
  const names = [...routing.matchAll(/\| \`([a-z0-9-]+)\` \|$/gm)].map((match) => match[1]).sort();
  compareSets("README.md Recommended routing", canonical, names);
}

const volatileCountPattern = /\b\d+\s+Minecraft\s+skills\b/i;
for (const file of [readmePath, agentsPath, codexManifestPath, claudeManifestPath]) {
  const text = fs.readFileSync(file, "utf8");
  if (volatileCountPattern.test(text)) {
    errors.push(`${path.relative(root, file)}: hard-coded skill count is not allowed; derive from .agents/skills instead`);
  }
}

for (const manifestPath of [codexManifestPath, claudeManifestPath]) {
  const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
  if (typeof manifest.description !== "string" || !/Minecraft/i.test(manifest.description)) {
    errors.push(`${path.relative(root, manifestPath)}: description must identify the Minecraft bundle`);
  }
}

if (errors.length > 0) {
  console.error("Skill metadata consistency check failed:\n");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`[PASS] skill metadata: ${canonical.length} canonical skills; README inventory/routing match; no hard-coded skill count`);
