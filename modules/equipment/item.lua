---@class Addon
local addon = select(2, ...)

local socketStats = {
    -- generic sockets
    'EMPTY_SOCKET_RED',
    'EMPTY_SOCKET_YELLOW',
    'EMPTY_SOCKET_BLUE',
    'EMPTY_SOCKET_META',
    'EMPTY_SOCKET_PRISMATIC',
}

---@param itemLink string
---@return EnchantItem
function addon.createItem(itemLink)
    ---@class EnchantItem
    local item = {}
    ---@type string[]?
    local linkValues

    ---@return string
    function item.getLink()
        return itemLink
    end

    ---@return string[] values https://warcraft.wiki.gg/wiki/ItemLink
    function item.getLinkValues()
        if not linkValues then
            local _, _, itemString = string.find(itemLink, '|Hitem:(.+)|h')

            linkValues = {strsplit(':', itemString or '')}
        end

        return linkValues
    end

    ---@return integer numGems
    ---@return integer numSockets
    function item.getGemStats()
        local numGems = 0
        local values = item.getLinkValues()

        for i = 3, 6 do
            if values[i] ~= '' then
                numGems = numGems + 1
            end
        end

        local stats = C_Item.GetItemStats(itemLink)

        if not stats then
            return numGems, numGems -- no stats available
        end

        local numSockets = 0

        for _, stat in pairs(socketStats) do
            numSockets = numSockets + (stats[stat] or 0)
        end

        return numGems, numSockets
    end

    ---@return string invTypeString INVTYPE_X https://warcraft.wiki.gg/wiki/Enum.InventoryType
    function item.getInvType()
        return (select(9, C_Item.GetItemInfo(item.getLinkValues()[1])))
    end

    return item
end
