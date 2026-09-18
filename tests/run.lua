--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CENSUS — Offline tests: grouping by core job types, privacy, the law count, locale parity
     Usage (from the lxr-census folder):  lua tests/run.lua [--mock out.js en|ka]
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE) os.exit(2) end
local Shim = require('tests.lib.fxshim')
for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/jobs.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil Locale = nil
Shim.load('shared/locale.lua') Shim.load('locales/en.lua') Shim.load('locales/ka.lua') Shim.load('config.lua') Shim.load('shared/rules.lua')
local C = LXRCensus

local passed, failed = 0, 0
local function test(name, fn) local okT, err = xpcall(fn, debug.traceback) if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

local function jobOfType(t) for name, def in pairs(LXRShared.Jobs) do if def.type == t then return name end end end
print('lxr-census offline tests')
test('every configured trade is a core job type with a label; unknown jobs are other', function()
    local types = {}
    for _, def in pairs(LXRShared.Jobs) do types[def.type] = true end
    for _, t in ipairs(Config.Census.trades) do assert(types[t], 'no core job of type ' .. t) assert(Locale.Bundles.en['trade.' .. t], 'label ' .. t) end
    eq(C.Trade('not_a_job'), 'other')
    eq(C.Trade(jobOfType('leo')), 'leo')
    for _, n in ipairs(Config.Needs) do assert(Locale.Bundles.en['need.' .. n.id], n.id) assert(n.law >= 0) end
end)
test('grouping keeps config order, counts duty, names only when asked', function()
    local leo, med = jobOfType('leo'), jobOfType('medical')
    local people = { { id = 3, name = 'B', job = med, onduty = true }, { id = 1, name = 'A', job = leo, onduty = true }, { id = 2, name = 'C', job = leo, onduty = false }, { id = 9, name = 'Z', job = 'ghost', onduty = false } }
    local g = C.Group(people, true, true)
    eq(g[1].trade, 'leo') eq(g[1].count, 2) eq(g[1].onduty, 1) eq(g[1].names[1], 'A #1') eq(g[1].names[2], 'C #2')
    eq(g[2].trade, 'medical') eq(g[#g].trade, 'other')
    local quiet = C.Group(people, false, false)
    eq(#quiet[1].names, 0)
    local noIds = C.Group(people, true, false) eq(noIds[1].names[1], 'A')
end)
test('privacy: all / staff / none', function()
    assert(C.Sees('all', false)) assert(C.Sees('staff', true)) assert(not C.Sees('staff', false)) assert(not C.Sees('none', true))
end)
test('the law count and what it allows', function()
    local leo, fed = jobOfType('leo'), jobOfType('federal')
    local people = { { job = leo, onduty = true }, { job = leo, onduty = false }, { job = fed, onduty = true }, { job = jobOfType('medical'), onduty = true } }
    eq(C.Law(people), 2)
    local a = C.Allows(2)
    for _, x in ipairs(a) do eq(x.ok, x.law <= 2, x.id) end
end)
test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)
print(('%d passed, %d failed'):format(passed, failed))
if arg and arg[1] == '--mock' and arg[2] then
    Config.Lang = arg[3] or 'en'
    local leo, med, trade, ranch, none, outlaw = jobOfType('leo'), jobOfType('medical'), jobOfType('trade'), jobOfType('ranch'), jobOfType('none'), jobOfType('outlaw')
    local people = {
        { id = 1, name = 'Levan Abashidze', job = leo, onduty = true }, { id = 5, name = 'Mira Holloway', job = leo, onduty = true }, { id = 8, name = 'Cole Bennett', job = leo, onduty = false },
        { id = 4, name = 'Nino Kvaratskhelia', job = med, onduty = true }, { id = 11, name = 'Hattie Moore', job = trade, onduty = true }, { id = 12, name = 'Grace Delacroix', job = trade, onduty = false },
        { id = 14, name = 'Silas Crane', job = ranch, onduty = true }, { id = 7, name = 'Tomas Reyes', job = none, onduty = false }, { id = 22, name = 'Ada Nix', job = none, onduty = false }, { id = 30, name = 'Jack Fell', job = outlaw, onduty = false },
    }
    local law = C.Law(people)
    local f = assert(io.open(arg[2], 'w'))
    f:write('window.__LXR_MOCK__ = ' .. json.encode({ action = 'open', payload = { groups = C.Group(people, true, true), total = #people, slots = 64, law = law, doctors = 1, allows = C.Allows(law) }, lang = Config.Lang, locale = Lang.bundle(), brand = { name = 'The Land of Wolves', theme = 'night' } }) .. ';\n')
    f:close()
    print('mock written to ' .. arg[2])
end
os.exit(failed == 0 and 0 or 1)
