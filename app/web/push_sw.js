// The web app's push worker. The app registers it (see _WebPush in
// lib/core/push_web.dart) with the server it subscribed to and the app's
// language in the query: push_sw.js?server=…&lang=…. It runs while no tab
// is open, so it words the notifications itself, from push_strings.json,
// which tool/push_strings.dart writes from the app's ARB files.
'use strict';

const params = new URL(self.location.href).searchParams;
const server = params.get('server');
const lang = params.get('lang');
// The worker's scope is push/ inside the app, so the app is one level up.
const app = new URL('../', self.registration.scope);

let strings;

function loadStrings() {
  strings ??= fetch(new URL('push_strings.json', self.location.href))
    .then((r) => (r.ok ? r.json() : Promise.reject(new Error(r.statusText))))
    .catch((e) => {
      strings = undefined;
      throw e;
    });
  return strings;
}

// The language to word notifications in: the app's, else the browser's,
// else English. "zh-TW" is written in traditional characters.
function language(all) {
  const tags = [lang, ...(self.navigator.languages || [self.navigator.language])].filter(Boolean);
  for (const tag of tags) {
    const parts = tag.split('-');
    const base = parts[0].toLowerCase();
    const rest = parts.slice(1).map((p) => p.toLowerCase());
    if (base === 'zh' && (rest.includes('hant') || ['tw', 'hk', 'mo'].some((r) => rest.includes(r)))) {
      if (all['zh-Hant']) return 'zh-Hant';
    }
    if (all[base]) return base;
  }
  return 'en';
}

// Fills {0}, {1}, … with args, or null when the message takes a different
// number of them: from a newer server, say nothing rather than something
// wrong.
function fill(text, args) {
  const wanted = new Set([...text.matchAll(/\{(\d+)\}/g)].map((m) => Number(m[1])));
  if (wanted.size !== args.length) return null;
  return text.replace(/\{(\d+)\}/g, (_, i) => String(args[i]));
}

async function show(m) {
  if (!m || typeof m.g !== 'string' || typeof m.t !== 'string' || typeof m.k !== 'string' || !Array.isArray(m.a)) {
    return;
  }
  let body = null;
  try {
    const all = await loadStrings();
    const text = all[language(all)]?.[m.k] ?? all.en?.[m.k];
    if (text) body = fill(text, m.a.filter((a) => typeof a === 'string'));
  } catch (e) {
    console.warn('push strings:', e);
  }
  // Browsers want a notification for every push, so one the worker cannot
  // word still shows its group's name.
  await self.registration.showNotification(m.t, {
    body: body ?? undefined,
    // One notification per expense: a change replaces the last one.
    tag: typeof m.e === 'string' && m.e ? m.e : undefined,
    icon: new URL('icons/Icon-192.png', app).href,
    data: { server, token: m.g },
  });
}

// A new server or language takes over at once.
self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('push', (event) => {
  let message;
  try {
    message = event.data?.json();
  } catch (e) {
    return;
  }
  event.waitUntil(show(message));
});

// Opens the group in a tab of the app that is open already, or a new one.
// The app opens it only if it still talks to the server it came from.
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const { server: from, token } = event.notification.data || {};
  if (!from || !token) return;
  event.waitUntil(
    (async () => {
      const tabs = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
      const tab = tabs.find((t) => t.url.startsWith(app.href));
      if (tab) {
        tab.postMessage({ balnanaOpen: { server: from, token } });
        await tab.focus();
        return;
      }
      const url = new URL('open', app);
      url.searchParams.set('server', from);
      url.searchParams.set('token', token);
      await self.clients.openWindow(url.href);
    })(),
  );
});
