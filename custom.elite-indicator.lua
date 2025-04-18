local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("Custom_EliteIndicator", 101)
if not mod then return end

local instanced_pvp
local ELITE_INDICATOR_ICON = true
local ELITE_INDICATOR_TEXT = false
local ELITE_INDICATOR_BORDER = false
local MAX_LEVEL = GetMaxLevelForPlayerExpansion()

local function UpdateLevel(f)
    local f = f.parent

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

    f.StateIcon:ClearAllPoints()
    f.StateIcon:SetPoint("RIGHT", f, "LEFT", -1, 0)

    if f.state.classification == "worldboss" then
        f.StateIcon:SetTexture("interface/addons/kui_nameplates_core/media/state-icons")
        f.StateIcon:SetTexCoord(0, 0.5, 0, 0.5)
        f.StateIcon:SetVertexColor(1, 1, 1)
        f.StateIcon:Show()
    elseif f.state.classification == "elite" then
        f.StateIcon:SetTexture("Interface/TargetingFrame/Nameplates")
        f.StateIcon:SetTexCoord(0.00390625, 0.148438, 0.234375, 0.507812)
        f.StateIcon:SetVertexColor(1, 1, 1)
        f.StateIcon:Show()
    elseif f.state.classification == "rareelite" then
        f.StateIcon:SetTexture("interface/addons/kui_nameplates_core/media/state-icons")
        f.StateIcon:SetTexCoord(0.5, 1, 0.5, 1)
        f.StateIcon:SetVertexColor(1, 1, 1)
        f.StateIcon:Show()
    elseif f.state.classification == "rare" then
        f.StateIcon:SetTexture("interface/addons/kui_nameplates_core/media/state-icons")
        f.StateIcon:SetTexCoord(0.5, 1, 0.5, 1)
        f.StateIcon:SetVertexColor(1, 0.82, 0)
        f.StateIcon:Show()
    else
        f.StateIcon:Hide()
    end
end

local function UpdateNameText(f)
    local indicator = ""
    local r, g, b = 1, 1, 1
    if f.state.level == -1 then
        r, g, b = 1, 0, 0
        indicator = "+??"
    elseif f.state.classification == "worldboss" then
        indicator = "b"
        r, g, b = 1, 0, 0
    elseif f.state.classification == "elite" then
        r, g, b = 1, 1, 0
        indicator = "+"
    elseif f.state.classification == "rareelite" then
        indicator = "r+"
        r, g, b = 1, 0.82, 0
    elseif f.state.classification == "rare" then
        indicator = "r"
        r, g, b = 1, 0.82, 0
    end

    local text = f.NameText:GetText()
    local color = CreateColor(r, g, b)
    f.NameText:SetText(text..color:GenerateHexColorMarkup()..indicator)
    f.NameText:Show()
end

function mod:Show(f)
    if ELITE_INDICATOR_ICON then
        UpdateStateIcon(f)
    end

    if ELITE_INDICATOR_TEXT then
        UpdateNameText(f)
    end

    if ELITE_INDICATOR_BORDER then

    end
end

function mod:Hide(f)
    if ELITE_INDICATOR_TEXT then
        f.ClassificationText:Hide()
    end
end

function mod:Create(f)
    if ELITE_INDICATOR_ICON then
        f.UpdateStateIcon = UpdateStateIcon
        f.UpdateStateIconSize = function() end
        f.StateIcon:SetSize(28, 28)
        UpdateStateIcon(f)
    end
end

function mod:PLAYER_ENTERING_WORLD()
    local in_instance, instance_type = IsInInstance()
    instanced_pvp = in_instance and (instance_type == "arena" or instance_type == "pvp")
end

function mod:OnInitialise()
    for _, f in addon:Frames() do
        self:Create(f)
    end
end

function mod:OnEnable()
    self:RegisterMessage("Create")
    self:RegisterMessage("Show")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.Nameplate.UpdateLevel = UpdateLevel
end
