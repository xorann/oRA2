assert( oRA, "oRA not found!")

------------------------------
--      Are you local?      --
------------------------------

local L = AceLibrary("AceLocale-2.2"):new("oRAPCoolDown")
local BS = AceLibrary("Babble-Spell-2.2")

----------------------------
--      Localization      --
----------------------------

L:RegisterTranslations("enUS", function() return {
	["cd"] = true,
	["cooldown"] = true,
	["cooldownparticipant"] = true,
	["Options for cooldowns."] = true,
	["gain Soulstone Resurrection"] = true,
	["gains Soulstone Resurrection"] = true,
	["Participant/CoolDown"] = true,
	["You gain Shield Wall"] = true,
} end )

L:RegisterTranslations("ruRU", function() return {
	["Options for cooldowns."] = "Опции для перезарядки.",
	["gain Soulstone Resurrection"] = "gain Soulstone Resurrection",
	["gains Soulstone Resurrection"] = "gains Soulstone Resurrection",
	["Participant/CoolDown"] = "Участник/Перезарядка",
} end )

L:RegisterTranslations("deDE", function() return {
	["gain Soulstone Resurrection"] = "Ihr bekommt 'Seelenstein%-Auferstehung'",
	["gains Soulstone Resurrection"] = "bekommt 'Seelenstein%-Auferstehung'",
	["You gain Shield Wall"] = true, -- translation missing
} end )

L:RegisterTranslations("frFR", function() return {
	--["cd"] = true,
	--["cooldown"] = true,
	--["cooldownparticipant"] = true,
	["Options for cooldowns."] = "Options concernant les temps de recharge.",
	["gain Soulstone Resurrection"] = "gagnez R\195\169surrection de Pierre d'\195\162me",
	["gains Soulstone Resurrection"] = "gagne R\195\169surrection de Pierre d'\195\162me",
	["Participant/CoolDown"] = "Participant/Temps de recharge",
} end )

L:RegisterTranslations("koKR", function() return {

	["Options for cooldowns."] = "재사용대기시간 설정",
	["gain Soulstone Resurrection"] = "영혼석 보관 효과를 얻었습니다",
	["gains Soulstone Resurrection"] = "님이 영혼석 보관 효과를 얻었습니다",
	["Participant/CoolDown"] = "부분/재사용대기시간",
} end )

L:RegisterTranslations("zhCN", function() return {
	["cd"] = "冷却",
	["cooldown"] = "冷却",
	["cooldownparticipant"] = "cooldownparticipant",
	["Options for cooldowns."] = "冷却监视器选项",
	["gain Soulstone Resurrection"] = "获得灵魂石",
	["gains Soulstone Resurrection"] = "获得灵魂石",
	["Participant/CoolDown"] = "Participant/CoolDown",
} end )

L:RegisterTranslations("zhTW", function() return {
	["cd"] = "冷卻",
	["cooldown"] = "冷卻",
	["cooldownparticipant"] = "cooldownparticipant",
	["Options for cooldowns."] = "冷卻監視器選項",
	["gain Soulstone Resurrection"] = "獲得靈魂石",
	["gains Soulstone Resurrection"] = "獲得靈魂石效果",
	["Participant/CoolDown"] = "隊員/冷卻",
} end )
----------------------------------
--      Module Declaration      --
----------------------------------

oRAPCoolDown = oRA:NewModule(L["cooldownparticipant"], "AceHook-2.1")
oRAPCoolDown.defaults = {
}
oRAPCoolDown.participant = true
oRAPCoolDown.name = L["Participant/CoolDown"]
-- oRAPCoolDown.consoleCmd = L["cd"]
-- oRAPCoolDown.consoleOptions = {
-- 	type = "group",
-- 	desc = L["Options for cooldowns."],
-- 	args = {
-- 	}
-- }


------------------------------
--      Initialization      --
------------------------------

function oRAPCoolDown:OnEnable()

	self.spell = nil
	self.sscasting = nil
	self.rescasting = nil
	self.innervate = nil

	local _, c = UnitClass("player")
	if c == "DRUID" or c == "WARLOCK" or c == "PALADIN" then
		self:RegisterEvent("SPELLCAST_START")
		self:RegisterEvent("SPELLCAST_FAILED", "SpellFailed")
		self:RegisterEvent("SPELLCAST_INTERRUPTED", "SpellFailed")
		self:RegisterEvent("SPELLCAST_STOP")
		if c == "WARLOCK" then
			self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS", "CheckSoulstone")
			self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "CheckSoulstone")
			self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS", "CheckSoulstone")
		end
	elseif c == "SHAMAN" then
		self:Hook("UseSoulstone", true)
	elseif c == "WARRIOR" then
		self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS", "CheckShieldWall")
		self:RegisterEvent("SPELLCAST_STOP")
	end
