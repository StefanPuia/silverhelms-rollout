local LibStub = _G.LibStub
local AceGUI = LibStub("AceGUI-3.0")
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
local Frames = {}
Rollouts.frames = {}

-- local function autoLayoutSize(size, point, dimension)
--     if size == "auto" then
--         size = dimension - point
--     elseif string.sub(size, -1) == "%" then
--         size = tonumber(string.sub(size, 1, -2)) / 100 * dimension
--     end
--     return size
-- end

-- local function autoLayoutPosition(point, size, dimensions, padding, i)
--     size = size or {}
--     padding = padding or {}
--     i = i or 0

--     if string.sub(point[1], -1) == "%" then point[1] = (tonumber(string.sub(point[1], 1, -2)) / 100 * dimensions[1]) end
--     if string.sub(point[2], -1) == "%" then point[2] = (tonumber(string.sub(point[2], 1, -2)) / 100 * dimensions[2]) end

--     sizeX = tonumber(size[1]) ~= nil and size[1] or 0
--     sizeX = autoLayoutSize(sizeX, point[1], dimensions[1])
--     sizeY = tonumber(size[2]) ~= nil and size[2] or 0
--     sizeY = autoLayoutSize(sizeY, point[2], dimensions[2])
--     padX = padding[1] or 0
--     padY = padding[2] or 0


--     return point[1] + (i * (sizeX + padX)), -1 * (point[2] + (i * (sizeY + padY)))
-- end

-- local function init()
--     local layouts = {
        
--     }

