local NUI_ACTIONS = (BabloHud and BabloHud.Constants and BabloHud.Constants.NUI_ACTIONS) or {}

local currentBar = nil   

RegisterCommand("pradiptahud:cancelProgress", function()
    if currentBar and currentBar.canCancel then
        currentBar.active = false
    end
end, false)
RegisterCommand("bablohud:cancelProgress", function()
    if currentBar and currentBar.canCancel then
        currentBar.active = false
    end
end, false)

RegisterKeyMapping("pradiptahud:cancelProgress", "Cancel progress bar", "keyboard", "x")

function SendProgressStart(data)
    SendNUIMessage({
        action = NUI_ACTIONS.PROGRESS_START or "progressBar:start",
        data   = data,
    })
end

function SendProgressStop()
    SendNUIMessage({ action = NUI_ACTIONS.PROGRESS_STOP or "progressBar:stop" })
end

function SendProgressUpdate(value, label)
    SendNUIMessage({
        action = NUI_ACTIONS.PROGRESS_UPDATE or "progressBar:update",
        data   = { value = value, label = label },
    })
end

function SpawnProp(ped, propConfig)
    if not propConfig or not propConfig.model then return nil end

    local modelHash = GetHashKey(propConfig.model)
    RequestModel(modelHash)

    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() > deadline then return nil end
        Citizen.Wait(0)
    end

    local pos    = GetEntityCoords(ped)
    local prop   = CreateObject(modelHash, pos.x, pos.y, pos.z, true, true, false)
    local bone   = GetPedBoneIndex(ped, propConfig.bone or 60309)

    local coords   = propConfig.coords   or {}
    local rotation = propConfig.rotation or {}

    AttachEntityToEntity(
        prop, ped, bone,
        coords.x   or 0.0, coords.y   or 0.0, coords.z   or 0.0,
        rotation.x or 0.0, rotation.y or 0.0, rotation.z or 0.0,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(modelHash)
    return prop
end

function PlayAnimation(ped, animConfig)
    if not animConfig then return end

    if animConfig.babloAnim then
        if GetResourceState("bablo-animations") == "started" then
            pcall(function()
                exports["bablo-animations"]:playAnimation(ped, animConfig.babloAnim)
            end)
        else
            print("[pradipta-hud] bablo-animations is not started — babloAnim will not play")
        end
        return
    end

    if not (animConfig.animDict and animConfig.anim) then return end

    RequestAnimDict(animConfig.animDict)
    local deadline = GetGameTimer() + 5000
    while not HasAnimDictLoaded(animConfig.animDict) do
        if GetGameTimer() > deadline then return end
        Citizen.Wait(0)
    end

    TaskPlayAnim(
        ped,
        animConfig.animDict,
        animConfig.anim,
        8.0, -8.0, -1,
        animConfig.flags or 1,
        0, false, false, false
    )
    RemoveAnimDict(animConfig.animDict)
end

function StopAnimation(ped, animConfig)
    if not animConfig then return end

    if animConfig.babloAnim then
        if GetResourceState("bablo-animations") == "started" then
            pcall(function()
                exports["bablo-animations"]:cancelAnimation()
            end)
        end
        return
    end

    if animConfig.animDict and animConfig.anim then
        ClearPedTasks(ped)
    end
end

function ApplyControlDisables(controlDisables)
    if not controlDisables then return end

    if controlDisables.disableMovement then
        DisableControlAction(0, 30, true)   
        DisableControlAction(0, 31, true)   
        DisableControlAction(0, 21, true)   
        DisableControlAction(0, 22, true)   
        DisableControlAction(0, 44, true)   
        DisableControlAction(0, 36, true)   
    end

    if controlDisables.disableCarMovement then
        DisableControlAction(27, 59, true)  
        DisableControlAction(27, 60, true)  
        DisableControlAction(27, 71, true)  
        DisableControlAction(27, 72, true)  
    end

    if controlDisables.disableMouse then
        DisableControlAction(0, 1, true)    
        DisableControlAction(0, 2, true)    
    end

    if controlDisables.disableCombat then
        DisableControlAction(0, 24, true)   
        DisableControlAction(0, 25, true)   
        DisableControlAction(0, 37, true)   
        DisableControlAction(0, 47, true)   
        DisableControlAction(0, 58, true)   
    end
end

function ProgressBar(options, callback)
    if not options then
        error("[pradipta-hud] ProgressBar export requires a data table")
        return
    end

    local isManual = options.manual == true
    if not isManual and not options.duration then
        error("[pradipta-hud] ProgressBar export requires 'duration' (or manual = true)")
        return
    end

    if currentBar then currentBar.active = false end

    local canCancel = options.canCancel ~= false

    SendProgressStart({
        duration = isManual and 0 or options.duration,
        manual   = isManual,
        label    = options.label or "Processing...",
        color    = options.color,
        control  = options.control or (canCancel and "X" or nil),
    })

    local bar = {
        active    = true,
        canCancel = canCancel,
        manual    = isManual,
        completed = false,
    }
    currentBar = bar

    Citizen.CreateThread(function()
        local ped       = PlayerPedId()
        local startTime = GetGameTimer()
        local props     = {}

        PlayAnimation(ped, options.animation)

        if options.prop_left  then props[1] = SpawnProp(ped, options.prop_left)  end
        if options.prop_right then props[2] = SpawnProp(ped, options.prop_right) end

        while bar.active do
            local elapsed = GetGameTimer() - startTime

            if not isManual and elapsed >= options.duration then break end

            ApplyControlDisables(options.controlDisables)

            if not options.useWhileDead and IsEntityDead(PlayerPedId()) then
                bar.active = false
                break
            end

            Citizen.Wait(0)
        end

        local elapsed   = GetGameTimer() - startTime
        local cancelled = isManual and not bar.completed
                       or (not isManual and elapsed < options.duration)

        for _, prop in ipairs(props) do
            if prop and DoesEntityExist(prop) then
                DeleteObject(prop)
            end
        end

        StopAnimation(PlayerPedId(), options.animation)

        if cancelled or isManual then
            SendProgressStop()
        end

        if currentBar == bar then currentBar = nil end

        if callback then callback(cancelled) end
    end)
end

function UpdateProgressBar(valueOrTable, label)
    if not currentBar then return false end

    local value, newLabel

    if type(valueOrTable) == "table" then
        value    = tonumber(valueOrTable.value or valueOrTable.progress or valueOrTable.percent)
        newLabel = valueOrTable.label
    else
        value    = tonumber(valueOrTable)
        newLabel = label
    end

    if value == nil and newLabel == nil then return false end

    if value ~= nil then
        value = math.max(0, math.min(100, value))
    end

    SendProgressUpdate(value, newLabel)

    if value ~= nil and value >= 100 and currentBar.manual then
        currentBar.completed = true
        currentBar.active    = false
    end

    return true
end

function CompleteProgressBar()
    if not currentBar then return false end
    SendProgressUpdate(100, nil)
    currentBar.completed = true
    currentBar.active    = false
    return true
end

function StopProgressBar()
    if currentBar then currentBar.active = false end
    SendProgressStop()
end

exports("ProgressBar",        ProgressBar)
exports("UpdateProgressBar",  UpdateProgressBar)
exports("CompleteProgressBar", CompleteProgressBar)
exports("StopProgressBar",    StopProgressBar)

RegisterNetEvent("pradipta-hud:progressbar:start")
AddEventHandler("pradipta-hud:progressbar:start", function(duration, label, color, control)
    SendProgressStart({
        duration = duration,
        label    = label,
        color    = color,
        control  = control,
    })
end)

RegisterNetEvent("pradipta-hud:progressbar:stop")
AddEventHandler("pradipta-hud:progressbar:stop", function()
    SendProgressStop()
end)

RegisterNetEvent("pradipta-hud:progressbar:update")
AddEventHandler("pradipta-hud:progressbar:update", function(valueOrTable, label)
    UpdateProgressBar(valueOrTable, label)
end)

RegisterNetEvent("pradipta-hud:progressbar:complete")
AddEventHandler("pradipta-hud:progressbar:complete", function()
    CompleteProgressBar()
end)
