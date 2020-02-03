local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")

local currentRoll = nil
local timeLeft = 0
local lastTick = 0
local callbacks = {
    finish = nil,
    cancel = nil
}

Rollouts.appendToHistory = function(roll)
    dbRolls = Rollouts.utils.getDBOption("data", "rolls")
    table.insert(dbRolls.history, 1, roll)
    Rollouts.ui.updateWindow()
end

Rollouts.appendToPending = function(roll)
    dbRolls = Rollouts.utils.getDBOption("data", "rolls")
    table.insert(dbRolls.pending, roll)
    Rollouts.ui.updateWindow()
end

Rollouts.isRolling = function()
    return currentRoll ~= nil
end

local function resetCallbacks()
    callbacks.finish = nil
    callbacks.cancel = nil
end

Rollouts.cancelRoll = function()
    if currentRoll ~= nil then
        timeLeft = 0
        currentRoll.status = "CANCELLED"
        Rollouts.appendToHistory(currentRoll)
        Rollouts.ui.openHistoryRollView(currentRoll)
        currentRoll = nil
        Rollouts.env.live = nil
        Rollouts.ui.showHistoryTab()
        if callbacks.cancel then callbacks.cancel() end
        resetCallbacks()
    end
end

Rollouts.finishRoll = function(whisperBack)
    if currentRoll ~= nil then
        if whisperBack then
            local message = "No one rolled for your " .. currentRoll.itemLink .. ". You can scrap it!"
            SendChatMessage(message, "WHISPER", GetDefaultLanguage("player"), Rollouts.utils.qualifyUnitName(currentRoll.owner))
        end
        currentRoll.status = timeLeft == 0 and "FINISHED" or "FINISHED-EARLY"
        timeLeft = 0
        Rollouts.appendToHistory(currentRoll)
        Rollouts.ui.openHistoryRollView(currentRoll)
        currentRoll = nil
        Rollouts.env.live = nil
        Rollouts.ui.showHistoryTab()
        if callbacks.finish then callbacks.finish() end
        resetCallbacks()
    end
end

Rollouts.setFinishCallback = function(callbackFinish)
    callbacks.finish = callbackFinish
end

Rollouts.setCancelCallback = function(callbackCancel)
    callbacks.cancel = callbackCancel
end

Rollouts.beginRoll = function(rollEntry)
    if currentRoll == nil then
        currentRoll = Rollouts.utils.sanitizeRollEntryObject(rollEntry)
        Rollouts.env.live = currentRoll
        Rollouts.env.showing = "live"

        timeLeft = Rollouts.utils.getEitherDBOption("rollTimeLimit")
        lastTick = GetServerTime()

        currentRoll.itemInfo = {GetItemInfo(currentRoll.itemLink)}
        local itemSlot = currentRoll.itemInfo[9]
        currentRoll.equippable = Rollouts.data.slots[itemSlot] ~= nil and #Rollouts.data.slots[itemSlot] > 0
        if not currentRoll.equippable then currentRoll.rollType = 1 end -- if not equippable, change roll type to greed

        Rollouts.ui.updateWindow()
        Rollouts.chat.sendWarning("Roll for " .. currentRoll.itemLink .. " " .. Rollouts.data.rollTypes[currentRoll.rollType])
    end
end

Rollouts.restartRoll = function(rollEntry)
    Rollouts.beginRoll(rollEntry)
end

local function sortRolls()
    if currentRoll ~= nil then
        table.sort(currentRoll.rolls, function(a, b)
            local pointsA = a.guild * 10000 + a.rank * 1000 + tonumber(a.roll)
            local pointsB = b.guild * 10000 + b.rank * 1000 + tonumber(b.roll)

            pointsA = a.failMessage and 0 or pointsA
            pointsB = b.failMessage and 0 or pointsB

            return pointsA > pointsB
        end)
    end
end

local function hasSubsequentRolls()
    return Rollouts.utils.getEitherDBOption("restartIfNoRolls") and currentRoll.rollType > Rollouts.utils.getEitherDBOption("lowestRestart")
end

