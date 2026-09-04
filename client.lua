--[[
    exter-albums | client.lua
    Framework/inventory agnostic thanks to bridge/client.lua
]]

ForceFps = false
LeftClick = false
CACHE_IMG = nil
EnableLoop = false
hideui = false

local cam, cur_pos, cur_rot
local angleY = 0.0
local angleZ = 0.0

-- ---------------------------------------------------------------------
-- Tell the server we're ready (used to build the "send to player" list)
-- ---------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(1)
        if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent('exter-albums:player')
            break
        end
    end
end)

-- ---------------------------------------------------------------------
-- /video : manual recording command (independent from the drone/camera flow)
-- ---------------------------------------------------------------------
RegisterCommand('video', function()
    local unique = math.random(1, 900000000)
    TriggerEvent('sb-rendering:addNewTask', 'exter-albums:updateVideo', unique, 5000)
    exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data)
        local resp = json.decode(data)
        TriggerServerEvent('exter-albums:createNewVideo', unique, resp.attachments[1].proxy_url)
    end)
end, false)

-- ---------------------------------------------------------------------
-- Open events (triggered by the item / command via server.lua)
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:open')
AddEventHandler('exter-albums:open', function(data)
    SetNuiFocus(1, 1)
    SendNUIMessage({ action = 'open', data = data })
    Bridge.CloseInventory()
end)

RegisterNetEvent('exter-albums:cam')
AddEventHandler('exter-albums:cam', function()
    SendNUIMessage({ action = 'cam' })
    ForceFps = true
    Bridge.CloseInventory()
    forceFirstPerson()
    SetNuiFocusKeepInput(0)
end)

RegisterNetEvent('exter-albums:drone')
AddEventHandler('exter-albums:drone', function()
    EnableFreeCam()
end)

-- ---------------------------------------------------------------------
-- NUI callbacks
-- ---------------------------------------------------------------------
RegisterNUICallback('savePhoto', function(data, cb)
    if CACHE_IMG then
        TriggerServerEvent('exter-albums:savePhoto', CACHE_IMG)
    end
    SendNUIMessage({ action = 'camkapa' })
    ForceFps = false
    forceFirstPerson()
    EnableLoop = false
    Thread()
    RenderScriptCams(false, true, 1000)
    FreezeEntityPosition(PlayerPedId(), false)
    cb('ok')
end)

RegisterNUICallback('rePhoto', function(data, cb)
    SendNUIMessage({ action = 'cam' })
    ForceFps = true
    forceFirstPerson()
    SetNuiFocusKeepInput(0)
    CACHE_IMG = nil
    SendNUIMessage({ action = 'camkapa' })
    ForceFps = false
    forceFirstPerson()
    EnableLoop = false
    Thread()
    RenderScriptCams(false, true, 1000)
    FreezeEntityPosition(PlayerPedId(), false)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(0, 0)
    cb('ok')
end)

RegisterNUICallback('getPlayerAlbum', function(data, cb)
    Bridge.TriggerServerCallback('exter-albums:getPlayerAlbum', function(x)
        cb(x)
    end)
end)

RegisterNUICallback('getPlayers', function(data, cb)
    Bridge.TriggerServerCallback('exter-albums:getPlayers', function(x)
        cb(x)
    end)
end)

RegisterNUICallback('delete', function(data, cb)
    TriggerServerEvent('exter-albums:delete', data)
    cb('ok')
end)

RegisterNUICallback('deletefullimg', function(data, cb)
    TriggerServerEvent('exter-albums:deletefullimg', data)
    cb('ok')
end)

RegisterNUICallback('changeCategory', function(data, cb)
    TriggerServerEvent('exter-albums:changeCategory', data)
    cb('ok')
end)

RegisterNUICallback('sendToPlayer', function(data, cb)
    TriggerServerEvent('exter-albums:sendToPlayer', data)
    cb('ok')
end)

