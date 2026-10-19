import { spawn } from 'node:child_process';
import net from 'node:net';
import { CliError } from './output.mjs';

export function run(command, args = [], options = {}) {
  return new Promise((resolve) => {
    const child = spawn(command, args, { ...options, stdio: ['ignore', 'pipe', 'pipe'] });
    let stdout = '';
    let stderr = '';
    child.stdout.on('data', (chunk) => { stdout += chunk; });
    child.stderr.on('data', (chunk) => { stderr += chunk; });
    child.on('error', (error) => resolve({ code: 127, stdout, stderr: String(error) }));
    child.on('close', (code) => resolve({ code, stdout, stderr }));
  });
}

export function pidAlive(pid) {
  if (!pid) return false;
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

export function isPortOpen(port, host = '127.0.0.1') {
  return new Promise((resolve) => {
    const socket = net.connect({ port, host });
    socket.once('connect', () => { socket.destroy(); resolve(true); });
    socket.once('error', () => resolve(false));
  });
}

export async function portOwnerPid(port) {
  const { stdout } = await run('lsof', ['-ti', `tcp:${port}`, '-sTCP:LISTEN']);
  const pid = Number.parseInt(stdout.trim().split('\n')[0], 10);
  return Number.isNaN(pid) ? null : pid;
}

export async function waitFor(check, { timeoutMs = 30000, intervalMs = 500, what = 'condition', fix } = {}) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await check()) return;
    await new Promise((resolve) => setTimeout(resolve, intervalMs));
  }
  throw new CliError(`Timed out after ${Math.round(timeoutMs / 1000)}s waiting for ${what}`, fix);
}

export async function processGroup(pid) {
  if (!pid) return null;
  const { stdout } = await run('ps', ['-o', 'pgid=', '-p', String(pid)]);
  const group = Number.parseInt(stdout.trim(), 10);
  return Number.isNaN(group) ? null : group;
}

export async function commandOf(pid) {
  if (!pid) return '';
  const { stdout } = await run('ps', ['-o', 'command=', '-p', String(pid)]);
  return stdout.trim();
}

/**
 * A pid from state.json is ours only if it is the process listening on the port, or that
 * process's group leader. A bare "pid is alive" check would trust a recycled pid.
 */
export function ownsPort({ recordedPid, ownerPid, ownerGroup }) {
  if (!recordedPid || !ownerPid) return false;
  return ownerPid === recordedPid || ownerGroup === recordedPid;
}

export async function portOwnedBy(port, recordedPid) {
  const ownerPid = await portOwnerPid(port);
  return ownsPort({ recordedPid, ownerPid, ownerGroup: await processGroup(ownerPid) });
}
