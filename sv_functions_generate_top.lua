-- generate large files

-- create 1430 files
function createAllFiles() -- +- 40 sec.
    -- retrieve file's list in the ‘resources/nice_ped/file_xml/’ directory
    local files = {}

    local cpt = 0
    for fi in io.popen('dir resources\\nice_ped\\file_xml /b'):lines() do -- print("file or directory: " .. fi)
      cpt = cpt + 1
      files[cpt] = fi -- table.insert(files, fi)
    end

    local s = cpt -- #files
    local file, content, current, structuredData, luaTableString, file_name, path, file2

    for i = 1, s do -- for _, file_name in ipairs(files) do
        file = io.open("resources/nice_ped/file_xml/" .. files[i], "r") -- local file = io.open("resources/nice_ped/file_xml/a_m_y_asbminer_03.xml", "r")
        content = file:read("*all")

        current = parseXML(content) -- print("current : " .. current)

        structuredData = convertToFilteredJSON(current) -- convert the file into a lua array -- print("structuredData : " .. structuredData)

        luaTableString = "return " .. serialize(structuredData) -- print("luaTableString : " .. luaTableString)

        file_name = string.match(files[i], "(.-)%.") -- create a variable but keep only what is before the first dot (.) -- local file_name = string.gsub(files[i], ".xml", "")

        path = "resources/nice_ped/list_lua/"..file_name..".txt"

        -- WriteFile
        file2 = io.open(path, "w")
        file2:write(luaTableString)
        file2:close()

        -- print("save ok : "..file_name..".txt")
    end
    print("createAllFiles() ok")
  end

  ---------------------------------------------

function createGroupFiles() -- list_lua/male/ list_lua/female/ list_lua/teen/

    local files = {}
    local cpt = 0
    for fi in io.popen('dir resources\\nice_ped\\list_lua /b'):lines() do
      cpt = cpt + 1
      files[cpt] = fi -- table.insert(files, fi)
    end

    local s = cpt -- #files

    local file_name_without_extension, content, nbr_mpt_male, nbr_mpt_female, nbr_mpt_teen, group_dir

    for i = 1, s do -- for _, file_name in ipairs(files) do
      content = LireFichier("resources/nice_ped/list_lua/" .. files[i])

      if content ~= nil then file_name_without_extension = string.match(files[i], "(.-)%.")
        -- retrieve ped TYPE (male, female, ...)
        -- count how many times ‘content’ contains the string ‘MPT_FEMALE’
        nbr_mpt_male = nbrOccurence(content, "mpt_male")
        if nbr_mpt_male > 1 then return print(file_name_without_extension .." has "..nbr_mpt_male.." mpt_male") end
        nbr_mpt_female = nbrOccurence(content, "mpt_female")
        if nbr_mpt_female > 1 then return print(file_name_without_extension .." has "..nbr_mpt_female.." mpt_female") end
        nbr_mpt_teen = nbrOccurence(content, "mpt_teen")
        if nbr_mpt_teen > 1 then return print(file_name_without_extension .." has "..nbr_mpt_teen.." mpt_teen") end

        if nbr_mpt_male == 1 then group_dir = "/male"
        elseif nbr_mpt_female == 1 then group_dir = "/female"
        elseif nbr_mpt_teen == 1 then group_dir = "/teen"
        else return print(file_name_without_extension .." have NOT MPT")
        end

        EcrireFichier({ filename = "resources/nice_ped/list_lua"..group_dir.."/"..file_name_without_extension..".txt", content = content })
        -- print(i .. " " .. file_name_without_extension)
      -- else print("content nil : " .. files[i])
      end
    end
    print("createGroupFiles() ok")
  end