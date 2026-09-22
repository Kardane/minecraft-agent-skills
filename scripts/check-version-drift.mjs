#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const repoRoot = process.cwd();

const activeFiles = [
  "README.md",
  "AGENTS.md",
  ".agents/skills/minecraft-fabric-server-dev/SKILL.md",
  ".agents/skills/minecraft-commands-scripting/SKILL.md",
  ".agents/skills/minecraft-commands-scripting/references/command-reference.md",
  ".agents/skills/minecraft-world-generation/SKILL.md",
  ".agents/skills/minecraft-server-admin/SKILL.md",
  ".agents/skills/minecraft-ci-release/SKILL.md",
  ".agents/skills/minecraft-ci-release/references/publishing-gradle.md",
  ".agents/skills/minecraft-java-reference-hub/SKILL.md",
  ".agents/skills/minecraft-java-reference-hub/agents/openai.yaml"
];

const forbidden = [/\b26\.x\b/i, /\b26\.2\b/i, /\bJava 25\b/i, /\b1\.21\.11\b/];
let failures = 0;

for (const file of activeFiles) {
  const text = fs.readFileSync(path.join(repoRoot, file), "utf8");
  if (!/1\.21\.8/.test(text)) {
    console.error(`[FAIL] ${file} does not mention the repository baseline Minecraft 1.21.8`);
    failures += 1;
  }
  for (const pattern of forbidden) {
    if (pattern.test(text)) {
      console.error(`[FAIL] ${file} contains out-of-baseline version guidance: ${pattern}`);
      failures += 1;
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

for (const file of java21Files) {
  const text = fs.readFileSync(path.join(repoRoot, file), "utf8");
  if (!/Java 21|JDK 21|java-version: "21"/.test(text)) {
    console.error(`[FAIL] ${file} does not carry the Java 21 baseline`);
    failures += 1;
  }
}

if (failures > 0) {
  console.error(`[FAIL] version drift check failed with ${failures} issue(s)`);
  process.exit(1);
}

console.log("[PASS] active guidance is pinned to Minecraft 1.21.8 / Java 21");
