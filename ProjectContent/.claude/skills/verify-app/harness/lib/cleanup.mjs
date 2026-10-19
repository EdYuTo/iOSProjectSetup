import { evidenceDir } from './paths.mjs';
import { readState } from './state.mjs';

/** Teardown order: recording, session, Appium. Only things app-ctl recorded. */
export function cleanupPlan(state) {
  const plan = [];
  if (state.recordPid) plan.push({ action: 'stop-recording', pid: state.recordPid });
  if (state.sessionId) plan.push({ action: 'end-session', sessionId: state.sessionId });
  if (state.appiumPid) plan.push({ action: 'stop-appium', pid: state.appiumPid });
  return plan;
}

export async function cleanup({ dryRun = false } = {}) {
  const plan = cleanupPlan(readState());
  const evidence = evidenceDir();
  if (dryRun) return { dryRun: true, wouldRun: plan, evidenceKept: evidence };
  const { recordStop } = await import('./evidence.mjs');
  const { endSession } = await import('./session.mjs');
  const { stopAppium } = await import('./appium.mjs');
  const done = [];
  for (const step of plan) {
    try {
      if (step.action === 'stop-recording') await recordStop();
      if (step.action === 'end-session') await endSession();
      if (step.action === 'stop-appium') await stopAppium();
      done.push({ ...step, ok: true });
    } catch (error) {
      done.push({ ...step, ok: false, error: error.message });
    }
  }
  return { ran: done, evidenceKept: evidence };
}
