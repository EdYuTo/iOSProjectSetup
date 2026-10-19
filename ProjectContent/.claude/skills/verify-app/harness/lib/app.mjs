import fs from 'node:fs';
import path from 'node:path';
import { APPS, WORKSPACE, deviceName, productsDir, repoRoot } from './paths.mjs';
import { CliError, log } from './output.mjs';
import { run } from './process.mjs';

function appConfig(key) {
  const app = APPS[key];
  if (!app) throw new CliError(`Unknown app "${key}"`, 'use --app app or --app catalog');
  return app;
}

export function appPath(key) {
  const bundle = path.join(productsDir, appConfig(key).product);
  if (!fs.existsSync(bundle)) throw new CliError(`${appConfig(key).product} is not built`, `run: app-ctl build --app ${key}`);
  return bundle;
}

export async function buildApp(key) {
  const app = appConfig(key);
  if (!fs.existsSync(path.join(repoRoot, WORKSPACE))) {
    log('generating the workspace (tuist)');
    await run('mise', ['exec', '--', 'tuist', 'install'], { cwd: repoRoot });
    const generated = await run('mise', ['exec', '--', 'tuist', 'generate', '--no-open'], { cwd: repoRoot });
    if (generated.code !== 0) throw new CliError('tuist generate failed', 'run: mise install && bundle exec fastlane generate_project open:false');
  }
  log(`building ${app.scheme}`);
  const built = await run('xcodebuild', [
    'build', '-workspace', WORKSPACE, '-scheme', app.scheme,
    '-destination', `platform=iOS Simulator,name=${deviceName()}`, '-derivedDataPath', './build_data', '-quiet'
  ], { cwd: repoRoot });
  if (built.code !== 0) {
    const errors = built.stdout.split('\n').concat(built.stderr.split('\n')).filter((line) => line.includes('error:')).slice(0, 5);
    throw new CliError(`Build failed: ${errors.join(' | ') || 'see xcodebuild output'}`, `run: xcodebuild build -workspace ${WORKSPACE} -scheme ${app.scheme} …`);
  }
  return { app: key, path: appPath(key) };
}
