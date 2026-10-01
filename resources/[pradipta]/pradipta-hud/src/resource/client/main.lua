local Constants   = (BabloHud and BabloHud.Constants) or {}
local NUI_ACTIONS = Constants.NUI_ACTIONS or {}
local KVP         = Constants.KVP        or {}

_G.PradiptaHudActive = false

local settingsCommand = "settings"
if Config and Config.Settings and type(Config.Settings.command) == "string" and Config.Settings.command ~= "" then
    settingsCommand = Config.Settings.command
end

function GetLocaleString(key, fallback)
    if Locale and type(Locale.t) == "function" then
        local result = Locale.t(key)
        if result then return result end
    end
    return fallback
end

function NotifySettingsLocked()
    local msg = GetLocaleString(
        "notifications.settingsLocked",
        "HUD customization is managed by the server. Settings aren't editable on this server."
    )
    exports["pradipta-hud"]:Notify(msg)
end

function AreSettingsLocked()
    if Config and Config.Settings and Config.Settings.enabled == false then
        return true
    end
    if BabloHud and BabloHud.GlobalConfig and BabloHud.GlobalConfig.isGated() then
        return true
    end
    return false
end

RegisterCommand(settingsCommand, function()
    if not _G.PradiptaHudActive then return end

    if AreSettingsLocked() then
        NotifySettingsLocked()
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = NUI_ACTIONS.TOGGLE_SETTINGS or "toggleSettings",
        data   = true,
    })
end, false)

if Config and Config.Settings and Config.Settings.keybind and Config.Settings.keybind.enabled == true then
    local defaultKey = Config.Settings.keybind.defaultKey or "I"
    local label      = GetLocaleString("keymapping.openSettings", "Open HUD Settings Menu")
    RegisterKeyMapping(settingsCommand, label, "keyboard", defaultKey)
end

if Config and Config.GlobalConfig and Config.GlobalConfig.enabled == true and Config.GlobalConfig.allowEdit == true then
    RegisterCommand("edithud", function()
        if not _G.PradiptaHudActive then return end
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "openEditMode", data = true })
    end, false)
end

SetNuiZindex(9999999)

local WEAPON_IMAGE_TEMPLATES = {
    ["pradipta-hud"]       = "nui://pradipta-hud/weapons/{weapon}.png",
    ["pradipta-inventory"] = "nui://pradipta-inventory/html/images/{weapon}.png",
    ox_inventory           = "nui://ox_inventory/web/images/{weapon}.png",
    ["qb-inventory"]       = "nui://qb-inventory/html/images/{weapon}.png",
    ["qs-inventory"]       = "nui://qs-inventory/html/images/{weapon}.png",
    ["ps-inventory"]       = "nui://ps-inventory/html/images/{weapon}.png",
    origen_inventory       = "nui://origen_inventory/html/images/{weapon}.png",
    core_inventory         = "nui://core_inventory/html/images/{weapon}.png",
    ["codem-inventory"]    = "nui://codem-inventory/html/itemimages/{weapon}.png",
    ["tgiann-inventory"]   = "nui://inventory_images/images/{weapon}.png",
}

function ResolveWeaponImageTemplate()
    local inventorySetting = (Config and Config.WeaponImageInventory) or "ox_inventory"
    local template = nil

    if type(inventorySetting) == "string" then
        if inventorySetting:find("{weapon}", 1, true) then
            
            template = inventorySetting
        else
            
            template = WEAPON_IMAGE_TEMPLATES[inventorySetting]
                or ("nui://" .. inventorySetting .. "/html/images/{weapon}.png")
        end
    end

    return template
end

function BuildWeaponImageOverrides()
    local overrides = {}
    if type(Config) == "table" and type(Config.WeaponImages) == "table" then
        for weaponName, url in pairs(Config.WeaponImages) do
            if type(weaponName) == "string" and type(url) == "string" and url ~= "" then
                overrides[string.lower(weaponName)] = url
            end
        end
    end
    return overrides
end

