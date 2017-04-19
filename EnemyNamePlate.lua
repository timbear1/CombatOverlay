----------------------
-- Namespaces
----------------------
local _, core = ...;
core.EnemyNamePlate = {};
local EnemyNamePlate = core.EnemyNamePlate;

----------------------
-- CONST
----------------------
local HEALTH_BAR_TEXTURE = "Interface\\AddOns\\EKplates\\media\\ufbar";
local HEALTH_BAR_HEIGHT = 8;
local HEALTH_FONT_SIZE = 12;

local NAME_FONT_SIZE = 14;
----------------------
-- EnemyNamePlate functions
----------------------

local function UpdateHealth(unitFrame)
	local unit = unitFrame.displayedUnit;
	local minHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit);
	local perc = minHealth/maxHealth;
	local perc_text = string.format("%d", math.floor(perc*100));

    unitFrame.healthBar:SetValue(perc);
    --if minHealth ~= maxHealth then 
    --    unitFrame.healthBar.value:SetText(perc_text);
    --else
    --    unitFrame.healthBar.value:SetText("");
    --end
    
    --if perc < .25 then
    --    unitFrame.healthBar.value:SetTextColor(0.8, 0.05, 0);
    --elseif perc < .3 then
    --    unitFrame.healthBar.value:SetTextColor(0.95, 0.7, 0.25);
    --else
    --    unitFrame.healthBar.value:SetTextColor(1, 1, 1);
    --end
end

local function OnEvent(self, event, ...)
	--local arg1, arg2, arg3, arg4 = ...

	if ( event == "PLAYER_TARGET_CHANGED" ) then
        core:Print("Target changed.");
		--UpdateName(self)
		--UpdateSelectionHighlight(self)
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		--UpdateAll(self)
	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
		if ( event == "UNIT_HEALTH_FREQUENT" ) then
			UpdateHealth(self)
			--UpdateSelectionHighlight(self)
		elseif ( event == "UNIT_AURA" ) then
			--UpdateBuffs(self)
			--UpdateSelectionHighlight(self)
		elseif ( event == "UNIT_THREAT_LIST_UPDATE" ) then
			--UpdateHealthColor(self)
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			--UpdateName(self)
			--UpdateforBossmod(self)
		elseif ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" ) then
			--UpdateAll(self)
		elseif (C.show_power and event == "UNIT_POWER_FREQUENT" ) then
			--UpdatePower(self)
		end
	end
end

local function UpdateNamePlateEvents(unitFrame)
	-- These are events affected if unit is in a vehicle
	local unit = unitFrame.unit;
	local displayedUnit;
	if ( unit ~= unitFrame.displayedUnit ) then
		displayedUnit = unitFrame.displayedUnit;
	end
	unitFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit, displayedUnit);
	unitFrame:RegisterUnitEvent("UNIT_AURA", unit, displayedUnit);
	unitFrame:RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit, displayedUnit);
    --unitFrame.power:Show();
end

local function RegisterNamePlateEvents(unitFrame)
	unitFrame:RegisterEvent("UNIT_NAME_UPDATE");
	unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	unitFrame:RegisterEvent("UNIT_PET");
	unitFrame:RegisterEvent("UNIT_ENTERED_VEHICLE");
	unitFrame:RegisterEvent("UNIT_EXITED_VEHICLE");
	UpdateNamePlateEvents(unitFrame);
	unitFrame:SetScript("OnEvent", OnEvent);
end

local function UnregisterNamePlateEvents(unitFrame)
	unitFrame:UnregisterAllEvents();
	unitFrame:SetScript("OnEvent", nil);
end

local function SetUnit(unitFrame, unit)
	unitFrame.unit = unit;
	unitFrame.displayedUnit = unit;	 -- For vehicles
	unitFrame.inVehicle = false;
	if ( unit ) then
		RegisterNamePlateEvents(unitFrame);
	else
		UnregisterNamePlateEvents(unitFrame);
	end
end

local function CreateBackdrop(parent, anchor, a)
    local frame = CreateFrame("Frame", nil, parent)

	local flvl = parent:GetFrameLevel()
	if flvl - 1 >= 0 then frame:SetFrameLevel(flvl-1) end

	frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", anchor, "TOPLEFT", -3, 3)
    frame:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 3, -3)

    frame:SetBackdrop(frameBD)
	if a then
		frame:SetBackdropColor(.15, .15, .15, a)
		frame:SetBackdropBorderColor(0, 0, 0)
	end

    return frame
