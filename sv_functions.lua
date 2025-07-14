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

function convertToFilteredJSON(parsedXML) -- filter the original large array to get only the essential
    local outfits = parsedXML.children.outfits
    local type = parsedXML.children.type

    local structuredData = {
        outfits = outfits,
        type = type,
    }

    return structuredData
end

function serialize(o) -- convert lua array to string
    if type(o) == "number" then
        return tostring(o)
    elseif type(o) == "string" then
        return string.format("%q", o)
    elseif type(o) == "table" then
        local parts = {}
        table.insert(parts, "{")
        for k, v in pairs(o) do
            local key_str
            if type(k) == "string" then
                key_str = string.format("[%q]", k)
            else
                key_str = string.format("[%s]", tostring(k))
            end
            table.insert(parts, key_str .. "=" .. serialize(v) .. ",")
        end
        table.insert(parts, "}")
        return table.concat(parts)
    else
        error("Cannot serialize a " .. type(o))
    end
end

function ReadFile(filename) -- return content from a file
    local file = io.open(filename, "r")
    if file == nil then return nil end

    local content = file:read("*all")
    file:close()

    return content
end

function GetValue(filename) -- return the lua array
    local xmlContent = ReadFile(filename)
    if xmlContent == nil then return nil end

    local f = load(xmlContent) -- local l = 'return {["outfits"]={[1]={["attr"]={["itemType"]="MetaPedOutfit"}}}}' -- xmlContent
    return f() -- BUG : attempt to call a string value (local 'f')
end

---------------------------------------------------------------------------

-- Cross-platform directory listing function
function listAllFilesInDir(dir)
    local files = {}
    local cpt = 0
    local fullPath = Config.paths.listLua
    
    -- Try to use io.popen with ls on Unix-like systems first, then fall back to Windows dir
    local command
    if os.execute("ls --version > /dev/null 2>&1") == 0 then
        -- Unix-like system (Linux/macOS)
        command = 'ls "' .. fullPath .. '"'
    else
        -- Windows system
        command = 'dir "' .. fullPath:gsub("/", "\\") .. '" /b'
    end
    
    for fi in io.popen(command):lines() do
        cpt = cpt + 1
        files[cpt] = fi
    end

    local s = cpt
    local content, f, tab

    for i = 1, s do
        local filePath = Config.paths.listLua .. files[i]
        content = ReadFile(filePath)

        f = load(content)
        tab = f()
        -- print(dump(tab))
    end
end

--[[
function ListLua() -- retrieve the peds from a LUA TABLE
  local files = {}
  files = listAllFilesInDir("list_lua")

  local tab = {}
  for _, file_name in ipairs(files) do
    local filePath = Config.paths.listLua .. file_name
    tab = GetValue(filePath)
    -- script
  end
end
]]

function infoOneFile(file_name)
  local filePath = Config.paths.listLua .. file_name
  local content = ReadFile(filePath)

  local f = load(content)
  local tab = f()
end

---------------------------------------------------------------------------

function createAllVarFiles() -- just get the number of variations and store it in a JS file
  local files = {}
  local fullPath = Config.paths.listLua
  
  -- Cross-platform directory listing
  local command
  if os.execute("ls --version > /dev/null 2>&1") == 0 then
    command = 'ls "' .. fullPath .. '"'
  else
    command = 'dir "' .. fullPath:gsub("/", "\\") .. '" /b'
  end
  
  for fi in io.popen(command):lines() do
    if WithoutExtension(fi) ~= fi then -- don't take directories
      table.insert(files, fi)
    end
  end

  local list_js = {}
  local cpt_list_js = 0
  local nbr = 0
  local list

  for _, file_name in ipairs(files) do 
    nbr = 0
    local filePath = Config.paths.listLua .. file_name
    list = GetValue(filePath)
    if list == nil then 
      -- print(file_name .. " nil")
    else
      for _, outfit in pairs(list.outfits) do
        if type(outfit.children.Item) == 'table' then 
          nbr = #outfit.children.Item
          cpt_list_js = cpt_list_js + 1
          list_js[cpt_list_js] = { name = WithoutExtension(file_name), nbr = nbr }
        end
      end
    end
  end

  local s_js = luaTableToJsString(list_js)
  WriteFile({ filename = Config.paths.listVarPedJs, content = s_js })
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

