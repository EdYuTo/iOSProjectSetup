/** Registers every command with the router. One block per command. */
export function registerAll(register) {
  register({
    key: 'version',
    usage: 'version',
    summary: 'Harness and pinned dependency versions.',
    example: 'app-ctl version',
    run: async () => {
      const { createRequire } = await import('node:module');
      const require = createRequire(import.meta.url);
      const pkg = require('../package.json');
      return { harness: pkg.name, dependencies: pkg.dependencies };
    }
  });
  register({
    key: 'doctor',
    usage: 'doctor',
    summary: 'Read-only health check: Xcode, simulator, harness, contention, Appium, session, builds. ok=false when a required check fails.',
    example: 'app-ctl doctor',
    run: async () => (await import('./doctor.mjs')).runDoctor()
  });

  register({
    key: 'simulator boot',
    usage: 'simulator boot',
    summary: 'Boot the test_device simulator from .actions.yml (newest iOS runtime) and wait until it is ready.',
    example: 'app-ctl simulator boot',
    run: async () => (await import('./simulator.mjs')).bootSimulator()
  });
  const lazy = (module, fn) => async (...args) => (await import(module))[fn](...args);

  register({ key: 'build', usage: 'build --app <app|catalog>', summary: 'Generate the workspace if needed and build the app for the simulator.',
    example: 'app-ctl build --app catalog', run: async ({ flags }) => lazy('./app.mjs', 'buildApp')(flags.app) });
  register({ key: 'launch', usage: 'launch --app <app|catalog> [--args "<launch arguments>"] [--fresh]', booleanFlags: ['fresh'],
    summary: 'Boot the simulator, start Appium, and open a session on the built app with launch arguments.',
    example: 'app-ctl launch --app app --args "-resetState"',
    run: async ({ flags }) => lazy('./session.mjs', 'launch')({ app: flags.app, args: flags.args, fresh: Boolean(flags.fresh) }) });
  register({ key: 'snapshot', usage: 'snapshot [--all]', booleanFlags: ['all'], summary: 'Accessibility tree as JSON (identified elements only unless --all).',
    example: 'app-ctl snapshot', run: async ({ flags }) => lazy('./ui.mjs', 'snapshot')({ all: Boolean(flags.all) }) });
  register({ key: 'tap', usage: 'tap <id>', summary: 'Tap the element with this accessibility identifier.',
    example: 'app-ctl tap catalogStepper.stepper.add', run: async ({ positionals }) => lazy('./ui.mjs', 'tap')(positionals[0]) });
  register({ key: 'back', usage: 'back', summary: "Tap the navigation bar's back button (it has no identifier).",
    example: 'app-ctl back', run: async () => lazy('./ui.mjs', 'back')() });
  register({ key: 'type', usage: 'type <id> <text>', summary: 'Type text into the element (appends).',
    example: 'app-ctl type settings.email.input ana@example.com', run: async ({ positionals }) => lazy('./ui.mjs', 'type')(positionals[0], positionals.slice(1).join(' ')) });
  register({ key: 'clear', usage: 'clear <id>', summary: 'Clear a text input.',
    example: 'app-ctl clear catalogTextFields.email.input', run: async ({ positionals }) => lazy('./ui.mjs', 'clear')(positionals[0]) });
  register({ key: 'swipe', usage: 'swipe <id> <up|down|left|right>', summary: 'Swipe on an element (e.g. scroll a list or chip row).',
    example: 'app-ctl swipe catalogChips.cuisines left', run: async ({ positionals }) => lazy('./ui.mjs', 'swipe')(positionals[0], positionals[1]) });
  register({ key: 'pull-to-refresh', usage: 'pull-to-refresh <id>', summary: 'Pull a list down to fire its refresh control (swipe is a fling and does not).',
    example: 'app-ctl pull-to-refresh orderList.list', run: async ({ positionals }) => lazy('./ui.mjs', 'pullToRefresh')(positionals[0]) });
  register({ key: 'wait', usage: 'wait <id> [--gone] [--timeout <seconds>]', booleanFlags: ['gone'], summary: 'Wait for an element to appear (or disappear).',
    example: 'app-ctl wait catalogStepper.cartBar --timeout 5', run: async ({ positionals, flags }) => lazy('./ui.mjs', 'wait')(positionals[0], { gone: Boolean(flags.gone), timeout: flags.timeout ?? 10 }) });
  register({ key: 'screenshot', usage: 'screenshot <name>', summary: "PNG into today's evidence folder.",
    example: 'app-ctl screenshot stepper-after-add', run: async ({ positionals }) => lazy('./evidence.mjs', 'screenshot')(positionals[0]) });
  register({ key: 'record start', usage: 'record start <name>', summary: 'Start a simulator video into the evidence folder.',
    example: 'app-ctl record start stepper-flow', run: async ({ positionals }) => lazy('./evidence.mjs', 'recordStart')(positionals[0]) });
  register({ key: 'record stop', usage: 'record stop', summary: 'Stop and finalise the running video.',
    example: 'app-ctl record stop', run: async () => lazy('./evidence.mjs', 'recordStop')() });
  register({ key: 'dismiss-save-password', usage: 'dismiss-save-password [--timeout <seconds>]',
    summary: "Dismiss iOS's Save Password sheet (\"Not Now\") if it shows within the timeout; reports dismissed or absent.",
    example: 'app-ctl dismiss-save-password --timeout 3',
    run: async ({ flags }) => ({ savePasswordPrompt: await lazy('./ui.mjs', 'dismissSavePasswordPrompt')(Number(flags.timeout ?? 5) * 1000) }) });
  register({ key: 'cleanup', usage: 'cleanup [--dry-run]', booleanFlags: ['dry-run'],
    summary: 'Stop recording, end the session and stop Appium, if app-ctl started them. Never deletes evidence.',
    example: 'app-ctl cleanup --dry-run', run: async ({ flags }) => lazy('./cleanup.mjs', 'cleanup')({ dryRun: Boolean(flags['dry-run']) }) });
}
