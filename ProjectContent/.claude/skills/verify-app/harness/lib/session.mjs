import { attach, remote } from 'webdriverio';
import { APPIUM_PORT, APPS } from './paths.mjs';
import { CliError, log } from './output.mjs';
import { run } from './process.mjs';
import { appPath } from './app.mjs';
import { ensureAppium } from './appium.mjs';
import { bootSimulator, xcodebuildContention } from './simulator.mjs';
import { readState, writeState } from './state.mjs';

const connection = { hostname: '127.0.0.1', port: APPIUM_PORT, logLevel: 'error' };

/**
 * Terminate, then install the bundle just built. With noReset the driver neither reinstalls a changed
 * binary nor applies new launch arguments to a running app; `simctl install` replaces the binary and
 * keeps the app's data container.
 */
export function launchCommands({ udid, bundleId, bundle }) {
  return [
    ['xcrun', ['simctl', 'terminate', udid, bundleId]],
    ['xcrun', ['simctl', 'install', udid, bundle]]
  ];
}

/**
 * Launch arguments for the app under test, passed through as typed: `--args "-resetState -page settings"`.
 * Read them in the app with `ProcessInfo.processInfo.arguments` (or `UserDefaults` for `-key value` pairs).
 */
export function launchArguments(args) {
  return args ? String(args).trim().split(/\s+/).filter(Boolean) : [];
}

export function missingSessionError(state) {
  return new CliError(
    'No live Appium session (never launched, or the simulator/Appium restarted)',
    `run: app-ctl launch --app ${state.sessionApp ?? '<app|catalog>'}`
  );
}

export async function currentDriver() {
  const state = readState();
  if (!state.sessionId) throw missingSessionError(state);
  try {
    const driver = await attach({ ...connection, sessionId: state.sessionId, capabilities: state.sessionCaps });
    await driver.getTimeouts();
    return driver;
  } catch {
    writeState({ sessionId: null });
    throw missingSessionError(state);
  }
}

export async function endSession() {
  const { sessionId } = readState();
  if (!sessionId) return false;
  try { await (await currentDriver()).deleteSession(); } catch { /* already gone */ }
  writeState({ sessionId: null, sessionCaps: null });
  return true;
}

export async function launch({ app, args, fresh = false }) {
  if (!app) throw new CliError('Missing --app', 'run: app-ctl launch --app <app|catalog> [--args "-flag value"]');
  const contention = await xcodebuildContention();
  if (contention.length) throw new CliError(`xcodebuild test is running (pid ${contention.join(', ')})`, 'wait for it to finish, then retry');
  const bundle = appPath(app);
  const { udid, device, runtime } = await bootSimulator();
  await ensureAppium();
  await endSession();
  const [terminate, install] = launchCommands({ udid, bundleId: APPS[app].bundleId, bundle });
  await run(...terminate);
  const installed = await run(...install);
  if (installed.code !== 0) throw new CliError(`Installing ${bundle} failed: ${installed.stderr.slice(-200)}`, `run: app-ctl build --app ${app}`);
  const launchArgs = launchArguments(args);
  log('creating session (the first run builds WebDriverAgent: a few minutes)');
  const driver = await remote({
    ...connection,
    capabilities: {
      platformName: 'iOS',
      'appium:automationName': 'XCUITest',
      'appium:deviceName': device,
      'appium:platformVersion': runtime,
      'appium:udid': udid,
      'appium:app': bundle,
      'appium:noReset': !fresh,
      'appium:fullReset': false,
      'appium:processArguments': { args: launchArgs },
      'appium:newCommandTimeout': 900,
      'appium:wdaLaunchTimeout': 600000,
      'appium:wdaConnectionTimeout': 600000
    }
  });
  writeState({ sessionId: driver.sessionId, sessionCaps: driver.capabilities, sessionApp: app });
  const { mtime } = (await import('node:fs')).statSync(bundle);
  return { sessionId: driver.sessionId, app, arguments: launchArgs, installed: bundle, builtAt: mtime.toISOString() };
}
