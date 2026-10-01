local NUI_ACTIONS = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}

local activeHints    = {}
local hintGeneration = 0

function IsControlHintsDisabled()
    return not Config
end

function IsTable(value)
    return type(value) == "table"
end

function ShowSingleHint(id, label, key, duration)
    if IsControlHintsDisabled() then return false end
    if type(id) ~= "string" or id == "" then return false end
    if type(label) ~= "string" or type(key) ~= "string" then return false end

    hintGeneration = hintGeneration + 1
    local generation = hintGeneration
    activeHints[id]  = generation

    SendNUIMessage({
        action = NUI_ACTIONS.CONTROL_HINT_SHOW or "controlHint:show",
        data   = { id = id, label = label, key = key },
    })

    duration = tonumber(duration)
    if duration and duration > 0 then
        CreateThread(function()
            Wait(math.floor(duration))
            
            if activeHints[id] == generation then
                activeHints[id] = nil
                SendNUIMessage({
                    action = NUI_ACTIONS.CONTROL_HINT_HIDE or "controlHint:hide",
                    data   = { id = id },
                })
            end
        end)
    end

    return true
end

function HideSingleHint(id)
    if type(id) ~= "string" or id == "" then return false end
    activeHints[id] = nil
    SendNUIMessage({
        action = NUI_ACTIONS.CONTROL_HINT_HIDE or "controlHint:hide",
        data   = { id = id },
    })
    return true
end

function ClearAllHints()
    activeHints = {}
    SendNUIMessage({ action = NUI_ACTIONS.CONTROL_HINT_CLEAR or "controlHint:clear" })
    return true
end

function ShowControlHint(idOrTable, label, key, duration)
    if type(idOrTable) == "string" then
        return ShowSingleHint(idOrTable, label, key, duration)
    end

    if type(idOrTable) ~= "table" then return false end

    local defaultDuration = tonumber(label)  

    if IsTable(idOrTable) and idOrTable.id then
        return ShowSingleHint(
            idOrTable.id,
            idOrTable.label,
            idOrTable.key,
            idOrTable.duration or defaultDuration
        )
    end

    local allOk = true
    for _, hint in ipairs(idOrTable) do
        if IsTable(hint) then
            local ok = ShowSingleHint(
                hint.id,
                hint.label,
                hint.key,
                hint.duration or defaultDuration
            )
            if not ok then allOk = false end
        end
    end
    return allOk
end

function HideControlHint(idOrTable)
    if type(idOrTable) == "string" then
        return HideSingleHint(idOrTable)
    end

    if type(idOrTable) ~= "table" then return false end

    if IsTable(idOrTable) and idOrTable.id then
        return HideSingleHint(idOrTable.id)
    end

    for _, entry in ipairs(idOrTable) do
        if type(entry) == "string" then
            HideSingleHint(entry)
        elseif IsTable(entry) and entry.id then
            HideSingleHint(entry.id)
        end
    end
    return true
end

exports("ShowControlHint",  ShowControlHint)
exports("ShowControlHints", ShowControlHint)
exports("HideControlHint",  HideControlHint)
exports("HideControlHints", HideControlHint)
exports("ClearControlHints", ClearAllHints)

RegisterNetEvent("pradipta-hud:controlhint:show")
AddEventHandler("pradipta-hud:controlhint:show", function(id, label, key, duration)
    ShowControlHint(id, label, key, duration)
end)

RegisterNetEvent("pradipta-hud:controlhint:hide")
AddEventHandler("pradipta-hud:controlhint:hide", function(idOrTable)
    HideControlHint(idOrTable)
end)

RegisterNetEvent("pradipta-hud:controlhint:clear")
AddEventHandler("pradipta-hud:controlhint:clear", function()
    ClearAllHints()
end)

