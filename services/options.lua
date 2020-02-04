local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")

Rollouts.defaultOptions = {
    global = {
        -- external
        -- time limit for the rolls
        rollTimeLimit = 30,
        -- time when the WA is going to start counting down
        rollCountdown = 0, -- seconds or 0 to disable it
        -- if no one rolls, restart the countdown with a lower roll type
        restartIfNoRolls = true,
        -- lowest roll type to restart for
        lowestRestart = 2, -- 3 = MS, 2 = OS, 1 = GREED
        -- default roll for whispers (0 to disable whsiper checks)
        enableWhisperAppend = true,
        -- default roll type
        defaultRollType = 3,
        -- toggle rank priority
        guildRanking = {
            enabled = true,
            -- guilds allowed to roll, and their rank rules, bottom to top
            guilds = {
                -- allow anyone else to roll
                [1] = {
                    name = "*",
                    ranks = {
                        [1] = {"*"}
                    }
                },
                [2] = {
                    name = "The Silverhelms",
                    ranks = {
                        [1] = {"Officer Alt", "Silver Alt", "Silvercorpse", "Silverfriend"},
                        [2] = {"Silverhelm"},
                        [3] = {"Guild Dad", "Guild Mom", "Silver Officer", "SilverVeteran", "Silver Knight"}
                    }
                }
            }
        },
        -- only accept rolls between these 2 values
        roll = {
            min = 1,
            max = 100
        },
        showMinimapIcon = true,
        debugMode = false,


        -- internal
        data = {
            rolls = {
                pending = {},
                history = {}
            }
        },
        font = "Fonts\\FRIZQT__.TTF",
        lastTab = "pending",
        minimapIconPos = {0, 0}
    }
}

local getEitherDBOption = Rollouts.utils.getEitherDBOption
local setDBOption = Rollouts.utils.setDBOption
local settingsTable = {
    type = "group",
    args = {
        generalOptions = {
            order = 1,
            name = "General",
            type = "group",
            args = {
                rollTimeLimit = {
                    order = 1,
                    name = "Roll Time Limit",
                    type = "range",
                    min = 0,
                    max = 100,
                    step = 1,
                    set = function(info, val) setDBOption(val, "rollTimeLimit") end,
                    get = function(info) return getEitherDBOption("rollTimeLimit") end
                },
                break1 = {
                    order = 2,
                    type = "description",
                    name = ""
                },
                rollCountdown = {
                    order = 3,
                    name = "Warning countdown",
                    type = "range",
                    min = 0,
                    max = 100,
                    step = 1,
                    set = function(info, val) setDBOption(val, "rollCountdown") end,
                    get = function(info) return getEitherDBOption("rollCountdown") end
                },
                break2 = {
                    order = 4,
                    type = "description",
                    name = ""
                },
                defaultRollType = {
                    order = 5,
                    name = "Default Roll Type",
                    type = "select",
                    values = Rollouts.data.rollTypes,
                    set = function(info, val) setDBOption(val, "defaultRollType") end,
                    get = function(info) return getEitherDBOption("defaultRollType") end
                },
                break3 = {
                    order = 6,
                    type = "description",
                    name = ""
                },
                restartIfNoRolls = {
                    order = 7,
                    name = "Restart if no rolls",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "restartIfNoRolls") end,
                    get = function(info) return getEitherDBOption("restartIfNoRolls") end
                },
                break4 = {
                    order = 8,
                    type = "description",
                    name = ""
                },
                lowestRestart = {
                    order = 9,
                    name = "Lowest restart",
                    type = "select",
                    values = Rollouts.data.rollTypes,
                    set = function(info, val) setDBOption(val, "lowestRestart") end,
                    get = function(info) return getEitherDBOption("lowestRestart") end
                },
                break5 = {
                    order = 10,
                    type = "description",
                    name = ""
                },
                enableWhisperAppend = {
                    order = 11,
                    name = "Enable whisper append",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableWhisperAppend") end,
                    get = function(info) return getEitherDBOption("enableWhisperAppend") end
                }
            }
        },
        advancedOptions = {
            order = 2,
            name = "Advanced Options",
            type = "group",
            args = {
                -- rollDesc = {
                --     order = 1,
                --     type = "description",
                --     name = "Only accept rolls between the following two numbers (default /roll is 1-100)"
                -- },
                -- minRoll = {
                --     order = 2,
                --     name = "Min Roll",
                --     type = "range",
                --     min = 0,
                --     max = 999999,
                --     step = 1,
                --     set = function(info, val) setDBOption(val, "roll", "min") end,
                --     get = function(info) return getEitherDBOption("roll", "min") end
                -- },
                -- maxRoll = {
                --     order = 3,
                --     name = "Max Roll",
                --     type = "range",
                --     min = 0,
                --     max = 999999,
                --     step = 1,
                --     set = function(info, val) setDBOption(val, "roll", "max") end,
                --     get = function(info) return getEitherDBOption("roll", "max") end
                -- },
                break1 = {
                    order = 4,
                    type = "description",
                    name = ""
                },
                showMinimapIcon = {
                    order = 5,
                    name = "Enable the minimap icon",
                    type = "toggle",
                    set = function(info, val)
                        setDBOption(val, "showMinimapIcon")
                        Rollouts.ui.displayMinimapButton()
                    end,
                    get = function(info) return getEitherDBOption("showMinimapIcon") end
                },
                break2 = {
                    order = 6,
                    type = "description",
                    name = ""
                },
                debugMode = {
                    order = 7,
                    name = "Enable Debug mode",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "debugMode") end,
                    get = function(info) return getEitherDBOption("debugMode") end
                }
            }
        },
        guildRanking = {
            order = 3,
            name = "Guild Ranking",
            type = "group",
            args = {
                enable = {
                    name = "Enable Ranking",
                    type = "toggle",
                    width = "full",
                    set = function(info, val) setDBOption(val, "guildRanking", "enabled") end,
                    get = function(info) return getEitherDBOption("guildRanking", "enabled") end
                },
                ranks = {
                    name = "Ranks",
                    type = "input",
                    width = "full",
                    multiline = 15,
                    get = function(info) return Rollouts.utils.stringify(getEitherDBOption("guildRanking", "guilds")) end,
                    set = function() Rollouts:Print("Ranks cannot be changed from settings yet") end
                }
            }
        }
    }
}

local ACFG = LibStub("AceConfig-3.0")
ACFG:RegisterOptionsTable("Rollouts", settingsTable)
Rollouts.interfaceOptionsRef = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Rollouts", "Silverhelms Rollouts")