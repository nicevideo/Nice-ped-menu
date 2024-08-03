function nbrOccurence(str, search)
    local _, nbr = string.gsub(string.lower(str), search, "")
    return tonumber(nbr)
end

local itemsTable = {
    [0x18729F39] = "boot_accessories",
    [0x1D4C528A] = "pants",
    [0x3C1A74CD] = "cloaks",
    [0x9925C067] = "hats",
    [0x485EE834] = "vests",
    [0x3107499B] = "chaps",
    [0x2026C46D] = "shirts_full",
    [0x3F7F3587] = "badges",
    [0x7505EF42] = "masks",
    [0x514ADCEA] = "spats",
    [0x5FC29285] = "neckwear",
    [0x777EC6EF] = "boots",
    [0x79D7DF96] = "accessories",
    [0x7A6BBD0B] = "jewelry_rings_right",
    [0xF16A1D23] = "jewelry_rings_left",
    [0x7BC10759] = "jewelry_bracelets",
    [0x91CE9B20] = "gauntlets",
    [0x7A96FACA] = "neckties",
    [0x7BE77792] = "holsters_knife",
    [0x7C00A8F0] = "talisman_holster",
    [0x83887E88] = "loadouts",
    [0x877A2CF7] = "suspenders",
    [0x8EFB276A] = "talisman_satchel",
    [0x94504D26] = "satchels",
    [0x9B2C8B89] = "gunbelts",
    [0xA6D134C6] = "belts",
    [0xFAE9107F] = "belt_buckles",
    [0xB6B6122D] = "holsters_left",
    [0xB9E2FA01] = "holsters_right",
    [0xDA0E2C55] = "ammo_rifles",
    [0xDB64A390] = "talisman_wrist",
    [0xE06D30CE] = "coats",
    [0x662AC34] = "coats_closed",
    [0xAF14310B] = "ponchos",
    [0x72E6EF74] = "armor",
    [0x5E47CA6] = "eyewear",
    [0xEABE0032] = "gloves",
    [0x1AECF7DC] = "talisman_belt",
    [0x3F1F01E5] = "ammo_pistols",
    [0x49C89D9B] = "holsters_crossdraw",
    [0x76F0E272] = "aprons",
    [0xA0E3AB7F] = "skirts",
    [0x4A73515C] = "MASKS_LARGE",
    [0x378AD10C] = "heads",
    [0x864B03AE] = "hair",
    [0x823687F5] = "BODIES_LOWER",
    [0x96EDAE5C] = "teeth",
    [0xB3966C9] = "BODIES_UPPER",
    [0xEA24B45E] = "eyes",
    [0x15D3C7F2] = "beards_chin",
    [0xB6B63737] = "beards_chops",
    [0xECC8B25A] = "beards_mustache",
    [0xF1542D11] = "gunbelt_accs",
    [0x8E84A2AA] = "hair_accessories",
    [0xA2926F9B] = "dresses",
    [0xF8016BCA] = "beards_complete"
}

--[[
RegisterCommand("nice_naked", function(source, args)
    if args[1] ~= nil then -- print("argument : " .. args[1])
            Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), tonumber(args[1]), 0) -- RemoveTagFromMetaPed -- Set target category, here the hash is for hats
            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- UpdatePedVariation
    else
        for hash, name in pairs(itemsTable) do
            Citizen.InvokeNative(0xD710A5007C2AC539, PlayerPedId(), hash, 0) -- RemoveTagFromMetaPed -- Set target category, here the hash is for hats
            Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), 0, 1, 1, 1, 0) -- UpdatePedVariation
        end
    end
end, false)
]]

