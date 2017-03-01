
assert( oRA, "oRA not found!")


------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("oRAGroupSetup")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["Group Setup"] = true,
    ["groupsetup"] = true, -- console
    ["Options for the group setup plugin."] = true,
    ["save"] = true, -- console
    ["Save"] = true,
    ["Save current group setup."] = true,
    ["<id>"] = true,
            
    ["restore"] = true,
    ["Restore"] = true,
    ["Restore saved group setup."] = true,
            
    ["remove"] = true,
    ["Remove"] = true,
    ["Remove saved group setup."] = true,
            
    ["Group Setup: Please provide an ID"] = true,
    ["Group Setup saved with id: "] = true,
    ["no information for player %s available"] = true,
    ["Group Setup |cff81d11f%s|r restored"] = true,
    ["Setup %s"] = true,
    ["You are not the raid leader or a raid assistant which will be necessary to restore a setup."] = true,
    ["You need to be the raid leader or an assitant to restore a group setup."] = true,
	["Could not restore setup |cffff0000%s|r"] = true,
    ["Restoring setup |cfffca820%s|r"] = true,
} end)

L:RegisterTranslations("deDE", function() return {
    ["Group Setup"] = "Gruppenaufstellung",
    ["groupsetup"] = "gruppenaufstellung", -- console
    ["Options for the group setup plugin."] = "Optionen für das Gruppenaufstellung-Plugin",
    ["save"] = "speichern", -- console
    ["Save"] = "Speichern",
    ["Save current group setup."] = "Aktuelle Gruppenaufstellung speichern",
    ["<id>"] = "<id>",
            
    ["restore"] = "wiederherstellen",
    ["Restore"] = "Wiederherstellen",
    ["Restore saved group setup."] = "Gespeicherte Gruppenaufstellung wiederherstellen.",
            
    ["remove"] = "entfernen",
    ["Remove"] = "Entfernen",
    ["Remove saved group setup."] = "Gespeicherte Gruppenaufstellung entfernen.",
            
    ["Group Setup: Please provide an ID"] = "Gruppenaufstellung: Bitte gib eine ID an.",
    ["Group Setup saved with id: "] = "Gruppenaufstellung gespeichert mit der id: ",
    ["no information for player %s available"] = "keine Informationen für den Spieler %s verfügbar",
    ["Group Setup |cff81d11f%s|r restored"] = "Gruppenaufstellung |cff81d11f%s|r wiederhergestellt",
    ["Setup %s"] = "Aufstellung %s",
    ["You are not the raid leader or a raid assistant which will be necessary to restore a setup."] = "Du bist nicht der Schlachtzugsleiter oder ein Assistent, was notwendig sein wird um eine Aufstellung wiederherstellen zu können.",
    ["You need to be the raid leader or an assitant to restore a group setup."] = "Du musst der Schlachtzugsleiter oder ein Assistent sein, um eine Gruppenaufstellung wiederherstellen zu können.",
	["Could not restore setup |cffff0000%s|r"] = "Setup |cffff0000%s|r konnte nicht wiederhergestellt werden.",
    ["Restoring setup |cfffca820%s|r"] = "Setup |cfffca820%s|r wird wiederhergestellt."
} end)


----------------------------------
--      Module Declaration      --
----------------------------------

oRAGroupSetup = oRA:NewModule("Group Setup")
oRAGroupSetup.revision = 20008
oRAGroupSetup.defaultDB = {
	database = {},
    idList = {},
    tmpRaidRoster = {}, -- keep our own raid roster information since GetRaidRosterInfo is buffered
}


