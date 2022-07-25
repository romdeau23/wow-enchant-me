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
        enchantable = true,
        condition = function ()
            return (
                addon.matchClassAndSpec({
                    WARRIOR = {true, true, true}, -- all specs
                    PALADIN = {false, true, true}, -- prot, retri
                    DEATHKNIGHT = {true, true, true}, -- all specs
                })
                or addon.matchProfession({182, 186, 393}) -- herb, mining, skinning
            )
        end,
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
local socketStats = {
    'EMPTY_SOCKET_RED',
    'EMPTY_SOCKET_YELLOW',
    'EMPTY_SOCKET_BLUE',
    'EMPTY_SOCKET_META',
    'EMPTY_SOCKET_PRISMATIC',
    'EMPTY_SOCKET_DOMINATION',
}

function addon.init()
    addon.registerEvents()
    addon.initFrames()
    addon.update()
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
    if UnitLevel('player') < 50 then
        return
    end

    for slot, slotInfo in pairs(slots) do
        local itemLink = GetInventoryItemLink('player', GetInventorySlotInfo(slot))
        local needsEnchant = false
        local needsGem = false
        local text

        if itemLink then
            local itemLinkValues = addon.parseItemLink(itemLink)
            needsEnchant = addon.needsEnchant(slotInfo, itemLinkValues)
            needsGem = addon.needsGem(itemLink, itemLinkValues)
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

function addon.onBagUpdate(bagId)
    if bagId == 0 then
        addon.update()
    end
end

function addon.parseItemLink(itemLink)
    local _, _, itemString = string.find(itemLink, '|Hitem:(.+)|h')

    return {strsplit(':', itemString or '')}
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

function addon.needsGem(itemLink, itemLinkValues)
    local numGems = 0

    for i = 3, 6 do
        if itemLinkValues[i] ~= '' then
            numGems = numGems + 1
        end
    end

    local numSockets = 0
    local stats = GetItemStats(itemLink)

    if stats == nil then
        return false
    end

    for _, stat in pairs(socketStats) do
        numSockets = numSockets + (stats[stat] or 0)
    end

    return numGems < numSockets
end

function addon.getProfessions()
    local profs = {}
    local prof1, prof2 = GetProfessions()

    for _, index in ipairs({prof1, prof2}) do
        if index then
            profs[select(7, GetProfessionInfo(index))] = true
        end
    end

    return profs
end

function addon.matchClassAndSpec(map)
    local class = select(2, UnitClass('player'))
    local spec = GetSpecialization()

    return map[class] ~= nil and map[class][spec] == true
end

function addon.matchProfession(profs)
    local knownProfs = addon.getProfessions()

    for _, id in ipairs(profs) do
        if knownProfs[id] then
            return true
        end
    end

    return false
end

function addon.matchInvType(itemId, map)
    local invType = select(9, GetItemInfo(itemId))

    return invType ~= nil and map[invType] ~= nil
end

-- init
addon.init()
