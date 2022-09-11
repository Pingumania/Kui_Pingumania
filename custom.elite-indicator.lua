local _, ns = ...
local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("Custom_EliteIndicator", 101)
if not mod then return end

local instanced_pvp
local ELITE_INDICATOR = true
local MAX_LEVEL = ns.Retail and GetMaxLevelForPlayerExpansion() or ns.BCC and 70 or ns.Classic and 60

local function UpdateLevel(plate)
	plate = plate.parent

	if kui.CLASSIC then
		plate.state.level = UnitLevel(plate.unit) or 0
	else
		plate.state.level = instanced_pvp and UnitLevel(plate.unit) or UnitEffectiveLevel(plate.unit) or 0
	end

	if plate.elements.LevelText then
		local l, cl, d = kui.UnitLevel(plate.unit, nil, instanced_pvp)
		if l == "??" then
			l = "B"
		end
		cl = strupper(gsub(cl, "+", "E"))
		if type(l) == "number" and l >= MAX_LEVEL then
			plate.LevelText:SetText(cl)
		else
			plate.LevelText:SetText(l..cl)
		end
		plate.LevelText:SetTextColor(d.r, d.g, d.b)
	end
end

local function UpdateStateIcon(plate)
	if not core.profile.state_icons or plate.IN_NAMEONLY or (plate.elements.LevelText and plate.LevelText:IsShown()) then
		plate.StateIcon:Hide()
		return
	end

	-- local ICON_SIZE = core:Scale(20)

	if plate.state.classification == "worldboss" then
		plate.StateIcon:SetTexture("interface/addons/kui_nameplates_core/media/state-icons")
		plate.StateIcon:SetTexCoord(0, 0.5, 0, 0.5)
		plate.StateIcon:SetVertexColor(1, 1, 1)
		plate.StateIcon:Show()
	elseif plate.state.classification == "elite" then
		plate.StateIcon:SetAtlas("nameplates-icon-elite-gold")
		plate.StateIcon:SetVertexColor(1, 1, 1)
		plate.StateIcon:Show()
	elseif plate.state.classification == "rareelite" then
		plate.StateIcon:SetTexture("interface/addons/kui_nameplates_core/media/state-icons")
		plate.StateIcon:SetTexCoord(0.5, 1, 0.5, 1)
		plate.StateIcon:SetVertexColor(1, 1, 1)
		plate.StateIcon:Show()
	elseif plate.state.classification == "rare" then
		plate.StateIcon:SetTexture("interface/addons/kui_nameplates_core/media/state-icons")
		plate.StateIcon:SetTexCoord(0.5, 1, 0.5, 1)
		plate.StateIcon:SetVertexColor(1, 0.82, 0)
		plate.StateIcon:Show()
	else
		plate.StateIcon:Hide()
	end
end

function mod:Show(plate)
	UpdateStateIcon(plate)
	-- f.UpdateStateIconSize = function() end
end

function mod:PLAYER_ENTERING_WORLD()
	local in_instance, instance_type = IsInInstance()
	instanced_pvp = in_instance and (instance_type == "arena" or instance_type == "pvp")
end

function mod:OnEnable()
	if ELITE_INDICATOR then
		for _, plate in addon:Frames() do
			self:Show(plate)
		end
		self:RegisterMessage("Show")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		addon.Nameplate.UpdateLevel = UpdateLevel
	end
end
