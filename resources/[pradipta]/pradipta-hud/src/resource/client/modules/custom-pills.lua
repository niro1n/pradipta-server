function SetCustomPill(id, value)
    local resolvedValue = nil
    if value ~= nil then
        local str = tostring(value)
        if str then resolvedValue = str end
    end

    SendNUIMessage({
        action = "setCustomPill",
        data   = {
            id    = tostring(id),
            value = resolvedValue,
        },
    })
end

function HasCustomPills()
    return Config.CustomPills and #Config.CustomPills > 0
end

function LoadCustomPillDefinitions()
    if not HasCustomPills() then return end
    SendNUIMessage({
        action = "loadCustomPills",
        data   = Config.CustomPills,
    })
end

local pillsActive = false

function StartPillFetchLoop(pill)
    local interval = tonumber(pill.fetchInterval) or 1000

    CreateThread(function()
        while pillsActive do
            local ok, result = pcall(pill.fetch)
            if ok then
                SetCustomPill(pill.id, result)
            end
            Citizen.Wait(interval)
        end
    end)
end

function StartAllPillFetchLoops()
    if not HasCustomPills() then return end
    pillsActive = true
    for _, pill in ipairs(Config.CustomPills) do
        if type(pill.fetch) == "function" then
            StartPillFetchLoop(pill)
        end
    end
end

function StopAllPillFetchLoops()
    pillsActive = false
    if not HasCustomPills() then return end
    for _, pill in ipairs(Config.CustomPills) do
        SetCustomPill(pill.id, pill.defaultValue)
    end
end

function RegisterPillEventHandlers()
    if not HasCustomPills() then return end
    for _, pill in ipairs(Config.CustomPills) do
        if type(pill.event) == "string" and pill.event ~= "" then
            local pillId = pill.id
            AddEventHandler(pill.event, function(value)
                SetCustomPill(pillId, value)
            end)
        end
    end
end

RegisterPillEventHandlers()

AddEventHandler("pradipta-hud:playerLoaded", function()
    LoadCustomPillDefinitions()
    StartAllPillFetchLoops()
end)

AddEventHandler("pradipta-hud:playerUnloaded", function()
    StopAllPillFetchLoops()
end)

