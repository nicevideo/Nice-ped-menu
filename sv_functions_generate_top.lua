-- generate large files

-- create 1430 files
function createAllFiles() -- +- 40 sec.
    -- retrieve file's list in the file_xml directory
    local files = {}
    local cpt = 0
    
    -- Cross-platform directory listing
    local xmlPath = Config.paths.fileXml
    local command
    if os.execute("ls --version > /dev/null 2>&1") == 0 then
        -- Unix-like system (Linux/macOS)
        command = 'ls "' .. xmlPath .. '"'
    else
        -- Windows system
        command = 'dir "' .. xmlPath:gsub("/", "\\") .. '" /b'
    end
    
    for fi in io.popen(command):lines() do
        cpt = cpt + 1
        files[cpt] = fi
    end

    local s = cpt
    local file, content, current, structuredData, luaTableString, file_name, path, file2

    for i = 1, s do
        local filePath = Config.paths.fileXml .. files[i]
        file = io.open(filePath, "r")
        content = file:read("*all")

        current = parseXML(content)

        structuredData = convertToFilteredJSON(current) -- convert the file into a lua array

        luaTableString = "return " .. serialize(structuredData)

        file_name = string.match(files[i], "(.-)%.") -- create a variable but keep only what is before the first dot (.)

        path = Config.paths.listLua .. file_name .. ".txt"

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
    
    -- Cross-platform directory listing
    local listLuaPath = Config.paths.listLua
    local command
    if os.execute("ls --version > /dev/null 2>&1") == 0 then
        command = 'ls "' .. listLuaPath .. '"'
    else
        command = 'dir "' .. listLuaPath:gsub("/", "\\") .. '" /b'
    end
    
    for fi in io.popen(command):lines() do
        cpt = cpt + 1
        files[cpt] = fi
    end

    local s = cpt

    local file_name_without_extension, content, nbr_mpt_male, nbr_mpt_female, nbr_mpt_teen, group_dir

    for i = 1, s do
        local filePath = Config.paths.listLua .. files[i]
        content = LireFichier(filePath)

        if content ~= nil then 
            file_name_without_extension = string.match(files[i], "(.-)%.")
            -- retrieve ped TYPE (male, female, ...)
            -- count how many times 'content' contains the string 'MPT_FEMALE'
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

            local outputPath = Config.paths.listLua .. group_dir .. "/" .. file_name_without_extension .. ".txt"
            EcrireFichier({ filename = outputPath, content = content })
            -- print(i .. " " .. file_name_without_extension)
        -- else print("content nil : " .. files[i])
        end
    end
    print("createGroupFiles() ok")
end