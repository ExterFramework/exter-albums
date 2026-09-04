Config = {}

-------------------------------------------------------------------------
-- FRAMEWORK
-- 'auto'       -> auto-detect ESX / QBCore / QBox, falls back to standalone
-- 'esx'        -> force ESX (es_extended)
-- 'qbcore'     -> force QBCore (qb-core)
-- 'qbox'       -> force QBox (qbx_core)
-- 'standalone' -> no framework at all, uses native FiveM identifiers only
-------------------------------------------------------------------------
Config.Framework = 'auto'

-------------------------------------------------------------------------
-- INVENTORY
-- 'auto'          -> auto-detect ox_inventory / qb-inventory / qs-inventory,
--                     otherwise falls back to the framework's own inventory
-- 'ox_inventory'  -> force ox_inventory
-- 'qb-inventory'  -> force qb-inventory
-- 'qs-inventory'  -> force qs-inventory
-- 'esx'           -> force ESX's own usable item system
-- 'standalone'    -> disable item requirement entirely, commands only
-------------------------------------------------------------------------
Config.Inventory = 'auto'

-------------------------------------------------------------------------
-- UI LIBRARY (notifications / progress bars)
-- 'auto'      -> use ox_lib if it's running, otherwise fall back to the
--                detected framework's notify/progressbar, otherwise the
--                plain native GTA UI
-- 'ox_lib'    -> force ox_lib
-- 'framework' -> force QBCore/ESX notify & progressbar
-- 'native'    -> force plain GTA notifications, no progress bar
-------------------------------------------------------------------------
Config.UILibrary = 'auto'

-------------------------------------------------------------------------
-- ITEMS
-------------------------------------------------------------------------
Config.AlbumItem = 'album'
Config.CamItem   = 'camera'
Config.Drone     = 'drone'

-- Also register /album, /camera, /drone chat commands as an alternative
-- way to open the features without using an item.
Config.AlbumCommand = true
Config.CamCommand   = true
Config.DroneCommand = true

-- If true, the chat commands above will ALSO require the player to be
-- carrying the matching item (checked live through the bridge, works
-- with ox_inventory / qb-inventory / qs-inventory / ESX inventory).
Config.CommandsRequireItem = false

-------------------------------------------------------------------------
-- DISCORD WEBHOOK
-- Used by screenshot-basic to upload photos/videos to Discord so they
-- can be displayed back in the NUI.
--
-- IMPORTANT: put YOUR OWN webhook URL here.
-- Never commit a real webhook URL to a public GitHub repository — treat
-- it like a password. If it ever leaks, delete it in Discord and make a
-- new one immediately.
-------------------------------------------------------------------------
Config.Webhook = ''
