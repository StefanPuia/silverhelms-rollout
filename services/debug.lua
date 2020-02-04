local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
Rollouts.debug = {}
_G.RolloutsDebug = Rollouts.debug

local randomData = {
    ["names"] = {
        Rollouts.utils.colour("TestWarrior", "warrior"),
        Rollouts.utils.colour("TestPaladin", "paladin"),
        Rollouts.utils.colour("TestHunter", "hunter"),
        Rollouts.utils.colour("TestRogue", "rogue"),
        Rollouts.utils.colour("TestPriest", "priest"),
        Rollouts.utils.colour("TestDK", "dk"),
        Rollouts.utils.colour("TestShaman", "shaman"),
        Rollouts.utils.colour("TestMage", "mage"),
        Rollouts.utils.colour("TestWarlock", "warlock"),
        Rollouts.utils.colour("TestMonk", "monk"),
        Rollouts.utils.colour("TestDruid", "druid"),
        Rollouts.utils.colour("TestDH", "dh"),
    }
}

local function createRandomRoll()
    local classId = math.random(12)
    local guildData = Rollouts.utils.getEitherDBOption("guildRanking", "guilds")
    local guildId = math.random(Rollouts.utils.tableSize(guildData))
    local rankId = math.random(Rollouts.utils.tableSize(guildData[guildId].ranks))
    local rankNameId = math.random(#guildData[guildId].ranks[rankId])
    local roll = math.random(100)
    local name = randomData.names[classId] .. roll
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

    Rollouts.appendRoll("Albionna", "52", "The Silverhelms", "Silver Officer", 5)
    Rollouts.appendRoll("Corpse", "12", "The Silverhelms", "Silvercorpse", 12)
    Rollouts.appendRoll("Enma", "87", "The Silverhelms", "Officer Alt", 9)
    Rollouts.appendRoll("Eyota", "13", "The Silverhelms", "SilverVeteran", 1)
    Rollouts.appendRoll("Mixpizza", "65", "The Silverhelms", "Silverhelm", 7)
    Rollouts.appendRoll("Pug", "99", "Random Guild", "Top Boi", 8)
    Rollouts.appendRoll("Puglet", "68", "Other Guild", "Recruit", 3)
    Rollouts.appendRoll("Raindrool", "58", "The Silverhelms", "Silver Alt", 7)
    Rollouts.appendRoll("Stabby", "37", "The Silverhelms", "Silverhelm", 4)
    Rollouts.appendRoll("Tanno", "74", "The Silverhelms", "Guild Dad", 10)
end