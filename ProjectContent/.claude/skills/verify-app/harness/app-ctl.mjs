import { parseArgs } from './lib/args.mjs';
import { CliError, emit, errorEnvelope } from './lib/output.mjs';
import { registerAll } from './lib/commands.mjs';

const COMMANDS = [];

/** Adds a command. `key` is one word ("doctor") or two ("record start"). */
function register(command) {
  COMMANDS.push({ booleanFlags: [], ...command });
}

function help() {
  return {
    ok: true,
    usage: 'app-ctl <command> [args] [--flags]   (every command prints one JSON object)',
    commands: COMMANDS.map(({ usage, summary, example }) => ({ usage, summary, example }))
  };
}

function findCommand(argv) {
  const two = argv.slice(0, 2).join(' ');
  return COMMANDS.find((command) => command.key === two) ?? COMMANDS.find((command) => command.key === argv[0]);
}

async function main(argv) {
  if (argv.length === 0 || argv[0] === '--help') return help();
  const command = findCommand(argv);
  if (!command) throw new CliError(`Unknown command "${argv.slice(0, 2).join(' ')}"`, 'run: app-ctl --help');
  const rest = argv.slice(command.key.split(' ').length);
  if (rest.includes('--help')) {
    const { usage, summary, example, booleanFlags } = command;
    return { ok: true, usage, summary, example, booleanFlags };
  }
  const result = await command.run(parseArgs(rest, command.booleanFlags));
  return { ok: true, ...result };
}

registerAll(register);

try {
  const result = await main(process.argv.slice(2));
  emit(result, result.ok === false ? 1 : 0);
} catch (error) {
  emit(errorEnvelope(error), 1);
}
