import { test } from 'node:test';
import assert from 'node:assert/strict';
import { findDevice, contendingXcodebuild } from '../lib/simulator.mjs';
import { deviceName } from '../lib/paths.mjs';
import { summarize } from '../lib/doctor.mjs';

const SIMCTL = {
  devices: {
    'com.apple.CoreSimulator.SimRuntime.iOS-18-5': [{ name: 'iPhone 17', udid: 'OLD', state: 'Shutdown', isAvailable: true }],
    'com.apple.CoreSimulator.SimRuntime.iOS-26-4': [
      { name: 'iPhone 17 Pro', udid: 'PRO', state: 'Shutdown', isAvailable: true },
      { name: 'iPhone 17', udid: 'F950', state: 'Booted', isAvailable: true }
    ]
  }
};

test('findDevice picks the exact name on the newest iOS runtime that has it', () => {
  assert.deepEqual(findDevice(SIMCTL, 'iPhone 17'), { udid: 'F950', state: 'Booted', name: 'iPhone 17', runtime: '26.4' });
  assert.deepEqual(findDevice(SIMCTL, 'iPhone 17 Pro'), { udid: 'PRO', state: 'Shutdown', name: 'iPhone 17 Pro', runtime: '26.4' });
  assert.equal(findDevice(SIMCTL, 'iPhone 99'), null);
  assert.equal(findDevice({ devices: {} }, 'iPhone 17'), null);
});

test('deviceName reads test_device from .actions.yml, like fastlane test_project', () => {
  assert.equal(deviceName('run_tests: true\n# comment\ntest_device: iPhone 17 Pro\n'), 'iPhone 17 Pro');
  assert.equal(deviceName('test_device: "iPhone 16"\n'), 'iPhone 16');
  assert.equal(deviceName(''), 'iPhone 17', 'falls back to the template default');
});

test('contendingXcodebuild flags test runs but not WebDriverAgent', () => {
  const ps = [
    '  101 /Applications/Xcode.app/usr/bin/xcodebuild test -workspace App.xcworkspace -scheme App',
    '  102 /Applications/Xcode.app/usr/bin/xcodebuild build-for-testing test-without-building -project WebDriverAgent.xcodeproj',
    '  103 /Applications/Xcode.app/usr/bin/xcodebuild build -scheme DesignSystemCatalog'
  ].join('\n');
  assert.deepEqual(contendingXcodebuild(ps), ['101']);
});

test('summarize is healthy only when every required check passes', () => {
  const checks = [
    { name: 'xcode', required: true, pass: true },
    { name: 'session', required: false, pass: false, fix: 'run: app-ctl launch --app catalog' }
  ];
  assert.deepEqual(summarize(checks), { ok: true, healthy: true, checks });
  const failing = [...checks, { name: 'simulator', required: true, pass: false, fix: 'run: app-ctl simulator boot' }];
  assert.equal(summarize(failing).ok, false);
  assert.equal(summarize(failing).healthy, false);
});

test('freshness compares the bundle with the newest source file, not commits', async () => {
  const { freshness, isSourceFile } = await import('../lib/doctor.mjs');
  assert.deepEqual(freshness(0, [{ path: 'a.swift', mtimeMs: 5 }]), { fresh: false, reason: 'not built' });
  assert.deepEqual(freshness(10, [{ path: 'a.swift', mtimeMs: 5 }, { path: 'b.swift', mtimeMs: 9 }]), { fresh: true, reason: 'fresh' });
  assert.deepEqual(freshness(10, [{ path: 'a.swift', mtimeMs: 5 }, { path: 'Edited.swift', mtimeMs: 12 }]), {
    fresh: false, reason: 'STALE: Edited.swift changed after the build'
  });
  assert.equal(isSourceFile('App/ContentView.swift'), true);
  assert.equal(isSourceFile('Modules/DesignSystem/Project.swift'), true);
  assert.equal(isSourceFile('README.md'), false, 'docs-only changes do not invalidate builds');
  assert.equal(isSourceFile('Modules/DesignSystem/Tests/Snapshots/x.png'), false);
});
