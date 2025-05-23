local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("Custom_TargetHelper", 101)
if not mod then return end

local classColoredHealthbar = false
local classColoredTargetArrows = false
local classColoredFrameGlow = false
local CLASS = select(2, UnitClass("player"))

local function GetColor(f)
    local r, g, b
    if UnitIsTapDenied(f.unit) then
        r, g, b = unpack(core.profile.colour_tapped)
    elseif f.state.name == ns.explosive_name then
        r, g, b = 1, 0, 0
    elseif f.state.target and not UnitIsPlayer(f.unit) then
        r, g, b = kui.GetClassColour(CLASS, 2)
    else
        r, g, b = unpack(f.state.healthColour)
    end
    return r, g, b
end

local function UpdateFrameGlow(f)
    local r, g, b = GetColor(f)
    if f.IN_NAMEONLY and classColoredFrameGlow then
        if f.NameOnlyGlow then
            if TARGET_GLOW and f.state.target then
                f.NameOnlyGlow:SetVertexColor(r, g, b)
            end
        end
    else
        if core.profile.target_glow and f.state.target and classColoredFrameGlow then
            f.TargetGlow:SetVertexColor(r, g, b)
            f.ThreatGlow:SetVertexColor(r, g, b)
        end
    end
end

local function UpdateTargetArrows(f)
    if not core.profile.target_arrows or f.IN_NAMEONLY or not classColoredTargetArrows then
        return
    end

    if f.state.target then
        local r, g, b = GetColor(f)
        f.TargetArrows:SetVertexColor(r, g, b)
    end
end

function mod:Show(f)
    if not f.state or not f.unit then return end
    if f.state.personal then return end
    local r, g, b = GetColor(f)
    if f.elements.HealthBar and classColoredHealthbar then
        f.HealthBar:SetStatusBarColor(r, g, b)
    end
end

function mod:Create(f)
    if f.UpdateFrameGlow then
        hooksecurefunc(f, "UpdateFrameGlow", function(f)
            UpdateFrameGlow(f)
        end)
    end
    if f.UpdateTargetArrows then
        hooksecurefunc(f, "UpdateTargetArrows", function(f)
            UpdateTargetArrows(f)
        end)
    end
end

function mod:Enable()
    self:RegisterMessage("Create")
    self:RegisterMessage("Show")
    self:RegisterMessage("Hide", "Show")
    self:RegisterMessage("LostTarget", "Show")
    self:RegisterMessage("GainedTarget", "Show")
    self:RegisterMessage("HealthColourChange", "Show")
    -- self:RegisterUnitEvent("UNIT_NAME_UPDATE", "Show")
end