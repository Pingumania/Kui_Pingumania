local _, ns = ...
if not ns.modules.name_left then return end

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_NameLeft", 101)
if not mod then return end

local function ScaleTextOffset(v)
    return floor(core:Scale(v)) - .5
end

local function UpdateNameTextPosition(f)
    if f.IN_NAMEONLY then return end
    f.NameText:SetJustifyH("LEFT")
    f.NameText:SetPoint("BOTTOMLEFT", f.HealthBar, "TOPLEFT", 0, ScaleTextOffset(core.profile.name_vertical_offset))
    f.NameText:SetPoint("RIGHT", f.HealthBar, 0, 0)
end

function mod:Create(f)
    hooksecurefunc(f, "UpdateNameTextPosition", function(f)
        UpdateNameTextPosition(f)
    end)
end

function mod:OnInitialise()
    for _, f in addon:Frames() do
        self:Create(f)
    end
end

function mod:OnEnable()
    self:RegisterMessage("Create")
end