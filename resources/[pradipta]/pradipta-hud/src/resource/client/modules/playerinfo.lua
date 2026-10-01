local NUI_ACTIONS      = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}
local ACTION_UPDATE    = NUI_ACTIONS.UPDATE_PLAYER_INFO or "updatePlayerInfo"

local running         = false       
local lastSnapshot    = nil         
local weaponCardVisible = false     
local hasWeaponEquipped = cache and cache.weapon and true or false

local hideWeaponHudTickerId = nil

local weaponLabelCache = nil

local WEAPON_HASH_TO_NAME = {}

local KNOWN_WEAPON_NAMES = {
    
    "weapon_pistol", "weapon_pistolmkii", "weapon_combatpistol", "weapon_appistol",
    "weapon_stungun", "weapon_pistol50", "weapon_snspistol", "weapon_snspistolmkii",
    "weapon_heavypistol", "weapon_vintagepistol", "weapon_flaregun", "weapon_marksmanpistol",
    "weapon_revolver", "weapon_revolvermkii", "weapon_doubleaction", "weapon_raypistol",
    "weapon_ceramicpistol", "weapon_navyrevolver", "weapon_gadgetpistol", "weapon_pistolxm3",
    
    "weapon_microsmg", "weapon_smg", "weapon_smgmkii", "weapon_assaultsmg",
    "weapon_combatpdw", "weapon_machinepistol", "weapon_minismg", "weapon_tacticalsmg",
    
    "weapon_pumpshotgun", "weapon_pumpshotgunmkii", "weapon_sawnoffshotgun",
    "weapon_assaultshotgun", "weapon_bullpupshotgun", "weapon_heavyshotgun",
    "weapon_doublebarrelshotgun", "weapon_sweeper", "weapon_combatshotgun",
    
    "weapon_assaultrifle", "weapon_assaultriflemkii", "weapon_carbinerifle",
    "weapon_carbineriflemkii", "weapon_advancedrifle", "weapon_specialcarbine",
    "weapon_specialcarbinemkii", "weapon_bullpuprifle", "weapon_bullpupriflomkii",
    "weapon_compactrifle", "weapon_militaryrifle", "weapon_heavyrifle", "weapon_tacticalrifle",
    
    "weapon_mg", "weapon_combatmg", "weapon_combatmgmkii", "weapon_gusenberg",
    
    "weapon_sniperrifle", "weapon_heavysniper", "weapon_heavysnipermkii",
    "weapon_marksmanrifle", "weapon_marksmanriflomkii", "weapon_precisionrifle",
    
    "weapon_musket", "weapon_rpg", "weapon_grenadelauncher", "weapon_smokelauncher",
    "weapon_minigun", "weapon_firework", "weapon_railgun", "weapon_hominglauncher",
    "weapon_compactlauncher", "weapon_widowmaker", "weapon_emplauncher",
    
    "weapon_knife", "weapon_bat", "weapon_hammer", "weapon_crowbar", "weapon_machete",
    "weapon_switchblade", "weapon_nightstick", "weapon_hatchet", "weapon_wrench",
    "weapon_poolcue", "weapon_battleaxe", "weapon_stone_hatchet",
}

for _, name in ipairs(KNOWN_WEAPON_NAMES) do
    local hash = GetHashKey(name)
    if hash and hash ~= 0 then
        WEAPON_HASH_TO_NAME[hash] = name
    end
end

function GetWeaponInternalName(weaponHash)
    if not weaponHash or weaponHash == 0 then return "" end
    return WEAPON_HASH_TO_NAME[weaponHash] or ""
end

function HashToHex(hash)
    if not hash then return nil end
    if hash < 0 then hash = hash + 4294967296 end
    return string.format("0x%08X", hash)
end

function GetWeaponLabelMap()
    if weaponLabelCache then return weaponLabelCache end

    local labels = {}

    if Framework and Framework.getCore then
        local core = Framework:getCore()
        if core and core.Shared and core.Shared.Weapons then
            for weaponName, weaponData in pairs(core.Shared.Weapons) do
                if type(weaponName) == "string" then
                    local hash = GetHashKey(string.upper(weaponName))
                    if hash and hash ~= 0 then
                        local label = (type(weaponData) == "table" and weaponData.label)
                            or labels[hash]
                            or weaponName
                        labels[hash] = label
                    end
                end
            end
        end
    end

    weaponLabelCache = labels
    return labels
end

local UNARMED_HASH = GetHashKey("WEAPON_UNARMED")