function BuildModuleConfig()
    local playerInfo = nil

    if Config and Config.DefaultSettings and Config.DefaultSettings.playerInfo then
        local src = Config.DefaultSettings.playerInfo

        local timeSource = src.timeSource
        if timeSource ~= "local" and timeSource ~= "server" then
            timeSource = "ingame"
        end

        playerInfo = {
            job   = { enabled = src.showJob   ~= false },
            id    = { enabled = src.showId    ~= false },
            time  = { enabled = src.showTime  ~= false, source = timeSource },
            bank  = { enabled = src.showBank  ~= false },
            cash  = { enabled = src.showCash  ~= false },
            dirty = { enabled = src.showDirtyMoney ~= false },
            gang  = { enabled = src.showGang  ~= false },
            weapon= { enabled = src.showWeapon ~= false },
        }
    end

    return {
        PlayerInfo = playerInfo,
        weaponImageTemplate  = ResolveWeaponImageTemplate(),
        weaponImageOverrides = BuildWeaponImageOverrides(),
    }
end

RegisterNUICallback("requestModuleConfig", function(_, cb)
    cb(BuildModuleConfig())
end)

AddEventHandler("pradipta-hud:playerLoaded", function()
    if _G.PradiptaHudActive then return end
    _G.PradiptaHudActive = true

    Wait(500)

    local dict     = Locale.getDictionary()
    local fallback = Locale.getFallback()
    local code     = Locale.getCode()
    SendNUIMessage({
        action = NUI_ACTIONS.LOAD_LOCALE or "loadLocale",
        data   = {
            code     = code,
            dict     = dict,
            fallback = (dict ~= fallback and fallback) or nil,
        },
    })

    SendNUIMessage({ action = NUI_ACTIONS.SET_HUD_VISIBLE or "setHudVisible", data = true })
    DisplayRadar(true)

    SendNUIMessage({ action = "moduleConfig", data = BuildModuleConfig() })

    if SendMinimapPosition then
        SendMinimapPosition(true)
    end

    TriggerServerEvent("pradipta-hud:requestServerInfo")

    if lib and lib.callback and lib.callback.await then
        CreateThread(function()
            local serverId = lib.callback.await("pradipta-hud:getServerId", false)
            if type(serverId) == "number" and serverId > 0 then
                _G.BabloHudServerId = serverId
            end
        end)
    end

    Info("HUD activated (player loaded)")
end)

RegisterNetEvent("pradipta-hud:receiveServerInfo")
AddEventHandler("pradipta-hud:receiveServerInfo", function(info)
    if type(info) ~= "table" then return end

    local hostname = (info.hostname or "")
        :gsub("%^%d",    "")
        :gsub("[^%w%-_]","_")
        :gsub("_+",      "_")
        :gsub("^_+",     "")
        :gsub("_+$",     "")

    _G.BabloHudHostname = hostname

    if type(info.serverId) == "number" and info.serverId > 0 then
        _G.BabloHudServerId = info.serverId
    end

    TriggerEvent("pradipta-hud:hostnameReady")
    Info("Server hostname for KVP: " .. hostname)
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    _G.PradiptaHudActive = false
    SendNUIMessage({ action = NUI_ACTIONS.SET_HUD_VISIBLE or "setHudVisible", data = false })
    DisplayRadar(false)
    Info("HUD deactivated (player unloaded)")
end)

RegisterCommand("removekvp", function()
    if not IsDebugEnabled() then
        Warn("removekvp is debug-only")
        return
    end
    local key = BabloHud.GetKvpKey(KVP.MINIMAP_POSITION or "bablo_hud_minimap_position")
    DeleteResourceKvp(key)
    Info("Minimap KVP removed (" .. key .. ")")
end, false)

