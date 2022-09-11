local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_CurrentTarget", 101)
if not mod then return end

function mod:Show(f)
	if f.state.target then
		f.HealthBar:SetStatusBarColor(1, 0, 1)
    else
        f.HealthBar:SetStatusBarColor(unpack(f.state.healthColour))
    end
end

function mod:Initialise()
    self:RegisterMessage("Show")
    self:RegisterMessage("LostTarget", "Show")
    self:RegisterMessage("GainedTarget", "Show")
end