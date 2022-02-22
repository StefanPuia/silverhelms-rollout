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
    ["INVTYPE_2HWEAPON"] = {16,17},
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
    [1] = {Rollouts.data.stats[1]}, -- Warrior
    [2] = {Rollouts.data.stats[1], Rollouts.data.stats[3]}, -- Paladin
    [3] = {Rollouts.data.stats[2]}, -- Hunter
    [4] = {Rollouts.data.stats[2]}, -- Rogue
    [5] = {Rollouts.data.stats[3]}, -- Priest
    [6] = {Rollouts.data.stats[1]}, -- DeathKnight
    [7] = {Rollouts.data.stats[2], Rollouts.data.stats[3]}, -- Shaman
    [8] = {Rollouts.data.stats[3]}, -- Mage
    [9] = {Rollouts.data.stats[3]}, -- Warlock
    [10] = {Rollouts.data.stats[2]}, -- Monk
    [11] = {Rollouts.data.stats[2], Rollouts.data.stats[3]}, -- Druid
    [12] = {Rollouts.data.stats[2]}, -- DemonHunter
}
Rollouts.data.specStats = {
    -- Death Knight
    [250] = Rollouts.data.stats[1], -- Blood
    [251] = Rollouts.data.stats[1], -- Frost
    [252] = Rollouts.data.stats[1], -- Unholy
    -- Paladin
    [66] = Rollouts.data.stats[1], -- Protection
    [70] = Rollouts.data.stats[1], -- Retribution
    -- Warrior
    [71] = Rollouts.data.stats[1], -- Arms
    [72] = Rollouts.data.stats[1], -- Fury
    [73] = Rollouts.data.stats[1], -- Protection
    -- Demon Hunter
    [577] = Rollouts.data.stats[2], -- Havoc
    [581] = Rollouts.data.stats[2], -- Vengeance
    -- Druid
    [103] = Rollouts.data.stats[2], -- Feral
    [104] = Rollouts.data.stats[2], -- Guardian
    -- Hunter
    [253] = Rollouts.data.stats[2], -- Beast Mastery
    [254] = Rollouts.data.stats[2], -- Marksmanship
    [255] = Rollouts.data.stats[2], -- Survival
    -- Monk
    [268] = Rollouts.data.stats[2], -- Brewmaster
    [269] = Rollouts.data.stats[2], -- Windwalker
    [270] = Rollouts.data.stats[2], -- Mistweaver
    -- Rogue
    [259] = Rollouts.data.stats[2], -- Assassination
    [260] = Rollouts.data.stats[2], -- Outlaw
    [261] = Rollouts.data.stats[2], -- Subtlety
    -- Shaman
    [263] = Rollouts.data.stats[2], -- Enhancement
    -- Druid
    [102] = Rollouts.data.stats[3], -- Balance
    [105] = Rollouts.data.stats[3], -- Restoration
    -- Mage
    [62] = Rollouts.data.stats[3], -- Arcane
    [63] = Rollouts.data.stats[3], -- Fire
    [64] = Rollouts.data.stats[3], -- Frost
    -- Paladin
    [65] = Rollouts.data.stats[3], -- Holy
    -- Priest
    [256] = Rollouts.data.stats[3], -- Discipline
    [257] = Rollouts.data.stats[3], -- Holy
    [258] = Rollouts.data.stats[3], -- Shadow
    -- Shaman
    [262] = Rollouts.data.stats[3], -- Elemental
    [264] = Rollouts.data.stats[3], -- Restoration
    -- Warlock
    [265] = Rollouts.data.stats[3], -- Affliction
    [266] = Rollouts.data.stats[3], -- Demonology
    [267] = Rollouts.data.stats[3], -- Destruction
}
Rollouts.data.failMessages = {
    ["ARMOR_TYPE"] = "armor type",
    ["WEAPON_TYPE"] = "weapon type",
    ["CLASS_WEAPON_TYPE"] = "class weapon type",
    ["NOT_MS_STAT"] = "not MS stat",
    ["NOT_OS_STAT"] = "not OS stat",
    ["ROLL_OWNER"] = "roll owner",
    ["ROLL_RULES"] = "roll rules",
    ["TOKEN_CLASS"] = "token class"
}
Rollouts.data.colours = {
    red = "FF0000",
    green = "00FF00",
    blue = "0000FF",
    yellow = "FFFF00",
    violet = "FF00FF",
    cyan = "00FFFF",
    gray = "484848",
    white = "FFFFFF",
    black = "000000",

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
Rollouts.data.specs = {
    -- Death Knight
    { value = "6.250", text = "|cffC41F3BBlood|r" },
    { value = "6.251", text = "|cffC41F3BFrost|r" },
    { value = "6.252", text = "|cffC41F3BUnholy|r" },
    -- Demon Hunter
    { value = "12.577", text = "|cffA330C9Havoc|r" },
    { value = "12.581", text = "|cffA330C9Vengeance|r" },
    -- Druid
    { value = "11.103", text = "|cffFF7D0AFeral|r" },
    { value = "11.104", text = "|cffFF7D0AGuardian|r" },
    { value = "11.102", text = "|cffFF7D0ABalance|r" },
    { value = "11.105", text = "|cffFF7D0ARestoration|r" },
    -- Hunter
    { value = "3.253", text = "|cffA9D271Beast Mastery|r" },
    { value = "3.254", text = "|cffA9D271Marksmanship|r" },
    { value = "3.255", text = "|cffA9D271Survival|r" },
    -- Mage
    { value = "8.62", text = "|cff40C7EBArcane|r" },
    { value = "8.63", text = "|cff40C7EBFire|r" },
    { value = "8.64", text = "|cff40C7EBFrost|r" },
    -- Monk
    { value = "10.268", text = "|cff00FF96Brewmaster|r" },
    { value = "10.269", text = "|cff00FF96Windwalker|r" },
    { value = "10.270", text = "|cff00FF96Mistweaver|r" },
    -- Paladin
    { value = "2.65", text = "|cffF58CBAHoly|r" },
    { value = "2.66", text = "|cffF58CBAProtection|r" },
    { value = "2.70", text = "|cffF58CBARetribution|r" },
    -- Priest
    { value = "5.256", text = "|cffFFFFFFDiscipline|r" },
    { value = "5.257", text = "|cffFFFFFFHoly|r" },
    { value = "5.258", text = "|cffFFFFFFShadow|r" },
    -- Rogue
    { value = "4.259", text = "|cffFFF569Assassination|r" },
    { value = "4.260", text = "|cffFFF569Outlaw|r" },
    { value = "4.261", text = "|cffFFF569Subtlety|r" },
    -- Shaman
    { value = "7.263", text = "|cff0070DEEnhancement|r" },
    { value = "7.262", text = "|cff0070DEElemental|r" },
    { value = "7.264", text = "|cff0070DERestoration|r" },
    -- Warlock
    { value = "9.265", text = "|cff8787EDAffliction|r" },
    { value = "9.266", text = "|cff8787EDDemonology|r" },
    { value = "9.267", text = "|cff8787EDDestruction|r" },
    -- Warrior
    { value = "1.71", text = "|cffC79C6EArms|r" },
    { value = "1.72", text = "|cffC79C6EFury|r" },
    { value = "1.73", text = "|cffC79C6EProtection|r" },
}
Rollouts.data.classes = {
    WARRIOR = 1,
    PALADIN = 2,
    HUNTER = 3,
    ROGUE = 4,
    PRIEST = 5,
    DEATHKNIGHT = 6,
    SHAMAN = 7,
    MAGE = 8,
    WARLOCK = 9,
    MONK = 10,
    DRUID = 11,
    DEMONHUNTER = 12,
}

local WEAPON = {
    H1 = {
        AXE = "One-Handed Axes",
        SWORD = "One-Handed Swords",
        MACE = "One-Handed Maces",
        FIST = "Fist",
        SHIELD = "Shields",
        DAGGER = "Daggers",
        WAND = "Wands",
        WARGLAIVE = "Warglaives"
    },
    H2 = {
        AXE = "Two-Handed Axes",
        SWORD = "Two-Handed Swords",
        MACE = "Two-Handed Maces",
        POLEARM = "Polearms",
        STAVE = "Staves",
        BOW = "Bows",
        CROSSBOW = "Crossbows",
        GUN = "Guns",
    }
}

Rollouts.data.weaponProficiencies = {
    -- Mage
    [62] = { WEAPON.H1.SWORD, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Arcane
    [63] = { WEAPON.H1.SWORD, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Fire
    [64] = { WEAPON.H1.SWORD, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Frost
    -- Paladin
    [66] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H1.MACE, WEAPON.H1.SHIELD }, -- Protection
    [70] = { WEAPON.H2.AXE, WEAPON.H2.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM }, -- Retribution
    [65] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H1.SHIELD }, -- Holy
    -- Warrior
    [71] = { WEAPON.H2.AXE, WEAPON.H2.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM }, -- Arms
    [72] = { WEAPON.H1.AXE, WEAPON.H2.AXE, WEAPON.H1.SWORD, WEAPON.H2.SWORD, WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H1.FIST }, -- Fury
    [73] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H1.MACE, WEAPON.H1.SHIELD }, -- Protection
    -- Druid
    [103] = { WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE }, -- Feral
    [104] = { WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE }, -- Guardian
    [102] = { WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE, WEAPON.H1.DAGGER }, -- Balance
    [105] = { WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE, WEAPON.H1.DAGGER }, -- Restoration
    -- Death Knight
    [250] = { WEAPON.H2.AXE, WEAPON.H2.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM }, -- Blood
    [251] = { WEAPON.H1.AXE, WEAPON.H2.AXE, WEAPON.H1.SWORD, WEAPON.H2.SWORD, WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.POLEARM }, -- Frost
    [252] = { WEAPON.H2.AXE, WEAPON.H2.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM }, -- Unholy
    -- Hunter
    [253] = { WEAPON.H1.SWORD, WEAPON.H2.BOW, WEAPON.H2.CROSSBOW, WEAPON.H2.GUN }, -- Beast Mastery
    [254] = { WEAPON.H1.SWORD, WEAPON.H2.BOW, WEAPON.H2.CROSSBOW, WEAPON.H2.GUN }, -- Marksmanship
    [255] = { WEAPON.H1.SWORD, WEAPON.H2.POLEARM }, -- Survival
    -- Priest
    [256] = { WEAPON.H1.MACE, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Discipline
    [257] = { WEAPON.H1.MACE, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Holy
    [258] = { WEAPON.H1.MACE, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Shadow
    -- Rogue
    [259] = { WEAPON.H1.DAGGER }, -- Assassination
    [260] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H1.MACE, WEAPON.H1.FIST }, -- Outlaw
    [261] = { WEAPON.H1.DAGGER }, -- Subtlety
    -- Shaman
    [262] = { WEAPON.H1.AXE, WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.SHIELD }, -- Elemental
    [264] = { WEAPON.H1.AXE, WEAPON.H1.MACE, WEAPON.H2.MACE, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.SHIELD }, -- Restoration
    [263] = { WEAPON.H1.AXE, WEAPON.H1.MACE, WEAPON.H1.FIST }, -- Enhancement
    -- Warlock
    [265] = { WEAPON.H1.SWORD, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Affliction
    [266] = { WEAPON.H1.SWORD, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Demonology
    [267] = { WEAPON.H1.SWORD, WEAPON.H2.STAVE, WEAPON.H1.DAGGER, WEAPON.H1.WAND }, -- Destruction
    -- Monk
    [268] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE, WEAPON.H1.FIST }, -- Brewmaster
    [269] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE, WEAPON.H1.FIST }, -- Windwalker
    [270] = { WEAPON.H1.AXE, WEAPON.H1.SWORD, WEAPON.H2.MACE, WEAPON.H2.POLEARM, WEAPON.H2.STAVE, WEAPON.H1.FIST }, -- Mistweaver
    -- Demon Hunter
    [577] = { WEAPON.H1.WARGLAIVE, WEAPON.H1.FIST, WEAPON.H1.AXE, WEAPON.H1.SWORD}, -- Havoc
    [581] = { WEAPON.H1.WARGLAIVE, WEAPON.H1.FIST, WEAPON.H1.AXE, WEAPON.H1.SWORD}, -- Vengeance
}

Rollouts.data.classWeapons = {
    [1] = {
        Rollouts.data.weaponProficiencies[71],
        Rollouts.data.weaponProficiencies[72],
        Rollouts.data.weaponProficiencies[73],
    }, -- Warrior
    [2] = {
        Rollouts.data.weaponProficiencies[65],
        Rollouts.data.weaponProficiencies[66],
        Rollouts.data.weaponProficiencies[70],
    }, -- Paladin
    [3] = {
        Rollouts.data.weaponProficiencies[253],
        Rollouts.data.weaponProficiencies[254],
        Rollouts.data.weaponProficiencies[255],
    }, -- Hunter
    [4] = {
        Rollouts.data.weaponProficiencies[259],
        Rollouts.data.weaponProficiencies[260],
        Rollouts.data.weaponProficiencies[261],
    }, -- Rogue
    [5] = {
        Rollouts.data.weaponProficiencies[256],
        Rollouts.data.weaponProficiencies[257],
        Rollouts.data.weaponProficiencies[258],
    }, -- Priest
    [6] = {
        Rollouts.data.weaponProficiencies[250],
        Rollouts.data.weaponProficiencies[251],
        Rollouts.data.weaponProficiencies[252],
    }, -- DeathKnight
    [7] = {
        Rollouts.data.weaponProficiencies[262],
        Rollouts.data.weaponProficiencies[264],
        Rollouts.data.weaponProficiencies[263],
    }, -- Shaman
    [8] = {
        Rollouts.data.weaponProficiencies[62],
        Rollouts.data.weaponProficiencies[63],
        Rollouts.data.weaponProficiencies[64],
    }, -- Mage
    [9] = {
        Rollouts.data.weaponProficiencies[265],
        Rollouts.data.weaponProficiencies[266],
        Rollouts.data.weaponProficiencies[267],
    }, -- Warlock
    [10] = {
        Rollouts.data.weaponProficiencies[268],
        Rollouts.data.weaponProficiencies[269],
        Rollouts.data.weaponProficiencies[270],
    }, -- Monk
    [11] = {
        Rollouts.data.weaponProficiencies[102],
        Rollouts.data.weaponProficiencies[103],
        Rollouts.data.weaponProficiencies[104],
        Rollouts.data.weaponProficiencies[105],
    }, -- Druid
    [12] = {
        Rollouts.data.weaponProficiencies[577],
        Rollouts.data.weaponProficiencies[581],
    }, -- DemonHunter
}

local TOKENS = {
  ['PATCH_9_2'] = {
    ['VENERATED'] = { -- Paladin, Priest, Shaman
      ['HELM'] = '191003',
      ['CHEST'] = '191012',
      ['SHOULDER'] = '191008',
      ['HANDS'] = '191016',
      ['LEGS'] = '191020',
    },
    ['DREADFUL'] = { -- Death Knight, Demon Hunter, Warlock
      ['HELM'] = '191005',
      ['CHEST'] = '191010',
      ['SHOULDER'] = '191006',
      ['HANDS'] = '191014',
      ['LEGS'] = '191018',
    },
    ['MYSTIC'] = { -- Druid, Hunter, Mage
      ['HELM'] = '191002',
      ['CHEST'] = '191011',
      ['SHOULDER'] = '191007',
      ['HANDS'] = '191015',
      ['LEGS'] = '191019',
    },
    ['ZENITH'] = { -- Monk, Rogue, Warrior
      ['HELM'] = '191004',
      ['CHEST'] = '191013',
      ['SHOULDER'] = '191009',
      ['HANDS'] = '191017',
      ['LEGS'] = '191021',
    },
  }
}

Rollouts.data.tokenSlot = {
    ["INVTYPE_HEAD"] = {
        TOKENS.PATCH_9_2.DREADFUL.HELM,
        TOKENS.PATCH_9_2.MYSTIC.HELM,
        TOKENS.PATCH_9_2.ZENITH.HELM,
        TOKENS.PATCH_9_2.VENERATED.HELM,
    },
    ["INVTYPE_SHOULDER"] = {
        TOKENS.PATCH_9_2.DREADFUL.SHOULDER,
        TOKENS.PATCH_9_2.MYSTIC.SHOULDER,
        TOKENS.PATCH_9_2.ZENITH.SHOULDER,
        TOKENS.PATCH_9_2.VENERATED.SHOULDER,
    },
    ["INVTYPE_CHEST"] = {
        TOKENS.PATCH_9_2.DREADFUL.CHEST,
        TOKENS.PATCH_9_2.MYSTIC.CHEST,
        TOKENS.PATCH_9_2.ZENITH.CHEST,
        TOKENS.PATCH_9_2.VENERATED.CHEST,
    },
    ["INVTYPE_HAND"] = {
        TOKENS.PATCH_9_2.DREADFUL.HANDS,
        TOKENS.PATCH_9_2.MYSTIC.HANDS,
        TOKENS.PATCH_9_2.ZENITH.HANDS,
        TOKENS.PATCH_9_2.VENERATED.HANDS,
    },
    ["INVTYPE_LEGS"] = {
        TOKENS.PATCH_9_2.DREADFUL.LEGS,
        TOKENS.PATCH_9_2.MYSTIC.LEGS,
        TOKENS.PATCH_9_2.ZENITH.LEGS,
        TOKENS.PATCH_9_2.VENERATED.LEGS,
    },
}

Rollouts.data.tokenClasses = {
    [1] = { -- Warrior
      TOKENS.PATCH_9_2.ZENITH.HELM,
      TOKENS.PATCH_9_2.ZENITH.CHEST,
      TOKENS.PATCH_9_2.ZENITH.SHOULDER,
      TOKENS.PATCH_9_2.ZENITH.HANDS,
      TOKENS.PATCH_9_2.ZENITH.LEGS,
    },
    [2] = { -- Paladin
      TOKENS.PATCH_9_2.VENERATED.HELM,
      TOKENS.PATCH_9_2.VENERATED.CHEST,
      TOKENS.PATCH_9_2.VENERATED.SHOULDER,
      TOKENS.PATCH_9_2.VENERATED.HANDS,
      TOKENS.PATCH_9_2.VENERATED.LEGS,
    },
    [3] = { -- Hunter
      TOKENS.PATCH_9_2.MYSTIC.HELM,
      TOKENS.PATCH_9_2.MYSTIC.CHEST,
      TOKENS.PATCH_9_2.MYSTIC.SHOULDER,
      TOKENS.PATCH_9_2.MYSTIC.HANDS,
      TOKENS.PATCH_9_2.MYSTIC.LEGS,
    },
    [4] = { -- Rogue
      TOKENS.PATCH_9_2.ZENITH.HELM,
      TOKENS.PATCH_9_2.ZENITH.CHEST,
      TOKENS.PATCH_9_2.ZENITH.SHOULDER,
      TOKENS.PATCH_9_2.ZENITH.HANDS,
      TOKENS.PATCH_9_2.ZENITH.LEGS,
    },
    [5] = { -- Priest
      TOKENS.PATCH_9_2.VENERATED.HELM,
      TOKENS.PATCH_9_2.VENERATED.CHEST,
      TOKENS.PATCH_9_2.VENERATED.SHOULDER,
      TOKENS.PATCH_9_2.VENERATED.HANDS,
      TOKENS.PATCH_9_2.VENERATED.LEGS,
    },
    [6] = { -- DeathKnight
      TOKENS.PATCH_9_2.DREADFUL.HELM,
      TOKENS.PATCH_9_2.DREADFUL.CHEST,
      TOKENS.PATCH_9_2.DREADFUL.SHOULDER,
      TOKENS.PATCH_9_2.DREADFUL.HANDS,
      TOKENS.PATCH_9_2.DREADFUL.LEGS,
    },
    [7] = { -- Shaman
      TOKENS.PATCH_9_2.VENERATED.HELM,
      TOKENS.PATCH_9_2.VENERATED.CHEST,
      TOKENS.PATCH_9_2.VENERATED.SHOULDER,
      TOKENS.PATCH_9_2.VENERATED.HANDS,
      TOKENS.PATCH_9_2.VENERATED.LEGS,
    },
    [8] = { -- Mage
      TOKENS.PATCH_9_2.MYSTIC.HELM,
      TOKENS.PATCH_9_2.MYSTIC.CHEST,
      TOKENS.PATCH_9_2.MYSTIC.SHOULDER,
      TOKENS.PATCH_9_2.MYSTIC.HANDS,
      TOKENS.PATCH_9_2.MYSTIC.LEGS,
    },
    [9] = { -- Warlock
      TOKENS.PATCH_9_2.DREADFUL.HELM,
      TOKENS.PATCH_9_2.DREADFUL.CHEST,
      TOKENS.PATCH_9_2.DREADFUL.SHOULDER,
      TOKENS.PATCH_9_2.DREADFUL.HANDS,
      TOKENS.PATCH_9_2.DREADFUL.LEGS,
    },
    [10] = { -- Monk
      TOKENS.PATCH_9_2.ZENITH.HELM,
      TOKENS.PATCH_9_2.ZENITH.CHEST,
      TOKENS.PATCH_9_2.ZENITH.SHOULDER,
      TOKENS.PATCH_9_2.ZENITH.HANDS,
      TOKENS.PATCH_9_2.ZENITH.LEGS,
    },
    [11] = { -- Druid
      TOKENS.PATCH_9_2.MYSTIC.HELM,
      TOKENS.PATCH_9_2.MYSTIC.CHEST,
      TOKENS.PATCH_9_2.MYSTIC.SHOULDER,
      TOKENS.PATCH_9_2.MYSTIC.HANDS,
      TOKENS.PATCH_9_2.MYSTIC.LEGS,
    },
    [12] = { -- DemonHunter
      TOKENS.PATCH_9_2.DREADFUL.HELM,
      TOKENS.PATCH_9_2.DREADFUL.CHEST,
      TOKENS.PATCH_9_2.DREADFUL.SHOULDER,
      TOKENS.PATCH_9_2.DREADFUL.HANDS,
      TOKENS.PATCH_9_2.DREADFUL.LEGS,
    },
}
