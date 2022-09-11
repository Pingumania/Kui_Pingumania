local _, ns = ...
if not ns.Retail then return end

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_RogueFix", 101)
if not mod then return end

local _, PlayerClass = UnitClass("player")

local function PostPowerUpdate()
    if (PlayerClass == "ROGUE") then
        local chargedPoints = GetUnitChargedPowerPoints("player")
        if chargedPoints then
            addon.ClassPowersFrame.icons[unpack(chargedPoints)]:SetVertexColor(0, 0.75, 1)
            addon.ClassPowersFrame.icons[unpack(chargedPoints)].glow:Show()
        else

        end
    end
end

function mod:OnEnable()
    self:AddCallback("ClassPowers", "PostPowerUpdate", PostPowerUpdate)
end
