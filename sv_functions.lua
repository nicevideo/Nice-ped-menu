--[[
function getSteamId()
  local identifiers = GetPlayerIdentifiers(source)

  for _, v in ipairs(identifiers) do
    if string.match(v, "steam") then return v end

    -- if string.match(v, "license:") then return v end
    -- if string.match(v, "discord") then return v end
    -- if string.match(v, "fivem") then return v end
    -- if string.match(v, "ip") then return v end
  end

  return nil
end
]]
----
-- functions files

function parseXML(inputXML)
    local stack = {}
    local current

    local parser = SLAXML:parser { -- to create the lua array
        startElement = function(name, nsURI, nsPrefix)
            local newElement = {attr = {}, children = {}}
            if current then
                if not current.children[name] then
                    current.children[name] = {}
                end
                table.insert(current.children[name], newElement)
                table.insert(stack, current)
            end
            current = newElement
        end,
        attribute = function(name, value, nsURI, nsPrefix)
            current.attr[name] = value
        end,
        text = function(text)
            text = text:match("^%s*(.-)%s*$")  -- trim whitespace
            if #text > 0 then current.value = text end
        end,
        closeElement = function(name, nsURI)
            if #stack > 0 then current = table.remove(stack) end
        end
    }

    parser:parse(inputXML)

    return current
end

function convertToFilteredJSON(node)
    local obj = {}
    for name, elements in pairs(node.children) do
      obj[name] = {}
      for _, element in ipairs(elements) do
        local childObj = {attr = element.attr}
        if element.value then
          childObj.value = element.value
        end
        if next(element.children) then
          childObj.children = convertToFilteredJSON(element)
        end
        table.insert(obj[name], childObj)
      end
    end
    return obj
end

function serialize(o)
    if type(o) == "number" then return tostring(o)
    elseif type(o) == "string" then return string.format("%q", o)
    elseif type(o) == "table" then
      local s = "{"
      for k, v in pairs(o) do
        -- k = type(k) == "string" and string.format("[%q]", k) or k
        -- s = s .. string.format("%s=%s,", k, serialize(v))

        k = type(k) == "number" and string.format("[%s]", k) or string.format("[%q]", k)
        s = s .. string.format("%s=%s,", k, serialize(v))

        -- k = type(k) == "number" and string.format('["%s"]', k) or string.format("[%q]", k)
        -- s = s .. string.format("%s=%s,", k, serialize(v))
      end
      return s .. "}"
    else error("cannot serialize a " .. type(o))
    end
end

function GetValue(filename) -- retrieve the information from the file containing the LUA TABLE
    local file = io.open(filename, "r")
    local xmlContent
    if file ~= nil then
      xmlContent = file:read("*all")
      file:close()
    else print(filename .. " not find") return nil
    end

    local f = load(xmlContent) -- local l = 'return {["outfits"]={[1]={["attr"]={["itemType"]="MetaPedOutfit"}}}}' -- xmlContent
    return f() -- BUG : attempt to call a string value (local 'f')
end

---------------------------------------------------------------------------

function listAllFilesInDir(dir) -- list directory's files
    local files = {}
    local cpt = 0
    for fi in io.popen('dir resources\\nice_ped\\'..dir..' /b'):lines() do -- 'dir resources\\nice_ped\\list_lua /b'
      cpt = cpt + 1
      files[cpt] = fi -- table.insert(files, fi)
    end

    local s = cpt -- #files

    local content, f, tab

    for i = 1, s do -- for _, file_name in ipairs(files) do
        content = ReadFile("resources/nice_ped/list_lua/" .. files[i])

        f = load(content)
        tab = f()
        -- print(dump(tab))
        -- GetValue("resources/nice_ped/list_lua/" .. files[i])
    end
end

--[[
function ListLua() -- retrieve the peds from a LUA TABLE
  local files = {}
  files = listAllFilesInDir("list_lua")

  local tab = {}
  for _, file_name in ipairs(files) do
    tab = GetValue("resources/nice_ped/list_lua/" .. file_name)
    -- script
  end
end
]]

function infoOneFile(file_name)
  local content = ReadFile("resources/nice_ped/list_lua/" .. file_name)

  local f = load(content)
  local tab = f()
end

---------------------------------------------------------------------------

function createAllVarFiles() -- just get the number of variations and store it in a JS file
  local files = {}
  for fi in io.popen('dir resources\\nice_ped\\list_lua /b'):lines() do
    if WithoutExtension(fi) ~= fi then -- don't take directories
      table.insert(files, fi)
    end
  end

  local list_js = {}
  local cpt_list_js = 0
  local nbr = 0
  local list

  for _, file_name in ipairs(files) do nbr = 0
    list = GetValue("resources/nice_ped/list_lua/" .. file_name)
    if list == nil then -- print(file_name .. " nil")
    else
      for _, outfit in pairs(list.outfits) do
        if type(outfit.children.Item) == 'table' then nbr = #outfit.children.Item
          cpt_list_js = cpt_list_js + 1
          list_js[cpt_list_js] = { name = WithoutExtension(file_name), nbr = nbr }
        end
      end
    end
  end

  local s_js = luaTableToJsString(list_js)
  WriteFile({ filename = "resources/nice_ped/list_var_ped.js", content = s_js })
end

function luaTableToJsString(luaTable)
  local jsArray = {}
  local key, value

  for _, obj in ipairs(luaTable) do
    key = obj["name"]
    value = obj["nbr"]
    table.insert(jsArray, "  \"" .. key .. "\" : " .. value)
  end

  local jsString = "let tab = {\n" .. table.concat(jsArray, ",\n") .. "\n}"

  return jsString