function sv_generate_file_list_ped(args) -- output : html tab_male.js
  local group = args.group -- male, female, teen
  local files = {}
  local groupPath = Config.paths.listLua .. group .. "/"
  
  -- Cross-platform directory listing
  local command
  if os.execute("ls --version > /dev/null 2>&1") == 0 then
    command = 'ls "' .. groupPath .. '"'
  else
    command = 'dir "' .. groupPath:gsub("/", "\\") .. '" /b'
  end

  for fi_male in io.popen(command):lines() do
    if WithoutExtension(fi_male) ~= fi_male then -- don't take directories
      table.insert(files, fi_male)
    end
  end

  shuffle(files) -- mélanger la liste

  local s = #files
  local tab_js = ""
  local cpt = 0
  local is_one = false

  for i = 1, s do -- for _, file_name in ipairs(files) do
    cpt = cpt + 1

    if cpt == 1 then is_one = true else is_one = false end

    tab_js = tab_js .. "" .. newTab({ file_name = WithoutExtension(files[i]), is_one = is_one, final = (i == s), group = group })

    --[[
    if cpt == 30 then -- max 30 ped par "page"
      page = page + 1
      cpt = 0
      -- WriteFile({ filename = Config.paths.listPed .. group .. "_" .. page .. ".txt", content = html })
      -- tab_js = ""
    end
    ]]
  end

  if cpt > 0 then
    -- WriteFile({ filename = Config.paths.listPed .. group .. "_" .. page .. ".txt", content = html })
    -- Close the JavaScript array
    tab_js = tab_js .. "];"
  end

  local outputFile = Config.paths.listPed .. "tab_" .. group .. ".js"
  WriteFile({ filename = outputFile, content = tab_js })
end

function newTab(args)
  local file_name = args.file_name -- nom du fichier (sans extension)
  local is_one = args.is_one -- true si c'est le premier élément
  local final = args.final -- true si c'est le dernier élément
  local group = args.group -- groupe (male, female, teen)

  local virgule = ""
  if not final then virgule = "," end

  if is_one then
    return "let tab_" .. group .. " = [\n  {\n    \"model\": \"" .. file_name .. "\",\n    \"texte\": \"" .. file_name .. "\"\n  }" .. virgule .. "\n"
  else
    return "  {\n    \"model\": \"" .. file_name .. "\",\n    \"texte\": \"" .. file_name .. "\"\n  }" .. virgule .. "\n"
  end
end

function createAllVarPedsFiles() -- create list_var_ped/nom_ped.txt (V2)
  local files = {}
  
  -- Cross-platform directory listing for each group
  local groups = {"male", "female", "teen"}
  
  for _, group in ipairs(groups) do
    local groupPath = Config.paths.listLua .. group .. "/"
    
    local command
    if os.execute("ls --version > /dev/null 2>&1") == 0 then
      command = 'ls "' .. groupPath .. '"'
    else
      command = 'dir "' .. groupPath:gsub("/", "\\") .. '" /b'
    end
    
    for fi in io.popen(command):lines() do
      if WithoutExtension(fi) ~= fi then
        local nom_fichier = WithoutExtension(fi)
        local filePath = groupPath .. fi
        local html = ReadFile(filePath)
        local outputPath = Config.paths.listVarPed .. nom_fichier .. ".txt"
        WriteFile({ filename = outputPath, content = html })
      end
    end
  end
end

function ReadFile(filename) -- return content from a file
    local file = io.open(filename, "r") -- r = read
    if file == nil then return nil end

    local content = file:read("*all")
    file:close()

    return content
end

function WriteFile(args)
    local filename = args.filename
    local content = args.content

    local file_write = io.open(filename, "w") or nil -- local f = assert(io.open(filename, "r")
    if file_write ~= nil then
        file_write:write(content)
        file_write:close()
    end
end

function WithoutExtension(file_name)
    return string.match(file_name, "(.-)%.") or file_name
end

function LireFichier(nomFichier)
    local fichier = io.open(nomFichier, "r")
    if fichier == nil then return nil end

    local contenu = fichier:read("*all")
    fichier:close()

    return contenu
end

function EcrireFichier(args)
    local nomFichier = args.filename
    local contenu = args.content

    local fichier = io.open(nomFichier, "w")
    if fichier ~= nil then
        fichier:write(contenu)
        fichier:close()
    end
end