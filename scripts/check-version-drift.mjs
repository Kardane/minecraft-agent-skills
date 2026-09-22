#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const repoRoot = process.cwd();

const checks = [
  {
    file: ".agents/skills/minecraft-ci-release/SKILL.md",
    references: [".agents/skills/minecraft-ci-release/references/publishing-gradle.md"],
    required: [
      /1\.0\.0\+26\.2/,
      /gameVersions\.add\(minecraftVersion\)/,
      /mainFile\.addGameVersion\(minecraftVersion\)/,
      /providers\.gradleProperty\("minecraft_version"\)/,
      /minecraft_version=26\.2/,
      /java-version: "25"/
    ],
    forbidden: [
      /1\.0\.0\+1\.21\.1\s+← mod 1\.0\.0 for MC 1\.21\.1/,
      /gameVersions\.addAll\("1\.21\.1"\)/,
      /cf\.addGameVersion\("1\.21\.1"\)/
    ]
  },
  {
    file: ".agents/skills/minecraft-server-admin/SKILL.md",
    required: [
      /minecraft-server:java25/,
      /VERSION: "26\.2"/,
      /java -Xms4G -Xmx4G -jar server\.jar --nogui/
    ]
  }
];

let failures = 0;

for (const check of checks) {
  const target = path.join(repoRoot, check.file);
  const text = [target, ...(check.references ?? []).map((file) => path.join(repoRoot, file))]
    .map((file) => fs.readFileSync(file, "utf8"))
    .join("\n");

  for (const pattern of check.required ?? []) {
    if (!pattern.test(text)) {
      console.error(`[FAIL] ${check.file} missing required pattern: ${pattern}`);
      failures += 1;
    }
  }

  for (const pattern of check.forbidden ?? []) {
    if (pattern.test(text)) {
      console.error(`[FAIL] ${check.file} still matches forbidden pattern: ${pattern}`);
      failures += 1;
    }
  }
}

if (failures > 0) {
  console.error(`[FAIL] version drift check failed with ${failures} issue(s)`);
  process.exit(1);
}

console.log("[PASS] version drift check passed");
