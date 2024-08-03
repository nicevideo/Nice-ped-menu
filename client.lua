--[[
RegisterCommand("setmodel", function(source, args, rawCommand) -- Set player model -- the old function that everyone knows
	if args[1] == nil then print("Please specify the model")
    else setModel(args[1])
	end
end, false)
]]

function setModel(hash)
	local characterModel = GetHashKey(hash)
	CreateThread(function()
		RequestModel(characterModel) while not HasModelLoaded(characterModel) do Wait(50) end
		SetPlayerModel(PlayerId(), characterModel, false)
		Citizen.InvokeNative(0x283978A15512B2FE, PlayerPedId(), true)
		SetEntityVisible(PlayerPedId(), true)
		while not IsEntityVisible(PlayerPedId()) do Wait(50) end
		SetModelAsNoLongerNeeded(characterModel)
	end)
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

--[[
RegisterCommand("list_pedmenu", function(source, args)
    TriggerServerEvent("nice_ped:sv_list_pedmenu", {}) -- va appeler nice_ped:cl_getListPed
end, false)
]]

RegisterNetEvent('nice_ped:cl_loadOnePed')
AddEventHandler('nice_ped:cl_loadOnePed', function(args)
    local list = args.list
    local mpt = args.mpt -- MPT_MALE MPT_FEMALE
    LoadPed({ list = list, mpt = mpt })
end)

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

local npc = {}
local cpt_npc = 1

local function deleteOldNpc()
    CreateThread(function()
        local cpt = cpt_npc
        for i = 1, cpt do if DoesEntityExist(npc[i]) then DeleteEntity(npc[i]) end end
        Wait(500)
        for i = 1, cpt do if DoesEntityExist(npc[i]) then DeleteEntity(npc[i]) end end
        Wait(500)
        for i = 1, cpt do if DoesEntityExist(npc[i]) then DeleteEntity(npc[i]) end end
    end)
end

local function createNpcInFrontOf(args)
    deleteOldNpc()

    Wait(1)

    CreateThread(function()
        cpt_npc = cpt_npc + 1

        if not in_array(args.model, human_peds) then return print("nice_ped : ERROR model") end -- verify that the model is a human ped

        local modelHashKey = joaat(args.model) RequestModel(modelHashKey) while not HasModelLoaded(modelHashKey) do Wait(50) end

        local _x, _y, _z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0))

        -- good heading
        local my_heading = GetEntityHeading(PlayerPedId())
        local h = my_heading + 180.0
        if h > 360.0 then h = h - 360.0 end

        npc[cpt_npc] = CreatePed(modelHashKey, _x, _y, _z, h, false, false, 0, 0) -- others players don't see the npc
        while not DoesEntityExist(npc[cpt_npc]) do Wait(50) end

        Citizen.InvokeNative(0x283978A15512B2FE, npc[cpt_npc], true) -- SetRandomOutfitVariation
        Citizen.InvokeNative(0x9587913B9E772D29, npc[cpt_npc]) -- PlaceEntityOnGroundProperly

        SetBlockingOfNonTemporaryEvents(npc[cpt_npc], true) -- NPC can't be scared
        SetEntityAsMissionEntity(npc[cpt_npc], true, true)
        FreezeEntityPosition(npc[cpt_npc], true)

        SetModelAsNoLongerNeeded(modelHashKey)

        Citizen.InvokeNative(0x6585D955A68452A5, npc[cpt_npc]) -- ClearPedEnvDirt(npc[cpt_npc])
        ClearPedDamageDecalByZone(npc[cpt_npc], 10, "ALL")
        Citizen.InvokeNative(0x8FE22675A5A45817, npc[cpt_npc]) -- ClearPedBloodDamage(npc[cpt_npc])
        Citizen.InvokeNative(0x7F5D88333EE8A86F, npc[cpt_npc], 1) -- ClearPedBloodDamageFacial
        Citizen.InvokeNative(0x9C720776DAA43E7E, npc[cpt_npc]) -- ClearPedWetness(npc[cpt_npc])
        N_0xe3144b932dfdff65(npc[cpt_npc], 0.0, -1, 1, 1) -- Citizen.InvokeNative(0xE3144B932DFDFF65, npc[cpt_npc], 0.0, -1, 1, 1) -- SetPedDirtCleaned

        ----
        -- RemoveAllPedWeapons(npc[cpt_npc], true, true)
    end)
