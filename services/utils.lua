local LibStub = _G.LibStub
local Rollouts = LibStub("AceAddon-3.0"):GetAddon("Rollouts")
Rollouts.utils = {}

Rollouts.runAsync = function(caller, callback, ...)
    caller(..., callback)
end

Rollouts.utils.strSplit = function(str, sep)
    str = str .. sep
    return {str:match((str:gsub("[^"..sep.."]*"..sep, "([^"..sep.."]*)"..sep)))}
end

Rollouts.utils.stringify = function (variable, i)
    if variable == nil then return "nil" end
    if type(variable) ~= "table" then return "'" .. tostring(variable) .. "'" end
    local x = ""
    if i == nil then i = 0 end
    for k,v in pairs(variable) do
        local value = type(v) == "table" and "{\n" .. Rollouts.utils.stringify(v, i + 1) .. string.rep(" ", (i - 1) * 2) .. "}" or "'" .. tostring(v) .. "'"
        x = x .. string.rep(" ", i * 2) .. "[" .. k .. "] = " .. value .. "\n"
    end
    return x
end

local function getDBOptionRecursive(db, ...)
    local currentVal = ({select(1, ...)})[1]
    local nextVal = ({select(1, ...)})[2]
    if (nextVal ~= nil) then
        if db[currentVal] == nil then db[currentVal] = {} end
        return getDBOptionRecursive(db[currentVal], select(2, ...))
    else
        return db[currentVal]
    end
end
Rollouts.utils.getDBOption = function(...)
    return getDBOptionRecursive(Rollouts.db.global, ...)
end

local function setDBOptionRecursive(db, val, ...)
    local currentVal = ({select(1, ...)})[1]
    local nextVal = ({select(1, ...)})[2]
    if db[currentVal] == nil then db[currentVal] = {} end
    if (nextVal ~= nil) then
        setDBOptionRecursive(db[currentVal], val, select(2, ...))
    else
        db[currentVal] = val
    end
end

Rollouts.utils.setDBOption = function(val, ...)
    setDBOptionRecursive(Rollouts.db.global, val, ...)
end

Rollouts.utils.getEitherDBOption = function(...)
    return getDBOptionRecursive(Rollouts.db.global, ...) or getDBOptionRecursive(Rollouts.defaultOptions, ...)
end

Rollouts.utils.intToHex = function(int)
    local hex = string.format("%x", int)
    return string.sub("00" .. hex, -2)
end

Rollouts.utils.colour = function(text, rOrHex, g, b)
    text = text or ""
    local r = g ~= nil and rOrHex or nil
    if r and g and b then
        r = Rollouts.utils.intToHex(r * 256)
        g = Rollouts.utils.intToHex(g * 256)
        b = Rollouts.utils.intToHex(b * 256)
        return "|cff" .. r .. g .. b .. text .. "|r"
    elseif rOrHex then
        hex = Rollouts.data.colours[rOrHex] or rOrHex
        return "|cff" .. hex .. text .. "|r"
    end
    return text
end

Rollouts.utils.makeRollEntryObject = function(itemLink, owner, rollType, time)
    owner = owner or GetUnitName("player")
    time = time or GetServerTime()
    rollType = rollType or Rollouts.utils.getEitherDBOption("defaultRollType")
    return {
        itemLink = itemLink,
        owner = owner,
        time = time,
        rollType = rollType,
        rolls = {}
    }
end

Rollouts.utils.sanitizeRollEntryObject = function(entry)
    return {
        itemLink = entry.itemLink,
        owner = entry.owner,
        time = entry.time,
        rollType = entry.rollType,
        rolls = {}
    }
end

Rollouts.utils.makeRollObject = function(name, roll, guildName, rankName, class, failMesage, spec, equipped)
    local guildRanks = Rollouts.utils.getEitherDBOption("guildRanking", "guilds")
    local guildIndex = Rollouts.utils.indexOf(guildRanks, function(g) return g.name == guildName end) or 1
    local rankIndex = guildRanks[guildIndex] and Rollouts.utils.indexOf(guildRanks[guildIndex].ranks, function(r)
        return Rollouts.utils.indexOf(r, rankName) > 0
    end) or 1
    return {
        name = name,
        guild = guildIndex,
        guildName = guildName,
        rank = rankIndex,
        rankName = rankName,
        class = class,
        spec = spec,
        roll = roll,
        equipped = equipped,
        failMesage = failMesage,
    }
end

Rollouts.utils.stringContainsItem = function(str)
    return string.find(str, "::") ~= nil and strfind(str, "|H(.-)|h")
end

Rollouts.utils.concat = function(table1, table2)
    local returnTable = {}
    for k,v in ipairs(table1) do
        table.insert(returnTable, v)
    end
    for k,v in ipairs(table2) do
        table.insert(returnTable, v)
    end
    return returnTable
end

Rollouts.utils.formatStamp = function(long)
    return date('%Y-%m-%d %H:%M:%S', long)
end

Rollouts.utils.sanitizeUnitName = function(unitName)
    if unitName == nil then return "" end
    return ({unitName:gsub("-" .. GetRealmName(), "")})[1]
end

Rollouts.utils.colourizeUnit = function(unitName)
    unitName = Rollouts.utils.sanitizeUnitName(unitName)
    local classId = UnitIsVisible(unitName) and select(3, UnitClass(unitName)) or nil
    return classId ~= nil and Rollouts.utils.colour(unitName, Rollouts.data.classColours[classId]) or unitName
end

Rollouts.utils.simplifyName = function(unitName)
    return string.lower(Rollouts.utils.removeColour(Rollouts.utils.sanitizeUnitName(unitName)))
end

Rollouts.utils.removeColour = function(text)
    text = text or ""
    local hasColour = strfind(text, "^(|cff)")
    return hasColour and string.sub(text, 11, -3) or text
end

Rollouts.utils.indexOf = function(table, predicate)
    for i, v in ipairs(table) do
        if type(predicate) == "function" then
            if predicate(v) then return i end
        else
            if predicate == v then return i end
        end
    end
    return 0
end

Rollouts.utils.capitalise = function(text)
    return string.upper(string.sub(text, 1, 2)) .. string.lower(string.sub(text, 2))
end

Rollouts.utils.qualifyUnitName = function(unitName, ignoreSameRealm)
    ignoreSameRealm = ignoreSameRealm or false
    local simple = Rollouts.utils.capitalise(Rollouts.utils.simplifyName(unitName))
    if string.find(simple, "-") ~= nil then return simple end
    if ignoreSameRealm then return simple end
    return simple .. "-" .. GetRealmName()
end

Rollouts.utils.unitInGroup = function(unitName)
    unitName = Rollouts.utils.simplifyName(unitName)
    return UnitInParty(unitName) or UnitInRaid(unitName)
end