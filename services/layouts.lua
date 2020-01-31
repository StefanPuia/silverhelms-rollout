local LibStub = _G.LibStub
local AceGUI = LibStub("AceGUI-3.0")

local function commonMainWindow(content, children)
    local width, height = content:GetSize()
    if children[1] then
        local rollList = children[1]
        rollList.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20)
        rollList.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 0, 0)
        rollList.frame:SetWidth(280)
    end

    if children[2] then
        local headerCurrentAction = children[2]
        headerCurrentAction.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, 5)
        headerCurrentAction.label:SetSize(width * 0.3, 40)
        headerCurrentAction.label:SetJustifyV("BOTTOM")
    end

    if children[3] then
        local timeLeft = children[3]
        timeLeft.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 285, 5)
        timeLeft.label:SetSize(width * 0.5, 40)
        timeLeft.label:SetJustifyV("BOTTOM")
    end
end

AceGUI:RegisterLayout("MainWindowNone",
    function(content, children)
        local width, height = content:GetSize()

        commonMainWindow(content, children)

        if children[4] then
            local rollHistory = children[4]
            rollHistory.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, -37)
            rollHistory.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 280, 3)
            rollHistory.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -37)
            rollHistory.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 3)
        end

        if children[5] then
            local buttonFinishRoll = children[5]
            buttonFinishRoll.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -200, 0)
            buttonFinishRoll.frame:SetSize(100, 35)
        end

        if children[6] then
            local buttonCancelRoll = children[6]
            buttonCancelRoll.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -100, 0)
            buttonCancelRoll.frame:SetSize(100, 35)
        end
    end
)

AceGUI:RegisterLayout("MainWindowLive",
    function(content, children)
        local width, height = content:GetSize()

        commonMainWindow(content, children)

        if children[4] then
            local currentRoll = children[4]
            currentRoll.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, -20)
            currentRoll.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -20)
            currentRoll.frame:SetHeight(100)
        end

        if children[5] then
            local rollHistory = children[5]
            rollHistory.frame:SetPoint("TOPLEFT", children[4].frame, "BOTTOMLEFT", 0, 0)
            rollHistory.frame:SetPoint("TOPRIGHT", children[4].frame, "BOTTOMRIGHT", 0, 0)
            rollHistory.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 280, 3)
            rollHistory.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 3)
        end

        if children[6] then
            local buttonFinishRoll = children[6]
            buttonFinishRoll.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -200, 0)
            buttonFinishRoll.frame:SetSize(100, 35)
        end

        if children[7] then
            local buttonCancelRoll = children[7]
            buttonCancelRoll.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -100, 0)
            buttonCancelRoll.frame:SetSize(100, 35)
        end
    end
)

AceGUI:RegisterLayout("MainWindowVirtual",
    function(content, children)
        local width, height = content:GetSize()

        commonMainWindow(content, children)

        if children[4] then
            local currentRoll = children[4]
            currentRoll.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, -20)
            currentRoll.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -20)
            currentRoll.frame:SetHeight(145)
            -- currentRoll.frame:SetSize(width - 280, 145)
        end

        if children[5] then
            local rollHistory = children[5]
            rollHistory.frame:SetPoint("TOPLEFT", children[4].frame, "BOTTOMLEFT", 0, 0)
            rollHistory.frame:SetPoint("TOPRIGHT", children[4].frame, "BOTTOMRIGHT", 0, 0)
            rollHistory.frame:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 280, 3)
            rollHistory.frame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 3)
        end

        if children[6] then
            local buttonCancelRoll = children[6]
            buttonCancelRoll.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -150, 0)
            buttonCancelRoll.frame:SetSize(150, 35)
        end
    end
)

AceGUI:RegisterLayout("RollInfoLive",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local item = children[1]
            item.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            item.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            item.frame:SetSize(width - 100, 40)
            item.label:SetSize(width - 100, 40)
        end

        if children[2] and children[1] then
            local rollType = children[2]
            rollType.frame:SetPoint("TOPLEFT", children[1].frame, "BOTTOMLEFT", 0, 0)
            rollType.frame:SetSize(100, 40)
        end

        if children[3] and children[1] and children[2] then
            local owner = children[3]
            owner.frame:SetPoint("TOPLEFT", children[2].frame, "TOPRIGHT", 5, 0)
            owner.frame:SetPoint("TOPRIGHT", children[1].frame, "BOTTOMRIGHT", 0, 0)
            local itemWidth = children[1].frame:GetWidth()
            owner.label:SetSize(itemWidth, 40)
            owner.frame:SetSize(itemWidth, 40)
        end
    end
)

