-- Who objects to the ObjectiveTracker...?

OBJECTIVE_TRACKER_ITEM_WIDTH = 33;
OBJECTIVE_TRACKER_HEADER_HEIGHT = 25;
OBJECTIVE_TRACKER_LINE_WIDTH = 240;
OBJECTIVE_TRACKER_HEADER_OFFSET_X = -10;
-- calculated values
OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT = 0;
OBJECTIVE_TRACKER_DASH_WIDTH = 0;
OBJECTIVE_TRACKER_TEXT_WIDTH = 0;

OBJECTIVE_TRACKER_COLOR = {
	["Normal"] = { r = 0.8, g = 0.8, b = 0.8 },
	["NormalHighlight"] = { r = HIGHLIGHT_FONT_COLOR.r, g = HIGHLIGHT_FONT_COLOR.g, b = HIGHLIGHT_FONT_COLOR.b },
	["Failed"] = { r = DIM_RED_FONT_COLOR.r, g = DIM_RED_FONT_COLOR.g, b = DIM_RED_FONT_COLOR.b },
	["FailedHighlight"] = { r = RED_FONT_COLOR.r, g = RED_FONT_COLOR.g, b = RED_FONT_COLOR.b },
	["Header"] = { r = 0.75, g = 0.61, b = 0 },
	["HeaderHighlight"] = { r = NORMAL_FONT_COLOR.r, g = NORMAL_FONT_COLOR.g, b = NORMAL_FONT_COLOR.b },
	["Complete"] = { r = 0.6, g = 0.6, b = 0.6 },
};
	OBJECTIVE_TRACKER_COLOR["Normal"].reverse = OBJECTIVE_TRACKER_COLOR["NormalHighlight"];
	OBJECTIVE_TRACKER_COLOR["NormalHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Normal"];
	OBJECTIVE_TRACKER_COLOR["Failed"].reverse = OBJECTIVE_TRACKER_COLOR["FailedHighlight"];
	OBJECTIVE_TRACKER_COLOR["FailedHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Failed"];
	OBJECTIVE_TRACKER_COLOR["Header"].reverse = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].reverse = OBJECTIVE_TRACKER_COLOR["Header"];


-- these are generally from events
OBJECTIVE_TRACKER_UPDATE_QUEST						= 0x0001;
OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED				= 0x0002;
OBJECTIVE_TRACKER_UPDATE_TASK_ADDED					= 0x0004;
OBJECTIVE_TRACKER_UPDATE_SCENARIO					= 0x0008;
OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE			= 0x0010;
OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT				= 0x0020;
OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED			= 0x0040;
OBJECTIVE_TRACKER_UPDATE_SCENARIO_BONUS_DELAYED		= 0x0080;
-- these are for the specific module ONLY!
OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST				= 0x0100;
OBJECTIVE_TRACKER_UPDATE_MODULE_AUTO_QUEST_POPUP	= 0x0200;
OBJECTIVE_TRACKER_UPDATE_MODULE_BONUS_OBJECTIVE		= 0x0400;
OBJECTIVE_TRACKER_UPDATE_MODULE_SCENARIO			= 0x0800;
OBJECTIVE_TRACKER_UPDATE_MODULE_ACHIEVEMENT			= 0x1000;
-- special updates
OBJECTIVE_TRACKER_UPDATE_STATIC						= 0x0000;
OBJECTIVE_TRACKER_UPDATE_ALL						= 0xFFFF;

OBJECTIVE_TRACKER_UPDATE_REASON = OBJECTIVE_TRACKER_UPDATE_ALL;		-- default
OBJECTIVE_TRACKER_UPDATE_ID = 0;

-- speed optimizations
local floor = math.floor;
local min = min;
local band = bit.band;

-- *****************************************************************************************************
-- ***** MODULE STUFF
-- *****************************************************************************************************

--[[
blockTemplate:		template for the blocks - a quest would be a single block
blockType:			type of object
lineTemplate:		template for the lines - a quest objective would be a single line (even if it wordwraps); only FRAME supported
lineSpacing:		spacing between lines; for the first line it'll be the distance from the top of its block
blockOffsetX:		offset from the left edge of the blocksframe
blockOffsetY:		offset from the block above
fromHeaderOffsetY:	offset from the header for the first block, if there's a header; used instead of blockOffsetY
fromModuleOffsetY:	offset from the previous module
freeBlocks:			table of free blocks; a module needs it own if not using default block template
usedBlocks:			table of used blocks; a module should always have its own
freelines:			table of free lines; a module needs it own if not using default line template
					there's no table of used lines, that's per block
updateReasonModule:	the update for this module alone
updateReasonEvents: the events which should update the module
=== modules do not need to change these, they're keyed by block & line ===
usedTimerBars:		table of used timer bars
freeTimerBars:		table of free timer bars
=== modules should NOT change these ===
contentsHeight:		the current combined height of all the blocks in the module
contentsAnimHeight: the current combined animation height of all the blocks in the module
oldContentsHeight:	the previous height on the last update
hasSkippedBlocks:	if the module couldn't display all its blocks because of not enough space
--]]