oRAGroupSetup.consoleCmd = L["groupsetup"]
oRAGroupSetup.consoleOptions = {
	type = "group",
	name = L["Group Setup"],
	desc = L["Options for the group setup plugin."],
	args   = {
		[L["save"]] = {
			type = "text",
			name = L["Save"],
			desc = L["Save current group setup."],
            usage = L["<id>"],
            get = false,
            set = function(id) oRAGroupSetup:Save(id) end,
            order = 1
		},
		[L["restore"]] = {
			type = "text",
			name = L["Restore"],
			desc = L["Restore saved group setup."],
			get = false,
            validate = {},
			set = function(id)
				oRAGroupSetup:Restore(id)
			end,
            order = 2
		},
        [L["remove"]] = {
			type = "text",
			name = L["Remove"],
			desc = L["Remove saved group setup."],
			get = false,
            validate = {},
			set = function(id)
				oRAGroupSetup:Clear(id)
			end,
            order = 3
		}
	},
}


------------------------------
--      Initialization      --
------------------------------
function oRAGroupSetup:OnEnable()
    --self:RegisterEvent("oRA_RecvSync")
    if not self.db.profile.idList then
        self.db.profile.idList = {}
    end    
    if not self.db.profile.database then
        self.db.profile.database = {}
    end
    
    self.consoleOptions.args[L["restore"]].validate = self.db.profile.idList -- update menu
    self.consoleOptions.args[L["remove"]].validate = self.db.profile.idList -- update menu
end


------------------------------
--      Event Handlers      --
------------------------------

local function removeKey(aTable, aKey)
    local tmp = {}
    for k, v in pairs(aTable) do
        if k ~= aKey then
            tmp[k] = v
        end
    end
    return tmp
end
function oRAGroupSetup:Clear(id)
    if id then        
        local tmp = {}
        for k, v in pairs(self.db.profile.database) do
            if k ~= id then
                tmp[k] = v
            end
        end
        self.db.profile.database = tmp
        
        tmp = {}
        for k, v in pairs(self.db.profile.idList) do
            if v ~= id then
                tmp[k] = v
            end
        end
        self.db.profile.idList = tmp
    else
        self.db.profile.database = {}
        self.db.profile.idList = {}
    end
    
    self.consoleOptions.args[L["restore"]].validate = self.db.profile.idList -- update menu
    self.consoleOptions.args[L["remove"]].validate = self.db.profile.idList -- update menu
end

function oRAGroupSetup:Save(id)
    if not id or id == "" then
        oRA:Print(L["Group Setup: Please provide an ID"])
    --[[elseif self.db.profile.database[id] then
        oRA:Print("Group Setup: ID already exists")]]
    else
        local setup = {}
        for i=1, GetNumRaidMembers() do
            local name, _, subgroup = GetRaidRosterInfo(i)
            setup[name] = subgroup
        end
        
        -- only save in idList if the entry does not already exist. otherwise we would have two entries for the same id
        if not self.db.profile.database[id] then
            table.insert(self.db.profile.idList, id)
        end
        self.db.profile.database[id] = setup
        
        self.consoleOptions.args[L["restore"]].validate = self.db.profile.idList -- update menu
        self.consoleOptions.args[L["remove"]].validate = self.db.profile.idList -- update menu
        
        oRA:Print(L["Group Setup saved with id: "] .. id)
        if not (IsRaidLeader() or IsRaidOfficer()) then
            oRA:Print(L["You are not the raid leader or a raid assistant which will be necessary to restore a setup."]) 
        end
    end
end

--[[ ------------------------------------------------
-- RESTORE UTILITY FUNCTIONS
--------------------------------------------------- ]]
local unknownRaidIds = {}
local movedId = {}
local restoreInProgress = false

local function myGetRaidRosterInfo(index)
    if not index then
        return nil
    else
        if oRAGroupSetup.db.profile.tmpRaidRoster[index] then
            return oRAGroupSetup.db.profile.tmpRaidRoster[index].name, 
                oRAGroupSetup.db.profile.tmpRaidRoster[index].rank,
                oRAGroupSetup.db.profile.tmpRaidRoster[index].subgroup
        end
    end
    
    return nil
