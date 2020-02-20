local LibStub = _G.LibStub
local AceGUI = LibStub("AceGUI-3.0")
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")

AceGUI:RegisterLayout("Stretch",
    function(content, children)
        local element = children[1]
        if element then
            element.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            element.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
        end
    end
)

local function commonMainWindow(content, children)
    local rollList = children[1]
    local status = children[2]
    local timeLeft = children[3]
    local settings = children[4]

    if status then
        local headerCurrentAction = status
        headerCurrentAction.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        headerCurrentAction.label:SetSize(280, 40)
        headerCurrentAction.label:SetJustifyV("TOP")
    end

    if timeLeft then
        local timeLeft = timeLeft
        timeLeft.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, 0)
        timeLeft.label:SetSize(500, 40)
        timeLeft.label:SetJustifyV("TOP")
    end

    if rollList and status then
        rollList.frame:SetPoint("TOPLEFT", status.frame, "BOTTOMLEFT", 0, 0)
        rollList.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
        rollList.frame:SetWidth(280)
    end

    if settings then
        settings.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
        settings.frame:SetSize(35, 35)
    end

    return rollList, status, timeLeft, settings
end

AceGUI:RegisterLayout("MainWindowNone",
    function(content, children)
        local rollList, status, timeLeft, settings = commonMainWindow(content, children)
        local rollHistory = children[5]
        local buttonFinishRoll = children[6]
        local buttonCancelRoll = children[7]

        if rollHistory and timeLeft then
            rollHistory.frame:SetPoint("TOPLEFT", timeLeft.frame, "BOTTOMLEFT", 1, -17)
            rollHistory.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 3)
        end

        if buttonFinishRoll and buttonCancelRoll then
            buttonFinishRoll.frame:SetPoint("RIGHT", buttonCancelRoll.frame, "LEFT", 0, 0)
            buttonFinishRoll.frame:SetSize(100, 35)
        end

        if buttonCancelRoll then
            buttonCancelRoll.frame:SetPoint("RIGHT", settings.frame, "LEFT", 0, 0)
            buttonCancelRoll.frame:SetSize(100, 35)
        end
    end
)

AceGUI:RegisterLayout("MainWindowLive",
    function(content, children)
        local rollList, status, timeLeft, settings = commonMainWindow(content, children)
        local currentRoll = children[5]
        local rollHistory = children[6]
        local buttonPauseRoll = children[7]
        local buttonFinishRoll = children[8]
        local buttonCancelRoll = children[9]

        if buttonPauseRoll and settings then
            buttonPauseRoll.frame:SetPoint("RIGHT", settings.frame, "LEFT", 0, 0)
            buttonPauseRoll.frame:SetSize(100, 35)
        end

        if buttonFinishRoll and buttonPauseRoll then
            buttonFinishRoll.frame:SetPoint("RIGHT", buttonPauseRoll.frame, "LEFT", 0, 0)
            buttonFinishRoll.frame:SetSize(100, 35)
        end

        if buttonCancelRoll and buttonFinishRoll then
            buttonCancelRoll.frame:SetPoint("RIGHT", buttonFinishRoll.frame, "LEFT", 0, 0)
            buttonCancelRoll.frame:SetSize(100, 35)
        end

        if currentRoll and rollList then
            currentRoll.frame:SetPoint("TOPLEFT", rollList.frame, "TOPRIGHT", 0, 0)
            currentRoll.frame:SetPoint("TOPRIGHT", settings.frame, "BOTTOMRIGHT", 0, 0)
            currentRoll.frame:SetHeight(100)
        end

        if rollHistory then
            rollHistory.frame:SetPoint("TOPLEFT", currentRoll.frame, "BOTTOMLEFT", 0, 0)
            rollHistory.frame:SetPoint("TOPRIGHT", currentRoll.frame, "BOTTOMRIGHT", 0, 0)
            rollHistory.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 280, 3)
            rollHistory.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 3)
        end
    end
)