end

function oRAPCoolDown:OnDisable()
	self:UnregisterAllEvents()
	self:UnhookAll()
end


-------------------------------
--      Event Handlers       --
-------------------------------

function oRAPCoolDown:SPELLCAST_START( arg1 )
	self.spell = arg1
	if self.spell == BS["Soulstone Resurrection"] then
		self.sscasting = true
	elseif self.spell == BS["Rebirth"] then
		self.rescasting = true
	elseif self.spell == BS["Divine Intervention"] then
		self.rescasting = true
	end
end

function oRAPCoolDown:SPELLCAST_STOP( arg1 )
	if self.spell == BS["Rebirth"] then
		self.rescasting = nil
		self.spell = nil
		self:SendMessage("CD 1 30")
	elseif self.spell == BS["Divine Intervention"] then
		self.rescasting = nil
		self.spell = nil
		self:SendMessage("CD 4 60", true) -- only oRA2 clients will receive this cooldown I just numbered on.
	end
	local _, c = UnitClass("player")	
	if c == "DRUID" and not self.innervate then
		self:ScheduleEvent( "oRAPCoolDown_InnervateCheck", 
		function() 
			local i = 1;
			local spellName,start,duration,timeleft
			while true do 
				spellName = GetSpellName(i, BOOKTYPE_SPELL)
				if spellName then
					if spellName == BS["Innervate"] then 
						start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL)
						timeleft = duration - (GetTime() - start)
						if timeleft > 300 and not self.innervate then
							self:SendMessage("CD 5 "..timeleft)
							self.innervate = true;
							self:ScheduleEvent( "oRAPCoolDown_ResetInnervate", function() self.innervate = nil end, timeleft)
						end
						break
					end
				else
					break
				end
				i = i + 1
			end
		end, 1.5)
	end
	
	if (c == "WARRIOR" or c == "DRUID") and not self.aoetaunt then
		self:ScheduleEvent("oRAPCoolDown_AOETauntCheck", 
			function() 
				local i = 1
				local spellName, start, duration, timeleft
				while true do 
					spellName = GetSpellName(i, BOOKTYPE_SPELL)
					if spellName then
						if spellName == BS["Challenging Shout"] or spellName == BS["Challenging Roar"] then 
							start, duration = GetSpellCooldown(i, BOOKTYPE_SPELL);
							timeleft = duration - (GetTime() - start)
							if timeleft > 500 and not self.aoetaunt then
								self:SendMessage("CD 7 " .. timeleft)
								self.aoetaunt = true
								self:ScheduleEvent("oRAPCoolDown_ResetAOETaunt", 
									function() 
										self.aoetaunt = nil 
									end, 
									timeleft
								)
							end
							break
						end
					else
						break
					end
					i = i + 1
				end
			end, 
			1.5
		)
	end
end

function oRAPCoolDown:SpellFailed()
	if self.spell == BS["Rebirth"] then self.rescasting = nil end
	if self.spell == BS["Soulstone Resurrection"] then self.sscasting = nil end
	if self.spell == BS["Divine Intervention"] then self.rescasting = nil end
end

function oRAPCoolDown:CheckSoulstone( arg1 )
	if self.sscasting then
		if string.find(arg1, L["gains Soulstone Resurrection"]) or string.find( arg1, L["gain Soulstone Resurrection"]) then
			self.spell = nil
			self.sscasting = nil
			self:SendMessage("CD 3 30")
		end
	end
end

function oRAPCoolDown:CheckShieldWall(arg1)
	if string.find(arg1, L["You gain Shield Wall"]) then
		self:SendMessage("CD 6 30")
	end
end


---------------
--   Hooks   --
---------------

function oRAPCoolDown:UseSoulstone()
	local text = HasSoulstone()
	if text and text == BS["Reincarnation"] then
		local cooldown = 60
		for tab = 1, GetNumTalentTabs(), 1 do
			for talent = 1, GetNumTalents(tab), 1 do
				local name, _, _, _, rank = GetTalentInfo(tab, talent)
				if name == BS["Improved Reincarnation"] then
					cooldown = cooldown - (rank*10)
					break
				end
			end
			if cooldown then break end
			self:SendMessage("CD 2 " .. cooldown )
		end
	end
	self.hooks["UseSoulstone"]()
end
