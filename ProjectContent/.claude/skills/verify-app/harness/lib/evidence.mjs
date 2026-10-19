import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { evidenceDir } from './paths.mjs';
import { CliError } from './output.mjs';
import { commandOf, pidAlive, waitFor } from './process.mjs';
import { currentDriver } from './session.mjs';
import { readState, writeState } from './state.mjs';

export function isRecordingCommand(command) {
  return /simctl\b.*\brecordVideo\b/.test(command);
}

async function ourRecording(pid) {
  return pidAlive(pid) && isRecordingCommand(await commandOf(pid));
}

export function safeName(name) {
  return String(name).trim().replace(/[^A-Za-z0-9._-]+/g, '-').replace(/^-+|-+$/g, '');
}

function evidencePath(name, extension) {
  const dir = evidenceDir();
  fs.mkdirSync(dir, { recursive: true });
  const stamp = new Date().toTimeString().slice(0, 8).replace(/:/g, '');
  return path.join(dir, `${stamp}-${safeName(name)}.${extension}`);
}

export async function screenshot(name) {
  if (!name) throw new CliError('Missing name', 'run: app-ctl screenshot <name>');
  const file = evidencePath(name, 'png');
  await (await currentDriver()).saveScreenshot(file);
  return { path: file, bytes: fs.statSync(file).size };
}

export async function recordStart(name) {
  const { udid, recordPid } = readState();
  if (await ourRecording(recordPid)) throw new CliError('A recording is already running', 'run: app-ctl record stop');
  if (!udid) throw new CliError('No simulator recorded', 'run: app-ctl simulator boot');
  const file = evidencePath(name ?? 'recording', 'mp4');
  const child = spawn('xcrun', ['simctl', 'io', udid, 'recordVideo', '--codec=h264', '--force', file], { detached: true, stdio: 'ignore' });
  child.unref();
  writeState({ recordPid: child.pid, recordPath: file });
  return { recording: true, path: file };
}

export async function recordStop() {
  const { recordPid, recordPath } = readState();
  if (!(await ourRecording(recordPid))) {
    writeState({ recordPid: null, recordPath: null });
    throw new CliError('No recording is running', 'run: app-ctl record start <name>');
  }
  process.kill(recordPid, 'SIGINT');
  await waitFor(() => !pidAlive(recordPid), { timeoutMs: 15000, what: 'the recording to finalise' });
  writeState({ recordPid: null, recordPath: null });
  return { path: recordPath, bytes: fs.existsSync(recordPath) ? fs.statSync(recordPath).size : 0 };
}