end
function printRoster()
    local tmp = {
        [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {},
    }
    for i=1, GetNumRaidMembers() do
        --local name, rank, subgroup = myGetRaidRosterInfo(i)
        --table.insert(tmp[subgroup], name)
        table.insert(tmp[oRAGroupSetup.db.profile.tmpRaidRoster[i].subgroup], oRAGroupSetup.db.profile.tmpRaidRoster[i].name)
    end
    
    for i=1, 8 do
        local msg = "g" .. i
        for j=1, table.getn(tmp[i]) do
            msg = msg .. " " .. tmp[i][j]
        end
        oRA:DebugMessage("|cAAAAAAff" .. msg .. "|r")
    end
end
local function getSubgroupDistribution()
    local subgroupDistribution = {}
    for i=1, 8 do
        subgroupDistribution[i] = 0
    end
    
    for i=1, GetNumRaidMembers() do
        local _, _, subgroup = myGetRaidRosterInfo(i)
        subgroupDistribution[subgroup] = subgroupDistribution[subgroup] + 1
    end
    
    return subgroupDistribution
end

local function findPlayerInDesiredSubgroup(subgroup, rosterId)
    if not subgroup or not rosterId then
        return nil
    end
    
    for i=rosterId +1, GetNumRaidMembers() do
        local _, _, group = myGetRaidRosterInfo(i)
        if group == subgroup then
            return i
        end
    end
    
    for i=1, table.getn(unknownRaidIds) do
        local _, _, group = myGetRaidRosterInfo(unknownRaidIds[i])
        if group == subgroup then
            return unknownRaidIds[i]
        end
    end
    
    return nil
end
local function movePlayerToSubgroup(name, subgroup, rosterId, subgroupDistribution)
    if subgroupDistribution[subgroup] >= 5 then -- subgroup is full: switch players
        if rosterId < GetNumRaidMembers() - 1 then
            -- find player of the desired subgroup
            local switcherId = findPlayerInDesiredSubgroup(subgroup, rosterId)
            if switcherId then
                local switcherName, _, switcherGroup = myGetRaidRosterInfo(switcherId)
                if switcherName then
                    local _, _, currentGroup = myGetRaidRosterInfo(rosterId) -- save current group
                    
                    if not movedId[rosterId] and not movedId[switcherId] then
                        --SendChatMessage(rosterId .. " --> " .. switcherId, "RAID")
                        SwapRaidSubgroup(rosterId, switcherId) -- swap players
                        local n,r,g = GetRaidRosterInfo(rosterId)
                        oRAGroupSetup.db.profile.tmpRaidRoster[rosterId].subgroup = switcherGroup -- update raid roster info
                        oRAGroupSetup.db.profile.tmpRaidRoster[switcherId].subgroup = currentGroup -- update raid roster info

                        movedId[rosterId] = true -- do not move the same player twice
                        movedId[switcherId] = true -- do not move the same player twice

                        --oRA:DebugMessage("  " .. name .. "(" .. switcherGroup .. ")" .. "=" .. oRAGroupSetup.db.profile.tmpRaidRoster[rosterId].name .. "(" .. oRAGroupSetup.db.profile.tmpRaidRoster[rosterId].subgroup .. ")/" .. g .. " " .. switcherName .. "(" .. currentGroup .. ")" .. "=" .. oRAGroupSetup.db.profile.tmpRaidRoster[switcherId].name .. "(" .. oRAGroupSetup.db.profile.tmpRaidRoster[switcherId].subgroup .. ")")
                        oRA:DebugMessage("  switched with " .. switcherName .. "(" .. switcherId .. ") updated groups " .. switcherGroup .. "/" .. currentGroup)

                        --printRoster()
                    end
                else
                    oRA:DebugMessage("  can't switch. ID " .. switcherId .. " does not exist")
                end
            else
                oRA:DebugMessage("  can't find anyone to change group with")
            end
        end
    else -- subgroup not full: move player to subgroup
        -- change subgroup distribution
        local _, _, oldSubgroup = myGetRaidRosterInfo(rosterId)
        subgroupDistribution[oldSubgroup] = subgroupDistribution[oldSubgroup] -1
        subgroupDistribution[subgroup] = subgroupDistribution[subgroup] +1
        
        -- move player
        SetRaidSubgroup(rosterId, subgroup)
        
        oRAGroupSetup.db.profile.tmpRaidRoster[rosterId].subgroup = subgroup -- update raid roster info
    end
    
    return subgroupDistribution
end
local function getRaidRoster()
    oRAGroupSetup.db.profile.tmpRaidRoster = {}
    for i=1, GetNumRaidMembers() do
        local _name, _rank, _subgroup, _level, _class, _fileName, _zone, _online, _isDead, _role, _isML = GetRaidRosterInfo(i)
        local entry = {
            name = _name,
            rank = _rank,
            subgroup = _subgroup,
        }
        
        oRAGroupSetup.db.profile.tmpRaidRoster[i] = entry
    end
    
    return oRAGroupSetup.db.profile.tmpRaidRoster
end
local function tryRestore(id)
    local setup = {}
    local subgroupDistribution = {}
    unknownRaidIds = {}
    movedId = {}

    oRAGroupSetup.db.profile.tmpRaidRoster = getRaidRoster() -- save it for later use
    setup = oRAGroupSetup.db.profile.database[id]
    subgroupDistribution = getSubgroupDistribution()
    
	local maxActions = 14
	local actions = 0
    
    for i = 1, GetNumRaidMembers() do
		if actions < maxActions then
			local name, _, subgroup = myGetRaidRosterInfo(i)
			if not setup[name] then -- unknown player
                table.insert(unknownRaidIds, i)
				oRA:Print(string.format(L["no information for player %s available"], name))     
			elseif setup[name] ~= subgroup then -- player in wrong group
				oRA:DebugMessage(i .. ": " .. name .. " " .. subgroup .. " to " .. setup[name])
				subgroupDistribution = movePlayerToSubgroup(name, setup[name], i, subgroupDistribution)
				actions = actions + 1
			else -- player in correct group
				--oRA:DebugMessage(i .. ": " .. name .. " correct g" .. setup[name])
			end
		end
    end
    oRA:DebugMessage(actions .. " actions")

    oRA:ScheduleEvent("oragroupsetuprestore", oRAGroupSetup.checkRestore, 1.0, self, id) -- interval has to be above 0.55, 1.0 for safety
end

local tries = 0
local offset = 0
function oRAGroupSetup:checkRestore(id)
    oRA:DebugMessage("check id " .. id)
    tries = tries + 1
    local setup = oRAGroupSetup.db.profile.database[id]
    
    oRA:DebugMessage("check restore " .. tries)
    if tries > 10 then
        oRA:DebugMessage("over 10 restores. abort")
        tries = 0
		offset = 0
		
		oRA:Print(string.format(L["Could not restore setup |cffff0000%s|r"], id))
		
        return
    end
    
	for i = 1, GetNumRaidMembers() do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if not setup[name] then -- unknown player
            --oRA:Print(string.format(L["no information for player %s available"], name))     
        elseif setup[name] ~= subgroup then -- player in wrong group
            -- something is wrong, do it again
			oRA:DebugMessage("|cffff0000"..name.."|r" .. " is not correct . group " .. subgroup .. " instead of " .. setup[name])
            tryRestore(id)
            return
        else -- player in correct group
            --oRA:DebugMessage(i .. ": " .. name .. " correct g" .. setup[name])
        end
    end
    
    oRA:Print(string.format(L["Group Setup |cff81d11f%s|r restored"], id))
    oRA:DebugMessage("-----------------------------")
    tries = 0
	offset = 0
    oRAGroupSetup.db.profile.tmpRaidRoster = {}
end

function oRAGroupSetup:Restore(id)
    if not (IsRaidLeader() or IsRaidOfficer()) then
        oRA:Print(L["You need to be the raid leader or an assitant to restore a group setup."])
        return
    end
    
    oRA:Print(string.format(L["Restoring setup |cfffca820%s|r"], id))
    tryRestore(id)
end

function oRAGroupSetup:Print()
    for anId, aSetup in pairs(self.db.profile.database) do
        oRA:Print(string.format(L["Setup %s"], anId))
        for key, value in pairs(aSetup) do
            oRA:DebugMessage("  " .. key .. " " .. value) 
        end
    end
end
