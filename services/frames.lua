local LibStub = _G.LibStub
local AceGUI = LibStub("AceGUI-3.0")
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
local Frames = {}
Rollouts.frames = {}

----------------------
--- CREATE WIDGETS ---
----------------------
local function createSimpleGroup(layout, width, height)
    local group = AceGUI:Create("SimpleGroup")
    group:SetLayout(layout or "Fill")

    if width then
        group:SetWidth(width)
    end

    if height then
        group:SetHeight(height)
    end

    return group
end

local function createInlineGroup(layout, width, height)
    local group = AceGUI:Create("InlineGroup")
    group:SetLayout(layout or "Fill")

    if width then
        group:SetWidth(width)
    end

    if height then
        group:SetHeight(height)
    end

    return group
end

local function createScrollContainer()
    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetAutoAdjustHeight(false)
    scrollContainer:SetLayout("Fill")

    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("Flow")
    scrollContainer:AddChild(scroll)

    return scrollContainer, scroll
end

local function createLabel(text, size, width, height, justifyH, justifyV)
    size = size or 20
    local label = AceGUI:Create("Label")
    label:SetText(text)
    label:SetFont(Rollouts.utils.getEitherDBOption("font"), size, "OUTLINE")
    if width then label:SetWidth(width) end
    if height then label:SetHeight(height) end
    if justifyH then label:SetJustifyH(justifyH) end
    if justifyV then label:SetJustifyV(justifyV) end

    return label
end

local function createIcon(image, label, width, anchor, height, fontSize)
    local icon = AceGUI:Create("Icon")
    icon:SetImage(image)
    width = width or 20
    height = height or width
    icon:SetImageSize(width, height)
    if label then
        icon:SetLabel(label)
    end
    anchor = anchor or "TOPLEFT"
    fontSize = fontSize or 20
    icon.image:SetPoint(anchor, icon.frame, anchor, 0, 0)
    icon.label:SetPoint(anchor, icon.frame, anchor, width + 5, (height - fontSize) / -2)
    icon.label:SetJustifyH("LEFT")
    icon.label:SetJustifyV("TOP")
    icon.label:SetHeight(height)
    icon.label:SetFont(Rollouts.utils.getEitherDBOption("font"), fontSize, "OUTLINE")
    return icon
end

local function createButton(text, onClick, autoWidth, disabled)
    local btn = AceGUI:Create("Button")
    if onClick then
        btn:SetCallback("OnClick", function() onClick() end)
    end
    btn:SetText(text)
    autoWidth = autoWidth ~= nil and autoWidth or true
    btn:SetAutoWidth(autoWidth)
    autoWidth = autoWidth ~= nil and autoWidth or false
    btn:SetDisabled(disabled)
    return btn
end

local function createEditBox(text, width, height, onEnterPressed, maxLetters, label, onEnter, onLeave)
    local editBox = AceGUI:Create("EditBox")
    if label then editBox:SetLabel(label) end
    if text then editBox:SetText(text) end
    if width then editBox:SetWidth(width) end
    if height then editBox:SetHeight(height) end
    if onEnter then editBox:SetCallback("OnEnter", onEnter) end
    if onLeave then editBox:SetCallback("OnLeave", onLeave) end
    if onEnterPressed then editBox:SetCallback("OnEnterPressed", onEnterPressed) end
    if maxLetters then editBox:SetMaxLetters(maxLetters) end
    return editBox
end

local function createDropDown(text, items, width, height, label, value, onValueChanged, onClosed)
    local dropDown = AceGUI:Create("Dropdown")
    if text then dropDown:SetText(text) end
    if width then dropDown:SetWidth(width) end
    if height then dropDown:SetHeight(height) end
    if label then dropDown:SetLabel(label) end
    if value then dropDown:SetValue(value) end
    if onValueChanged then dropDown:SetCallback("OnValueChanged", onValueChanged) end
    if onClosed then dropDown:SetCallback("OnClosed", onClosed) end
    local list = {}
    local order = {}
    if items then
        for i,item in pairs(items) do
            local value = item.value or i
            local text = item.text or item
            list[value] = text
            table.insert(order, value)
        end
        dropDown:SetList(list, order)
    end
    return dropDown
