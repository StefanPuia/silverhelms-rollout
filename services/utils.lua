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

Rollouts.utils.makeRollEntryObject = function(itemLink, owners, rollType, time)
    owners = owners or { GetUnitName("player") }
    time = time or GetServerTime()
    rollType = rollType or Rollouts.utils.getEitherDBOption("defaultRollType")
    return {
        itemLink = itemLink,
        owners = Rollouts.utils.cloneArray(owners),
        time = time,
        rollType = rollType,
        rolls = {}
    }
end

Rollouts.utils.sanitizeRollEntryObject = function(entry)
    return {
        itemLink = entry.itemLink,
        owners = entry.owners,
        time = entry.time,
        rollType = entry.rollType,
        rolls = {}
    }
end

Rollouts.utils.makeRollObject = function(name, roll, guildName, rankName, class, failMessage, spec, equipped)
    local guildRanks = Rollouts.utils.getEitherDBOption("guildRanking", "guilds")
    local guildIndex = Rollouts.utils.indexOf(guildRanks, function(g) return g.name == guildName end) or 1
    guildIndex = guildIndex > 1 and guildIndex or 1
    local rankIndex = guildRanks[guildIndex] and Rollouts.utils.indexOf(guildRanks[guildIndex].ranks, function(r)
        return Rollouts.utils.indexOf(r, rankName) > 0
    end) or 1
    rankIndex = rankIndex > 1 and rankIndex or 1
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
        failMessage = failMessage,
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

Rollouts.utils.colourizeUnit = function(unitName, classId)
    unitName = Rollouts.utils.sanitizeUnitName(unitName)
    if not classId then
        classId = UnitIsVisible(unitName) and select(3, UnitClass(unitName)) or nil
    end
    return classId ~= nil and Rollouts.utils.colour(unitName, Rollouts.data.classColours[classId]) or unitName
end

Rollouts.utils.simplifyName = function(unitName, capitalise)
    local simple = string.lower(Rollouts.utils.removeColour(Rollouts.utils.sanitizeUnitName(unitName)))
    if capitalise then return Rollouts.utils.capitalise(simple) end
    return simple
end

Rollouts.utils.removeColour = function(text)
    text = text or ""
    local hasColour = strfind(text, "^(|cff)")
    return hasColour and string.sub(text, 11, -3) or text
end

Rollouts.utils.contains = function(array, item)
    return Rollouts.utils.indexOf(array, item) > 0
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
    return string.upper(string.sub(text, 1, 1)) .. string.lower(string.sub(text, 2))
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
    if UnitInParty("player") then
        return UnitInParty(unitName) or UnitInRaid(unitName)
    end
    return Rollouts.utils.simplifyName(GetUnitName("player")) == Rollouts.utils.simplifyName(unitName)
end

Rollouts.utils.tableSize = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

Rollouts.utils.printDebug = function(text)
    if Rollouts.utils.getEitherDBOption("debugMode") then
        Rollouts:Print(text)
    end
end

Rollouts.utils.cloneArray = function(table)
    local clone = {}
    for k,v in pairs(table) do
        clone[k] = v
    end
    return clone
end

Rollouts.utils.getItemLinkData = function(itemString)
    if not itemString then return {} end
    local _, itemID, enchantID, gemID1, gemID2, gemID3, gemID4,
        suffixID, uniqueID, linkLevel, specializationID, upgradeTypeID, instanceDifficultyID, numBonusIDs = strsplit(":", itemString)
    local tempString, _, _, _ = strmatch(itemString,
        "item:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:[-%d]-:([-:%d]+):([-%d]-):([-%d]-):([-%d]-)|")
    tempString = tempString or ""
    local bonusIDs, upgradeValue
    if upgradeTypeID and upgradeTypeID ~= "" then
        upgradeValue = tempString:match("[-:%d]+:([-%d]+)")
        bonusIDs = {strsplit(":", tempString:match("([-:%d]+):"))}
    else
        bonusIDs = {strsplit(":", tempString)}
    end

    return {
        itemId = itemID,
        enchantId = enchantID,
        gemId1 = gemID1,
        gemId2 = gemID2,
        gemId3 = gemID3,
        gemId4 = gemID4,
        suffixId = suffixID,
        uniqueId = uniqueID,
        linkLevel = linkLevel,
        specializationId = specializationID,
        upgradeTypeId = upgradeTypeID,
        instanceDifficultyId = instanceDifficultyID,
        numBonusIds = numBonusIDs,
        bonusIds = bonusIDs,
        upgradeValue = upgradeValue
    }
end

local function canBeGrouped(itemLink1, itemLink2)
    local itemData1 = Rollouts.utils.getItemLinkData(itemLink1)
    local itemData2 = Rollouts.utils.getItemLinkData(itemLink2)
    return itemData1.itemId == itemData2.itemId
end

Rollouts.utils.groupPending = function()
    local pending = Rollouts.utils.getEitherDBOption("data", "rolls", "pending")
    local grouped = {}
    if #pending > 0 then table.insert(grouped, pending[1]) end
    for i = 2, #pending do
        local index = Rollouts.utils.indexOf(grouped, function(grp) return canBeGrouped(grp.itemLink, pending[i].itemLink) end)
        if index > 0 then
            for o, owner in ipairs(pending[i].owners) do
                table.insert(grouped[index].owners, owner)
            end
        else
            table.insert(grouped, pending[i])
        end
    end
    Rollouts.utils.setDBOption(grouped, "data", "rolls", "pending")
    Rollouts.ui.updateWindow()