Rollouts.getWinningRolls = function()
    local winning = {}
    if #currentRoll.rolls then
        table.insert(winning, currentRoll.rolls[1])
    end

    for i = 2, #currentRoll.rolls do
        if currentRoll.rolls[i].roll == winning[1].roll
                and currentRoll.rolls[i].guild == winning[1].guild
                and currentRoll.rolls[i].rank == winning[1].rank then
            table.insert(currentRoll.rolls[i])
        end
    end

    if #winning > 1 then
        local wins = {}
        for k,v in ipairs(winning) do table.insert(wins, v.name) end
        Rollouts.chat.sendMessage("Multiple players rolled the same. " .. table.concat(wins, ", ") .. " please roll again.")
        return true
    elseif #winning == 1 then
        local message = "Roll ended on " .. currentRoll.itemLink .. ". " .. Rollouts.utils.qualifyUnitName(winning[1].name, true) .. " won."
        message = message .. " Please trade " .. currentRoll.owner .. "."
        Rollouts.chat.sendMessage(message)
        return true
    else
        if not hasSubsequentRolls() then
            local message = "Roll ended on " .. currentRoll.itemLink .. ". No one rolled."
            Rollouts.chat.sendMessage(message)
        end
        return false
    end
end

Rollouts.appendRoll = function(name, roll, guild, rank, classId, spec, equipped)
    if currentRoll ~= nil
            and not Rollouts.getRoll(name)
            and Rollouts.utils.unitInGroup(name)
        then

        local failMessage = nil
        local itemMaterial = currentRoll.itemInfo[7]
        local itemSlot = currentRoll.itemInfo[9]

        local isClassMaterial = (itemSlot ~= "INVTYPE_CLOAK" and itemMaterial == "Cloth") or itemMaterial == "Leather" or itemMaterial == "Mail" or itemMaterial == "Plate"
        
        if currentRoll.rollType > 1 and isClassMaterial and Rollouts.data.classArmorType[classId] ~= itemMaterial then
            failMessage = Rollouts.data.failMessages["ARMOR_TYPE"]
        end

        if Rollouts.utils.simplifyName(name) == Rollouts.utils.simplifyName(currentRoll.owner) then
            failMessage = Rollouts.data.failMessages["ROLL_OWNER"]
        end

        table.insert(currentRoll.rolls, 1, Rollouts.utils.makeRollObject(name, roll, guild, rank, class, failMessage, spec, equipped))
        sortRolls()
        Rollouts.ui.updateWindow()
    end
end

Rollouts.getRoll = function(name)
    if currentRoll ~= nil then
        name = Rollouts.utils.simplifyName(name)
        for i, roll in ipairs(currentRoll.rolls) do
            if Rollouts.utils.simplifyName(roll.name) == name then
                return roll
            end
        end
    end
    return nil
end

Rollouts.updateRoll = function(name, guild, rank, class, spec, equipped)
    if currentRoll ~= nil then
        local roll = Rollouts.getRoll(name)
        if roll then
            if guild then roll.guild = guild end
            if rank then roll.rank = rank end
            if class then roll.class = class end
            if spec then roll.spec = spec end
            if equipped then roll.equipped = equipped end
        end
    end
end


Rollouts.getHeaderStatus = function()
    if currentRoll ~= nil then
        return Rollouts.utils.colour("Rolling", "green")
    end
    return Rollouts.utils.colour("Standby", "yellow")
end

Rollouts.getTimeLeft = function()
    if timeLeft > 20 then return Rollouts.utils.colour(timeLeft, "green") end
    if timeLeft > 10 then return Rollouts.utils.colour(timeLeft, "yellow") end
    return Rollouts.utils.colour(timeLeft, "red")
end

Rollouts.rollTick = function()
    if currentRoll ~= nil then
        local currentTick = GetServerTime()
        local tickSize = currentTick - lastTick
        if tickSize > 0 then
            timeLeft = timeLeft - tickSize
            if timeLeft <= 0 then
                timeLeft = 0
                if Rollouts.getWinningRolls() then return Rollouts.finishRoll() end
                if hasSubsequentRolls() then
                    timeLeft = Rollouts.utils.getEitherDBOption("rollTimeLimit")
                    currentRoll.status = "CONTINUED"
                    Rollouts.appendToHistory(currentRoll)
                    local auxRollObject = Rollouts.utils.makeRollEntryObject(currentRoll.itemLink, currentRoll.owner, currentRoll.rollType - 1)
                    currentRoll = nil
                    Rollouts.beginRoll(auxRollObject)
                else
                    Rollouts.finishRoll(true)
                end
            else
                local rollCountdown = Rollouts.utils.getEitherDBOption("rollCountdown")
                if timeLeft == rollCountdown then
                    Rollouts.chat.sendWarning(currentRoll.itemLink .. " Roll ending in " .. timeLeft)
                end
                if timeLeft < rollCountdown then
                    Rollouts.chat.sendMessage(timeLeft)
                end
            end
        end
        lastTick = currentTick
    end
end