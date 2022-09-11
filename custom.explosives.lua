local _, ns = ...
if not ns.Retail then return end
if not ns.modules.explosives then return end

local addon = KuiNameplates
local mod = addon:NewPlugin("Custom_Explosives", 101, 5)
if not mod then return end

local mob_name
local function icon_Show(self)
    self.v:Show()
    self.h:Show()
    self.i:Show()
end

local function icon_Hide(self)
    self.v:Hide()
    self.h:Hide()
    self.i:Hide()
end

function mod:Create(f)
    f.feicon = {}

    local v = f:CreateTexture(nil, "ARTWORK", nil, 1)
    v:SetTexture("interface/buttons/white8x8")
    v:SetVertexColor(1, 0, 0, .5)
    v:SetHeight(30000)
    v:SetWidth(3)
    f.feicon.v = v

    local h = f:CreateTexture(nil, "ARTWORK", nil, 1)
    h:SetTexture("interface/buttons/white8x8")
    h:SetVertexColor(1, 0, 0, .5)
    h:SetHeight(3)
    h:SetWidth(30000)
    f.feicon.h = h

    local i = f:CreateTexture(nil, "ARTWORK", nil, 2)
    i:SetTexture(135799)
    i:SetVertexColor(1, 1, 1, 1)
    i:SetHeight(50)
    i:SetWidth(50)
    f.feicon.i = i

    i:SetPoint("BOTTOM", f, "TOP")
    v:SetPoint("CENTER", i)
    h:SetPoint("CENTER", i)

    f.feicon.Show = icon_Show
    f.feicon.Hide = icon_Hide
    f.feicon:Hide()
end

function mod:Show(f)
    if f.state.name ~= mob_name then return end
    if not f.feicon then
        self:Create(f)
    end
    f.feicon:Show()
end

function mod:Hide(f)
    if f.feicon then
        f.feicon:Hide()
    end
end

function mod:PLAYER_ENTERING_WORLD()
    if IsInInstance() then
        local _, instanceType, difficulty = GetInstanceInfo()
        if instanceType == "party" then
            local name, groupType, isHeroic, isChallengeMode, displayHeroic, displayMythic, toggleDifficultyID = GetDifficultyInfo(difficulty)
            if isChallengeMode then
                self:RegisterMessage("Show")
                return
            end
        end
    end
    self:UnregisterMessage("Show")
end

function mod:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_INSTANCE_INFO", "PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHALLENGE_MODE_START", "PLAYER_ENTERING_WORLD")
    self:RegisterMessage("Hide")

    local locale = GetLocale()
    local names = {
        deDE = "Sprengstoff",
        enUS = "Explosives",
        esMX = "Explosivos",
        frFR = "Explosifs",
        itIT = "Esplosivi",
        ptBR = "Explosivos",
        ruRU = "Взрывчатка",
        koKR = "폭발물",
        zhCN = "爆炸物",
    }
    mob_name = (locale and names[locale]) or names.enUS
end