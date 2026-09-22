#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const skillsDir = path.join(root, ".agents", "skills");
const evalPath = path.join(root, "tests", "routing", "skill-routing-evals.json");

const errors = [];
const skillNames = fs.readdirSync(skillsDir, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();
const skillSet = new Set(skillNames);
const capabilityOwner = new Map();
const skillCapabilities = new Map();

for (const skill of skillNames) {
  const skillFile = path.join(skillsDir, skill, "SKILL.md");
  const text = fs.readFileSync(skillFile, "utf8");
  const match = text.match(/^- `Primary capabilities`:\s*(.+)$/m);
  if (!match) {
    errors.push(`${skill}: missing machine-readable Primary capabilities line`);
    continue;
  }

  const capabilities = [...match[1].matchAll(/`([a-z0-9-]+)`/g)].map((m) => m[1]);
  if (capabilities.length === 0) {
    errors.push(`${skill}: Primary capabilities line has no capability ids`);
    continue;
  }
  skillCapabilities.set(skill, capabilities);

  for (const capability of capabilities) {
    if (capabilityOwner.has(capability)) {
      errors.push(`capability ${capability} has multiple primary owners: ${capabilityOwner.get(capability)}, ${skill}`);
    } else {
      capabilityOwner.set(capability, skill);
    }
  }
}

const suite = JSON.parse(fs.readFileSync(evalPath, "utf8"));
if (!Array.isArray(suite.cases) || suite.cases.length === 0) {
  errors.push("routing eval corpus has no cases");
}

const ids = new Set();
const casesPerSkill = new Map(skillNames.map((skill) => [skill, 0]));
const casesPerCapability = new Map([...capabilityOwner.keys()].map((cap) => [cap, 0]));

for (const testCase of suite.cases ?? []) {
  const label = testCase.id ?? "<missing-id>";
  if (typeof testCase.id !== "string" || !/^[a-z0-9-]+$/.test(testCase.id)) {
    errors.push(`${label}: invalid id`);
  } else if (ids.has(testCase.id)) {
    errors.push(`${label}: duplicate id`);
  } else {
    ids.add(testCase.id);
  }

  if (typeof testCase.prompt !== "string" || testCase.prompt.trim().length < 8) {
    errors.push(`${label}: prompt is missing or too short`);
  }

  const owner = capabilityOwner.get(testCase.capability);
  if (!owner) {
    errors.push(`${label}: unknown capability ${testCase.capability}`);
    continue;
  }
  casesPerCapability.set(testCase.capability, (casesPerCapability.get(testCase.capability) ?? 0) + 1);

  if (testCase.expected_primary !== owner) {
    errors.push(`${label}: expected_primary=${testCase.expected_primary} but capability ${testCase.capability} is owned by ${owner}`);
  }
  if (!skillSet.has(testCase.expected_primary)) {
    errors.push(`${label}: unknown expected_primary skill ${testCase.expected_primary}`);
  } else {
    casesPerSkill.set(testCase.expected_primary, (casesPerSkill.get(testCase.expected_primary) ?? 0) + 1);
  }

  const supporting = testCase.allowed_supporting ?? [];
  if (!Array.isArray(supporting)) {
    errors.push(`${label}: allowed_supporting must be an array`);
    continue;
  }
  const seen = new Set();
  for (const skill of supporting) {
    if (!skillSet.has(skill)) errors.push(`${label}: unknown supporting skill ${skill}`);
    if (skill === testCase.expected_primary) errors.push(`${label}: primary skill duplicated in allowed_supporting`);
    if (seen.has(skill)) errors.push(`${label}: duplicate supporting skill ${skill}`);
    seen.add(skill);
  }
}

for (const [capability, count] of casesPerCapability) {
  if (count === 0) errors.push(`capability ${capability} has no routing eval case`);
}
for (const [skill, count] of casesPerSkill) {
  if (count < 2) errors.push(`${skill}: needs at least 2 primary routing eval cases, found ${count}`);
}

if (errors.length > 0) {
  console.error("Routing eval contract failed:\n");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(`[PASS] routing contract: ${skillNames.length} skills, ${capabilityOwner.size} unique capabilities, ${suite.cases.length} eval cases`);
