fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Syncs the time & weather for all players on the server and allows editing by command'
version '2.3.0'

shared_scripts {
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

server_script 'server.lua'
client_script 'client.lua'
