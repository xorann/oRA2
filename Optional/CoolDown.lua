assert( oRA, "oRA not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("oRAOCoolDown")

local roster = AceLibrary("RosterLib-2.0")
local surface = AceLibrary("Surface-1.0")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["CoolDown Monitor"] = true,
	["cooldown"] = true,
	["cooldownoptional"] = true,
	["Optional/CoolDown"] = true,
	["Options for CoolDown."] = true,
	["Toggle"] = true,
	["toggle"] = true,
	["Toggle the CoolDown Monitor."] = true,
	
	["scale"] = true,
	["Bar scale"] = true,
	["Set the bar scale."] = true,
	
	["lock"] = true,
	["Lock"] = true,
	["Lock the CoolDown Monitor."] = true,
	
	["rebirth"] = true,
	["Rebirth"] = true,
	["Show Rebirth."] = true,
	["reincarnation"] = true,
	["Reincarnation"] = true,
	["Show Reincarnation."] = true,
	["soulstone"] = true,
	["Soulstone"] = true,
	["Show Soulstone."] = true,
	["divineintervention"] = true,
	["Divine Intervention"] = true,
	["Show Divine Intervention."] = true,

	["innervate"] = true,
	["Innervate"] = true,
	["Show Innervate."] = true,
	["shieldwall"] = true,
	["Shield Wall"] = true,
	["Show Shield Wall."] = true,
	["aoetaunt"] = true,
	["Aoe Taunt"] = true,
	["Show Aoe Taunt."] = true,
} end )

L:RegisterTranslations("deDE", function() return {
	["CoolDown Monitor"] = "Cooldown Anzeige",
	["cooldown"] = "cooldown",
	["cooldownoptional"] = "CooldownOptional",
	["Optional/CoolDown"] = "Optional/Cooldown",
	["Options for CoolDown."] = "Optionen für Cooldowns",
	["Toggle"] = "Umschalten",
	["toggle"] = "umschalten",
	["Toggle the CoolDown Monitor."] = "Ein-/Ausblenden der Cooldown Anzeige",
	
	["rebirth"] = "wiedergeburt",
	["Rebirth"] = "Wiedergeburt",
	["Show Rebirth."] = "Zeige Wiedergeburt",
	["reincarnation"] = "reinkarnation",
	["Reincarnation"] = "Reinkarnation",
	["Show Reincarnation."] = "Zeige Reinkarnation",
	["soulstone"] = "seelenstein",
	["Soulstone"] = "Seelenstein",
	["Show Soulstone."] = "Zeige Seelenstein",
	["divineintervention"] = "vorausahnendereingriff",
	["Divine Intervention"] = "Vorausahnender Eingriff",
	["Show Divine Intervention."] = "Zeige vorausahnender Eingriff",

	["innervate"] = "anregen",
	["Innervate"] = "Anregen",
	["Show Innervate."] = "Zeige Anregen",
	["shieldwall"] = "schildwall",
	["Shield Wall"] = "Schildwall",
	["Show Shield Wall."] = "Zeige Schildwall",
	["aoetaunt"] = "massenspott",
	["Aoe Taunt"] = "Massenspott",
	["Show Aoe Taunt."] = "Zeige Massenspott",
} end )

L:RegisterTranslations("ruRU", function() return {
	["CoolDown Monitor"] = "Монитор перезарядки",
	["Optional/CoolDown"] = "Дополнительно/Перезарядка",
	["Options for CoolDown."] = "Опции для перезарядки.",
	["Toggle"] = "Вкл./Выкл.",
	["Toggle the CoolDown Monitor."] = "Вкл./Выкл. монитор перезарядки.",
} end )

L:RegisterTranslations("koKR", function() return {
	["CoolDown Monitor"] = "재사용대기시간 모니터",
	["Optional/CoolDown"] = "부가/재사용대기시간",
	["Options for CoolDown."] = "재사용대기시간에 관한 설정.",
	["Toggle"] = "토글",
	["Toggle the CoolDown Monitor."] = "재사용대기시간 모니터 토글",
} end )

L:RegisterTranslations("zhCN", function() return {
	["CoolDown Monitor"] = "冷却监视器",
	["cooldown"] = "冷却",
	["cooldownoptional"] = "cooldownoptional",
	["Optional/CoolDown"] = "Optional/CoolDown",
	["Options for CoolDown."] = "冷却监视器的选项",
	["Toggle"] = "显示",
	["toggle"] = "显示",
	["Toggle the CoolDown Monitor."] = "显示冷却监视器",
} end )

