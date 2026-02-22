---@class Addon
local addon = select(2, ...)

---@return boolean
local function showMissingArmorSockets()
    return addon.config.db.showMissingArmorSockets
end

---@return table<string, EnchantSlot>
function addon.getBaseSlots()
    return {
        HeadSlot = addon.createSlot({
            enchantable = true,
            socketable = 1,
            socketCondition = showMissingArmorSockets,
        }),
        -- NeckSlot = addon.createSlot({})
        ShoulderSlot = addon.createSlot({
            enchantable = true,
        }),
        -- BackSlot = addon.createSlot({})
        ChestSlot = addon.createSlot({
            enchantable = true,
        }),
        WristSlot = addon.createSlot({
            socketable = 1,
            socketCondition = showMissingArmorSockets,
        }),
        MainHandSlot = addon.createSlot({
            enchantable = true,
        }),
        SecondaryHandSlot = addon.createSlot({
            enchantable = true,
            enchantCondition = function (item)
                -- off hand weapons can be enchanted
                local invType = item.getInvType()

                return invType == 'INVTYPE_WEAPON' or invType == 'INVTYPE_2HWEAPON'
            end,
        }),
        -- HandsSlot = {}),
        WaistSlot = addon.createSlot({
            socketable = 1,
            socketCondition = showMissingArmorSockets,
        }),
        LegsSlot = addon.createSlot({
            enchantable = true,
        }),
        FeetSlot = addon.createSlot({
            enchantable = true,
        }),
        Finger0Slot = addon.createSlot({
            enchantable = true,
        }),
        Finger1Slot = addon.createSlot({
            enchantable = true,
        }),
        -- Trinket0Slot = addon.createSlot({})
        -- Trinket1Slot = addon.createSlot({})
    }
end