--     for layoutName, layout in pairs(layouts) do
--         AceGUI:RegisterLayout(layoutName,
--             function(content, children)
--                 local width, height = content:GetSize()
--                 if #layout > 0 then
--                     for k,v in ipairs(layout) do
--                         if children[k] then
--                             local frame = children[k].frame
--                             if v.point then
--                                 local x, y = autoLayoutPosition(v.point, v.size, {width, height}, v.padding)
--                                 frame:SetPoint("TOPLEFT", content, v.anchor or "TOPLEFT", x, y)
--                             end
--                             if v.size then
--                                 frame:SetWidth(autoLayoutSize(v.size[1], v.point[1], width))
--                                 frame:SetHeight(autoLayoutSize(v.size[2], v.point[2], height))
--                                 frame:GetSize()
--                             end
--                         end
--                     end
--                 else
--                     for i = 0, (#children - 1) do
--                         local frame = children[i + 1].frame
--                         local x, y = autoLayoutPosition(layout.point, layout.size, {width, height}, layout.padding, i)
--                         frame:SetPoint("TOPLEFT", content, layout.anchor or "TOPLEFT", x, y)
--                         frame:SetWidth(autoLayoutSize(layout.size[1], layout.point[1], width))
--                         frame:SetHeight(autoLayoutSize(layout.size[2], layout.point[2], width))
--                         frame:GetSize()
--                     end
--                 end
--             end
--         )
--     end
-- end

local function getWindowSize()
    local size = {0, 0}
    if Frames.mainWindow then
        return Frames.mainWindow.frame:GetSize()
    end
end

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

----------------------
--- HELPER METHODS ---
----------------------

local function statusColour(text, status)
    if status == "FINISHED" then return Rollouts.utils.colour(text, "green") end
    if status == "FINISHED-EARLY" then return Rollouts.utils.colour(text, "yellow") end
    if status == "CANCELLED" then return Rollouts.utils.colour(text, "red") end
    if status == "CONTINUED" then return Rollouts.utils.colour(text, "cyan") end
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
        GameTooltip:SetOwner(widget.frame, "ANCHOR_BOTTOMRIGHT")
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

local function createRollsContainer()
    local scrollContainer, scroll = createScrollContainer()
    local displayRoll = Rollouts.getDisplayRoll()
    local rolls = displayRoll and displayRoll.rolls or {}
    for i, rollEntry in ipairs(rolls) do
        local group = createSimpleGroup("RollListRowLayout", nil, 50)

        group:AddChild(createLabel(rollEntry.roll, 15))
        group:AddChild(createLabel(rollEntry.name, 15))
        group:AddChild(createLabel(rollEntry.rankName, 15))
        group:AddChild(createLabel(Rollouts.utils.colour(rollEntry.failMesage, "red"), 15))

        scroll:AddChild(group)
    end
    local container = createInlineGroup("Stretch")
    container:AddChild(scrollContainer)
    return container
end

local function createRollInfoFrame()
    local container = createInlineGroup()
    local displayRoll = Rollouts.getDisplayRoll()
    if not displayRoll then return container end

    local rollInfoLayout = Rollouts.env.showing == "virtual" and "RollInfoVirtual" or "RollInfoLive"
    container:SetLayout(rollInfoLayout)
    
    container:AddChild(createItemIcon(displayRoll.itemLink, true, 32))
    container:AddChild(createLabel(Rollouts.data.rollTypes[displayRoll.rollType], 20, 100))
    container:AddChild(createLabel("Owner: " .. displayRoll.owner, 20, 500))

    if Rollouts.env.showing == "virtual" then
        container:AddChild(createLabel(statusColour(displayRoll.status, displayRoll.status)))
        local winnerText = ""
        if #displayRoll.rolls and displayRoll.rolls[1] then
            winnerText = "Winner: " .. (displayRoll.rolls[1].name or "")
            winnerText = winnerText .. " (" .. displayRoll.rolls[1].roll .. ")"
        end
        container:AddChild(createLabel(winnerText, 20, 500))
    end
    return container
end

local function createPendingRollsFrame()
    local scrollContainer, scroll = createScrollContainer()
    local pending = Rollouts.utils.getEitherDBOption("data", "rolls", "pending")
    if pending and #pending then
        for i, row in ipairs(pending) do
            local group = createSimpleGroup("PendingRollRow", 1000, 40)

            local itemLink = createItemIcon(row.itemLink, false, 32)
            group:AddChild(itemLink)

            local owner = createLabel(row.owner, 15)
            group:AddChild(owner)
            
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
    if history and #history then
        for i, row in ipairs(history) do
            local group = createSimpleGroup("HistoryRollRow", 1000, 40)

            local itemLink = createItemIcon(row.itemLink, false, 32)
            group:AddChild(itemLink)

            local owner = createLabel(row.owner, 15, 100, 15)
            group:AddChild(owner)

            local winner = createLabel(#row.rolls and row.rolls[1] and row.rolls[1].name or "", 15, 100, 15)
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
            end))
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
        Rollouts.getWinningRolls()
        Rollouts.finishRoll()
    end, nil, disabled)
end

local function createCancelRollButton()
    local disabled = not Rollouts.env.live
    local buttonText = Rollouts.utils.colour("Cancel", disabled and "gray" or nil)
    return createButton(buttonText, Rollouts.cancelRoll, nil, disabled)
end

local function createCloseDetailViewButton()
    return createButton("Close details", Rollouts.ui.closeHistoryRollView)
end