function GetWeaponDisplayName(weaponHash)
    
    if not weaponHash or weaponHash == 0 or weaponHash == UNARMED_HASH then
        return Locale.t("framework.fallbacks.unarmed")
    end

    local labels = GetWeaponLabelMap()
    local label  = labels[weaponHash]
    if label and label ~= "" then return label end

    local hex = HashToHex(weaponHash)
    if hex then
        local localeKey    = "weapons." .. hex
        local localeResult = Locale.t(localeKey)
        if localeResult ~= localeKey then return localeResult end
    end

    if type(GetWeaponDisplayNameFromHash) == "function" then
        local ok, displayKey = pcall(GetWeaponDisplayNameFromHash, weaponHash)
        if ok and displayKey and displayKey ~= "NULL" then
            local text = GetLabelText(displayKey)
            if text and text ~= "NULL" then return text end
            return displayKey
        end
    end

    return Locale.t("framework.fallbacks.weaponName")
end

function GetVoiceProximity()
    local proximity = LocalPlayer and LocalPlayer.state and LocalPlayer.state.proximity
    if proximity then
        local index = tonumber(proximity.index) or tonumber(proximity.mode)
        if index then
            return math.max(1, math.floor(index + 1)), 5
        end
    end
    return 3, 5
end

function GetRadioFrequency()
    local channel = LocalPlayer and LocalPlayer.state and LocalPlayer.state.radioChannel
    local n = channel and tonumber(channel)
    if n and n > 0 then return string.format("%.1f", n) end
    return "0.0"
end

function GetAmmoData(ped, weaponHash)
    local _, clipAmmo   = GetAmmoInClip(ped, weaponHash)
    local totalAmmo     = GetAmmoInPedWeapon(ped, weaponHash)
    clipAmmo  = clipAmmo  or 0
    totalAmmo = totalAmmo or 0
    return clipAmmo, math.max(0, totalAmmo - clipAmmo)
end

function GetServerPlayerId()
    local id = nil
    if Framework and Framework.getPlayerId then
        id = Framework:getPlayerId()
    end
    if not id then
        id = GetPlayerServerId(PlayerId())
    end
    if type(id) ~= "number" or id <= 0 then return nil end
    return id
end

function CollectPlayerInfo()
    local ped = cache and cache.ped
    if not ped or not DoesEntityExist(ped) then return nil end

    local playerId   = PlayerId()
    local playerName = GetPlayerName(playerId) or "Player"
    local jobName    = "Unemployed"
    local jobGrade   = "Worker"
    local wallet     = 0
    local bank       = 0
    local dirtyMoney = nil
    local gangName   = nil
    local gangGrade  = nil

    if Framework then
        if Framework.getPlayerName then playerName = Framework:getPlayerName() end

        if Framework.getJob then
            jobName, jobGrade = Framework:getJob()
        end

        if Framework.getMoney then
            wallet, bank = Framework:getMoney()
        end

        if Framework.getDirtyMoney then
            local ok, dirty = pcall(function() return Framework:getDirtyMoney() end)
            if ok and type(dirty) == "number" and dirty > 0 then
                dirtyMoney = dirty
            end
        end

        if Framework.getGang then
            local ok, gang = pcall(function() return Framework:getGang() end)
            if ok and type(gang) == "table" then
                gangName  = gang.label or gang.name
                gangGrade = gang.grade
            end
        end
    end

    local currentWeapon = GetSelectedPedWeapon(ped)
    local hasWeapon     = currentWeapon and currentWeapon ~= 0 and currentWeapon ~= UNARMED_HASH

    local ammoClip, ammoTotal = 0, 0
    if hasWeapon then
        ammoClip, ammoTotal = GetAmmoData(ped, currentWeapon)
    end

    local voiceLevel, voiceMax = GetVoiceProximity()

    return {
        playerName    = playerName,
        playerId      = GetServerPlayerId(),
        activePlayers = #GetActivePlayers(),
        voiceLevel    = voiceLevel,
        voiceMax      = voiceMax,
        radioFrequency = GetRadioFrequency(),
        bank          = bank,
        wallet        = wallet,
        dirtyMoney    = dirtyMoney,
        gang          = gangName,
        gangGrade     = gangGrade,
        job           = jobName,
        jobGrade      = jobGrade,
        gameHour      = GetClockHours(),
        gameMinute    = GetClockMinutes(),
        weapon        = GetWeaponDisplayName(currentWeapon),
        weaponImage   = GetWeaponInternalName(currentWeapon),
        hasWeapon     = hasWeapon and true or false,
        ammoClip      = ammoClip,
        ammoTotal     = ammoTotal,
    }
end

function PlayerInfoChanged(prev, next)
    if not prev or not next then return true end
    return prev.playerName    ~= next.playerName
        or prev.job           ~= next.job
        or prev.jobGrade      ~= next.jobGrade
        or prev.wallet        ~= next.wallet
        or prev.bank          ~= next.bank
        or prev.dirtyMoney    ~= next.dirtyMoney
        or prev.gang          ~= next.gang
        or prev.gangGrade     ~= next.gangGrade
        or prev.voiceLevel    ~= next.voiceLevel
        or prev.radioFrequency ~= next.radioFrequency
        or prev.activePlayers ~= next.activePlayers
        or prev.gameHour      ~= next.gameHour
        or prev.gameMinute    ~= next.gameMinute
        or prev.playerId      ~= next.playerId