AceGUI:RegisterLayout("RollInfoVirtual",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] and children[4] then
            local item = children[1]
            item.frame:SetPoint("TOPLEFT", children[4].frame, "BOTTOMLEFT", 0, -5)
            item.frame:SetPoint("TOPRIGHT", children[4].frame, "BOTTOMRIGHT", 0, -5)
            item.frame:SetHeight(40)
            item.label:SetHeight(40)
        end

        if children[2] and children[1] then
            local rollType = children[2]
            rollType.frame:SetPoint("TOPLEFT", children[1].frame, "BOTTOMLEFT", 0, 0)
            rollType.label:SetSize(100, 40)
        end

        if children[3] and children[2] and children[1] then
            local owner = children[3]
            owner.frame:SetPoint("TOPLEFT", children[2].frame, "TOPRIGHT", 5, 0)
            owner.frame:SetPoint("TOPRIGHT", children[1].frame, "BOTTOMRIGHT", 0, 0)
            local itemWidth = children[1].frame:GetWidth()
            owner.frame:SetSize(itemWidth, 40)
            owner.label:SetSize(itemWidth, 40)
        end

        if children[4] then
            local status = children[4]
            status.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            status.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            status.label:SetHeight(40)
        end

        if children[5] and children[3] and children[2] then
            local winner = children[5]
            winner.frame:SetPoint("TOPLEFT", children[2].frame, "BOTTOMLEFT", 0, -5)
            winner.frame:SetPoint("TOPRIGHT", children[3].frame, "TOPRIGHT", 0, -5)
            winner.label:SetHeight(40)
        end
    end
)

AceGUI:RegisterLayout("RollListRowLayout",
    function(content, children)
        local width = 280

        if children[1] then
            local roll = children[1]
            roll.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -5)
            roll.frame:SetSize(35, 30)
            roll.label:SetSize(35, 30)
        end

        if children[2] and children[1] then
            local player = children[2]
            player.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
            player.frame:SetPoint("TOPRIGHT", children[1].frame, "TOPLEFT", 5, 0)
            player.frame:SetSize(180, 30)
            player.label:SetSize(180, 30)
        end

        if children[3] and children[2] then
            local guildRank = children[3]
            guildRank.frame:SetPoint("TOPLEFT", children[2].frame, "BOTTOMLEFT", 0, -7)
            guildRank.frame:SetPoint("TOPRIGHT", children[2].frame, "BOTTOMRIGHT", 0, -7)
            guildRank.label:SetHeight(30)
        end

        if children[4] and children[1] then
            local failMesage = children[4]
            failMesage.frame:SetPoint("TOPRIGHT", children[1].frame, "BOTTOMRIGHT", 0, -7)
            failMesage.frame:SetSize(100, 30)
            failMesage.label:SetSize(100, 30)
        end
    end
)

AceGUI:RegisterLayout("HistoryViewFrame",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local pendingRollsButton = children[1]
            pendingRollsButton.frame:SetPoint("TOPLEFT", content, "TOPLEFT", -1, 1)
            pendingRollsButton.frame:SetSize(100, 35)
        end

        if children[2] then
            local rollsHistoryButton = children[2]
            rollsHistoryButton.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 100, 1)
            rollsHistoryButton.frame:SetSize(100, 35)
        end

        if children[3] then
            local pendingRolls = children[3]
            pendingRolls.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -15)
            pendingRolls.frame:SetSize(width + 1, height - 12)
        end

        if children[4] then
            local queuePendingJobs = children[4]
            queuePendingJobs.frame:SetPoint("TOPRIGHT", content, "TOPRIGHT", -1, 1)
            queuePendingJobs.frame:SetSize(200, 35)
        end
    end
)

AceGUI:RegisterLayout("PendingRollRow",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local item = children[1]
            item.frame:SetPoint("LEFT", content, "LEFT", 5, 0)
            item.frame:SetSize(32, 32)
        end

        if children[2] and children[1] then
            local owner = children[2]
            owner.frame:SetPoint("LEFT", children[1].frame, "RIGHT", 5, 0)
            owner.frame:SetSize(300, 20)
        end

        if children[3] and children[2] then
            local timestamp = children[3]
            timestamp.frame:SetPoint("LEFT", children[2].frame, "RIGHT", 5, 0)
            timestamp.label:SetSize(255, 20)
        end

        if children[5] then
            local removeRollBtn = children[5]
            removeRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -5, 0)
            removeRollBtn.frame:SetSize(40, 32)
        end

        if children[4] and children[5] then
            local beginRollBtn = children[4]
            beginRollBtn.frame:SetPoint("RIGHT", children[5].frame, "LEFT", -5, 0)
            beginRollBtn.frame:SetSize(120, 32)
        end
    end
)

AceGUI:RegisterLayout("HistoryRollRow",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local item = children[1]
            item.frame:SetPoint("LEFT", content, "LEFT", 5, 0)
            item.frame:SetSize(32, 32)
        end

        if children[2] then
            local owner = children[2]
            owner.frame:SetPoint("LEFT", content, "LEFT", 50, 0)
            owner.label:SetSize(200, 32)
        end

        if children[3] then
            local winner = children[3]
            winner.frame:SetPoint("LEFT", content, "LEFT", 250, 0)
            winner.label:SetSize(200, 32)
        end

        if children[4] then
            local timestamp = children[4]
            timestamp.frame:SetPoint("LEFT", content, "LEFT", 455, 0)
            timestamp.label:SetSize(255, 32)
        end

        if children[5] then
            local viewRollBtn = children[5]
            viewRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -130, 0)
            viewRollBtn.frame:SetSize(65, 32)
        end

        if children[6] then
            local restartRollBtn = children[6]
            restartRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -50, 0)
            restartRollBtn.frame:SetSize(75, 32)
        end

        if children[7] then
            local removeRollBtn = children[7]
            removeRollBtn.frame:SetPoint("RIGHT", content, "RIGHT", -5, 0)
            removeRollBtn.frame:SetSize(40, 32)
        end
    end
)