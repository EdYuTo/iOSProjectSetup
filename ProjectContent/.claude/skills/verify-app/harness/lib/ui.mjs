import { CliError } from './output.mjs';
import { closestIds, parseSource, toSnapshot } from './snapshot.mjs';
import { pollUntil } from './poll.mjs';
import { currentDriver } from './session.mjs';

export async function snapshot({ all = false } = {}) {
  const driver = await currentDriver();
  const elements = toSnapshot(parseSource(await driver.getPageSource()), { all });
  return { count: elements.length, elements };
}

async function element(driver, id) {
  // UIAlertController lists each action twice in the tree; WebdriverIO's strict selectors would refuse that.
  const found = await driver.$(`~${id}`, { strict: false });
  if (await found.isExisting()) return found;
  const ids = toSnapshot(parseSource(await driver.getPageSource())).map((item) => item.id);
  throw new CliError(`No element with identifier "${id}". Closest: ${closestIds(id, ids).join(', ') || 'none'}`, 'run: app-ctl snapshot');
}

export async function tap(id) {
  const driver = await currentDriver();
  await (await element(driver, id)).click();
  return { tapped: id };
}

/** Taps the navigation bar's back button. UIKit names it "BackButton" (label "Back") rather than giving it an identifier. */
export async function back() {
  const driver = await currentDriver();
  const button = await driver.$('-ios predicate string:type == "XCUIElementTypeButton" AND (name == "BackButton" OR label == "Back")', { strict: false });
  if (!(await button.isExisting())) throw new CliError('No back button on this screen', 'run: app-ctl snapshot --all');
  await button.click();
  return { tapped: 'Back' };
}

export async function type(id, text) {
  const driver = await currentDriver();
  await (await element(driver, id)).addValue(text);
  return { typed: id, text };
}

export async function clear(id) {
  const driver = await currentDriver();
  await (await element(driver, id)).clearValue();
  return { cleared: id };
}

export async function swipe(id, direction) {
  if (!['up', 'down', 'left', 'right'].includes(direction)) throw new CliError(`Bad direction "${direction}"`, 'use up, down, left or right');
  const driver = await currentDriver();
  const target = await element(driver, id);
  await driver.execute('mobile: swipe', { direction, elementId: target.elementId });
  return { swiped: id, direction };
}

/** Drags down from near the top of a list, slowly enough for its refresh control to fire. */
export async function pullToRefresh(id) {
  const driver = await currentDriver();
  const target = await element(driver, id);
  const { x, y, width, height } = await driver.getElementRect(target.elementId);
  const fromX = x + width / 2;
  const fromY = y + Math.min(80, height / 4);
  await driver.execute('mobile: dragFromToForDuration', {
    fromX, fromY, toX: fromX, toY: fromY + Math.min(400, height / 2), duration: 0.6,
  });
  return { pulled: id };
}

export async function wait(id, { gone = false, timeout = 10 } = {}) {
  const driver = await currentDriver();
  const met = await pollUntil(async () => {
    const exists = await (await driver.$(`~${id}`, { strict: false })).isExisting();
    return gone ? !exists : exists;
  }, { timeoutMs: Number(timeout) * 1000 });
  if (!met) throw new CliError(`"${id}" did not ${gone ? 'disappear' : 'appear'} within ${timeout}s`, 'run: app-ctl snapshot');
  return { id, state: gone ? 'gone' : 'present' };
}

/**
 * iOS offers to save the credentials when a sign-in screen with typed credentials goes away.
 * The prompt is system UI that swallows the next tap, so dismiss it ("Not Now").
 */
export async function dismissSavePasswordPrompt(timeoutMs = 5000) {
  const driver = await currentDriver();
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    try {
      const buttons = await driver.execute('mobile: alert', { action: 'getButtons' });
      if (buttons.includes('Not Now')) {
        await driver.execute('mobile: alert', { action: 'dismiss', buttonLabel: 'Not Now' });
        return 'dismissed';
      }
    } catch {
      // No alert yet.
    }
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  return 'absent';
}
