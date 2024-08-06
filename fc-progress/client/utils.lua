function loadDict(dict)
    if DoesAnimDictExist(dict) and not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(50)
        end
    end
end

function loadModel(model)
    model = type(model) == 'number' and model or GetHashKey(model)
    if IsModelValid(model) and IsModelInCdimage(model) and not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(50)
        end
    end
end