end

------------------------------------------------------------------------------------------------------------------------

local pageIsOpen = false
local firstCall = true

RegisterCommand(Config.command, function(source, args) -- pedmenu : start html page
    -- get ped's list
    if not pageIsOpen then -- IS CLOSED SO WE OPEN ****************
        pageIsOpen = true
        if firstCall then -- first page opening
            firstCall = false
            SetNuiFocus(true, true) SendNUIMessage({ type = "start" }) -- TriggerServerEvent('nice_ped:sv_getListPed', {}) -- to nice_ped:cl_getListPed
        else -- NOT first page opening
            SetNuiFocus(true, true) SendNUIMessage({ type = "open" })
        end
    else -- IS OPEN, SO WE CLOSE ****************
        SetNuiFocus(false, false) SendNUIMessage({ type = "close" })
        pageIsOpen = false
    end
end, false)
TriggerEvent('chat:addSuggestion', '/' .. Config.command, 'Nice ped menu', {})

--[[
-- first time opening a page
RegisterNetEvent("nice_ped:cl_getListPed", function(args) -- come from nice_ped:sv_getListPed
    SetNuiFocus(true, true) SendNUIMessage({ type = "start" })
end)
]]

--[[
-- VARIATION **************** (in the future for a v2)
RegisterNUICallback('getListVar', function(data) -- display ped's variation
    local pseudo = data.pseudo if type(pseudo) ~= "string" then pseudo = "a_f_m_armcholeracorpse_01" end -- un pseudo de base
    if string.len(pseudo) > 75 then pseudo = "a_f_m_armcholeracorpse_01" end -- un pseudo de base

    TriggerServerEvent("nice_ped:sv_getListVarPed", { pseudo = pseudo }) -- to nice_ped:cl_getListVarPed
end)
-- display ped's variation
RegisterNetEvent("nice_ped:cl_getListVarPed", function(args) -- come from nice_ped:sv_getListVarPed
    local list = args.list
    -- SetNuiFocus(true, true)
    SendNUIMessage({ type = "listVar", list = list })
end)
-- end VARIATION ****************
]]

--[[
-- ADMIN ****************
RegisterNUICallback('getListPlayer', function(data) -- display player's list who have access + management
    TriggerServerEvent("nice_ped:sv_getListPlayer", {}) -- to nice_ped:cl_getListPlayer
end)

-- nice_ped:cl_getListPlayer
RegisterNetEvent("nice_ped:cl_getListPlayer", function(args) -- come from nice_ped:sv_getListPlayer
    local list = args.list
    -- SetNuiFocus(true, true)
    SendNUIMessage({ type = "listPlayer", list = list })
end)
-- END ADMIN ****************
]]

-- CLOSE
RegisterNUICallback('close', function(data)
    deleteOldNpc()
    SetNuiFocus(false, false) SendNUIMessage({ type = "close" })
    pageIsOpen = false
end)

--------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback('spawnped', function(data) -- print("spawnped")
    -- TODO:security (steamid, ...)

    local name = data.name

    if string.len(name) > 50 then return print("nice_ped : ERROR name") end
    if string.find(name, "/") then return print("nice_ped : ERROR name") end

    if not in_array(name, human_peds) then return print("nice_ped : ERROR model") end -- security

    -- print("name : " .. name)

    ExecuteCommand(Config.spawnped .. " " .. name)
end)

RegisterNUICallback('viewped', function(data) -- print("viewped") -- ped overview
    -- TODO:security (steamid, ...)

    local name = data.name

    if string.len(name) > 50 then return print("nice_ped : ERROR name") end
    if string.find(name, "/") then return print("nice_ped : ERROR name") end

    -- print("name : " .. name)

    if not in_array(name, human_peds) then return print("nice_ped : ERROR model") end -- security

    createNpcInFrontOf({ model = name })
end)


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- AddEventHandler("onResourceStop", function(resourceName)
-- 	if GetCurrentResourceName() == resourceName then
-- 	end
-- end)