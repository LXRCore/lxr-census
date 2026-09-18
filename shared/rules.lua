--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CENSUS — Shared rules: grouping, privacy, what the law count allows
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRCensus = LXRCensus or {}
local C = LXRCensus

---Job type for a job name ('other' when unknown or not listed).
function C.Trade(jobName)
    local def = LXRShared.Jobs and LXRShared.Jobs[jobName]
    local t = def and def.type or 'other'
    for _, k in ipairs(Config.Census.trades) do if k == t then return t end end
    return 'other'
end

---Group a list of { name, job, onduty, id } by trade, in config order (+ 'other' last when used).
function C.Group(people, withNames, withIds)
    local by = {}
    for _, p in ipairs(people) do
        local t = C.Trade(p.job)
        by[t] = by[t] or { trade = t, count = 0, onduty = 0, names = {} }
        by[t].count = by[t].count + 1
        if p.onduty then by[t].onduty = by[t].onduty + 1 end
        if withNames then by[t].names[#by[t].names + 1] = withIds and ('%s #%d'):format(p.name, p.id) or p.name end
    end
    local out = {}
    for _, t in ipairs(Config.Census.trades) do if by[t] then out[#out + 1] = by[t] end end
    if by.other then out[#out + 1] = by.other end
    for _, g in ipairs(out) do table.sort(g.names) end
    return out
end

---Does a viewer with `isStaff` see names / ids under the privacy setting?
function C.Sees(setting, isStaff)
    if setting == 'all' then return true end
    if setting == 'staff' then return isStaff == true end
    return false
end

---Law on duty among the people (leo + federal, on duty).
function C.Law(people)
    local n = 0
    for _, p in ipairs(people) do
        local t = C.Trade(p.job)
        if (t == 'leo' or t == 'federal') and p.onduty then n = n + 1 end
    end
    return n
end

---What the law count allows: { { id, law, ok } }.
function C.Allows(law)
    local out = {}
    for _, n in ipairs(Config.Needs) do out[#out + 1] = { id = n.id, law = n.law, ok = law >= n.law } end
    return out
end