L:RegisterTranslations("zhTW", function() return {
	["CoolDown Monitor"] = "冷卻監視器",
	["cooldown"] = "冷卻",
	["cooldownoptional"] = "cooldownoptional",
	["Optional/CoolDown"] = "可選/冷卻",
	["Options for CoolDown."] = "冷卻監視器的選項",
	["Toggle"] = "顯示",
	["toggle"] = "顯示",
	["Toggle the CoolDown Monitor."] = "顯示冷卻監視器",
} end )

L:RegisterTranslations("frFR", function() return {
	["CoolDown Monitor"] = "Surveillance des \"cooldowns\"",
	--["cooldown"] = true,
	--["cooldownoptional"] = true,
	["Optional/CoolDown"] = "Optionnel/Temps de recharge",
	["Options for CoolDown."] = "Options concernant les temps de recharge.",
	["Toggle"] = "Afficher",
	--["toggle"] = true,
	["Toggle the CoolDown Monitor."] = "Affiche ou non la surveillance des temps de recharge.",
} end )

----------------------------------
--      Module Declaration      --
----------------------------------

oRAOCoolDown = oRA:NewModule(L["cooldownoptional"], "CandyBar-2.0")
oRAOCoolDown.defaults = {
	hidden = false,
	locked = false,
	scale = 1.0,
	cooldowns = {},
	
	rebirth = true,
	reincarnation = true,
	soulstone = true,
	divineintervention = true,
	innervate = true,
	shieldwall = true,
	aoetaunt = true,
}
oRAOCoolDown.optional = true
oRAOCoolDown.name = L["Optional/CoolDown"]
oRAOCoolDown.consoleCmd = L["cooldown"]
oRAOCoolDown.consoleOptions = {
	type = "group",
	desc = L["Options for CoolDown."],
	name = L["CoolDown Monitor"],
	args = {
		[L["toggle"]] = {
			type = "toggle", name = L["Toggle"],
			desc = L["Toggle the CoolDown Monitor."],
			order = 1,
			get = function() return not oRAOCoolDown.db.profile.hidden end,
			set = function(v)
					oRAOCoolDown:ToggleView()
			end,
		},
		[L["lock"]] = {
			type = "toggle", name = L["Lock"],
			desc = L["Lock the CoolDown Monitor."],
			order = 2,
			get = function() return oRAOCoolDown.db.profile.locked end,
			set = function(v)
					oRAOCoolDown:ToggleLock()
			end,
		},
		[L["scale"]] = {
			type = "range",
			name = L["Bar scale"],
			desc = L["Set the bar scale."],
			order = 3,
			min = 0.2,
			max = 2.0,
			step = 0.1,
			get = function() return oRAOCoolDown.db.profile.scale end,
			set = function(v) 
					oRAOCoolDown.db.profile.scale = v 
					oRAOCoolDown:StopAllCoolDowns()
					oRAOCoolDown:StartAllCoolDowns()
				end,
		},
		spacer = {
			type = "header",
			name = "  ",
			order = 4,
		},
		[L["rebirth"]] = {
			type = "toggle", name = L["Rebirth"],
			desc = L["Show Rebirth."],
			order = 11,
			get = function() return oRAOCoolDown.db.profile.rebirth end,
			set = function(v) oRAOCoolDown.db.profile.rebirth = v end,
		},
		[L["reincarnation"]] = {
			type = "toggle", name = L["Reincarnation"],
			desc = L["Show Reincarnation."],
			order = 12,
			get = function() return oRAOCoolDown.db.profile.reincarnation end,
			set = function(v) oRAOCoolDown.db.profile.reincarnation = v end,
		},
		[L["soulstone"]] = {
			type = "toggle", name = L["Soulstone"],
			desc = L["Show Soulstone."],
			order = 13,
			get = function() return oRAOCoolDown.db.profile.soulstone end,
			set = function(v) oRAOCoolDown.db.profile.soulstone = v end,
		},
		[L["divineintervention"]] = {
			type = "toggle", name = L["Divine Intervention"],
			desc = L["Show Divine Intervention."],
			order = 14,
			get = function() return oRAOCoolDown.db.profile.divineintervention end,
			set = function(v) oRAOCoolDown.db.profile.divineintervention = v end,
		},
		[L["innervate"]] = {
			type = "toggle", name = L["Innervate"],
			desc = L["Show Innervate."],
			order = 21,
			get = function() return oRAOCoolDown.db.profile.innervate end,
			set = function(v) oRAOCoolDown.db.profile.innervate = v end,
		},
		[L["shieldwall"]] = {
			type = "toggle", name = L["Shield Wall"],
			desc = L["Show Shield Wall."],
			order = 22,
			get = function() return oRAOCoolDown.db.profile.shieldwall end,
			set = function(v) oRAOCoolDown.db.profile.shieldwall = v end,
		},
		[L["aoetaunt"]] = {
			type = "toggle", name = L["Aoe Taunt"],
			desc = L["Show Aoe Taunt."],
			order = 23,
			get = function() return oRAOCoolDown.db.profile.aoetaunt end,
			set = function(v) oRAOCoolDown.db.profile.aoetaunt = v end,
		},
	}
}


