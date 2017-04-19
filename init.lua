local _, core = ...; -- Namespace

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
	["config"] = core.Config.Toggle, -- this is a function (no knowledge of Config object)
	
	["help"] = function()
		print(" ");
		core:Print("List of slash commands:")
		core:Print("|cff00cc66/co config|r - shows config menu");
		core:Print("|cff00cc66/co help|r - shows help info");
		print(" ");
	end,
	
	["example"] = {
		["test"] = function(...)
			core:Print("My Value:", tostringall(...));
		end
	}
};

local function HandleSlashCommands(str)	
	if (#str == 0) then	
		-- User just entered "/at" with no additional args.
		core.commands.help();
		return;		
	end	
	
	local args = {};
	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg);
		end
	end
	
	local path = core.commands; -- required for updating found table.
	
	for id, arg in ipairs(args) do
		if (#arg > 0) then -- if string length is greater than 0.
			arg = arg:lower();			
			if (path[arg]) then
				if (type(path[arg]) == "function") then				
					-- all remaining args passed to our function!
					path[arg](select(id + 1, unpack(args))); 
					return;					
				elseif (type(path[arg]) == "table") then				
					path = path[arg]; -- another sub-table found!
				end
			else
				-- does not exist!
				core.commands.help();
				return;
			end
		end
	end
end

-- WARNING: self automatically becomes events frame!
function core:Init(name)
	if (name ~= "CombatOverlay") then return end 

	-- allows using left and right buttons to move through chat 'edit' box
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false);
	end
	
	----------------------------------
	-- Register Slash Commands!
	----------------------------------
	SLASH_RELOADUI1 = "/rl"; -- new slash command for reloading UI
	SlashCmdList.RELOADUI = ReloadUI;

	SLASH_FRAMESTK1 = "/fs"; -- new slash command for showing framestack tool
	SlashCmdList.FRAMESTK = function()
		LoadAddOn("Blizzard_DebugTools");
		FrameStackTooltip_Toggle();
	end

	SLASH_AuraTracker1 = "/co";
	SlashCmdList.AuraTracker = HandleSlashCommands;
	
    core:Print("Welcome back", UnitName("player").."!");
end

local function HideBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame.SetupClassNameplateBars = function() end
	ClassNameplateManaBarFrame:Hide()
  
	hooksecurefunc(NamePlateDriverFrame, "SetupClassNameplateBar", function()  
		NamePlateTargetResourceFrame:Hide()  
		NamePlatePlayerResourceFrame:Hide()	  
	end)  

	local checkBox = InterfaceOptionsNamesPanelUnitNameplatesMakeLarger
	function checkBox.setFunc(value)
		if value == "1" then
			SetCVar("NamePlateHorizontalScale", checkBox.largeHorizontalScale)
			SetCVar("NamePlateVerticalScale", checkBox.largeVerticalScale)
		else
			SetCVar("NamePlateHorizontalScale", checkBox.normalHorizontalScale)
			SetCVar("NamePlateVerticalScale", checkBox.normalVerticalScale)
		end
		NamePlates_UpdateNamePlateOptions()
	end
	
	--去你的DBM
	if DBM and DBM.Nameplate then
		function DBM.Nameplate:SupportedNPMod()
			return true
		end
	end
end

local function test(namePlate)
	core:Print(namePlate);
end

function core:OnEvent(event, ...)
	local arg1 = ...

	if ( event == "VARIABLES_LOADED" ) then
		HideBlizzard();
	elseif ( event == "ADDON_LOADED") then 
		core:Init(...);
	elseif ( event == "NAME_PLATE_CREATED" ) then
		local namePlate = ...
		core.EnemyNamePlate:Created(namePlate);
	elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then 
		local unit = ...
		core.EnemyNamePlate:Add(unit);
	elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then 
		local unit = ...
		core.EnemyNamePlate:Remove(unit);
	end
	--[[ if ( event == "PLAYER_ENTERING_WORLD" ) then
		defaultcvar()
	end
	if ( event == "VARIABLES_LOADED" ) then
		HideBlizzard()
		if C.playerplate then  
			SetCVar("nameplateShowSelf", 1)  
		else  
			SetCVar("nameplateShowSelf", 0)  
		end  

		NamePlates_UpdateNamePlateOptions()
	elseif ( event == "NAME_PLATE_CREATED" ) then
		local namePlate = ...
		OnNamePlateCreated(namePlate)
	elseif ( event == "NAME_PLATE_UNIT_ADDED" ) then 
		local unit = ...
		OnNamePlateAdded(unit)
	elseif ( event == "NAME_PLATE_UNIT_REMOVED" ) then 
		local unit = ...
		OnNamePlateRemoved(unit)
	elseif event == "RAID_TARGET_UPDATE" then
		OnRaidTargetUpdate()
	elseif event == "DISPLAY_SIZE_CHANGED" then
		NamePlates_UpdateNamePlateOptions()
	elseif ( event == "UNIT_FACTION" ) then
		OnUnitFactionChanged(...)
	elseif C.boss_mod and event == "UNIT_AURA" and arg1 == "player" then
		for _, namePlate in pairs(C_NamePlate.GetNamePlates()) do
			UpdateBuffs(namePlate.UnitFrame)
		end
	end ]]--
end

local events = CreateFrame("Frame");
events:SetScript("OnEvent", core.OnEvent);
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("VARIABLES_LOADED")
events:RegisterEvent("NAME_PLATE_CREATED")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")