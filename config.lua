Config = {}

Config.loadskin = "loadskin" -- command name to reset the player skin (depends on the framework ?)
-- vorp = rc ?

Config.command = "pedmenu" -- command to display the menu with the ped's list
Config.spawnped = "spawnped" -- command to spawn a ped with the nickname in parameter

Config.steamIdList = { -- steamId list that can use /Config.command and /Config.spawnped
-- TODO
}

-- Dynamic paths configuration
Config.resourceName = GetCurrentResourceName() -- Get the actual resource name dynamically
Config.resourcePath = "resources/" .. Config.resourceName .. "/"

-- Directory paths (relative to resource root)
Config.paths = {
    fileXml = Config.resourcePath .. "file_xml/",
    listLua = Config.resourcePath .. "list_lua/",
    listPed = Config.resourcePath .. "list_ped/",
    listVarPed = Config.resourcePath .. "list_var_ped/",
    
    -- Files
    listVarPedJs = Config.resourcePath .. "list_var_ped.js"
}