AceGUI:RegisterLayout("MainWindowVirtual",
    function(content, children)
        local rollList, status, timeLeft, settings = commonMainWindow(content, children)
        local currentRoll = children[5]
        local rollHistory = children[6]
        local btnCloseDetails = children[7]

        if btnCloseDetails then
            btnCloseDetails.frame:SetPoint("RIGHT", settings.frame, "LEFT", 0, 0)
            btnCloseDetails.frame:SetSize(150, 35)
        end

        if currentRoll and timeLeft and btnCloseDetails then
            currentRoll.frame:SetPoint("TOPLEFT", timeLeft.frame, "BOTTOMLEFT", 1, 0)
            currentRoll.frame:SetPoint("TOPRIGHT", settings.frame, "BOTTOMRIGHT", 0, 0)
            currentRoll.frame:SetHeight(145)
        end

        if rollHistory then
            rollHistory.frame:SetPoint("TOPLEFT", currentRoll.frame, "BOTTOMLEFT", 0, 0)
            rollHistory.frame:SetPoint("TOPRIGHT", currentRoll.frame, "BOTTOMRIGHT", 0, 0)
            rollHistory.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 280, 3)
            rollHistory.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 3)
        end
    end
)

AceGUI:RegisterLayout("RollInfoLive",
    function(content, children)
        local item = children[1]
        local rollType = children[2]
        local owner = children[3]

        if item then
            item.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            item.frame:SetPoint("BOTTOMRIGHT", content, "TOPRIGHT", 0, -40)
        end

        if rollType and item then
            rollType.frame:SetPoint("TOPLEFT", item.frame, "BOTTOMLEFT", 0, 0)
            rollType.frame:SetSize(80, 40)
        end

        if owner and item and rollType then
            owner.frame:SetPoint("TOPLEFT", rollType.frame, "TOPRIGHT", 5, 0)
            owner.frame:SetPoint("TOPRIGHT", item.frame, "BOTTOMRIGHT", 0, 0)
            owner.label:SetPoint("TOPLEFT", rollType.frame, "TOPRIGHT", 5, 0)
            owner.label:SetPoint("TOPRIGHT", item.frame, "BOTTOMRIGHT", 0, 0)
        end
    end
)

AceGUI:RegisterLayout("RollInfoVirtual",
    function(content, children)
        local item = children[1]
        local rollType = children[2]
        local owner = children[3]
        local status = children[4]
        local winner = children[5]

        if item and status then
            item.frame:SetPoint("TOPLEFT", status.frame, "BOTTOMLEFT", 0, -5)
            item.frame:SetPoint("TOPRIGHT", status.frame, "BOTTOMRIGHT", 0, -5)
            item.frame:SetHeight(40)
            item.label:SetHeight(40)
        end

        if rollType and item then
            rollType.frame:SetPoint("TOPLEFT", item.frame, "BOTTOMLEFT", 0, 0)
            rollType.label:SetSize(100, 40)
        end

        if owner and rollType and item then
            owner.frame:SetPoint("TOPLEFT", rollType.frame, "TOPRIGHT", 5, 0)
            owner.frame:SetPoint("TOPRIGHT", item.frame, "BOTTOMRIGHT", 0, 0)
            local itemWidth = item.frame:GetWidth()
            owner.frame:SetSize(itemWidth, 40)
            owner.label:SetSize(itemWidth, 40)
        end

        if status then
            status.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            status.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            status.label:SetHeight(40)
        end

        if winner and owner and rollType then
            winner.frame:SetPoint("TOPLEFT", rollType.frame, "BOTTOMLEFT", 0, -5)
            winner.frame:SetPoint("TOPRIGHT", owner.frame, "TOPRIGHT", 0, -5)
            winner.label:SetHeight(40)
        end
    end
)

AceGUI:RegisterLayout("RollListRowLayout",
    function(content, children)
        local roll = children[1]
        local player = children[2]

        if player then
            player.frame:SetPoint("LEFT", content, "LEFT", 0, 0)
            player.frame:SetPoint("RIGHT", content, "RIGHT", -40, 0)
        end

        if roll and player then
            roll.frame:SetPoint("LEFT", player.frame, "RIGHT", 0, 0)
            roll.frame:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        end
    end
)

