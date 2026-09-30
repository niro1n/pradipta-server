fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Allows players to deliver packages and sell drugs to npcs'
version '1.3.0'

shared_scripts {
    'config.lua',
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/deliveries.lua',
    'client/cornerselling.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/deliveries.lua',
    'server/cornerselling.lua'
}
