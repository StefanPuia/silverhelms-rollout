local LibStub = _G.LibStub
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
            Rollouts.appendRoll(Rollouts.utils.colourizeUnit(name), roll, guildName, guildRankName, classId)
        end
    end
end

function Rollouts:HandleWhisper(e, ...)
    local message = select(1, ...)
    local source = select(2, ...)

    if Rollouts.utils.unitInGroup(source) and Rollouts.utils.stringContainsItem(message) and Rollouts.utils.getEitherDBOption("enableWhisperAppend") then
        local itemString = select(3, strfind(message, "|H(.-)|h"))
        if itemString ~= nil then
            local itemInfo = {GetItemInfo(itemString)}
            if itemInfo[2] ~= nil then
                source = Rollouts.utils.colourizeUnit(source)
                Rollouts.appendToPending(Rollouts.utils.makeRollEntryObject(itemInfo[2], source))
                return
            end
        end

    end
end

Rollouts.chat.sendWarning = function(message)
    if UnitInRaid("player") and (
            UnitIsGroupLeader("player", "LE_PARTY_CATEGORY_HOME")
            or UnitIsGroupLeader("player", "LE_PARTY_CATEGORY_INSTANCE")
            or UnitIsGroupAssistant("player", "LE_PARTY_CATEGORY_HOME")
            or UnitIsGroupAssistant("player", "LE_PARTY_CATEGORY_INSTANCE")
        ) then
        SendChatMessage(message, "RAID_WARNING", GetDefaultLanguage("player"), nil)
    else
        Rollouts.chat.sendMessage(message)
    end
end

Rollouts.chat.sendMessage = function(message)
    local chatType = "SAY"
    if UnitInRaid("player") then
        chatType = "RAID"
    elseif UnitInParty("player") then
        chatType = "PARTY"
    end
    SendChatMessage(message, chatType, GetDefaultLanguage("player"), nil)
end