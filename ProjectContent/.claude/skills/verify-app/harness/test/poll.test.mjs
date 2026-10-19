import { test } from 'node:test';
import assert from 'node:assert/strict';
import { pollUntil } from '../lib/poll.mjs';

test('pollUntil keeps checking until the condition holds', async () => {
  let calls = 0;
  const met = await pollUntil(async () => ++calls >= 3, { timeoutMs: 1000, intervalMs: 10 });
  assert.equal(met, true);
  assert.equal(calls, 3);
});

test('pollUntil waits the whole timeout before giving up', async () => {
  const started = Date.now();
  const met = await pollUntil(async () => false, { timeoutMs: 300, intervalMs: 20 });
  assert.equal(met, false);
  assert.ok(Date.now() - started >= 300, `gave up after ${Date.now() - started} ms`);
});

test('pollUntil treats a failing check as not yet', async () => {
  let calls = 0;
  const met = await pollUntil(async () => { calls += 1; if (calls < 2) throw new Error('stale'); return true; }, { timeoutMs: 500, intervalMs: 10 });
  assert.equal(met, true);
});
