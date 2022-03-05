-- Perek • https://linktr.ee/IamPerek --

fx_version "cerulean"
game { "gta5" }

author 'Perek'
description 'fivem-appearance to QB-Core'
repository 'www.github.com/IamPerek/prk-fivem-appearance'

shared_script 'config.lua'

client_scripts {
  'game/build/client.js',
  'client/client.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/server.lua',
  'server/version.lua',
}


files {
  'web/build/index.html',
  'web/build/static/js/*.js',
  'locales/*.json',
  'peds.json'
}

ui_page 'web/build/index.html'

provide 'qb-clothing'