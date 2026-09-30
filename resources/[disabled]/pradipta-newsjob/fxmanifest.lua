fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Allows players to play as a news reporter and access the equipment for it'
version '1.5.0'

shared_scripts {
    'config.lua',
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
}

client_scripts {
    'client/main.lua',
    'client/spawner.lua',
    'client/camera.lua',
}

server_script 'server/main.lua'
