local addon = KuiNameplates
local core = KuiNameplatesCore
local mod = addon:NewPlugin("Custom_Objectives", 101)
if not mod then return end

-- TODO:
-- Distinguish between world and normal quests

local tinsert = tinsert
local tremove = tremove
local wipe = wipe
local next = next
local pairs = pairs
local match = string.match
local tonumber = tonumber

local ScanTooltip = CreateFrame("GameTooltip", "Kui_Nameplates_Objective_Tip", nil, "GameTooltipTemplate")
ScanTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
local result, activePlates = {}, {}
local FORMAT_QUESTOBJECTIVE = "^.-%s*%-*%s*(.+)"
local FORMAT_QUEST_OBJECTS_FOUND = "^(%d+)/(%d+)"
local FORMAT_QUEST_OBJECTS_PROGRESS = "%((%d+)%%%)$"
local onQuest, inProgress, line, unitName, text, r, g, b, d1, d2, lineObj, offsetX, questName

local function ScanPlate(f)
	if UnitIsPlayer(f.unit) then return end
	ScanTooltip:ClearLines()
	ScanTooltip:SetUnit(f.unit)
	inProgress = nil
	unitName = nil
	questName = nil
	wipe(result)

	for i = 2, ScanTooltip:NumLines() do
		lineObj = _G["Kui_Nameplates_Objective_TipTextLeft"..i]
		line = lineObj:GetText()
		if line and #line > 1 then
			offsetX = select(4, lineObj:GetPoint(2))
			if (offsetX < 20) then -- title
				r, g, b = lineObj:GetTextColor()
				if b == 0 and g < 0.83 then
					if line == UnitName("player") then
						unitName = nil
					elseif UnitInParty(line) then
						unitName = line
					else
						questName = line
						unitName = nil
						inProgress = nil
						result[questName] = false
					end
				end
			elseif unitName == nil and offsetX < 30 then -- objective
				text = match(line, FORMAT_QUESTOBJECTIVE)
				if text then -- player's quest
					if inProgress == nil then
						result[questName] = false
					end
					d1 = match(text, FORMAT_QUEST_OBJECTS_PROGRESS)
					if d1 and (tonumber(d1) < 100) then
						inProgress = true
					else
						inProgress = true
						d1, d2 = match(text, FORMAT_QUEST_OBJECTS_FOUND)
						if (d1 == d2) then
							inProgress = false
							-- break
						end
						if inProgress then
							r, g, b = lineObj:GetTextColor()
							if r < 0.51 and g < 0.51 and b < 0.51 then
								inProgress = false
							end
						end
					end
					if inProgress then
						result[questName] = true
						-- break
					end
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

		return true, inProgress
	end
end

local function UpdateQuestIcon(f)
	onQuest = nil
	inProgress = nil
	f.ObjectiveIcon:SetPoint("LEFT", f.NameText, -25, 0)
	onQuest, inProgress = ScanPlate(f)
	if onQuest and inProgress then
		f.ObjectiveIcon:SetVertexColor(1, 1, 0)
		f.ObjectiveIcon:Show()
	else
		f.ObjectiveIcon:Hide()
	end
end

local function RemovePlates(f)
	if #activePlates > 0 then
		for i=1, #activePlates do
			if activePlates[i] == f then
				tremove(activePlates, i)
			end
		end
	end
end

local function UpdatePlates()
	if #activePlates > 0 then
		onQuest = nil
		inProgress = nil
		for i = 1, #activePlates do
			local f = activePlates[i]
			if f then
				UpdateQuestIcon(f)
			else
				tremove(activePlates, i)
			end
		end
	end
end

function mod:Show(f)
	if UnitIsPlayer(f.unit) then return end
	UpdateQuestIcon(f)
	tinsert(activePlates, f)
end

function mod:Hide(f)
	f.ObjectiveIcon:Hide()
	RemovePlates(f)
end

function mod:Create(f)
	if f.ObjectiveIcon then return end
	local objective = f:CreateTexture(nil, "OVERLAY")
	objective:SetSize(19, 18)
	objective:SetAtlas("WhiteCircle-RaidBlips")
	objective:SetScale(0.5)
	f.ObjectiveIcon = objective
end

function mod:OnEnable()
	self:RegisterMessage("Create")
	self:RegisterMessage("Show")
	self:RegisterMessage("Hide")
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", UpdatePlates)
end
