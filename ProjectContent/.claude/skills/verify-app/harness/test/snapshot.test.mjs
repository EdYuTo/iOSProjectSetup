import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseSource, toSnapshot, closestIds } from '../lib/snapshot.mjs';

// Trimmed from a real XCUITest driver page source (DesignSystemCatalog, Chips page).
const SOURCE = `<?xml version="1.0" encoding="UTF-8"?>
<AppiumAUT>
  <XCUIElementTypeApplication type="XCUIElementTypeApplication" name="TF Catalog" label="TF Catalog" enabled="true" visible="true" x="0" y="0" width="402" height="874">
    <XCUIElementTypeNavigationBar type="XCUIElementTypeNavigationBar" name="Chips" enabled="true" visible="true" x="0" y="62" width="402" height="54">
      <XCUIElementTypeButton type="XCUIElementTypeButton" name="BackButton" label="TF Catalog" enabled="true" visible="true" x="16" y="62" width="44" height="44"/>
    </XCUIElementTypeNavigationBar>
    <XCUIElementTypeOther type="XCUIElementTypeOther" name="catalogChips.page" enabled="true" visible="true" x="0" y="0" width="402" height="874">
      <XCUIElementTypeButton type="XCUIElementTypeButton" name="catalogChips.cuisines.chip.0" label="All" enabled="true" visible="true" x="16" y="186" width="97" height="33"/>
      <XCUIElementTypeButton type="XCUIElementTypeButton" value="1" name="catalogChips.cuisines.chip.2" label="Japanese &amp; more" enabled="true" visible="true" x="225" y="186" width="97" height="33"/>
      <XCUIElementTypeButton type="XCUIElementTypeButton" name="catalogChips.cuisines.chip.4" label="Greek" enabled="true" visible="false" x="434" y="186" width="98" height="33"/>
    </XCUIElementTypeOther>
  </XCUIElementTypeApplication>
</AppiumAUT>`;

test('parseSource reads every element with unescaped attributes', () => {
  const elements = parseSource(SOURCE);
  assert.equal(elements.length, 7);
  assert.equal(elements.find((e) => e.name === 'catalogChips.cuisines.chip.2').label, 'Japanese & more');
});

test('toSnapshot keeps only convention identifiers by default', () => {
  const snapshot = toSnapshot(parseSource(SOURCE));
  assert.deepEqual(snapshot.map((e) => e.id), [
    'catalogChips.page', 'catalogChips.cuisines.chip.0', 'catalogChips.cuisines.chip.2', 'catalogChips.cuisines.chip.4'
  ]);
  assert.deepEqual(snapshot[2], {
    id: 'catalogChips.cuisines.chip.2', type: 'Button', label: 'Japanese & more', value: '1',
    enabled: true, visible: true, rect: { x: 225, y: 186, width: 97, height: 33 }
  });
  assert.equal(snapshot[3].visible, false);
});

test('toSnapshot --all keeps unidentified elements with a null id', () => {
  const all = toSnapshot(parseSource(SOURCE), { all: true });
  assert.equal(all.length, 7);
  assert.equal(all.find((e) => e.label === 'TF Catalog' && e.type === 'Button').id, null);
});

test('closestIds ranks by edit distance', () => {
  const ids = ['cart.placeOrderButton', 'cart.coupon.input', 'menu.meal.1.stepper.add', 'cart.tip.chip.0'];
  assert.deepEqual(closestIds('cart.placeOrderButon', ids, 2), ['cart.placeOrderButton', 'cart.coupon.input']);
});