--------------------
--- MINIMAP ICON ---
--------------------
createMinimapButton = function()
    if Frames.miniMapIcon ~= nil then return Frames.miniMapIcon end

    -- Create minimap button
    local minibtn = CreateFrame("Button", nil, Minimap)
    minibtn:SetFrameLevel(8)
    minibtn:SetSize(32,32)
    minibtn:SetMovable(true)

    minibtn:SetNormalTexture(1373910)
    minibtn:SetPushedTexture(1373910)
    minibtn:SetHighlightTexture(1373910)
    
    local myIconPos = 0
    
    -- Control movement
    local function UpdateMapBtn()
        local Xpoa, Ypoa = GetCursorPosition()
        local Xmin, Ymin = Minimap:GetLeft(), Minimap:GetBottom()
        Xpoa = Xmin - Xpoa / Minimap:GetEffectiveScale() + 70
        Ypoa = Ypoa / Minimap:GetEffectiveScale() - Ymin - 70
        myIconPos = math.deg(math.atan2(Ypoa, Xpoa))
        minibtn:ClearAllPoints()
        minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * cos(myIconPos)), (80 * sin(myIconPos)) - 52)
    end
    
    minibtn:RegisterForDrag("LeftButton")
    minibtn:SetScript("OnDragStart", function()
        minibtn:StartMoving()
        minibtn:SetScript("OnUpdate", UpdateMapBtn)
    end)
    
    minibtn:SetScript("OnDragStop", function()
        minibtn:StopMovingOrSizing();
        minibtn:SetScript("OnUpdate", function()
            local point1, frame, point2, offX, offY = minibtn:GetPoint()
            Rollouts.utils.setDBOption({offX, offY}, "minimapIconPos")
        end)
        UpdateMapBtn();
    end)
    
    -- Set position
    minibtn:ClearAllPoints();
    local savedPos = Rollouts.utils.getEitherDBOption("minimapIconPos")
    minibtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", savedPos[1], savedPos[2])
    
    -- Control clicks
    minibtn:SetScript("OnClick", function()
        Rollouts.ui.toggleMainWindow()
    end)
    Frames.miniMapIcon = minibtn
end

Rollouts.frames.displayMinimapButton = function()
    local pref = Rollouts.utils.getEitherDBOption("showMinimapIcon")

    if not Frames.miniMapIcon then createMinimapButton() end

    if pref then
        Frames.miniMapIcon:Show()
    else
        Frames.miniMapIcon:Hide()
    end
end

-------------------
--- MAIN WINDOW ---
-------------------

local function createMainWindow()
    local window = AceGUI:Create("Window")
    Frames.mainWindow = window
    window.frame:SetMinResize(1200, 500)
    window.frame:SetMaxResize(1300, 1000)
    window:SetTitle("Rollouts")
    window:EnableResize(not Rollouts.isRolling())
    window:SetCallback("OnClose", function() Rollouts.frames.mainWindow.hide() end)

    -- window:SetCallback("OnEnter", Rollouts.ui.pauseTick)
    -- window:SetCallback("OnLeave", Rollouts.ui.resumeTick)
    local windowData = Rollouts.env.mainWindowData
    if windowData.size then window.frame:SetSize(unpack(windowData.size)) else window.frame:SetSize(1200, 500) end
    if windowData.point then
        local region1, parent, region2, x, y = unpack(windowData.point)
        window.frame:SetPoint(region1, window.frame:GetParent(), region2, x, y)
    end

    local mainWindowLayout = "MainWindowNone"
    if Rollouts.env.showing == "live" then mainWindowLayout = "MainWindowLive" end
    if Rollouts.env.showing == "virtual" then mainWindowLayout = "MainWindowVirtual" end
    window:SetLayout(mainWindowLayout)

    -- roll list
    window:AddChild(createRollsContainer())
    -- header labels
    window:AddChild(createLabel("Status: " .. Rollouts.getHeaderStatus()))
    window:AddChild(createLabel("Time Left: " .. Rollouts.getTimeLeft()))

    local settingsIcon = createIcon(136243, nil, 35)
    settingsIcon:SetCallback("OnClick", function()
        LibStub("AceConfigDialog-3.0"):Open("Rollouts")
    end)
    window:AddChild(settingsIcon)

    -- current roll info
    if Rollouts.env.showing == "live" or Rollouts.env.showing == "virtual" then
        window:AddChild(createRollInfoFrame())
    end

    -- roll history tabs
    window:AddChild(createHistoryViewFrame())

    -- buttons
    if Rollouts.env.showing == "virtual" then
        window:AddChild(createCloseDetailViewButton())
    else
        window:AddChild(createFinishEarlyButton())
        window:AddChild(createCancelRollButton())
    end
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
    if Rollouts.frames.mainWindow.shown then
        hideMainWindow()
        showMainWindow()
    end
end

Rollouts.frames.mainWindow = {
    shown = false,
    show = showMainWindow,
    hide = hideMainWindow,
    update = updateMainWindow,
}