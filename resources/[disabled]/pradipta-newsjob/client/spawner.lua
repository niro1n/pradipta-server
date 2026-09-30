function StoreCurrentVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end

    local plate = PradiptaCore.Functions.GetPlate(veh)
    if not CurrentPlate[plate] then return end

    TriggerServerEvent('pradipta-vehiclekeys:server:RemoveVehicleKeys', plate)
    CurrentPlate[plate] = nil
    DeleteVehicle(veh)
end

local function SpawnReporterVehicle(args)
    if PlayerJob.name ~= 'reporter' then return end
    local coords = Config.Locations[args.location].coords

    PradiptaCore.Functions.TriggerCallback('PradiptaCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        local plate = 'WZNW' .. math.random(1000, 9999)
        SetVehicleNumberPlateText(veh, plate)
        CurrentPlate[plate] = true
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
        SetVehicleEngineOn(veh, true, true, false)
        if args.modLivery then
            local livery = GetVehicleLiveryCount(veh) < 0 and args.modLivery - 1 or args.modLivery
            PradiptaCore.Functions.SetVehicleProperties(veh, { modLivery = livery })
        end
        if Config.UseableItems and args.location == 'vehicle' then
            TriggerServerEvent('pradipta-newsjob:server:addVehicleItems', plate)
        end
    end, args.vehicle, coords, true)
end

function MenuGarage(location)
    local currentGarrage = Config.Locations[location]
    if not currentGarrage or not currentGarrage.vehicles then return end

    local grade = PradiptaCore.Functions.GetPlayerData().job.grade.level
    local menu = { { header = Lang:t('text.' .. location), isMenuHeader = true } }

    for veh, vehData in pairs(currentGarrage.vehicles[grade] or {}) do
        menu[#menu + 1] = {
            header = vehData.label,
            txt = '',
            params = {
                event = SpawnReporterVehicle,
                args = { vehicle = veh, location = location, modLivery = vehData.modLivery },
                isAction = true
            }
        }
    end

    menu[#menu + 1] = {
        header = Lang:t('text.close_menu'),
        txt = '',
        params = { event = 'pradipta-menu:client:closeMenu' }
    }

    exports['pradipta-menu']:openMenu(menu)
end
