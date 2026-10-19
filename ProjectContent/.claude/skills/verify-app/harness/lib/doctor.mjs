import fs from 'node:fs';
import path from 'node:path';
import { APPIUM_PORT, APPS, harnessDir, productsDir, repoRoot } from './paths.mjs';
import { isPortOpen, portOwnedBy, run } from './process.mjs';
import { device, xcodebuildContention } from './simulator.mjs';
import { readState } from './state.mjs';

export function summarize(checks) {
  const healthy = checks.every((check) => !check.required || check.pass);
  return { ok: healthy, healthy, checks };
}

/** Files that change what the app binary does (code, manifests, plists, assets, strings). */
export function isSourceFile(file) {
  return /\.(swift|plist|strings|xcstrings|json|xcassets\/.*)$/.test(file) && !/\/(Tests|UITests)\//.test(file);
}

/** A build is fresh when no source file changed after it, committed or not. */
export function freshness(builtAtMs, sources) {
  if (!builtAtMs) return { fresh: false, reason: 'not built' };
  const newest = sources.reduce((latest, source) => (source.mtimeMs > latest.mtimeMs ? source : latest), { mtimeMs: 0 });
  return newest.mtimeMs > builtAtMs
    ? { fresh: false, reason: `STALE: ${newest.path} changed after the build` }
    : { fresh: true, reason: 'fresh' };
}

async function iosSources() {
  const { stdout } = await run('git', ['ls-files', '-co', '--exclude-standard'], { cwd: repoRoot });
  return stdout.split('\n').filter((file) => isSourceFile(file) && !file.startsWith('.claude/')).flatMap((file) => {
    try {
      return [{ path: file, mtimeMs: fs.statSync(path.join(repoRoot, file)).mtimeMs }];
    } catch {
      return [];
    }
  });
}

export async function runDoctor() {
  const state = readState();
  const checks = [];

  const xcode = await run('xcodebuild', ['-version']);
  checks.push({
    name: 'xcode', required: true, pass: xcode.code === 0, detail: xcode.stdout.split('\n')[0],
    fix: 'install Xcode 26 and run: sudo xcode-select -s /Applications/Xcode.app'
  });

  const sim = xcode.code === 0 ? await device() : null;
  checks.push({
    name: 'simulator', required: true, pass: sim?.state === 'Booted', detail: sim ?? 'not found',
    fix: 'run: app-ctl simulator boot'
  });

  const driverInstalled = fs.existsSync(path.join(harnessDir, 'node_modules', 'appium-xcuitest-driver'));
  checks.push({
    name: 'harness', required: true, pass: driverInstalled,
    fix: `run: (cd ${path.relative(repoRoot, harnessDir)} && npm ci)`
  });

  const contention = await xcodebuildContention();
  checks.push({
    name: 'contention', required: true, pass: contention.length === 0,
    detail: contention.length ? `xcodebuild test running (pid ${contention.join(', ')})` : 'none',
    fix: 'wait for the xcodebuild test run to finish'
  });

  const appiumUp = await isPortOpen(APPIUM_PORT);
  const appiumOurs = appiumUp && (await portOwnedBy(APPIUM_PORT, state.appiumPid));
  checks.push({
    name: 'appium', required: false, pass: appiumOurs,
    detail: appiumUp ? (appiumOurs ? `pid ${state.appiumPid}` : 'port taken by another process') : 'not running',
    fix: 'run: app-ctl launch --app <app|catalog>'
  });

  checks.push({
    name: 'session', required: false, pass: Boolean(appiumOurs && state.sessionId),
    detail: state.sessionId ? `${state.sessionApp} ${state.sessionId}` : 'none',
    fix: 'run: app-ctl launch --app <app|catalog>'
  });

  const sources = await iosSources();
  for (const [key, app] of Object.entries(APPS)) {
    const bundle = path.join(productsDir, app.product);
    const builtAt = fs.existsSync(bundle) ? fs.statSync(bundle).mtimeMs : 0;
    const { fresh, reason } = freshness(builtAt, sources);
    checks.push({ name: `build:${key}`, required: false, pass: fresh, detail: reason, fix: `run: app-ctl build --app ${key}` });
  }


  return summarize(checks);
}
