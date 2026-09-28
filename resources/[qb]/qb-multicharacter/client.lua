local cam = nil
local charPed = nil
local currentCharPedCid = nil
local isNuiReady = false
local isUiActive = false
local isMenuOpen = false
local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
local cached_player_skins = {}

local randommodels = { -- models possible to load when choosing empty slot
    'mp_m_freemode_01',
    'mp_f_freemode_01',
}

-- Main Thread

CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsSessionStarted() then
            TriggerEvent('qb-multicharacter:client:chooseChar')
            return
        end
    end
end)

-- Functions

local function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

local function initializePedModel(model, data)
    CreateThread(function()
        if not model or model == false then
            model = joaat(randommodels[math.random(#randommodels)])
        elseif type(model) == 'string' and tonumber(model) then
            model = tonumber(model)
        end
        loadModel(model)
        if DoesEntityExist(charPed) then
            SetEntityAsMissionEntity(charPed, true, true)
            DeleteEntity(charPed)
        end
        charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
        SetEntityAsMissionEntity(charPed, true, true)
        if Entity(charPed) and Entity(charPed).state then
            Entity(charPed).state:set('isCharPed', true, false)
        end
        SetPedComponentVariation(charPed, 0, 0, 0, 2)
        FreezeEntityPosition(charPed, false)
        SetEntityInvincible(charPed, true)
        PlaceObjectOnGroundProperly(charPed)
        SetBlockingOfNonTemporaryEvents(charPed, true)
        if data then
            -- illenium-appearance: data from getSkin is already in illenium JSON format
            local appearance = type(data) == 'string' and json.decode(data) or data
            if appearance and GetResourceState('illenium-appearance') == 'started' then
                exports['illenium-appearance']:setPedAppearance(charPed, appearance)
            end
        end
    end)
end

local function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, 0.0, 0.0, Config.CamCoords.w, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

local function openCharMenu(bool)
    isMenuOpen = bool
    if bool then
        -- Ensure NUI is ready before firing message
        local startWait = GetGameTimer()
        while not isNuiReady and (GetGameTimer() - startWait) < 4000 do
            Wait(50)
        end

        QBCore.Functions.TriggerCallback('qb-multicharacter:server:GetNumberOfCharacters', function(result, countries)
            local translations = {}
            for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
                if k:sub(0, ('ui.'):len()) then
                    translations[k:sub(('ui.'):len() + 1)] = Lang:t(k)
                end
            end
            local uiData = {
                action = 'ui',
                customNationality = Config.customNationality,
                toggle = true,
                nChar = result,
                enableDeleteButton = Config.EnableDeleteButton,
                translations = translations,
                countries = countries,
            }
            skyCam(true)
            SetNuiFocus(true, true)
            SendNUIMessage(uiData)

            -- Active watchdog: resend message and refocus if NUI didn't activate
            CreateThread(function()
                local retries = 0
                while isMenuOpen and not isUiActive and retries < 8 do
                    Wait(750)
                    if isMenuOpen and not isUiActive then
                        retries = retries + 1
                        SetNuiFocus(true, true)
                        SendNUIMessage(uiData)
                    end
                end
            end)
        end)
    else
        isUiActive = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'ui',
            toggle = false
        })
        skyCam(false)
    end
end

-- Events

RegisterNetEvent('qb-multicharacter:client:closeNUIdefault', function() -- This event is only for no starting apartments
    currentCharPedCid = nil
    if DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        charPed = nil
    end
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    openCharMenu()
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    -- illenium-appearance listens to this event in client/framework/qb/main.lua
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    currentCharPedCid = nil
    if DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        charPed = nil
    end
    SetNuiFocus(false, false)
end)

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    currentCharPedCid = nil
    if DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        charPed = nil
    end
    isUiActive = false
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(500)
    local interior = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z - 18.9)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Wait(250)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Wait(500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(250)
    openCharMenu(true)
end)

