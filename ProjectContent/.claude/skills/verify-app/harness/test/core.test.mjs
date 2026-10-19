import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { execFileSync, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const harness = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
process.env.APP_CTL_STATE_DIR = mkdtempSync(path.join(tmpdir(), 'tfctl-state-'));

const { parseArgs } = await import('../lib/args.mjs');
const { CliError, errorEnvelope } = await import('../lib/output.mjs');
const { readState, writeState } = await import('../lib/state.mjs');

test('parseArgs separates positionals, valued and boolean flags', () => {
  const parsed = parseArgs(['tap', 'cart.place', '--timeout', '5', '--gone', '--rtl'], ['gone', 'rtl']);
  assert.deepEqual(parsed, { positionals: ['tap', 'cart.place'], flags: { timeout: '5', gone: true, rtl: true } });
});

test('a trailing flag without a value is boolean', () => {
  assert.deepEqual(parseArgs(['launch', '--fresh'], []).flags, { fresh: true });
});

test('errorEnvelope includes the fix when present', () => {
  assert.deepEqual(errorEnvelope(new CliError('No session', 'run: app-ctl launch --app catalog')), {
    ok: false, error: 'No session', fix: 'run: app-ctl launch --app catalog'
  });
  assert.deepEqual(errorEnvelope(new Error('boom')), { ok: false, error: 'boom' });
});

test('writeState merges and null deletes', () => {
  writeState({ sessionId: 'abc', appiumPid: 12 });
  writeState({ sessionId: null, udid: 'U' });
  assert.deepEqual(readState(), { appiumPid: 12, udid: 'U' });
});

test('unknown command prints a JSON error with a help fix and exits 1', () => {
  const result = spawnSync('node', [path.join(harness, 'app-ctl.mjs'), 'nope'], { encoding: 'utf8' });
  assert.equal(result.status, 1);
  const json = JSON.parse(result.stdout);
  assert.equal(json.ok, false);
  assert.match(json.error, /Unknown command "nope"/);
  assert.equal(json.fix, 'run: app-ctl --help');
});

test('--help lists commands as JSON', () => {
  const json = JSON.parse(execFileSync('node', [path.join(harness, 'app-ctl.mjs'), '--help'], { encoding: 'utf8' }));
  assert.equal(json.ok, true);
  assert.ok(json.commands.some((c) => c.usage.startsWith('version')));
  assert.ok(json.commands.some((c) => c.usage.startsWith('doctor')));
});

test('--help lists back for the navigation bar button, which has no identifier', () => {
  const json = JSON.parse(execFileSync('node', [path.join(harness, 'app-ctl.mjs'), '--help'], { encoding: 'utf8' }));
  assert.ok(json.commands.some((c) => c.usage === 'back'), 'back is missing from --help');
});

test('--help lists pull-to-refresh, which a swipe fling does not trigger', () => {
  const json = JSON.parse(execFileSync('node', [path.join(harness, 'app-ctl.mjs'), '--help'], { encoding: 'utf8' }));
  assert.ok(json.commands.some((c) => c.usage === 'pull-to-refresh <id>'), 'pull-to-refresh is missing from --help');
});

test('--help lists dismiss-save-password for prompts that appear outside login', () => {
  const json = JSON.parse(execFileSync('node', [path.join(harness, 'app-ctl.mjs'), '--help'], { encoding: 'utf8' }));
  const command = json.commands.find((c) => c.usage.startsWith('dismiss-save-password'));
  assert.ok(command, 'dismiss-save-password is missing from --help');
  assert.match(command.usage, /--timeout <seconds>/);
});

test('emit delivers large JSON through a pipe before exiting', () => {
  const script = `import('${path.join(harness, 'lib', 'output.mjs')}').then(({ emit }) => emit({ ok: true, big: 'x'.repeat(2000000) }, 0))`;
  const result = spawnSync('node', ['--input-type=module', '-e', script], { encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 });
  assert.equal(result.status, 0);
  assert.equal(JSON.parse(result.stdout).big.length, 2000000);
});

test('writeState is atomic (no temp file left) and a corrupt state file fails loudly', async () => {
  const fs = await import('node:fs');
  const dir = process.env.APP_CTL_STATE_DIR;
  writeState({ appiumPid: 42 });
  assert.deepEqual(fs.readdirSync(dir).filter((name) => name.includes('.tmp')), []);

  fs.writeFileSync(path.join(dir, 'state.json'), '{"appiumPid": 4');
  assert.throws(() => readState(), (error) => /state\.json is corrupt/.test(error.message) && /delete/.test(error.fix));
  fs.rmSync(path.join(dir, 'state.json'));
  assert.deepEqual(readState(), {}, 'a missing file is an empty state');
});
