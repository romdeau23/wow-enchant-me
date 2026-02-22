---@class Addon
local addon = select(2, ...)

---@return EnchantHandler
function addon.createPlayerHandler()
    local handler = addon.createHandler(
        'player',
        addon.getBaseSlots(),
        nil,
        function (slotName) return _G['Character' .. slotName] end
    )
    local equipmentUpdated = false

    local function updateFlagsIfVisible()
        if CharacterFrame:IsShown() then
            handler.updateFlags()
        end
    end

    ---@param bagId integer
    local function onBagUpdate(bagId)
        if bagId == 0 then
            -- this also fires for the default backpack, but it seems impossible to differentiate
            equipmentUpdated = true
        end
    end

    local function onBagUpdateDelayed()
        if equipmentUpdated then
            equipmentUpdated = false
            updateFlagsIfVisible()
        end
    end

    -- update flags once character frame is shown
    hooksecurefunc(CharacterFrame, 'Show', handler.updateFlags)

    -- register event listeners
    addon.on('PLAYER_EQUIPMENT_CHANGED', updateFlagsIfVisible) -- changing gear, adding sockets
    addon.on('PLAYER_LEVEL_UP', updateFlagsIfVisible) -- leveling up
    addon.on('SOCKET_INFO_UPDATE', updateFlagsIfVisible) -- socket info becoming available
    addon.on('BAG_UPDATE', onBagUpdate) -- adding enchants, gems
    addon.on('BAG_UPDATE_DELAYED', onBagUpdateDelayed) -- adding enchants, gems

    return handler
end