DEFAULT_OBJECTIVE_TRACKER_MODULE = {
	blockTemplate = "ObjectiveTrackerBlockTemplate",
	blockType = "Frame",
	lineTemplate = "ObjectiveTrackerLineTemplate",
	lineSpacing = 2,
	freeBlocks = { },
	usedBlocks = { },
	freeLines = { },
	blockOffsetX = 0,
	blockOffsetY = -6,
	fromHeaderOffsetY = -10,
	fromModuleOffsetY = -10,
	contentsHeight = 0,
	contentsAnimHeight = 0,
	oldContentsHeight = 0,
	hasSkippedBlocks = false,
	usedTimerBars = { },
	freeTimerBars = { },
	updateReasonModule = 0,
	updateReasonEvents = 0,
};

function ObjectiveTracker_GetModuleInfoTable()
	local info = {};
	setmetatable(info, { __index = DEFAULT_OBJECTIVE_TRACKER_MODULE; });
	return info;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:BeginLayout(isStaticReanchor)
	self.firstBlock = nil;
	self.oldContentsHeight = self.contentsHeight;
	self.contentsHeight = 0;
	self.contentsAnimHeight = 0;
	-- if it's not a static reanchor, reset whether we've skipped blocks
	if ( not isStaticReanchor ) then
		self.hasSkippedBlocks = false;
	end
	self:MarkBlocksUnused();
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:EndLayout(isStaticReanchor)
	-- isStaticReanchor not used yet
	self:FreeUnusedBlocks();
end

-- ***** BLOCKS

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetHeader(block, text, animateReason, onFinishUpdateReason)
	block.module = self;
	block.isHeader = true;
	block.Text:SetText(text);
	block.animateReason = animateReason or 0;
	block.onFinishUpdateReason = onFinishUpdateReason or OBJECTIVE_TRACKER_UPDATE_ALL;
	self.Header = block;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetBlock(id)
	-- first try to return existing block
	local block = self.usedBlocks[id];
	if ( not block ) then
		local numFreeBlocks = #self.freeBlocks;
		if ( numFreeBlocks > 0 ) then
			-- get a free block
			block = self.freeBlocks[numFreeBlocks];
			tremove(self.freeBlocks, numFreeBlocks);
		else
			-- create a new block
			block = CreateFrame(self.blockType, nil, self.BlocksFrame or ObjectiveTrackerFrame.BlocksFrame, self.blockTemplate);
			block.lines = { };
		end
		self.usedBlocks[id] = block;
		block.module = self;
		block.id = id;
	end
	block.used = true;
	block.height = 0;
	block.currentLine = nil;
	-- prep lines
	if ( block.lines ) then
		for objectiveKey, line in pairs(block.lines) do
			line.used = nil;
		end
	end

	return block;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetExistingBlock(id)
	return self.usedBlocks[id];
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:MarkBlocksUnused()
	for _, block in pairs(self.usedBlocks) do
		block.used = nil;
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeBlock(block)
	-- free all the lines
	for _, line in pairs(block.lines) do
		self:FreeLine(block, line);
	end
	block.lines = { };
	-- free the block
	tinsert(self.freeBlocks, block);
	self.usedBlocks[block.id] = nil;
	block:Hide();
	-- callback
	if ( self.OnFreeBlock ) then
		self:OnFreeBlock(block);
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeUnusedBlocks()
	for questID, block in pairs(self.usedBlocks) do
		if ( not block.used ) then
			self:FreeBlock(block);
		end
	end
end