end

function nbrOccurence(str, search)
  local _, nbr = string.gsub(string.lower(str), search, "")
  return nbr
end

---------------------------------------------------------------------------

function generate_js_tab(args)
--[[
  let tab = [
    { name: "User1", group: "A" },
    { name: "User2", group: "B" }
  ];
]]
  local list = {}
  list = args.list
  local s = #list
  local group = args.group or ""
  local string_js = ""
  string_js = string_js .. "let tab = ["

  for i = 1, s do
    string_js = string_js .. "{ name: '"..list[i].."', group: '"..group.."' },"
  end
  string_js = string_js .. "];"

  return string_js
end

function WithoutExtension(nom)
  return string.match(nom, "(.-)%.")
end

function sv_generate_file_list_ped(args) -- generate multi-page ped groups
  local list = {}
  local cpt = 0

  local tab_group = { "male", "female", "teen" }
  local group = args["group"] or "male"
  if not in_array(group, tab_group) then return end

  for fi_male in io.popen('dir resources\\nice_ped\\list_lua\\'.. group ..' /b'):lines() do -- 'dir resources\\nice_ped\\list_lua /b'
    cpt = cpt + 1
    list[cpt] = WithoutExtension(fi_male) -- string.match(fi_male, "(.-)%.") -- sans extension
  end

  table.sort(list) -- trier par ordre alphabétique le tableau list

  local html = ""

  local page = 1 -- CONST
  local elInThisPage = 0 -- CONST

  local nbrPedByPage = args["nbrPedByPage"] or 50

  for _, nom_fichier in pairs(list) do
    html = html .. "<div class='image-item' data-name='"..nom_fichier.."'><img src='"..nom_fichier.."_1.jpg' alt='"..nom_fichier.."'><div class='image-name'>"..nom_fichier.."</div></div>"

    elInThisPage = elInThisPage + 1
    if elInThisPage > nbrPedByPage then
      -- WriteFile({ filename = "resources/nice_ped/list_ped/"..group.."_"..page..".txt", content = html })
      page = page + 1
      elInThisPage = 0
      html = ""
    end
  end

  if elInThisPage > 0 then
    -- WriteFile({ filename = "resources/nice_ped/list_ped/"..group.."_"..page..".txt", content = html })
  end

  local tab_js = generate_js_tab({ list = list, group = group})
  WriteFile({ filename = "resources/nice_ped/list_ped/tab_"..group..".js", content = tab_js })
end

--[[
function sv_generate_file_list_var_ped(args) -- generate a page of all the variations of a ped
  local list = {}
  list = args["files"]

  local html = ""
  local file_write

  table.sort(list) -- trier par ordre alphabétique le tableau list

  local nbr = 0

  for _, outfit in pairs(list.children.outfits) do
    if type(outfit.children.Item) == 'table' then nbr = nbr + #outfit.children.Item end
  end

  for _, nom_fichier in pairs(list) do nbr = 0
    for _, outfit in pairs(list.children.outfits) do
      if type(outfit.children.Item) == 'table' then nbr = nbr + #outfit.children.Item end
    end

    html = ""
    html = html .. "<div class='image-item' data-name='"..nom_fichier.."'><img src='"..nom_fichier.."_"..nbr..".jpg' alt='"..nom_fichier.."'><div class='image-name'>"..nom_fichier.."</div></div>"

    WriteFile({ filename = "resources/nice_ped/list_var_ped/"..nom_fichier..".txt", content = html })
  end
end
]]

---------------------------------------------------------------------------

function ReadFile(filename)
  local file = io.open(filename, "r") -- r = read
  if not file then print(filename .. " not file") return nil end

  local content = file:read("*all") -- Reads the entire contents of the file
  file:close()

  return content
end

function WriteFile(args)
  local file_write = io.open(args.filename, "w") or nil -- local f = assert(io.open(filename, "r"))
  if file_write ~= nil then
    file_write:write(args.content)
    file_write:close()
  end
end

function displayTableDifferences(table1, table2)
  local diff = {}
  for key, value in pairs(table1) do
    if not table2[key] then table.insert(diff, key) end
  end

  for key, value in pairs(table2) do
    if not table1[key] then table.insert(diff, key) end
  end

  print("Table differences:")
  for _, key in ipairs(diff) do print(key) end
end

function extractVariables(xmlContent, hierarchy) -- Function for extracting variables from XML according to the specified hierarchy
    local variables = {} -- Table for storing extracted variables
    local currentXML = xmlContent

    for _, node in ipairs(hierarchy) do
        local nodeName, attribute = node:match("([^%[]+)%[?([^%]]*)%]?") -- Extracts the node name and attribute (if any)
        if nodeName and currentXML then -- print("nodeName and currentXML : " .. nodeName)
            -- print("attribute : " .. attribute)

            -- Extracts values from the current node
            local nodeValues = {}
            for value in currentXML:gmatch("<"..nodeName.."%s-"..attribute.."%s-=%s-\"(.-)\"%s->.-</"..nodeName..">") do print("currentXML:gmatch")
                table.insert(nodeValues, value)
            end

            -- Stores extracted values
            if #nodeValues > 0 then -- print("nodeValues > 0")
                variables[nodeName] = nodeValues
            end

            -- Updates the current XML for the next node
            currentXML = currentXML:match("<"..nodeName.."%s-"..attribute.."%s-=%s-\".-\"%s->(.-)</"..nodeName..">")
        else print("not good") return nil
        end
    end

    return variables
end

function in_array(val, tab)
    for _, value in ipairs(tab) do
        if value == val then return true end
    end

    return false
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else return tostring(o)
    end
end