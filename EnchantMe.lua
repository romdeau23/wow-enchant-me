local _, addon = ...
local frame = CreateFrame('Frame')
local eventHandlers = {
    PLAYER_EQUIPMENT_CHANGED = 'update',
    SOCKET_INFO_UPDATE = 'update',
    ACTIVE_TALENT_GROUP_CHANGED = 'update',
    PLAYER_LEVEL_UP = 'update',
    BAG_UPDATE = 'onBagUpdate',
}
EnchantMeAddon = addon

local slots = {
    HeadSlot = {
        slotFrame = CharacterHeadSlot,
        enchantable = false,
    },
    NeckSlot = {
        slotFrame = CharacterNeckSlot,
        enchantable = false,
        socketable = 3,
    },
    ShoulderSlot = {
        slotFrame = CharacterShoulderSlot,
        enchantable = false,
    },
    BackSlot = {
        slotFrame = CharacterBackSlot,
        enchantable = true,
    },
    ChestSlot = {
        slotFrame = CharacterChestSlot,
        enchantable = true,
    },
    WristSlot = {
        slotFrame = CharacterWristSlot,
        enchantable = true,
    },
    MainHandSlot = {
        slotFrame = CharacterMainHandSlot,
        enchantable = true,
    },
    SecondaryHandSlot = {
        slotFrame = CharacterSecondaryHandSlot,
        enchantable = true,
        condition = function (itemId)
            return addon.matchInvType(itemId, {INVTYPE_WEAPON = true, INVTYPE_2HWEAPON = true}) -- off hand weapons
        end,
    },
    HandsSlot = {
        slotFrame = CharacterHandsSlot,
        enchantable = false,
    },
    WaistSlot = {
        slotFrame = CharacterWaistSlot,
        enchantable = true,
    },
    LegsSlot = {
        slotFrame = CharacterLegsSlot,
        enchantable = true,
    },
    FeetSlot = {
        slotFrame = CharacterFeetSlot,
        enchantable = true,
    },
    Finger0Slot = {
        slotFrame = CharacterFinger0Slot,
        enchantable = true,
    },
    Finger1Slot = {
        slotFrame = CharacterFinger1Slot,
        enchantable = true,
    },
    Trinket0Slot = {
        slotFrame = CharacterTrinket0Slot,
        enchantable = false,
    },
    Trinket1Slot = {
        slotFrame = CharacterTrinket1Slot,
        enchantable = false,
    },
}
local socketStats = {
    'EMPTY_SOCKET_RED',
    'EMPTY_SOCKET_YELLOW',
    'EMPTY_SOCKET_BLUE',
    'EMPTY_SOCKET_META',
    'EMPTY_SOCKET_PRISMATIC',
}

function addon.init()
    addon.makeToolTipScannerForUpgradeLevel()
    addon.registerEvents()
    addon.initFrames()
    addon.update()
end

-- how to find the upgrade level
local UP1 = ITEM_UPGRADE_TOOLTIP_FORMAT -- "Upgrade Level: %d/%d" -- Upgrade Level: 1/8
local UP2 = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING -- "Upgrade Level: %s %d/%d" -- Upgrade Level: Veteran 1/8
local FIND_UP_1 = "^" .. gsub(UP1, "%%(d)", "(%%%d+)")
local FIND_UP_2 = "^" .. gsub(gsub(UP2, "%%(d)", "(%%%d+)"), "%%(s)", "(%%%a*)")
local scantip
function addon.makeToolTipScannerForUpgradeLevel()
    scantip = CreateFrame("GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate")
    scantip:SetOwner(UIParent, "ANCHOR_NONE")
end

-- Create a function for simplicity's sake:
local function GetItemUpgradeLevel(itemLink)
    -- Pass the item link to the tooltip:
    scantip:SetHyperlink(itemLink)

    -- Scan the tooltip:
    for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
        local text = _G["MyScanningTooltipTextLeft"..i]:GetText()
        if text and text ~= "" then
            local levelClass, currentUpgradeLevel, maxUpgradeLevel = nil, strmatch(text, FIND_UP_1)
            if not currentUpgradeLevel then
                levelClass, currentUpgradeLevel, maxUpgradeLevel = strmatch(text, FIND_UP_2)
            end
            --print("pat:", FIND_UP_2, "text:", text, " currentUpgradeLevel:", currentUpgradeLevel, " maxUpgradeLevel:", maxUpgradeLevel)
            if currentUpgradeLevel then
                return levelClass, currentUpgradeLevel, maxUpgradeLevel
            end
        end
    end
end