-- ***** LINES

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeLine(block, line)
	block.lines[line.objectiveKey] = nil;
	-- if the line has a type, the freeLines will be the cache for that type of line, otherwise use the module's default
	local freeLines = (line.type and line.type.freeLines) or self.freeLines;
	tinsert(freeLines, line);
	-- remove timer bar
	if ( line.TimerBar ) then
		self:FreeTimerBar(block, line);
	end
	if ( line.type and self.OnFreeTypedLine ) then
		self:OnFreeTypedLine(line);
	elseif ( self.OnFreeLine ) then
		self:OnFreeLine(line);
	end
	line:Hide();
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeUnusedLines(block)
	for objectiveKey, line in pairs(block.lines) do
		if ( not line.used ) then
			self:FreeLine(block, line);
		end
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:GetLine(block, objectiveKey, lineType)
	-- first look for existing line
	local line = block.lines[objectiveKey];

	-- if existing line is not of the same type, discard it
	if ( line and line.type ~= lineType ) then
		self:FreeLine(block, line);
		line = nil;
	end
	
	if ( line ) then
		line.used = true;
		return line;
	end

	local freeLines = (lineType and lineType.freeLines) or self.freeLines;
	local numFreeLines = #freeLines;
	local parent = block.ScrollContents or block;
	if ( numFreeLines > 0 ) then
		-- get a free line
		line = freeLines[numFreeLines];
		tremove(freeLines, numFreeLines);
		line:SetParent(parent);
		line:Show();
	else
		-- create a new line
		line = CreateFrame("Frame", nil, parent, (lineType and lineType.template) or self.lineTemplate);
		line.type = lineType;
	end
	block.lines[objectiveKey] = line;
	line.objectiveKey = objectiveKey;
	line.used = true;
	return line;
end

-- ***** OBJECTIVES

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddObjective(block, objectiveKey, text, lineType, useFullHeight, hideDash, colorStyle)
	local line = self:GetLine(block, objectiveKey, lineType);
	-- width
	if ( block.lineWidth ~= line.width ) then
		line.Text:SetWidth(block.lineWidth or self.lineWidth);
		line.width = block.lineWidth;	-- default should be nil
	end
	-- dash
	if ( hideDash and not line.hideDash ) then
		line.Dash:Hide();
		line.hideDash = true;
	elseif ( not hideDash and line.hideDash ) then
		line.Dash:Show();
		line.hideDash = nil;
	end
	-- set the text
	local height = self:SetStringText(line.Text, text, useFullHeight, colorStyle, block.isHighlighted);
	line:SetHeight(height);
	block.height = block.height + height + block.module.lineSpacing;
	-- anchor the line
	local anchor = block.currentLine or block.HeaderText;
	if ( anchor ) then
		line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -block.module.lineSpacing);
	else
		line:SetPoint("TOPLEFT", 0, -block.module.lineSpacing);
	end
	block.currentLine = line;
	return line;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
	fontString:SetHeight(0);
	fontString:SetText(text);
	stringHeight = fontString:GetHeight();
	if ( stringHeight > OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT and not useFullHeight ) then
		fontString:SetHeight(OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT);
		stringHeight = OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT;
	end
	colorStyle = colorStyle or OBJECTIVE_TRACKER_COLOR["Normal"];
	if ( useHighlight and colorStyle.reverse ) then
		colorStyle = colorStyle.reverse;
	end
	if ( fontString.colorStyle ~= colorStyle ) then
		fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
		fontString.colorStyle = colorStyle;
	end
	return stringHeight;
end

-- ***** BLOCK HEADER

