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
    -- Tanno, 74
    -- Albionna, 52
    -- Eyota, 13
    -- Mixpizza, 65
    -- Stabby, 37
    -- Enma, 87
    -- Raindrool, 58
    -- Corpse, 12
    -- Pug, 99
    -- Puglet, 68

    Rollouts.appendRoll(Rollouts.utils.colour("Albionna", Rollouts.data.classColours[5]), "52", "The Silverhelms", "Silver Officer", 5)
    Rollouts.appendRoll(Rollouts.utils.colour("Corpse", Rollouts.data.classColours[12]), "12", "The Silverhelms", "Silvercorpse", 12)
    Rollouts.appendRoll(Rollouts.utils.colour("Enma", Rollouts.data.classColours[9]), "87", "The Silverhelms", "Officer Alt", 9)
    Rollouts.appendRoll(Rollouts.utils.colour("Eyota", Rollouts.data.classColours[1]), "13", "The Silverhelms", "SilverVeteran", 1)
    Rollouts.appendRoll(Rollouts.utils.colour("Mixpizza", Rollouts.data.classColours[7]), "65", "The Silverhelms", "Silverhelm", 7)
    Rollouts.appendRoll(Rollouts.utils.colour("Pug", Rollouts.data.classColours[8]), "99", "Random Guild", "Top Boi", 8)
    Rollouts.appendRoll(Rollouts.utils.colour("Puglet", Rollouts.data.classColours[3]), "68", "Other Guild", "Recruit", 3)
    Rollouts.appendRoll(Rollouts.utils.colour("Raindrool", Rollouts.data.classColours[7]), "58", "The Silverhelms", "Silver Alt", 7)
    Rollouts.appendRoll(Rollouts.utils.colour("Stabby", Rollouts.data.classColours[4]), "37", "The Silverhelms", "Silverhelm", 4)
    Rollouts.appendRoll(Rollouts.utils.colour("Tanno", Rollouts.data.classColours[10]), "74", "The Silverhelms", "Guild Dad", 10)
end