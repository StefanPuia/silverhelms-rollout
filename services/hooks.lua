local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")

local function AnchorFrameToMouse(frame)
    local x, y = GetCursorPosition()
    local effScale = frame:GetEffectiveScale()
    frame:ClearAllPoints()
    frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", (x / effScale), (y / effScale))
end
 
local function hookAnchorTooltipToMouse()
    Rollouts:SecureHook("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
        if GetMouseFocus() ~= WorldFrame then return end
        tooltip:SetOwner(parent, "ANCHOR_CURSOR")
        AnchorFrameToMouse(tooltip)
        tooltip.default = 1
    end)
end

local function unhookAnchorTooltipToMouse()
    Rollouts:Unhook("GameTooltip_SetDefaultAnchor")
end
 


Rollouts.hooks = {
    anchorTooltipToMouse = {
        hook = hookAnchorTooltipToMouse,
        unhook = unhookAnchorTooltipToMouse
    }
}