function DEFAULT_OBJECTIVE_TRACKER_MODULE:SetBlockHeader(block, text)
	local height = self:SetStringText(block.HeaderText, text, nil, OBJECTIVE_TRACKER_COLOR["Header"], block.isHighlighted);
	block.height = height;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderEnter(block)
	block.isHighlighted = true;
	if ( block.HeaderText ) then
		local headerColorStyle = OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
		block.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
		block.HeaderText.colorStyle = headerColorStyle;
	end
	for objectiveKey, line in pairs(block.lines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if ( colorStyle ) then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if ( line.Dash ) then
				line.Dash:SetTextColor(OBJECTIVE_TRACKER_COLOR["NormalHighlight"].r, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].g, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].b);
			end
		end
	end
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderLeave(block)
	block.isHighlighted = nil;
	if ( block.HeaderText ) then
		local headerColorStyle = OBJECTIVE_TRACKER_COLOR["Header"];
		block.HeaderText:SetTextColor(headerColorStyle.r, headerColorStyle.g, headerColorStyle.b);
		block.HeaderText.colorStyle = headerColorStyle;
	end
	for objectiveKey, line in pairs(block.lines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if ( colorStyle ) then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if ( line.Dash ) then
				line.Dash:SetTextColor(OBJECTIVE_TRACKER_COLOR["Normal"].r, OBJECTIVE_TRACKER_COLOR["Normal"].g, OBJECTIVE_TRACKER_COLOR["Normal"].b);
			end
		end
	end	
end

-- ***** TIMER BAR

function DEFAULT_OBJECTIVE_TRACKER_MODULE:AddTimerBar(block, line, duration, startTime)
	local timerBar = self.usedTimerBars[block] and self.usedTimerBars[block][line];
	if ( not timerBar ) then
		local numFreeTimerBars = #self.freeTimerBars;
		local parent = block.ScrollContents or block;
		if ( numFreeTimerBars > 0 ) then
			timerBar = self.freeTimerBars[numFreeTimerBars];
			tremove(self.freeTimerBars, numFreeTimerBars);
			timerBar:SetParent(parent);
			timerBar:Show();
		else
			timerBar = CreateFrame("Frame", nil, parent, "ObjectiveTrackerTimerBarTemplate");
			timerBar.Label:SetPoint("LEFT", OBJECTIVE_TRACKER_DASH_WIDTH, 0);
			timerBar.height = timerBar:GetHeight();
		end
		if ( not self.usedTimerBars[block] ) then
			self.usedTimerBars[block] = { };
		end
		self.usedTimerBars[block][line] = timerBar;
		timerBar:Show();
	end	
	-- anchor the status bar
	local anchor = block.currentLine or block.HeaderText;
	if ( anchor ) then
		timerBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -block.module.lineSpacing);
	else
		timerBar:SetPoint("TOPLEFT", 0, -block.module.lineSpacing);
	end

	timerBar.Bar:SetMinMaxValues(0, duration);
	timerBar.duration = duration;
	timerBar.startTime = startTime;
	timerBar.block = block;

	line.TimerBar = timerBar;
	block.height = block.height + timerBar.height + block.module.lineSpacing;
	block.currentLine = timerBar;
	return timerBar;
end

function DEFAULT_OBJECTIVE_TRACKER_MODULE:FreeTimerBar(block, line)
	local timerBar = line.TimerBar;
	if ( timerBar ) then
		self.usedTimerBars[block][line] = nil;
		tinsert(self.freeTimerBars, timerBar);
		timerBar:Hide();
		line.TimerBar = nil;
	end
end

-- *****************************************************************************************************
-- ***** BLOCK HEADER HANDLERS
-- *****************************************************************************************************

function ObjectiveTrackerBlockHeader_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function ObjectiveTrackerBlockHeader_OnClick(self, mouseButton)
	local block = self:GetParent();
	block.module:OnBlockHeaderClick(block, mouseButton);
end

function ObjectiveTrackerBlockHeader_OnEnter(self)
	local block = self:GetParent();
	block.module:OnBlockHeaderEnter(block);
end

function ObjectiveTrackerBlockHeader_OnLeave(self)
	local block = self:GetParent();
	block.module:OnBlockHeaderLeave(block);
end

-- *****************************************************************************************************
-- ***** TIMER BARS
-- *****************************************************************************************************

function ObjectiveTrackerTimerBar_OnUpdate(self, elapsed)
	local timeNow = GetTime();
	local timeRemaining = self.duration - (timeNow - self.startTime);
	self.Bar:SetValue(timeRemaining);
	if ( timeRemaining < 0 ) then
		-- hold at 0 for a moment
		if ( timeRemaining > -1 ) then
			timeRemaining = 0;
		else
			ObjectiveTracker_Update(self.block.module.updateReasonModule);
			return;
		end
	end
	self.Label:SetText(GetTimeStringFromSeconds(timeRemaining, nil, true));
	self.Label:SetTextColor(ObjectiveTrackerTimerBar_GetTextColor(self.duration, self.duration - timeRemaining));
end

function ObjectiveTrackerTimerBar_GetTextColor(duration, elapsed)
	local START_PERCENTAGE_YELLOW = .66
	local START_PERCENTAGE_RED = .33
	
	local percentageLeft = 1 - ( elapsed / duration )
	if ( percentageLeft > START_PERCENTAGE_YELLOW ) then
		return 1, 1, 1;
	elseif ( percentageLeft > START_PERCENTAGE_RED ) then -- Start fading to yellow by eliminating blue
		local blueOffset = (percentageLeft - START_PERCENTAGE_RED) / (START_PERCENTAGE_YELLOW - START_PERCENTAGE_RED);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / START_PERCENTAGE_RED; -- Fade to red by eliminating green
		return 1, greenOffset, 0;
	end
