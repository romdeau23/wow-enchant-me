---@class Addon
local addon = select(2, ...)
local config, private = addon.module(), {}
addon.config = config

---@type ConfigModule.Config
local DEFAULT_CONFIG = {
    indicatorPos = 'TOPLEFT',
    flagColor = 'ffff0000',
    showMissingArmorSockets = false,
}

---@class ConfigModule.Config
---@field indicatorPos string
---@field flagColor string
---@field showMissingArmorSockets boolean

function config.init()
    config.db = addon.loadSavedVar(
        'EnchantMeAddonConfig',
        5,
        DEFAULT_CONFIG,
        private.migrations
    )
end

---@return ConfigModule.Config
function config.getDefaultConfig()
    return DEFAULT_CONFIG
end

private.migrations = {
    [2] = function (data)
        data.ignoreBelt = nil
    end,
    [3] = function (data)
        data.ignoreSockets = false
    end,
    [4] = function (data)
        data.showMissingJewelrySockets = not data.ignoreSockets
        data.showMissingArmorSockets = false
        data.ignoreSockets = nil
    end,
    [5] = function (data)
        data.showMissingJewelrySockets = nil
    end,
}
