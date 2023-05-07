local _, ns = ...

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_PixelPerfect", 101)
if not mod then return end

local function SetScale(f)
    f:SetIgnoreParentScale(true)
    f:SetScale(PixelUtil.GetPixelToUIUnitFactor())
end

function mod:Show(f)
    SetScale(f)
end

function mod:Create(f)
    SetScale(f)
end

function mod:OnEnable()
    for _, f in addon:Frames() do
        SetScale(f)
    end
    self:RegisterMessage("Create")
    self:RegisterMessage("Show")

    addon.UI_SCALE_CHANGED = function() end
end