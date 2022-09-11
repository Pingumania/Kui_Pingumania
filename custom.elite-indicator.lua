local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_EliteIndicator", 101)
if not mod then return end

local ELITE_INDICATOR = true

local function UpdateLevelColor(f)
	local in_instance, instance_type = IsInInstance()
	local instanced_pvp = in_instance and (instance_type == "arena" or instance_type == "pvp")
	local level = instanced_pvp and UnitLevel(f.unit) or UnitEffectiveLevel(f.unit)
	local d = GetQuestDifficultyColor(level <= 0 and 999 or level)
	f.LevelText:SetTextColor(d.r, d.g, d.b)
end

local function UpdateLevelPos(f, x)
	f.LevelText:ClearAllPoints()

	if f.state.no_name then
		f.LevelText:SetPoint("LEFT", x, 0)
	else
		f.LevelText:SetPoint("BOTTOMLEFT", x, core.profile.bot_vertical_offset)
	end
end

local function UpdateLevelText(f)
	if f.IN_NAMEONLY then return end

	local c = UnitClassification(f.unit)

	if not core.profile.level_text or f.state.minus or f.state.personal then
		if c == "elite" then
			f.LevelText:SetText("E")
		elseif c == "rareelite" then
			f.LevelText:SetText("RE")
		elseif c == "rare" then
			f.LevelText:SetText("R")
		else
			f.LevelText:Hide()
			return
		end
		UpdateLevelPos(f, 3)
	else
		UpdateLevelPos(f, 2)
	end
	UpdateLevelColor(f)
	f.LevelText:Show()
end

function mod:Show(f)
	if f.StateIcon then
		f.StateIcon:SetPoint("LEFT", f.HealthBar, "LEFT", 0, 0)
	end

	if ELITE_INDICATOR then
		f.UpdateLevelText = UpdateLevelText
	end
end

function mod:OnEnable()
	self:RegisterMessage("Show")
end
