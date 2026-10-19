import { deviceName } from './paths.mjs';
import { CliError, log } from './output.mjs';
import { run } from './process.mjs';
import { writeState } from './state.mjs';

/** "com.apple.CoreSimulator.SimRuntime.iOS-26-4" -> [26, 4]; null for other platforms. */
export function iosVersion(runtimeKey) {
  const match = runtimeKey.match(/SimRuntime\.iOS-(\d+)-(\d+)/);
  return match ? [Number(match[1]), Number(match[2])] : null;
}

/** The named device on the newest installed iOS runtime that has it. */
export function findDevice(simctlJson, name = deviceName()) {
  const candidates = Object.entries(simctlJson.devices ?? {})
    .map(([key, devices]) => ({ version: iosVersion(key), devices }))
    .filter(({ version }) => version)
    .sort((a, b) => b.version[0] - a.version[0] || b.version[1] - a.version[1]);
  for (const { version, devices } of candidates) {
    const match = devices.find((device) => device.name === name && device.isAvailable !== false);
    if (match) return { udid: match.udid, state: match.state, name, runtime: version.join('.') };
  }
  return null;
}

export async function device() {
  const { code, stdout } = await run('xcrun', ['simctl', 'list', 'devices', 'available', '-j']);
  if (code !== 0) throw new CliError('xcrun simctl failed', 'install Xcode 26 and run: xcode-select -p');
  return findDevice(JSON.parse(stdout));
}

export async function bootSimulator() {
  const found = await device();
  if (!found) {
    throw new CliError(
      `No "${deviceName()}" simulator on any installed iOS runtime`,
      'create it in Xcode › Window › Devices and Simulators, or change test_device in .actions.yml'
    );
  }
  if (found.state !== 'Booted') {
    log(`booting ${found.name} (${found.udid})`);
    await run('xcrun', ['simctl', 'boot', found.udid]);
  }
  await run('xcrun', ['simctl', 'bootstatus', found.udid, '-b']);
  writeState({ udid: found.udid, runtime: found.runtime });
  return { udid: found.udid, device: found.name, runtime: found.runtime, wasBooted: found.state === 'Booted' };
}

/** PIDs of `xcodebuild test` runs that would fight Appium for the simulator. */
export function contendingXcodebuild(psOutput) {
  return psOutput
    .split('\n')
    .map((line) => line.trim())
    .filter((line) => /xcodebuild/.test(line) && /\btest\b/.test(line) && !/WebDriverAgent/.test(line))
    .map((line) => line.split(/\s+/)[0]);
}

export async function xcodebuildContention() {
  const { stdout } = await run('ps', ['-axo', 'pid,command']);
  return contendingXcodebuild(stdout);
}
