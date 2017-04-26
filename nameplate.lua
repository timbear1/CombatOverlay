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
local HEALTH_BAR_HEIGHT_NORMAL = 4;
local HEALTH_BAR_HEIGHT_TARGET = 9;
local HEALTH_BAR_WIDTH_NORMAL = 20;
local HEALTH_BAR_WIDTH_TARGET = 5;
local HEALTH_FONT_SIZE = 12;

local NAME_FONT_SIZE = 14;

local POWER_BAR_HEIGHT_NORMAL = -2;
local POWER_BAR_HEIGHT_TARGET = -4;

local BAR_COLOR_ENEMY = { r = 0.92, g = 0.15, b = 0.15 }
local BAR_COLOR_NEUTRAL = { r = 0.9, g = 0.92, b = 0.2 }
local BAR_COLOR_FRIENDLY = { r = 0.19, g = 0.9, b = 0.22 }

local USE_HIGH_DPI_SCALE = true;
local HIGH_DPI_SCALE = 0.5625;

local AURA_ICON_SIZE = 22;
local AURA_TARGET_MAX_NUM = 5;
local AURA_FONT_SIZE = 12;
local AURA_FONT = "Interface\\AddOns\\EKplates\\media\\number.ttf";
local AURA_STATUS_BAR_COLOR = { r = 1.0, g = 0.77, b = 0.0 }

local CAST_BAR_HEIGHT = 8;
local CAST_BAR_TEXTURE = "Interface\\AddOns\\EKplates\\media\\ufbar";
local CAST_BAR_COLOR_INTERRUPTIBLE = { r = 1.0, g = 0.77, b = 0.0 }
local CAST_BAR_COLOR_NOT_INTERRUPTIBLE = { r = 0.5, g = 0.5, b = 0.5 }

local CLASS_RESOURCE_HEIGHT = 10;
local CLASS_RESOURCE_SPACING = 2;
local CLASS_RESOURCE_COLOR = { r = 0.8, g = 0.8, b = 0.8 }

local MY_CLASS = select(2, UnitClass("player"));  --dont touch this

core.Config.customWhitelist = {
    -- Warlock
    ["Unstable Affliction"]  = true,
    ["Corruption"]  = true,
    ["Agony"]  = true,
    ["Siphon Life"]  = true,
    ["Phantom Fingularity"]  = true,
    ["Phantom Fingularity"]  = true, 

    -- Druid
    ["Regrowth"] = true,

    -- Paladin
    ["Judgment"] = true,
}

core.Config.CCWhitelist = {
    -- Warlock
    ["Fear"]  = true,
    ["Axe Toss"] = true,
    ["Shadowfury"] = true,
    ["Summon Infernal"] = true,
    ["Summon Abyssal"] = true,
    ["Banish"] = true,
    ["Blood Horror"] = true,
    ["Mortal Coil"] = true,
    ["Howl of Terror"] = true,
    ["Mesmerize"] = true,
    ["Seduction"] = true,

    -- Druid
    ["Cyclone"] = true,
    ["Maim"] = true,
    ["Mighty Bash"] = true,
    ["Incapacitating Roar"] = true,
    ["Solar Beam"] = true,

    -- Hunter
    ["Binding Shot"] = true,
    ["Intimidation"] = true,
    ["Freezing Trap"] = true,
    ["Wyvern Sting"] = true,

    -- Mage
    ["Deep Freeze"] = true,
    ["Polymorph"] = true,
    ["Ring of Frost"] = true,
    ["Dragon's Breath"] = true,
    ["Frostjaw"] = true,

    -- Monk
    ["Charging Ox Wave"] = true,
    ["Fists of Fury"] = true,
    ["Leg Sweep"] = true,
    ["Paralysis"] = true,

    -- Paladin
    ["Hammer of Justice"] = true,
    ["Fist of Justice"] = true,
    ["Holy Wrath"] = true,
    ["Repentance"] = true,
    ["Blinding Light"] = true,
    ["Turn Evil"] = true,
    ["Avenger's Shield"] = true,

    -- Priest
    ["Mind Control"] = true,
    ["Holy Word: Chastise"] = true,
    ["Psychic Horror"] = true,
    ["Shackle Undead"] = true,
    ["Psychic Scream"] = true,
    ["Silence"] = true,

    -- Rogue
    ["Cheap Shot"] = true,
    ["Kidney Shot"] = true,
    ["Gouge"] = true,
    ["Sap"] = true,
    ["Blind"] = true,
    ["Garrote"] = true,

    -- Shaman
    ["Pulverize"] = true,
    ["Capacitor Totem"] = true,
    ["Hex"] = true,

    -- Death knight
    ["Asphyxiate"] = true,
    ["Gnaw"] = true,
    ["Remorseless Winter"] = true,
    ["Asphyxiate"] = true,
    ["Strangulate"] = true,

    -- Warrior
    ["Shockwave"] = true,
    ["Storm Bolt"] = true,
    ["Intimidating Shout"] = true,

    -- Race
    ["War Stomp"] = true,
    ["Quaking Palm"] = true,
    ["Arcane Torrent"] = true,
}

