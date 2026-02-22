---@class Addon
local addon = select(2, ...)

---@return EnchantHandler
function addon.createInspectHandler()
    ---@type EnchantHandler
    local handler
    local inspectFrameHooked = false

    ---@return boolean
    local function updateGuard()
        if not InspectFrame then
            return false
        end

        if not inspectFrameHooked then
            hooksecurefunc(InspectFrame, 'Hide', handler.clearFlags)
            inspectFrameHooked = true
        end

        return InspectFrame:IsVisible()
    end

    handler = addon.createHandler(
        'target',
        addon.getBaseSlots(),
        updateGuard,
        function (slotName) return _G['Inspect' .. slotName] end
    )

    -- register event listeners
    addon.on('INSPECT_READY', addon.debounce(0.1, handler.updateFlags)) -- this can fire many times

    return handler
end
