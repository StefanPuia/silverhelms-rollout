local LibStub = _G.LibStub
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1-eq")
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")

local currentRoll = nil
local isPaused = false
local timeLeft = 0
local lastTick = 0
local callbacks = {
    finish = nil,
    cancel = nil,
    rulePredicate = nil
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

Rollouts.cancelRoll = function()
    if currentRoll ~= nil then
        timeLeft = 0
        currentRoll.status = "CANCELLED"
        Rollouts.appendToHistory(currentRoll)
        Rollouts.ui.openHistoryRollView(currentRoll)
        currentRoll = nil
        Rollouts.env.live = nil
        Rollouts.ui.showHistoryTab()
        if callbacks.cancel then
            callbacks.cancel()
        end
    end
end

Rollouts.finishRoll = function()
    if currentRoll ~= nil then
        currentRoll.status = timeLeft == 0 and "FINISHED" or "FINISHED-EARLY"
        timeLeft = 0
        Rollouts.appendToHistory(currentRoll)
        Rollouts.ui.openHistoryRollView(currentRoll)
        currentRoll = nil
        Rollouts.env.live = nil
        Rollouts.ui.showHistoryTab()
        if callbacks.finish then
            callbacks.finish()
        end
    end
end

Rollouts.setFinishCallback = function(callbackFinish)
    callbacks.finish = callbackFinish
end

Rollouts.setCancelCallback = function(callbackCancel)
    callbacks.cancel = callbackCancel
end

Rollouts.beginRoll = function(rollEntry, isRestart, rulePredicate, ruleMessage)
    LGIST:Rescan()
    ruleMessage = ruleMessage and (". " .. ruleMessage) or ""
    if currentRoll == nil then
        if isRestart ~= true then
            callbacks.finish = nil
            callbacks.cancel = nil
            callbacks.rulePredicate = nil
        end
        if rulePredicate then callbacks.rulePredicate = rulePredicate end

        currentRoll = Rollouts.utils.sanitizeRollEntryObject(rollEntry)
        Rollouts.env.live = currentRoll
        Rollouts.env.showing = "live"

        timeLeft = Rollouts.utils.getEitherDBOption("rollTimeLimit")
        lastTick = GetServerTime()
        isPaused = false

        currentRoll.itemInfo = {GetItemInfo(currentRoll.itemLink)}
        local itemSlot = currentRoll.itemInfo[9]
        currentRoll.equippable = Rollouts.data.slots[itemSlot] ~= nil and #Rollouts.data.slots[itemSlot] > 0
        if not currentRoll.equippable then currentRoll.rollType = 1 end -- if not equippable, change roll type to greed

        Rollouts.ui.updateWindow()
        local countDisplay = #currentRoll.owners > 1 and ("x" .. #currentRoll.owners .. " ") or ""
        Rollouts.chat.sendWarning("Roll for " .. countDisplay
            .. (currentRoll.itemInfo[2] or "") .. " " .. (Rollouts.data.rollTypes[currentRoll.rollType] or "") .. ruleMessage)
    end
end

Rollouts.restartRoll = function(rollEntry)
    local newInstance = Rollouts.utils.sanitizeRollEntryObject(rollEntry)
    newInstance.time = GetServerTime()
    Rollouts.beginRoll(newInstance)
end

local function getRollPoints(roll)
    if not roll then return 0 end

    local order = {
        guild = 100000,
        guildRank = 10000,
        ilvl = 1000,
        roll = 1
    }

    -- sort owner at the bottom
    -- local rollName = Rollouts.utils.simplifyName(roll.name)
    -- if currentRoll ~= nil and Rollouts.utils.indexOf(currentRoll.owners, function(owner)
    --     return Rollouts.utils.simplifyName(owner) == rollName
    -- end) > 0 then
    --     return -1
    -- end

    local points = (roll.roll and tonumber(roll.roll) or 0) * order.roll

    -- guild ranking
    if Rollouts.utils.getEitherDBOption("guildRanking", "enabled") then
        points = points + (roll.guild or 0) * order.guild + (roll.rank or 0) * order.guildRank
    end

    -- ilvl threshold
    if roll.equipped ~= nil and currentRoll ~= nil and currentRoll.itemInfo[4] ~= nil then
        local threshold = Rollouts.utils.getEitherDBOption("minIlvlThreshold") or 0
        local ilvl = currentRoll.itemInfo[4] or 0

        for _, eqItem in ipairs(roll.equipped) do
            local rollIlvl = ({GetItemInfo(eqItem)})[4] or 0
            local delta = ilvl - rollIlvl
            if delta > 0 and delta >= threshold then
                points = points + order.ilvl
            end
        end
    end


    if roll.failMessage ~= nil then return -1/points end
    return points
end

local function sortRolls()
    if currentRoll ~= nil then
        table.sort(currentRoll.rolls, function(a, b)
            local pointsA = getRollPoints(a)
            local pointsB = getRollPoints(b)
            if pointsA ~= pointsB then return pointsA > pointsB end
            return Rollouts.utils.simplifyName(a.name) < Rollouts.utils.simplifyName(b.name)
        end)
    end
end

local function hasSubsequentRolls()
    return Rollouts.utils.getEitherDBOption("restartIfNoRolls") and currentRoll.rollType > Rollouts.utils.getEitherDBOption("lowestRestart")
end

local function identicalRolls(roll1, roll2)
    return getRollPoints(roll1) == getRollPoints(roll2) and roll1.failMessage == nil and roll2.failMessage == nil
end

Rollouts.getWinners = function(rollObj, justNames)
    rollObj = rollObj or currentRoll
    if not rollObj then return {} end
    if rollObj.status == "CANCELLED" then return {} end
    justNames = justNames or false
    local winning = {}
    local availableSpots = #rollObj.owners

    for i = 1, availableSpots do
        if rollObj.rolls[i] and rollObj.rolls[i].failMessage == nil then
            table.insert(winning, rollObj.rolls[i])
        end
    end

    local lastRoll = winning[#winning]
    for i = availableSpots + 1, #rollObj.rolls do
        if identicalRolls(rollObj.rolls[i], lastRoll) then
            table.insert(winning, rollObj.rolls[i])
        else
            break
        end
    end

    if justNames then
        local winningNames = {}
        for i = 1, #winning do
            table.insert(winningNames, winning[i].name)
        end
        -- print(table.concat(winningNames, " "))
        return winningNames
    end
    -- print(Rollouts.utils.stringify(winning))
    return winning
end

local function giveAway(owner, winner)
    Rollouts.chat.sendMessage(Rollouts.utils.simplifyName(winner, true) .. " trade " .. Rollouts.utils.simplifyName(owner, true))
end

local function continueRoll(owners, rollType, status, rulePredicate, ruleMessage)
    timeLeft = Rollouts.utils.getEitherDBOption("rollTimeLimit")
    currentRoll.status = status or "CONTINUED"
    Rollouts.appendToHistory(currentRoll)
    local auxRollObject = Rollouts.utils.makeRollEntryObject(currentRoll.itemLink, owners, rollType)
    currentRoll = nil
    Rollouts.beginRoll(auxRollObject, true, rulePredicate, ruleMessage)
end

local function whisperReturned(message, owners)
    owners = owners or {}
    for i, owner in ipairs(owners) do
        SendChatMessage(message, "WHISPER", GetDefaultLanguage("player"), Rollouts.utils.qualifyUnitName(owner))
    end
end

Rollouts.handleWinningRolls = function()
    if not currentRoll then return end
    local winning = Rollouts.getWinners(currentRoll)
    local availableSpots = #currentRoll.owners
    currentRoll.remainingOwners = Rollouts.utils.cloneArray(currentRoll.owners)
    local message = "Roll ended on " .. (currentRoll.itemInfo[2] or "") .. ". "
    local whisper = "No one rolled for your " .. currentRoll.itemLink .. ". You can scrap it!"

    if #winning > availableSpots then
        local distinct = {}
        local sameRolls = {}
        for i = 1, #winning - 1 do
            if not identicalRolls(winning[i], winning[#winning]) then
                table.insert(distinct, winning[i])
            else
                table.insert(sameRolls, winning[i].name)
            end
        end
        table.insert(sameRolls, winning[#winning].name)

        for i = 1, #distinct do
            giveAway(currentRoll.remainingOwners[1], distinct[i].name)
            table.remove(currentRoll.remainingOwners, 1)
        end

        Rollouts.chat.sendMessage("Multiple players rolled the same. " .. table.concat(sameRolls, ", ") .. " please roll again.")
        continueRoll(currentRoll.remainingOwners, currentRoll.rollType, "MULTIPLE", function(rollEntry)
            return Rollouts.utils.indexOf(sameRolls, function(win)
                return Rollouts.utils.simplifyName(rollEntry.name, true) == Rollouts.utils.simplifyName(win, true)
            end) > 0
        end, "Only expecting rolls from " .. table.concat(sameRolls, ", "))

    elseif #winning == availableSpots then
        Rollouts.chat.sendMessage(message)
        for i = 1, #winning do
            giveAway(currentRoll.owners[i], winning[i].name)
        end
        Rollouts.finishRoll()

    elseif #winning < availableSpots then
        Rollouts.chat.sendMessage(message)
        for i = 1, #winning do
            giveAway(currentRoll.remainingOwners[1], winning[i].name)
            table.remove(currentRoll.remainingOwners, 1)
        end
        if hasSubsequentRolls() then
            continueRoll(currentRoll.remainingOwners, currentRoll.rollType - 1)
        else
            whisperReturned(whisper, currentRoll.remainingOwners)
            Rollouts.finishRoll()
        end

    else
        if not hasSubsequentRolls() then
            local message = message .. "No one rolled."
            Rollouts.chat.sendMessage(message)
            whisperReturned(whisper, currentRoll.owners)
            Rollouts.finishRoll()
        else
            continueRoll(currentRoll.owners, currentRoll.rollType - 1)
        end
    end
end

local function validateRoll(rollObject)
    local getEitherDBOption = Rollouts.utils.getEitherDBOption
    local failMessage = nil
    local itemSubType = currentRoll.itemInfo[7]
    local itemSlot = currentRoll.itemInfo[9]

    local isClassMaterial = (itemSlot ~= "INVTYPE_CLOAK" and itemSubType == "Cloth")
            or itemSubType == "Leather" or itemSubType == "Mail" or itemSubType == "Plate"

    if getEitherDBOption("enableArmorTypeValidation") and currentRoll.rollType > 1 
            and isClassMaterial and Rollouts.data.classArmorType[rollObject.class] ~= itemSubType then
        failMessage = Rollouts.data.failMessages["ARMOR_TYPE"]
    end

    if getEitherDBOption("enableWeaponTypeValidation") and currentRoll.rollType > 1
            and Rollouts.utils.contains({"INVTYPE_WEAPON", "INVTYPE_SHIELD", "INVTYPE_RANGEDRIGHT"}, itemSlot) then
        if rollObject.spec ~= nil then
            if not Rollouts.utils.contains(Rollouts.data.weaponProficiencies[rollObject.spec], itemSubType) then
                failMessage = Rollouts.data.failMessages["WEAPON_TYPE"]
            end
        elseif rollObject.class ~= nil then
            if not Rollouts.utils.canClassEquip(rollObject.class, itemSubType) then
                failMessage = Rollouts.data.failMessages["CLASS_WEAPON_TYPE"]
            end
        end
    end

    local currentRollStats = Rollouts.utils.getItemMainStats(currentRoll.itemLink)
    if getEitherDBOption("enableStatValidation") and currentRollStats then
        local foundOSStat = false
        for _,stat in ipairs(currentRollStats) do
            if Rollouts.utils.contains(Rollouts.data.classStats[rollObject.class], stat) then
                foundOSStat = true
                break
            end
        end
        if currentRoll.rollType >= 2 and not foundOSStat then
            failMessage = Rollouts.data.failMessages["NOT_" .. Rollouts.data.rollTypes[currentRoll.rollType] .. "_STAT"]
        elseif currentRoll.rollType == 3
                and rollObject.spec
                and not Rollouts.utils.contains(currentRollStats, Rollouts.data.specStats[rollObject.spec]) then
            failMessage = Rollouts.data.failMessages["NOT_MS_STAT"]
        end
    end

    if getEitherDBOption("enableOwnerValidation") and Rollouts.utils.indexOf(currentRoll.owners, function(owner)
        return Rollouts.utils.simplifyName(rollObject.name) == Rollouts.utils.simplifyName(owner)
    end) > 0 then
        failMessage = Rollouts.data.failMessages["ROLL_OWNER"]
    end

    if callbacks.rulePredicate and not callbacks.rulePredicate(rollObject) then
        failMessage = Rollouts.data.failMessages["ROLL_RULES"]
    end

    rollObject.failMessage = failMessage
end

Rollouts.appendRoll = function(name, roll, guild, rank, classId, spec, equipped)
    if currentRoll ~= nil
            and not Rollouts.getRoll(name)
            and (Rollouts.utils.unitInGroup(name) and Rollouts.utils.unitInGroup("player") or not Rollouts.utils.unitInGroup("player"))
        then

        local rollObj = Rollouts.utils.makeRollObject(name, roll, guild, rank, classId, nil, spec, equipped)
        validateRoll(rollObj)

        table.insert(currentRoll.rolls, 1, rollObj)
        sortRolls()
        Rollouts.ui.updateWindow()
        return rollObj
    end
    return false
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
            validateRoll(roll)
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

Rollouts.pauseUnpause = function(force)
    isPaused = not isPaused
    if force ~= nil then isPaused = force end
    if not isPaused then
        tickSize = 0
    end
    Rollouts.ui.updateWindow()
end

Rollouts.isPaused = function ()
    return isPaused
end

Rollouts.rollTick = function()
    if currentRoll ~= nil then
        sortRolls()
        local currentTick = GetServerTime()
        local tickSize = currentTick - lastTick
        if tickSize > 0 then
            if not isPaused then
                timeLeft = timeLeft - tickSize
            end
            if timeLeft <= 0 then
                timeLeft = 0
                Rollouts.handleWinningRolls()
            else
                if not isPaused then
                    local rollCountdown = Rollouts.utils.getEitherDBOption("rollCountdown")
                    if timeLeft == rollCountdown then
                        Rollouts.chat.sendWarning(currentRoll.itemLink .. " Roll ending in " .. timeLeft)
                    elseif timeLeft < rollCountdown and timeLeft % 5 == 0 then
                        Rollouts.chat.sendWarning(currentRoll.itemLink .. " Roll ending in " .. timeLeft)
                    elseif timeLeft < rollCountdown and timeLeft < 5 then
                        Rollouts.chat.sendMessage(timeLeft)
                    end
                end
            end
        end
        lastTick = currentTick
    end
end