-------------------------------------------------------------------------------------------------------
-- Overall Quality
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_Quality"]={
	name = OVERALL_QUALITY;
	data = {
		[1] = {
			text = VIDEO_QUALITY_LABEL1,
			tooltip = VIDEO_QUALITY_SUBTEXT1,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_LOW,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_LOW,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_LOW,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_LOW,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_LOW,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_LOW,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_BILINEAR,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_LOW,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_DISABLED,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_DISABLED,
				Graphics_SSAODropDown = VIDEO_OPTIONS_DISABLED,
			},
		},
		[2] = {
			text = VIDEO_QUALITY_LABEL2,
			tooltip = VIDEO_QUALITY_SUBTEXT2,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_LOW,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_TRILINEAR,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_DISABLED,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_DISABLED,
				Graphics_SSAODropDown = VIDEO_OPTIONS_DISABLED,
			},
		},
		[3] = {
			text = VIDEO_QUALITY_LABEL3,
			tooltip = VIDEO_QUALITY_SUBTEXT3,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_4XANISOTROPIC,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_LOW,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
				Graphics_SSAODropDown = VIDEO_OPTIONS_LOW,
			},
		},
		[4] = {
			text = VIDEO_QUALITY_LABEL4,
			tooltip = VIDEO_QUALITY_SUBTEXT4,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_8XANISOTROPIC,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
				Graphics_SSAODropDown = VIDEO_OPTIONS_HIGH,
			},
		},
		[5] = {
			text = VIDEO_QUALITY_LABEL5,
			tooltip = VIDEO_QUALITY_SUBTEXT5,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_16XANISOTROPIC,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
				Graphics_SSAODropDown = VIDEO_OPTIONS_ULTRA,
			},
		},
	},
	SetDisplayValue = 
		function(self,value)
		end,
	preGetValue = 
		function(self)
			self.selectedID = nil;
		end,
	GetValueNew = 
		function(self)
			if(self.preGetValue) then
				self:preGetValue();
			end
			if(self.selectedID == nil) then
				self.selectedID = (self.doGetValue or Graphics_TableGetValue)(self);
			end
			return self.selectedID;
		end,
	GetCurrentValue =
		function(self)
			local value = self:GetValue();
			return value;
		end,
	description =  "Video Quality:",
	dependtarget = Graphics_ControlRefreshValue,
	initialize = 
		function(self)
			self:SetBackdrop({bgFile = "Interface\\Buttons\\UI-SliderBar-Background", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", tile = true, tileSize = 8, edgeSize = 8, pieces=93, insets = { left = 3, right = 3, top = 6, bottom = 6 } } );
			local parent = self:GetParent():GetName();
			local name = self:GetName();

			_G[name.."Text"]:SetFontObject("OptionsFontSmall");
			_G[name.."Low"]:Hide();
			_G[name.."High"]:Hide();

			local fullwidth = _G[parent .."GraphicsHeaderUnderline"]:GetWidth() - 20;
			self.noclick = true;
			self:SetWidth(fullwidth);
			if(not self.isdependtarget) then
				self:setinitialslider();
			end
			self:updatecustomfield(self:GetValue());
			self.noclick = false;
		end,
	setinitialslider = function(self)
		self.noclick = true;
		if (self.raid) then
			RaidGraphics_Quality:SetValue(BlizzardOptionsPanel_GetCVarSafe("raidGraphicsQuality"));	-- set the slider only
		else
			Graphics_Quality:SetValue(BlizzardOptionsPanel_GetCVarSafe("graphicsQuality"));	-- set the slider only
		end
		self.noclick = false;
	end,
	onload = function(self)
		self.sliderGetValue = self.GetValue;
		self.GetValue = self.GetValueNew;
		self:setinitialslider();
	end,
	updatecustomfield =
		function(self, value)
			if(value > #self.data) then
				_G["Graphics_RightQualityLabel"]:Show();
			else
				self.noclick = true;
				Graphics_Quality:SetValue(value);	-- set the slider only
				self.noclick = false;
				if ( self:GetValue() > #self.data ) then
					_G["Graphics_RightQualityLabel"]:Show();
				else
					_G["Graphics_RightQualityLabel"]:Hide();
				end
			end
		end,
	onvaluechanged = 
		function(self, value)
			value = floor(value + 0.5);
			self.savevalue = value;
			if(not self.noclick) then
				VideoOptions_OnClick(self, value);
				self:updatecustomfield(value);
			end
		end,
	commitslider =
		function(self)
			local value = self:GetValue();
			if(value > #self.data) then
				value = self:sliderGetValue();
			end
			local graphicsQualityCVar = "graphicsQuality";
			if (self.raid) then
				graphicsQualityCVar = "RaidGraphicsQuality";
			end
			BlizzardOptionsPanel_SetCVarSafe(graphicsQualityCVar, value);
		end,
}

VideoData["RaidGraphics_Quality"] = {};
setmetatable( VideoData["RaidGraphics_Quality"], {__index = VideoData["Graphics_Quality"]});
VideoData["RaidGraphics_Quality"].data = {
	[1] = {
		text = VIDEO_QUALITY_LABEL1,
		tooltip = VIDEO_QUALITY_SUBTEXT1,
		notify = {
			RaidGraphics_ViewDistanceDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_ParticleDensityDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_GroundClutterDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_ShadowsDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_TextureResolutionDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_FilteringDropDown = VIDEO_OPTIONS_BILINEAR,
			RaidGraphics_LiquidDetailDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_SunshaftsDropDown = VIDEO_OPTIONS_DISABLED,
			RaidGraphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_DISABLED,
			RaidGraphics_SSAODropDown = VIDEO_OPTIONS_DISABLED,
		},
	},
	[2] = {
		text = VIDEO_QUALITY_LABEL2,
		tooltip = VIDEO_QUALITY_SUBTEXT2,
		notify = {
			RaidGraphics_ViewDistanceDropDown = VIDEO_OPTIONS_FAIR,
			RaidGraphics_ParticleDensityDropDown = VIDEO_OPTIONS_FAIR,
			RaidGraphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_FAIR,
			RaidGraphics_GroundClutterDropDown = VIDEO_OPTIONS_FAIR,
			RaidGraphics_ShadowsDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_TextureResolutionDropDown = VIDEO_OPTIONS_FAIR,
			RaidGraphics_FilteringDropDown = VIDEO_OPTIONS_TRILINEAR,
			RaidGraphics_LiquidDetailDropDown = VIDEO_OPTIONS_FAIR,
			RaidGraphics_SunshaftsDropDown = VIDEO_OPTIONS_DISABLED,
			RaidGraphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_DISABLED,
			RaidGraphics_SSAODropDown = VIDEO_OPTIONS_DISABLED,
		},
	},
	[3] = {
		text = VIDEO_QUALITY_LABEL3,
		tooltip = VIDEO_QUALITY_SUBTEXT3,
		notify = {
			RaidGraphics_ViewDistanceDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_ParticleDensityDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_GroundClutterDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_ShadowsDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_TextureResolutionDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_FilteringDropDown = VIDEO_OPTIONS_4XANISOTROPIC,
			RaidGraphics_LiquidDetailDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_SunshaftsDropDown = VIDEO_OPTIONS_LOW,
			RaidGraphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
			RaidGraphics_SSAODropDown = VIDEO_OPTIONS_LOW,
		},
	},
	[4] = {
		text = VIDEO_QUALITY_LABEL4,
		tooltip = VIDEO_QUALITY_SUBTEXT4,
		notify = {
			RaidGraphics_ViewDistanceDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_ParticleDensityDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_GroundClutterDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_ShadowsDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_FilteringDropDown = VIDEO_OPTIONS_8XANISOTROPIC,
			RaidGraphics_LiquidDetailDropDown = VIDEO_OPTIONS_MEDIUM,
			RaidGraphics_SunshaftsDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
			RaidGraphics_SSAODropDown = VIDEO_OPTIONS_HIGH,
		},
	},
	[5] = {
		text = VIDEO_QUALITY_LABEL5,
		tooltip = VIDEO_QUALITY_SUBTEXT5,
		notify = {
			RaidGraphics_ViewDistanceDropDown = VIDEO_OPTIONS_ULTRA,
			RaidGraphics_ParticleDensityDropDown = VIDEO_OPTIONS_ULTRA,
			RaidGraphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_ULTRA,
			RaidGraphics_GroundClutterDropDown = VIDEO_OPTIONS_ULTRA,
			RaidGraphics_ShadowsDropDown = VIDEO_OPTIONS_ULTRA,
			RaidGraphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_FilteringDropDown = VIDEO_OPTIONS_16XANISOTROPIC,
			RaidGraphics_LiquidDetailDropDown = VIDEO_OPTIONS_ULTRA,
			RaidGraphics_SunshaftsDropDown = VIDEO_OPTIONS_HIGH,
			RaidGraphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
			RaidGraphics_SSAODropDown = VIDEO_OPTIONS_ULTRA,
		},
	},
};
VideoData["RaidGraphics_Quality"].updatecustomfield =
	function(self, value)
		if(value > #self.data) then
			_G["RaidGraphics_RightQualityLabel"]:Show();
		else
			self.noclick = true;
			RaidGraphics_Quality:SetValue(value);	-- set the slider only
			self.noclick = false;
			if ( self:GetValue() > #self.data ) then
				_G["RaidGraphics_RightQualityLabel"]:Show();
			else
				_G["RaidGraphics_RightQualityLabel"]:Hide();
			end
		end
	end;

-------------------------------------------------------------------------------------------------------
-- Display
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_DisplayModeDropDown"]={
	name = DISPLAY_MODE;
	description = OPTION_TOOLTIP_DISPLAY_MODE,
	dataA = {
		[1] = {
			text = VIDEO_OPTIONS_WINDOWED,
			cvars =	{
				gxWindow = 1,
				gxMaximize = 0,
			},
			windowed = true;
			fullscreen = false;
		},
		[2] = {
			text = VIDEO_OPTIONS_WINDOWED_FULLSCREEN,
			cvars =	{
				gxWindow = 1,
				gxMaximize = 1,
			},
			windowed = true;
			fullscreen = true;
		},
		[3] = {
			text = VIDEO_OPTIONS_FULLSCREEN,
			cvars =	{
				gxWindow = 0,
				gxMaximize = 0,
			},
			windowed = false;
			fullscreen = true;
		},
	},
	dataB = {
		[1] = {
			text = VIDEO_OPTIONS_WINDOWED,
			cvars =	{
				gxWindow = 1,
				gxMaximize = 0,
			},
			windowed = true;
			fullscreen = false;
		},
	},
	onload =
		function(self)
			self.data = self.dataA;
		end,
	onrefresh =
		function(self)
			if(Graphics_PrimaryMonitorDropDown:landscape()) then
				self.data = self.dataA;
			else
				self.data = self.dataB;
			end
		end,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable;
	dependent = {
		"Graphics_ResolutionDropDown",
		"Graphics_RefreshDropDown",
		"Advanced_GammaSlider",
	},
	GetSafeValue =
		function(self)
			local value = self:GetValue();
			return  (value <= #self.data) and value or 1;
		end,
	windowedmode =
		function(self)
			return self.data[self:GetSafeValue()].windowed;
		end,
	fullscreenmode =
		function(self)
			return self.data[self:GetSafeValue()].fullscreen;
		end,
	lookup = Graphics_TableLookupSafe,
	restart = true,
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_PrimaryMonitorDropDown"]={
	name = PRIMARY_MONITOR;
	description = OPTION_TOOLTIP_PRIMARY_MONITOR,
	
	table = {},
	tablefunction = 
		function(self)
			local count = GetMonitorCount();
			for i=1, count do
				local name = GetMonitorName(i);
				if(not name) then
					if(i == 1) then
						name = VIDEO_OPTIONS_MONITOR_PRIMARY;
					else
						name = string.format(VIDEO_OPTIONS_MONITOR, i-1);
					end
				end
				self.table[i] = name;
			end
		end,
	SetValue = 
		function (self, value)
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value-1);
		end,
	doGetValue = 
		function (self)
			return 1+BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end,
	cvar = "gxMonitor",
	dependent = {
		"Graphics_DisplayModeDropDown",
		"Graphics_ResolutionDropDown",	--resolutions may disappear when we change the monitor
		"Graphics_RefreshDropDown",
		"Advanced_GammaSlider",
	},
	landscape =
		function(self)
			local ratio = GetMonitorAspectRatio(self:GetValue());
			return (ratio>=1.0);
		end,
	clientRestart = true,
}

-------------------------------------------------------------------------------------------------------

-- helper function to deal with decoding the resolution string
function DecodeResolution(valueString)
	if(valueString == nil) then
		return 0,0;
	end
	local xIndex = strfind(valueString, "x");
	local width = strsub(valueString, 1, xIndex-1);
	local height = strsub(valueString, xIndex+1, strlen(valueString));
	local widthIndex = strfind(height, " ");
	if (widthIndex ~= nil) then
		height = strsub(height, 0, widthIndex-1);
	end
	return tonumber(width), tonumber(height);
end

VideoData["Graphics_ResolutionDropDown"]={
	name = RESOLUTION;
	description = OPTION_TOOLTIP_RESOLUTION,	
	
	tablefunction = 
		function(self)
			return GetScreenResolutions(Graphics_PrimaryMonitorDropDown:GetValue());
		end,
	getValues = 
		function(self)
			return DecodeResolution(self.table[self:GetValue()]);
		end,
	readfilter =
		function(self, value)
			local width, height = DecodeResolution(value);
			if ( width/height > 4/3 ) then
				value = value.." ".. WIDESCREEN_TAG;
			end
			return value;
		end,
	SetValue =
		function (self, value)
			local width, height = DecodeResolution(self.table[value]);
			SetScreenResolution(width, height);
		end,
	doGetValue = 
		function(self)
			return GetCurrentResolution(Graphics_PrimaryMonitorDropDown:GetValue());
		end,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable,
	dependent = {
		"Graphics_RefreshDropDown"
	},
	onrefresh =
	function(self)
		if(Graphics_DisplayModeDropDown:windowedmode() and Graphics_DisplayModeDropDown:fullscreenmode()) then
			VideoOptions_Disable(self);
		else
			VideoOptions_Enable(self);
		end
	end,
	lookup = Graphics_TableLookupSafe,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_RefreshDropDown"]={
	name = REFRESH_RATE;
	description = OPTION_TOOLTIP_REFRESH_RATE,
	
	TABLENEXT = 2;
	tablefunction = 
		function()
			-- get refresh rates for the currently selected resolution
			local x, y = Graphics_ResolutionDropDown:getValues();
			local monitor = Graphics_PrimaryMonitorDropDown:GetValue();
			return GetRefreshRates(x, y, monitor);
		end,
	readfilter =
		function(self, numer, denom)
			return string.format("%.1f", numer / denom) .. HERTZ;
		end,
	SetValue = 
		function (self, value)
			local x, y = Graphics_ResolutionDropDown:getValues();
			local monitor = Graphics_PrimaryMonitorDropDown:GetValue();
			SetRefresh(value, x, y, monitor);
		end,
	doGetValue = 
		function ()
			local x, y = Graphics_ResolutionDropDown:getValues();
			local monitor = Graphics_PrimaryMonitorDropDown:GetValue();
			return GetCurrentRefresh(x, y, monitor);
		end,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable,
	onrefresh =
		function(self)
			if(Graphics_DisplayModeDropDown:windowedmode()) then
				VideoOptions_Disable(self);
			else
				VideoOptions_Enable(self);
			end
		end,
	lookup = Graphics_TableLookupSafe,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_VerticalSyncDropDown"]={
	name = VERTICAL_SYNC;
	description = OPTION_TOOLTIP_VERTICAL_SYNC,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxVSync = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxVSync = 1,
			},
		},
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_AntiAliasingDropDown"]={
	name = ANTIALIASING;
	description = OPTION_TOOLTIP_ANTIALIASING,
	
	dataA = {
		[1] = {
			text = VIDEO_OPTIONS_NONE,
			cvars =	{
				ffxAntiAliasingMode = 0,
			},
		},
		[2] = {
			text = ANTIALIASING_FXAA_LOW,
			cvars =	{
				ffxAntiAliasingMode = 2,
			},
		},
		[3] = {
			text = ANTIALIASING_FXAA_HIGH,
			cvars =	{
				ffxAntiAliasingMode = 1,
			},
		},
		[4] = {
			text = ANTIALIASING_CMAA,
			cvars =	{
				ffxAntiAliasingMode = 3,
			},
		},
	},
	dataB = {
		[1] = {
			text = VIDEO_OPTIONS_NONE,
			cvars =	{
				ffxAntiAliasingMode = 0,
			},
		},
		[2] = {
			text = ANTIALIASING_FXAA_LOW,
			cvars =	{
				ffxAntiAliasingMode = 2,
			},
		},
		[3] = {
			text = ANTIALIASING_FXAA_HIGH,
			cvars =	{
				ffxAntiAliasingMode = 1,
			},
		},
	},
	dataC = {
		[1] = {
			text = VIDEO_OPTIONS_NONE,
			cvars =	{
				ffxAntiAliasingMode = 0,
			},
		},
		[4] = {
			text = ANTIALIASING_CMAA,
			cvars =	{
				ffxAntiAliasingMode = 3,
			},
		},
	},
	dataD = {
		[1] = {
			text = VIDEO_OPTIONS_NONE,
			cvars =	{
				ffxAntiAliasingMode = 0,
			},
		},
	},
	onload =
		function(self)
			self.data = self.dataA;
		end,
	onrefresh =
		function(self)
			local fxaa, cmaa = AntiAliasingSupported();
			if(fxaa and cmaa) then
				self.data = self.dataA;
			elseif(fxaa) then
				self.data = self.dataB;
			elseif(cmaa) then
				self.data = self.dataC;
			else
				self.data = self.dataD;
			end
		end,
}

-------------------------------------------------------------------------------------------------------
-- Graphics
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_ViewDistanceDropDown"]={
	name = FARCLIP;
	description = OPTION_TOOLTIP_FARCLIP,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				farClip = GetDefaultVideoQualityOption("farClip", 0),
				wmoLodDist =  GetDefaultVideoQualityOption("wmoLodDist", 0),
				terrainLodDist = GetDefaultVideoQualityOption("terrainLodDist", 0),
				terrainTextureLod = GetDefaultVideoQualityOption("terrainTextureLod", 0),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				farClip = GetDefaultVideoQualityOption("farClip", 1, 600),
				wmoLodDist =  GetDefaultVideoQualityOption("wmoLodDist", 1, 300),
				terrainLodDist = GetDefaultVideoQualityOption("terrainLodDist", 1, 300),
				terrainTextureLod = GetDefaultVideoQualityOption("terrainTextureLod", 1, 1),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				farClip =  GetDefaultVideoQualityOption("farClip", 2, 800),
				wmoLodDist = GetDefaultVideoQualityOption("wmoLodDist", 2, 400),
				terrainLodDist = GetDefaultVideoQualityOption("terrainLodDist", 2, 450),
				terrainTextureLod = GetDefaultVideoQualityOption("terrainTextureLod", 2, 1),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				farClip = GetDefaultVideoQualityOption("farClip", 3, 1000),
				wmoLodDist = GetDefaultVideoQualityOption("wmoLodDist", 3, 500),
				terrainLodDist = GetDefaultVideoQualityOption("terrainLodDist", 3, 500),
				terrainTextureLod = GetDefaultVideoQualityOption("terrainTextureLod", 3, 0),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				farClip = GetDefaultVideoQualityOption("farClip", 4, 1300),
				wmoLodDist = GetDefaultVideoQualityOption("wmoLodDist", 4, 650),
				terrainLodDist = GetDefaultVideoQualityOption("terrainLodDist", 4, 650),
				terrainTextureLod = GetDefaultVideoQualityOption("terrainTextureLod", 4, 0),
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ViewDistanceDropDown"]={
	name = FARCLIP;
	description = OPTION_TOOLTIP_FARCLIP,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidfarclip = GetDefaultVideoQualityOption("raidfarclip", 0, 200, true),
				raidWmoLodDist =  GetDefaultVideoQualityOption("raidWmoLodDist", 0, 100, true),
				raidTerrainLodDist = GetDefaultVideoQualityOption("raidTerrainLodDist", 0, 200, true),
				raidTerrainTextureLod = GetDefaultVideoQualityOption("raidTerrainTextureLod", 0, 1, true),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidfarclip = GetDefaultVideoQualityOption("raidfarclip", 1, 600, true),
				raidWmoLodDist =  GetDefaultVideoQualityOption("raidWmoLodDist", 1, 300, true),
				raidTerrainLodDist = GetDefaultVideoQualityOption("raidTerrainLodDist", 1, 300, true),
				raidTerrainTextureLod = GetDefaultVideoQualityOption("raidTerrainTextureLod", 1, 1, true),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidfarclip =  GetDefaultVideoQualityOption("raidfarclip", 2, 800, true),
				raidWmoLodDist = GetDefaultVideoQualityOption("raidWmoLodDist", 2, 400, true),
				raidTerrainLodDist = GetDefaultVideoQualityOption("raidTerrainLodDist", 2, 450, true),
				raidTerrainTextureLod = GetDefaultVideoQualityOption("raidTerrainTextureLod", 2, 1, true),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidfarclip = GetDefaultVideoQualityOption("raidfarclip", 3, 1000, true),
				raidWmoLodDist = GetDefaultVideoQualityOption("raidWmoLodDist", 3, 500, true),
				raidTerrainLodDist = GetDefaultVideoQualityOption("raidTerrainLodDist", 3, 500, true),
				raidTerrainTextureLod = GetDefaultVideoQualityOption("raidTerrainTextureLod", 3, 0, true),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidfarclip = GetDefaultVideoQualityOption("raidfarclip", 4, 1300, true),
				raidWmoLodDist = GetDefaultVideoQualityOption("raidWmoLodDist", 4, 650, true),
				raidTerrainLodDist = GetDefaultVideoQualityOption("raidTerrainLodDist", 4, 650, true),
				raidTerrainTextureLod = GetDefaultVideoQualityOption("raidTerrainTextureLod", 4, 0, true),
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterDropDown"]={
	name= GROUND_CLUTTER;
	description = OPTION_TOOLTIP_GROUND_CLUTTER,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				groundEffectDist =  GetDefaultVideoQualityOption("groundEffectDist", 0, 70),
				groundEffectDensity = GetDefaultVideoQualityOption("groundEffectDensity", 0, 16),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				groundEffectDist =  GetDefaultVideoQualityOption("groundEffectDist", 1, 110),
				groundEffectDensity = GetDefaultVideoQualityOption("groundEffectDensity", 1, 40),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				groundEffectDist =  GetDefaultVideoQualityOption("groundEffectDist", 2, 160),
				groundEffectDensity = GetDefaultVideoQualityOption("groundEffectDensity", 2, 64),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				groundEffectDist =  GetDefaultVideoQualityOption("groundEffectDist", 3, 200),
				groundEffectDensity = GetDefaultVideoQualityOption("groundEffectDensity", 3, 80),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				groundEffectDist =  GetDefaultVideoQualityOption("groundEffectDist", 4, 260),
				groundEffectDensity = GetDefaultVideoQualityOption("groundEffectDensity", 4, 128),
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_GroundClutterDropDown"]={
	name= GROUND_CLUTTER;
	description = OPTION_TOOLTIP_GROUND_CLUTTER,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidgroundEffectDist =  GetDefaultVideoQualityOption("raidgroundEffectDist", 0, 70, true),
				raidgroundEffectDensity = GetDefaultVideoQualityOption("raidgroundEffectDensity", 0, 16, true),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidgroundEffectDist =  GetDefaultVideoQualityOption("raidgroundEffectDist", 1, 110, true),
				raidgroundEffectDensity = GetDefaultVideoQualityOption("raidgroundEffectDensity", 1, 40, true),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidgroundEffectDist =  GetDefaultVideoQualityOption("raidgroundEffectDist", 2, 160, true),
				raidgroundEffectDensity = GetDefaultVideoQualityOption("raidgroundEffectDensity", 2, 64, true),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidgroundEffectDist =  GetDefaultVideoQualityOption("raidgroundEffectDist", 3, 200, true),
				raidgroundEffectDensity = GetDefaultVideoQualityOption("raidgroundEffectDensity", 3, 80, true),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidgroundEffectDist =  GetDefaultVideoQualityOption("raidgroundEffectDist", 4, 260, true),
				raidgroundEffectDensity = GetDefaultVideoQualityOption("raidgroundEffectDensity", 4, 128, true),
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_EnvironmentalDetailDropDown"]={
	name = ENVIRONMENT_DETAIL;
	description = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				environmentDetail = GetDefaultVideoQualityOption("environmentDetail", 0, 50),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				environmentDetail = GetDefaultVideoQualityOption("environmentDetail", 1, 75),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				environmentDetail = GetDefaultVideoQualityOption("environmentDetail", 2, 100),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				environmentDetail = GetDefaultVideoQualityOption("environmentDetail", 3, 125),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				environmentDetail = GetDefaultVideoQualityOption("environmentDetail", 4, 150),
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_EnvironmentalDetailDropDown"]={
	name = ENVIRONMENT_DETAIL;
	description = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidEnvironmentDetail = GetDefaultVideoQualityOption("raidEnvironmentDetail", 0, 50, true),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidEnvironmentDetail = GetDefaultVideoQualityOption("raidEnvironmentDetail", 1, 75, true),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidEnvironmentDetail = GetDefaultVideoQualityOption("raidEnvironmentDetail", 2, 100, true),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidEnvironmentDetail = GetDefaultVideoQualityOption("raidEnvironmentDetail", 3, 125, true),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidEnvironmentDetail = GetDefaultVideoQualityOption("raidEnvironmentDetail", 4, 150, true),
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				particleDensity = GetDefaultVideoQualityOption("particleDensity", 0, 10),
				weatherDensity = GetDefaultVideoQualityOption("weatherDensity", 0, 0),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				particleDensity = GetDefaultVideoQualityOption("particleDensity", 1, 40),
				weatherDensity = GetDefaultVideoQualityOption("weatherDensity", 1, 1),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				particleDensity = GetDefaultVideoQualityOption("particleDensity", 2, 60),
				weatherDensity = GetDefaultVideoQualityOption("weatherDensity", 2, 1),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				particleDensity = GetDefaultVideoQualityOption("particleDensity", 3, 80),
				weatherDensity = GetDefaultVideoQualityOption("weatherDensity", 3, 2),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				particleDensity = GetDefaultVideoQualityOption("particleDensity", 4, 100),
				weatherDensity = GetDefaultVideoQualityOption("weatherDensity", 4, 3),
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidParticleDensity = GetDefaultVideoQualityOption("raidParticleDensity", 0, 10, true),
				raidWeatherDensity = GetDefaultVideoQualityOption("raidWeatherDensity", 0, 0, true),
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidParticleDensity = GetDefaultVideoQualityOption("raidParticleDensity", 1, 40, true),
				raidWeatherDensity = GetDefaultVideoQualityOption("raidWeatherDensity", 1, 1, true),
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidParticleDensity = GetDefaultVideoQualityOption("raidParticleDensity", 2, 60, true),
				raidWeatherDensity = GetDefaultVideoQualityOption("weatherDensity", 2, 1, true),
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidParticleDensity = GetDefaultVideoQualityOption("raidParticleDensity", 3, 80, true),
				raidWeatherDensity = GetDefaultVideoQualityOption("weatherDensity", 3, 2, true),
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidParticleDensity = GetDefaultVideoQualityOption("raidParticleDensity", 4, 100, true),
				raidWeatherDensity = GetDefaultVideoQualityOption("raidWeatherDensity", 4, 3, true),
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SSAODropDown"]={
	name = SSAO_LABEL;
	description = OPTION_TOOLTIP_SSAO,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				ssao = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				ssao = 2,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				ssao = 1,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				ssao = 3,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_SSAODropDown"]={
	name = SSAO_LABEL;
	description = OPTION_TOOLTIP_SSAO,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				raidSSAO = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidSSAO = 2,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidSSAO = 1,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidSSAO = 3,
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ShadowsDropDown"]={
	name = SHADOW_QUALITY;
	description = OPTION_TOOLTIP_SHADOW_QUALITY,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				shadowMode = GetDefaultVideoQualityOption("shadowMode", 0, 0),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_LOW;
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				shadowMode = GetDefaultVideoQualityOption("shadowMode", 1, 1),
				shadowTextureSize = GetDefaultVideoQualityOption("shadowTextureSize", 1, 1024),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_FAIR;
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				shadowMode = GetDefaultVideoQualityOption("shadowMode", 2, 1),
				shadowTextureSize = GetDefaultVideoQualityOption("shadowTextureSize", 2, 2048),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM;
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				shadowMode = GetDefaultVideoQualityOption("shadowMode", 3, 2),
				shadowTextureSize = GetDefaultVideoQualityOption("shadowTextureSize", 3, 2048),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_HIGH;
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				shadowMode = GetDefaultVideoQualityOption("shadowMode", 4, 3),
				shadowTextureSize = GetDefaultVideoQualityOption("shadowTextureSize", 4, 2048),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA;
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ShadowsDropDown"]={
	name = SHADOW_QUALITY;
	description = OPTION_TOOLTIP_SHADOW_QUALITY,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidshadowMode = GetDefaultVideoQualityOption("raidshadowMode", 0, 0, true),
				raidShadowTextureSize = GetDefaultVideoQualityOption("raidShadowTextureSize", 1, 1024, true),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_LOW;
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidshadowMode = GetDefaultVideoQualityOption("raidshadowMode", 1, 1, true),
				raidShadowTextureSize = GetDefaultVideoQualityOption("raidShadowTextureSize", 1, 1024, true),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_FAIR;
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidshadowMode = GetDefaultVideoQualityOption("raidshadowMode", 2, 1, true),
				raidShadowTextureSize = GetDefaultVideoQualityOption("raidShadowTextureSize", 2, 2048, true),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM;
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidshadowMode = GetDefaultVideoQualityOption("raidshadowMode", 3, 2, true),
				raidShadowTextureSize = GetDefaultVideoQualityOption("raidShadowTextureSize", 3, 2048, true),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_HIGH;
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidshadowMode = GetDefaultVideoQualityOption("raidshadowMode", 4, 3, true),
				raidShadowTextureSize = GetDefaultVideoQualityOption("raidShadowTextureSize", 4, 2048, true),
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA;
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_TextureResolutionDropDown"]={
	name = TEXTURE_DETAIL;
	description = OPTION_TOOLTIP_TEXTURE_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				terrainMipLevel = GetDefaultVideoQualityOption("terrainMipLevel", 0, 1),
				componentTextureLevel = GetDefaultVideoQualityOption("componentTextureLevel", 0, 1),
				worldBaseMip = GetDefaultVideoQualityOption("worldBaseMip", 0, 2),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				terrainMipLevel = GetDefaultVideoQualityOption("terrainMipLevel", 1, 1),
				componentTextureLevel = GetDefaultVideoQualityOption("componentTextureLevel", 1, 1),
				worldBaseMip = GetDefaultVideoQualityOption("worldBaseMip", 1, 1),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				terrainMipLevel = GetDefaultVideoQualityOption("terrainMipLevel", 2, 0),
				componentTextureLevel = GetDefaultVideoQualityOption("componentTextureLevel", 2, 0),
				worldBaseMip = GetDefaultVideoQualityOption("worldBaseMip", 2, 1),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				terrainMipLevel = GetDefaultVideoQualityOption("terrainMipLevel", 3, 0),
				componentTextureLevel = GetDefaultVideoQualityOption("componentTextureLevel", 3, 0),
				worldBaseMip = GetDefaultVideoQualityOption("worldBaseMip", 3, 0),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_TextureResolutionDropDown"]={
	name = TEXTURE_DETAIL;
	description = OPTION_TOOLTIP_TEXTURE_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidTerrainMipLevel = GetDefaultVideoQualityOption("raidTerrainMipLevel", 0, 1, true),
				raidComponentTextureLevel = GetDefaultVideoQualityOption("raidComponentTextureLevel", 0, 1, true),
				raidWorldBaseMip = GetDefaultVideoQualityOption("raidWorldBaseMip", 0, 2, true),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidTerrainMipLevel = GetDefaultVideoQualityOption("raidTerrainMipLevel", 1, 1, true),
				raidComponentTextureLevel = GetDefaultVideoQualityOption("raidComponentTextureLevel", 1, 1, true),
				raidWorldBaseMip = GetDefaultVideoQualityOption("raidWorldBaseMip", 1, 1, true),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidTerrainMipLevel = GetDefaultVideoQualityOption("raidTerrainMipLevel", 2, 0, true),
				raidComponentTextureLevel = GetDefaultVideoQualityOption("raidComponentTextureLevel", 2, 0, true),
				raidWorldBaseMip = GetDefaultVideoQualityOption("raidWorldBaseMip", 2, 1, true),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidTerrainMipLevel = GetDefaultVideoQualityOption("raidTerrainMipLevel", 3, 0, true),
				raidComponentTextureLevel = GetDefaultVideoQualityOption("raidComponentTextureLevel", 3, 0, true),
				raidWorldBaseMip = GetDefaultVideoQualityOption("raidWorldBaseMip", 3, 0, true),
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ProjectedTexturesDropDown"]={
	name = PROJECTED_TEXTURES;
	description = OPTION_TOOLTIP_PROJECTED_TEXTURES,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				projectedTextures = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				projectedTextures = 1,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ProjectedTexturesDropDown"]={
	name = PROJECTED_TEXTURES;
	description = OPTION_TOOLTIP_PROJECTED_TEXTURES,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				raidProjectedTextures = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				raidProjectedTextures = 1,
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_FilteringDropDown"]={
	name = ANISOTROPIC;
	description = OPTION_TOOLTIP_ANISOTROPIC,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_BILINEAR,
			cvars =	{
				textureFilteringMode = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_TRILINEAR,
			cvars =	{
				textureFilteringMode = 1,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_2XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 2,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_4XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 3,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_8XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 4,
			},
		},
		[6] = {
			text = VIDEO_OPTIONS_16XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 5,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_FilteringDropDown"]={
	name = ANISOTROPIC;
	description = OPTION_TOOLTIP_ANISOTROPIC,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_BILINEAR,
			cvars =	{
				raidTextureFilteringMode = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_TRILINEAR,
			cvars =	{
				raidTextureFilteringMode = 1,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_2XANISOTROPIC,
			cvars =	{
				raidTextureFilteringMode = 2,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_4XANISOTROPIC,
			cvars =	{
				raidTextureFilteringMode = 3,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_8XANISOTROPIC,
			cvars =	{
				raidTextureFilteringMode = 4,
			},
		},
		[6] = {
			text = VIDEO_OPTIONS_16XANISOTROPIC,
			cvars =	{
				raidTextureFilteringMode = 5,
			},
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_LiquidDetailDropDown"]={
	name = LIQUID_DETAIL;
	description = OPTION_TOOLTIP_LIQUID_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				waterDetail = GetDefaultVideoQualityOption("waterDetail", 0, 0),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				waterDetail = GetDefaultVideoQualityOption("waterDetail", 1, 1),
				reflectionMode = GetDefaultVideoQualityOption("reflectionMode", 1, 0),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				waterDetail = GetDefaultVideoQualityOption("waterDetail", 2, 2),
				reflectionMode = GetDefaultVideoQualityOption("reflectionMode", 2, 1),
				rippleDetail = GetDefaultVideoQualityOption("rippleDetail", 2, 0),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				waterDetail = GetDefaultVideoQualityOption("waterDetail", 4, 3),
				reflectionMode = GetDefaultVideoQualityOption("reflectionMode", 4, 2),
				rippleDetail = GetDefaultVideoQualityOption("rippleDetail", 4, 3),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_LiquidDetailDropDown"]={
	name = LIQUID_DETAIL;
	description = OPTION_TOOLTIP_LIQUID_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidWaterDetail = GetDefaultVideoQualityOption("raidWaterDetail", 0, 0, true),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				raidWaterDetail = GetDefaultVideoQualityOption("raidWaterDetail", 1, 1, true),
				raidReflectionMode = GetDefaultVideoQualityOption("raidReflectionMode", 1, 0, true),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				raidWaterDetail = GetDefaultVideoQualityOption("raidWaterDetail", 2, 2, true),
				raidReflectionMode = GetDefaultVideoQualityOption("raidReflectionMode", 2, 1, true),
				raidRippleDetail = GetDefaultVideoQualityOption("raidRippleDetail", 2, 0, true),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				raidWaterDetail = GetDefaultVideoQualityOption("raidWaterDetail", 4, 3, true),
				raidReflectionMode = GetDefaultVideoQualityOption("raidReflectionMode", 4, 2, true),
				raidRippleDetail = GetDefaultVideoQualityOption("raidRippleDetail", 4, 3, true),
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SunshaftsDropDown"]={
	name = SUNSHAFTS;
	description = OPTION_TOOLTIP_SUNSHAFTS,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				sunshafts = 0,
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				sunshafts = GetDefaultVideoQualityOption("sunshafts", 2, 1),
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				sunshafts = GetDefaultVideoQualityOption("sunshafts", 3, 2),
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_SunshaftsDropDown"]={
	name = SUNSHAFTS;
	description = OPTION_TOOLTIP_SUNSHAFTS,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				raidSunShafts = 0,
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				raidSunShafts = GetDefaultVideoQualityOption("raidSunShafts", 2, 1, true),
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				raidSunShafts = GetDefaultVideoQualityOption("raidSunShafts", 3, 2, true),
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_HIGH,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
-- Advanced
-------------------------------------------------------------------------------------------------------

VideoData["Advanced_BufferingDropDown"]={
	name = TRIPLE_BUFFER;
	description = OPTION_TOOLTIP_TRIPLE_BUFFER,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxTripleBuffer = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxTripleBuffer = 1,
			},
		},
	},
	restart = true;
}

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_LagDropDown"]={
	name = FIX_LAG;
	description = OPTION_TOOLTIP_FIX_LAG,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxFixLag = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxFixLag = 1,
			},
		},
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_HardwareCursorDropDown"]={
	name = HARDWARE_CURSOR;
	description = OPTION_TOOLTIP_HARDWARE_CURSOR,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxCursor = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxCursor = 1,
			},
		},
	},
	onload =
		function(self)
			local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
			if ( not hardwareCursor ) then
				VideoOptionsDropDownMenu_DisableDropDown(self);
			end
		end,
	restart = true,
}

