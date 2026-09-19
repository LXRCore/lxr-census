--[[
    ██╗     ██╗  ██╗██████╗        ██████╗███████╗███╗   ██╗███████╗██╗   ██╗███████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██╔════╝██╔════╝████╗  ██║██╔════╝██║   ██║██╔════╝
    ██║      ╚███╔╝ ██████╔╝█████╗██║     █████╗  ██╔██╗ ██║███████╗██║   ██║███████╗
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██╔══╝  ██║╚██╗██║╚════██║██║   ██║╚════██║
    ███████╗██╔╝ ██╗██║  ██║      ╚██████╗███████╗██║ ╚████║███████║╚██████╔╝███████║
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝       ╚═════╝╚══════╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚══════╝

    LXR Core - Census

    Who is in town, by trade. A page that counts the living by the core's
    job types, says how many of the law and the doctors are on duty, and
    tells the outlaws what the town's law count allows tonight. Names are a
    privacy setting; the counts are for everyone.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/GAhk8cgXe9
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (one RPC on open)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE PAGE ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Census = {
    key = 'F9',
    names = 'staff',             -- 'all' | 'staff' | 'none' — whose names appear next to the counts
    staffGroup = 'helper',       -- core permission group that counts as staff for `names`
    showIds = 'staff',           -- server ids next to names: 'all' | 'staff' | 'none'
    -- the trades the page groups by, in this order (core job types); anything else lands in 'other'
    trades = { 'leo', 'federal', 'justice', 'government', 'medical', 'faith', 'press', 'trade', 'service', 'industry', 'ranch', 'transport', 'outlaw', 'civ', 'none' },
}

-- what the law count allows: other resources ask `exports['lxr-census']:Allows(id)`
Config.Needs = {
    { id = 'store',   law = 1 },   -- store robberies
    { id = 'coach',   law = 2 },   -- stagecoach
    { id = 'bank',    law = 4 },   -- bank
    { id = 'train',   law = 5 },   -- train
}

Config.Security = { rateLimit = { windowMs = 3000, burst = 3 } }
Config.Debug = { printBanner = true }
