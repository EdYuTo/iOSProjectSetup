import { test } from 'node:test';
import assert from 'node:assert/strict';
import { appiumDecision } from '../lib/appium.mjs';
import { missingSessionError } from '../lib/session.mjs';
import { safeName } from '../lib/evidence.mjs';
import { cleanupPlan } from '../lib/cleanup.mjs';

test('appium: reuse ours, start when free, refuses a foreign port', () => {
  assert.equal(appiumDecision({ portOpen: true, ownedPid: true }), 'reuse');
  assert.equal(appiumDecision({ portOpen: false, ownedPid: false }), 'start');
  assert.equal(appiumDecision({ portOpen: false, ownedPid: true }), 'start');
  assert.equal(appiumDecision({ portOpen: true, ownedPid: false }), 'refuse');
});

test('missing session gives a launch fix', () => {
  const error = missingSessionError({ sessionApp: 'catalog' });
  assert.match(error.message, /No live Appium session/);
  assert.equal(error.fix, 'run: app-ctl launch --app catalog');
  assert.equal(missingSessionError({}).fix, 'run: app-ctl launch --app <app|catalog>');
});

test('safeName keeps evidence names filesystem-safe', () => {
  assert.equal(safeName('cart / place order!'), 'cart-place-order');
  assert.equal(safeName('stepper.add_1'), 'stepper.add_1');
});

test('cleanupPlan lists only what app-ctl started, in teardown order', () => {
  const plan = cleanupPlan({ recordPid: 5, sessionId: 's', appiumPid: 7, udid: 'U' });
  assert.deepEqual(plan.map((step) => step.action), ['stop-recording', 'end-session', 'stop-appium']);
  assert.deepEqual(cleanupPlan({ udid: 'U' }), []);
});

test('launch reinstalls the freshly built bundle before every session (noReset never reinstalls)', async () => {
  const { launchCommands } = await import('../lib/session.mjs');
  assert.deepEqual(launchCommands({ udid: 'U', bundleId: 'com.x.App', bundle: '/b/App.app' }), [
    ['xcrun', ['simctl', 'terminate', 'U', 'com.x.App']],
    ['xcrun', ['simctl', 'install', 'U', '/b/App.app']]
  ]);
});

test('a recorded pid only counts as ours when it is the port owner (or its group)', async () => {
  const { ownsPort } = await import('../lib/process.mjs');
  assert.equal(ownsPort({ recordedPid: 100, ownerPid: 100, ownerGroup: 100 }), true);
  assert.equal(ownsPort({ recordedPid: 100, ownerPid: 230, ownerGroup: 100 }), true, 'backend: node grandchild in our group');
  assert.equal(ownsPort({ recordedPid: 100, ownerPid: 555, ownerGroup: 555 }), false, 'recycled pid: port held by a stranger');
  assert.equal(ownsPort({ recordedPid: undefined, ownerPid: 555, ownerGroup: 555 }), false);
  assert.equal(ownsPort({ recordedPid: 100, ownerPid: null, ownerGroup: null }), false, 'nothing listening');
});

test('a recording pid only counts when its command is simctl recordVideo', async () => {
  const { isRecordingCommand } = await import('../lib/evidence.mjs');
  assert.equal(isRecordingCommand('xcrun simctl io 4E45 recordVideo --codec=h264 --force /x.mp4'), true);
  assert.equal(isRecordingCommand('/usr/bin/some-other-tool --serve'), false);
  assert.equal(isRecordingCommand(''), false);
});

test('launchArguments passes --args through, split on whitespace', async () => {
  const { launchArguments } = await import('../lib/session.mjs');
  assert.deepEqual(launchArguments('-resetState -page  settings'), ['-resetState', '-page', 'settings']);
  assert.deepEqual(launchArguments(undefined), []);
  assert.deepEqual(launchArguments('   '), []);
});