end

Rollouts.utils.cleanupHistory = function()
    local days = Rollouts.utils.getEitherDBOption("autoRemoveDays")
    local history = Rollouts.utils.getEitherDBOption("data", "rolls", "history")
    local cleaned = {}
    local now = GetServerTime()
    if days > 0 then
        local limit = now - 60 * 60 * 24 * days
        for i = 1, #history do
            if history[i].time > limit then
                table.insert(cleaned, history[i])
            end
        end
    end
    Rollouts.utils.setDBOption(cleaned, "data", "rolls", "history")
end

Rollouts.utils.parseGuildRanking = function(input)
    if not input then return nil end
    local guilds = {}
    local lastGuild = nil
    local lines = Rollouts.utils.strSplit(input, "\n")
    for p, l in ipairs(lines) do
        local line = string.trim(l)
        if line ~= "" then
            if string.find(line, "-\\-") == 1 then
                -- comment, do nothing
            elseif string.find(line, "#") == 1 then
                if lastGuild ~= nil then table.insert(guilds, lastGuild) end
                local guildName = string.trim(string.sub(line, 2))
                lastGuild = {
                    name = guildName,
                    ranks = {}
                }
            else
                if lastGuild == nil then return nil end
                local ranks = Rollouts.utils.strSplit(line, ",")
                for i, rank in ipairs(ranks) do ranks[i] = string.trim(rank) end
                table.insert(lastGuild.ranks, ranks)
            end
        end
    end
    if lastGuild ~= nil then table.insert(guilds, lastGuild) end

    local sortedGuilds = {}
    for i = #guilds, 1, -1 do
        local sortedRanks = {}
        for j = #(guilds[i].ranks), 1, -1 do
            table.insert(sortedRanks, guilds[i].ranks[j])
        end
        table.insert(sortedGuilds, {
            name = guilds[i].name,
            ranks = sortedRanks
        })
    end

    return sortedGuilds
end

Rollouts.utils.stringifyGuildRanking = function(ranking)
    local output = {
        "-- Use dashes (--) to show comments",
        "-- Hashtags (#) mean a guild name",
        "-- Split ranks that should have the same ranking with a comma (,)",
        "-- Keep in mind that guild names and ranks are case-sensitive (aA)",
        "-- Use asterisk (*) to allow any rank",
        ""
    }

    for guildId = #ranking, 1, -1 do
        table.insert(output, "\n# " .. ranking[guildId].name)
        for rankId = #ranking[guildId].ranks, 1, -1 do
            table.insert(output, table.concat(ranking[guildId].ranks[rankId], ", "))
        end
    end

    return table.concat(output, "\n")
end

Rollouts.utils.queryGuildMembers = function(player)
    numTotalMembers, numOnlineMaxLevelMembers, numOnlineMembers = GetNumGuildMembers();

    for i = 0, numTotalMembers do
    name, rank, rankIndex, level, class, zone, note,
            officernote, online, status, classFileName = GetGuildRosterInfo(i)

        if name == Rollouts.utils.qualifyUnitName(player) then
            return {
            name = name,
            rank = rank,
            rankIndex = rankIndex,
            level = level,
            class = class,
            zone = zone,
            note = note,
            officernote = officernote,
            online = online,
            status = status,
            classFileName = classFileName
        }
        end
    end

    return nil
end

Rollouts.utils.getItemMainStats = function(itemLinkString)
    local _,itemLink = GetItemInfo(itemLinkString)
    if not itemLink then return nil end
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    GameTooltip:SetHyperlink(itemLink)
    GameTooltip:Show()
    local stats = {}
    for i = 1, select("#", GameTooltip:GetRegions()) do
        local region = select(i, GameTooltip:GetRegions())
        if region and region:GetObjectType() == "FontString" then
            local text = region:GetText() -- string or nil
            local stat = string.upper(string.match(text or "", "+[%d,]+ (%w+)") or "")
            if stat and Rollouts.utils.indexOf({"STRENGTH", "INTELLECT", "AGILITY"}, stat) > 0 then
                table.insert(stats, stat)
            end
        end
    end
    GameTooltip:Hide()

    return #stats ~= 0 and stats or nil
end

Rollouts.utils.canClassEquip = function(class, weaponType)
    if class == nil or weaponType == nil then return false end
    local classWeaponList = Rollouts.data.classWeapons[class]
    local allWeapons = {}
    for _,list in ipairs(classWeaponList) do
        for _,v in ipairs(list) do
            table.insert(allWeapons, v)
        end
    end
    return Rollouts.utils.contains(allWeapons, weaponType)
end

Rollouts.utils.getRollSlotForToken = function(itemLink)
    local itemData = Rollouts.utils.getItemLinkData(itemLink)
    if itemData ~= nil and itemData.itemId ~= nil then
        local itemId = itemData.itemId
        for slot, itemIds in pairs(Rollouts.data.tokenSlot) do
            if Rollouts.utils.contains(itemIds, itemId) then
                return slot
            end
        end
    end
    return ""
end
