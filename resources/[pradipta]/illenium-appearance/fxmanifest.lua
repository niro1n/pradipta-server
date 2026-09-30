fx_version "cerulean"
game "gta5"
author 'NIRO1N'
description "A flexible player customization script for FiveM servers."
repository "https://github.com/iLLeniumStudios/illenium-appearance"
version "main"

lua54 "yes"

client_scripts {
  "game/constants.lua",
  "game/util.lua",
  "game/customization.lua",
  "game/nui.lua",
  "client/outfits.lua",
  "client/common.lua",
  "client/zones.lua",
  "client/framework/framework.lua",
  "client/framework/pradipta/compatibility.lua",
  "client/framework/pradipta/main.lua",
  "client/framework/pradipta/migrate.lua",
  "client/framework/esx/compatibility.lua",
  "client/framework/esx/main.lua",
  "client/framework/ox/main.lua",
  "client/target/target.lua",
  "client/target/pradipta.lua",
  "client/target/ox.lua",
  "client/management/management.lua",
  "client/management/common.lua",
  "client/management/pradipta.lua",
  "client/management/pradiptax.lua",
  "client/management/esx.lua",
  "client/radial/radial.lua",
  "client/radial/pradipta.lua",
  "client/radial/ox.lua",
  "client/stats.lua",
  "client/defaults.lua",
  "client/blips.lua",
  "client/props.lua",
  "client/client.lua",
}

server_scripts {
  "@oxmysql/lib/MySQL.lua",
  "server/database/database.lua",
  "server/database/jobgrades.lua",
  "server/database/managementoutfits.lua",
  "server/database/playeroutfitcodes.lua",
  "server/database/playeroutfits.lua",
  "server/database/players.lua",
  "server/database/playerskins.lua",
  "server/database/users.lua",
  "server/framework/pradipta/main.lua",
  "server/framework/pradipta/migrate.lua",
  "server/framework/esx/main.lua",
  "server/framework/esx/migrate.lua",
  "server/framework/esx/callbacks.lua",
  "server/framework/esx/management.lua",
  "server/framework/ox/main.lua",
  "server/util.lua",
  "server/server.lua",
  "server/permissions.lua"
}

shared_scripts {
  "shared/config.lua",
  "shared/blacklist.lua",
  "shared/peds.lua",
  "shared/tattoos.lua",
  "shared/theme.lua",
  "shared/framework/framework.lua",
  "shared/framework/esx/util.lua",
  "locales/locales.lua",
  "locales/ar.lua",
  "locales/bg.lua",
  "locales/cs.lua",
  "locales/de.lua",
  "locales/en.lua",
  "locales/es-ES.lua",
  "locales/fr.lua",
  "locales/hu.lua",
  "locales/it.lua",
  "locales/nl.lua",
  "locales/pt-BR.lua",
  "locales/ro-RO.lua",
  "locales/id.lua",
  "@ox_lib/init.lua"
}

files {
  "web/dist/index.html",
  "web/dist/assets/*.js"
}

ui_page "web/dist/index.html"
