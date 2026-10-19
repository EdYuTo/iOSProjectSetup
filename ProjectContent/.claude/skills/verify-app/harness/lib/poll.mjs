/**
 * Calls `check` until it returns true or the timeout passes. A check that throws counts as "not yet".
 * WebdriverIO 10's waitForExist gives up within milliseconds on XCUITest, so waits poll by hand.
 */
export async function pollUntil(check, { timeoutMs, intervalMs = 250 }) {
  const deadline = Date.now() + timeoutMs;
  for (;;) {
    try {
      if (await check()) return true;
    } catch {
      // Not yet.
    }
    if (Date.now() >= deadline) return false;
    await new Promise((resolve) => setTimeout(resolve, Math.min(intervalMs, Math.max(0, deadline - Date.now()))));
  }
}
