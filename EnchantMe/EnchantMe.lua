local addonName, EM = ...

EnchantMeAddon = EM

EM.frame = CreateFrame('Frame')
EM.eventHandlers = {
    PLAYER_EQUIPMENT_CHANGED = 'update',
    SOCKET_INFO_UPDATE = 'update',
    ITEM_UPGRADE_MASTER_UPDATE = 'update',
    ACTIVE_TALENT_GROUP_CHANGED = 'update',
    PLAYER_LEVEL_UP = 'update',
    BAG_UPDATE = 'onBagUpdate',
}
EM.slots = {
    HeadSlot = {
        slotFrame = CharacterHeadSlot,
        enchantable = false,
    },
    NeckSlot = {
        slotFrame = CharacterNeckSlot,
        enchantable = false,
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
        enchantable = false,
    },
    HandsSlot = {
        slotFrame = CharacterHandsSlot,
        enchantable = true,
        classes = {
            WARRIOR = {true, true, true}, -- all specs
            PALADIN = {false, true, true}, -- prot, retri
            DEATHKNIGHT = {true, true, true}, -- all specs
        },
        profs = {[182] = true, [186] = true, [393] = true}, -- herb, mining, skinning
    },
    WaistSlot = {
        slotFrame = CharacterWaistSlot,
        enchantable = false,
    },
    LegsSlot = {
        slotFrame = CharacterLegsSlot,
        enchantable = false,
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
EM.socketStats = {
    'EMPTY_SOCKET_RED',
    'EMPTY_SOCKET_YELLOW',
    'EMPTY_SOCKET_BLUE',
    'EMPTY_SOCKET_META',
    'EMPTY_SOCKET_PRISMATIC',
}

function EM:initialize(name)
    self:registerEvents()
    self:initFrames()
    self:update()
end

function EM:registerEvents()
    for event in pairs(self.eventHandlers) do
        self.frame:RegisterEvent(event)
    end

    self.frame:SetScript('OnEvent', function (frame, event, ...)
        self[self.eventHandlers[event]](self, ...)
    end)
end

function EM:initFrames()
    for slot, slotInfo in pairs(self.slots) do
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

function EM:update()
    if UnitLevel('player') < 50 then
        return
    end

    for slot, slotInfo in pairs(self.slots) do
        local itemLink = GetInventoryItemLink('player', GetInventorySlotInfo(slot))
        local needsEnchant = false
        local needsGem = false
        local text

        if itemLink then
            local itemInfo = self:parseItemLink(itemLink)
            needsEnchant = self:needsEnchant(slot, slotInfo, itemInfo)
            needsGem = self:needsGem(slot, itemLink, itemInfo)
        end

        if needsEnchant and needsGem then
            text = 'E,G'
        elseif needsEnchant then
            text = 'E'
        elseif needsGem then
            text = 'G'
        end

        if text then
            slotInfo.textFrame.text:SetFormattedText('|cffff0000%s|r', text)
            slotInfo.textFrame:Show()
        else
            slotInfo.textFrame:Hide()
        end
    end
end

function EM:onBagUpdate(bagId)
    if bagId == 0 then
        self:update()
    end
end

function EM:needsEnchant(slot, slotInfo, itemInfo)
    if not slotInfo.enchantable or itemInfo[2] ~= '' then
        return false -- not enchantable or already enchanted
    end

    if slotInfo.classes then
        local class = select(2, UnitClass('player'))
        local spec = GetSpecialization()

        if slotInfo.classes[class] and slotInfo.classes[class][spec] then
            return true -- needed based on class & spec
        end
    end

    if slotInfo.profs then
        for _, id in ipairs(self:getProfessions()) do
            if slotInfo.profs[id] then
                return true -- needed based on profession
            end
        end
    end

    return not slotInfo.classes and not slotInfo.profs -- needed unless there are any conditions
end

function EM:needsGem(slot, itemLink, itemInfo)
    local numGems = 0

    for i = 3, 6 do
        if itemInfo[i] ~= '' then
            numGems = numGems + 1
        end
    end

    local numSockets = 0
    local stats = GetItemStats(itemLink)

    if stats == nil then
        return false
    end

    for _, stat in pairs(self.socketStats) do
        numSockets = numSockets + (stats[stat] or 0)
    end

    return numGems < numSockets
end

function EM:getProfessions()
    local prof1, prof2 = GetProfessions()
    local ids = {}

    for _, prof in ipairs({prof1, prof2}) do
        local id = select(7, GetProfessionInfo(prof))
        table.insert(ids, id)
    end

    return ids
end

function EM:parseItemLink(itemLink)
    local _, _, itemString = string.find(itemLink, '|Hitem:(.+)|h')

    return {strsplit(':', itemString or '')}
end

-- init
EM:initialize()
