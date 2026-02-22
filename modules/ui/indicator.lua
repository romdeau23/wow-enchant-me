---@class Addon
local addon = select(2, ...)

local positionOffsets = {
    TOPLEFT = {x = 3, y = -2},
    TOPRIGHT = {x = -3, y = -2},
    BOTTOMLEFT = {x = 3, y = 2},
    BOTTOMRIGHT = {x = -3, y = 2},
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
    frame:SetSize(10, 10)
    frame:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropColor(0, 0, 0, 0)

    local text = frame:CreateFontString(nil, 'ARTWORK')
    text:SetFont('Fonts\\FRIZQT__.TTF', 11, 'THICKOUTLINE')
    text:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)

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

        frame:ClearAllPoints()
        frame:SetPoint(point, frame:GetParent(), point, offsets.x, offsets.y)
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
