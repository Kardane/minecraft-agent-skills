#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const canonical = path.join(root, ".agents", "skills");
const errors = [];

const forbidden = [
  { pattern: /\b26\.x\b/i, label: "Minecraft 26.x" },
  { pattern: /\b26\.2\b/i, label: "Minecraft 26.2" },
  { pattern: /\bJava 25\b/i, label: "Java 25" },
  { pattern: /\b1\.21\.11\b/, label: "Minecraft 1.21.11" },
  { pattern: /\b1\.21\.10\b/, label: "Minecraft 1.21.10" },
  { pattern: /\b1\.21\.9\b/, label: "Minecraft 1.21.9" },
  { pattern: /\b1\.21\.5\b/, label: "Minecraft 1.21.5" }
];

function walk(dir) {
  const out = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walk(full));
    else out.push(full);
  }
  return out;
}

const files = [
  path.join(root, "README.md"),
  path.join(root, "AGENTS.md"),
  ...walk(canonical).filter((file) => /\.(?:md|ya?ml|json|sh|mjs)$/.test(file))
];

for (const file of files) {
  const text = fs.readFileSync(file, "utf8");
  for (const { pattern, label } of forbidden) {
    if (pattern.test(text)) {
      errors.push(`${path.relative(root, file).replaceAll(path.sep, "/")}: contains out-of-baseline guidance (${label})`);
    }
  }
}

const java21Files = [
  "README.md",
  "AGENTS.md",
  ".agents/skills/minecraft-fabric-server-dev/SKILL.md",
  ".agents/skills/minecraft-server-admin/SKILL.md",
  ".agents/skills/minecraft-ci-release/SKILL.md",
  ".agents/skills/minecraft-ci-release/references/publishing-gradle.md"
];

for (const rel of java21Files) {
  const text = fs.readFileSync(path.join(root, rel), "utf8");
  if (!/Java 21|JDK 21|java-version: "21"/.test(text)) {
    errors.push(`${rel}: does not carry the Java 21 baseline`);
  }
}

if (errors.length > 0) {
  console.error("Version drift check failed:\n");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`[PASS] Minecraft 1.21.8 / Java 21 baseline; scanned ${files.length} canonical guidance files`);
