--[[
    exter-albums | server bridge
    Detects the running framework, inventory and database resource so the
    rest of the script never has to care which one the server is using.
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

-- ---------------------------------------------------------------------
-- Inventory detection
-- ---------------------------------------------------------------------
local function setupInventory()
    local wanted = Config.Inventory

    if wanted ~= 'auto' then
        Bridge.Inventory = wanted
        return
    end

    if GetResourceState('ox_inventory') == 'started' then
        Bridge.Inventory = 'ox_inventory'
    elseif GetResourceState('qs-inventory') == 'started' then
        Bridge.Inventory = 'qs-inventory'
    elseif GetResourceState('qb-inventory') == 'started' then
        Bridge.Inventory = 'qb-inventory'
    else
        -- fall back to whatever the framework itself provides
        Bridge.Inventory = Bridge.Framework
    end
end

setupFramework()
setupInventory()

CreateThread(function()
    print(('[exter-albums] framework: ^2%s^0 | inventory: ^2%s^0'):format(Bridge.Framework, Bridge.Inventory))
end)

-- ---------------------------------------------------------------------
-- Identifiers / player info
-- ---------------------------------------------------------------------

--- Returns a stable per-character identifier used to own rows in the DB.
function Bridge.GetIdentifier(src)
    src = tonumber(src)
    if not src then return nil end

    if Bridge.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        return xPlayer and xPlayer.identifier or nil
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        local Player = QBCore.Functions.GetPlayer(src)
        return Player and Player.PlayerData.citizenid or nil
    else
        return GetPlayerIdentifierByType(src, 'license') or GetPlayerIdentifierByType(src, 'steam') or ('src:' .. src)
    end
end

--- Returns a display name for the player (used for the "send to player" list).
function Bridge.GetPlayerName(src)
    src = tonumber(src)
    if not src then return 'Unknown' end

    if Bridge.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            if xPlayer.getName then return xPlayer.getName() end
            local first = xPlayer.get('firstName') or xPlayer.variables and xPlayer.variables.firstName
            local last = xPlayer.get('lastName') or xPlayer.variables and xPlayer.variables.lastName
            if first and last then return first .. ' ' .. last end
        end
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player and Player.PlayerData.charinfo then
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        end
    end

    return GetPlayerName(src) or ('Player ' .. tostring(src))
end

--- Checks whether a player has a given item (only used when
--- Config.CommandsRequireItem is true).
function Bridge.HasItem(src, item, amount)
    amount = amount or 1
    src = tonumber(src)

    if Bridge.Inventory == 'ox_inventory' then
        local count = exports.ox_inventory:GetItemCount(src, item)
        return (count or 0) >= amount
    elseif Bridge.Inventory == 'qb-inventory' or Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        local Player = QBCore and QBCore.Functions.GetPlayer(src)
        if not Player then return false end
        local hasItem = Player.Functions.GetItemByName(item)
        return hasItem ~= nil and hasItem.amount >= amount
    elseif Bridge.Inventory == 'qs-inventory' then
        local hasItem = exports['qs-inventory']:GetItemByName(src, item)
        return hasItem ~= nil and hasItem.amount >= amount
    elseif Bridge.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return false end
        local invItem = xPlayer.getInventoryItem(item)
        return invItem ~= nil and invItem.count >= amount
    end

    -- standalone / unknown inventory: can't verify, allow by default
    return true
end

-- ---------------------------------------------------------------------
-- Usable items
-- ---------------------------------------------------------------------

--- Registers `item` so that using it server-side calls cb(source).
--- Works with ox_inventory, ESX and QBCore/QBox. On standalone /
--- unsupported inventories the item simply won't be usable — rely on
--- the chat commands instead.
function Bridge.RegisterUsableItem(item, cb)
    if Bridge.Inventory == 'ox_inventory' then
        exports(item, function(event, itemData, inventory, slot, data)
            if event ~= 'usingItem' then return end
            if inventory and inventory.type == 'player' then
                cb(inventory.id)
            end
        end)
    elseif Bridge.Framework == 'esx' then
        ESX.RegisterUsableItem(item, function(src)
            cb(src)
        end)
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        QBCore.Functions.CreateUseableItem(item, function(src)
            cb(src)
        end)
    else
        print(("[exter-albums] item '%s' could not be registered as usable (no supported inventory found) — use the chat command instead."):format(item))
    end
end

-- ---------------------------------------------------------------------
-- Server callbacks (framework agnostic request/response)
-- ---------------------------------------------------------------------
local standaloneCallbacks = {}

function Bridge.RegisterServerCallback(name, cb)
    if Bridge.Framework == 'esx' then
        ESX.RegisterServerCallback(name, cb)
    elseif Bridge.Framework == 'qbcore' or Bridge.Framework == 'qbox' then
        QBCore.Functions.CreateCallback(name, cb)
    else
        standaloneCallbacks[name] = cb
    end
end

RegisterNetEvent('exter-albums:bridgeCallbackRequest', function(name, reqId, ...)
    local src = source
    local cb = standaloneCallbacks[name]
    if not cb then return end

    cb(src, function(...)
        TriggerClientEvent('exter-albums:bridgeCallback', src, reqId, ...)
    end, ...)
end)

-- ---------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------
function Bridge.Notify(src, msg, type)
    TriggerClientEvent('exter-albums:notify', src, msg, type or 'inform')
end

-- ---------------------------------------------------------------------
-- Database (oxmysql preferred, legacy global MySQL as a fallback)
-- ---------------------------------------------------------------------
Bridge.DB = {}

local function driver()
    if GetResourceState('oxmysql') == 'started' then
        return 'oxmysql'
    elseif MySQL ~= nil and MySQL.Async ~= nil then
        return 'mysql-async'
    end
    return nil
end

function Bridge.DB.Query(query, params, cb)
    cb = cb or function() end
    params = params or {}
    local d = driver()

    if d == 'oxmysql' then
        exports.oxmysql:execute(query, params, cb)
    elseif d == 'mysql-async' then
        MySQL.Async.fetchAll(query, params, cb)
    else
        print('[exter-albums] ^1No supported database resource found. Please start oxmysql.^0')
        cb({})
    end
end

function Bridge.DB.Insert(query, params, cb)
    cb = cb or function() end
    params = params or {}
    local d = driver()

    if d == 'oxmysql' then
        exports.oxmysql:insert(query, params, cb)
    elseif d == 'mysql-async' then
        MySQL.Async.execute(query, params, cb)
    else
        print('[exter-albums] ^1No supported database resource found. Please start oxmysql.^0')
        cb(nil)
    end
end

function Bridge.DB.Execute(query, params, cb)
    cb = cb or function() end
    params = params or {}
    local d = driver()

    if d == 'oxmysql' then
        exports.oxmysql:execute(query, params, cb)
    elseif d == 'mysql-async' then
        MySQL.Async.execute(query, params, cb)
    else
        print('[exter-albums] ^1No supported database resource found. Please start oxmysql.^0')
        cb(nil)
    end
end
