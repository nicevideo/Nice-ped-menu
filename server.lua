-- first of all recreate from the XML
-- createAllFiles() -- 1

-- then create the txt files (list_lua/male female teen)
-- createGroupFiles() -- 2

-- enfin, créer les fichiers html

-- 3
-- sv_generate_file_list_ped({ group = "male" }) -- .js
-- sv_generate_file_list_ped({ group = "female" }) -- .js
-- sv_generate_file_list_ped({ group = "teen" }) -- .js
-- print("finish")

--[[
-- ped's variation (in the future, V2)
RegisterServerEvent('nice_ped:sv_getListVarPed') -- from RegisterNUICallback('getListVar')
AddEventHandler('nice_ped:sv_getListVarPed', function(args)
  local _src = source

  local name = args.name
  if string.len(name) > 50 then return print("nice_ped : ERROR name") end
  if string.find(name, "/") then return print("nice_ped : ERROR name") end

  if not in_array(name, human_peds) then return print("nice_ped : ERROR model") end -- security

  local list = {} -- ped's list

  -- récupérer la liste de ped depuis un fichier (optimisation)
  -- local contenu = GetValue("resources/nice_ped/list_ped_var/"..name..".txt")
  local contenu = ""
  local file = io.open("resources/nice_ped/list_ped_var/"..name..".txt", "r") or nil -- local f = assert(io.open(filename, "r"))
  if file ~= nil then
    contenu = file:read("*all") or {}
    file:close()
  end

  list = contenu

  TriggerClientEvent("nice_ped:cl_getListVarPed", _src, { list = list })
end)
]]

--------------------------------------------------------------------------------------------------------------

function shuffle(tbl)
  local j, s
  s = #tbl
  for i = s, 2, -1 do
    j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end

  return tbl
end

--------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent('nice_ped:sv_loadOnePed') -- load a ped (NOT variation)
AddEventHandler('nice_ped:sv_loadOnePed', function(args)
  -- TODO: security steamId

  local _src = source
  local file_name = args.pseudo

  local infos = {}
  infos = GetValue("resources/nice_ped/list_lua/" .. file_name .. ".txt")

  local list = {} -- ped's informations

  local items = {}
  items = infos.outfits[1].children.Item[1].children.explicitAssets[1].children

  list["items"] = {}
  list["items"] = items

  -- print("mpt : " .. infos.type[1].value) -- MPT_FEMALE

  TriggerClientEvent("nice_ped:cl_loadOnePed", _src, { list = list, mpt = infos.type[1].value})
end)