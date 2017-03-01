
assert( oRA, "oRA not found!")


------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("oRAGroupSwap")


----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["Group Swap"] = true,
    ["groupswap"] = true, -- console
    ["Options for the group swap plugin."] = true,
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
            
    ["GroupSwap: Please provide an ID"] = true,
    ["Group Setup saved with id: "] = true,
    ["no information for player %s available"] = true,
    ["Group Setup %s restored"] = true,
    ["Setup %s"] = true,
    ["You are not the raid leader or a raid assistant which will be necessary to restore a setup."] = true,
    ["You need to be the raid leader or an assitant to restore a group setup."] = true,
	["Could not restore setup %s"] = true,
} end)

L:RegisterTranslations("deDE", function() return {
    ["Group Swap"] = "Gruppenwechsel",
    ["groupswap"] = "gruppenwechsel", -- console
    ["Options for the group swap plugin."] = "Optionen für das Gruppenwechsel Plugin",
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
            
    ["GroupSwap: Please provide an ID"] = "Gruppenwechsel: Bitte gib eine ID an.",
    ["Group Setup saved with id: "] = "Gruppenaufstellung gespeichert mit der id: ",
    ["no information for player %s available"] = "keine Informationen für den Spieler %s verfügbar",
    ["Group Setup %s restored"] = "Gruppenaufstellung %s wiederhergestellt",
    ["Setup %s"] = "Aufstellung %s",
    ["You are not the raid leader or a raid assistant which will be necessary to restore a setup."] = "Du bist nicht der Schlachtzugsleiter oder ein Assistent, was notwendig sein wird um eine Aufstellung wiederherstellen zu können.",
    ["You need to be the raid leader or an assitant to restore a group setup."] = "Du musst der Schlachtzugsleiter oder ein Assistent sein, um eine Gruppenaufstellung wiederherstellen zu können.",
	["Could not restore setup %s"] = "Setup %s konnte nicht wiederhergestellt werden.",
} end)


----------------------------------
--      Module Declaration      --
----------------------------------

oRAGroupSwap = oRA:NewModule("Group Swap")
oRAGroupSwap.revision = 20008
oRAGroupSwap.defaultDB = {
	database = {},
    idList = {},
    tmpRaidRoster = {}, -- keep our own raid roster information since GetRaidRosterInfo is buffered
}


oRAGroupSwap.consoleCmd = L["groupswap"]
oRAGroupSwap.consoleOptions = {
	type = "group",
	name = L["Group Swap"],
	desc = L["Options for the group swap plugin."],
	args   = {
		[L["save"]] = {
			type = "text",
			name = L["Save"],
			desc = L["Save current group setup."],
            usage = L["<id>"],
            get = false,
            set = function(id) oRAGroupSwap:Save(id) end,
            order = 1
		},
		[L["restore"]] = {
			type = "text",
			name = L["Restore"],
			desc = L["Restore saved group setup."],
			get = false,
            validate = {},
			set = function(id)
				oRAGroupSwap:Restore(id)
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
				oRAGroupSwap:Clear(id)
			end,
            order = 3
		}
	},
}


------------------------------
--      Initialization      --
------------------------------
function oRAGroupSwap:OnEnable()
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
function oRAGroupSwap:Clear(id)
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

function oRAGroupSwap:Save(id)
    if not id or id == "" then
        oRA:Print(L["GroupSwap: Please provide an ID"])
    --[[elseif self.db.profile.database[id] then
        oRA:Print("GroupSwap: ID already exists")]]
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
--local raidRoster = {} -- keep our own raid roster information since GetRaidRosterInfo is buffered

local function myGetRaidRosterInfo(index)
    if not index then
        return nil
    else
        if oRAGroupSwap.db.profile.tmpRaidRoster[index] then
            return oRAGroupSwap.db.profile.tmpRaidRoster[index].name, 
                oRAGroupSwap.db.profile.tmpRaidRoster[index].rank,
                oRAGroupSwap.db.profile.tmpRaidRoster[index].subgroup
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
        table.insert(tmp[oRAGroupSwap.db.profile.tmpRaidRoster[i].subgroup], oRAGroupSwap.db.profile.tmpRaidRoster[i].name)
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
                    SwapRaidSubgroup(rosterId, switcherId) -- swap players
                    local n,r,g = GetRaidRosterInfo(rosterId)
                    oRAGroupSwap.db.profile.tmpRaidRoster[rosterId].subgroup = switcherGroup -- update raid roster info
                    oRAGroupSwap.db.profile.tmpRaidRoster[switcherId].subgroup = currentGroup -- update raid roster info
                    
                    --oRA:DebugMessage("  " .. name .. "(" .. switcherGroup .. ")" .. "=" .. oRAGroupSwap.db.profile.tmpRaidRoster[rosterId].name .. "(" .. oRAGroupSwap.db.profile.tmpRaidRoster[rosterId].subgroup .. ")/" .. g .. " " .. switcherName .. "(" .. currentGroup .. ")" .. "=" .. oRAGroupSwap.db.profile.tmpRaidRoster[switcherId].name .. "(" .. oRAGroupSwap.db.profile.tmpRaidRoster[switcherId].subgroup .. ")")
                    oRA:DebugMessage("  switched with " .. switcherName .. "(" .. switcherId .. ") updated groups " .. switcherGroup .. "/" .. currentGroup)
                    
                    --printRoster()
                    
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
        
        oRAGroupSwap.db.profile.tmpRaidRoster[rosterId].subgroup = subgroup -- update raid roster info
    end
    
    return subgroupDistribution
