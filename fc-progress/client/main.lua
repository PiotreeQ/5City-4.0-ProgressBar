local progressActive = false
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring
local playerState = LocalPlayer.state
local createdProps = {}

-- discord.gg/piotreqscripts

RegisterCommand('test_progress', function()
    local success = exports['fc-progress']:progressBar({
        duration = 2000,
        icon = 'fa-solid fa-arrows-rotate',
        label = 'Drinking water',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
        anim = {
            dict = 'mp_player_intdrink',
            clip = 'loop_bottle'
        },
        prop = {
            model = `prop_ld_flow_bottle`,
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.0, 0.0, -1.5)
        },
    })
    print(success)
end)

local function createProp(ped, prop)
    loadModel(prop.model)
    local coords = GetEntityCoords(ped)
    local object = CreateObject(prop.model, coords.x, coords.y, coords.z, false, false, false)

    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, prop.bone or 60309), prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, true, true, false, true, prop.rotOrder or 0, true)
    SetModelAsNoLongerNeeded(prop.model)

    return object
end

local function interruptProgress(ped, data)
    if not data.useWhileDead and IsEntityDead(ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(ped) then return true end
    if not data.allowCuffed and IsPedCuffed(ped) then return true end
    if not data.allowFalling and IsPedFalling(ped) then return true end
    if not data.allowSwimming and IsPedSwimming(ped) then return true end
end

function progressBar(data)
    if progressActive then
        return
    end

    SendNUIMessage({
        action = 'StartProgress',
        data = data
    })

    local ped = PlayerPedId()
    progressActive = true
    playerState.invBusy = true
    local progressCancel = false

    if data.anim then
        if data.anim.dict then
            loadDict(data.anim.dict)
            TaskPlayAnim(ped, data.anim.dict, data.anim.clip, data.anim.blendIn or 3.0, data.anim.blendOut or 1.0, data.anim.duration or -1, data.anim.flag or 49, data.anim.playbackRate or 0, data.anim.lockX, data.anim.lockY, data.anim.lockZ)
            RemoveAnimDict(data.anim.dict)
        elseif data.anim.scenario then
            TaskStartScenarioInPlace(ped, data.anim.scenario, 0, data.anim.playEnter ~= nil and data.anim.playEnter or true)
        end
    end

    if data.prop then
        playerState:set('lib:progressProps', data.prop, true)
    end

    local disable = data.disable

    while progressActive do
        if disable then
            if disable.mouse then
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 106, true)
            end

            if disable.move then
                DisableControlAction(0, 21, true)
                DisableControlAction(0, 30, true)
                DisableControlAction(0, 31, true)
                DisableControlAction(0, 36, true)
            end

            if disable.sprint and not disable.move then
                DisableControlAction(0, 21, true)
            end

            if disable.car then
                DisableControlAction(0, 63, true)
                DisableControlAction(0, 64, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
                DisableControlAction(0, 75, true)
            end

            if disable.combat then
                DisableControlAction(0, 25, true)
                DisablePlayerFiring(PlayerId(), true)
            end
        end

        if data.canCancel then
            if IsControlPressed(0, 73) then -- X
                progressCancel = true
                progressActive = false
            end
        end

        if interruptProgress(ped, data) then
            progressCancel = true
            progressActive = false
        end

        Wait(0)
    end

    if data.anim then
        if data.anim.dict then
            StopAnimTask(ped, data.anim.dict, data.anim.clip, 1.0)
            Wait(0)
        else
            ClearPedTasks(ped)
        end
    end

    if data.prop then
        playerState:set('lib:progressProps', nil, true)
    end

    playerState.invBusy = false
    if progressCancel then
        SendNUIMessage({ action = 'CancelProgress' })
        return false
    end

    return true
end

function isProgressActive()
    return progressActive
end

exports('isProgressActive', isProgressActive)
exports('progressBar', progressBar)

RegisterNUICallback('FinishProgress', function()
    progressActive = false
end)

local function deleteProgressProps(serverId)
    local playerProps = createdProps[serverId]
    if not playerProps then return end
    for i = 1, #playerProps do
        local prop = playerProps[i]
        if DoesEntityExist(prop) then
            DeleteEntity(prop)
        end
    end
    createdProps[serverId] = nil
end

RegisterNetEvent('onPlayerDropped', function(serverId)
    deleteProgressProps(serverId)
end)

AddStateBagChangeHandler('lib:progressProps', nil, function(bagName, key, value, reserved, replicated)
    if replicated then return end

    local ply = GetPlayerFromStateBagName(bagName)
    if ply == 0 then return end

    local ped = GetPlayerPed(ply)
    local serverId = GetPlayerServerId(ply)
    
    if not value then
        return deleteProgressProps(serverId)
    end
    
    createdProps[serverId] = {}
    local playerProps = createdProps[serverId]
    
    if value.model then
        playerProps[#playerProps+1] = createProp(ped, value)
    else
        for i = 1, #value do
            local prop = value[i]

            if prop then
                playerProps[#playerProps+1] = createProp(ped, prop)
            end
        end
    end
end)
