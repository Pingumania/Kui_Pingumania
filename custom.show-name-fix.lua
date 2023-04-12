local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_ShowNameFix", 101)
if not mod then return end

local SHOW_ALWAYS
local SHOW_HOSTILE
local plugin_fading

local function UnitShouldDisplayName(f)
    if SHOW_ALWAYS then
        return true
    elseif f.state.target then
        return true
    elseif SHOW_HOSTILE and f.state.reaction < 4 then
        return true
    else
        return false
    end
end

local function ShowNameUpdate(self, f)
    if f.state.target or
       f.state.threat or
       UnitShouldDisplayName(f)
    then
        f.state.tracked = true
        f.state.no_name = nil
    else
        f.state.tracked = nil
        f.state.no_name = core.profile.hide_names
    end

    if core.profile.show_arena_id and f.state.arenaid then
        f.state.no_name = nil
    elseif f.state.personal or not core.profile.name_text then
        f.state.no_name = true
    end

    if core.profile.fade_untracked or core.profile.fade_avoid_tracked or core.profile.fade_avoid_combat then
        plugin_fading:UpdateFrame(f)
    end
end

function mod:CVAR_UPDATE()
    if C_CVar.GetCVar("UnitNameNPC") == "0" then
        SHOW_ALWAYS = false
    else
        SHOW_ALWAYS = true
    end

    if C_CVar.GetCVar("UnitNameHostleNPC") == "0" then
        SHOW_HOSTILE = false
    else
        SHOW_HOSTILE = true
    end
end

function mod:OnEnable()
    plugin_fading = addon:GetPlugin("Fading")
    core.ShowNameUpdate = ShowNameUpdate
    self:RegisterEvent("CVAR_UPDATE")
end