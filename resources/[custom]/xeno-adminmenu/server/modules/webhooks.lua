




local COLORS = {
    info    = 3447003,   
    success = 3066993,   
    warning = 15105570,  
    error   = 15158332,  
    admin   = 10181046,  
    player  = 3447003,   
    system  = 8421504,   
    kick    = 15158332,  
    weather = 1752220,   
    report  = 15844367,  
    item    = 3066993,   
}




function SendDiscordWebhook(eventType, title, description, color, fields)
    exports.oxmysql:execute('SELECT * FROM xeno_admin_webhooks WHERE is_active = 1', {}, function(webhooks)
        if not webhooks then return end

        for _, webhook in ipairs(webhooks) do
            local events = {}
            if type(webhook.events) == "string" then
                events = json.decode(webhook.events) or {}
            elseif type(webhook.events) == "table" then
                events = webhook.events
            end

            local hasEvent = false
            for _, ev in ipairs(events) do
                if ev == eventType then
                    hasEvent = true
                    break
                end
            end

            if hasEvent then
                local embedFields = {}
                if fields then
                    for _, f in ipairs(fields) do
                        table.insert(embedFields, {
                            name = f.name or "Field",
                            value = f.value or "N/A",
                            inline = f.inline ~= false
                        })
                    end
                end

                local embed = {
                    {
                        title = title or "Server Event",
                        description = description or "",
                        color = color or COLORS.info,
                        fields = embedFields,
                        footer = {
                            text = "Xeno Admin Menu • " .. os.date("%Y-%m-%d %H:%M:%S")
                        },
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                    }
                }

                local payload = json.encode({ embeds = embed })

                PerformHttpRequest(webhook.url, function(statusCode, responseText, headers)
                    if statusCode ~= 200 and statusCode ~= 204 then
                        DebugLog('^1[Xeno-AdminMenu] Webhook failed ('..tostring(statusCode)..'): '..tostring(webhook.name)..'^0')
                    end
                end, 'POST', payload, { ['Content-Type'] = 'application/json' })
            end
        end
    end)
end




function AddLog(logType, message, adminName, targetName, details, discordEventOverride)
    local detailsJson = details and json.encode(details) or "{}"

    exports.oxmysql:execute(
        'INSERT INTO xeno_admin_logs (type, message, admin_name, target_name, details) VALUES (?, ?, ?, ?, ?)',
        { logType, message, adminName or "", targetName or "", detailsJson }
    )

    
    local eventMap = {
        admin   = 'admin_action',
        player  = 'player_join',
        ban     = 'player_ban',
        kick    = 'player_kick',
        system  = 'system_alert',
        staff   = 'staff_added',
        group   = 'group_created',
        weather = 'weather_change',
        report  = 'report_action',
        item    = 'give_item'
    }

    local discordEvent = discordEventOverride or eventMap[logType] or 'system_alert'
    if discordEvent == 'skip' then return end

    local discordColor = COLORS[logType] or COLORS.info

    local fields = {}
    if adminName then
        table.insert(fields, { name = "Admin", value = adminName, inline = true })
    end
    if targetName then
        table.insert(fields, { name = "Target", value = targetName, inline = true })
    end

    SendDiscordWebhook(discordEvent, "📋 " .. (logType:upper()) .. " Log", message, discordColor, fields)
end






RegisterNetEvent('xeno-adminmenu:server:RequestWebhooks', function(targetSrc)
    local src = targetSrc or source
    if not IsPlayerAdmin(src) then return end

    exports.oxmysql:execute('SELECT * FROM xeno_admin_webhooks', {}, function(result)
        if result then
            for i = 1, #result do
                if type(result[i].events) == "string" then
                    result[i].events = json.decode(result[i].events) or {}
                else
                    result[i].events = result[i].events or {}
                end
                if result[i].is_active == nil then
                    result[i].isActive = true
                else
                    result[i].isActive = (result[i].is_active == 1 or result[i].is_active == true)
                end
            end
            TriggerClientEvent('xeno-adminmenu:client:ReceiveWebhooks', src, result)
        end
    end)
end)