RegisterCommand("hudinfo", function()
    local settingsKey = BabloHud.GetKvpKey(KVP.SETTINGS        or "bablo_hud_settings")
    local minimapKey  = BabloHud.GetKvpKey(KVP.MINIMAP_POSITION or "bablo_hud_minimap_position")

    Info("^3=== bablo-hud KVP Data ===^0")
    Info("^3Hostname: " .. (_G.BabloHudHostname or "(not set)") .. "^0")

    local settingsVal = GetResourceKvpString(settingsKey)
    if settingsVal and settingsVal ~= "" then
        Info("^2[Settings]^0 (" .. settingsKey .. ") " .. settingsVal)
    else
        Info("^1[Settings]^0 (" .. settingsKey .. ") (empty)")
    end

    local minimapVal = GetResourceKvpString(minimapKey)
    if minimapVal and minimapVal ~= "" then
        Info("^2[Minimap Position]^0 (" .. minimapKey .. ") " .. minimapVal)
    else
        Info("^1[Minimap Position]^0 (" .. minimapKey .. ") (empty)")
    end

    local physW, physH   = GetActualScreenResolution()
    local activeW, activeH = GetActiveScreenResolution()
    local physAspect     = (physW and physH and physH > 0) and (physW / physH) or 0
    local aspectTrue     = GetAspectRatio(true)  or 0
    local aspectFalse    = GetAspectRatio(false) or 0
    local screenAspect   = GetScreenAspectRatio and GetScreenAspectRatio() or 0
    local safeZone       = GetSafeZoneSize() or 0

    print(string.format(
        "[pradipta-hud] aspect: physical=%sx%s (%.4f) active=%sx%s GetAspectRatio(true)=%.4f GetAspectRatio(false)=%.4f screen=%.4f safezone=%.3f",
        tostring(physW), tostring(physH), physAspect,
        tostring(activeW), tostring(activeH),
        aspectTrue, aspectFalse, screenAspect, safeZone
    ))

    if Minimap and Minimap.getAnchor then
        local ok, anchor = pcall(function() return Minimap:getAnchor() end)
        if ok and anchor then
            print(string.format(
                "[pradipta-hud] minimap anchor: left=%.1f top=%.1f width=%.1f height=%.1f",
                anchor.leftPx  or 0,
                anchor.topPx   or 0,
                anchor.widthPx or 0,
                anchor.heightPx or 0
            ))
        end
    end

    SendNUIMessage({ action = "dumpPositions", data = true })
    Info("^3(NUI positions returned via callback)^0")
end, false)

RegisterNUICallback("dumpDebug", function(data, cb)
    print("=== bablo-hud NUI DEBUG DUMP ===")
    local ok, encoded = pcall(json.encode, data)
    if ok and encoded then
        for i = 1, #encoded, 900 do
            print(encoded:sub(i, i + 899))
        end
    end
    print("=== END DEBUG DUMP ===")
    cb({ success = true })
end)

RegisterNUICallback("dumpPositions", function(data, cb)
    Info("^3=== NUI Element Positions ===^0")
    if type(data) == "table" then
        for elementName, pos in pairs(data) do
            if type(pos) == "table" then
                local scaleStr = pos.scale and string.format("  scale=%.2f", pos.scale) or ""
                Info(string.format("  ^2%s^0: x=%.1f  y=%.1f%s",
                    elementName, pos.x or 0, pos.y or 0, scaleStr))
            end
        end
    end
    cb({ success = true })
end)

if Config and Config.HideNativeTexts then
    local hide = Config.HideNativeTexts
    local hideVehicleName  = hide.vehicleName  == true
    local hideVehicleClass = hide.vehicleClass == true
    local hideAreaName     = hide.areaName     == true
    local hideStreetName   = hide.streetName   == true

    if hideVehicleName or hideVehicleClass or hideAreaName or hideStreetName then
        CreateThread(function()
            while true do
                
                if hideVehicleName  then HideHudComponentThisFrame(6) end
                if hideAreaName     then HideHudComponentThisFrame(7) end
                if hideVehicleClass then HideHudComponentThisFrame(8) end
                if hideStreetName   then HideHudComponentThisFrame(9) end
                Wait(0)
            end
        end)
    end
end

local lastSafeZoneSize = nil

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(100) end
    Wait(1000)

    while true do
        local size = GetSafeZoneSize()
        if size ~= lastSafeZoneSize then
            lastSafeZoneSize = size
            SendNUIMessage({
                action = NUI_ACTIONS.SAFEZONE_UPDATE or "safeZone:update",
                data   = { size = size },
            })
        end
        Wait(10000)
    end
end)

RegisterCommand("testaudio", function()
    
    local deadline = GetGameTimer() + 5000
    while true do
        if RequestScriptAudioBank("audiodirectory/bablo_custom_sounds", false) then break end
        if GetGameTimer() > deadline then
            Info("[pradipta-hud] RequestScriptAudioBank failed after 5s - bank limit or missing file")
            return
        end
        Wait(100)
    end

    local sounds = { "bomb-ticking", "unbuckle", "buckle" }
    for _, soundName in ipairs(sounds) do
        Info("[pradipta-hud] Playing sound " .. soundName)
        local soundId = GetSoundId()
        PlaySoundFromEntity(soundId, soundName, PlayerPedId(), "bablo_special_soundset", 0, 0)
        while not HasSoundFinished(soundId) do Wait(0) end
        ReleaseSoundId(soundId)
    end
end, false)

