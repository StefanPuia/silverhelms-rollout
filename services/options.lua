local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
Rollouts.options = {}

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
        -- override sorting if ilvl threshold is met
        minIlvlThreshold = 0,
        -- enablePauseIfUnsure
        enablePauseIfUnsure = true,
        -- default roll type
        defaultRollType = 3,
        -- validation
        enableArmorTypeValidation = true,
        enableWeaponTypeValidation = true,
        enableOwnerValidation = true,
        enableStatValidation = true,
        enableTokenClassValidation = true,
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
                    name = "Example Guild",
                    ranks = {
                        [1] = {"Alt", "Social", "Officer Alt"},
                        [2] = {"Trial"},
                        [3] = {"Raider", "Veteran", "Officer"}
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
        autoRemoveDays = 7,


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
                -- break1 = {
                --     order = 2,
                --     type = "description",
                --     name = ""
                -- },
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
                -- break3 = {
                --     order = 6,
                --     type = "description",
                --     name = ""
                -- },
                lowestRestart = {
                    order = 7,
                    name = "Lowest restart",
                    type = "select",
                    values = Rollouts.data.rollTypes,
                    set = function(info, val) setDBOption(val, "lowestRestart") end,
                    get = function(info) return getEitherDBOption("lowestRestart") end
                },
                break5 = {
                    order = 8,
                    type = "description",
                    name = ""
                },
                restartIfNoRolls = {
                    order = 9,
                    name = "Restart if no rolls",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "restartIfNoRolls") end,
                    get = function(info) return getEitherDBOption("restartIfNoRolls") end
                },
                break4 = {
                    order = 10,
                    type = "description",
                    name = ""
                },
                enableWhisperAppend = {
                    order = 11,
                    name = "Enable whispered item capture",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableWhisperAppend") end,
                    get = function(info) return getEitherDBOption("enableWhisperAppend") end
                },
                break6 = {
                    order = 12,
                    type = "description",
                    name = ""
                },
                minIlvlThreshold = {
                    order = 13,
                    name = "Sort rolls higher up if ilvl difference is bigger than this",
                    type = "range",
                    min = 0,
                    max = 100,
                    step = 1,
                    set = function(info, val) setDBOption(val, "minIlvlThreshold") end,
                    get = function(info) return getEitherDBOption("minIlvlThreshold") end
                },
                enablePauseIfUnsure = {
                    order = 11,
                    name = "Pause the roll before the end if data is missing",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enablePauseIfUnsure") end,
                    get = function(info) return getEitherDBOption("enablePauseIfUnsure") end
                },
                break7 = {
                    order = 12,
                    type = "description",
                    name = ""
                },
            }
        },
        validationOptions = {
            order = 2,
            name = "Roll Validation",
            type = "group",
            args = {
                enableArmorTypeValidation = {
                    order = 1,
                    name = "Armor Type Validation",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableArmorTypeValidation") end,
                    get = function(info) return getEitherDBOption("enableArmorTypeValidation") end
                },
                break1 = {
                    order = 2,
                    type = "description",
                    name = ""
                },
                enableWeaponTypeValidation = {
                    order = 3,
                    name = "Weapon Type Validation",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableWeaponTypeValidation") end,
                    get = function(info) return getEitherDBOption("enableWeaponTypeValidation") end
                },
                break2 = {
                    order = 4,
                    type = "description",
                    name = ""
                },
                enableOwnerValidation = {
                    order = 5,
                    name = "Reject Owner",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableOwnerValidation") end,
                    get = function(info) return getEitherDBOption("enableOwnerValidation") end
                },
                break3 = {
                    order = 6,
                    type = "description",
                    name = ""
                },
                enableStatValidation = {
                    order = 7,
                    name = "Stat Validation",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableStatValidation") end,
                    get = function(info) return getEitherDBOption("enableStatValidation") end
                },
                break4 = {
                    order = 8,
                    type = "description",
                    name = ""
                },
                enableTokenClassValidation = {
                    order = 9,
                    name = "Token Class Validation",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "enableTokenClassValidation") end,
                    get = function(info) return getEitherDBOption("enableTokenClassValidation") end
                },
                break5 = {
                    order = 10,
                    type = "description",
                    name = ""
                },
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
                    multiline = 20,
                    get = function(info) return Rollouts.utils.stringifyGuildRanking(getEitherDBOption("guildRanking", "guilds")) end,
                    set = function(info, val)
                        local parsed = Rollouts.utils.parseGuildRanking(val)
                        if parsed ~= nil then
                            setDBOption(parsed, "guildRanking", "guilds")
                        else
                            Rollouts:Print("Cannot parse the rankings. Please check your syntax.")
                        end
                    end
                }
            }
        },
        advancedOptions = {
            order = 4,
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
                autoRemoveDays = {
                    order = 7,
                    name = "Automatically remove history items  after this number of days:",
                    type = "range",
                    min = 0,
                    max = 90,
                    step = 1,
                    set = function(info, val) setDBOption(val, "autoRemoveDays") end,
                    get = function(info) return getEitherDBOption("autoRemoveDays") end
                },
                break3 = {
                    order = 8,
                    type = "description",
                    name = ""
                },
                debugMode = {
                    order = 9,
                    name = "Enable Debug mode",
                    type = "toggle",
                    set = function(info, val) setDBOption(val, "debugMode") end,
                    get = function(info) return getEitherDBOption("debugMode") end
                },
                break4 = {
                    order = 10,
                    type = "description",
                    name = ""
                },
                runTestCase = {
                    order = 11,
                    name = "Run Test Cases",
                    type = "execute",
                    func = function() Rollouts.debug.testCase() end
                },
                break5 = {
                    order = 12,
                    type = "description",
                    name = ""
                },
                clearHistory = {
                    order = 13,
                    name = "Clear History",
                    type = "execute",
                    func = function()
                        Rollouts.ui.alert("Are you sure you want to clear the history?",
                        function()
                            setDBOption({}, "data", "rolls", "history")
                        end, false, false, "RESET_DEFAULTS")
                    end
                }
            }
        },
        resetOptions = {
            order = 5,
            name = "Reset Defaults",
            type = "execute",
            func = function()
                Rollouts.ui.alert("Are you sure you want to reset your settings?",
                function()
                    Rollouts.options.resetOptionsToDefaults()
                end, false, false, "RESET_DEFAULTS")
            end
        }
    }
}

