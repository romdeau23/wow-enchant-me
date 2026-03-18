---@class Addon
local addon = select(2, ...)

local positionOffsets = {
    TOPLEFT = {x = 3, y = -2},
    TOPRIGHT = {x = -3, y = -2},
    BOTTOMLEFT = {x = 3, y = 2},
    BOTTOMRIGHT = {x = -3, y = 2},
    CENTER = {x = 0, y = -3.5},
}

---@param parentFrame table
---@return EnchantIndicator
function addon.createIndicator(parentFrame)
    ---@class EnchantIndicator
    local indicator = {}
    ---@type string[]
    local flags = {}

    assert(parentFrame)

    local frame = CreateFrame('Frame', nil, parentFrame, 'BackdropTemplate')
    frame:SetAllPoints()
    frame:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropColor(0, 0, 0, 0)

    local text = frame:CreateFontString(nil, 'ARTWORK')

    local function updateText()
        if #flags > 0 then
            text:SetFormattedText('|c%s%s|r', addon.config.db.flagColor, table.concat(flags, ','))
            frame:Show()
        else
            frame:Hide()
        end
    end

    function indicator.updateFrame()
        local point = addon.config.db.indicatorPos
        local offsets = positionOffsets[point]

        text:ClearAllPoints()
        text:SetPoint(point, frame:GetParent(), point, offsets.x, offsets.y)
        text:SetFont('Fonts\\FRIZQT__.TTF', addon.config.db.flagFontSize, 'THICKOUTLINE')

        updateText()
    end

    ---@param newFlags string[]
    function indicator.setFlags(newFlags)
        flags = newFlags
        updateText()
    end

    indicator.updateFrame()

    return indicator
end
