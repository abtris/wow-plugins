VUHDO_PANEL_MODELS = {};
VUHDO_PANEL_DYN_MODELS = {};

local tinsert = tinsert;
local tremove = tremove;
local twipe = table.wipe;
local ceil = ceil;
local pairs = pairs;
local _ = _;
local sCnt;



--
local VUHDO_PANEL_SETUP;

local VUHDO_getGroupMembers;
function VUHDO_modelToolsInitBurst()
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];

	VUHDO_getGroupMembers = VUHDO_GLOBAL["VUHDO_getGroupMembers"];
end



--
local tModelArray, tKey;
function VUHDO_clearUndefinedModelEntries()
	for _, tModelArray in pairs(VUHDO_PANEL_MODELS) do
		for sCnt = 15, 1, -1 do -- VUHDO_MAX_GROUPS_PER_PANEL
			if (tModelArray[sCnt] == 0) then -- VUHDO_ID_UNDEFINED
				tremove(tModelArray, sCnt);
			end
		end
	end

	for tKey, tModelArray in pairs(VUHDO_PANEL_MODELS) do
		if (#(tModelArray or {}) == 0) then
			VUHDO_PANEL_MODELS[tKey] = nil;
		end
	end
end



--
function VUHDO_initPanelModels()
	for sCnt = 1, 10 do -- VUHDO_MAX_PANELS
		VUHDO_PANEL_MODELS[sCnt] = VUHDO_PANEL_SETUP[sCnt]["MODEL"]["groups"];
	end
end



--
local tIsShowModel;
local tIsOmitEmpty;
local tPanelNum, tModelArray;
local tModelId;
local tMaxRows, tNumModels, tRepeatModels;
function VUHDO_initDynamicPanelModels()
	if (VUHDO_isConfigPanelShowing()) then
		VUHDO_PANEL_DYN_MODELS = VUHDO_deepCopyTable(VUHDO_PANEL_MODELS);
		return;
	end

	twipe(VUHDO_PANEL_DYN_MODELS);

	for tPanelNum, tModelArray in pairs(VUHDO_PANEL_MODELS) do
		tIsOmitEmpty = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["ommitEmptyWhenStructured"];
		VUHDO_PANEL_DYN_MODELS[tPanelNum] = {};
		tMaxRows = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"]["maxRowsWhenLoose"];

		for _, tModelId in pairs(tModelArray) do
			tNumModels = #VUHDO_getGroupMembers(tModelId);
			if (not tIsOmitEmpty or tNumModels > 0) then

				tRepeatModels = ceil(tNumModels / tMaxRows);
				if (tRepeatModels == 0) then
					tRepeatModels = 1;
				end

				for _ = 1, tRepeatModels do
					tinsert(VUHDO_PANEL_DYN_MODELS[tPanelNum], tModelId);
				end
			end
		end

	end
end

