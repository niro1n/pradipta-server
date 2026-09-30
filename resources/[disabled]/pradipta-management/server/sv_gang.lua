local PradiptaCore = exports['pradipta-core']:GetCoreObject({ 'Functions' })

-- Get Employees
PradiptaCore.Functions.CreateCallback('pradipta-gangmenu:server:GetEmployees', function(source, cb, gangname)
	local src = source
	local Player = exports['pradipta-core']:GetPlayer(src)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'GetEmployees Exploiting')
		return
	end

	local employees = {}
	local players = MySQL.query.await("SELECT * FROM `players` WHERE `gang` LIKE '%" .. gangname .. "%'", {})
	if players[1] ~= nil then
		for _, value in pairs(players) do
			local Target = PradiptaCore.Functions.GetPlayerByCitizenId(value.citizenid) or PradiptaCore.Functions.GetOfflinePlayerByCitizenId(value.citizenid)

			if Target then
				local isOnline = Target.PlayerData.source
				employees[#employees + 1] = {
					empSource = Target.PlayerData.citizenid,
					grade = Target.PlayerData.gang.grade,
					isboss = Target.PlayerData.gang.isboss,
					name = (isOnline and '🟢 ' or '❌ ') .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname
				}
			end
		end
	end
	cb(employees)
end)

RegisterNetEvent('pradipta-gangmenu:server:stash', function()
	local src = source
	local Player = exports['pradipta-core']:GetPlayer(src)
	if not Player then return end
	local playerGang = Player.PlayerData.gang
	if not playerGang.isboss then return end
	local playerPed = GetPlayerPed(src)
	local playerCoords = GetEntityCoords(playerPed)
	if not Config.GangMenus[playerGang.name] then return end
	local bossCoords = Config.GangMenus[playerGang.name]
	for i = 1, #bossCoords do
		local coords = bossCoords[i]
		if #(playerCoords - coords) < 2.5 then
			local stashName = 'boss_' .. playerGang.name
			exports['pradipta-inventory']:OpenInventory(src, stashName, {
				maxweight = 4000000,
				slots = 25,
			})
			return
		end
	end
end)

-- Grade Change
RegisterNetEvent('pradipta-gangmenu:server:GradeUpdate', function(data)
	local src = source
	local Player = exports['pradipta-core']:GetPlayer(src)
	local Employee = PradiptaCore.Functions.GetPlayerByCitizenId(data.cid) or PradiptaCore.Functions.GetOfflinePlayerByCitizenId(data.cid)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'GradeUpdate Exploiting')
		return
	end
	if data.grade > Player.PlayerData.gang.grade.level then
		TriggerClientEvent('PradiptaCore:Notify', src, 'You cannot promote to this rank!', 'error')
		return
	end

	if Employee then
		if Employee.Functions.SetGang(Player.PlayerData.gang.name, data.grade) then
			TriggerClientEvent('PradiptaCore:Notify', src, 'Successfully promoted!', 'success')
			Employee.Functions.Save()

			if Employee.PlayerData.source then
				TriggerClientEvent('PradiptaCore:Notify', Employee.PlayerData.source, 'You have been promoted to ' .. data.gradename .. '.', 'success')
			end
		else
			TriggerClientEvent('PradiptaCore:Notify', src, 'Grade does not exist.', 'error')
		end
	end
	TriggerClientEvent('pradipta-gangmenu:client:OpenMenu', src)
end)

-- Fire Member
RegisterNetEvent('pradipta-gangmenu:server:FireMember', function(target)
	local src = source
	local Player = exports['pradipta-core']:GetPlayer(src)
	local Employee = PradiptaCore.Functions.GetPlayerByCitizenId(target) or PradiptaCore.Functions.GetOfflinePlayerByCitizenId(target)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'FireEmployee Exploiting')
		return
	end

	if Employee then
		if target == Player.PlayerData.citizenid then
			TriggerClientEvent('PradiptaCore:Notify', src, 'You can\'t kick yourself out of the gang!', 'error')
			return
		elseif Employee.PlayerData.gang.grade.level > Player.PlayerData.gang.grade.level then
			TriggerClientEvent('PradiptaCore:Notify', src, 'You cannot fire this citizen!', 'error')
			return
		end
		if Employee.Functions.SetGang('none', '0') then
			Employee.Functions.Save()
			TriggerEvent('pradipta-log:server:CreateLog', 'gangmenu', 'Gang Fire', 'orange', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.gang.name .. ')', false)
			TriggerClientEvent('PradiptaCore:Notify', src, 'Gang Member fired!', 'success')

			if Employee.PlayerData.source then -- Player is online
				TriggerClientEvent('PradiptaCore:Notify', Employee.PlayerData.source, 'You have been expelled from the gang!', 'error')
			end
		else
			TriggerClientEvent('PradiptaCore:Notify', src, 'Error.', 'error')
		end
	end
	TriggerClientEvent('pradipta-gangmenu:client:OpenMenu', src)
end)

-- Recruit Player
RegisterNetEvent('pradipta-gangmenu:server:HireMember', function(recruit)
	local src = source
	local Player = exports['pradipta-core']:GetPlayer(src)
	local Target = exports['pradipta-core']:GetPlayer(recruit)

	if not Player.PlayerData.gang.isboss then
		ExploitBan(src, 'HireEmployee Exploiting')
		return
	end

	if Target and Target.Functions.SetGang(Player.PlayerData.gang.name, 0) then
		TriggerClientEvent('PradiptaCore:Notify', src, 'You hired ' .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' come ' .. Player.PlayerData.gang.label .. '', 'success')
		TriggerClientEvent('PradiptaCore:Notify', Target.PlayerData.source, 'You have been hired as ' .. Player.PlayerData.gang.label .. '', 'success')
		TriggerEvent('pradipta-log:server:CreateLog', 'gangmenu', 'Recruit', 'yellow', (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname) .. ' successfully recruited ' .. Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.gang.name .. ')', false)
	end
	TriggerClientEvent('pradipta-gangmenu:client:OpenMenu', src)
end)

-- Get closest player sv
PradiptaCore.Functions.CreateCallback('pradipta-gangmenu:getplayers', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for _, v in pairs(PradiptaCore.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = exports['pradipta-core']:GetPlayer(v)
			players[#players + 1] = {
				id = v,
				coords = GetEntityCoords(targetped),
				name = ped.PlayerData.charinfo.firstname .. ' ' .. ped.PlayerData.charinfo.lastname,
				citizenid = ped.PlayerData.citizenid,
				sources = GetPlayerPed(ped.PlayerData.source),
				sourceplayer = ped.PlayerData.source
			}
		end
	end
	table.sort(players, function(a, b)
		return a.name < b.name
	end)
	cb(players)
end)
