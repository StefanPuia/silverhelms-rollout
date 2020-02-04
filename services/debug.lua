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