end

----------------------
--- HELPER METHODS ---
----------------------

local function statusColour(text, status)
    if status == "FINISHED" then return Rollouts.utils.colour(text, "green") end
    if status == "FINISHED-EARLY" then return Rollouts.utils.colour(text, "yellow") end
    if status == "CANCELLED" then return Rollouts.utils.colour(text, "red") end
    if status == "CONTINUED" or status == "MULTIPLE" then return Rollouts.utils.colour(text, "cyan") end
    return text
end

--------------------------------
--- CREATE CUSTOM COMPONENTS ---
--------------------------------

local function createItemIcon(itemLink, showLabel, width, anchor, height, fontSize)
    local item = itemLink and {GetItemInfo(itemLink)} or {}
    label = showLabel and item[2] or ""
    local itemIcon = createIcon(item[10], label, width, anchor, height, fontSize)
    if not item[10] then return itemIcon end
    itemIcon:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", widget.frame, "TOPLEFT", width, -1 * width)
        GameTooltip:SetHyperlink(item[2])
        GameTooltip:Show()
    end)
    itemIcon:SetCallback("OnLeave", function(widget)
        GameTooltip:Hide()
    end)
    itemIcon:SetCallback("OnClick", function(widget)
        if IsShiftKeyDown() and item[2] then
            ChatEdit_InsertLink(item[2])
        end
    end)
    return itemIcon
end

local function formatGuildRankName(guild, rank)
    return string.format("%s%s%s%s%s",
        Rollouts.utils.colour("<", "white"),
        Rollouts.utils.colour(guild, "green"),
        Rollouts.utils.colour("> [", "white"),
        Rollouts.utils.colour(rank, "green"),
        Rollouts.utils.colour("]", "white")
    )
end

local function formatSpecDisplay(classId, specId)
    if classId and specId then
        for i,v in ipairs(Rollouts.data.specs) do
            if v.value == classId .. "." .. specId then
                return v.text
            end
        end
    end
    return ""
end

local function createRollsContainer()
    local scrollContainer, scroll = createScrollContainer()
    local displayRoll = Rollouts.getDisplayRoll()
    local rolls = displayRoll and displayRoll.rolls or {}
    for i, rollEntry in ipairs(rolls) do
        local group = createSimpleGroup("RollListRowLayout", nil, 24)

        group:AddChild(createLabel(Rollouts.utils.colour(rollEntry.roll, rollEntry.failMessage and "red" or nil), 15))
        group:AddChild(createLabel(rollEntry.name, 15))

        group.frame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(group.frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", group.frame, "TOPLEFT")
            GameTooltip:SetText(rollEntry.name)
            if rollEntry.spec then GameTooltip:AddLine(formatSpecDisplay(rollEntry.class, rollEntry.spec)) end
            if rollEntry.guildName then GameTooltip:AddLine(formatGuildRankName(rollEntry.guildName, rollEntry.rankName)) end
            GameTooltip:AddLine(string.format("Rolled: %s", rollEntry.roll))
            if rollEntry.failMessage then
                GameTooltip:AddLine("Fail Reason: " .. Rollouts.utils.colour(rollEntry.failMessage, "red"))
            end
            GameTooltip:Show()
        end)
        group.frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        group.frame:SetScript("OnMouseUp", function()
            Rollouts.ui.manualFail(rollEntry)
        end)

        scroll:AddChild(group)
    end
    local container = createInlineGroup("Stretch")
    container:AddChild(scrollContainer)
    return container, scrollContainer
end