-- ---------------------------------------------------------------------
-- Camera flow (first person photo/video capture)
-- ---------------------------------------------------------------------
function forceFirstPerson()
    while ForceFps do
        DisableControlAction(0, 199, true)
        DisableControlAction(0, 200, true)

        if IsControlJustPressed(0, 201) then
            if LeftClick == false then
                LeftClick = true
                ForceFps = false
                forceFirstPerson()
                SendNUIMessage({ action = 'takedphoto' })
                Wait(500)
                exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data)
                    local resp = json.decode(data)
                    SendNUIMessage({ action = 'photoinfo', img = resp.attachments[1].proxy_url })
                    CACHE_IMG = resp.attachments[1].proxy_url
                    SetNuiFocus(1, 1)
                    LeftClick = false
                end)
            end
        end

        if IsControlJustPressed(0, 194) then
            SendNUIMessage({ action = 'camkapa' })
            ForceFps = false
            forceFirstPerson()
            EnableLoop = false
            Thread()
            RenderScriptCams(false, true, 1000)
            FreezeEntityPosition(PlayerPedId(), false)
        end

        if IsControlJustPressed(0, 236) then
            LeftClick = true
            local unique = math.random(1, 900000000)
            SendNUIMessage({ action = 'recording' })
            TriggerEvent('sb-rendering:addNewTask', 'exter-albums:updateVideo', unique, 10000)
            exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data)
                local resp = json.decode(data)
                TriggerServerEvent('exter-albums:createNewVideo', unique, resp.attachments[1].proxy_url)
            end)
            SetTimeout(10000, function()
                SendNUIMessage({ action = 'stoprec' })
                ForceFps = false
                forceFirstPerson()
                SendNUIMessage({ action = 'camkapa' })
                LeftClick = false
            end)
        end

        if LeftClick == false then
            SendNUIMessage({ type = 'camera' })
        end

        if GetFollowPedCamViewMode() ~= 4 then
            SetFollowPedCamViewMode(4)
        end

        DisableControlAction(0, 24, true)  -- attack
        DisableControlAction(0, 257, true) -- attack 2
        DisableControlAction(0, 25, true)  -- aim
        DisableControlAction(0, 263, true) -- melee attack 1
        DisableControlAction(0, 47, true)  -- weapon wheel
        DisableControlAction(0, 264, true) -- melee
        DisableControlAction(0, 140, true) -- melee
        DisableControlAction(0, 141, true) -- melee
        DisableControlAction(0, 142, true) -- melee
        DisableControlAction(0, 143, true) -- melee
        DisableControlAction(0, 0, true)   -- V (vehicle cam)

        Wait(0)
    end
end

