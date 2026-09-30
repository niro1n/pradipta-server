fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Provides the logic for handling cryptocurrency aka pradiptait'
version '1.2.1'

shared_scripts {
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
client_script 'client.lua'

dependency 'pradipta-minigames'
