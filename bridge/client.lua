--[[
    exter-albums | client bridge
    Detects the running framework/inventory/UI library so client.lua never
    has to hardcode ESX, QBCore, ox_lib, etc.
]]

Bridge = Bridge or {}

local ESX, QBCore = nil, nil

-- ---------------------------------------------------------------------
-- Framework detection
-- ---------------------------------------------------------------------
local function setupFramework()
    local wanted = Config.Framework

    if wanted == 'esx' or (wanted == 'auto' and GetResourceState('es_extended') == 'started') then
        Bridge.Framework = 'esx'
        ESX = exports['es_extended']:getSharedObject()
    elseif wanted == 'qbox' or (wanted == 'auto' and GetResourceState('qbx_core') == 'started') then
        Bridge.Framework = 'qbox'
        QBCore = exports['qbx_core']:GetCoreObject()
    elseif wanted == 'qbcore' or (wanted == 'auto' and GetResourceState('qb-core') == 'started') then
        Bridge.Framework = 'qbcore'
        QBCore = exports['qb-core']:GetCoreObject()
    else
        Bridge.Framework = 'standalone'
    end
end

setupFramework()

-- ---------------------------------------------------------------------
-- UI library detection (ox_lib vs framework vs native)
-- ---------------------------------------------------------------------
local function useOxLib()
    if Config.UILibrary == 'ox_lib' then return true end
    if Config.UILibrary == 'framework' or Config.UILibrary == 'native' then return false end
    return GetResourceState('ox_lib') == 'started'
end

Bridge.UseOxLib = useOxLib()

-- ---------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------
function Bridge.Notify(msg, type, duration)
    type = type or 'inform'
    duration = duration or 5000

    if Config.UILibrary == 'native' then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, true)
        return
    end

    if Bridge.UseOxLib then
        local ok = pcall(function()
            exports.ox_lib:notify({ description = msg, type = type, duration = duration })
        end)
        if ok then return end
    end

    if Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        QBCore.Functions.Notify(msg, type, duration)
    elseif Bridge.Framework == 'esx' then
        ESX.ShowNotification(msg)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

RegisterNetEvent('exter-albums:notify', function(msg, type)
    Bridge.Notify(msg, type)
end)

-- ---------------------------------------------------------------------
-- Progress bar
-- ---------------------------------------------------------------------
--- cb() runs on success, cancelCb() runs if the player cancelled it
--- (movement, combat, etc). On native/no-lib setups it always "succeeds"
--- after `duration`, since there is no cancel support.
function Bridge.ProgressBar(label, duration, cb, cancelCb)
    duration = duration or 3000

    if Bridge.UseOxLib then
        local ok, success = pcall(function()
            return exports.ox_lib:progressBar({
                duration = duration,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = { move = true, car = true, combat = true },
            })
        end)
        if ok then
            if success then
                if cb then cb() end
            else
                if cancelCb then cancelCb() end
            end
            return
        end
    end

    if (Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox') and Config.UILibrary ~= 'native' then
        QBCore.Functions.Progressbar('exter-albums-progress', label, duration, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            if cb then cb() end
        end, function()
            if cancelCb then cancelCb() end
        end)
        return
    end

    -- native fallback: just wait, no cancel support
    CreateThread(function()
        Wait(duration)
        if cb then cb() end
    end)
end

-- ---------------------------------------------------------------------
-- Inventory helpers
-- ---------------------------------------------------------------------

--- Closes whichever inventory UI might currently be open, no matter which
--- inventory resource the server is running.
function Bridge.CloseInventory()
    TriggerEvent('inventory:client:forceClose') -- qb-inventory / qs-inventory / ps-inventory
    if GetResourceState('ox_inventory') == 'started' then
        pcall(function() exports.ox_inventory:closeInventory() end)
    end
end

-- ---------------------------------------------------------------------
-- Server callbacks (framework agnostic request/response)
-- ---------------------------------------------------------------------
local pendingCallbacks = {}
local reqCounter = 0

RegisterNetEvent('exter-albums:bridgeCallback', function(reqId, ...)
    local cb = pendingCallbacks[reqId]
    if cb then
        pendingCallbacks[reqId] = nil
        cb(...)
    end
end)

function Bridge.TriggerServerCallback(name, cb, ...)
    if Bridge.Framework == 'esx' then
        ESX.TriggerServerCallback(name, cb, ...)
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        QBCore.Functions.TriggerCallback(name, cb, ...)
    else
        reqCounter = reqCounter + 1
        pendingCallbacks[reqCounter] = cb
        TriggerServerEvent('exter-albums:bridgeCallbackRequest', name, reqCounter, ...)
    end
end