function addon.registerEvents()
    for event in pairs(eventHandlers) do
        frame:RegisterEvent(event)
    end

    frame:SetScript('OnEvent', function (_, event, ...)
        addon[eventHandlers[event]](...)
    end)
end

function addon.initFrames()
    for _, slotInfo in pairs(slots) do
        local textFrame = CreateFrame('Frame', nil, slotInfo.slotFrame, 'BackdropTemplate')
        textFrame:SetPoint('TOPLEFT', slotInfo.slotFrame, 'TOPLEFT', 3, -2)
        textFrame:SetSize(10, 10)
        textFrame:SetBackdrop({bgFile = nil, edgeFile = nil, tile = false, tileSize = 32, edgeSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})
        textFrame:SetBackdropColor(0,0,0,0)

        local text = textFrame:CreateFontString(nil, 'ARTWORK')
        text:SetFont('Fonts\\FRIZQT__.TTF', 11, 'THICKOUTLINE')
        text:SetPoint('TOPLEFT', textFrame, 'TOPLEFT', 0, 0)

        textFrame.text = text
        slotInfo.textFrame = textFrame
    end
end

function addon.update()
    if UnitLevel('player') < 60 then
        return
    end

    for slot, slotInfo in pairs(slots) do
        local itemLink = GetInventoryItemLink('player', GetInventorySlotInfo(slot))
        local flags = {}
        local upgradeStr, itemLinkValues

        if itemLink then
            upgradeStr, itemLinkValues = addon.parseItemLink(itemLink)

            if addon.needsEnchant(slotInfo, itemLinkValues) then
                table.insert(flags, 'E')
            end

            local numGems, numSockets = addon.getGemStats(itemLink, itemLinkValues)

            if numGems < numSockets then
                table.insert(flags, 'G')
            end

            if slotInfo.socketable and numSockets < slotInfo.socketable then
                table.insert(flags, 'S')
            end
        end

        local ttStr
        local upgradeStrHex = "0000ff00"
        local hasTxt = false
        if upgradeStr then
            hasTxt = true
            local itemName, itemLink, itemQuality = GetItemInfo(itemLink)
            local r, g, b, hex = GetItemQualityColor(itemQuality)
            upgradeStrHex = hex
            --print(itemLink, " - upgradeStr:", upgradeStr)
        end
        if #flags > 0 then
            hasTxt = true
            ttStr = table.concat(flags, ',')
            --print(itemLink, " - ttStr:", ttStr)
        end

        if hasTxt then
            slotInfo.textFrame.text:SetJustifyH("LEFT")
            slotInfo.textFrame.text:SetFormattedText('|c%s%s|r%s|cffff0000%s|r', upgradeStrHex, upgradeStr or " ", (upgradeStr and "\r") or "",  ttStr or "")
            slotInfo.textFrame:Show()
        else
            slotInfo.textFrame:Hide()
        end
    end
end

function addon.onBagUpdate(bagId)
    if bagId == 0 then
        addon.update()
    end
end

function addon.parseItemLink(itemLink)
    local levelClass, level, max = GetItemUpgradeLevel(itemLink)
    --print("#####", levelClass, level, max)
    local upgradeStr
    if level then
        if levelClass then
            levelClass = string.lower( string.sub(levelClass,1,1) )
        else
            levelClass = ""
        end
        upgradeStr = levelClass .. level .. "/" .. max
    end

    local _, _, itemString = string.find(itemLink, '|Hitem:(.+)|h')
    --print("###",strsplit(':', itemString or ''))
    return upgradeStr, {strsplit(':', itemString or '')}
end

function addon.needsEnchant(slotInfo, itemLinkValues)
    if not slotInfo.enchantable or itemLinkValues[2] ~= '' then
        return false -- not enchantable or already enchanted
    end

    if slotInfo.condition and not slotInfo.condition(itemLinkValues[1]) then
        return false -- condition not satisfied
    end

    return true
end

function addon.getGemStats(itemLink, itemLinkValues)
    local numGems = 0

    for i = 3, 6 do
        if itemLinkValues[i] ~= '' then
            numGems = numGems + 1
        end
    end

    local stats = GetItemStats(itemLink)

    if stats == nil then
        return 0, 0
    end

    local numSockets = 0

    for _, stat in pairs(socketStats) do
        numSockets = numSockets + (stats[stat] or 0)
    end

    return numGems, numSockets
end

function addon.matchInvType(itemId, map)
    local invType = select(9, GetItemInfo(itemId))

    return invType ~= nil and map[invType] ~= nil
end

-- init
addon.init()
