local migrations = {
    [[
        CREATE TABLE IF NOT EXISTS pradipta_hud_mileage
        (
            plate VARCHAR(16) NOT NULL,
            mileage DOUBLE NOT NULL DEFAULT 0,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (plate)
        );
    ]],
}

local persistentEnabled = Config and Config.Mileage and Config.Mileage.persistent ~= false
local dbReady           = false

local mileageCache = {}

local dirtyPlates  = {}

function NormalisePlate(raw)
    if type(raw) ~= "string" then return nil end
    local trimmed = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then return nil end
    return trimmed:upper()
end

function FlushDirtyMileage()
    if not persistentEnabled or not dbReady then return end

    for plate in pairs(dirtyPlates) do
        dirtyPlates[plate] = nil
        local mileage = mileageCache[plate]
        if mileage then
            local ok, err = pcall(function()
                MySQL.query.await(
                    "INSERT INTO pradipta_hud_mileage (plate, mileage) VALUES (?, ?) ON DUPLICATE KEY UPDATE mileage = ?",
                    { plate, mileage, mileage }
                )
            end)
            if not ok then
                print(("[pradipta-hud] mileage save failed for %s: %s"):format(plate, tostring(err)))
            end
        end
    end
end

if persistentEnabled then
    MySQL.ready(function()
        for _, sql in ipairs(migrations) do
            local ok, err = pcall(function()
                MySQL.query.await(sql)
            end)
            if not ok then
                print(("[pradipta-hud] mileage migration failed: %s"):format(tostring(err)))
                return
            end
        end
        dbReady = true
    end)

    CreateThread(function()
        local intervalSec = tonumber(Config.Mileage and Config.Mileage.saveInterval) or 60
        local intervalMs  = intervalSec * 1000
        while true do
            Wait(intervalMs)
            FlushDirtyMileage()
        end
    end)

    AddEventHandler("onResourceStop", function(resourceName)
        if GetCurrentResourceName() == resourceName then
            FlushDirtyMileage()
        end
    end)
end

if lib and lib.callback and lib.callback.register then
    lib.callback.register("pradipta-hud:mileage:get", function(_, rawPlate)
        local plate = NormalisePlate(rawPlate)
        if not plate then return 0.0 end

        if mileageCache[plate] ~= nil then
            return mileageCache[plate]
        end

        if not persistentEnabled or not dbReady then return 0.0 end

        local ok, result = pcall(function()
            return MySQL.scalar.await(
                "SELECT mileage FROM pradipta_hud_mileage WHERE plate = ?",
                { plate }
            )
        end)

        local value = (ok and tonumber(result)) or 0.0
        mileageCache[plate] = value
        return value
    end)
end

RegisterNetEvent("pradipta-hud:mileage:add")
AddEventHandler("pradipta-hud:mileage:add", function(rawPlate, rawDelta)
    local plate = NormalisePlate(rawPlate)
    local delta = tonumber(rawDelta)

    if not plate or not delta then return end
    if delta <= 0 or delta > 2.0 then return end  

    mileageCache[plate] = (mileageCache[plate] or 0.0) + delta
    dirtyPlates[plate]  = true
end)