------------------------------
--      Initialization      --
------------------------------
function oRAOCoolDown:OnEnable()
	roster:Enable()
	if not self.db.profile.cooldowns then self.db.profile.cooldowns = {} end
	self.enabled = nil

	self:RegisterEvent("oRA_LeftRaid")	
	self:RegisterEvent("oRA_JoinedRaid")
	self:RegisterEvent("oRA_BarTexture")
end

function oRAOCoolDown:OnDisable()
	self:UnregisterAllEvents()
	self:DisableMonitor()
end


------------------------
--   Event Handlers   --
------------------------
function oRAOCoolDown:oRA_JoinedRaid()
	if not self.enabled then
		self.enabled = true
		if not self.db.profile.hidden then
			self:SetupFrames()
			self.cdframe:Show()
			self:StartAllCoolDowns()
		end
		self:RegisterCheck("CD", "oRA_CoolDown")
	end
end

function oRAOCoolDown:oRA_LeftRaid()
	self:DisableMonitor()
end

function oRAOCoolDown:oRA_CoolDown(msg, author)
	msg = self:CleanMessage(msg)
	local _,_,what,length = string.find( msg, "^CD (%d+) (%d+)")
	local _,_,_,_,deci = string.find( msg, "^CD (%d+) (%d+).(%d+)");
	if author and what and time then
		if not self.db.profile.cooldowns then self.db.profile.cooldowns = {} end
		if (self.db.profile.rebirth and what == "1") or (self.db.profile.reincarnation and what == "2") or (self.db.profile.soulstone and what == "3") or (self.db.profile.divineintervention and what == "4") or (self.db.profile.innervate and what == "5") or (self.db.profile.shieldwall and what == "6") or (self.db.profile.aoetaunt and what == "7") then
			if what == "5" then
				author = "innervate_"..author
				if deci then
					self.db.profile.cooldowns[author] = time() + tonumber(length.."."..deci)
					self:StartCoolDown( author, tonumber(length.."."..deci))
				else
					self.db.profile.cooldowns[author] = time() + tonumber(length)
					self:StartCoolDown( author, tonumber(length))
				end
			elseif what == "7" then
				author = "aoetaunt_"..author
				if deci then
					self.db.profile.cooldowns[author] = time() + tonumber(length.."."..deci)
					self:StartCoolDown( author, tonumber(length.."."..deci))
				else
					self.db.profile.cooldowns[author] = time() + tonumber(length)
					self:StartCoolDown( author, tonumber(length))
				end
			else
				self.db.profile.cooldowns[author] = time() + tonumber(length)*60
				self:StartCoolDown( author, tonumber(length)*60)
			end
		end
	end
end

function oRAOCoolDown:oRA_BarTexture( texture )
	for key, val in pairs( self.db.profile.cooldowns) do
		self:SetCandyBarTexture( "oRAOCoolDown "..key, surface:Fetch(texture))
	end
end

-------------------------
--  Utility Functions  --
-------------------------

function oRAOCoolDown:DisableMonitor()
	self.enabled = nil
	if self.cdframe and self.cdframe:IsVisible() then self.cdframe:Hide() end
	self:StopAllCoolDowns()
	self:UnregisterCheck("CD")
end

function oRAOCoolDown:SavePosition()
	local f = self.cdframe
	local x,y = f:GetLeft(), f:GetTop()
	local s = f:GetEffectiveScale()
		
	x,y = x*s,y*s

	self.db.profile.posx = x
	self.db.profile.posy = y		
end

function oRAOCoolDown:RestorePosition()
	local x = self.db.profile.posx
	local y = self.db.profile.posy
		
	if not x or not y then return end
				
	local f = self.cdframe
	local s = f:GetEffectiveScale()

	x,y = x/s,y/s

	f:ClearAllPoints()
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