-- ---------------------------------------------------------------------
-- Drone / free cam flow
-- ---------------------------------------------------------------------
function EnableFreeCam()
    Bridge.CloseInventory()
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    local pos = GetGameplayCamCoord()
    local rawRot = GetGameplayCamRot()
    local rot = vector3(rawRot.x, 0.0, rawRot.z)

    cur_pos = pos
    cur_rot = rot

    SetFreecamPosition(pos.x + 1.0, pos.y, pos.z)
    SetFreecamRotation(rot.x, rot.y, rot.z)
    RequestAnimDict('idle_a')
    TaskPlayAnim(PlayerId(), 'amb@world_human_golf_player@male@idle_a', 'idle_a', 8.0, -8.0, -1, 2, 0, false, false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    RenderScriptCams(true, true, 1000)
    ClearFocus()
    SendNUIMessage({ action = 'cam' })
    ForceFps = true
    SetNuiFocusKeepInput(0)
    EnableLoop = true
    Thread()
    SetPlayerControl(PlayerPedId(), false)
end

function Thread()
    while EnableLoop do
        DisableControlAction(0, 199, true)
        DisableControlAction(0, 200, true)

        if IsControlPressed(0, 32) then
            cur_pos = vector3(cur_pos.x, cur_pos.y + 0.1, cur_pos.z)
            SetCamCoord(cam, cur_pos)
        end
        if IsControlPressed(0, 34) then
            cur_pos = vector3(cur_pos.x - 0.1, cur_pos.y, cur_pos.z)
            SetCamCoord(cam, cur_pos)
        end
        if IsControlPressed(0, 33) then
            cur_pos = vector3(cur_pos.x, cur_pos.y - 0.1, cur_pos.z)
            SetCamCoord(cam, cur_pos)
        end
        if IsControlPressed(0, 35) then
            cur_pos = vector3(cur_pos.x + 0.1, cur_pos.y, cur_pos.z)
            SetCamCoord(cam, cur_pos)
        end
        if IsControlPressed(0, 44) then
            cur_pos = vector3(cur_pos.x, cur_pos.y, cur_pos.z + 0.1)
            SetCamCoord(cam, cur_pos)
        end
        if IsControlPressed(0, 46) then
            cur_pos = vector3(cur_pos.x, cur_pos.y, cur_pos.z - 0.1)
            SetCamCoord(cam, cur_pos)
        end

        if IsControlJustPressed(0, 194) then
            SendNUIMessage({ action = 'camkapa' })
            EnableLoop = false
            RenderScriptCams(false, true, 1000)
            FreezeEntityPosition(PlayerPedId(), false)
        end

        if IsControlJustPressed(0, 201) then
            if LeftClick == false then
                ForceFps = false
                forceFirstPerson()
                hideui = false
                Wait(100)
                SendNUIMessage({ action = 'takedphoto' })
                exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data)
                    local resp = json.decode(data)
                    SendNUIMessage({ action = 'photoinfo', img = resp.attachments[1].proxy_url })
                    CACHE_IMG = resp.attachments[1].proxy_url
                    SetNuiFocus(1, 1)
                    FreezeEntityPosition(PlayerPedId(), false)
                    hideui = true
                end)
            end
        end

        local newPos = ProcessNewPosition()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
        PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)

        if hideui == false then
            SendNUIMessage({ type = 'drone' })
        end

        Wait(0)
    end
end

function ProcessNewPosition()
    local mouseX, mouseY

    if IsInputDisabled(0) then
        mouseX = GetDisabledControlNormal(1, 1) * 8.0
        mouseY = GetDisabledControlNormal(1, 2) * 8.0
    else
        mouseX = GetDisabledControlNormal(1, 1) * 1.5
        mouseY = GetDisabledControlNormal(1, 2) * 1.5
    end

    angleZ = angleZ - mouseX
    angleY = angleY + mouseY
    if angleY > 89.0 then angleY = 89.0 elseif angleY < -89.0 then angleY = -89.0 end

    local pCoords = GetEntityCoords(PlayerPedId())

    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (1.5 + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (1.5 + 0.5),
        z = pCoords.z + (Sin(angleY)) * (1.5 + 0.5),
    }

    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local _, hitBool, hitCoords = GetShapeTestResult(rayHandle)

    local maxRadius = 1.5
    if hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < 2.5 then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
    end

    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = (Sin(angleY)) * maxRadius,
    }

    return {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z,
    }
end

function SetFreecamPosition(x, y, z)
    local pos = vector3(x, y, z)
    local int = GetInteriorAtCoords(pos)

    LoadInterior(int)
    SetFocusArea(pos)
    LockMinimapPosition(x, y)
    SetCamCoord(cam, pos)
end

function SetFreecamRotation(x, y, z)
    local rotX, rotY, rotZ = ClampCameraRotation(x, y, z)
    local rot = vector3(rotX, rotY, rotZ)

    LockMinimapAngle(math.floor(rotZ))
    SetCamRot(cam, rot)
end

function Clamp(x, min, max)
    return math.min(math.max(x, min), max)
end

function ClampCameraRotation(rotX, rotY, rotZ)
    local x = Clamp(rotX, -90.0, 90.0)
    local y = rotY % 360
    local z = rotZ % 360
    return x, y, z
end

function SetDisplay(bool)
    SendNUIMessage({ type = 'camera', status = bool })
end

function SetDisplay2(bool)
    SendNUIMessage({ type = 'drone', status = bool })
end
