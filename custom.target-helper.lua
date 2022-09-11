local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("Custom_TargetHelper", 101)
if not mod then return end

local class = select(2, UnitClass("player"))

function mod:Show(f)
    if not f.state or not f.unit then return end
    if f.state.personal then return end
    local r, g, b
    if UnitIsTapDenied(f.unit) then
        r, g, b = unpack(core.profile.colour_tapped)
    elseif f.state.target and not UnitIsPlayer(f.unit) then
        r, g, b = kui.GetClassColour(class, 2)
    else
        r, g, b = unpack(f.state.healthColour)
    end

    if f.elements.HealthBar then
        f.HealthBar:SetStatusBarColor(r, g, b)
    end
end

function mod:Initialise()
    self:RegisterMessage("Show")
    self:RegisterMessage("Hide", "Show")
    self:RegisterMessage("LostTarget", "Show")
    self:RegisterMessage("GainedTarget", "Show")
    self:RegisterMessage("HealthColourChange", "Show")
    -- self:RegisterUnitEvent("UNIT_NAME_UPDATE", "Show")
end