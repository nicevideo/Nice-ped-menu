function NativeSetPedFaceFeature(ped, index, value)
    Citizen.InvokeNative(0x5653AB26C82938CF, ped, index, value)
    NativeUpdatePedVariation(ped)
end

function NativeSetPedComponentEnabled(ped, componentHash, immediately, isMp)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, isMp, true)
    NativeUpdatePedVariation(ped)
end

function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function NativeUpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    while not NativeHasPedComponentLoaded(ped) do Wait(1) end
end

function modelrequest(model)
    CreateThread(function() RequestModel(model) end)
end

function LoadModel(target, model)
    local _model = GetHashKey(model)
    while not HasModelLoaded(_model) do Wait(50) end -- modelrequest(_model) end
    Citizen.InvokeNative(0xED40380076A31506, PlayerId(), _model, false)
    if IsPedMale(PlayerPedId()) then Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 0, 0)
    else Citizen.InvokeNative(0x77FF8D35EEC6BBC4, PlayerPedId(), 7, true)
    end
    NativeUpdatePedVariation(PlayerPedId())
end

function GetPedModel(sex) -- utility ?
    local model = "mp_male"
    if sex == 1 then model = "mp_male"
    elseif sex == 2 then model = "mp_female"
    end

    return model
end