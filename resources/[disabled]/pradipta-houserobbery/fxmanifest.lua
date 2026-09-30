fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Allows players to rob houses for items to sell'
version '1.5.0'

shared_scripts {
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

dependencies {
    'pradipta-minigames'
}
