local _, ns = ...
if not ns.Retail then return end
if not ns.modules.objectives then return end

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_Objectives", 101)
if not mod then return end

local ScanTooltip = CreateFrame("GameTooltip", "Kui_Nameplates_Tooltip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
local result, activePlates, worldQuests = {}, {}, {}
local FORMAT_QUESTOBJECTIVE = "^.-%s*%-*%s*(.+)"
local FORMAT_QUEST_OBJECTS_FOUND = "^(%d+)/(%d+)"
local FORMAT_QUEST_OBJECTS_PROGRESS = "%((%d+)%%%)$"

local function ScanPlate(f)
    if UnitIsPlayer(f.unit) then return end
    ScanTooltip:ClearLines()
    ScanTooltip:SetUnit(f.unit)
    local inProgress
    local unitName
    local questName
    local questID
    local isWorldQuest
    wipe(result)

    for i = 3, ScanTooltip:NumLines() do
        local lineObj = _G["Kui_Nameplates_TooltipTextLeft"..i]
        local line = lineObj and lineObj:GetText()
        if not line then return end
        local offsetX = select(4, lineObj:GetPoint(2))
        if (offsetX < 20) then -- title
            local r, g, b = lineObj:GetTextColor()
            if b == 0 and g < 0.83 then
                if line == UnitName("player") then
                    unitName = nil
                elseif UnitInParty(line) then
                    unitName = line
                else
                    questName = line
                    questID = questID or worldQuests[line]
                    isWorldQuest = worldQuests[line] and true or false
                    unitName = nil
                    inProgress = nil
                    result[questName] = false
                end
            end
        elseif unitName == nil and offsetX < 30 then -- objective
            local text = strmatch(line, FORMAT_QUESTOBJECTIVE)
            if text and questName then -- player's quest
                if inProgress == nil then
                    result[questName] = false
                end
                local progress = questID and C_TaskQuest.GetQuestProgressBarInfo(questID)
                local d1, d2 = strmatch(text, FORMAT_QUEST_OBJECTS_PROGRESS)
                if d1 or progress then
                    inProgress = true
                else
                    inProgress = true
                    d1, d2 = strmatch(text, FORMAT_QUEST_OBJECTS_FOUND)
                    if (d1 == d2) then
                        inProgress = false
                    end
                    if inProgress then
                        local r, g, b = lineObj:GetTextColor()
                        if r < 0.51 and g < 0.51 and b < 0.51 then
                            inProgress = false
                        end
                    end
                end
                if inProgress then
                    result[questName] = true
                end
            end
        end
    end

    if next(result) then
        inProgress = false
        for _, v in pairs(result) do
            if v then
                inProgress = true
            end
        end

        return true, inProgress, isWorldQuest
    end
end

local function UpdateQuestIcon(f)
    local onQuest, inProgress, isWorldQuest = ScanPlate(f)
    if onQuest and inProgress then
        if isWorldQuest then
            f.ObjectiveIcon:SetVertexColor(1, 0.5, 0.25)
        else
            f.ObjectiveIcon:SetVertexColor(1, 1, 0)
        end
        f.ObjectiveIcon:SetPoint("CENTER", f.NameText, -(f.NameText:GetWidth() + 12), 0)
        f.ObjectiveIcon:Show()
    else
        f.ObjectiveIcon:Hide()
    end
end

function mod:Show(f)
    if UnitIsPlayer(f.unit) then return end
    UpdateQuestIcon(f)
    activePlates[f] = true
end

function mod:Hide(f)
    f.ObjectiveIcon:Hide()
    activePlates[f] = nil
end

function mod:Create(f)
    if f.ObjectiveIcon then return end
    local objective = f:CreateTexture(nil, "OVERLAY")
    objective:SetSize(19, 18)
    objective:SetAtlas("WhiteCircle-RaidBlips")
    objective:SetScale(0.5)
    f.ObjectiveIcon = objective
end

function mod:PLAYER_ENTERING_WORLD(event)
    local uiMapID = C_Map.GetBestMapForUnit("player")
    if uiMapID then
        for k, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) or {}) do
            if task.inProgress then
                -- track active world quests
                local questID = task.questId
                local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
                if questName then
                    worldQuests[questName] = questID
                end
            end
        end
    end
    self:RegisterEvent("QUEST_LOG_UPDATE")
end

function mod:PLAYER_LEAVING_WORLD()
    self:UnregisterEvent("QUEST_LOG_UPDATE")
end

function mod:QUEST_ACCEPTED(event, questID)
    if questID and C_QuestLog.IsQuestTask(questID) then
        local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
        if questName then
            worldQuests[questName] = questID
        end
    end
    self:UNIT_QUEST_LOG_CHANGED()
end

function mod:QUEST_REMOVED()
    self:UNIT_QUEST_LOG_CHANGED()
end

function mod:QUEST_WATCH_LIST_CHANGED(event, questID)
    self:QUEST_ACCEPTED(event, questID)
end

function mod:UNIT_QUEST_LOG_CHANGED(event, unitID)
    if unitID == "player" then return end
    for f, active in pairs(activePlates) do
        if active then
            UpdateQuestIcon(f)
        end
    end
end

function mod:QUEST_LOG_UPDATE()
    for f, active in pairs(activePlates) do
        if active then
            UpdateQuestIcon(f)
        end
    end
end

function mod:OnEnable()
    for _, f in addon:Frames() do
        self:Create(f)
    end
end

function mod:OnEnable()
    self:RegisterMessage("Create")
    self:RegisterMessage("Show")
    self:RegisterMessage("Hide")
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    self:RegisterEvent("QUEST_REMOVED")
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEAVING_WORLD")
end
