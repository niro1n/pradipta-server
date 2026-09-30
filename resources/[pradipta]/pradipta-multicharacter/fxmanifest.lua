fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'NIRO1N'
description 'Allows players to create multiple characters'
version '1.5.0'

shared_scripts {
    '@pradipta-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/reset.css',
    'html/vue.js',
    'html/swal2.js',
    'html/profanity.js',
    'html/translations.js',
    'html/validation.js',
    'html/app.js',
    'html/assets/**'
}

dependencies {
    'pradipta-core',
    'pradipta-spawn'
}
