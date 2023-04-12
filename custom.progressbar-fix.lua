local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local kui = LibStub("Kui-1.0")
local mod = addon:NewPlugin("ProgressbarFix", 101)
if not mod then return end

function mod:Show(f)
    if not f.IN_NAMEONLY then return end
    if f.parent and f.parent.UnitFrame and f.parent.UnitFrame.WidgetContainer then
        f.NameText:SetPoint("BOTTOM", f.HealthBar, "TOP", 0, 15)
    end
end

function mod:Enable()
    for _, f in addon:Frames() do
        self:Show(f)
    end
    self:RegisterMessage("Show")
end