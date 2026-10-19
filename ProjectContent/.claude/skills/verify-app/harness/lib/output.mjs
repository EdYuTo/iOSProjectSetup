/** An expected failure: `fix` is the concrete next command for the agent. */
export class CliError extends Error {
  constructor(message, fix) {
    super(message);
    this.fix = fix;
  }
}

export function errorEnvelope(error) {
  return { ok: false, error: error.message, ...(error.fix ? { fix: error.fix } : {}) };
}

export function log(...parts) {
  process.stderr.write(`app-ctl: ${parts.join(' ')}\n`);
}

/** Prints one JSON object and exits only after stdout has flushed (pipes are async on macOS). */
export function emit(json, code) {
  process.stdout.write(`${JSON.stringify(json, null, 2)}\n`, () => process.exit(code));
}
