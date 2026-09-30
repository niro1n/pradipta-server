fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Allows players to grow weed plants in their house to harvest for items to sell'
version '1.5.0'

shared_scripts {
    'config.lua',
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