local function createRollInfoFrame()
    local container = createInlineGroup()
    local displayRoll = Rollouts.getDisplayRoll()
    if not displayRoll then return container end

    local rollInfoLayout = Rollouts.env.showing == "virtual" and "RollInfoVirtual" or "RollInfoLive"
    container:SetLayout(rollInfoLayout)

    container:AddChild(createItemIcon(displayRoll.itemLink, true, 32))
    container:AddChild(createLabel(Rollouts.data.rollTypes[displayRoll.rollType], 20, 100))
    container:AddChild(createLabel("Owner: " .. table.concat(displayRoll.owners, ", "), 20, 500))

    if Rollouts.env.showing == "virtual" then
        container:AddChild(createLabel(statusColour(displayRoll.status, displayRoll.status)))
        local winners = Rollouts.getWinners(displayRoll, true)
        container:AddChild(createLabel("Winner: " .. table.concat(winners, ", "), 20, 500))
    end
    return container
end

local function createPendingRollsFrame()
    local scrollContainer, scroll = createScrollContainer()
    local pending = Rollouts.utils.getEitherDBOption("data", "rolls", "pending")
    if pending and #pending > 0 then
        for i, row in ipairs(pending) do
            local group = createSimpleGroup("PendingRollRow", 1000, 40)

            local itemLink = createItemIcon(row.itemLink, false, 32)
            group:AddChild(itemLink)

            local owners = createLabel(table.concat(row.owners, ", "), 15)
            group:AddChild(owners)

            local timestamp = createLabel(statusColour(Rollouts.utils.formatStamp(row.time), row.status), 15)
            group:AddChild(timestamp)

            local enqueued = Rollouts.ui.isEnqueued(row)
            local beginRollBtnDisabled = Rollouts.isRolling() or enqueued
            local beginRollBtnText = Rollouts.utils.colour("Start Roll", beginRollBtnDisabled and "gray" or nil)
            local beginRollBtn = createButton(beginRollBtnText, function()
                Rollouts.beginRoll(row)
                table.remove(pending, i)
                Rollouts.ui.updateWindow()
            end, nil, beginRollBtnDisabled)
            group:AddChild(beginRollBtn)

            local removeRoll = createButton(Rollouts.utils.colour("X", enqueued and "gray" or nil), function()
                table.remove(pending, i)
                Rollouts.ui.updateWindow()
            end, enqueued)
            group:AddChild(removeRoll)

            scroll:AddChild(group)
        end
    end
    local container = createInlineGroup("Stretch")
    container:AddChild(scrollContainer)
    return container
end

local function createRollHistoryFrame()
    local scrollContainer, scroll = createScrollContainer()
    local history = Rollouts.utils.getEitherDBOption("data", "rolls", "history")
    if history and #history > 0 then
        for i, row in ipairs(history) do
            local group = createSimpleGroup("HistoryRollRow", 1000, 40)

            local itemLink = createItemIcon(row.itemLink, false, 32)
            group:AddChild(itemLink)

            local owners = createLabel(table.concat(row.owners, ", "), 15, 100, 15)
            group:AddChild(owners)

            local winner = createLabel(table.concat(Rollouts.getWinners(row, true), ", "), 15)
            group:AddChild(winner)

            local timestamp = createLabel(statusColour(Rollouts.utils.formatStamp(row.time), row.status), 15)
            group:AddChild(timestamp)


            local viewRollBtnDisabled = Rollouts.env.virtual == row
            local viewRollBtnText = Rollouts.utils.colour("View", viewRollBtnDisabled and "gray" or nil)
            local viewRollBtn = createButton(viewRollBtnText, function()
                Rollouts.ui.openHistoryRollView(row)
            end, nil, viewRollBtnDisabled)
            group:AddChild(viewRollBtn)

            local restartRollBtnDisabled = Rollouts.isRolling()
            local restartRollBtnText = Rollouts.utils.colour("Restart", restartRollBtnDisabled and "gray" or nil)
            local restartRollBtn = createButton(restartRollBtnText, function()
                Rollouts.restartRoll(row)
            end, nil, restartRollBtnDisabled)
            group:AddChild(restartRollBtn)

            local removeRollButton = createButton("X", function()
                table.remove(history, i)
                Rollouts.ui.updateWindow()
            end)
            group:AddChild(removeRollButton)

            scroll:AddChild(group)
        end
    end
    local container = createInlineGroup("Stretch")
    container:AddChild(scrollContainer)
    return container
