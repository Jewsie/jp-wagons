resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
fx_version 'cerulean'
game 'rdr3'

description 'A robbery script for SynthesisRP'

author 'Jack P'

escrow_ignore {
    'config.lua',
    'client/*.lua',
    'server/*.lua'
}

shared_script 'config.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
client_scripts {
    '@menuv/menuv.lua',
    'client/*.lua'
}

lua54 'yes'