AceGUI:RegisterLayout("HistoryViewFrame",
    function(content, children)
        local pendingRollsButton = children[1]
        local rollsHistoryButton = children[2]
        local pendingRolls = children[3]
        local queuePendingJobs = children[4]

        if pendingRollsButton then
            pendingRollsButton.frame:SetPoint("TOPLEFT", content, "TOPLEFT", -1, 1)
            pendingRollsButton.frame:SetSize(120, 35)
        end

        if rollsHistoryButton and pendingRollsButton then
            rollsHistoryButton.frame:SetPoint("LEFT", pendingRollsButton.frame, "RIGHT", 0, 0)
            rollsHistoryButton.frame:SetSize(120, 35)
        end

        if pendingRolls and pendingRollsButton then
            pendingRolls.frame:SetPoint("TOPLEFT", pendingRollsButton.frame, "BOTTOMLEFT", 1, 19)
            pendingRolls.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, -3)
        end

        if queuePendingJobs then
            queuePendingJobs.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 1, 1)
            queuePendingJobs.frame:SetSize(200, 35)
        end
    end
)

AceGUI:RegisterLayout("PendingRollRow",
    function(content, children)
        local item = children[1]
        local owner = children[2]
        local timestamp = children[3]
        local beginRollBtn = children[4]
        local removeRollBtn = children[5]

        if item then
            item.frame:SetPoint("LEFT", content, "LEFT", 5, 0)
            item.frame:SetSize(32, 32)
        end

        if owner and item then
            owner.frame:SetPoint("LEFT", item.frame, "RIGHT", 5, 0)
            owner.frame:SetSize(300, 20)
        end

        if timestamp and beginRollBtn then
            timestamp.frame:SetPoint("RIGHT", beginRollBtn.frame, "LEFT", 5, 0)
            timestamp.label:SetSize(255, 20)
            if Rollouts.frames.mainWindow.getWidth() < 1110 then
                timestamp.frame:Hide()
            else
                timestamp.frame:Show()
            end
        end

        if removeRollBtn then
            removeRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -5, 0)
            removeRollBtn.frame:SetSize(40, 32)
        end

        if beginRollBtn and removeRollBtn then
            beginRollBtn.frame:SetPoint("RIGHT", removeRollBtn.frame, "LEFT", -5, 0)
            beginRollBtn.frame:SetSize(120, 32)
        end
    end
)

AceGUI:RegisterLayout("HistoryRollRow",
    function(content, children)
        local item = children[1]
        local owner = children[2]
        local winner = children[3]
        local timestamp = children[4]
        local viewRollBtn = children[5]
        local restartRollBtn = children[6]
        local removeRollBtn = children[7]

        if item then
            item.frame:SetPoint("LEFT", content, "LEFT", 5, 0)
            item.frame:SetSize(32, 32)
        end

        if owner and item then
            owner.frame:SetPoint("LEFT", item.frame, "RIGHT", 5, 0)
            owner.frame:SetSize(200, 32)
            owner.label:SetSize(200, 32)
        end

        if winner and owner and viewRollBtn then
            winner.frame:SetPoint("LEFT", owner.frame, "RIGHT", 5, 0)
            winner.frame:SetPoint("RIGHT", timestamp.frame, "LEFT", 5, 0)
        end

        if timestamp and viewRollBtn then
            timestamp.frame:SetPoint("RIGHT", viewRollBtn.frame, "LEFT", 5, 0)
            timestamp.frame:SetSize(200, 32)
            if Rollouts.frames.mainWindow.getWidth() < 1110 then
                timestamp.frame:Hide()
            else
                timestamp.frame:Show()
            end
        end

        if viewRollBtn then
            viewRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -130, 0)
            viewRollBtn.frame:SetSize(65, 32)
        end

        if restartRollBtn then
            restartRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -50, 0)
            restartRollBtn.frame:SetSize(75, 32)
        end

        if removeRollBtn then
            removeRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -5, 0)
            removeRollBtn.frame:SetSize(40, 32)
        end
    end
)

