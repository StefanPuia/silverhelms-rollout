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

local queue = {
    enabled = false,
    originalSize = 0,
    rolls = {}
}

Rollouts.ui.isEnqueued = function(rollObject)
    for i,roll in ipairs(queue.rolls) do
        if roll.original == rollObject then
            return true
        end
    end
    return false
end

Rollouts.ui.getQueueButtonText = function()
    local text = queue.enabled and ("Queuing Jobs (" .. #queue.rolls .. "/" .. queue.originalSize .. ")") or "Queue Pending Jobs"
    return Rollouts.utils.colour(text, queue.enabled and "gray" or nil)
end

Rollouts.ui.prepareQueue = function()
    if not queue.enabled then
        local pending = Rollouts.utils.getEitherDBOption("data", "rolls", "pending")
        queue.rolls = {}
        for i,v in ipairs(pending) do
            queue.rolls[i] = {
                original = v,
                parameter = Rollouts.utils.sanitizeRollEntryObject(v)
            }
        end
        queue.originalSize = #queue.rolls
        queue.enabled = true
        Rollouts.ui.enqueue()
    end
    updateWindow()
end

local function clearQueue()
    queue.enabled = false
    queue.originalSize = 0
    queue.rolls = {}
    updateWindow()
end

Rollouts.ui.enqueue = function()
    if queue.enabled then
        local pending = Rollouts.utils.getEitherDBOption("data", "rolls", "pending")

        if #queue.rolls == 0 then
            clearQueue()
        end

        if not Rollouts.isRolling() then
            local currentQueueItem = queue.rolls[1]
            if currentQueueItem then
                for i,pendingRoll in ipairs(pending) do
                    if currentQueueItem.original == pendingRoll then
                        table.remove(pending, i)
                        updateWindow()
                    end
                end
                Rollouts.beginRoll(currentQueueItem.parameter)
                Rollouts.setFinishCallback(function()
                    table.remove(queue.rolls, 1)
                    Rollouts.ui.showPendingTab()
                    Rollouts.ui.enqueue()
                end)
                Rollouts.setCancelCallback(function()
                    clearQueue()
                    Rollouts.ui.showPendingTab()
                end)
            end
        end
    end
end