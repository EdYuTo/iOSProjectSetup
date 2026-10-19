/** `--name value` becomes a string flag; names in `booleanFlags` (or a trailing flag) become `true`. */
export function parseArgs(argv, booleanFlags = []) {
  const positionals = [];
  const flags = {};
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (!arg.startsWith('--')) {
      positionals.push(arg);
      continue;
    }
    const name = arg.slice(2);
    const next = argv[index + 1];
    if (booleanFlags.includes(name) || next === undefined || next.startsWith('--')) {
      flags[name] = true;
    } else {
      flags[name] = next;
      index += 1;
    }
  }
  return { positionals, flags };
}
