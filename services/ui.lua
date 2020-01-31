local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
Rollouts.ui = {}

local function updateWindow()
    Rollouts.frames.mainWindow.update()
end
Rollouts.ui.updateWindow = updateWindow

local prevTick = 0
local isTicking = true
Rollouts.ui.uiTick = function()
    local currentTick = GetServerTime()
    if currentTick > prevTick then
        if isTicking then
            Rollouts.rollTick()
            if Rollouts.isRolling() then
                updateWindow()
            else
                if currentTick > prevTick + 60 then
                    updateWindow()
                end
            end
        end
        prevTick = currentTick
    end
end

Rollouts.ui.pauseTick = function()
    isTicking = false
end

Rollouts.ui.resumeTick = function()
    isTicking = true
end

Rollouts.ui.toggleMainWindow = function()
    if Rollouts.frames.mainWindow.shown then
        Rollouts.frames.mainWindow.hide()
    else
        Rollouts.frames.mainWindow.show()
    end
end

Rollouts.ui.showPendingTab = function()
    local tabName = "pending"
    Rollouts.env.historyTab = tabName
    Rollouts.utils.setDBOption(tabName, "lastTab")
    updateWindow()
end

Rollouts.ui.showHistoryTab = function()
    local tabName = "history"
    Rollouts.env.historyTab = tabName
    Rollouts.utils.setDBOption(tabName, "lastTab")
    updateWindow()
end

Rollouts.ui.openHistoryRollView = function(historyEntry)
    Rollouts.env.virtual = historyEntry
    Rollouts.env.showing = "virtual"
    updateWindow()
end

Rollouts.ui.closeHistoryRollView = function()
    Rollouts.env.virtual = false
    Rollouts.env.showing = "none"
    if Rollouts.isRolling() then
        Rollouts.env.showing = "live"
    end
    updateWindow()
end