function CleanDrawable(args)
    local _type = args.type or "drawable"
    local v = args.v or 0
    if v == 0 then return "" end

    if in_array(_type, {"drawable", "albedo", "normal", "material"}) then -- drawable, albedo, normal, material OK
        if nbrOccurence(v, '_') >= 2 then v = GetHashKey(v)
        else
            local splitDrawable = mysplit(v, '_')
            v = splitDrawable[#splitDrawable]
            v = tonumber(v)
            -- print("v : " .. v)
        end
    elseif _type == "palette" then
        if nbrOccurence(v, '_') == 1 or nbrOccurence(v, '_') == 2 then -- PALETTE
            local splitPalette = mysplit(v, '_')
            v = splitPalette[#splitPalette]
            v = tonumber(v)
            -- print("palette : " .. v)
        end
    elseif in_array(_type, {"tint0", "tint1", "tint2"}) then v = tonumber(v) -- TINT0, TINT1, TINT2
    end

    return v
end

--[[
RegisterCommand("nice_ped", function(source, args)
    -- if (palette) { result = `/nice_ped ${drawable} ${albedo} ${normal} ${material} ${palette} ${tint0} ${tint1} ${tint2}`;
    -- } else { result = `/nice_ped ${drawable} ${albedo} ${normal} ${material} ${tint0} ${tint1} ${tint2}`;
    -- }

    local drawable, albedo, normal, material, palette = nil, nil, nil, nil, nil
    local tint0, tint1, tint2 = nil, nil, nil

    drawable = CleanDrawable({ type = "drawable", v = args[1] })
    albedo = CleanDrawable({ type = "albedo", v = args[2] })
    normal = CleanDrawable({ type = "normal", v = args[3] })
    material = CleanDrawable({ type = "material", v = args[4] })

    if args[8] == nil then -- pallette = nil
        tint0 = CleanDrawable({ type = "tint0", v = tonumber(args[5]) })
        tint1 = CleanDrawable({ type = "tint1", v = tonumber(args[6]) })
        tint2 = CleanDrawable({ type = "tint2", v = tonumber(args[7]) })

        -- print drawable, albedo, normal, material, tint0, tint1, tint2
        -- print(drawable .. " - " .. albedo .. " - " .. normal .. " - " .. material .. " - " .. tint0 .. " - " .. tint1 .. " - " .. tint2)

        Citizen.InvokeNative(0xBC6DF00D7A4A6819, PlayerPedId(), drawable, albedo, normal, material, tint0, tint1, tint2)
    else -- palette NOT nil
        palette = CleanDrawable({ type = "palette", v = args[5] })
        tint0 = CleanDrawable({ type = "tint0", v = tonumber(args[6]) })
        tint1 = CleanDrawable({ type = "tint1", v = tonumber(args[7]) })
        tint2 = CleanDrawable({ type = "tint2", v = tonumber(args[87]) })

        -- print drawable, albedo, normal, material, palette, tint0, tint1, tint2
        -- print(drawable .. " - " .. albedo .. " - " .. normal .. " - " .. material .. " - " .. palette .. " - " .. tint0 .. " - " .. tint1 .. " - " .. tint2)

        Citizen.InvokeNative(0xBC6DF00D7A4A6819, PlayerPedId(), drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    end

    Citizen.InvokeNative(0xCC8CA3E88256E58F, PlayerPedId(), false, true, true, true, false) -- UpdatePedVariation
end, false)
]]

RegisterCommand(Config.spawnped, function(source, args)
    TriggerServerEvent("nice_ped:sv_loadOnePed", { pseudo = args[1] })
end, false)

function LoadPed(args)
    ExecuteCommand(Config.loadskin) Wait(2000)
    local pl = PlayerPedId()

    --[[
    -- TODO: if my ped is a male and i want a special female ped
    local mpt = args.mpt or "CPT_MALE" -- print(list.items[1].type[1].value) -- MPT_FEMALE
    if string.lower(mpt) == "mpt_female" then -- print("female ped")
        -- LoadModel(nil, "mp_female") pl = PlayerPedId()
    elseif string.lower(mpt) == "mpt_male" then -- print("male ped")
        -- LoadModel(nil, "mp_male") pl = PlayerPedId()
    end
    ]]

    Wait(2000)

    for hash, name in pairs(itemsTable) do
        Citizen.InvokeNative(0xD710A5007C2AC539, pl, hash, 0) -- RemoveTagFromMetaPed -- Set target category, here the hash is for hats
        Citizen.InvokeNative(0xCC8CA3E88256E58F, pl, 0, 1, 1, 1, 0) -- UpdatePedVariation
    end

    Wait(2000)

    local drawable, albedo, normal, material, palette
    local tint0, tint1, tint2, probability

    local list = args.list

    -- print(dump(list))

    local items = {}
    items = list["items"]

    local nbrOcc, splitDrawable

    for _, v in pairs(items) do
        for _, vv in pairs(v) do
            for _, vvv in pairs(vv) do
                drawable, albedo, normal, material, palette = nil, nil, nil, nil, nil
                tint0, tint1, tint2, probability = nil, nil, nil, nil
                for kkkk, vvvv in pairs(vvv) do

                    if kkkk == "drawable" then drawable = vvvv[1].value end
                    if kkkk == "albedo" then albedo = vvvv[1].value end
                    if kkkk == "normal" then normal = vvvv[1].value end
                    if kkkk == "material" then material = vvvv[1].value end
                    if kkkk == "palette" then palette = vvvv[1].value end
                    -- attr
                    if kkkk == "tint0" then tint0 = tonumber(vvvv[1].attr.value) end
                    if kkkk == "tint1" then tint1 = tonumber(vvvv[1].attr.value) end
                    if kkkk == "tint2" then tint2 = tonumber(vvvv[1].attr.value) end
                    if kkkk == "probability" then probability = vvvv[1].attr.value end
                end

                if drawable ~= nil then -- print("drawable not null : " .. drawable)
                    nbrOcc = nbrOccurence(drawable, '_')
                    nbrOcc = nbrOcc
                    if nbrOcc >= 2 then drawable = GetHashKey(drawable)
                    else
                        splitDrawable = mysplit(drawable, '_')
                        if nbrOcc == 1 and string.sub(splitDrawable[2], 1, 2) == "0x" then -- hexadecimal
                            -- print("one " .. drawable)
                            drawable = splitDrawable[#splitDrawable]
                            drawable = tonumber(drawable)
                        else
                            -- print("multi " .. drawable)
                            drawable = GetHashKey(drawable)
                        end
                    end

                    albedo = CleanDrawable({ type = "albedo", v = albedo })
                    normal = CleanDrawable({ type = "normal", v = normal })
                    material = CleanDrawable({ type = "material", v = material })

                    if palette ~= nil and palette ~= "" then
                        palette = CleanDrawable({ type = "palette", v = palette })
                    end

                    if palette ~= nil and palette ~= "" then Citizen.InvokeNative(0xBC6DF00D7A4A6819, pl, drawable, albedo, normal, material, palette, tint0, tint1, tint2) -- SetMetaPedTag
                    else Citizen.InvokeNative(0xBC6DF00D7A4A6819, pl, drawable, albedo, normal, material, tint0, tint1, tint2) -- SetMetaPedTag
                    end

                    -- print(drawable .. " - " .. albedo .. " - " .. normal .. " - " .. material .. " - " .. palette .. " - " .. tint0 .. " - " .. tint1 .. " - " .. tint2)
                end
            end
        end
    end

    Citizen.InvokeNative(0xCC8CA3E88256E58F, pl, false, true, true, true, false) -- UpdatePedVariation
end

----------------------------------------------------------------

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

function in_array(val, tab)
    for _, value in pairs(tab) do -- ipairs
        if value == val then return true end
    end

    return false
end

function mysplit(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end
    return t
end