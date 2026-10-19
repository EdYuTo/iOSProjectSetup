import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { APPIUM_PORT, harnessDir, stateDir } from './paths.mjs';
import { CliError } from './output.mjs';
import { isPortOpen, portOwnedBy, portOwnerPid, waitFor } from './process.mjs';
import { readState, writeState } from './state.mjs';

export function appiumDecision({ portOpen, ownedPid }) {
  if (portOpen) return ownedPid ? 'reuse' : 'refuse';
  return 'start';
}

export async function ensureAppium() {
  const decision = appiumDecision({ portOpen: await isPortOpen(APPIUM_PORT), ownedPid: await portOwnedBy(APPIUM_PORT, readState().appiumPid) });
  if (decision === 'reuse') return { pid: readState().appiumPid, startedNow: false };
  if (decision === 'refuse') {
    throw new CliError(
      `Port ${APPIUM_PORT} is used by another process (pid ${await portOwnerPid(APPIUM_PORT)}); app-ctl will not kill it`,
      `stop that process yourself, then run: app-ctl launch …`
    );
  }
  fs.mkdirSync(stateDir(), { recursive: true });
  const out = fs.openSync(path.join(stateDir(), 'appium.log'), 'a');
  const child = spawn(path.join(harnessDir, 'node_modules', '.bin', 'appium'), ['--port', String(APPIUM_PORT), '--log-level', 'warn'], {
    cwd: harnessDir, env: { ...process.env, APPIUM_HOME: harnessDir }, detached: true, stdio: ['ignore', out, out]
  });
  child.unref();
  writeState({ appiumPid: child.pid });
  await waitFor(async () => {
    try { return (await fetch(`http://127.0.0.1:${APPIUM_PORT}/status`)).ok; } catch { return false; }
  }, { timeoutMs: 30000, what: 'Appium to start', fix: `read ${path.join(stateDir(), 'appium.log')}` });
  return { pid: child.pid, startedNow: true };
}

export async function stopAppium() {
  const { appiumPid } = readState();
  if (!(await portOwnedBy(APPIUM_PORT, appiumPid))) {
    writeState({ appiumPid: null });
    return false;
  }
  process.kill(-appiumPid, 'SIGTERM');
  await waitFor(async () => !(await isPortOpen(APPIUM_PORT)), { timeoutMs: 10000, what: 'Appium to stop' });
  writeState({ appiumPid: null });
  return true;
}
