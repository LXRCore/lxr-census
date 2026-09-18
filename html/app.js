/* LXR-CENSUS — the page | © 2026 iBoss21 / LXRCore */
(function () {
  const $ = (id) => document.getElementById(id);
  const app = $('app');
  const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'lxr-census';
  let L = {};
  const t = (k, vars) => { let s = L[k] || k.split('.').pop().replace(/_/g, ' '); if (vars) for (const v in vars) s = s.replace('%{' + v + '}', vars[v]); return s; };
  const post = (name, body) => fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body || {}) }).catch(() => {});
  function applyLocale() { document.querySelectorAll('[data-l]').forEach(el => { const k = 'ui.' + el.dataset.l; if (L[k]) el.textContent = L[k]; }); }
  const el = (tag, cls, text) => { const e = document.createElement(tag); if (cls) e.className = cls; if (text != null) e.textContent = text; return e; };
  function render(p) {
    $('total').textContent = p.total; $('slots').textContent = t('ui.of_slots', { n: p.slots });
    $('law').textContent = p.law; $('doctors').textContent = p.doctors;
    const g = $('groups'); g.innerHTML = '';
    (p.groups || []).forEach((grp, i) => {
      const row = el('div', 'cs-group');
      const n = el('span', 'cs-group__n', String(grp.count)); if (grp.onduty) { const s = el('small', '', t('ui.on_duty', { n: grp.onduty })); n.appendChild(s); }
      row.append(el('span', 'cs-group__i', String(i + 1).padStart(2, '0')), el('span', 'cs-group__trade', t('trade.' + grp.trade)), n, el('span', 'cs-group__names', (grp.names || []).join(' · ')));
      g.appendChild(row);
    });
    if (!(p.groups || []).length) g.appendChild(el('div', 'cs-group__names', t('ui.empty')));
    const a = $('allows'); a.innerHTML = '';
    (p.allows || []).forEach(x => { const row = el('div', 'cs-allow' + (x.ok ? ' is-ok' : '')); const dot = el('span', 'lxr-dot'); row.append(dot, el('span', '', t('need.' + x.id)), el('span', 'cs-allow__law', t('ui.needs_law', { n: x.law }))); a.appendChild(row); });
  }
  document.addEventListener('keydown', e => { if (e.key === 'Backspace' || e.key === 'Escape') post('close'); });
  window.addEventListener('message', e => {
    const m = e.data || {};
    if (m.brand && m.brand.theme) document.documentElement.dataset.theme = m.brand.theme;
    if (m.locale) { L = m.locale; applyLocale(); }
    if (m.lang) document.body.classList.toggle('lang-ka', m.lang === 'ka');
    if (m.action === 'open') { render(m.payload || {}); app.classList.remove('lxr-hidden'); }
    if (m.action === 'close') app.classList.add('lxr-hidden');
  });
  if (window.__LXR_MOCK__) window.postMessage(window.__LXR_MOCK__, '*');
})();
