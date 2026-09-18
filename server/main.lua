--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CENSUS — Server: the count
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local C = LXRCensus
local RES = GetCurrentResourceName()
local buckets = {}

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function nameOf(P) local c = P.PlayerData.charinfo or {} return ((c.firstname or '') .. ' ' .. (c.lastname or '')):gsub('^%s+', '') end
local function people()
    local out = {}
    for src, P in pairs(LXRCore.Players) do out[#out + 1] = { id = tonumber(src) or P.PlayerData.source, name = nameOf(P), job = P.PlayerData.job.name, onduty = P.PlayerData.job.onduty == true } end
    return out
end
local function doctors(list)
    local n = 0
    for _, p in ipairs(list) do if C.Trade(p.job) == 'medical' and p.onduty then n = n + 1 end end
    return n
end

LXR.RPC.Register('lxr-census:open', function(src)
    if limited(src) then return false, 'rate' end
    local list = people()
    local staff = LXRCore.Perms.Has(src, Config.Census.staffGroup)
    local law = C.Law(list)
    return true, {
        groups = C.Group(list, C.Sees(Config.Census.names, staff), C.Sees(Config.Census.showIds, staff)),
        total = #list, slots = GetConvarInt('sv_maxclients', 32), law = law, doctors = doctors(list), allows = C.Allows(law),
    }
end)

AddEventHandler('playerDropped', function() buckets[source] = nil end)
CreateThread(function() if Config.Debug.printBanner then print(('^1[lxr-census]^7 v%s — %d trades, %d needs'):format(GetResourceMetadata(RES, 'version', 0), #Config.Census.trades, #Config.Needs)) end end)
exports('LawOnDuty', function() return C.Law(people()) end)
exports('Allows', function(id) for _, a in ipairs(C.Allows(C.Law(people()))) do if a.id == id then return a.ok, a.law end end return false, 0 end)
exports('Count', function() return #people() end)
