# exter-albums

A photo album / camera / drone script for FiveM. Take photos and videos
in-world, browse them in an in-game gallery, organize them into
categories, and share them with other players.

This version has been rewritten to be **framework, inventory and
UI-library agnostic** — it auto-detects what your server is running and
adapts to it. It also fixes several bugs and security issues found in
the original release (see [Changelog](#changelog--fixes) below).

## Features

- Take photos in first-person camera mode
- Record short video clips
- Drone / free-cam mode for aerial shots
- In-game gallery with categories (all / recent / videos / folders / documents)
- Share a photo/video with another online player
- Delete photos/videos you own
- Works with **any** combination of framework / inventory / UI library below

## Compatibility

| Type | Supported |
|---|---|
| Framework | ESX (`es_extended`), QBCore (`qb-core`), QBox (`qbx_core`), Standalone |
| Inventory | `ox_inventory`, `qb-inventory`, `qs-inventory`, ESX's own inventory, Standalone (commands only) |
| UI library | `ox_lib` (notify + progress bar), framework's own notify/progressbar, or plain native GTA notifications |
| Database | [`oxmysql`](https://github.com/overextended/oxmysql) (recommended). A legacy global `MySQL` object exposed by another resource is also detected as a fallback. |

Everything above is auto-detected at resource start — you normally don't
need to configure anything. You can also force a specific framework /
inventory / UI library in `config.lua` if you want to skip detection.

## Dependencies

- [`oxmysql`](https://github.com/overextended/oxmysql) — database access
- [`screenshot-basic`](https://github.com/gottfriedleibniz/screenshot-basic) — uploads screenshots/clips to your Discord webhook
- Your framework (ESX / QBCore / QBox) — optional, only if you're not running standalone
- One of `ox_inventory` / `qb-inventory` / `qs-inventory` / your framework's own inventory — optional, only needed for item-based usage
- [`ox_lib`](https://github.com/overextended/ox_lib) — optional, only used for nicer notifications/progress bars if it's running
- ['sb-rendering'](https://github.com/SOBING4413/sb-rendering)

Make sure `exter-albums` starts **after** your framework, your inventory
and `oxmysql` in `server.cfg`.

## Installation

1. Download/clone this resource into your `resources` folder.
2. Import [`install.sql`](install.sql) into your database.
3. Add a Discord webhook URL to `Config.Webhook` in `config.lua` (used by
   `screenshot-basic` to upload photos/videos). **Never commit your real
   webhook to a public repository.**
4. Add the items below to your inventory if you want item-based usage
   (all three are optional — chat commands work with or without them).
5. Add `ensure exter-albums` to your `server.cfg`, after your framework,
   inventory and `oxmysql`.

### Adding the items

Item names are configurable in `config.lua` (`Config.AlbumItem`,
`Config.CamItem`, `Config.Drone` — defaults: `album`, `camera`, `drone`).

**ox_inventory** (`data/items.lua`):
```lua
['album'] = {
    label = 'Photo Album',
    weight = 100,
    stack = false,
    close = true,
},
['camera'] = {
    label = 'Camera',
    weight = 400,
    stack = false,
    close = true,
},
['drone'] = {
    label = 'Drone',
    weight = 800,
    stack = false,
    close = true,
},
```

**qb-inventory / qs-inventory** (`shared/items.lua`):
```lua
['album']  = { name = 'album',  label = 'Photo Album', weight = 100, type = 'item', image = 'album.png',  unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A photo album' },
['camera'] = { name = 'camera', label = 'Camera',       weight = 400, type = 'item', image = 'camera.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Take photos and videos' },
['drone']  = { name = 'drone',  label = 'Drone',        weight = 800, type = 'item', image = 'drone.png',  unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A camera drone' },
```

**ESX** (`es_extended` items table — insert via your database/admin tool
using the same item names).

If you don't want to bother with items at all, leave
`Config.AlbumCommand` / `Config.CamCommand` / `Config.DroneCommand` set
to `true` and use `/album`, `/camera`, `/drone` instead.

## Configuration

All options live in `config.lua`:

```lua
Config.Framework = 'auto'        -- 'auto' | 'esx' | 'qbcore' | 'qbox' | 'standalone'
Config.Inventory = 'auto'        -- 'auto' | 'ox_inventory' | 'qb-inventory' | 'qs-inventory' | 'esx' | 'standalone'
Config.UILibrary = 'auto'        -- 'auto' | 'ox_lib' | 'framework' | 'native'

Config.AlbumItem = 'album'
Config.CamItem   = 'camera'
Config.Drone     = 'drone'

Config.AlbumCommand = true
Config.CamCommand   = true
Config.DroneCommand = true
Config.CommandsRequireItem = false

Config.Webhook = ''              -- your Discord webhook URL
```

## Commands

| Command | Description |
|---|---|
| `/album` | Open your photo album |
| `/camera` | Enter first-person photo/video mode |
| `/drone` | Enter drone/free-cam mode |
| `/video` | Manual short video capture |

Controls while in camera/drone mode:

- **Fire** — take photo
- **Cover/Reload** — cancel/exit
- **Special ability (default `X`)** — record a 10s video

## Changelog / fixes

Compared to the original release, this version:

- Adds full ESX / QBCore / QBox / standalone and multi-inventory support
  through a bridge layer (`bridge/client.lua`, `bridge/server.lua`)
  instead of hardcoding ESX everywhere.
- Adds optional `ox_lib` notifications/progress bars with automatic
  fallback to your framework's own UI, or plain native notifications.
- **Removes a real Discord webhook URL that was hardcoded in
  `config.lua`.** If you're upgrading from an older copy of this
  script, treat that old webhook as compromised and delete it.
- Fixes a SQL injection vulnerability — every query now uses
  parameterized statements instead of string concatenation.
- Fixes a logic bug in the delete-by-URL query where missing
  parentheses (`WHERE url = ? OR video = ? AND owner = ?`) let **any
  player delete any other player's photo** if they knew (or guessed)
  its URL. Category changes and photo sharing now also verify
  ownership before making any change.
- Fixes a broken `fxmanifest.lua` (`author"sobing` was an unterminated
  string that could fail to parse).
- Fixes a bug in `GetPlayerFullName` where the function's `src`
  parameter was silently discarded in favor of the global `source`
  value, breaking it outside of a direct event context.
- Fixes the `/video` command referencing an undefined `unique`
  variable.
- Removes unused/blocking global variables (`xPlayer`, `result`, etc.)
  in favor of locals, avoiding cross-player race conditions.
- Switches all database access from blocking `MySQL.Sync.*` calls to
  async `oxmysql` calls.
- Ensures every NUI callback calls back (`cb('ok')`), which previously
  could leave a pending NUI `fetch()` hanging.
- Removes the old sample SQL dump containing real player identifiers
  and Discord CDN links; replaced with a clean, empty `install.sql`.

## License

MIT — do whatever you want with it, a credit is appreciated but not required.