end

BabloHud = BabloHud or {}

function BabloHud.PushPlayerInfoSnapshot()
    local info = CollectPlayerInfo()
    if not info then return end
    lastSnapshot = nil   
    SendNUIMessage({ action = ACTION_UPDATE, data = info })
    lastSnapshot = info
end

function SendPlayerInfo(info)
    if not info then return end
    if not PlayerInfoChanged(lastSnapshot, info) then return end
    SendNUIMessage({ action = ACTION_UPDATE, data = info })
    lastSnapshot = info
end

function SyncWeaponHudHide()
    local shouldHide = weaponCardVisible and hasWeaponEquipped

    if shouldHide then
        if not hideWeaponHudTickerId and Bablo and Bablo.Ticker then
            hideWeaponHudTickerId = Bablo.Ticker:register(function()
                HideHudComponentThisFrame(2)
            end)
        end
    else
        if hideWeaponHudTickerId and Bablo and Bablo.Ticker then
            Bablo.Ticker:unregister(hideWeaponHudTickerId)
            hideWeaponHudTickerId = nil
        end
    end
end

RegisterNUICallback("setWeaponCardVisible", function(data, cb)
    if type(data) == "table" and data.visible ~= nil then
        weaponCardVisible = data.visible == true
        SyncWeaponHudHide()
    end
    cb({ success = true })
end)

RegisterNUICallback("requestPlayerInfoSnapshot", function(_, cb)
    if BabloHud and BabloHud.PushPlayerInfoSnapshot then
        BabloHud.PushPlayerInfoSnapshot()
    end
    cb({ success = true })
end)

RegisterNUICallback("requestServerTime", function(_, cb)
    local ok, result = pcall(function()
        return lib.callback.await("pradipta-hud:getServerTime", false)
    end)
    if ok and type(result) == "table" and type(result.h) == "number" then
        cb(result)
    else
        cb(false)
    end
end)

lib.onCache("weapon", function(weaponHash)
    hasWeaponEquipped = weaponHash and true or false
    SyncWeaponHudHide()

    if not running then return end

    local isArmed    = weaponHash and weaponHash ~= 0 and weaponHash ~= UNARMED_HASH
    local ammoClip, ammoTotal = 0, 0
    if isArmed then
        local ped = cache and cache.ped
        if ped then ammoClip, ammoTotal = GetAmmoData(ped, weaponHash) end
    end

    local serverId = GetServerPlayerId()

    SendNUIMessage({
        action = ACTION_UPDATE,
        data   = {
            weapon      = GetWeaponDisplayName(weaponHash),
            weaponImage = GetWeaponInternalName(weaponHash),
            hasWeapon   = isArmed and true or false,
            ammoClip    = ammoClip,
            ammoTotal   = ammoTotal,
            playerId    = serverId,
        },
    })
end)

function StartPlayerInfoModule()
    if running then return end
    running = true
    Info("Player info module started")

    CreateThread(function()
        local lastClipAmmo = nil

        while running do
            local weaponHash = cache and cache.weapon

            if weaponHash and weaponHash ~= 0 and weaponHash ~= UNARMED_HASH then
                local ped     = cache and cache.ped
                local clipAmmo, totalAmmo = GetAmmoData(ped, weaponHash)

                if clipAmmo ~= lastClipAmmo then
                    lastClipAmmo = clipAmmo
                    SendNUIMessage({
                        action = ACTION_UPDATE,
                        data   = {
                            weapon      = GetWeaponDisplayName(weaponHash),
                            weaponImage = GetWeaponInternalName(weaponHash),
                            hasWeapon   = true,
                            ammoClip    = clipAmmo,
                            ammoTotal   = totalAmmo,
                        },
                    })
                end

                Wait(IsPedShooting(ped) and 50 or 250)
            else
                lastClipAmmo = nil
                Wait(1000)
            end
        end
    end)

    CreateThread(function()
        Wait(300)
        while running do
            local info = CollectPlayerInfo()
            if info then SendPlayerInfo(info) end
            Wait(5000)
        end
    end)
end

exports("RefreshPlayerInfo", function()
    if not _G.PradiptaHudActive then return false end
    BabloHud.PushPlayerInfoSnapshot()
    return true
end)

RegisterNetEvent("pradipta-hud:playerinfo:refresh")
AddEventHandler("pradipta-hud:playerinfo:refresh", function()
    if not _G.PradiptaHudActive then return end
    BabloHud.PushPlayerInfoSnapshot()
end)

AddEventHandler("pradipta-hud:playerLoaded", function()
    StartPlayerInfoModule()

    CreateThread(function()
        Wait(3000)
        if BabloHud and BabloHud.PushPlayerInfoSnapshot then
            BabloHud.PushPlayerInfoSnapshot()
        end
    end)
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    running = false
end)
