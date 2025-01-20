fx_version 'cerulean'

game 'gta5'

author 'void'
version '1.0.0'

lua54 'yes'

client_scripts {
	'@qbx_core/modules/playerdata.lua',
	'client/**',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/**',
	'framework/db.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
	-- 'shared/**',
}

files {
	-- 'config/client.lua',
	'config/shared.lua',
}
