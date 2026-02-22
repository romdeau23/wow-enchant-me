---@class Addon
local addon = select(2, ...)

---@param unit string
---@param slots table<string, EnchantSlot>
---@param updateGuard nil|fun():boolean
---@param getSlotFrame fun(slotName: string):table
---@return EnchantHandler
function addon.createHandler(unit, slots, updateGuard, getSlotFrame)
    ---@class EnchantHandler
    local handler = {}
    ---@type table<string, EnchantIndicator>
    local indicators = {}

    ---@param slotName string
    ---@param flags string[]
    local function setIndicatorFlags(slotName, flags)
        if not indicators[slotName] then
            if #flags == 0 then
                -- delay creating the indicator until we have something to display
                return
            end

            indicators[slotName] = addon.createIndicator(getSlotFrame(slotName))
        end

        indicators[slotName].setFlags(flags)
    end

    function handler.updateFlags()
        -- check guard
        if updateGuard and not updateGuard() then
            return
        end

        -- check unit level
        local unitLevel = UnitLevel(unit)

        if unitLevel < addon.const.minUnitLevel or unitLevel > addon.const.maxUnitLevel then
            handler.clearFlags()
            return
        end

        -- update flags
        for slotName, slot in pairs(slots) do
            local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(slotName))

            if itemLink then
                local item = addon.createItem(itemLink)

                setIndicatorFlags(slotName, slot.getFlags(item))
            else
                setIndicatorFlags(slotName, {})
            end
        end
    end

    function handler.clearFlags()
        for _, indicator in pairs(indicators) do
            indicator.setFlags({})
        end
    end

    function handler.updateFrames()
        for _, indicator in pairs(indicators) do
            indicator.updateFrame()
        end
    end

    return handler
end
