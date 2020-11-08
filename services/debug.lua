local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
Rollouts.debug = {}
_G.RolloutsDebug = Rollouts.debug

local randomData = {
    ["names"] = {
        "TestWarrior",
        "TestPaladin",
        "TestHunter",
        "TestRogue",
        "TestPriest",
        "TestDK",
        "TestShaman",
        "TestMage",
        "TestWarlock",
        "TestMonk",
        "TestDruid",
        "TestDH",
    }
}

local function createRandomRoll()
    local classId = math.random(12)
    local guildData = Rollouts.utils.getEitherDBOption("guildRanking", "guilds")
    local guildId = math.random(Rollouts.utils.tableSize(guildData))
    local rankId = math.random(Rollouts.utils.tableSize(guildData[guildId].ranks))
    local rankNameId = math.random(#guildData[guildId].ranks[rankId])
    local roll = math.random(100)
    local name = Rollouts.utils.colour(randomData.names[classId] .. roll, Rollouts.data.classColours[classId])
    return {name, roll, guildData[guildId].name, guildData[guildId].ranks[rankId][rankNameId], classId}
end

local testCases = {
    ["Single winner"] = {
        owners = { "Enma" },
        itemLink = "item:174137::::::::20:264::::::",
        steps = {{
            rolls = {
                { "Albionna", "52", "Example Guild", "Officer", 5},
                { "Corpse", "12", "Example Guild", "Social", 12},
                { "Chullee", "35", "Example Guild", "Veteran", 10},
                { "Enma", "87", "Example Guild", "Officer Alt", 9},
                { "Eyota", "52", "Example Guild", "Veteran", 1},
                { "Mixpizza", "65", "Example Guild", "Trial", 7},
                { "Pug", "99", "Random Guild", "Top Boi", 8},
                { "Puglet", "68", "Other Guild", "Recruit", 4},
                { "Raindrool", "58", "Example Guild", "Alt", 7},
                { "Stabby", "37", "Example Guild", "Trial", 4},
                { "Tanno", "74", "Example Guild", "Officer", 10}
            },
            expected = {
                order = {
                    { "tanno", 74 },
                    { "chullee", 35 },
                    { "stabby", 37 },
                    { "corpse", 12 },
                    { "puglet", 68 },
                    -- fails
                    { "albionna", 52 }, -- armor
                    { "eyota", 52 }, -- armor
                    { "mixpizza", 65 }, -- armor
                    { "enma", 87 }, -- owner / armor
                    { "raindrool", 58 }, -- armor
                    { "pug", 99 }, -- armor
                },
                winners = { "tanno" }
            }
        }}
    },
    ["No winner"] = {
        owners = { "Enma" },
        itemLink = "item:6543::::::::20:264:::1:1706:::",
        steps = {{
            rolls = {
                { "Chullee", "35", "Example Guild", "Veteran", 10},
                { "Tanno", "74", "Example Guild", "Officer", 10},
                { "Enma", "87", "Example Guild", "Officer Alt", 9},
            },
            expected = {
                order = {
                    { "tanno", 74 },
                    { "chullee", 35 },
                    { "enma", 87 }, -- owner
                },
                winners = {}
            }
        }}
    },
    ["Two winners"] = {
        owners = { "Enma", "Albionna" },
        itemLink = "item:174137::::::::20:264::::::",
        steps = {{
            rolls = {
                { "Chullee", "35", "Example Guild", "Veteran", 10},
                { "Tanno", "74", "Example Guild", "Officer", 10},
                { "Albionna", "52", "Example Guild", "Officer", 5},
                { "Enma", "87", "Example Guild", "Officer Alt", 9},
                { "Corpse", "12", "Example Guild", "Social", 12}
            },
            expected = {
                order = {
                    { "tanno", 74 },
                    { "chullee", 35 },
                    { "corpse", 12 },
                    { "albionna", 52 }, -- armor / owner
                    { "enma", 87 }, -- owner / armor
                },
                winners = { "tanno", "chullee" }
            }
        }}
    },
    ["Multiple winners one owner"] = {
        owners = { "Enma" },
        itemLink = "item:174137::::::::20:264::::::",
        steps = {{
            rolls = {
                { "Tanno", "74", "Example Guild", "Officer", 10},
                { "Chullee", "74", "Example Guild", "Veteran", 10},
                { "Albionna", "52", "Example Guild", "Officer", 5}
            },
            expected = {
                order = {
                    { "chullee", 74 },
                    { "tanno", 74 },
                    { "albionna", 52 }, -- armor
                },
                winners = { "chullee", "tanno" }
            }
        }, {
            rolls = {
                { "Chullee", "58", "Example Guild", "Veteran", 10},
                { "Tanno", "23", "Example Guild", "Officer", 10},
                { "Albionna", "100", "Example Guild", "Officer", 5}
            },
            expected = {
                order = {
                    { "chullee", 58 },
                    { "tanno", 23 },
                    { "albionna", 100 }, -- armor / rules
                },
                winners = { "chullee" }
            }
        }}
    },
    ["A lot of winners, few owners"] = {
        owners = { "Owner1", "Owner2", "Owner3" },
        itemLink = "item:6543::::::::20:264:::1:1706:::",
        steps = {{ -- 1
            rolls = {
                { "Player5", "85", "Guild", "Rank", 5},
                { "Player1", "85", "Guild", "Rank", 5},
                { "Player2", "97", "Guild", "Rank", 5},
                { "Player3", "85", "Guild", "Rank", 5},
                { "Player4", "74", "Guild", "Rank", 5},
            },
            expected = {
                order = {
                    { "player2", 97 },
                    { "player1", 85 },
                    { "player3", 85 },
                    { "player5", 85 },
                    { "player4", 74 },
                },
                winners = { "player2", "player1", "player3", "player5" }
            }
        }, { -- 2
           rolls = {
                { "Player5", "74", "Guild", "Rank", 5},
                { "Player1", "85", "Guild", "Rank", 5},
                { "Player2", "97", "Guild", "Rank", 5},
                { "Player3", "74", "Guild", "Rank", 5},
                { "Player4", "74", "Guild", "Rank", 5},
            },
            expected = {
                order = {
                    { "player1", 85 },
                    { "player3", 74 },
                    { "player5", 74 },
                    { "player2", 97 }, -- rules
                    { "player4", 74 }, -- rules
                },
                winners = { "player1", "player3", "player5" }
            }
        }, { -- 3
           rolls = {
                { "Player5", "74", "Guild", "Rank", 5},
                { "Player1", "85", "Guild", "Rank", 5},
                { "Player2", "97", "Guild", "Rank", 5},
                { "Player3", "74", "Guild", "Rank", 5},
                { "Player4", "53", "Guild", "Rank", 5},
            },
            expected = {
                order = {
                    { "player3", 74 },
                    { "player5", 74 },
                    { "player2", 97 }, -- rules
                    { "player1", 85 }, -- rules
                    { "player4", 53 }, -- rules
                },
                winners = { "player3", "player5" }
            }
        }, { -- 4
           rolls = {
                { "Player5", "74", "Guild", "Rank", 5},
                { "Player1", "85", "Guild", "Rank", 5},
                { "Player2", "97", "Guild", "Rank", 5},
                { "Player3", "100", "Guild", "Rank", 5},
                { "Player4", "53", "Guild", "Rank", 5},
            },
            expected = {
                order = {
                    { "player3", 100 },
                    { "player5", 74 },
                    { "player2", 97 }, -- rules
                    { "player1", 85 }, -- rules
                    { "player4", 53 }, -- rules
                },
                winners = { "player3" }
            }
        }}
    },
    ["Weapon check"] = {
        owners = { "Tanno" },
        itemLink = "item:150424::::::::60:::::",
        steps = {{
            rolls = {
                { "Albionna", "52", "Example Guild", "Officer", 5, 257},
                { "Corpse", "12", "Example Guild", "Social", 12, 577},
                { "Chullee", "35", "Example Guild", "Veteran", 10, 269},
                { "Enma", "87", "Example Guild", "Officer", 9},
                { "Eyota", "52", "Example Guild", "Veteran", 1, 72},
                { "Tanno", "74", "Example Guild", "Officer", 10},
            },
            expected = {
                order = {
                    { "enma", 87 },
                    { "albionna", 52 },
                    -- fails
                    { "tanno", 74 }, -- owner
                    { "eyota", 52 }, -- weapon
                    { "chullee", 35 }, -- weapon
                    { "corpse", 12 }, -- weapon
                },
                winners = { "enma" }
            }
        }}
    },
    ["Ilvl threshold check"] = {
        owners = { "Enma" },
        itemLink = "|cffa335ee|Hitem:159256::::::::50:257::35:8:6534:6578:6579:6438:6462:6515:1538:4786::::|h[Iron-Kelp Wristwraps]|h|r",
        steps = {{
            rolls = {
                { "Nympse", "52", "Example Guild", "Officer", 5, 257, {"|cffa335ee|Hitem:159256::::::::50:257::35:8:6534:6578:6579:6438:6462:6515:1538:4786::::|h[Iron-Kelp Wristwraps]|h|r"}},
                { "Chhe", "8", "Example Guild", "Officer", 8, 64, {"|cff1eff00|Hitem:154692::::::::50:257::13:2:1693:6848::::|h[Tidespray Linen Bracers of the Fireflash]|h|r"}},
            },
            expected = {
                order = {
                    { "chhe", 8 },
                    { "nympse", 52 },
                },
                winners = { "chhe" }
            }
        }}
    }
}

Rollouts.debug.appendRandomRolls = function(number)
    number = number or 5
    for i = 1, number do
        Rollouts.appendRoll(unpack(createRandomRoll()))
    end
end

local function printTestFailure(testName, stepId, rollId, expectedType, expected, actual)
    local message = "Test [" .. Rollouts.utils.colour(testName, "red") .. "], step [" .. stepId .. "] failed. "
    if rollId then message = message .. "Roll " .. rollId .. ". " end
    message = message .. "\nExpected " .. expectedType .. ": '" .. expected .. "'. Instead got '" .. actual .. "'\n"
    Rollouts:Print(message)
end

local function assert(testName, stepId, rollId, expectedType, expected, actual, stats)
    if expected ~= actual then
        printTestFailure(testName, stepId, rollId, expectedType, expected, actual)
        stats.breakout = true
        stats.failed = stats.failed + 1
        return false
    end
    return true
end

Rollouts.debug.testCase = function()
    local failed = 0
    local testStats = { failed = 0, completed = 0, breakout = false }

    Rollouts:Print("Running test cases...\n")
    for testName, testCase in pairs(testCases) do
        if testStats.breakout then break end

        Rollouts:Print("Starting test [" .. Rollouts.utils.colour(testName, "yellow") .. "].")
        Rollouts.cancelRoll()
        Rollouts.beginRoll({
            itemLink = testCase.itemLink or "item:174137::::::::20:264::::::",
            owners = testCase.owners,
            time = GetServerTime(),
            rollType = 3,
            rolls = {}
        })

        local testSteps = testCase.steps
        for stepIndex = 1, #testSteps do
            if testStats.breakout then break end
            local testStep = testSteps[stepIndex]

            for rollId, roll in ipairs(testStep.rolls) do
                Rollouts.appendRoll(Rollouts.utils.colour(roll[1], Rollouts.data.classColours[roll[5]]), roll[2], roll[3], roll[4], roll[5], roll[6], roll[7])
            end

            local displayRoll = Rollouts.getDisplayRoll()
            local rolls = displayRoll and displayRoll.rolls or {}
            local expectedOrder = testStep.expected.order

            if not assert(testName, stepIndex, nil, "rolls count", #expectedOrder, #rolls, testStats) then break end

            if testStats.breakout then break end
            for rollId, rollEntry in ipairs(rolls) do
                local expectedRollName = expectedOrder[rollId][1]
                local expectedRollValue = expectedOrder[rollId][2]
                local player = Rollouts.utils.simplifyName(rollEntry.name) or ""
                if not assert(testName, stepIndex, rollId, "roll order", expectedRollName, player, testStats) then break end
                if not assert(testName, stepIndex, rollId, "roll value", expectedRollValue, tonumber(rollEntry.roll), testStats) then break end
            end

            if testStats.breakout then break end
            local expectedWinners = testStep.expected.winners
            local actualWinners = Rollouts.getWinners(nil, true)
            if not assert(testName, stepIndex, nil, "winner count", #expectedWinners, #actualWinners, testStats) then break end

            if testStats.breakout then break end
            for i = 1, #expectedWinners do
                local player = Rollouts.utils.simplifyName(actualWinners[i]) or "nil"
                if not assert(testName, stepIndex, i, "winner", expectedWinners[i], player, testStats) then break end
            end

            if testStats.breakout then break end
            Rollouts.handleWinningRolls()
        end

        if not testStats.breakout then
            Rollouts:Print("Test [" .. Rollouts.utils.colour(testName, "green") .. "] completed successfully.\n")
            Rollouts.cancelRoll()
            testStats.completed = testStats.completed + 1
        end
    end
    Rollouts.handleWinningRolls()
    Rollouts:Print("Tests finished. " .. Rollouts.utils.colour(testStats.completed, "green") .. " completed and "
            .. Rollouts.utils.colour(testStats.failed, "red") .. " failed.")
end

Rollouts.debug.toggleDebugWindow = function()
    if Rollouts.frames.debugWindow.shown then
        Rollouts.frames.debugWindow.hide()
    else
        Rollouts.frames.debugWindow.show()
    end
end

Rollouts.debug.setEditingData = function(dataType)
    return function(self, event, value)
        if dataType == "classAndSpec" then
            local class, spec = Rollouts.utils.strSplit(value, ".")
            Rollouts.env.debugData.editing.class = tonumber(class)
            Rollouts.env.debugData.editing.spec = tonumber(spec)
        elseif dataType == "equipped" then
            local items = Rollouts.utils.strSplit(value, ",")
            local equipped = {}
            for i, item in ipairs(items) do
                local name, link = GetItemInfo(item)
                if link then
                    table.insert(equipped, link)
                end
            end
            Rollouts.env.debugData.editing.equipped = equipped
        else
            Rollouts.env.debugData.editing[dataType] = value
        end
    end
end

Rollouts.debug.addRollFromEditingData = function()
    local data = Rollouts.env.debugData.editing
    local roll = data.roll
    local guildName = data.guildName
    local rankName = data.rankName
    local classId = data.class
    local spec = data.spec
    local equipped = data.equipped
    local name = Rollouts.utils.colour(data.name, Rollouts.data.classColours[classId])
    local rollObj = Rollouts.appendRoll(name, roll, guildName, rankName, classId, spec, equipped)
    if (rollObj) then
        table.insert(Rollouts.env.debugData.rolls, {name, roll, guildName, rankName, classId, spec, equipped})
        Rollouts.frames.debugWindow.updateHistory()
    end
end