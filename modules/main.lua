---@class Addon
local addon = select(2, ...)
local main, private = addon.module(), {}
addon.main = main

---@type EnchantHandler[]
local handlers = {}

function main.init()
    addon.on('PLAYER_LOGIN', function ()
        private.createHandlers()

        return false
    end)
end

function main.updateHandlers()
    for _, handler in ipairs(handlers) do
        handler.updateFrames()
        handler.updateFlags()
    end
end

function private.createHandlers()
    if PlayerGetTimerunningSeasonID() then
        -- disable enchant checks when timerunning
        return
    end

    table.insert(handlers, addon.createPlayerHandler())
    table.insert(handlers, addon.createInspectHandler())
end
