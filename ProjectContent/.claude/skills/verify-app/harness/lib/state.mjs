import fs from 'node:fs';
import path from 'node:path';
import { stateDir } from './paths.mjs';
import { CliError } from './output.mjs';

const stateFile = () => path.join(stateDir(), 'state.json');

/** A missing file is an empty state; a corrupt one fails loudly so owned PIDs are never silently forgotten. */
export function readState() {
  let text;
  try {
    text = fs.readFileSync(stateFile(), 'utf8');
  } catch {
    return {};
  }
  try {
    return JSON.parse(text);
  } catch {
    throw new CliError(
      `${stateFile()} state.json is corrupt; processes it tracked (Appium, recording) may still be running`,
      `check port 4725 with lsof, stop what app-ctl started, then delete ${stateFile()}`
    );
  }
}

/** Merges `patch` into the state atomically (write a temp file, then rename); `null`/`undefined` remove keys. */
export function writeState(patch) {
  fs.mkdirSync(stateDir(), { recursive: true });
  const next = { ...readState(), ...patch };
  for (const [key, value] of Object.entries(next)) {
    if (value === null || value === undefined) delete next[key];
  }
  const temp = `${stateFile()}.${process.pid}.tmp`;
  fs.writeFileSync(temp, JSON.stringify(next, null, 2));
  fs.renameSync(temp, stateFile());
  return next;
}