end

-- *****************************************************************************************************
-- ***** FRAME HANDLERS
-- *****************************************************************************************************

function ObjectiveTracker_OnLoad(self)
	-- create a line so we can get some measurements
	local line = CreateFrame("Frame", nil, self, DEFAULT_OBJECTIVE_TRACKER_MODULE.lineTemplate);
	line.Text:SetText("Double line|ntest");	
	-- reuse it
	tinsert(DEFAULT_OBJECTIVE_TRACKER_MODULE.freeLines, line);
	-- get measurements
	OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT = math.ceil(line.Text:GetStringHeight());
	OBJECTIVE_TRACKER_DASH_WIDTH = line.Dash:GetWidth();
	OBJECTIVE_TRACKER_TEXT_WIDTH = OBJECTIVE_TRACKER_LINE_WIDTH - OBJECTIVE_TRACKER_DASH_WIDTH - 12;
	DEFAULT_OBJECTIVE_TRACKER_MODULE.lineWidth = OBJECTIVE_TRACKER_TEXT_WIDTH;
	DEFAULT_OBJECTIVE_TRACKER_MODULE.BlocksFrame = self.BlocksFrame;
	line.Text:SetWidth(OBJECTIVE_TRACKER_TEXT_WIDTH);

	local frameLevel = self.BlocksFrame:GetFrameLevel();
	self.HeaderMenu:SetFrameLevel(frameLevel + 2);

	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_Initialize(self.BlockDropDown, nil, "MENU");
	QuestPOI_Initialize(self.BlocksFrame, function(self) self:SetScale(0.9); self:RegisterForClicks("LeftButtonUp", "RightButtonUp"); end );
end

function ObjectiveTracker_Initialize(self)
	self.MODULES = {	SCENARIO_CONTENT_TRACKER_MODULE,
						AUTO_QUEST_POPUP_TRACKER_MODULE,
						QUEST_TRACKER_MODULE,
						BONUS_OBJECTIVE_TRACKER_MODULE,
						ACHIEVEMENT_TRACKER_MODULE,
	};
	
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("TRACKED_ACHIEVEMENT_LIST_CHANGED");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("QUEST_AUTOCOMPLETE");
	self:RegisterEvent("QUEST_ACCEPTED");	
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE");
	self:RegisterEvent("TRACKED_ACHIEVEMENT_UPDATE");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("QUEST_TURNED_IN");
	self:RegisterEvent("PLAYER_MONEY");
	self.watchMoneyReasons = 0;

	self.initialized = true;
end

function ObjectiveTracker_OnEvent(self, event, ...)
	if ( event == "QUEST_LOG_UPDATE" ) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
	elseif ( event == "TRACKED_ACHIEVEMENT_UPDATE" ) then
		AchievementObjectiveTracker_OnAchievementUpdate(...);
	elseif ( event == "QUEST_ACCEPTED" ) then
		local questLogIndex, questID = ...;
		if ( IsQuestTask(questID) ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_TASK_ADDED, questID);
		else
			if ( AUTO_QUEST_WATCH == "1" and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS ) then
				AddQuestWatch(questLogIndex);
				QuestSuperTracking_OnQuestTracked(questID);
			end
		end
	elseif ( event == "TRACKED_ACHIEVEMENT_LIST_CHANGED" ) then
		local achievementID, added = ...;
		if ( added ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED, achievementID);
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT);
		end
	elseif ( event == "QUEST_WATCH_LIST_CHANGED" ) then
		local questID, added = ...;
		if ( added ) then
			if ( not IsQuestTask(questID) ) then
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST_ADDED, questID);
			end
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_QUEST);
		end
	elseif ( event == "QUEST_POI_UPDATE" ) then
		QuestPOIUpdateIcons();
		if ( GetCVar("trackQuestSorting") == "proximity" ) then
			SortQuestWatches();
		end
		-- SortQuestWatches might not trigger a QUEST_WATCH_LIST_CHANGED due to unique signals, so force an update
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
		QuestSuperTracking_OnPOIUpdate();
	elseif ( event == "SCENARIO_CRITERIA_UPDATE" ) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO);
	elseif ( event == "SUPER_TRACKED_QUEST_CHANGED" ) then
		local questID = ...;
		QuestPOI_SelectButtonByQuestID(self.BlocksFrame, questID);
	elseif ( event == "ZONE_CHANGED" ) then
		local inMicroDungeon = IsPlayerInMicroDungeon();
		if ( inMicroDungeon ~= self.inMicroDungeon ) then
			if ( not WorldMapFrame:IsShown() and GetCVarBool("questPOI") ) then
				SetMapToCurrentZone();			-- update the zone to get the right POI numbers for the tracker
			end
			SortQuestWatches();
			self.inMicroDungeon = inMicroDungeon;
		end
	elseif ( event == "QUEST_AUTOCOMPLETE" ) then
		local questId = ...;
		AutoQuestPopupTracker_AddPopUp(questId, "COMPLETE");
	elseif ( event == "SCENARIO_UPDATE" ) then
		local newStage = ...;
		if ( newStage ) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO_NEW_STAGE);
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_SCENARIO);
		end
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		if ( not WorldMapFrame:IsShown() and GetCVarBool("questPOI") ) then
			SetMapToCurrentZone();			-- update the zone to get the right POI numbers for the tracker
		end
		SortQuestWatches();
	elseif ( event == "QUEST_TURNED_IN" ) then
		local questID, xp, money = ...;
		if ( IsQuestTask(questID) ) then
			BonusObjectiveTracker_OnTaskCompleted(...);
		end
	elseif ( event == "PLAYER_MONEY" and self.watchMoneyReasons > 0 ) then
		ObjectiveTracker_Update(self.watchMoneyReasons);	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( not self.initialized ) then
			ObjectiveTracker_Initialize(self);
		end
		ObjectiveTracker_Update();
		QuestSuperTracking_ChooseClosestQuest();
		self.inMicroDungeon = IsPlayerInMicroDungeon();
	elseif ( event == "VARIABLES_LOADED" ) then
		ObjectiveTracker_Update();
	end