end
local function getRaidRoster()
    oRAGroupSwap.db.profile.tmpRaidRoster = {}
    for i=1, GetNumRaidMembers() do
        local _name, _rank, _subgroup, _level, _class, _fileName, _zone, _online, _isDead, _role, _isML = GetRaidRosterInfo(i)
        local entry = {
            name = _name,
            rank = _rank,
            subgroup = _subgroup,
        }
        --table.insert(raidRoster, entry) 
        oRAGroupSwap.db.profile.tmpRaidRoster[i] = entry
    end
    
    return oRAGroupSwap.db.profile.tmpRaidRoster
end
local tries = 0
local offset = 0
function oRAGroupSwap:checkRestore(id)
    oRA:DebugMessage("check id " .. id)
    tries = tries + 1
    local setup = oRAGroupSwap.db.profile.database[id]
    
    oRA:DebugMessage("check restore " .. tries)
    if tries > 10 then
        oRA:DebugMessage("over 10 restores. abort")
        tries = 0
		offset = 0
		
		oRA:Print(string.format(L["Could not restore setup %s"], id))
		
        return
    end
    
	for i = 1, GetNumRaidMembers() do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if not setup[name] then -- unknown player
            --oRA:Print(string.format(L["no information for player %s available"], name))     
        elseif setup[name] ~= subgroup then -- player in wrong group
            -- something is wrong, do it again
			oRA:DebugMessage("|cffff0000"..name.."|r" .. " is not correct . group " .. subgroup .. " instead of " .. setup[name])
            oRAGroupSwap:Restore(id)
            return
        else -- player in correct group
            --oRA:DebugMessage(i .. ": " .. name .. " correct g" .. setup[name])
        end
    end
    
    oRA:Print(string.format(L["Group Setup %s restored"], id))
    oRA:DebugMessage("-----------------------------")
    tries = 0
	offset = 0
end

function oRAGroupSwap:Restore(id)
    if not (IsRaidLeader() or IsRaidOfficer()) then
        oRA:Print(L["You need to be the raid leader or an assitant to restore a group setup."])
        return
    end
    
    local setup = {}
    local subgroupDistribution = {}
    --local offset = 0
    --local raidRoster = {}
    
    --if oRAGroupSwapLocals.inProgress then
    --    setup = oRAGroupSwapLocals.setup
    --    subgroupDistribution = oRAGroupSwapLocals.subgroupDistribution
        --offset = oRAGroupSwapLocals.offset
    --    id = oRAGroupSwapLocals.id
    --else
        oRAGroupSwap.db.profile.tmpRaidRoster = getRaidRoster() -- save it for later use
        --oRAGroupSwap.db.profile.raidRoster = raidRoster
        setup = oRAGroupSwap.db.profile.database[id]
        subgroupDistribution = getSubgroupDistribution()
        --offset = 0
    --end 

    --printRoster()
    
    --oRA:Print("offset " .. offset)
    
    --for k,v in pairs(subgroupDistribution) do
    --    oRA:DebugMessage("subgroup " .. k .. ": " .. v) 
    --end
    
    --local max = offset + 20
    --if max >= GetNumRaidMembers() then
    --    max = GetNumRaidMembers()
    --end
	local maxActions = 40
	local actions = 0
    --for i = 1 + offset, max do
    for i = 1, GetNumRaidMembers() do
		if actions < maxActions then
			local name, _, subgroup = myGetRaidRosterInfo(i)
			if not setup[name] then -- unknown player
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
    
	--offset = offset + 20
    oRA:ScheduleEvent("oragroupswaprestore", oRAGroupSwap.checkRestore, 1.0, self, id) -- interval has to be above 0.55, 1.0 for safety
    
    --[[oRAGroupSwapLocals.setup = setup
    oRAGroupSwapLocals.subgroupDistribution = subgroupDistribution
    oRAGroupSwapLocals.offset = offset + 5
    oRAGroupSwapLocals.id = id
    oRAGroupSwapLocals.raidRoster = raidRoster
    
    if offset + 5 >= GetNumRaidMembers() then
        oRAGroupSwapLocals.inProgress = false
        oRA:Print(string.format(L["Group Setup %s restored"], id))
        oRA:DebugMessage("-----------------------------")
    else
        oRAGroupSwapLocals.inProgress = true
        oRA:ScheduleEvent("oragroupswaprestore", oRAGroupSwap.Restore, 0.1, id)
    end]]
end

function oRAGroupSwap:Print()
    for anId, aSetup in pairs(self.db.profile.database) do
        oRA:Print(string.format(L["Setup %s"], anId))
        for key, value in pairs(aSetup) do
            oRA:DebugMessage("  " .. key .. " " .. value) 
        end
    end
end
