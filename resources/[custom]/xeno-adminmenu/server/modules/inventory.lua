local InventoryType = Config.Inventory or 'autodetect'

CreateThread(function()
    if InventoryType == 'autodetect' then
        if GetResourceState('ox_inventory') == 'started' then
            InventoryType = 'ox_inventory'
        elseif GetResourceState('qb-inventory') == 'started' then
            InventoryType = 'qb-inventory'
        elseif GetResourceState('qs-inventory') == 'started' then
            InventoryType = 'qs-inventory'
        elseif GetResourceState('ps-inventory') == 'started' then
            InventoryType = 'ps-inventory'
        elseif GetResourceState('lj-inventory') == 'started' then
            InventoryType = 'lj-inventory'
        elseif GetResourceState('core_inventory') == 'started' then
            InventoryType = 'core_inventory'
        else
            InventoryType = 'unknown'
        end
    end
    DebugLog('^2[Xeno-AdminMenu] Inventory initialized: ' .. InventoryType .. '^0')
end)

function GetInventoryType()
    return InventoryType
end

local CachedAllItems = nil
function GetAllFrameworkItems()
    if CachedAllItems then return CachedAllItems end
    
    local allItems = {}
    
    if InventoryType == 'ox_inventory' then
        local items = exports.ox_inventory:Items()
        if items then
            for k, v in pairs(items) do
                table.insert(allItems, {
                    name = v.name,
                    label = v.label or v.name,
                    image = 'nui://ox_inventory/web/images/' .. (v.name .. '.png')
                })
            end
        end
    elseif InventoryType == 'qs-inventory' then
        
        local items = nil
        pcall(function() items = exports['qs-inventory']:GetItemList() end)
        if items then
            for k, v in pairs(items) do
                table.insert(allItems, {
                    name = v.name,
                    label = v.label or v.name,
                    image = 'nui://qs-inventory/html/images/' .. (v.image or (v.name .. '.png'))
                })
            end
        elseif Framework == 'qbcore' or Framework == 'qbox' then
            local Shared = exports['qb-core']:GetCoreObject().Shared
            if Shared and Shared.Items then
                for k, v in pairs(Shared.Items) do
                    table.insert(allItems, {
                        name = v.name,
                        label = v.label or v.name,
                        image = 'nui://qs-inventory/html/images/' .. (v.image or (v.name .. '.png'))
                    })
                end
            end
        end
    elseif InventoryType == 'core_inventory' then
        local items = nil
        pcall(function() items = exports['core_inventory']:getItems() end)
        if items then
            for k, v in pairs(items) do
                table.insert(allItems, {
                    name = v.name,
                    label = v.label or v.name,
                    image = 'nui://core_inventory/html/img/' .. (v.image or (v.name .. '.png'))
                })
            end
        end
    else
        
        if Framework == 'qbcore' or Framework == 'qbox' then
            local Shared = Core and Core.Shared
            if not Shared then
                Shared = exports['qb-core']:GetCoreObject().Shared
            end
            if Shared and Shared.Items then
                for k, v in pairs(Shared.Items) do
                    local invDir = InventoryType
                    if invDir == 'autodetect' or invDir == 'unknown' then invDir = 'qb-inventory' end
                    table.insert(allItems, {
                        name = v.name,
                        label = v.label or v.name,
                        image = 'nui://' .. invDir .. '/html/images/' .. (v.image or (v.name .. '.png'))
                    })
                end
            end
        elseif Framework == 'esx' then
            local ESX = exports['es_extended']:getSharedObject()
            if ESX and ESX.Items then
                for k, v in pairs(ESX.Items) do
                    table.insert(allItems, {
                        name = v.name or k,
                        label = v.label or k,
                        image = 'nui://' .. (InventoryType == 'unknown' and 'qs-inventory' or InventoryType) .. '/html/images/' .. ((v.name or k) .. '.png')
                    })
                end
            end
        end
    end
    
    if #allItems > 0 then
        CachedAllItems = allItems
    else
        DebugLog('^3[Xeno-AdminMenu] Warning: No items found to cache. Check inventory configuration. InventoryType: ' .. tostring(InventoryType) .. '^0')
        if Framework == 'qbcore' then
            local Shared = Core and Core.Shared
            if not Shared then Shared = exports['qb-core']:GetCoreObject().Shared end
            if not Shared then DebugLog('^1[Xeno-AdminMenu] Error: Shared object is completely nil!^0')
            elseif not Shared.Items then DebugLog('^1[Xeno-AdminMenu] Error: Shared.Items is nil!^0')
            else DebugLog('^1[Xeno-AdminMenu] Error: Shared.Items has 0 entries!^0') end
        end
    end
    return allItems
