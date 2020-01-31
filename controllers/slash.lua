local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
local SLASH_COMMAND = "rollout"

local function printHelp()
    Rollouts.Print("Rollout commands:")
    Rollouts.Print("/" .. SLASH_COMMAND .. " - show the rollout window")
    Rollouts.Print("/" .. SLASH_COMMAND .. " <MS/OS/GREED> <Character?> [Item Link] - starts a rollout")
    Rollouts.Print("/" .. SLASH_COMMAND .. " <stop/cancel> - cancels the rollout")
    Rollouts.Print("/" .. SLASH_COMMAND .. " end - ends the rollout before the timer expires")
    Rollouts.Print("/" .. SLASH_COMMAND .. " help - shows this text")
    Rollouts.Print("/" .. SLASH_COMMAND .. " options - opens the options page")
end

Rollouts:RegisterChatCommand(SLASH_COMMAND, "RolloutController")
Rollouts:RegisterChatCommand("rollouts", "RolloutController")

function Rollouts:RolloutController(input)
    local messageParts = Rollouts.utils.strSplit(input, " ")
    local command = messageParts[1] ~= nil and string.upper(messageParts[1])
    if command == "" then
        Rollouts.ui.toggleMainWindow()
    else
        if command == "STOP" or command == "CANCEL" then
            Rollouts.rollout.cancel()
        elseif command == "END" then
            Rollouts.rollout.finish()
        elseif command == "OPTIONS" then
            local ACD = LibStub("AceConfigDialog-3.0")
            ACD:Open("Rollouts")
        elseif command == "HELP" then
            printHelp()
        else
            local itemString = select(3, strfind(input, "|H(.+)|h"))
            if itemString ~= nil and itemString ~= "" then
                local itemInfo = {GetItemInfo(itemString)}
                if itemInfo[2] == nil then
                    Rollouts:Print("Please link a valid item. /rollout help")
                else
                    local rollType = messageParts[1]
                    if rollType == "MS" or rollType == "OS" or rollType == "GREED" then
                        for rollTypeId, t in ipairs(Rollouts.data.rollTypes) do
                            if rollType == t then
                                local owner = not Rollouts.utils.stringContainsItem(messageParts[2]) and messageParts[2] or nil
                                Rollouts.beginRoll(Rollouts.utils.makeRollEntryObject(itemInfo[2], owner, rollTypeId))
                                return
                            end
                        end
                        return true
                    else
                        Rollouts:Print("Specify a roll type <MS/OS/GREED>. /rollout help")
                    end
                end
            else
                Rollouts:Print("Could not find an item. '/ROLLOUT <MS/OS/GREED> [Item]'. /rollout help")
            end
            
        end
    end
end