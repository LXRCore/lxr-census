--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-CENSUS — Client: the page
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local LXR = exports['lxr-core']:GetLXR()
local open = false

local function page(action, payload) SendNUIMessage({ action = action, payload = payload, brand = LXRCore.Brand, lang = Config.Lang, locale = Lang.bundle() }) end
local function close() if not open then return end open = false SetNuiFocus(false, false) page('close') end
local function toggle()
    if open then return close() end
    if not LocalPlayer.state.isLoggedIn then return end
    local ok, data = LXR.RPC.Server('lxr-census:open')
    if not ok then return end
    open = true
    SetNuiFocus(true, true)
    page('open', data)
end

RegisterCommand('census', toggle, false)
RegisterKeyMapping('census', 'Town census', 'keyboard', Config.Census.key)
RegisterNUICallback('close', function(_, cb) close() cb({ ok = true }) end)
RegisterNetEvent('lxr:client:unloaded', close)
AddEventHandler('onResourceStop', function(res) if res == GetCurrentResourceName() then close() end end)
exports('IsOpen', function() return open end)