end

function GetPlayerItems(src)
    local items = {}
    
    if InventoryType == 'ox_inventory' then
        local inv = exports.ox_inventory:GetInventoryItems(src)
        if inv then
            for k, v in pairs(inv) do
                if v and v.slot and v.slot <= 5 then
                    table.insert(items, {
                        name = v.name,
                        label = v.label or v.name,
                        count = v.count,
                        iconPath = 'ox_inventory/web/images/' .. v.name .. '.png'
                    })
                end
            end
        end
    elseif InventoryType == 'qb-inventory' or InventoryType == 'ps-inventory' or InventoryType == 'lj-inventory' then
        local Player
        if Framework == 'qbcore' then
            Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
        elseif Framework == 'qbox' then
            Player = exports.qbx_core:GetPlayer(src)
        end
        if Player and Player.PlayerData.items then
            for k, v in pairs(Player.PlayerData.items) do
                if v and v.slot and v.slot <= 5 then
                    table.insert(items, {
                        name = v.name,
                        label = v.label or v.name,
                        count = v.amount or v.count or 1,
                        iconPath = InventoryType .. '/html/images/' .. v.name .. '.png'
                    })
                end
            end
        end
    elseif InventoryType == 'qs-inventory' then
        local inv = exports['qs-inventory']:GetInventory(src)
        if inv then
            for k, v in pairs(inv) do
                if v and v.slot and tonumber(v.slot) <= 5 then
                    table.insert(items, {
                        name = v.name,
                        label = v.label or v.name,
                        count = v.amount or 1,
                        iconPath = 'qs-inventory/html/images/' .. v.name .. '.png'
                    })
                end
            end
        end
    elseif InventoryType == 'core_inventory' then
        local inv = exports['core_inventory']:getInventory('content-' .. src)
        if inv then
            for k, v in pairs(inv) do
                if tonumber(k) and tonumber(k) <= 5 then
                    table.insert(items, {
                        name = v.name,
                        label = v.label or v.name,
                        count = v.amount or v.count or 1,
                        iconPath = 'core_inventory/html/img/' .. v.name .. '.png'
                    })
                end
            end
        end
    end
    
    
    
    return items
end

function GivePlayerItem(src, item, count)
    count = tonumber(count) or 1
    if InventoryType == 'ox_inventory' then
        exports.ox_inventory:AddItem(src, item, count)
    elseif InventoryType == 'qb-inventory' or InventoryType == 'ps-inventory' or InventoryType == 'lj-inventory' then
        local Player
        if Framework == 'qbcore' then
            Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
        elseif Framework == 'qbox' then
            Player = exports.qbx_core:GetPlayer(src)
        end
        if Player then
            Player.Functions.AddItem(item, count)
        end
    elseif InventoryType == 'qs-inventory' then
        exports['qs-inventory']:AddItem(src, item, count)
    elseif InventoryType == 'core_inventory' then
        exports['core_inventory']:addItem('content-' .. src, item, count, {}, 'admin')
    end
end

function RemovePlayerItem(src, item, count)
    count = tonumber(count) or 1
    if InventoryType == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(src, item, count)
    elseif InventoryType == 'qb-inventory' or InventoryType == 'ps-inventory' or InventoryType == 'lj-inventory' then
        local Player
        if Framework == 'qbcore' then
            Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
        elseif Framework == 'qbox' then
            Player = exports.qbx_core:GetPlayer(src)
        end
        if Player then
            Player.Functions.RemoveItem(item, count)
        end
    elseif InventoryType == 'qs-inventory' then
        exports['qs-inventory']:RemoveItem(src, item, count)
    elseif InventoryType == 'core_inventory' then
        exports['core_inventory']:removeItem('content-' .. src, item, count)
    end
end

function OpenInventoryForAdmin(adminSrc, targetSrc)
    if InventoryType == 'ox_inventory' then
        exports.ox_inventory:forceOpenInventory(adminSrc, 'player', targetSrc)
    elseif InventoryType == 'qb-inventory' or InventoryType == 'ps-inventory' or InventoryType == 'lj-inventory' or InventoryType == 'qs-inventory' then
        TriggerClientEvent('xeno-adminmenu:client:OpenTargetInventory', adminSrc, targetSrc, InventoryType)
    elseif InventoryType == 'core_inventory' then
        TriggerClientEvent('core_inventory:client:openInventory', adminSrc, targetSrc, 'content-' .. targetSrc)
    end
end
