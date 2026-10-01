local resourceName  = GetCurrentResourceName()
local globalConfig  = {}  

function GetConfigFilename()
    local gc = Config and Config.GlobalConfig
    return (gc and gc.filename) or "global-config.json"
end

function IsGlobalConfigEnabled()
    local gc = Config and Config.GlobalConfig
    return gc and gc.enabled == true
end

function IsGlobalConfigEditAllowed()
    local gc = Config and Config.GlobalConfig
    return gc and gc.allowEdit == true
end

function LoadGlobalConfig()
    local filename = GetConfigFilename()
    local raw      = LoadResourceFile(resourceName, filename)

    if not raw or raw == "" then
        globalConfig = {}
        return
    end

    local ok, decoded = pcall(json.decode, raw)
    if ok and type(decoded) == "table" then
        globalConfig = decoded
    else
        globalConfig = {}
    end
end

function SaveGlobalConfig()
    local filename = GetConfigFilename()
    local encoded  = json.encode(globalConfig) or "{}"
    return SaveResourceFile(resourceName, filename, encoded, -1)
end

function PushGlobalConfigToPlayer(playerId)
    local isAdmin = false
    if IsGlobalConfigEnabled() and Framework and Framework.isAdmin then
        isAdmin = Framework.isAdmin(Framework, playerId) == true
    end

    TriggerClientEvent("pradipta-hud:globalConfig:push", playerId, {
        enabled   = IsGlobalConfigEnabled(),
        config    = globalConfig,
        isAdmin   = isAdmin,
        allowEdit = IsGlobalConfigEditAllowed(),
    })
end

function BroadcastGlobalConfig()
    TriggerClientEvent("pradipta-hud:globalConfig:broadcast", -1, {
        enabled   = IsGlobalConfigEnabled(),
        config    = globalConfig,
        allowEdit = IsGlobalConfigEditAllowed(),
    })
end

AddEventHandler("onResourceStart", function(startedResource)
    if startedResource ~= resourceName then return end
    LoadGlobalConfig()
end)

RegisterNetEvent("pradipta-hud:globalConfig:request")
AddEventHandler("pradipta-hud:globalConfig:request", function()
    PushGlobalConfigToPlayer(source)
end)

RegisterNetEvent("pradipta-hud:globalConfig:publish")
AddEventHandler("pradipta-hud:globalConfig:publish", function(newData)
    local playerId = source

    if not IsGlobalConfigEnabled() then return end

    if not (Framework and Framework.isAdmin and Framework.isAdmin(Framework, playerId)) then
        return
    end

    if type(newData) ~= "table" then return end

    if type(globalConfig) == "table" then
        for k, v in pairs(newData) do
            globalConfig[k] = v
        end
    else
        globalConfig = newData
    end

    SaveGlobalConfig()
    BroadcastGlobalConfig()
end)