RegisterNetEvent('xeno-adminmenu:server:SaveWebhook', function(webhookData)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local eventsJson = json.encode(webhookData.events or {})

    if webhookData.id and type(webhookData.id) == "number" then
        exports.oxmysql:execute(
            'UPDATE xeno_admin_webhooks SET name = ?, url = ?, events = ?, description = ?, is_active = ? WHERE id = ?',
            { webhookData.name, webhookData.url, eventsJson, webhookData.description or "", webhookData.isActive and 1 or 0, webhookData.id },
            function()
                TriggerEvent('xeno-adminmenu:server:RequestWebhooks', src)
                AddLog('admin', 'Updated webhook: ' .. webhookData.name, GetPlayerName(src), nil, nil)
            end
        )
    else
        exports.oxmysql:execute(
            'INSERT INTO xeno_admin_webhooks (name, url, events, description, is_active) VALUES (?, ?, ?, ?, ?)',
            { webhookData.name, webhookData.url, eventsJson, webhookData.description or "", (webhookData.isActive ~= false) and 1 or 0 },
            function()
                TriggerEvent('xeno-adminmenu:server:RequestWebhooks', src)
                AddLog('admin', 'Created webhook: ' .. webhookData.name, GetPlayerName(src), nil, nil)
            end
        )
    end
end)


RegisterNetEvent('xeno-adminmenu:server:DeleteWebhook', function(webhookId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    exports.oxmysql:execute('DELETE FROM xeno_admin_webhooks WHERE id = ?', { webhookId }, function()
        TriggerEvent('xeno-adminmenu:server:RequestWebhooks', src)
        AddLog('admin', 'Deleted a webhook', GetPlayerName(src), nil, nil)
    end)
end)


RegisterNetEvent('xeno-adminmenu:server:ToggleWebhook', function(webhookId, isActive)
    local src = source
    if not IsPlayerAdmin(src) then return end

    exports.oxmysql:execute('UPDATE xeno_admin_webhooks SET is_active = ? WHERE id = ?',
        { isActive and 1 or 0, webhookId },
        function()
            TriggerEvent('xeno-adminmenu:server:RequestWebhooks', src)
        end
    )
end)


RegisterNetEvent('xeno-adminmenu:server:TestWebhook', function(webhookUrl)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local embed = {
        {
            title = "✅ Webhook Test Successful",
            description = "This is a test message from **Xeno Admin Menu**.\nIf you see this, your webhook is working correctly!",
            color = COLORS.success,
            footer = {
                text = "Xeno Admin Menu • " .. os.date("%Y-%m-%d %H:%M:%S")
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(webhookUrl, function(statusCode)
        if statusCode == 200 or statusCode == 204 then
            TriggerClientEvent('xeno-adminmenu:client:WebhookTestResult', src, true)
        else
            TriggerClientEvent('xeno-adminmenu:client:WebhookTestResult', src, false)
        end
    end, 'POST', json.encode({ embeds = embed }), { ['Content-Type'] = 'application/json' })
end)






RegisterNetEvent('xeno-adminmenu:server:RequestLogs', function(filter, page)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local limit = 50
    local offset = ((page or 1) - 1) * limit

    local query = 'SELECT * FROM xeno_admin_logs'
    local params = {}

    if filter and filter ~= '' and filter ~= 'all' then
        query = query .. ' WHERE type = ?'
        table.insert(params, filter)
    end

    query = query .. ' ORDER BY created_at DESC LIMIT ? OFFSET ?'
    table.insert(params, limit)
    table.insert(params, offset)

    exports.oxmysql:execute(query, params, function(result)
        if result then
            for i = 1, #result do
                if type(result[i].details) == "string" then
                    result[i].details = json.decode(result[i].details)
                end
            end
            TriggerClientEvent('xeno-adminmenu:client:ReceiveLogs', src, result, page or 1)
        end
    end)
end)


RegisterNetEvent('xeno-adminmenu:server:ClearLogs', function()
    local src = source
    if not IsPlayerAdmin(src) then return end

    exports.oxmysql:execute('DELETE FROM xeno_admin_logs', {}, function()
        TriggerEvent('xeno-adminmenu:server:RequestLogs')
        AddLog('admin', 'Cleared all logs', GetPlayerName(src), nil, nil)
    end)
end)




AddEventHandler('playerJoining', function()
    local src = source
    local name = GetPlayerName(src)
    AddLog('player', name .. ' joined the server', nil, name, { src = tostring(src) }, 'player_join')
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src)
    AddLog('player', name .. ' left the server (' .. tostring(reason) .. ')', nil, name, { reason = reason }, 'player_leave')
end)
