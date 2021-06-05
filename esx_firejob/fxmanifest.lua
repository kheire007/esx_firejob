fx_version 'cerulean'
game 'gta5'

description 'ESX Fire Job'

version '1.0.1'

server_scripts {
  '@es_extended/locale.lua',
  'locales/*.lua',
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/*.lua',
  'config.lua',
  'client/main.lua'
}

exports {
  'openFire',
  'getJob'
}
