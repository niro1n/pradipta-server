RegisterNetEvent('pradipta-radialmenu:server:RemoveStretcher', function(pos, stretcherObject)
    TriggerClientEvent('pradipta-radialmenu:client:RemoveStretcherFromArea', -1, pos, stretcherObject)
end)

RegisterNetEvent('pradipta-radialmenu:Stretcher:BusyCheck', function(target, type)
    local src = source
    if not IsCloseToTarget(src, target) then return end
    TriggerClientEvent('pradipta-radialmenu:Stretcher:client:BusyCheck', target, source, type)
end)

RegisterNetEvent('pradipta-radialmenu:server:BusyResult', function(isBusy, target, type)
    local src = source
    if not IsCloseToTarget(src, target) then return end
    TriggerClientEvent('pradipta-radialmenu:client:Result', target, isBusy, type)
end)
