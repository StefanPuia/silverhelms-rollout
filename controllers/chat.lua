local LibStub = _G.LibStub
local LGIST = LibStub:GetLibrary("LibGroupInSpecT-1.1-eq")
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
Rollouts.chat = {}

function Rollouts:OnEnable()
    Rollouts:RegisterEvent("CHAT_MSG_SYSTEM", "HandleRollMessage")
    Rollouts:RegisterEvent("CHAT_MSG_WHISPER", "HandleWhisper")
end

function Rollouts:HandleRollMessage(e, message)
    local name, roll, minRoll, maxRoll = message:match("^(.+) rolls (%d+) %((%d+)%-(%d+)%)$")
    if name and roll and minRoll and maxRoll then
        if tonumber(minRoll) == Rollouts.utils.getEitherDBOption("roll", "min")
                and tonumber(maxRoll) == Rollouts.utils.getEitherDBOption("roll", "max") then

            local guildName, guildRankName = GetGuildInfo(name)
            local classId = select(3, UnitClass(name))

            if not guildName and not classId then
                local guildMember = Rollouts.utils.queryGuildMembers(name)
                if guildMember then
                    guildName = GetGuildInfo("player")
                    guildRankName = guildMember.rank
                    classId = Rollouts.data.classes[guildMember.classFileName]
                end
            end

            local specId = nil
            local equipped = nil
            local guid = UnitGUID(name)
            local cachedInfo = LGIST:GetCachedInfo(guid)
            if cachedInfo then
                specId = cachedInfo.global_spec_id
                if Rollouts.env.live then
                    local rollSlot = Rollouts.env.live.itemInfo[9]
                    if not rollSlot or rollSlot == "" or rollSlot == nil then
                        rollSlot = Rollouts.utils.getRollSlotForToken(Rollouts.env.live.itemLink)
                    end
                    local slots = Rollouts.data.slots[rollSlot]
                    equipped = {}
                    for _,slot in ipairs(slots) do
                        table.insert(equipped, cachedInfo.equipped[slot])
                    end
                end
            else
                LGIST:Rescan(guid)
            end

            Rollouts.appendRoll(Rollouts.utils.colourizeUnit(name, classId), roll, guildName, guildRankName, classId, specId, equipped)
        end
    end
end

function Rollouts:HandleWhisper(e, ...)
    local message = select(1, ...)
    local source = select(2, ...)

    if Rollouts.utils.unitInGroup(source) and Rollouts.utils.stringContainsItem(message) and Rollouts.utils.getEitherDBOption("enableWhisperAppend") then
        local items = {}
        for capture in string.gmatch(message, "|H(.-)|h") do
            table.insert(items, capture)
        end
        for i, itemString in ipairs(items) do
            if itemString ~= nil then
                local itemInfo = {GetItemInfo(itemString)}
                if itemInfo[2] ~= nil then
                    source = Rollouts.utils.colourizeUnit(source)
                    Rollouts.appendToPending(Rollouts.utils.makeRollEntryObject(itemInfo[2], { source }))
                end
            end
        end
    end
end

local function sendSafe(message, channel)
    SendChatMessage(message, channel)
end

Rollouts.chat.sendWarning = function(message)
    if UnitInRaid("player") and (
            UnitIsGroupLeader("player", "LE_PARTY_CATEGORY_HOME")
            or UnitIsGroupLeader("player", "LE_PARTY_CATEGORY_INSTANCE")
            or UnitIsGroupAssistant("player", "LE_PARTY_CATEGORY_HOME")
            or UnitIsGroupAssistant("player", "LE_PARTY_CATEGORY_INSTANCE")
        ) then
        sendSafe(message, "RAID_WARNING")
    else
        Rollouts.chat.sendMessage(message)
    end
end

Rollouts.chat.sendMessage = function(message)
    if UnitInRaid("player") then
        sendSafe(message, "RAID")
    elseif UnitInParty("player") then
        sendSafe(message, "PARTY")
    end
    Rollouts.utils.printDebug(message)
end