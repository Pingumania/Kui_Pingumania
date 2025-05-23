local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_SpellTimer", 101)
if not mod then return end

local format = format

function mod:CastBarShow(f)
    local font, _, flags = f.NameText:GetFont()
    f.SpellTimer:SetFont(font or core.profile.font_face, core.profile.font_size_small, flags or core.profile.font_style)
    f.SpellTimer:Show()
    f.CastBarUpdateFrame:HookScript("OnUpdate", function()
        local value
        if f.cast_state.channel then
            value = f.CastBar:GetValue()
        else
            value = (f.cast_state.end_time - f.cast_state.start_time) - (GetTime() - f.cast_state.start_time)
        end
        if value < 99 and value >= 0 then
            f.SpellTimer:SetText(format("%.1f", value))
        elseif value >= 99 then
            f.SpellTimer:SetText("~")
        end
    end)
end

function mod:CastBarHide(f)
    f.SpellTimer:Hide()
end

function mod:Create(f)
    if f.SpellTimer then return end
    local timer = f:CreateFontString(nil, "OVERLAY")
    timer:SetPoint("RIGHT", f.CastBar.bg, "RIGHT", -2, 0)
    f.SpellTimer = timer
end

function mod:OnInitialise()
    for _, f in addon:Frames() do
        self:Create(f)
    end
end

function mod:OnEnable()
    self:RegisterMessage("CastBarShow")
    self:RegisterMessage("CastBarHide")
    self:RegisterMessage("Create")
end
