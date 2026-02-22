---@class Addon
local addon = select(2, ...)

---@class EnchantSlot.Options
---@field enchantable? boolean
---@field enchantCondition? fun(item: EnchantItem):boolean
---@field socketable? integer
---@field socketCondition? fun(item: EnchantItem):boolean

---@param options EnchantSlot.Options
---@return EnchantSlot
function addon.createSlot(options)
    ---@class EnchantSlot
    local slot = {}

    ---@param item EnchantItem
    ---@return boolean
    local function needsEnchant(item)
        if not options.enchantable or item.getLinkValues()[2] ~= '' then
            return false -- not enchantable or already enchanted
        end

        if options.enchantCondition and not options.enchantCondition(item) then
            return false -- condition not satisfied
        end

        return true
    end

    ---@param item EnchantItem
    ---@return string[]
    function slot.getFlags(item)
        local flags = {}

        if needsEnchant(item) then
            table.insert(flags, 'E')
        end

        local numGems, numSockets = item:getGemStats()

        if numGems < numSockets then
            table.insert(flags, 'G')
        end

        if
            options.socketable
            and numSockets < options.socketable
            and (not options.socketCondition or options.socketCondition(item))
        then
            table.insert(flags, 'S')
        end

        return flags
    end

    return slot
end