end

function ObjectiveTracker_OnSizeChanged(self)
	ObjectiveTracker_Update();
end

function ObjectiveTrackerHeader_OnAnimFinished(self)
	local header = self:GetParent();
	header.animating = false;
	ObjectiveTracker_Update(header.onFinishUpdateReason);
end

-- *****************************************************************************************************
-- ***** BUTTONS
-- *****************************************************************************************************

function ObjectiveTracker_MinimizeButton_OnClick(self)
	if ( ObjectiveTrackerFrame.collapsed ) then
		ObjectiveTracker_Expand();
	else
		ObjectiveTracker_Collapse();
	end
	ObjectiveTracker_Update();
end

function ObjectiveTracker_Collapse()
	ObjectiveTrackerFrame.collapsed = true;
	ObjectiveTrackerFrame.BlocksFrame:Hide();
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5);
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5);
	ObjectiveTrackerFrame.HeaderMenu.Title:Show();	
end

function ObjectiveTracker_Expand()
	ObjectiveTrackerFrame.collapsed = nil;
	ObjectiveTrackerFrame.BlocksFrame:Show();
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1);
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1);
	ObjectiveTrackerFrame.HeaderMenu.Title:Hide();
end

function ObjectiveTracker_ToggleDropDown(frame, handlerFunc)
	local dropDown = ObjectiveTrackerBlockDropDown;
	if ( dropDown.activeFrame ~= frame ) then
		CloseDropDownMenus();
	end
	dropDown.activeFrame = frame;
	dropDown.initialize = handlerFunc;
	ToggleDropDownMenu(1, nil, dropDown, "cursor", 3, -3);
end

-- *****************************************************************************************************
-- ***** BLOCK CONTROL
-- *****************************************************************************************************

