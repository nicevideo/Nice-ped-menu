fx_version "adamant"
games {'rdr3'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'NiceTV / https://discord.com/channels/906822115024597042/ / https://github.com/nicevideo?tab=repositories / https://www.youtube.com/@nicevideo2017/videos'
description 'use ped (reload debug)'
version '1.0.0'

shared_scripts {
	'config.lua',
	'slaxml.lua',
	'peds_humans.lua'
}

client_scripts {
	'cl_functions_ped.lua',
	'cl_functions.lua',
	'client.lua'
}

server_scripts {
	'sv_functions.lua',
	'sv_functions_generate_top.lua',
	'server.lua',
	'file_xml/*.xml'
}

files {
	'html/index.html',
	'html/loupe.png',
	'html/picture/*.png',
	'html/j.js',
	'html/tab_female.js',
	'html/tab_male.js'
}

ui_page "html/index.html"