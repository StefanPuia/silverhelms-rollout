local LibStub = _G.LibStub
local AceGUI = LibStub("AceGUI-3.0")

local function commonMainWindow(content, children)
    local width, height = content:GetSize()
    if children[1] then
        local rollList = children[1]
        rollList.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20)
        rollList.frame:SetSize(280, height - 15)
    end

    if children[2] then
        local headerCurrentAction = children[2]
        headerCurrentAction.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
        headerCurrentAction.label:SetSize(width * 0.3, 40)
    end

    if children[3] then
        local timeLeft = children[3]
        timeLeft.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 285, -5)
        timeLeft.label:SetSize(width * 0.5, 40)
    end
end

AceGUI:RegisterLayout("MainWindowNone",
    function(content, children)
        local width, height = content:GetSize()

        commonMainWindow(content, children)

        if children[4] then
            local rollHistory = children[4]
            rollHistory.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, -35)
            rollHistory.frame:SetSize(width - 280, height - 40)
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
            currentRoll.frame:SetSize(width - 280, 95)
        end

        if children[5] then
            local rollHistory = children[5]
            rollHistory.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, -110)
            rollHistory.frame:SetSize(width - 280, height - 115)
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
            currentRoll.frame:SetSize(width - 280, 145)
        end

        if children[5] then
            local rollHistory = children[5]
            rollHistory.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 280, -160)
            rollHistory.frame:SetSize(width - 280, height - 165)
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
            local rollType = children[1]
            rollType.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -5)
            rollType.label:SetSize(width * 0.2, 40)
        end

        if children[2] then
            local item = children[2]
            item.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 50, 0)
            item.frame:SetSize(width * 0.75, 40)
            item.label:SetSize(width * 0.75 - 32, 40)
        end

        if children[3] then
            local owner = children[3]
            owner.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -35)
            owner.frame:SetSize(width, 40)
            owner.label:SetSize(width, 40)
        end
    end
)

AceGUI:RegisterLayout("RollInfoVirtual",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local rollType = children[1]
            rollType.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -30)
            rollType.label:SetSize(100, 40)
        end

        if children[2] then
            local item = children[2]
            item.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 100, -25)
            item.frame:SetSize(width * 0.75, 40)
            item.label:SetSize(width * 0.75 - 32, 40)
        end

        if children[3] then
            local owner = children[3]
            owner.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -60)
            owner.frame:SetSize(width, 40)
            owner.label:SetSize(width, 40)
        end

        if children[4] then
            local status = children[4]
            status.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            status.label:SetSize(width, 40)
        end

        if children[5] then
            local winner = children[5]
            winner.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -85)
            winner.frame:SetSize(width, 40)
            winner.label:SetSize(width, 40)
        end
    end
)

AceGUI:RegisterLayout("RollListRowLayout",
    function(content, children)
        local width = 280

        if children[1] then
            local roll = children[1]
            roll.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            roll.label:SetSize(35, 30)
        end

        if children[2] then
            local player = children[2]
            player.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 35, 0)
            player.label:SetSize(180, 15)
        end

        if children[3] then
            local guildRank = children[3]
            guildRank.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20)
            guildRank.label:SetSize(width, 15)
        end

        if children[4] then
            local failMesage = children[4]
            failMesage.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20)
            failMesage.frame:SetSize(width, 30)
            failMesage.label:SetSize(width, 30)
        end
    end
)

AceGUI:RegisterLayout("HistoryViewFrame",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local pendingRollsButton = children[1]
            pendingRollsButton.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            pendingRollsButton.frame:SetSize(100, 35)
        end

        if children[2] then
            local rollsHistoryButton = children[2]
            rollsHistoryButton.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 100, 0)
            rollsHistoryButton.frame:SetSize(100, 35)
        end

        if children[3] then
            local pendingRolls = children[3]
            pendingRolls.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -20)
            pendingRolls.frame:SetSize(width, height - 10)
        end
    end
)

AceGUI:RegisterLayout("PendingRollRow",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local item = children[1]
            item.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            item.frame:SetSize(32, 32)
        end

        if children[2] then
            local owner = children[2]
            owner.frame:SetPoint("TOPLEFT", content, "LEFT", 50, 16)
            owner.frame:SetSize(100, 20)
        end

        if children[3] then
            local timestamp = children[3]
            timestamp.frame:SetPoint("TOPLEFT", content, "LEFT", 455, 16)
            timestamp.label:SetSize(255, 20)
        end

        if children[4] then
            local beginRollBtn = children[4]
            beginRollBtn.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -130, 0)
            beginRollBtn.frame:SetSize(90, 32)
        end

        if children[5] then
            local removeRollBtn = children[5]
            removeRollBtn.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -40, 0)
            removeRollBtn.frame:SetSize(40, 32)
        end
    end
)

AceGUI:RegisterLayout("HistoryRollRow",
    function(content, children)
        local width, height = content:GetSize()

        if children[1] then
            local item = children[1]
            item.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
            item.frame:SetSize(32, 32)
        end

        if children[2] then
            local owner = children[2]
            owner.frame:SetPoint("TOPLEFT", content, "LEFT", 50, 16)
            owner.label:SetSize(200, 20)
        end

        if children[3] then
            local winner = children[3]
            winner.frame:SetPoint("TOPLEFT", content, "LEFT", 250, 16)
            winner.label:SetSize(200, 20)
        end

        if children[4] then
            local timestamp = children[4]
            timestamp.frame:SetPoint("TOPLEFT", content, "LEFT", 455, 16)
            timestamp.label:SetSize(255, 20)
        end

        if children[5] then
            local viewRollBtn = children[5]
            viewRollBtn.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -180, 0)
            viewRollBtn.frame:SetSize(65, 32)
        end

        if children[6] then
            local restartRollBtn = children[6]
            restartRollBtn.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -115, 0)
            restartRollBtn.frame:SetSize(75, 32)
        end

        if children[7] then
            local removeRollBtn = children[7]
            removeRollBtn.frame:SetPoint("TOPLEFT", content, "TOPRIGHT", -40, 0)
            removeRollBtn.frame:SetSize(40, 32)
        end
    end
)