local function InternalAddBlock(block)
	local module = block.module or DEFAULT_OBJECTIVE_TRACKER_MODULE;
	local blocksFrame = module.BlocksFrame;
	block:ClearAllPoints();
	block.nextBlock = nil;
	
	local offsetY = module.blockOffsetY;
	if ( blocksFrame.currentBlock ) then
		if ( blocksFrame.currentBlock.isHeader ) then
			offsetY = module.fromHeaderOffsetY;
		end
		-- check if the block can fit
		if ( blocksFrame.contentsHeight + block.height - offsetY > blocksFrame.maxHeight ) then
			return false;
		end
		if ( block.isHeader ) then
			offsetY = offsetY + blocksFrame.currentBlock.module.fromModuleOffsetY;
			block:SetPoint("LEFT", OBJECTIVE_TRACKER_HEADER_OFFSET_X, 0);
		else
			block:SetPoint("LEFT", module.blockOffsetX, 0);		
		end
		block:SetPoint("TOP", blocksFrame.currentBlock, "BOTTOM", 0, offsetY);
	else
		offsetY = 0;
		-- check if the block can fit
		if ( blocksFrame.contentsHeight + block.height > blocksFrame.maxHeight ) then
			return false;
		end
		-- if the blocks frame is a scrollframe, attach to its scrollchild
		if ( block.isHeader ) then
			block:SetPoint("TOPLEFT", blocksFrame.ScrollContents or blocksFrame, "TOPLEFT", OBJECTIVE_TRACKER_HEADER_OFFSET_X, offsetY);
		else
			block:SetPoint("TOPLEFT", blocksFrame.ScrollContents or blocksFrame, "TOPLEFT", module.blockOffsetX, offsetY);
		end
	end

	if ( not module.firstBlock and not block.isHeader ) then
		module.firstBlock = block;
	end
	if ( blocksFrame.currentBlock ) then
		blocksFrame.currentBlock.nextBlock = block;
	end
	blocksFrame.currentBlock = block;
	blocksFrame.contentsHeight = blocksFrame.contentsHeight + block.height - offsetY;
	module.contentsAnimHeight = module.contentsAnimHeight + block.height;
	module.contentsHeight = module.contentsHeight + block.height - offsetY;
	return true;
end

function ObjectiveTracker_AddBlock(block, ignoreHeaderAnimating)
	local header = block.module.Header;
	local blockAdded = false;
	-- if there's no header or it's been added, just add the block...
	if ( not header or header.added ) then
		-- ...unless we're still animating the header
		if ( header and header.animating and not ignoreHeaderAnimating ) then
			blockAdded = false;
		else
			blockAdded = InternalAddBlock(block);
		end
	elseif ( ObjectiveTracker_CanFitBlock(block, header) ) then
		-- try to add header and maybe block
		if ( InternalAddBlock(header) ) then
			header.added = true;
			if ( not header:IsShown() ) then
				header:Show();
				if ( header.animateReason and band(OBJECTIVE_TRACKER_UPDATE_REASON, header.animateReason ) > 0 and not header.animating ) then
					-- animate stuff
					header.animating = true;
					header.HeaderOpenAnim:Play();
				end
			end
			-- if the header is not animating, we can add block
			if ( not header.animating or ignoreHeaderAnimating ) then
				blockAdded = InternalAddBlock(block);
			end
		end
	end
	if ( not blockAdded ) then
		block.module.hasSkippedBlocks = true;
	end
	return blockAdded;
end

function ObjectiveTracker_CanFitBlock(block, header)
	local module = block.module;
	local blocksFrame = module.BlocksFrame;
	local offsetY;
	if ( not blocksFrame.currentBlock ) then
		offsetY = 0;
	elseif ( blocksFrame.currentBlock.isHeader ) then
		offsetY = module.fromHeaderOffsetY;
	else
		offsetY = block.module.blockOffsetY;
	end

	local totalHeight;
	if ( header ) then
		totalHeight = header.height - offsetY + block.height - module.fromHeaderOffsetY;
	else
		totalHeight = block.height - offsetY;
	end
	return (blocksFrame.contentsHeight + totalHeight) <= blocksFrame.maxHeight;
end

-- ***** SLIDING

function ObjectiveTracker_SlideBlock(block, slideData)
	block.slideData = slideData;
	if ( slideData.startDelay ) then
		block.slideTime = -slideData.startDelay;
	else
		block.slideTime = 0;
	end
	block.slideHeight = slideData.startHeight;
	block:SetHeight(slideData.startHeight);
	block:SetScript("OnUpdate", ObjectiveTracker_OnSlideBlockUpdate);
end

function ObjectiveTracker_EndSlideBlock(block)
	block:SetScript("OnUpdate", nil);
	block:SetHeight(block.slideData.endHeight);
	if ( block.slideData.scroll ) then
		block:SetVerticalScroll(0);
	end
end

function ObjectiveTracker_OnSlideBlockUpdate(block, elapsed)
	local slideData = block.slideData;

	block.slideTime = block.slideTime + elapsed;
	if ( block.slideTime <= 0 ) then
		return;
	end
	
	height = floor(slideData.startHeight + (slideData.endHeight - slideData.startHeight) * (min(block.slideTime, slideData.duration) / slideData.duration));
	if ( height ~= block.slideHeight ) then
		block.slideHeight = height;
		block:SetHeight(height);
		if ( slideData.scroll ) then
			block:UpdateScrollChildRect();
			-- scrolling means the bottom of the content comes in first or leaves last
			block:SetVerticalScroll(max(slideData.endHeight, slideData.startHeight) - height);
		end
	end

	if ( block.slideTime >= slideData.duration + (slideData.endDelay or 0) ) then
		block:SetScript("OnUpdate", nil);
		if ( slideData.onFinishFunc ) then
			slideData.onFinishFunc(block);
		end
	end
