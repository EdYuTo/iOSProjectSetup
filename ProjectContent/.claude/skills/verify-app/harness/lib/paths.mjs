import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const harnessDir = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
export const skillDir = path.dirname(harnessDir);
export const repoRoot = path.resolve(skillDir, '..', '..', '..');
export const WORKSPACE = '__PROJECTNAMEIDENTIFIER__.xcworkspace';
export const productsDir = path.join(repoRoot, 'build_data', 'Build', 'Products', 'Debug-iphonesimulator');

export const APPIUM_PORT = 4725;
export const APPS = {
  app: { scheme: '__PROJECTNAMEIDENTIFIER__', product: '__PROJECTNAMEIDENTIFIER__.app', bundleId: '__PROJECTBUNDLEPREFIX__.__PROJECTNAMEIDENTIFIER__' },
  catalog: { scheme: 'DesignSystemCatalog', product: 'DesignSystemCatalog.app', bundleId: '__PROJECTBUNDLEPREFIX__.DesignSystemCatalog' }
};

/** The simulator the tests use: `test_device` in .actions.yml (the same one fastlane test_project picks). */
export function deviceName(actionsYml = readActionsYml()) {
  const match = actionsYml.match(/^test_device:\s*(.+?)\s*$/m);
  return match ? match[1].replace(/^["']|["']$/g, '') : 'iPhone 17';
}

function readActionsYml() {
  try {
    return fs.readFileSync(path.join(repoRoot, '.actions.yml'), 'utf8');
  } catch {
    return '';
  }
}

export function stateDir() {
  return process.env.APP_CTL_STATE_DIR ?? path.join(repoRoot, '.verify', 'state');
}

export function evidenceDir(date = new Date()) {
  const root = process.env.APP_CTL_EVIDENCE_DIR ?? path.join(repoRoot, '.verify', 'evidence');
  return path.join(root, date.toISOString().slice(0, 10));
}
