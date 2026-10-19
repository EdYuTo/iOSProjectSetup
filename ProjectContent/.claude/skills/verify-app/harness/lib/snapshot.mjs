/** Accessibility identifier convention (spec §11.4). XCUITest exposes it as the `name` attribute. */
export const IDENTIFIER = /^[a-z][A-Za-z0-9]*(\.[A-Za-z0-9-]+)+$/;

const ENTITIES = { '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&apos;': "'" };
const unescape = (value) => value.replace(/&(amp|lt|gt|quot|apos);/g, (entity) => ENTITIES[entity]);

/** Flat list of elements from an XCUITest driver page source. */
export function parseSource(xml) {
  const elements = [];
  for (const match of xml.matchAll(/<XCUIElementType(\w+)\s([^>]*?)\/?>/g)) {
    const attributes = { type: match[1] };
    for (const [, key, value] of match[2].matchAll(/(\w+)="([^"]*)"/g)) {
      if (key !== 'type') attributes[key] = unescape(value);
    }
    elements.push(attributes);
  }
  return elements;
}

export function toSnapshot(elements, { all = false } = {}) {
  return elements
    .filter((element) => all || IDENTIFIER.test(element.name ?? ''))
    .map((element) => ({
      id: IDENTIFIER.test(element.name ?? '') ? element.name : null,
      type: element.type,
      label: element.label ?? null,
      value: element.value ?? null,
      enabled: element.enabled === 'true',
      visible: element.visible === 'true',
      rect: { x: Number(element.x), y: Number(element.y), width: Number(element.width), height: Number(element.height) }
    }));
}

function editDistance(a, b) {
  const previous = Array.from({ length: b.length + 1 }, (_, index) => index);
  for (let i = 1; i <= a.length; i += 1) {
    let diagonal = previous[0];
    previous[0] = i;
    for (let j = 1; j <= b.length; j += 1) {
      const above = previous[j];
      previous[j] = Math.min(previous[j] + 1, previous[j - 1] + 1, diagonal + (a[i - 1] === b[j - 1] ? 0 : 1));
      diagonal = above;
    }
  }
  return previous[b.length];
}

export function closestIds(target, ids, limit = 5) {
  return [...new Set(ids)]
    .map((id) => ({ id, distance: editDistance(target, id) }))
    .sort((a, b) => a.distance - b.distance || a.id.localeCompare(b.id))
    .slice(0, limit)
    .map(({ id }) => id);
}