RegisterNetEvent('qb-multicharacter:client:spawnLastLocation', function(coords, cData)
    QBCore.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
        if result then
            TriggerEvent('apartments:client:SetHomeBlip', result.type)
            local ped = PlayerPedId()
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
            SetEntityHeading(ped, coords.w)
            FreezeEntityPosition(ped, false)
            SetEntityVisible(ped, true)
            local PlayerData = QBCore.Functions.GetPlayerData()
            local insideMeta = PlayerData.metadata['inside']
            DoScreenFadeOut(500)

            if insideMeta and insideMeta.house then
                TriggerEvent('qb-houses:client:LastLocationHouse', insideMeta.house)
            elseif insideMeta and insideMeta.apartment and insideMeta.apartment.apartmentType and insideMeta.apartment.apartmentId then
                TriggerEvent('qb-apartments:client:LastLocationHouse', insideMeta.apartment.apartmentType, insideMeta.apartment.apartmentId)
            else
                SetEntityCoords(ped, coords.x, coords.y, coords.z)
                SetEntityHeading(ped, coords.w)
                FreezeEntityPosition(ped, false)
                SetEntityVisible(ped, true)
            end

            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            Wait(2000)
            DoScreenFadeIn(250)
        end
    end, cData.citizenid)
end)

-- NUI Callbacks

RegisterNUICallback('nuiReady', function(_, cb)
    isNuiReady = true
    cb('ok')
end)

RegisterNUICallback('uiLoaded', function(_, cb)
    isUiActive = true
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    local cData = data and data.cData
    currentCharPedCid = nil
    DoScreenFadeOut(10)
    if cData then
        TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    end
    openCharMenu(false)
    if DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        charPed = nil
    end
    if Config.SkipSelection then
        SetNuiFocus(false, false)
        skyCam(false)
    else
        openCharMenu(false)
    end
    cb('ok')
end)

RegisterNUICallback('disconnectButton', function(_, cb)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('qb-multicharacter:server:disconnect')
    cb('ok')
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    local cData = data.cData
    currentCharPedCid = nil
    DoScreenFadeOut(10)
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    if DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        charPed = nil
    end
    cb('ok')
end)

RegisterNUICallback('cDataPed', function(nData, cb)
    local cData = nData.cData
    local targetCid = cData and cData.citizenid or 'empty'

    if DoesEntityExist(charPed) and currentCharPedCid == targetCid then
        cb('ok')
        return
    end

    currentCharPedCid = targetCid
    if DoesEntityExist(charPed) then
        SetEntityAsMissionEntity(charPed, true, true)
        DeleteEntity(charPed)
        charPed = nil
    end
    if cData ~= nil then
        if not cached_player_skins[cData.citizenid] then
            local temp_model = promise.new()
            local temp_data = promise.new()

            QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
                temp_model:resolve(model)
                temp_data:resolve(data)
            end, cData.citizenid)

            local resolved_model = Citizen.Await(temp_model)
            local resolved_data = Citizen.Await(temp_data)

            cached_player_skins[cData.citizenid] = { model = resolved_model, data = resolved_data }
        end

        local model = cached_player_skins[cData.citizenid].model
        local data = cached_player_skins[cData.citizenid].data

        if data then
            local appearance = type(data) == 'string' and json.decode(data) or data
            local pedModel = (appearance and appearance.model) or model
            initializePedModel(pedModel, appearance)
        elseif model then
            initializePedModel(model)
        else
            initializePedModel()
        end
        cb('ok')
    else
        initializePedModel()
        cb('ok')
    end
end)

RegisterNUICallback('setupCharacters', function(_, cb)
    QBCore.Functions.TriggerCallback('qb-multicharacter:server:setupCharacters', function(result)
        cached_player_skins = {}
        SendNUIMessage({
            action = 'setupCharacters',
            characters = result
        })
        cb('ok')
    end)
end)

RegisterNUICallback('removeBlur', function(_, cb)
    SetTimecycleModifier('default')
    cb('ok')
end)

RegisterNUICallback('createNewCharacter', function(data, cb)
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == Lang:t('ui.male') or cData.gender == 'Male' or cData.gender == 'Laki-laki' or cData.gender == 0 then
        cData.gender = 0
    elseif cData.gender == Lang:t('ui.female') or cData.gender == 'Female' or cData.gender == 'Perempuan' or cData.gender == 1 then
        cData.gender = 1
    end
    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
    Wait(500)
    cb('ok')
end)

RegisterNUICallback('removeCharacter', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
    DeletePed(charPed)
    TriggerEvent('qb-multicharacter:client:chooseChar')
    cb('ok')
end)

-- Recovery Commands (in case of NUI desync)
RegisterCommand('fixchar', function()
    TriggerEvent('qb-multicharacter:client:chooseChar')
end, false)

RegisterCommand('loadchar', function()
    TriggerEvent('qb-multicharacter:client:chooseChar')
end, false)