core.Config.BuffWhitelist = {
    -- Warlock
    ["Unending Resolve"]  = true,
    ["Nether Ward"]  = true,

}
----------------------
-- EnemyNamePlate functions
----------------------

local createtext = function(f, layer, fontsize, font, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(font, fontsize, flag)
	text:SetJustifyH(justifyh)
	return text
end

local function UpdateHealth(unitFrame)
	local unit = unitFrame.displayedUnit;
	local minHealth, maxHealth = UnitHealth(unit), UnitHealthMax(unit);
	local perc = minHealth/maxHealth;

    unitFrame.healthBar:SetValue(perc);

    local reaction = UnitReaction("player", unitFrame.unit);
    if ( reaction == 2 ) then
        -- ENEMY
        unitFrame.healthBar:SetStatusBarColor(BAR_COLOR_ENEMY.r, BAR_COLOR_ENEMY.g, BAR_COLOR_ENEMY.b);
    elseif ( reaction == 4 ) then
        -- NEUTRAL
        unitFrame.healthBar:SetStatusBarColor(BAR_COLOR_NEUTRAL.r, BAR_COLOR_NEUTRAL.g, BAR_COLOR_NEUTRAL.b);
    else
        -- FRIENDLY
        unitFrame.healthBar:SetStatusBarColor(BAR_COLOR_FRIENDLY.r, BAR_COLOR_FRIENDLY.g, BAR_COLOR_FRIENDLY.b);
    end
end

local function UpdatePower(unitFrame)
	local unit = unitFrame.displayedUnit;
    local _, powerTypeString = UnitPowerType(unit);
	local minPower, maxPower = UnitPower(unit), UnitPowerMax(unit);
	local perc = minPower/maxPower;

    unitFrame.power:SetValue(perc);
	
	local color = PowerBarColor[powerTypeString];
    unitFrame.power:SetStatusBarColor(color.r, color.g, color.b);
end

local function UpdateName(unitFrame)
	local name = GetUnitName(unitFrame.displayedUnit, false) or UNKNOWN;
	--local level = UnitLevel(unitFrame.unit);
	
	if name and not UnitIsUnit(unitFrame.displayedUnit, "player") then
        local hexColor = "ffffffff";
		if UnitIsPlayer(unitFrame.unit) then
            local _, englishClass = UnitClass(unitFrame.unit);
            --core:Print("Class: ", WrapTextInColorCode(englishClass, RAID_CLASS_COLORS[englishClass].colorStr));
            hexColor = RAID_CLASS_COLORS[englishClass].colorStr;
		end
        unitFrame.name:SetText(WrapTextInColorCode(name, hexColor));
	else
        unitFrame.name:SetText("");
    end
end

local function UpdateTarget(unitFrame)
    local unit = unitFrame.displayedUnit;
    if UnitIsUnit(unit,"target") then
        unitFrame.healthBar:ClearAllPoints();
        unitFrame.healthBar:SetHeight(HEALTH_BAR_HEIGHT_TARGET);
        unitFrame.healthBar:SetPoint("LEFT", HEALTH_BAR_WIDTH_TARGET, 0);
        unitFrame.healthBar:SetPoint("RIGHT", HEALTH_BAR_WIDTH_TARGET*-1, 0);
        unitFrame.healthBar.bd:SetBackdropBorderColor(0.25, 0.25, 0.25);
        unitFrame.power:ClearAllPoints();
        unitFrame.power:SetPoint("TOPLEFT", unitFrame.healthBar, "BOTTOMLEFT", 0, -2);
        unitFrame.power:SetPoint("BOTTOMRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 0, POWER_BAR_HEIGHT_TARGET-2);
        unitFrame.power.bd:SetBackdropBorderColor(0.25, 0.25, 0.25);
        unitFrame.castBar:SetHeight(CAST_BAR_HEIGHT);
        unitFrame.castBar:SetPoint("TOPLEFT", unitFrame.power, "BOTTOMLEFT", 0, -4);
        unitFrame.castBar:SetPoint("TOPRIGHT", unitFrame.power, "BOTTOMRIGHT", 0, -4);
        unitFrame.castBar.bd:SetBackdropBorderColor(0, 0, 0);
    elseif UnitIsUnit(unitFrame.displayedUnit, "player") then
        unitFrame.healthBar:ClearAllPoints();
        unitFrame.healthBar:SetHeight(HEALTH_BAR_HEIGHT_TARGET);
        unitFrame.healthBar:SetPoint("LEFT", HEALTH_BAR_WIDTH_TARGET, 0);
        unitFrame.healthBar:SetPoint("RIGHT", HEALTH_BAR_WIDTH_TARGET*-1, 0);
        unitFrame.healthBar.bd:SetBackdropBorderColor(0, 0, 0);
        unitFrame.power:ClearAllPoints();
        unitFrame.power:SetPoint("TOPLEFT", unitFrame.healthBar, "BOTTOMLEFT", 0, -2);
        unitFrame.power:SetPoint("BOTTOMRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 0, POWER_BAR_HEIGHT_TARGET-2);
        unitFrame.power.bd:SetBackdropBorderColor(0, 0, 0);
        unitFrame.castBar:SetHeight(CAST_BAR_HEIGHT);
        unitFrame.castBar:SetPoint("TOPLEFT", unitFrame.power, "BOTTOMLEFT", 0, -4);
        unitFrame.castBar:SetPoint("TOPRIGHT", unitFrame.power, "BOTTOMRIGHT", 0, -4);
        unitFrame.castBar.bd:SetBackdropBorderColor(0, 0, 0);
    else
        unitFrame.healthBar:ClearAllPoints();
        unitFrame.healthBar:SetHeight(HEALTH_BAR_HEIGHT_NORMAL);
        unitFrame.healthBar:SetPoint("LEFT", HEALTH_BAR_WIDTH_NORMAL, 0);
        unitFrame.healthBar:SetPoint("RIGHT", HEALTH_BAR_WIDTH_NORMAL*-1, 0);
        unitFrame.healthBar.bd:SetBackdropBorderColor(0, 0, 0);
        unitFrame.power:ClearAllPoints();
        unitFrame.power:SetPoint("TOPLEFT", unitFrame.healthBar, "BOTTOMLEFT", 0, -2);
        unitFrame.power:SetPoint("BOTTOMRIGHT", unitFrame.healthBar, "BOTTOMRIGHT", 0, POWER_BAR_HEIGHT_NORMAL-2);
        unitFrame.power.bd:SetBackdropBorderColor(0, 0, 0);
        unitFrame.castBar:SetHeight(CAST_BAR_HEIGHT);
        unitFrame.castBar:SetPoint("TOPLEFT", unitFrame.power, "BOTTOMLEFT", 0, -4);
        unitFrame.castBar:SetPoint("TOPRIGHT", unitFrame.power, "BOTTOMRIGHT", 0, -4);
        unitFrame.castBar.bd:SetBackdropBorderColor(0, 0, 0);
    end
end

--[[ Auras ]]-- 

local day, hour, minute = 86400, 3600, 60
local function FormatTime(s)
    if s >= day then
        return format("%dd", floor(s/day + 0.5))
    elseif s >= hour then
        return format("%dh", floor(s/hour + 0.5))
    elseif s >= minute then
        return format("%dm", floor(s/minute + 0.5))
    end

    return format("%d", math.fmod(s, minute))
end

local function CreateAuraIcon(parent)
	local aura = CreateFrame("Frame",nil,parent);
	aura:SetSize(AURA_ICON_SIZE, AURA_ICON_SIZE);

	aura.icon = aura:CreateTexture(nil, "OVERLAY", nil, 3);
	aura.icon:SetPoint("TOPLEFT", aura,"TOPLEFT", 1, -1);
	aura.icon:SetPoint("BOTTOMRIGHT", aura,"BOTTOMRIGHT",-1, 1);
	aura.icon:SetTexCoord(.08, .92, 0.08, 0.92);
	
	aura.overlay = aura:CreateTexture(nil, "ARTWORK", nil, 7);
	aura.overlay:SetTexture("Interface\\Buttons\\WHITE8x8");
	aura.overlay:SetAllPoints(aura);
	
	aura.bd = aura:CreateTexture(nil, "ARTWORK", nil, 6);
	aura.bd:SetTexture("Interface\\Buttons\\WHITE8x8");
	aura.bd:SetVertexColor(0, 0, 0);
	aura.bd:SetPoint("TOPLEFT", aura,"TOPLEFT", -1, 1);
	aura.bd:SetPoint("BOTTOMRIGHT", aura,"BOTTOMRIGHT", 1, -1);
	
	aura.text = createtext(aura, "OVERLAY", AURA_FONT_SIZE, AURA_FONT, "OUTLINE", "CENTER");
	aura.text:SetPoint("BOTTOM", aura, "BOTTOM", 0, 3);
	aura.text:SetTextColor(1, 1, 0);
	
	aura.count = createtext(aura, "OVERLAY", AURA_FONT_SIZE-2, AURA_FONT, "OUTLINE", "RIGHT");
	aura.count:SetPoint("TOPRIGHT", aura, "TOPRIGHT", -1, 2);
	aura.count:SetTextColor(.4, .95, 1);

    aura.statusBar = CreateFrame("StatusBar", nil, aura);
    aura.statusBar:SetPoint("BOTTOM", aura, "BOTTOM", 0, 0);
    aura.statusBar:SetHeight(4);
    aura.statusBar:SetWidth(AURA_ICON_SIZE);
    aura.statusBar:SetMinMaxValues(0, 1);
    aura.statusBar:SetValue(1.0);
    aura.statusBar:SetStatusBarTexture(HEALTH_BAR_TEXTURE);
    aura.statusBar:SetStatusBarColor(AURA_STATUS_BAR_COLOR.r, AURA_STATUS_BAR_COLOR.g, AURA_STATUS_BAR_COLOR.b);
    local flvl = aura:GetFrameLevel();
	aura.statusBar:SetFrameLevel(flvl+1);

    aura.statusBar.bg = aura.statusBar:CreateTexture(nil, "BACKGROUND");
	aura.statusBar.bg:SetAllPoints(aura.statusBar);
	aura.statusBar.bg:SetColorTexture(0.8, 0.8, 0.8);

	return aura;
end

local function UpdateAuraIcon(aura, unit, index, filter, custom_icon)
	local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter);
	
	aura.icon:SetTexture(icon);
	aura.expirationTime = expirationTime;
	aura.duration = duration;
	aura.spellID = spellID;
    aura.startTime = expirationTime - duration;
	--local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none;
	aura.overlay:SetVertexColor(0.9, 0.9, 0.9)
    --aura.overlay:SetVertexColor(color.r, color.g, color.b)
    
	if count and count > 1 then
		aura.count:SetText(count)
	else
		aura.count:SetText("")
	end

    -- Debuffs that last forever like corruption with Absolute Corruption talent 
    -- Show them as full duration always. 
    if (duration == 0) then
        aura.statusBar:SetValue(1.0);
    end
	
	aura:SetScript("OnUpdate", function(self, elapsed)
		if not self.duration then return end
		
		self.elapsed = (self.elapsed or 0) + elapsed

		if self.elapsed < .2 then return end
		self.elapsed = 0

        
		local timeLeft = self.expirationTime - GetTime();
        local relativeTimeLeft = (GetTime() - self.startTime) / (self.expirationTime - self.startTime);
		if timeLeft <= 0 then
			self.text:SetText(nil)
		else
			self.text:SetText(FormatTime(timeLeft))
            self.statusBar:SetValue(1.0 - relativeTimeLeft);
		end
	end)
	
	aura:Show()
end

local function UpdateAuras(unitFrame, auras, type, allAuras, whitelist)
    if not auras or not unitFrame.displayedUnit then return end
	if UnitIsUnit(unitFrame.displayedUnit, "player") then return end -- No buffs on the player
	local unit = unitFrame.displayedUnit;
	local i = 1;

	for index = 1, 20 do
		if ( i <= AURA_TARGET_MAX_NUM ) then
			local dname, _, _, _, _, dduration, _, dcaster, _, _, dspellid = UnitAura(unit, index, type);

            if ( dcaster == "player" or allAuras ) then
                if ( whitelist[dname] ) then 
                    -- Check if we have a icon we can reuse, if not create a new one. 
                    if not auras[i] then 
                        auras[i] = CreateAuraIcon(auras);
                    end
                    UpdateAuraIcon(auras[i], unit, index, type);
                    if i ~= 1 then
                        auras[i]:SetPoint("LEFT", auras[i-1], "RIGHT", 4, 0);
                    end
                    i = i + 1;
                end
            end
		end
	end
	
	local aurasNumber = i - 1
	
	if i > 1 then
		auras[1]:SetPoint("LEFT", auras, "CENTER", -((AURA_ICON_SIZE+4)*(aurasNumber)-4)/2,0);
	end
	for index = i, #auras do 
        auras[index]:Hide(); 
    end
end

local function UpdateAllAuras(unitFrame)
	-- Check if we are looking for helpful or harmful custom auras on the target. 
    local type = 'HELPFUL';
    local reaction = UnitReaction("player", unitFrame.unit);
    if ( reaction == 2 or reaction == 4) then 
        type = 'HARMFUL';
    end

    UpdateAuras(unitFrame, unitFrame.customAuras, type, false, core.Config.customWhitelist);
    UpdateAuras(unitFrame, unitFrame.CCAuras, 'HARMFUL', true, core.Config.CCWhitelist);
    UpdateAuras(unitFrame, unitFrame.BuffAuras, 'HELPFUL', true, core.Config.BuffWhitelist);
end

local function UpdateCastBar(unitFrame)
	local castBar = unitFrame.castBar;
    castBar.ignore = UnitIsUnit("player", unitFrame.displayedUnit);
    castBar:Hide();
end

local function SpellCastStart(unitFrame)
    if UnitIsUnit(unitFrame.displayedUnit, "player") then return end -- No cast bar on the player
    local castBar = unitFrame.castBar;
    local unit = unitFrame.unit;
    local name, _, text, texture, startTime, endTime, _, castid, notInterruptible, spellid = UnitCastingInfo(unitFrame.unit);
    
    if(not name) then
		return castBar:Hide();
	end

    endTime = endTime / 1e3;
	startTime = startTime / 1e3;
    local duration = endTime - startTime;

    castBar.castid = castid;
	castBar.startTime = startTime;
    castBar.endTime = endTime;
	castBar.casting = true;

    castBar:SetMinMaxValues(0, 1);

    local duration = (GetTime() - startTime) / (endTime - startTime);
    castBar:SetValue(duration);

    if ( notInterruptible ) then
        castBar:SetStatusBarColor(CAST_BAR_COLOR_NOT_INTERRUPTIBLE.r, CAST_BAR_COLOR_NOT_INTERRUPTIBLE.g, CAST_BAR_COLOR_NOT_INTERRUPTIBLE.b);
    else
        castBar:SetStatusBarColor(CAST_BAR_COLOR_INTERRUPTIBLE.r, CAST_BAR_COLOR_INTERRUPTIBLE.g, CAST_BAR_COLOR_INTERRUPTIBLE.b);
    end

    unitFrame.castBar:Show();
    unitFrame.castBar.text:SetText(name);
end

local function SpellCastFailed(unitFrame, castId)
    if (unitFrame.castBar.castid ~= castId) then return end
    unitFrame.castBar:Hide();
    unitFrame.castBar.casting = false;
end

local function SpellCastStop(unitFrame, castId)
    if (unitFrame.castBar.castid ~= castId) then return end
    unitFrame.castBar:Hide();
    unitFrame.castBar.casting = false;
end

local function SpellCastInterrupted(unitFrame, castId)
    if (unitFrame.castBar.castid ~= castId) then return end
    unitFrame.castBar:Hide();
    unitFrame.castBar.casting = false;
end

local function SpellCastInterruptible(unitFrame)
    unitFrame.castBar:SetStatusBarColor(CAST_BAR_COLOR_INTERRUPTIBLE.r, CAST_BAR_COLOR_INTERRUPTIBLE.g, CAST_BAR_COLOR_INTERRUPTIBLE.b);
end

local function SpellCastNotInterruptible(unitFrame)
    unitFrame.castBar:SetStatusBarColor(CAST_BAR_COLOR_NOT_INTERRUPTIBLE.r, CAST_BAR_COLOR_NOT_INTERRUPTIBLE.g, CAST_BAR_COLOR_NOT_INTERRUPTIBLE.b);
end

local function SpellCastDelayed(unitFrame)
    --core:Print("Spell Cast: Delayed");
    local castBar = unitFrame.castBar;
    local unit = unitFrame.unit;
    local name, _, _, _, startTime, endTime, _, castid = UnitCastingInfo(unitFrame.unit);

     if(not name) then
		return castBar:Hide();
	end

    endTime = endTime / 1e3;
	startTime = startTime / 1e3;

	castBar.startTime = startTime;
    castBar.endTime = endTime;

end

local function SpellCastChannelStart(unitFrame)
    if UnitIsUnit(unitFrame.displayedUnit, "player") then return end -- No cast bar on the player
    local castBar = unitFrame.castBar;
    local unit = unitFrame.unit;
    local name, _, _, texture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit);
    
    if(not name) then
		return castBar:Hide();
	end

    endTime = endTime / 1e3;
	startTime = startTime / 1e3;
    local duration = endTime - startTime;

	castBar.startTime = startTime;
    castBar.endTime = endTime;
	castBar.channeling = true;
    castBar.casting = false;
    castBar.castId = nil;

    castBar:SetMinMaxValues(0, 1);

    local duration = (GetTime() - startTime) / (endTime - startTime);
    castBar:SetValue(1.0 - duration);

    if ( notInterruptible ) then
        castBar:SetStatusBarColor(CAST_BAR_COLOR_NOT_INTERRUPTIBLE.r, CAST_BAR_COLOR_NOT_INTERRUPTIBLE.g, CAST_BAR_COLOR_NOT_INTERRUPTIBLE.b);
    else
        castBar:SetStatusBarColor(CAST_BAR_COLOR_INTERRUPTIBLE.r, CAST_BAR_COLOR_INTERRUPTIBLE.g, CAST_BAR_COLOR_INTERRUPTIBLE.b);
    end

    unitFrame.castBar:Show();
    unitFrame.castBar.text:SetText(name);
end

local function SpellCastChannelUpdate(unitFrame)
    --if UnitIsUnit(unitFrame.displayedUnit, "player") then return end -- No cast bar on the player
    local castBar = unitFrame.castBar;
    local unit = unitFrame.unit;
    local name, _, _, _, startTime, endTime = UnitChannelInfo(unit);
    
    if(not name) then
		return castBar:Hide();
	end

    endTime = endTime / 1e3;
	startTime = startTime / 1e3;
    local duration = endTime - startTime;

	castBar.startTime = startTime;
    castBar.endTime = endTime;
end

local function SpellCastChannelStop(unitFrame)
    if (unitFrame.castBar.castid ~= castId) then return end
    unitFrame.castBar:Hide();
    unitFrame.castBar.casting = false;
end

local function CastBarOnUpdate(self, elapsed)
    if(self.casting) then
		local duration = (GetTime() - self.startTime) / (self.endTime - self.startTime);
		if(duration >= 1) then
			self.casting = false;
			self:Hide();
			return
		end
		self:SetValue(duration);
    elseif (self.channeling) then
        local duration = (GetTime() - self.startTime) / (self.endTime - self.startTime);
		if(duration >= 1.0) then
			self.casting = false;
			self:Hide();
			return
		end
        self:SetValue(1.0 - duration);
    end
end

local function SetupClassResourcePoints(classResource, numPoints)
    for i = 1, 6 do
        local width = (140.0/6.0) - CLASS_RESOURCE_SPACING;
        local position = (width * (i-1)) + (CLASS_RESOURCE_SPACING * (i-1)) + 1;

        classResource[i]:SetSize(width, CLASS_RESOURCE_HEIGHT);
        classResource[i]:SetPoint("LEFT", classResource, "LEFT", position, 0);
    end
end

local function RegisterClassResource(classResource)
    classResource:RegisterEvent("UNIT_POWER_FREQUENT");
    classResource:RegisterEvent("PLAYER_ENTERING_WORLD");
    classResource:RegisterEvent("NAME_PLATE_UNIT_ADDED");
    classResource:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
    classResource:RegisterEvent("PLAYER_TARGET_CHANGED");
    classResource:RegisterEvent("RUNE_POWER_UPDATE");
end

local function UnRegisterClassResource(classResource)
    classResource:UnregisterEvent("UNIT_POWER_FREQUENT");
    classResource:UnregisterEvent("PLAYER_ENTERING_WORLD");
    classResource:UnregisterEvent("NAME_PLATE_UNIT_ADDED");
    classResource:UnregisterEvent("NAME_PLATE_UNIT_REMOVED");
    classResource:UnregisterEvent("PLAYER_TARGET_CHANGED");
    classResource:UnregisterEvent("RUNE_POWER_UPDATE");
end

local function UpdateClassResource(unitFrame)
    local classResource = unitFrame.classResource;

    if not UnitIsUnit(unitFrame.displayedUnit, "player")  then 
        UnRegisterClassResource(classResource);
        classResource:Hide();
        return
    end

    local ClassPowerID, ClassPowerType, RequireSpec;
    if(MY_CLASS == 'MONK') then  
        ClassPowerID = SPELL_POWER_CHI;
        ClassPowerType = "CHI";
        RequireSpec = SPEC_MONK_WINDWALKER;
    elseif(MY_CLASS == 'PALADIN') then  
        ClassPowerID = SPELL_POWER_HOLY_POWER;
        ClassPowerType = "HOLY_POWER";
        RequireSpec = SPEC_PALADIN_RETRIBUTION;
    elseif(MY_CLASS == 'MAGE') then  
        ClassPowerID = SPELL_POWER_ARCANE_CHARGES;
        ClassPowerType = "ARCANE_CHARGES";
        RequireSpec = SPEC_MAGE_ARCANE;
    elseif(MY_CLASS == 'WARLOCK') then  
        ClassPowerID = SPELL_POWER_SOUL_SHARDS;
        ClassPowerType = "SOUL_SHARDS";
    elseif(MY_CLASS == 'ROGUE' or MY_CLASS == 'DRUID') then  
        ClassPowerID = SPELL_POWER_COMBO_POINTS;
        ClassPowerType = "COMBO_POINTS";
    end  

    RegisterClassResource(classResource);
    SetupClassResourcePoints(classResource, 6);
    classResource:Show();

    classResource:SetScript("OnEvent", function(self, event, unit, powerType)  
        if event == "PLAYER_TALENT_UPDATE" then  
			if core:multicheck(MY_CLASS, "WARLOCK", "PALADIN", "MONK", "MAGE", "ROGUE", "DRUID", "DEATHKNIGHT") and not RequireSpec or RequireSpec == GetSpecialization() then
				RegisterClassResource(self);
				self:Show();
                core:Print("Talent Change to ret!");
			else  
				UnRegisterClassResource(self);
				self:Hide();
			end
		elseif event == "PLAYER_ENTERING_WORLD" or (event == "UNIT_POWER_FREQUENT" and unit == "player" and powerType == ClassPowerType) then  

        end
    end)
    classResource:RegisterEvent("PLAYER_TALENT_UPDATE");
end

local function OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4 = ...

	if ( event == "PLAYER_TARGET_CHANGED" ) then
		UpdateName(self);
        UpdateTarget(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
        UpdateTarget(self);
		--UpdateAll(self)
	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
		if ( event == "UNIT_HEALTH_FREQUENT" ) then
			UpdateHealth(self);
		elseif ( event == "UNIT_AURA" ) then
			UpdateAllAuras(self);
		elseif ( event == "UNIT_NAME_UPDATE" ) then
			UpdateName(self);
		elseif ( event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" ) then
			--UpdateAll(self);
		elseif (event == "UNIT_POWER_FREQUENT" ) then
			UpdatePower(self);
		elseif (event == "UNIT_SPELLCAST_START") then
            SpellCastStart(self);
		elseif (event == "UNIT_SPELLCAST_FAILED") then
            SpellCastFailed(self, arg4);
		elseif (event == "UNIT_SPELLCAST_STOP") then
            SpellCastStop(self, arg4);
		elseif (event == "UNIT_SPELLCAST_INTERRUPTED") then
            SpellCastInterrupted(self, arg4);
		elseif (event == "UNIT_SPELLCAST_INTERRUPTIBLE") then
            SpellCastInterruptible(self);
		elseif (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE") then
            SpellCastNotInterruptible(self);
		elseif (event == "UNIT_SPELLCAST_DELAYED") then
            SpellCastDelayed(self);
		elseif (event == "UNIT_SPELLCAST_CHANNEL_START") then
            SpellCastChannelStart(self);
		elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then
            SpellCastChannelUpdate(self);
		elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP") then
            SpellCastChannelStop(self);
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
    unitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit, displayedUnit);
    unitFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit, displayedUnit);
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

local frameBD = {
    edgeFile = "Interface\\AddOns\\EKplates\\media\\glow", edgeSize = 3,
    bgFile = "Interface\\Buttons\\WHITE8x8",
    insets = {left = 3, right = 3, top = 3, bottom = 3}
}

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
    UpdateHealth(namePlate.UnitFrame);
    UpdatePower(namePlate.UnitFrame);
    UpdateName(namePlate.UnitFrame);
    UpdateTarget(namePlate.UnitFrame);
    UpdateAllAuras(namePlate.UnitFrame);
    UpdateCastBar(namePlate.UnitFrame);
    UpdateClassResource(namePlate.UnitFrame);

    -- Check if the target is already casting/channeling something
    local casting = UnitCastingInfo(unit);
    local channeling = UnitChannelInfo(unit);
    if ( casting ) then
        SpellCastStart(namePlate.UnitFrame);
    elseif ( channeling ) then
        SpellCastChannelStart(namePlate.UnitFrame);
    end
end

function EnemyNamePlate:Remove(unit)
    local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
    SetUnit(namePlate.UnitFrame, nil)
end

function EnemyNamePlate:Created(namePlate)

    namePlate.UnitFrame = CreateFrame("Button", "$parentUnitFrame", namePlate);
	namePlate.UnitFrame:SetAllPoints(namePlate);
	namePlate.UnitFrame:SetFrameLevel(namePlate:GetFrameLevel());

    if (USE_HIGH_DPI_SCALE) then
        local scale = HIGH_DPI_SCALE / UIParent:GetEffectiveScale();
        namePlate.UnitFrame:SetScale(scale);
    end
    
    namePlate.UnitFrame.healthBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame);
    namePlate.UnitFrame.healthBar:SetHeight(HEALTH_BAR_HEIGHT_NORMAL);
    namePlate.UnitFrame.healthBar:SetPoint("LEFT", HEALTH_BAR_WIDTH_NORMAL, 0);
    namePlate.UnitFrame.healthBar:SetPoint("RIGHT", HEALTH_BAR_WIDTH_NORMAL*-1, 0);
    namePlate.UnitFrame.healthBar:SetStatusBarTexture(HEALTH_BAR_TEXTURE);
    namePlate.UnitFrame.healthBar:SetMinMaxValues(0, 1);
    namePlate.UnitFrame.healthBar.bd = CreateBackdrop(namePlate.UnitFrame.healthBar, namePlate.UnitFrame.healthBar, 1);

    namePlate.UnitFrame.power = CreateFrame("StatusBar", nil, namePlate.UnitFrame);
    --namePlate.UnitFrame.power:SetHeight(HEALTH_BAR_HEIGHT_NORMAL)
    namePlate.UnitFrame.power:SetPoint("TOPLEFT", namePlate.UnitFrame.healthBar, "BOTTOMLEFT", 0, -2);
    namePlate.UnitFrame.power:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.healthBar, "BOTTOMRIGHT", 0, POWER_BAR_HEIGHT_NORMAL-2);
    namePlate.UnitFrame.power:SetStatusBarTexture(HEALTH_BAR_TEXTURE);
    namePlate.UnitFrame.power:SetMinMaxValues(0, 1);
    namePlate.UnitFrame.power.bd = CreateBackdrop(namePlate.UnitFrame.power, namePlate.UnitFrame.power, 1);

    namePlate.UnitFrame.name = createtext(namePlate.UnitFrame, "OVERLAY", NAME_FONT_SIZE-4, STANDARD_TEXT_FONT, "OUTLINE", "CENTER");
    namePlate.UnitFrame.name:SetPoint("TOPLEFT", namePlate.UnitFrame, "TOPLEFT", 5, -5);
    namePlate.UnitFrame.name:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame, "TOPRIGHT", -5, -15);
    namePlate.UnitFrame.name:SetIndentedWordWrap(false);
    namePlate.UnitFrame.name:SetTextColor(1,1,1);
    namePlate.UnitFrame.name:SetText("Name");

    namePlate.UnitFrame.customAuras = CreateFrame("Frame", nil, namePlate.UnitFrame);
    namePlate.UnitFrame.customAuras:SetPoint("BOTTOM", namePlate.UnitFrame.name, "TOP", 0, 2);
    namePlate.UnitFrame.customAuras:SetWidth(140);
    namePlate.UnitFrame.customAuras:SetHeight(AURA_ICON_SIZE);
    namePlate.UnitFrame.customAuras:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2);    

    namePlate.UnitFrame.CCAuras = CreateFrame("Frame", nil, namePlate.UnitFrame);
    namePlate.UnitFrame.CCAuras:SetPoint("BOTTOM", namePlate.UnitFrame.customAuras, "TOP", 0, 2);
    namePlate.UnitFrame.CCAuras:SetWidth(140);
    namePlate.UnitFrame.CCAuras:SetHeight(AURA_ICON_SIZE);
    namePlate.UnitFrame.CCAuras:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2);

    namePlate.UnitFrame.castBar = CreateFrame("StatusBar", nil, namePlate.UnitFrame);
    --namePlate.UnitFrame.castBar:Hide();
    namePlate.UnitFrame.castBar:SetHeight(CAST_BAR_HEIGHT);
    namePlate.UnitFrame.castBar:SetPoint("TOPLEFT", namePlate.UnitFrame.power, "BOTTOMLEFT", 0, -4);
    namePlate.UnitFrame.castBar:SetPoint("TOPRIGHT", namePlate.UnitFrame.power, "BOTTOMRIGHT", 0, -4);
    namePlate.UnitFrame.castBar:SetStatusBarTexture(CAST_BAR_TEXTURE);
    namePlate.UnitFrame.castBar:SetMinMaxValues(0, 1);
    namePlate.UnitFrame.castBar:SetStatusBarColor(0.5, 0.5, 0.5);
    namePlate.UnitFrame.castBar.bd = CreateBackdrop(namePlate.UnitFrame.castBar, namePlate.UnitFrame.castBar, 1);
    namePlate.UnitFrame.castBar:SetScript("OnUpdate", CastBarOnUpdate);

    namePlate.UnitFrame.castBar.text = createtext(namePlate.UnitFrame.castBar, "OVERLAY", NAME_FONT_SIZE-4, STANDARD_TEXT_FONT, "OUTLINE", "CENTER");
    namePlate.UnitFrame.castBar.text:SetPoint("TOPLEFT", namePlate.UnitFrame.castBar, "TOPLEFT", 0, 0);
    namePlate.UnitFrame.castBar.text:SetPoint("BOTTOMRIGHT", namePlate.UnitFrame.castBar, "BOTTOMRIGHT", 0, 0);
    namePlate.UnitFrame.castBar.text:SetIndentedWordWrap(false);
    namePlate.UnitFrame.castBar.text:SetTextColor(1,1,1);
    namePlate.UnitFrame.castBar.text:SetText("");

    namePlate.UnitFrame.BuffAuras = CreateFrame("Frame", nil, namePlate.UnitFrame);
    namePlate.UnitFrame.BuffAuras:SetPoint("TOP", namePlate.UnitFrame.castBar, "BOTTOM", 0, -4);
    namePlate.UnitFrame.BuffAuras:SetWidth(140);
    namePlate.UnitFrame.BuffAuras:SetHeight(AURA_ICON_SIZE);
    namePlate.UnitFrame.BuffAuras:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2);

    -- Class resource, combo points, holy power, shards m.m. 
    namePlate.UnitFrame.classResource = CreateFrame("Frame", nil, namePlate.UnitFrame);
    namePlate.UnitFrame.classResource:SetPoint("BOTTOM", namePlate.UnitFrame.healthBar, "TOP", 0, 4);
    namePlate.UnitFrame.classResource:SetWidth(140);
    namePlate.UnitFrame.classResource:SetHeight(CLASS_RESOURCE_HEIGHT);
    namePlate.UnitFrame.classResource:SetFrameLevel(namePlate.UnitFrame:GetFrameLevel() + 2);

    for i = 1, 6 do
        namePlate.UnitFrame.classResource[i] = CreateFrame("Frame", nil, namePlate.UnitFrame.classResource);
		namePlate.UnitFrame.classResource[i]:SetFrameLevel(namePlate.UnitFrame.classResource:GetFrameLevel() + 1);
		namePlate.UnitFrame.classResource[i].texture = namePlate.UnitFrame.classResource[i]:CreateTexture(nil, "BACKGROUND");
		namePlate.UnitFrame.classResource[i].texture:SetAllPoints(namePlate.UnitFrame.classResource[i]);
        namePlate.UnitFrame.classResource[i].texture:SetColorTexture(0.8, 0.8, 0.8);
	end

    SetupClassResourcePoints(namePlate.UnitFrame.classResource, 6);
    namePlate.UnitFrame.classResource:Hide();

    --namePlate.UnitFrame.classResource.texture = namePlate.UnitFrame.classResource:CreateTexture(nil, "OVERLAY");
    --namePlate.UnitFrame.classResource.texture:SetAllPoints(namePlate.UnitFrame.classResource);
    --namePlate.UnitFrame.classResource.texture:SetColorTexture(0.8, 0.0, 0.0);
    --namePlate.UnitFrame.classResource:Hide();
    
	namePlate.UnitFrame:EnableMouse(false)
end