function oRAOCoolDown:SetupFrames()
	if not self.cdframe then
		local cdframe = CreateFrame("Frame", "oRACoolDownFrame", UIParent)
		
		if self.db.profile.locked then
			cdframe:EnableMouse(false)
			cdframe:SetMovable(false)
		else
			cdframe:EnableMouse(true)
			cdframe:SetMovable(true)		
		end
		
		cdframe:RegisterForDrag("LeftButton")
		cdframe:SetScript("OnDragStart", function() self["cdframe"]:StartMoving() end)
		cdframe:SetScript("OnDragStop", function() self["cdframe"]:StopMovingOrSizing() self:SavePosition() end)
		cdframe:SetWidth(175)
		cdframe:SetHeight(50)
		--cdframe:SetBackdrop({
		--	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
		--	edgeFile = "Interface\Tooltips\UI-Tooltip-Border", edgeSize = 16,
		--	insets = {left = 0, right = 0, top = 0, bottom = 0},
		--})
		--cdframe:SetBackdropColor(0,0,0,0.5)
		--cdframe:SetBackdropBorderColor(1,1,1,.5)
		cdframe:Hide()
		cdframe:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

		local title = cdframe:CreateFontString(nil, "ARTWORK")
		title:SetFontObject(GameFontNormalSmall)
		title:SetText(L["CoolDown Monitor"])
		title:SetJustifyH("CENTER")
		title:SetWidth(160)
		title:SetHeight(12)
		if self.db.profile.locked then
			title:Hide()
		else
			title:Show()
		end
		title:ClearAllPoints()
		title:SetPoint("TOP", cdframe, "TOP", 0, -5)

		local text = cdframe:CreateFontString(nil, "ARTWORK")
		text:SetFontObject(GameFontHighlightSmall)
		text:SetJustifyH("CENTER")
		text:SetJustifyV("TOP")
		text:SetWidth(160)
		--text:SetHeight(25)
		text:Show()
		text:ClearAllPoints()
		text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)

		self.cdframe = cdframe
		self.title = title
		self.text = text
		
		self:RestorePosition()
	end
end


function oRAOCoolDown:StartAllCoolDowns()
	local t = time()
	for key, val in pairs(self.db.profile.cooldowns) do
		if t >= val then
			self.db.profile.cooldowns[key] = nil
			self:StopCoolDown( key )
		else
			self:StartCoolDown( key, val - t )
		end
	end
end

function oRAOCoolDown:StopAllCoolDowns()
	local t = time()
	for key, val in pairs(self.db.profile.cooldowns) do
		if t >= val then self.db.profile.cooldowns[key] = nil end
		self:StopCoolDown( key )
	end
end

function oRAOCoolDown:StartCoolDown( player, time )
	if not self.enabled or self.db.profile.hidden then return end
	local innervate, aoetaunt = nil, nil
	local player2 = player
	if string.find(player, "^innervate_") then
		player = string.sub(player,11)
		innervate = true
	elseif string.find(player, "^aoetaunt_") then
		player = string.sub(player,10)
		aoetaunt = true
	end
	local unit = roster:GetUnitObjectFromName( player )
	if not unit then return end
	self:RegisterCandyBarGroup("oRAOCoolDownGroup")
	self:SetCandyBarGroupPoint("oRAOCoolDownGroup", "TOP", self.text, "BOTTOM", 0, -5 )
	if innervate then
		self:RegisterCandyBar( "oRAOCoolDown "..player2, time, player, nil, "Mage")
	elseif aoetaunt then
		self:RegisterCandyBar( "oRAOCoolDown "..player2, time, player, nil, "Red")
	else
		self:RegisterCandyBar( "oRAOCoolDown "..player2, time, player, nil, unit.class)
	end
	self:RegisterCandyBarWithGroup( "oRAOCoolDown "..player2, "oRAOCoolDownGroup")
	self:SetCandyBarWidth( "oRAOCoolDown "..player2, 150)
	self:SetCandyBarTexture( "oRAOCoolDown "..player2, surface:Fetch(self.core.db.profile.bartexture))
	self:StartCandyBar( "oRAOCoolDown "..player2, true)
	
	local scale = self.db.profile.scale or 1
	self:SetCandyBarScale("oRAOCoolDown " .. player2, scale)
end

function oRAOCoolDown:StopCoolDown( player )
	self:UnregisterCandyBar( "oRAOCoolDown "..player )
end


-------------------------
--  Command Handlers   --
-------------------------
function oRAOCoolDown:ToggleView()
	self.db.profile.hidden = not self.db.profile.hidden
	if self.cdframe and self.cdframe:IsVisible() then
		self:StopAllCoolDowns()
		self.cdframe:Hide()
	end
	if self.enabled and not self.db.profile.hidden then
		if not self.cdframe then self:SetupFrames() end
		self.cdframe:Show()
		self:StartAllCoolDowns()
	end
end

function oRAOCoolDown:ToggleLock()
	self.db.profile.locked = not self.db.profile.locked
	
	if not self.title then 
		self:SetupFrames() 
	end
		
	if self.db.profile.locked then
		self.title:Hide()		
		self.cdframe:EnableMouse(false)
		self.cdframe:SetMovable(false)
	else		
		self.title:Show()		
		self.cdframe:EnableMouse(true)
		self.cdframe:SetMovable(true)
	end
end
