local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_AurasRight", 101)
if not mod then return end

local function PostCreateAuraFrame(f)
    if f.id == "core_dynamic" then
        f.point = {"BOTTOMRIGHT", "RIGHT", "LEFT"}
        hooksecurefunc(f.parent, "UpdateFrameSize", function(self)
            f:ClearAllPoints()
            f:SetPoint("BOTTOMRIGHT", f.parent.bg, "TOPRIGHT", 0, core:Scale(core.profile.auras_offset))
        end)
    end
end

function mod:Enable()
    self:AddCallback("Auras", "PostCreateAuraFrame", PostCreateAuraFrame)
end