AceGUI:RegisterLayout("DebugWindowLayout",
    function (content, children)
        local editContainer = children[1]
        local historyContainer = children[2]

        if editContainer then
            editContainer.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            editContainer.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            editContainer.frame:SetHeight(144)
        end

        if historyContainer and editContainer then
            historyContainer.frame:SetPoint("TOPLEFT", editContainer.frame, "BOTTOMLEFT", 0, 10)
            historyContainer.frame:SetPoint("TOPRIGHT", editContainer.frame, "BOTTOMRIGHT", 0, 10)
            historyContainer.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
            historyContainer.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
        end
    end
)

AceGUI:RegisterLayout("DebugEditContainerLayout",
    function (content, children)
        local width, height = content:GetSize()
        local halfSize = (width - 15) / 2

        local playerName = children[1]
        local guildName = children[2]
        local rankName = children[3]
        local appendRollBtn = children[4]

        local specName = children[5]
        local rollValue = children[6]
        local equipped = children[7]

        if playerName then
            playerName.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
            playerName.frame:SetWidth(halfSize)
        end

        if guildName and playerName then
            guildName.frame:SetPoint("TOPLEFT", playerName.frame, "BOTTOMLEFT", 0, -2)
            guildName.frame:SetPoint("TOPRIGHT", playerName.frame, "BOTTOMRIGHT", 0, -2)
            guildName.frame:SetWidth(halfSize)
        end

        if rankName and guildName then
            rankName.frame:SetPoint("TOPLEFT", guildName.frame, "BOTTOMLEFT", 0, -2)
            rankName.frame:SetPoint("TOPRIGHT", guildName.frame, "BOTTOMRIGHT", 0, -2)
            rankName.frame:SetWidth(halfSize)
        end

        if appendRollBtn and rankName then
            appendRollBtn.frame:SetPoint("TOPLEFT", rankName.frame, "BOTTOMLEFT", 0, -2)
            appendRollBtn.frame:SetPoint("TOPRIGHT", rankName.frame, "BOTTOMRIGHT", 0, -2)
            appendRollBtn.frame:SetHeight(32)
        end

        if specName and playerName then
            specName.frame:SetPoint("TOPLEFT", playerName.frame, "TOPRIGHT", 5, 0)
            specName.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, -5)
            specName.frame:SetWidth(halfSize)
        end

        if rollValue and specName then
            rollValue.frame:SetPoint("TOPLEFT", specName.frame, "BOTTOMLEFT", 0, -2)
            rollValue.frame:SetPoint("TOPRIGHT", specName.frame, "BOTTOMRIGHT", 0, -2)
            rollValue.frame:SetWidth(halfSize)
        end

        if equipped and rollValue then
            equipped.frame:SetPoint("TOPLEFT", rollValue.frame, "BOTTOMLEFT", 0, -2)
            equipped.frame:SetPoint("TOPRIGHT", rollValue.frame, "BOTTOMRIGHT", 0, -2)
            equipped.frame:SetWidth(halfSize)
        end
    end
)

AceGUI:RegisterLayout("DebugRollHistoryRow",
    function (content, children)
        local playerName = children[1]
        local rollValue = children[2]
        local deleteBtn = children[3]
        local appendBtn = children[4]

        if playerName then
            playerName.frame:SetPoint("LEFT", content, "LEFT", 0, 0)
            playerName.frame:SetSize(180, 27)
        end

        if rollValue and playerName then
            rollValue.frame:SetPoint("LEFT", playerName.frame, "RIGHT", 0, 0)
            rollValue.frame:SetSize(70, 27)
        end

        if deleteBtn then
            deleteBtn.frame:SetPoint("RIGHT", content, "RIGHT", 0, 0)
            deleteBtn.frame:SetSize(40, 27)
        end

        if appendBtn and deleteBtn then
            appendBtn.frame:SetPoint("RIGHT", deleteBtn.frame, "LEFT", 0, 0)
            appendBtn.frame:SetSize(100, 27)
        end
    end
)