fx_version 'cerulean'
game 'gta5'

author 'FiveM Developer'
description 'Professional Dispatch, MDT, Police Job & Jail System'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locale.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    'server/main.lua',
    'server/dispatch.lua',
    'server/mdt.lua',
    'server/police.lua',
    'server/jail.lua'
}

client_scripts {
    '@es_extended/imports.lua',
    'client/main.lua',
    'client/dispatch.lua',
    'client/mdt.lua',
    'client/police.lua',
    'client/jail.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/mdt.js',
    'html/js/dispatch.js'
}

exports {
    'getPoliceCount',
    'setPlayerWanted',
    'getPlayerWanted',
    'jailPlayer',
    'unjailPlayer',
    'createDispatch'
}

dependencies {
    'es_extended',
    'ox_lib'
}