end

function EnemyNamePlate:Add(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit);
	SetUnit(namePlate.UnitFrame, unit);
    core:Print("Nameplate Added!");
end

function EnemyNamePlate:Remove(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    SetUnit(namePlate.UnitFrame, nil)
	core:Print("Nameplate removed!");
end

function EnemyNamePlate:Created(namePlate)
	core:Print("Nameplate created!");

    namePlate.UnitFrame = CreateFrame("Button", "$parentUnitFrame", namePlate)
	namePlate.UnitFrame:SetAllPoints(namePlate)
	namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel())
    
    namePlate.UnitFrame.healthBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
    namePlate.UnitFrame.healthBar:SetHeight(HEALTH_BAR_HEIGHT)
    namePlate.UnitFrame.healthBar:SetPoint("LEFT", 0, 0)
    namePlate.UnitFrame.healthBar:SetPoint("RIGHT", 0, 0)
    namePlate.UnitFrame.healthBar:SetStatusBarTexture(HEALTH_BAR_TEXTURE)
    namePlate.UnitFrame.healthBar:SetMinMaxValues(0, 1)
    
    namePlate.UnitFrame.healthBar.bd = CreateBackdrop(namePlate.UnitFrame.healthBar, namePlate.UnitFrame.healthBar, 1) 
    --[[
    namePlate.UnitFrame.healthBar.value = createtext(namePlate.UnitFrame.healthBar, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
    namePlate.UnitFrame.healthBar.value:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "TOPRIGHT", 0, -G.fontsize/3)
    namePlate.UnitFrame.healthBar.value:SetTextColor(1,1,1)
    namePlate.UnitFrame.healthBar.value:SetText("Value")
    
    namePlate.UnitFrame.name = createtext(namePlate.UnitFrame, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
    namePlate.UnitFrame.name:SetPoint("TOPLEFT", namePlate.UnitFrame, "TOPLEFT", 5, -5)
    namePlate.UnitFrame.name:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame, "TOPRIGHT", -5, -15)
    namePlate.UnitFrame.name:SetIndentedWordWrap(false)
    namePlate.UnitFrame.name:SetTextColor(1,1,1)
    namePlate.UnitFrame.name:SetText("Name")
    
    namePlate.UnitFrame.castBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame)
    namePlate.UnitFrame.castBar:Hide()
    namePlate.UnitFrame.castBar.iconWhenNoninterruptible = false
    namePlate.UnitFrame.castBar:SetHeight(8)
    if C.classresource_show and C.classresource == "target" then  
        namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -7)  
        namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -7)  
    else  
        namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -3)  
        namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -3)  
    end  

    namePlate.UnitFrame.castBar:SetStatusBarTexture(G.ufbar)
    namePlate.UnitFrame.castBar:SetStatusBarColor(0.5, 0.5, 0.5)
    createBackdrop(namePlate.UnitFrame.castBar, namePlate.UnitFrame.castBar, 1) 
        
    namePlate.UnitFrame.castBar.Text = createtext(namePlate.UnitFrame.castBar, "OVERLAY", G.fontsize-4, G.fontflag, "CENTER")
    namePlate.UnitFrame.castBar.Text:SetPoint("TOPLEFT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -5, 5)
    namePlate.UnitFrame.castBar.Text:SetPoint("TOPRIGHT", namePlate.UnitFrame.castBar, "BOTTOMRIGHT", 5, -5)
    namePlate.UnitFrame.castBar.Text:SetText("Spell Name")
    
    namePlate.UnitFrame.castBar.Icon = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
    namePlate.UnitFrame.castBar.Icon:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.castBar, "BOTTOMLEFT", -4, -1)
    namePlate.UnitFrame.castBar.Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    if C.classresource_show and C.classresource == "target" then  
        namePlate.UnitFrame.castBar.Icon:SetSize(25, 25)  
    else  
        namePlate.UnitFrame.castBar.Icon:SetSize(21, 21)  
    end  

    namePlate.UnitFrame.castBar.Icon.iconborder = CreateBG(namePlate.UnitFrame.castBar.Icon)
    namePlate.UnitFrame.castBar.Icon.iconborder:SetDrawLayer("OVERLAY", -1)
    
    namePlate.UnitFrame.castBar.BorderShield = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY", 1)
    namePlate.UnitFrame.castBar.BorderShield:SetAtlas("nameplates-InterruptShield")
    namePlate.UnitFrame.castBar.BorderShield:SetSize(15, 15)
    namePlate.UnitFrame.castBar.BorderShield:SetPoint("LEFT", namePlate.UnitFrame.castBar, "LEFT", 5, -5)

    namePlate.UnitFrame.castBar.Spark = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
    namePlate.UnitFrame.castBar.Spark:SetSize(30, 25)
    namePlate.UnitFrame.castBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    namePlate.UnitFrame.castBar.Spark:SetBlendMode("ADD")
    namePlate.UnitFrame.castBar.Spark:SetPoint("CENTER", 0, -1)
    
    namePlate.UnitFrame.castBar.Flash = namePlate.UnitFrame.castBar:CreateTexture(nil, "OVERLAY")
    namePlate.UnitFrame.castBar.Flash:SetAllPoints()
    namePlate.UnitFrame.castBar.Flash:SetTexture(G.ufbar)
    namePlate.UnitFrame.castBar.Flash:SetBlendMode("ADD")
    
    CastingBarFrame_OnLoad(namePlate.UnitFrame.castBar, nil, false, true)
    namePlate.UnitFrame.castBar:SetScript("OnEvent", CastingBarFrame_OnEvent)
    namePlate.UnitFrame.castBar:SetScript("OnUpdate", CastingBarFrame_OnUpdate)
    namePlate.UnitFrame.castBar:SetScript("OnShow", CastingBarFrame_OnShow)

    namePlate.UnitFrame.RaidTargetFrame = CreateFrame("Frame", nil, namePlate.UnitFrame)
    namePlate.UnitFrame.RaidTargetFrame:SetSize(30, 30)
    
    if C.boss_mod_hidename then
        namePlate.UnitFrame.RaidTargetFrame:SetPoint("TOP", namePlate.UnitFrame, "BOTTOM", 0, 30)
    else
        namePlate.UnitFrame.RaidTargetFrame:SetPoint("RIGHT", namePlate.UnitFrame.name, "LEFT")
    end
    
    namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon = namePlate.UnitFrame.RaidTargetFrame:CreateTexture(nil, "OVERLAY")
    namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetTexture(G.raidicon)
    namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:SetAllPoints()
    namePlate.UnitFrame.RaidTargetFrame.RaidTargetIcon:Hide()
    
    namePlate.UnitFrame.redarrow = namePlate.UnitFrame:CreateTexture("$parent_Arrow", 'OVERLAY')
    namePlate.UnitFrame.redarrow:SetSize(50, 50)
    if C.HideArrow then
        namePlate.UnitFrame.redarrow:SetAlpha(0)
    end
    if C.HorizontalArrow then
        namePlate.UnitFrame.redarrow:SetTexture(G.redarrow2)
    else
        namePlate.UnitFrame.redarrow:SetTexture(G.redarrow1)
    end
    namePlate.UnitFrame.redarrow:SetPoint("CENTER")
    namePlate.UnitFrame.redarrow:Hide()
    
    namePlate.UnitFrame.icons = CreateFrame("Frame", nil, namePlate.UnitFrame)
    namePlate.UnitFrame.icons:SetPoint("BOTTOM", namePlate.UnitFrame, "TOP", 0, 0)
    namePlate.UnitFrame.icons:SetWidth(140)
    namePlate.UnitFrame.icons:SetHeight(C.auraiconsize)
    namePlate.UnitFrame.icons:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2)
    
    namePlate.UnitFrame.power = namePlate.UnitFrame:CreateFontString(nil, "OVERLAY")
    namePlate.UnitFrame.power:SetFont(G.numberstylefont, G.fontsize, "OUTLINE")
    namePlate.UnitFrame.power:SetPoint("LEFT", namePlate.UnitFrame.healthBar, "RIGHT", 2, 2)
    namePlate.UnitFrame.power:SetTextColor(.8,.8,1)
    namePlate.UnitFrame.power:SetShadowColor(0, 0, 0, 0.4)
    namePlate.UnitFrame.power:SetShadowOffset(1, -1)
    namePlate.UnitFrame.power:SetText("55")
    ]]--
	namePlate.UnitFrame:EnableMouse(false)
end