end

-- ***** UPDATE

function DEFAULT_OBJECTIVE_TRACKER_MODULE:StaticReanchor()
	local block = self.firstBlock;
	self:BeginLayout(true);
	while ( block ) do
		if ( block.module == self ) then
			local nextBlock = block.nextBlock;
			if ( ObjectiveTracker_AddBlock(block) ) then
				block.used = true;			
				block:Show();
				block = nextBlock;
			else
				-- a prior module reduced the previously available space
				block.used = false;
				block:Hide();
				break;
			end
		else
			break;
		end
	end
	self:EndLayout(true);
end

function ObjectiveTrackerFrame_OnUpdate(self, elapsed)
	if ( self:GetHeight() > 0 ) then
		self:SetScript("OnUpdate", nil);
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ALL);
	end
end

function ObjectiveTracker_Update(reason, id)
	local tracker = ObjectiveTrackerFrame;

	if ( not tracker.initialized ) then
		return;
	end

	tracker.BlocksFrame.maxHeight = ObjectiveTrackerFrame.BlocksFrame:GetHeight();
	if ( tracker.BlocksFrame.maxHeight == 0 ) then
		tracker:SetScript("OnUpdate", ObjectiveTrackerFrame_OnUpdate);
		return;
	end

	OBJECTIVE_TRACKER_UPDATE_REASON = reason or OBJECTIVE_TRACKER_UPDATE_ALL;
	OBJECTIVE_TRACKER_UPDATE_ID = id;

	tracker.BlocksFrame.currentBlock = nil;
	tracker.BlocksFrame.contentsHeight = 0;

	-- mark headers unused
	for i = 1, #tracker.MODULES do
		if ( tracker.MODULES[i].Header ) then
			tracker.MODULES[i].Header.added = nil;
		end
	end

	-- run module updates
	local gotMoreRoomThisPass = false;
	for i = 1, #tracker.MODULES do
		local module = tracker.MODULES[i];
		if ( band(OBJECTIVE_TRACKER_UPDATE_REASON, module.updateReasonModule + module.updateReasonEvents ) > 0 ) then
			-- run a full update on this module
			module:Update();
			-- check if it's now taking up less space, using subtraction because of floats
			if ( module.oldContentsHeight - module.contentsHeight >= 1 ) then
				-- it is taking up less space, might have freed room for other modules
				gotMoreRoomThisPass = true;
			end
		else
			-- this module's contents have not have changed
			-- but if we got more room and this module has unshown content, do a full update
			-- also do a full update if the header is animating since the module does not technically have any blocks at that point
			if ( (module.hasSkippedBlocks and gotMoreRoomThisPass) or (module.Header and module.Header.animating) ) then
				module:Update();			
			else
				module:StaticReanchor();
			end
		end
	end

	-- hide unused headers
	for i = 1, #tracker.MODULES do
		ObjectiveTracker_CheckAndHideHeader(tracker.MODULES[i].Header);
	end

	if ( tracker.BlocksFrame.currentBlock ) then
		tracker.HeaderMenu:Show();
	else
		tracker.HeaderMenu:Hide();
	end
end

function ObjectiveTracker_CheckAndHideHeader(moduleHeader)
	if ( moduleHeader and not moduleHeader.added and moduleHeader:IsShown() ) then
		moduleHeader:Hide();
		if ( moduleHeader.animating ) then
			moduleHeader.animating = nil;
			moduleHeader.HeaderOpenAnim:Stop();
		end
	end
end

function ObjectiveTracker_WatchMoney(watchMoney, reason)
	if ( watchMoney ) then
		if ( band(ObjectiveTrackerFrame.watchMoneyReasons, reason) == 0 ) then
			ObjectiveTrackerFrame.watchMoneyReasons = ObjectiveTrackerFrame.watchMoneyReasons + reason;
		end
	else
		if ( band(ObjectiveTrackerFrame.watchMoneyReasons, reason) > 0 ) then
			ObjectiveTrackerFrame.watchMoneyReasons = ObjectiveTrackerFrame.watchMoneyReasons - reason;
		end
	end
end