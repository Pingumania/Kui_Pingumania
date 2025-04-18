local _, ns = ...

local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_Objectives", 101)
if not mod then return end

-----------------------------------------------------------------
-- TODO:
-- Also show the remaining % or count on the quest icon
-- Problem: Unit can be part of multiple quests
--   => Return the highest remaining
-----------------------------------------------------------------

local activePlates, worldQuests = {}, {}
local FORMAT_QUEST_OBJECTS_FOUND = "^(%d+)/(%d+)"
local FORMAT_QUEST_OBJECTS_PROGRESS = "%((%d+)%%%)$"
local playerName = UnitName("player")

local function TooltipScanLines(tooltipData)
    if not tooltipData then
        return
    end

    local isPlayer
    local questName
    local questID
    local isWorldQuest

    for i = 3, #tooltipData.lines do
        local line = tooltipData.lines[i]

        if (line.type == 17) then -- QuestTitle
            questName = line.leftText
            questID = line.id or questID or worldQuests[questName]
            isWorldQuest = worldQuests[questName] and true
        elseif (line.type == 18) then -- QuestPlayer
            isPlayer = line.leftText ~= playerName
        elseif (line.type == 8 and not isPlayer) then -- QuestObjective
            -- Maybe we can use C_TooltipInfo.GetQuestPartyProgress(questID [, omitTitle, ignoreActivePlayer])
            -- local data = C_TooltipInfo.GetQuestPartyProgress(questID)
            local inProgress = not line.completed
            local progress = questID and C_TaskQuest.GetQuestProgressBarInfo(questID)
            local d1 = strmatch(line.leftText, FORMAT_QUEST_OBJECTS_PROGRESS)
            local d2, d3 = strmatch(line.leftText, FORMAT_QUEST_OBJECTS_FOUND)
            local remaining = 0
            if d1 or progress then
                remaining = 100 - (d1 or progress)
            elseif d2 and d3 then
                remaining = d3 - d2
            end
            if inProgress and remaining > 0 then
                return inProgress, remaining, isWorldQuest
            end
        end
    end
end

local function UpdateQuestIcon(f)
    if UnitIsPlayer(f.unit) or f.IN_NAMEONLY or not f.ObjectiveIcon or not f.ObjectiveText then
        return
    end
    local tooltipData = C_TooltipInfo.GetUnit(f.unit)
    local inProgress, remaining, isWorldQuest = TooltipScanLines(tooltipData)
    if inProgress then
        if isWorldQuest then
            f.ObjectiveIcon:SetVertexColor(1, 1, 0.467)
        else
            f.ObjectiveIcon:SetVertexColor(1, 1, 0)
        end
        f.ObjectiveIcon:Show()
        f.ObjectiveText:SetText(remaining)
        f.ObjectiveText:Show()
    else
        f.ObjectiveIcon:Hide()
        f.ObjectiveText:SetText("")
        f.ObjectiveText:Hide()
    end
end

function mod:Show(f)
    local font, _, flags = f.NameText:GetFont()
    f.ObjectiveText:SetFont(font or core.profile.font_face, core.profile.font_size_small, flags or core.profile.font_style)
    UpdateQuestIcon(f)
    activePlates[f] = true
end

function mod:Hide(f)
    activePlates[f] = nil
    if not f.ObjectiveIcon or not f.ObjectiveText then return end
    f.ObjectiveIcon:Hide()
    f.ObjectiveText:Hide()
end

function mod:Create(f)
    if f.ObjectiveIcon and f.ObjectiveText then return end
    local icon = f:CreateTexture(nil, "ARTWORK")
    icon:SetSize(30, 30)
    icon:SetAtlas("VignetteLoot")
    icon:SetPoint("LEFT", f, "RIGHT", 1, 0)
    icon:Hide()
    f.ObjectiveIcon = icon
    local text = f:CreateFontString(nil, "OVERLAY")
    text:SetJustifyH("CENTER")
    text:SetPoint("CENTER", icon, 0, 0)
    text:Hide()
    f.ObjectiveText = text
end

function mod:PLAYER_ENTERING_WORLD(event)
    local uiMapID = C_Map.GetBestMapForUnit("player")
    if uiMapID then
        for k, task in pairs(C_TaskQuest.GetQuestsForPlayerByMapID(uiMapID) or {}) do
            if task.inProgress then
                local questID = task.questId
                local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
                if questName then
                    worldQuests[questName] = questID
                end
            end
        end
    end
end

function mod:QUEST_ACCEPTED(event, questID)
    if questID and C_QuestLog.IsQuestTask(questID) then
        local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
        if questName then
            worldQuests[questName] = questID
        end
    end
    self:UNIT_QUEST_LOG_CHANGED(event, "player")
end

function mod:QUEST_WATCH_LIST_CHANGED(event, questID, added)
    if added then
        self:QUEST_ACCEPTED(event, questID)
    end
end

function mod:QUEST_WATCH_UPDATE(event, questID)
    self:QUEST_ACCEPTED(event, questID)
end

function mod:UNIT_QUEST_LOG_CHANGED(event)
    for f, active in pairs(activePlates) do
        if active then
            UpdateQuestIcon(f)
        end
    end
end

function mod:OnInitialise()
    for _, f in addon:Frames() do
        self:Create(f)
    end
end

function mod:OnEnable()
    -- Workaround for KNP not supporting RegisterUnitEvent correctly
    local f = CreateFrame("Frame")
    f:RegisterUnitEvent("UNIT_QUEST_LOG_CHANGED", "player")
    f:SetScript("OnEvent", function(self, event)
        mod:UNIT_QUEST_LOG_CHANGED(event)
    end)

    self:RegisterMessage("Create")
    self:RegisterMessage("Show")
    self:RegisterMessage("Hide")
    -- self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
    -- self:RegisterEvent("QUEST_REMOVED", UNIT_QUEST_LOG_CHANGED)
    -- self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- self:RegisterEvent("QUEST_COMPLETE", UNIT_QUEST_LOG_CHANGED)
    -- self:RegisterEvent("QUEST_WATCH_UPDATE", UNIT_QUEST_LOG_CHANGED)
    -- self:RegisterEvent("QUEST_AUTOCOMPLETE", UNIT_QUEST_LOG_CHANGED)
    -- self:RegisterEvent("QUEST_TURNED_IN", UNIT_QUEST_LOG_CHANGED)
    -- self:RegisterEvent("QUEST_LOG_CRITERIA_UPDATE", UNIT_QUEST_LOG_CHANGED)

    -- Disable KNP Quest module
    local plugin_quest = addon:GetPlugin("Quest")
    plugin_quest.QuestLogUpdate = function() end
    plugin_quest.Show = function() end
    plugin_quest:UnregisterEvent("QUEST_LOG_UPDATE")
end