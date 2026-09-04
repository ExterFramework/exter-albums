fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'sobing'
description 'exter-albums — universal photo album/camera/drone script (ESX / QBCore / QBox / standalone, any inventory)'
version '2.0.0'

ui_page 'nui/index.html'

shared_scripts {
    'config.lua',
}

client_scripts {
    'bridge/client.lua',
    'client.lua',
}

server_scripts {
    'bridge/server.lua',
    'server.lua',
}

files {
    'nui/index.html',
    'nui/*.png',
    'img/*.png',
    'img/*.gif',
    'img/*.svg',
    'nui/images/*.*',
    'nui/fonts/*.*',
    'nui/*.jpeg',
    'nui/style.css',
    'nui/js.js',
}
