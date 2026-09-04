--[[
    exter-albums | server.lua
    Framework/inventory agnostic thanks to bridge/server.lua
]]

local Players = {}

-- ---------------------------------------------------------------------
-- Online player list (used for "send photo to player")
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:player')
AddEventHandler('exter-albums:player', function()
    local src = source
    Players[src] = {
        name = Bridge.GetPlayerName(src),
        source = src,
        online = true,
    }
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    Players[src] = nil
end)

-- ---------------------------------------------------------------------
-- Share a photo/video with another online player
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:sendToPlayer')
AddEventHandler('exter-albums:sendToPlayer', function(data)
    local src = source
    local target = tonumber(data and data.source)
    local shareId = tonumber(data and data.share)

    if not target or not shareId or not Players[target] then return end

    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    -- Only allow sharing photos the requesting player actually owns.
    Bridge.DB.Query('SELECT `url`, `video` FROM `exter-albums` WHERE `id` = ? AND `owner` = ?', { shareId, identifier }, function(result)
        if not result or not result[1] then return end
        local row = result[1]

        if row.video then
            Bridge.DB.Insert('INSERT INTO `exter-albums` (`owner`, `url`, `video`) VALUES (?, ?, ?)', {
                Bridge.GetIdentifier(target), row.url, row.video,
            })
        else
            Bridge.DB.Insert('INSERT INTO `exter-albums` (`owner`, `url`) VALUES (?, ?)', {
                Bridge.GetIdentifier(target), row.url,
            })
        end
    end)
end)

-- ---------------------------------------------------------------------
-- Video capture flow
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:createNewVideo')
AddEventHandler('exter-albums:createNewVideo', function(unique, img)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    Bridge.DB.Insert('INSERT INTO `exter-albums` (`owner`, `url`, `uniq`) VALUES (?, ?, ?)', {
        identifier, img, unique,
    })
end)

RegisterNetEvent('exter-albums:updateVideo')
AddEventHandler('exter-albums:updateVideo', function(data)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    Bridge.DB.Execute('UPDATE `exter-albums` SET `video` = ? WHERE `uniq` = ? AND `owner` = ?', {
        data.video_proxy, data.unique, identifier,
    })
end)

-- ---------------------------------------------------------------------
-- Delete
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:delete')
AddEventHandler('exter-albums:delete', function(id)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    Bridge.DB.Execute('DELETE FROM `exter-albums` WHERE `id` = ? AND `owner` = ?', {
        id, identifier,
    })
end)

RegisterNetEvent('exter-albums:deletefullimg')
AddEventHandler('exter-albums:deletefullimg', function(url)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    -- NOTE: parentheses are required here — without them "OR ... AND owner = ?"
    -- would let ANY player delete ANY other player's photo just by URL.
    Bridge.DB.Execute('DELETE FROM `exter-albums` WHERE (`url` = ? OR `video` = ?) AND `owner` = ?', {
        url, url, identifier,
    })
end)

-- ---------------------------------------------------------------------
-- Change category
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:changeCategory')
AddEventHandler('exter-albums:changeCategory', function(data)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    Bridge.DB.Execute('UPDATE `exter-albums` SET `category` = ? WHERE (`url` = ? OR `video` = ?) AND `owner` = ?', {
        data.category, data.url, data.url, identifier,
    })
end)

-- ---------------------------------------------------------------------
-- Save a still photo
-- ---------------------------------------------------------------------
RegisterNetEvent('exter-albums:savePhoto')
AddEventHandler('exter-albums:savePhoto', function(url)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    Bridge.DB.Insert('INSERT INTO `exter-albums` (`owner`, `url`) VALUES (?, ?)', {
        identifier, url,
    })
end)

-- ---------------------------------------------------------------------
-- Item usage / commands
-- ---------------------------------------------------------------------
local function openAlbum(src)
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return end

    Bridge.DB.Query('SELECT * FROM `exter-albums` WHERE `owner` = ?', { identifier }, function(result)
        TriggerClientEvent('exter-albums:open', src, result or {})
    end)
end

local function openCam(src)
    TriggerClientEvent('exter-albums:cam', src)
end

local function openDrone(src)
    TriggerClientEvent('exter-albums:drone', src)
end

Bridge.RegisterUsableItem(Config.AlbumItem, openAlbum)
Bridge.RegisterUsableItem(Config.CamItem, openCam)
Bridge.RegisterUsableItem(Config.Drone, openDrone)

local function commandGuard(src, item, action)
    if Config.CommandsRequireItem and not Bridge.HasItem(src, item) then
        Bridge.Notify(src, 'You do not have the required item.', 'error')
        return
    end
    action(src)
end

if Config.AlbumCommand then
    RegisterCommand(Config.AlbumItem, function(source)
        commandGuard(source, Config.AlbumItem, openAlbum)
    end, false)
end

if Config.DroneCommand then
    RegisterCommand(Config.Drone, function(source)
        commandGuard(source, Config.Drone, openDrone)
    end, false)
end

if Config.CamCommand then
    RegisterCommand(Config.CamItem, function(source)
        commandGuard(source, Config.CamItem, openCam)
    end, false)
end

-- ---------------------------------------------------------------------
-- Callbacks
-- ---------------------------------------------------------------------
Bridge.RegisterServerCallback('exter-albums:getPlayerAlbum', function(src, cb)
    local identifier = Bridge.GetIdentifier(src)
    if not identifier then return cb({}) end

    Bridge.DB.Query('SELECT * FROM `exter-albums` WHERE `owner` = ?', { identifier }, function(result)
        cb(result or {})
    end)
end)

Bridge.RegisterServerCallback('exter-albums:getPlayers', function(src, cb)
    cb(Players)
end)
