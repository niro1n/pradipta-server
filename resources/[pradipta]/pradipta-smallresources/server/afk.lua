RegisterNetEvent('KickForAFK', function()
    DropPlayer(source, Lang:t('afk.kick_message'))
end)

PradiptaCore.Functions.CreateCallback('pradipta-afkkick:server:GetPermissions', function(source, cb)
    cb(PradiptaCore.Functions.GetPermission(source))
end)
