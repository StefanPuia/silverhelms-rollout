local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")

Rollouts.data = {}
Rollouts.data.rollTypes = {
    [3] = "MS",
    [2] = "OS",
    [1] = "GREED"
}
Rollouts.data.slots = {
    [""] = {},
    ["INVTYPE_AMMO"] = {0},
    ["INVTYPE_HEAD"] = {1},
    ["INVTYPE_NECK"] = {2},
    ["INVTYPE_SHOULDER"] = {3},
    ["INVTYPE_BODY"] = {4},
    ["INVTYPE_CHEST"] = {5},
    ["INVTYPE_ROBE"] = {5},
    ["INVTYPE_WAIST"] = {6},
    ["INVTYPE_LEGS"] = {7},
    ["INVTYPE_FEET"] = {8},
    ["INVTYPE_WRIST"] = {9},
    ["INVTYPE_HAND"] = {10},
    ["INVTYPE_FINGER"] = {11,12},
    ["INVTYPE_TRINKET"] = {13,14},
    ["INVTYPE_CLOAK"] = {15},
    ["INVTYPE_WEAPON"] = {16,17},
    ["INVTYPE_SHIELD"] = {17},
    ["INVTYPE_2HWEAPON"] = {16},
    ["INVTYPE_WEAPONMAINHAND"] = {16},
    ["INVTYPE_WEAPONOFFHAND"] = {17},
    ["INVTYPE_HOLDABLE"] = {17},
    ["INVTYPE_RANGED"] = {18},
    ["INVTYPE_THROWN"] = {18},
    ["INVTYPE_RANGEDRIGHT"] = {18},
    ["INVTYPE_RELIC"] = {18},
    ["INVTYPE_TABARD"] = {19},
    ["INVTYPE_BAG"] = {20,21,22,23},
    ["INVTYPE_QUIVER"] = {20,21,22,23}
}
Rollouts.data.classArmorType = {
    [1] = "Plate", -- Warrior
    [2] = "Plate", -- Paladin
    [3] = "Mail", -- Hunter
    [4] = "Leather", -- Rogue
    [5] = "Cloth", -- Priest
    [6] = "Plate", -- DeathKnight
    [7] = "Mail", -- Shaman
    [8] = "Cloth", -- Mage
    [9] = "Cloth", -- Warlock
    [10] = "Leather", -- Monk
    [11] = "Leather", -- Druid
    [12] = "Leather", -- DemonHunter
}
Rollouts.data.stats = {
    [1] = "STRENGTH",
    [2] = "AGILITY",
    [3] = "INTELLECT"
}
Rollouts.data.classStats = {
    ["1"] = {Rollouts.data.stats[1]}, -- Warrior
    ["2"] = {Rollouts.data.stats[1], Rollouts.data.stats[3]}, -- Paladin
    ["3"] = {Rollouts.data.stats[2]}, -- Hunter
    ["4"] = {Rollouts.data.stats[2]}, -- Rogue
    ["5"] = {Rollouts.data.stats[3]}, -- Priest
    ["6"] = {Rollouts.data.stats[1]}, -- DeathKnight
    ["7"] = {Rollouts.data.stats[2], Rollouts.data.stats[3]}, -- Shaman
    ["8"] = {Rollouts.data.stats[3]}, -- Mage
    ["9"] = {Rollouts.data.stats[3]}, -- Warlock
    ["10"] = {Rollouts.data.stats[2]}, -- Monk
    ["11"] = {Rollouts.data.stats[2], Rollouts.data.stats[3]}, -- Druid
    ["12"] = {Rollouts.data.stats[2]}, -- DemonHunter
}
Rollouts.data.specStats = {
    -- Death Knight
    ["250"] = Rollouts.data.stats[1], -- Blood
    ["251"] = Rollouts.data.stats[1], -- Frost
    ["252"] = Rollouts.data.stats[1], -- Unholy
    -- Paladin
    ["66"] = Rollouts.data.stats[1], -- Protection
    ["70"] = Rollouts.data.stats[1], -- Retribution
    -- Warrior
    ["71"] = Rollouts.data.stats[1], -- Arms
    ["72"] = Rollouts.data.stats[1], -- Fury
    ["73"] = Rollouts.data.stats[1], -- Protection
    -- Demon Hunter
    ["577"] = Rollouts.data.stats[2], -- Havoc
    ["581"] = Rollouts.data.stats[2], -- Vengeance
    -- Druid
    ["103"] = Rollouts.data.stats[2], -- Feral
    ["104"] = Rollouts.data.stats[2], -- Guardian
    -- Hunter
    ["253"] = Rollouts.data.stats[2], -- Beast Mastery
    ["254"] = Rollouts.data.stats[2], -- Marksmanship
    ["255"] = Rollouts.data.stats[2], -- Survival
    -- Monk
    ["268"] = Rollouts.data.stats[2], -- Brewmaster
    ["269"] = Rollouts.data.stats[2], -- Windwalker
    ["270"] = Rollouts.data.stats[2], -- Mistweaver
    -- Rogue
    ["259"] = Rollouts.data.stats[2], -- Assassination
    ["260"] = Rollouts.data.stats[2], -- Outlaw
    ["261"] = Rollouts.data.stats[2], -- Subtlety
    -- Shaman
    ["263"] = Rollouts.data.stats[2], -- Enhancement
    -- Druid
    ["102"] = Rollouts.data.stats[3], -- Balance
    ["105"] = Rollouts.data.stats[3], -- Restoration
    -- Mage
    ["62"] = Rollouts.data.stats[3], -- Arcane
    ["63"] = Rollouts.data.stats[3], -- Fire
    ["64"] = Rollouts.data.stats[3], -- Frost
    -- Paladin
    ["65"] = Rollouts.data.stats[3], -- Holy
    -- Priest
    ["256"] = Rollouts.data.stats[3], -- Discipline
    ["257"] = Rollouts.data.stats[3], -- Holy
    ["258"] = Rollouts.data.stats[3], -- Shadow
    -- Shaman
    ["262"] = Rollouts.data.stats[3], -- Elemental
    ["264"] = Rollouts.data.stats[3], -- Restoration
    -- Warlock
    ["265"] = Rollouts.data.stats[3], -- Affliction
    ["266"] = Rollouts.data.stats[3], -- Demonology
    ["267"] = Rollouts.data.stats[3], -- Destruction
}
Rollouts.data.failMessages = {
    ["ARMOR_TYPE"] = "armor type",
    ["NOT_MS_STAT"] = "not MS stat",
    ["NOT_OS_STAT"] = "not OS stat",
    ["ROLL_OWNER"] = "roll owner"
}
Rollouts.data.colours = {
    red = "FF0000",
    green = "00FF00",
    blue = "0000FF",
    yellow = "FFFF00",
    violet = "FF00FF",
    cyan = "00FFFF",
    gray = "484848",

    dk = "C41F3B",
    dh = "A330C9",
    druid = "FF7D0A",
    hunter = "A9D271",
    mage = "40C7EB",
    monk = "00FF96",
    paladin = "F58CBA",
    priest = "FFFFFF",
    rogue = "FFF569",
    shaman = "0070DE",
    warlock = "8787ED",
    warrior = "C79C6E"
}
Rollouts.data.classColours = {
    [1] = Rollouts.data.colours.warrior, -- Warrior
    [2] = Rollouts.data.colours.paladin, -- Paladin
    [3] = Rollouts.data.colours.hunter, -- Hunter
    [4] = Rollouts.data.colours.rogue, -- Rogue
    [5] = Rollouts.data.colours.priest, -- Priest
    [6] = Rollouts.data.colours.dk, -- DeathKnight
    [7] = Rollouts.data.colours.shaman, -- Shaman
    [8] = Rollouts.data.colours.mage, -- Mage
    [9] = Rollouts.data.colours.warlock, -- Warlock
    [10] = Rollouts.data.colours.monk, -- Monk
    [11] = Rollouts.data.colours.druid, -- Druid
    [12] = Rollouts.data.colours.dh, -- DemonHunter
}