end

local function createHistoryViewFrame()
    local container = createSimpleGroup()
    container:SetLayout("HistoryViewFrame")
    local rollDB = Rollouts.utils.getEitherDBOption("data", "rolls")

    local pendingBtnDisabled = Rollouts.env.historyTab == "pending"
    local pendingBtnText = Rollouts.utils.colour("Pending (" .. #rollDB.pending .. ")", pendingBtnDisabled and "gray" or nil)
    local pendingBtn = createButton(pendingBtnText, Rollouts.ui.showPendingTab, nil, pendingBtnDisabled)
    container:AddChild(pendingBtn)

    local historyBtnDisabled = Rollouts.env.historyTab == "history"
    local historyBtnText = Rollouts.utils.colour("History (" .. #rollDB.history .. ")", historyBtnDisabled and "gray" or nil)
    local historyButton = createButton(historyBtnText, Rollouts.ui.showHistoryTab, nil, historyBtnDisabled)
    container:AddChild(historyButton)

     if Rollouts.env.historyTab == "pending" then
        container:AddChild(createPendingRollsFrame())
        if #rollDB.pending > 1 then
            container:AddChild(createButton(Rollouts.ui.getQueueButtonText(), function()
                Rollouts.ui.prepareQueue()
            end, nil, Rollouts.ui.isEnqueued()))
            container:AddChild(createButton("Group Items", Rollouts.utils.groupPending))
        end
    elseif Rollouts.env.historyTab == "history" then
        container:AddChild(createRollHistoryFrame())
    end

    return container
end

local function createFinishEarlyButton()
    local disabled = not Rollouts.env.live
    local buttonText = Rollouts.utils.colour("Finish Now", disabled and "gray" or nil)
    return createButton(buttonText, function()
        Rollouts.handleWinningRolls()
        Rollouts.finishRoll()
    end, nil, disabled)
end

local function createPauseUnpauseButton()
    local disabled = not Rollouts.env.live
    local display = Rollouts.isPaused() and "Resume" or "Pause"
    local buttonText = Rollouts.utils.colour(display, disabled and "gray" or nil)
    return createButton(buttonText, Rollouts.pauseUnpause, nil, disabled)
end

local function createCancelRollButton()
    local disabled = not Rollouts.env.live
    local buttonText = Rollouts.utils.colour("Cancel", disabled and "gray" or nil)
    return createButton(buttonText, Rollouts.cancelRoll, nil, disabled)
end

local function createCloseDetailViewButton()
    return createButton("Close details", Rollouts.ui.closeHistoryRollView)
end

local function createDebugEditContainer()
    local container = createSimpleGroup("DebugEditContainerLayout")
    
    container:AddChild(createEditBox("Player", nil, 32, Rollouts.debug.setEditingData("name"), 15))
    container:AddChild(createEditBox("Guild", nil, 32, Rollouts.debug.setEditingData("guildName"), 15))
    container:AddChild(createEditBox("Rank", nil, 32, Rollouts.debug.setEditingData("rankName"), 15))
    container:AddChild(createButton("Append Roll", Rollouts.debug.addRollFromEditingData))
    
    container:AddChild(createDropDown("Specialization", Rollouts.data.specs, nil, 32, nil, "6.250", Rollouts.debug.setEditingData("classAndSpec")))
    container:AddChild(createEditBox("50", nil, 32, Rollouts.debug.setEditingData("roll"), 15))
    container:AddChild(createEditBox("Equipped", nil, 32, Rollouts.debug.setEditingData("equipped"), 15))

    return container
end

local function createDebugHistoryContainer()
    local scrollContainer, scroll = createScrollContainer()
    local debugData = Rollouts.env.debugData
    local rolls = debugData and debugData.rolls or {}
    for i, rollEntry in ipairs(rolls) do
        local name, roll, guildName, rankName, classId, spec, equipped = unpack(rollEntry)
        local group = createSimpleGroup("DebugRollHistoryRow", 480, 35)

        group:AddChild(createLabel(name, 15))
        group:AddChild(createLabel(roll, 15))
        group:AddChild(createButton("X", function()
            table.remove(rolls, i)
            Rollouts.frames.debugWindow.updateHistory()
        end))
        group:AddChild(createButton("Append", function()
            Rollouts.appendRoll(name, roll, guildName, rankName, classId, spec, equipped)
        end))

        group.frame:SetScript("OnEnter", function()
            GameTooltip:SetOwner(group.frame, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", group.frame, "TOPLEFT")
            GameTooltip:SetText(name)
            if spec then GameTooltip:AddLine(formatSpecDisplay(classId, spec)) end
            if guildName then GameTooltip:AddLine(formatGuildRankName(guildName, rankName)) end
            GameTooltip:AddLine(string.format("Rolled: %s", roll))
            GameTooltip:Show()
        end)
        group.frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        group.frame:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        scroll:AddChild(group)
    end
    local container = createInlineGroup("Stretch")
    container:AddChild(scrollContainer)
    return container, scrollContainer
end

-------------------
--- MAIN WINDOW ---
-------------------

local function getMainWindowToDoLayout()
    local mainWindowLayout = "MainWindowNone"
    if Rollouts.env.showing == "live" then mainWindowLayout = "MainWindowLive" end
    if Rollouts.env.showing == "virtual" then mainWindowLayout = "MainWindowVirtual" end
    return mainWindowLayout
end

local function updateWindowContents()
    local window = Frames.mainWindow
    if not window then return end

    window:ReleaseChildren()
    window.currentLayout = getMainWindowToDoLayout()
    window:SetLayout(window.currentLayout)

    -- roll list
    window.rollsContainer = createRollsContainer()
    window:AddChild(window.rollsContainer)
    -- header labels
    window:AddChild(createLabel("Status: " .. Rollouts.getHeaderStatus()))
    window.timeLeftLabel = createLabel("Time Left: " .. Rollouts.getTimeLeft())
    window:AddChild(window.timeLeftLabel)

    local settingsIcon = createIcon(136243, nil, 35)
    settingsIcon:SetCallback("OnClick", function()
        Rollouts.ui.toggleSettings()
    end)
    window:AddChild(settingsIcon)

    -- current roll info
    if Rollouts.env.showing == "live" or Rollouts.env.showing == "virtual" then
        window:AddChild(createRollInfoFrame())
    end

    -- roll history tabs
    local rollHistoryFrame = createHistoryViewFrame()
    window:AddChild(rollHistoryFrame)
    window.currentHistoryTab = Rollouts.env.historyTab

    -- buttons
    if Rollouts.env.showing == "virtual" then
        window:AddChild(createCloseDetailViewButton())
    else
        window:AddChild(createCancelRollButton())
        window:AddChild(createFinishEarlyButton())
        window.pauseButton = createPauseUnpauseButton()
        window:AddChild(window.pauseButton)
    end
    window:DoLayout()
end

local function createMainWindow()
    local window = AceGUI:Create("Rollouts-Window")
    _G.RolloutsMainWindow = window
    table.insert(UISpecialFrames, "RolloutsMainWindow")
    Frames.mainWindow = window
    window.frame:SetMinResize(900, 420)
    window.frame:SetMaxResize(1300, 1000)
    window:SetTitle("Rollouts")
    window:EnableResize(true)
    window:SetCallback("OnClose", function() Rollouts.frames.mainWindow.hide() end)
    local windowData = Rollouts.env.mainWindowData
    if windowData.size then window.frame:SetSize(unpack(windowData.size)) else window.frame:SetSize(1200, 500) end
    if windowData.point then
        local region1, parent, region2, x, y = unpack(windowData.point)
        window.frame:SetPoint(region1, window.frame:GetParent(), region2, x, y)
    end
    updateWindowContents()
end

local function hideMainWindow()
    if Frames.mainWindow then
        local windowData = Rollouts.env.mainWindowData
        windowData.point = {Frames.mainWindow:GetPoint()}
        windowData.size = {Frames.mainWindow.frame:GetSize()}
        Frames.mainWindow:Hide()
        Frames.mainWindow = nil
    end
    Rollouts.frames.mainWindow.shown = false
end

local function showMainWindow()
    if Frames.mainWindow then
        hideMainWindow()
    end
    createMainWindow()
    Frames.mainWindow:Show()
    Frames.mainWindow.frame:StopMovingOrSizing()
    Rollouts.frames.mainWindow.shown = true
end

local function updateMainWindow()
    local toDoLayout = getMainWindowToDoLayout()
    if Frames.mainWindow and toDoLayout == Frames.mainWindow.currentLayout
        and toDoLayout == "MainWindowLive" and Frames.mainWindow.currentHistoryTab == Rollouts.env.historyTab then
        Frames.mainWindow.rollsContainer:ReleaseChildren()
        local rollsContainer, scroll = createRollsContainer()
        Frames.mainWindow.rollsContainer:AddChild(scroll)
        Frames.mainWindow.timeLeftLabel:SetText("Time Left: " .. Rollouts.getTimeLeft())
        Frames.mainWindow.pauseButton:SetText(Rollouts.isPaused() and "Resume" or "Pause")
        Frames.mainWindow:DoLayout()
    else
        if Rollouts.frames.mainWindow.shown then
            updateWindowContents()
        end
    end
end

local function getWindowSize(window, dim)
    if window then
        local width, height = window.frame:GetSize()
        local size = { width = width, height = height }
        return size[dim]
    else
        return -1
    end
end

Rollouts.frames.mainWindow = {
    shown = false,
    show = showMainWindow,
    hide = hideMainWindow,
    update = updateMainWindow,
    getWidth = function() return getWindowSize(Frames.mainWindow, "width") end,
    getHeight = function() return getWindowSize(Frames.mainWindow, "height") end
}

--------------------
--- DEBUG WINDOW ---
--------------------

local function createDebugWindow()
    local window = AceGUI:Create("Rollouts-Window")
    _G.RolloutsDebugWindow = window
    table.insert(UISpecialFrames, "RolloutsDebugWindow")
    Frames.debugWindow = window
    window:SetTitle("Rollouts Debug")
    window.frame:SetSize(500, 500)
    window:EnableResize(true)
    window.frame:SetMinResize(500, 500)
    window.frame:SetMaxResize(500, 1000)
    window:SetCallback("OnClose", function() Rollouts.frames.debugWindow.hide() end)
    window:SetLayout("DebugWindowLayout")

    window:AddChild(createDebugEditContainer())
    window.historyContainer = createDebugHistoryContainer()
    window:AddChild(window.historyContainer)
end

local function updateDebugWindowHistory()
    local window = Frames.debugWindow
    if window then
        local container, scroll = createDebugHistoryContainer()
        window.historyContainer:ReleaseChildren()
        window.historyContainer:AddChild(scroll)
        window:DoLayout()
    end
end

local function hideDebugWindow()
    if Frames.debugWindow then
        Frames.debugWindow:Hide()
        Frames.debugWindow = nil
    end
    Rollouts.frames.debugWindow.shown = false
end

local function showDebugWindow()
    if Frames.debugWindow then
        hideDebugWindow()
    end
    createDebugWindow()
    Frames.debugWindow:Show()
    Rollouts.frames.debugWindow.shown = true
end

Rollouts.frames.debugWindow = {
    shown = false,
    show = showDebugWindow,
    hide = hideDebugWindow,
    updateHistory = updateDebugWindowHistory
}