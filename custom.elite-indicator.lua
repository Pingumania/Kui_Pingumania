local _, ns = ...
local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("Custom_EliteIndicator", 101)
if not mod then return end

local instanced_pvp
local ELITE_INDICATOR = true
local MAX_LEVEL = ns.Mainline and GetMaxLevelForPlayerExpansion() or ns.BCC and 70 or ns.Classic and 60

local function UpdateLevel(f)
	f = f.parent

	if kui.CLASSIC then
		f.state.level = UnitLevel(f.unit) or 0
	else
		f.state.level = instanced_pvp and UnitLevel(f.unit) or UnitEffectiveLevel(f.unit) or 0
	end

	if f.elements.LevelText then
		local l, cl, d = kui.UnitLevel(f.unit, nil, instanced_pvp)
		if l == "??" then
			l = "B"
		end
		cl = strupper(gsub(cl, "+", "E"))
		if type(l) == "number" and l >= MAX_LEVEL then
			f.LevelText:SetText(cl)
		else
			f.LevelText:SetText(l..cl)
		end
		f.LevelText:SetTextColor(d.r, d.g, d.b)
	end
end

local function UpdateStateIcon(f)
	if not core.profile.state_icons or f.IN_NAMEONLY or (f.elements.LevelText and f.LevelText:IsShown()) then
		f.StateIcon:Hide()
		return
	end

	if f.state.classification == "elite" then
		f.StateIcon:SetAtlas("nameplates-icon-elite-gold")
		f.StateIcon:SetSize(20, 20)
		f.StateIcon:SetVertexColor(1, 1, 1)
		f.StateIcon:Show()
	elseif f.state.classification == "rareelite" then
		f.StateIcon:SetAtlas("vignettekill")
		f.StateIcon:SetSize(18, 18)
		f.StateIcon:SetVertexColor(1, 1, 1)
		f.StateIcon:Show()
	elseif f.state.classification == "rare" then
		f.StateIcon:SetAtlas("vignettekill")
		f.StateIcon:SetSize(18, 18)
		f.StateIcon:SetVertexColor(1, 1, 1)
		f.StateIcon:Show()
	else
		f.StateIcon:Hide()
	end
end

function mod:Show(f)
	f.UpdateStateIcon = UpdateStateIcon
	f.UpdateStateIconSize = function() end
end

function mod:PLAYER_ENTERING_WORLD()
	local in_instance, instance_type = IsInInstance()
	instanced_pvp = in_instance and (instance_type == "arena" or instance_type == "pvp")
end

function mod:OnEnable()
	if ELITE_INDICATOR then
		self:RegisterMessage("Show")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		addon.Nameplate.UpdateLevel = UpdateLevel
	end
end
