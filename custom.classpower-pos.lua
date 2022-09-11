local addon = KuiNameplates
local mod = addon:NewPlugin("Cusotm_ClassPowerPosition", 101)
if not mod then return end

local function PostPositionFrame(f, parent)
	if f and parent.HealthText:IsShown() then
		f:ClearAllPoints()
		f:SetPoint("CENTER", parent.HealthBar, "BOTTOM", -30, 0)
	end
end

function mod:OnEnable()
	self:AddCallback("ClassPowers", "PostPositionFrame", PostPositionFrame)
end
