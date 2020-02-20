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

Rollouts.debug.appendRandomRolls = function(number)
    number = number or 5
    for i = 1, number do
        Rollouts.appendRoll(unpack(createRandomRoll()))
    end
end

Rollouts.debug.testCase = function()
    Rollouts.beginRoll({
        itemLink = 174137,
        owner = "Enma",
        time = GetServerTime(),
        rollType = 3,
        rolls = {}
    })

    local expected = {
        { "tanno", 74 },
        { "chullee", 35 },
        { "stabby", 37 },
        { "corpse", 12 },
        { "puglet", 68 },

        -- fails
        { "albionna", 52 }, -- armor
        { "eyota", 13 }, -- armor
        { "mixpizza", 65 }, -- armor
        { "enma", 87 }, -- owner / armor
        { "raindrool", 58 }, -- armor
        { "pug", 99 }, -- armor
    }

    local test = {
        { "Albionna", "52", "The Silverhelms", "Silver Officer", 5},
        { "Corpse", "12", "The Silverhelms", "Silvercorpse", 12},
        { "Chullee", "35", "The Silverhelms", "SilverVeteran", 10},
        { "Enma", "87", "The Silverhelms", "Officer Alt", 9},
        { "Eyota", "13", "The Silverhelms", "SilverVeteran", 1},
        { "Mixpizza", "65", "The Silverhelms", "Silverhelm", 7},
        { "Pug", "99", "Random Guild", "Top Boi", 8},
        { "Puglet", "68", "Other Guild", "Recruit", 4},
        { "Raindrool", "58", "The Silverhelms", "Silver Alt", 7},
        { "Stabby", "37", "The Silverhelms", "Silverhelm", 4},
        { "Tanno", "74", "The Silverhelms", "Guild Dad", 10}
    }

    for i, roll in ipairs(test) do
        Rollouts.appendRoll(Rollouts.utils.colour(roll[1], Rollouts.data.classColours[roll[5]]), roll[2], roll[3], roll[4], roll[5])
    end

    local displayRoll = Rollouts.getDisplayRoll()
    local rolls = displayRoll and displayRoll.rolls or {}
    for i, rollEntry in ipairs(rolls) do
        local player = Rollouts.utils.simplifyName(rollEntry.name) or ""
        if player ~= expected[i][1] then
            Rollouts:Print("Test failed. Roll id: " .. i .. ". Expected " .. expected[i][1] .. " instead got " .. player)
            Rollouts.finishRoll()
            return
        end
    end

    Rollouts:Print("Test completed.")
    Rollouts.finishRoll()
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