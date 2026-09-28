fx_version 'cerulean'
game 'gta5'

author 'niro1n'
description 'Pradipta Administrative Console'

version '4.0.0'

dependencies {
    'oxmysql'
}

escrow_ignore {
    'shared/*.lua',
    'translation.lua',
    'client/*.lua',
    'client/modules/*.lua',
    'server/framework.lua',
    'server/database.lua',
    'server/modules/*.lua',
    'server/api/*.lua',
    'server/main.lua'
}

ui_page 'web/dist/index.html'

shared_scripts {
    'shared/*.lua',
    'translation.lua'
}

client_scripts {
    'client/*.lua',
    'client/modules/*.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/config.lua',
    'server/framework.lua',
    'server/database.lua',
    'server/modules/permission_manager.lua',
    'server/modules/registration.lua',
    'server/api/*.lua',
    'server/modules/inventory.lua',
    'server/modules/players.lua',
    'server/modules/actions.lua',
    'server/modules/bans.lua',
    'server/modules/weathersync.lua',
    'server/modules/permissions.lua',
    'server/modules/webhooks.lua',
    'server/main.lua'
}

files {
    'web/dist/index.html',
    'web/dist/assets/*.js',
    'web/dist/assets/*.css',
    'web/dist/assets/*.png',
    'web/dist/assets/*.jpg',
    'web/dist/assets/*.svg',
    'web/dist/assets/*.wav'
}

server_exports {
    'GetWeather',
    'SetWeather',
    'GetTime',
    'SetTime',
    'GetState',
    'IsBlackout',
    'SetBlackout',
    'IsAdmin',
    'HasPermission',
    'GetStaff',
    'GetGroup'
}