VideoData["Advanced_MaxFPSSlider"]={
	name = MAXFPS;
	tooltip = OPTION_MAXFPS,
	initialize = 
		function(self)
			local value = self:GetCurrentValue();
			if(value == 0) then
				_G["Advanced_MaxFPSCheckBox"]:SetChecked(false);
				VideoOptions_Disable(self);
			else
				_G["Advanced_MaxFPSCheckBox"]:SetChecked(true);
				VideoOptions_Enable(self);
			end
		end,
}
VideoData["Advanced_MaxFPSBKSlider"]={
	name = MAXFPSBK;
	tooltip = OPTION_MAXFPSBK,
	initialize = 
		function(self)
			local value = self:GetCurrentValue();
			if(value == 0) then
				_G["Advanced_MaxFPSBKCheckBox"]:SetChecked(false);
				VideoOptions_Disable(self);
			else
				_G["Advanced_MaxFPSBKCheckBox"]:SetChecked(true);
				VideoOptions_Enable(self);
			end
		end,
}

VideoData["Advanced_MaxFPSCheckBox"]={
	name = MAXFPS_CHECK;
	tooltip = OPTION_MAXFPS_CHECK,
}
VideoData["Advanced_MaxFPSBKCheckBox"]={
	name = MAXFPSBK_CHECK;
	tooltip = OPTION_MAXFPSBK_CHECK,
}
-------------------------------------------------------------------------------------------------------
VideoData["Advanced_GammaSlider"]={
	name = GAMMA;
	tooltip = OPTION_TOOLTIP_GAMMA,
	type = CONTROLTYPE_SLIDER,
	onrefresh =
		function(self)
			local parent = (self:GetParent()):GetName();
			local checkbox = _G[parent .. "DesktopGamma"];
			if((IsMacClient() and not Graphics_DisplayModeDropDown:fullscreenmode()) or (not IsMacClient() and Graphics_DisplayModeDropDown:windowedmode())) then
				self:Hide();
				checkbox:Hide();
			else
				self:Show();
				checkbox:Show();
				local value = Advanced_DesktopGamma:GetChecked();
				if(Advanced_DesktopGamma:GetChecked()) then
					VideoOptions_Disable(self);
				else
					VideoOptions_Enable(self);
				end
			end
		end,
	initialize = function(self)
	end,
}
-------------------------------------------------------------------------------------------------------
VideoData["Advanced_DesktopGamma"]={
	name = DESKTOP_GAMMA;
	tooltip = OPTION_TOOLTIP_DESKTOP_GAMMA,
	cvar = "desktopGamma",
	GetValue =
		function(self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end,
	SetValue = 
		function (self, value)
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
			self:SetChecked(value and value ~= 0);
			Advanced_GammaSlider:onrefresh();
		end,
	SetDisplayValue =
		function (self, value)
			self:SetValue(value);	-- live updating
		end,
	onload =
		function(self)
			self:SetChecked(self:GetValue() and self:GetValue() ~= 0);
		end,
	onclick = 
		function(self)
			if ( self:GetChecked() ) then
				PlaySound("igMainMenuOptionCheckBoxOn");
			else
				PlaySound("igMainMenuOptionCheckBoxOff");
			end
			BlizzardOptionsPanel_CheckButton_OnClick(self);
			VideoOptionsValueChanged(self, (self:GetChecked() and 1 or 0), flag);
			Graphics_EnableApply(self);
		end,
}
VideoData["Advanced_UseUIScale"]={
	name = USE_UISCALE;
	tooltip = OPTION_TOOLTIP_USE_UISCALE,
}
VideoData["Advanced_StereoEnabled"]={
	name = ENABLE_STEREO_VIDEO;
	tooltip = OPTION_TOOLTIP_ENABLE_STEREO_VIDEO,
}

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_GraphicsAPIDropDown"]={
	name = GXAPI;
	description = OPTION_TOOLTIP_GXAPI;

	tablefunction = 
		function(self)
			self.cvarValues = { GetGraphicsAPIs() };	-- this is a table of the cvar values, ie "d3d9", "opengl", etc
			local temp = { };
			for i = 1, #self.cvarValues do
				tinsert(temp, _G["GXAPI_"..strupper(self.cvarValues[i])]);
			end
			return unpack(temp);
		end,
	SetValue =
		function (self, value)
			SetCVar("gxapi", self.cvarValues[value]);
		end,
	doGetValue = 
		function(self)
			local api = GetCVar("gxapi");
			for i = 1, #self.cvarValues do
				if (string.lower(self.cvarValues[i]) == string.lower(api)) then
					return i;
				end
			end
		end,
	lookup = Graphics_TableLookupSafe,
	clientRestart = true,
	gameRestart = true,
}