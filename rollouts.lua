local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):NewAddon("Rollouts", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

function Rollouts:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RolloutsDB", Rollouts.defaultOptions, true)
    self.env = {
        historyTab = Rollouts.utils.getEitherDBOption("lastTab"),
        mainWindowData = {
            point = nil,
            size = nil
        },
        live = nil,
        virtual = nil,
        showing = "none",
        debugData = {
            editing = {
                name = "Player",
                roll = 50,
                guildName = "Guild",
                rankName = "Rank",
                class = 6,
                spec = 250,
                equipped = {}
            },
            rolls = {}
        }
    }
    self.uiTick = self:ScheduleRepeatingTimer(Rollouts.ui.uiTick, 0.1)
    Rollouts.utils.cleanupHistory()
    Rollouts.ui.displayMinimapButton()
end

Rollouts.getDisplayRoll = function()
    if Rollouts.env.showing == "none" then
        return {
            rolls = {}
        }
    elseif Rollouts.env.showing == "live" then
        return Rollouts.env.live
    elseif Rollouts.env.showing == "virtual" then
        return Rollouts.env.virtual
    end
end