Rollouts.options.resetOptionsToDefaults = function()
    setDBOption(Rollouts.defaultOptions.global.rollTimeLimit, "rollTimeLimit")
    setDBOption(Rollouts.defaultOptions.global.rollCountdown, "rollCountdown")
    setDBOption(Rollouts.defaultOptions.global.defaultRollType, "defaultRollType")
    setDBOption(Rollouts.defaultOptions.global.restartIfNoRolls, "restartIfNoRolls")
    setDBOption(Rollouts.defaultOptions.global.lowestRestart, "lowestRestart")
    setDBOption(Rollouts.defaultOptions.global.enableWhisperAppend, "enableWhisperAppend")
    setDBOption(Rollouts.defaultOptions.global.minIlvlThreshold, "minIlvlThreshold")

    setDBOption(Rollouts.defaultOptions.global.guildRanking.enabled, "guildRanking", "enabled")
    setDBOption({ [1] = { name = "*", ranks = {{"*"}} } }, "guildRanking", "guilds")

    setDBOption(Rollouts.defaultOptions.global.showMinimapIcon, "showMinimapIcon")
    setDBOption(Rollouts.defaultOptions.global.debugMode, "debugMode")
    setDBOption(Rollouts.defaultOptions.global.autoRemoveDays, "autoRemoveDays")

    setDBOption(Rollouts.defaultOptions.global.enableArmorTypeValidation, "enableArmorTypeValidation")
    setDBOption(Rollouts.defaultOptions.global.enableWeaponTypeValidation, "enableWeaponTypeValidation")
    setDBOption(Rollouts.defaultOptions.global.enableOwnerValidation, "enableOwnerValidation")
    setDBOption(Rollouts.defaultOptions.global.enableStatValidation, "enableStatValidation")

    Rollouts:Print("Settings reset to defaults.")
end

local ACFG = LibStub("AceConfig-3.0")
ACFG:RegisterOptionsTable("Rollouts", settingsTable)
Rollouts.interfaceOptionsRef = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Rollouts", "Silverhelms Rollouts")