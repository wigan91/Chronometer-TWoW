﻿--<< ====================================================================== >>--
-- Class Setup                                                                --
--<< ====================================================================== >>--
Chronometer = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceConsole-2.0", "AceDebug-2.0", "AceHook-2.1", "CandyBar-2.0", "FuBarPlugin-2.0")
-- embedded libs
local L = AceLibrary("AceLocale-2.2"):new("Chronometer")
local BS = AceLibrary("Babble-Spell-2.2")
local dewdrop = AceLibrary("Dewdrop-2.0")
local waterfall 		= AceLibrary("Waterfall-1.0")
local paint 			= AceLibrary("PaintChips-2.0")
local self 				= Chronometer

Chronometer:RegisterDB("ChronometerDB")

Chronometer.SPELL = 1
Chronometer.EVENT = 2

Chronometer.revision = GetAddOnMetadata("Chronometer-TWoW", "Version");

Chronometer.dataSetup = {}

-- stuff for FuBar:
Chronometer.hasIcon  = "Interface\\AddOns\\Chronometer\\icon"
Chronometer.defaultPosition = "LEFT"
Chronometer.defaultMinimapPosition = 250
Chronometer.cannotDetachTooltip = true
Chronometer.tooltipHiddenWhenEmpty = true
Chronometer.hideWithoutStandby = true
Chronometer.clickableTooltip = false
Chronometer.hasNoColor = true
--Chronometer.independentProfile = true
--Chronometer.overrideMenu = true

Chronometer.rightclick = false

local defaults = {
	barscale = nil,
	growup = false,
	reverse = false,
	fadeonkill = true,
	fadeonfade = true,
	barposition = {},
	bartex = "default",
	ghost = 0,
	selfbars = true,
	barwidth = nil,
	barheight = nil,
	spacing = 0,
	iconposition = "LEFT",
	textsize = 10,
	textcolor = "white",
	bgcolor = "teal",
	barcolor = "gray",
	bordercolor = "black",
	bordertex = "None",
	bgalpha = nil,
	text = "$t",
	showIcon = true,
	showText = true,
	uncolored = true,
	onlyself = false,
	disabledSpells = {
		COMMON = {},
		RACIAL = {},
	},
}
	

Chronometer:RegisterDefaults('profile', defaults)

local media = LibStub("LibSharedMedia-3.0")
media:Register("statusbar", "Frost", "Interface\\Addons\\Chronometer\\Textures\\Frost")
media:Register("statusbar", "banto", "Interface\\Addons\\Chronometer\\Textures\\banto")
media:Register("statusbar", "smooth", "Interface\\Addons\\Chronometer\\Textures\\smooth")
media:Register("statusbar", "perl", "Interface\\Addons\\Chronometer\\Textures\\perl")
media:Register("statusbar", "glaze", "Interface\\Addons\\Chronometer\\Textures\\glaze")
media:Register("statusbar",	"cilo", "Interface\\Addons\\Chronometer\\Textures\\cilo")
media:Register("statusbar",	"charcoal", "Interface\\Addons\\Chronometer\\Textures\\Charcoal")
media:Register("statusbar",	"diagonal", "Interface\\Addons\\Chronometer\\Textures\\Diagonal")
media:Register("statusbar",	"fifths", "Interface\\Addons\\Chronometer\\Textures\\Fifths")
media:Register("statusbar",	"smoothv2", "Interface\\Addons\\Chronometer\\Textures\\Smoothv2")
media:Register("statusbar", "Healbot", "Interface\\Addons\\Chronometer\\Textures\\Healbot")
media:Register("statusbar", "LiteStep", "Interface\\Addons\\Chronometer\\Textures\\LiteStep")
media:Register("statusbar", "Rocks", "Interface\\Addons\\Chronometer\\Textures\\Rocks")
media:Register("statusbar", "Runes", "Interface\\Addons\\Chronometer\\Textures\\Runes")
media:Register("statusbar", "Xeon", "Interface\\Addons\\Chronometer\\Textures\\Xeon")

local options
local latins = {I=1, II=2, III=3, IV=4, V=5, VI=6, VII = 7, VIII = 8, IX = 9, X = 10, XI = 11, XII = 12, XIII = 13, XIV = 14} 

--------------------- FOR DEBUG ----------------------------
local join = function (list, separator)
		-- Type check
		if ( not list or type(list) ~= "table" ) then 
			ChatFrame1:AddMessage("Non-table passed to join");
			return;
		end
		if ( separator == nil ) then separator = ""; end
		
		local i;
		local c = "";
		local msg = "";
		local currType;
		for i,v in list do
			if ( tonumber(i) ) then
				currType = type(v);
				if( currType == "string" or currType == "number") then
					msg = msg .. c .. v;
				else
					msg = msg .. c .. "(" .. tostring(v) .. ")";
				end
				c = separator;
			end
		end
		return msg;		
	end
local printc = function(...)
	DEFAULT_CHAT_FRAME:AddMessage(join(arg, ""))
end
local function printTable(table,rowname,level,spacer)
	if ( level == nil ) then level = 1; end
	
	if ( type(rowname) == "nil" ) then rowname = "ROOT"; 
	elseif ( type(rowname) == "string" ) then 
		rowname = "\""..rowname.."\"";
	elseif ( type(rowname) ~= "number" ) then
		rowname = "*"..type(rowname).."*";
	end

	local msg = (spacer or "");	
	
	if ( table == nil ) then 
		printc(msg,"[",rowname,"] := nil "); return 
	end
	if ( type(table) == "table" and level > 0 ) then
		printc (msg,rowname," = { ");
		for k,v in table do
			if v == nil then printc(msg,"[",rowname,"] := nil "); end
			printTable(v,k,level-1,msg.."  ");
		end
		printc(msg,"}");
	elseif (type(table) == "function" ) then 
		printc(msg,"[",rowname,"] => {{FunctionPtr*}}");
	elseif (type(table) == "userdata" ) then 
		printc(msg,"[",rowname,"] => {{UserData}}");
	elseif (type(table) == "boolean" ) then 
		local value = "true";
		if ( not table ) then
			value = "false";
		end
		printc(msg,"[",rowname,"] => ",value);
	else	
		printc(msg,"[",rowname,"] => ",table);
	end
end
LPrintTable = printTable
---------------------------------------------------------------------  ]]

local function convertcolor(color, ...)

	if type(color) == "string" then
		return paint:GetRGBPercent(color)
	elseif type(color) == "table" then
		return color
	else 
		return {color,arg1,arg2}
end

end
					
local fubarOptions = { "detachTooltip", "colorText", "text", "lockTooltip", "position", "minimapAttach", "hide", "icon" }
do
	local function set(field, value)
		self.db.profile[field] = value
	end
	local function get(field)
		return self.db.profile[field]
	end
	
	local function setcolor(field, c1, c2, c3, c4)
		self.db.profile[field] = {c1, c2, c3, c4}
	end
	local function getcolor(field)
		local color = self.db.profile[field]
		local r,g,b,a
		if type(color) == "string" then
			r,g,b,a = paint:GetRGBPercent(color)
		elseif type(color) == "table" then
			r,g,b,a = unpack(color)
		elseif color == nil then
			r,g,b,a = 1, 1, 1, 1
		end		
		return r,g,b,a
	end
	local hcolor = "|cFF77BBFF"
	options = {
		type = "group",
		icon = "Interface\\AddOns\\Chronometer\\icon",
		args = {
			header = {
				type = "header",
				name = hcolor..L["Chronometer Options"].."  |c88888888 v"..Chronometer.revision,
				icon = "Interface\\AddOns\\Chronometer\\icon",
				order = 1,
			}, 
			mspacer = {	type = "header",	order = 3	},
			main = {
				name = hcolor.. L["General"], type = "group", desc = L["General options"], order = 10,
				args = {
					aheader = {type = "header",	name = hcolor..L["General options"], order = 1 },
					
					
					ghost = {name = L["Ghost"], desc = L["Change the amount of time that ghost bars stay up."], type = "range",  order = 30,
						get = get,
						set = set,
						min = 0, max = 30,
						passValue = 'ghost'},
					kill = {
						name = L["Kill"], desc = L["Toggles whether bars disappear when killing things."], type = "toggle",  order = 40,
						get = get,
						set = set,
						passValue = 'fadeonkill'},
					fade = {
						name = L["Fade"], desc = L["Toggles whether bars disappear when spells fade."], type = "toggle",  order = 50,
						get = get,
						set = set,
						passValue = 'fadeonfade'},
					self = {
						name = L["Self"], desc = L["Toggles bars for spell durations on the player."], type = "toggle",  order = 60,
						get = get,
						set = set,
						passValue = 'selfbars'},
					onlyself = {
						name = L["Only self"], desc =  L["Only self"], type = "toggle", order = 70,
						get = get,
						set = set,
						passValue = 'onlyself',
					},
				},
			},
			timers = {
				name = hcolor.. L["Timers"], type = "group", desc = L["Timers visibility options"], order = 20,
				args = {
					aheader = {type = "header",	name = hcolor..L["Timers visibility options"], order = 1 },
					spellt = {
						classpellheader = {type = "header", name = hcolor..L["Class Spell timers"], order = 1},
						name = L["Class Spells"], desc = L["Class Spell timers"], type = "group", order = 20,
						args = {},
					},
					eventt = {
						classeventheader = {type = "header", name = hcolor..L["Class Event timers"], order = 1},
						name = L["Class Events"], desc = L["Class Event timers"], type = "group", order = 30,
						args = {},
					},
			racial = {
						rheader = {type = "header", name = hcolor..L["Race specific timers"], order = 1},
						name = L["Racial"], desc = L["Race specific timers"], type = "group", order = 50,
						args = {},
					},
			common = {
						comheader = {type = "header", name = hcolor..L["Common timers"], order = 1},
						name = L["Common"], desc = L["Common timers (trinkets, potions, etc.)"], type = "group", order = 70,
						args = {},
					},
				},
					},
						
			bar = {
				name = hcolor.. L["Bar"], desc=L["CandyBar options"], type = "group", order = 50,
				args = {
					test = {name = L["Test"], desc = L["Runs test bars."], type = "execute", func = "RunTest", order = 10,},
					anchor = {name = L["Anchor"], desc = L["Shows the dragable anchor."], type = "execute", func = "ToggleAnchor", order = 5, } ,
					texture = {
						name = L["Bar Texture"], desc = L["Changes the texture of the timer bars."], type = "text", order = 20,
						get = get,
						set = set,
						validate = media:List('statusbar'),
						passValue = 'bartex',
					},
					color = {
						name = L["Bar Color"], desc=L["Set the default bar color."], type = 'color',order = 30,
						get = getcolor,
						set = setcolor,
						--validate = colors,
						passValue = 'barcolor',
					},
					bgcolor = {
						name = L["Background Color"], desc=L["Set the bar background color."], type = 'color',order = 40,
						get = getcolor,
						set = setcolor,
						--validate = colors,
						passValue = 'bgcolor',
					},
					bgalpha = {
						name = L["Background Alpha"],desc = L["Alpha value of the bar background."],type = "range",order = 50,
						get = get,
						set = set,
						min = 0.0, max = 1.0,
						passValue = 'bgalpha',
					},
					
					bordercolor = {
						name = "Border Color", desc="Set the border's color.", type = 'color',order = 60,
						get = getcolor,
						set = setcolor,
						--validate = colors,
						passValue = 'bordercolor',
					},
					bordertex = {
						name = "Border Texture", desc = "Changes the texture of the border of bars.", type = "text", order = 70,
						get = get,
						set = set,
						validate = media:List('border'),
						passValue = 'bordertex',
					},
					
					height = {
						name = L["Bar Height"], desc=L["Set the bar height."], type = "range",order = 90,
						get = get,
						set = set,
						min = 8, max = 30, step = 1,
						passValue = 'barheight',
					},
					width = {
						name = L["Bar Width"], desc=L["Set the bar width."], type = "range",order = 100,
						get = get,
						set = set,
						min = 50, max = 300, step = 1,
						passValue = 'barwidth',
					},
					scale = {
						name = L["Bar Scale"], desc=L["Set the bar scale."], type = "range",order = 103,
						get = get,
						set = set,
						min = 0.5, max = 1.5,
						passValue = 'barscale',
					},
					spacing = {
						name = L["Bar Vertical Spacing"], desc=L["Set the bar vertical spacing."], type = "range",order = 105,
						get = get,
						set = set,
						min = 0, max = 15, step = 1,
						passValue = 'spacing',
					},
					iconposition = {
						name = L["Icon Position"], desc = L["Changes icon position."], type = "text", order = 107,
						get = get,
						set = set,
						validate = { "LEFT", "RIGHT"},
						passValue = 'iconposition',
					},
					growth = {
						name = L["Bar Growth"], desc=L["Toggles bar growing up or downwards."], type = "toggle",order = 110,
						get = function () return self.db.profile.growup end,
						set = function (v) self.db.profile.growup = v
						self:SetCandyBarGroupGrowth("Chronometer", self.db.profile.growup) end,
					},
					reverse = {
						name = L["Reverse"], desc = L["Toggles if bars are reversed (fill up instead of emptying)."], type = "toggle",order = 120,
						get = get,
						set = set,
						passValue = 'reverse',
					},
					text = {
						name = L["Bar Text"], desc=L["Sets the text to be displayed on the bar."], type = "text",order = 130,
						usage = L["Use $s for spell name and $t for the target's name."],
						get = get,
						set = set,
						passValue = 'text',
					},
					textcolor = {
						name = L["Text Color"], desc=L["Set the bar text color."], type = "color",order = 140,
						get = getcolor,
						set = setcolor,
						--validate = colors,
						passValue = 'textcolor',
				},
					textsize = {
						name = L["Text Size"], desc = L["Set the bar text size."], type = "range",order = 150,
						get = get,
						set = set,
						min = 8, max = 20, step = 0.5,
						passValue = 'textsize',
			},
			
		},
			},
			fubar = { 
				type = "group", name = L["Fubar plugin"], desc = L["Fubar plugin options."], order=-15,
				args = {}
			},
		},
	}


end
--Code by Grayhoof (SCT)
local function CloneTable(t)				-- return a copy of the table t
	local new = {};					-- create a new table
	local i, v = next(t, nil);		-- i is an index of t, v = t[i]
	while i do
		if type(v)=="table" then 
			v=CloneTable(v);
		end 
		new[i] = v;
		i, v = next(t, i);			-- get next index
	end
	return new;
end

local function moveChild(source, dest, name)
	--dest[name] = CloneTable( source[name])
	source[name].hidden = true
end
function moveFubarOptions(source)
	source.fubar = { type = "group", name = "Fubar plugin options", desc = "Fubar plugin options.", args = {}}
	for k,v in fubarOptions do
		source[v].hidden = true
		--printc(v)
	--	printTable(source[v],"source['"..v.."']", 3)
		--moveChild(source,source.fubar.args,v)
	end
end



function Chronometer:OnInitialize()

	
	self.spellcache = AceLibrary("SpellCache-1.0")
	self.parser = ParserLib:GetInstance("1.1")
	self.gratuity = AceLibrary("Gratuity-2.0")

	paint:RegisterColor("gray", 0.5,0.5,0.5)
	paint:RegisterColor("forest", 0.0,0.5,0.0)
	paint:RegisterColor("maroon", 0.5,0.0,0.0)
	paint:RegisterColor("navy", 0.0,0.0,0.5)
	paint:RegisterColor("olive", 0.5,0.5,0.0)
	paint:RegisterColor("purple", 0.5,0.0,0.5)
	paint:RegisterColor("teal", 0.0,0.5,0.5)

	local colors = {"white", "black", "blue", "magenta", "cyan", "green", "yellow", "orange", "red", "gray", "forest", "maroon", "navy", "olive", "purple", "teal"}

	self.COLOR_MAP = {
		[0]="olive",[1]="teal",[2]="purple",[3]="forest",
	}

	self.textures = {
		["default"] = nil,
		["banto"] = "Interface\\Addons\\Chronometer\\Textures\\banto",
		["smooth"] = "Interface\\Addons\\Chronometer\\Textures\\smooth",
		["perl"] = "Interface\\Addons\\Chronometer\\Textures\\perl",
		["glaze"] = "Interface\\Addons\\Chronometer\\Textures\\glaze",
		["cilo"] = "Interface\\Addons\\Chronometer\\Textures\\cilo",
		["charcoal"] = "Interface\\Addons\\Chronometer\\Textures\\Charcoal",
		["diagonal"] = "Interface\\Addons\\Chronometer\\Textures\\Diagonal",
		["fifths"] = "Interface\\Addons\\Chronometer\\Textures\\Fifths",
		["smoothv2"] = "Interface\\Addons\\Chronometer\\Textures\\Smoothv2",
	}
	
	

--[[
	options.args.config = {
		name = L["Config"], desc=L["Show GUI Configuration Menu"], type = "execute", guiHidden = true,
		func =  function()
		dewdrop:Open(UIParent, 'children', function() dewdrop:FeedAceOptionsTable(options) end,'cursorX', true, 'cursorY', true) end,
	}
]]
--	options.args.test = { type="group", name = "test", desc = " ", args = {}}
--	
	local t = AceLibrary("AceDB-2.0"):GetAceOptionsDataTable(Chronometer)
	
--	printTable(t,"t",3)
	
	for k,v in pairs(t) do
		if options.args[k] == nil then
			if k == "profile" then 
				options.args["aprofile"] = v  
			else
				options.args[k] = v
			end
		end
	end
	
	for k in t do t[k] = nil end
	table.setn(t,0)
	
	t = AceLibrary("FuBarPlugin-2.0"):GetAceOptionsDataTable(Chronometer)
	for k,v in pairs(t) do
		if not options.args.fubar.args[k] then	options.args.fubar.args[k] = v	end
	end

	
	
	
	waterfall:Register('Chronometer', 'aceOptions', options, 'title','Chronometer Options','colorR', 0.5, 'colorG', 0.8, 'colorB', 0.5,
	'treeLevels', 3)--, 'treeType', "SECTIONS")

	Chronometer:RegisterChatCommand({'/chron', '/chronometer'}, function()
		waterfall:Open('Chronometer')
	end)
	
	self.OnClick = function() waterfall:Open('Chronometer') end
	self.OnMenuRequest = options
		
	Chronometer:RegisterChatCommand({'/chroncl'}, options)
	
	self.OnMenuRequest.args.lockTooltip.hidden = true
	self.OnMenuRequest.args.detachTooltip.hidden = true
	if not FuBar then
		self.OnMenuRequest.args.hide.guiName = "Hide minimap icon"
		self.OnMenuRequest.args.hide.desc = "Hide minimap icon"
	end

	-- create the anchor frame
	self.anchor = self:CreateAnchor(L["Chronometer"], 0,1,0)

	self:RegisterCandyBarGroup("Chronometer")
	self:SetCandyBarGroupPoint("Chronometer", "TOP", self.anchor, "BOTTOM", 0, 0)	
	self:SetCandyBarGroupGrowth("Chronometer", self.db.profile.growup)
	
	dewdrop:InjectAceOptionsTable(self, self.OnMenuRequest)
	--AceLibrary("AceConsole-2.0"):InjectAceOptionsTable(Chronometer, Chronometer.OnMenuRequest)
	--'treeType', "SECTIONS") 
	
	self.options = nil
end

function Chronometer:OnEnable()
	
	
	for k,v in fubarOptions do
--		printc(v)
		if self.OnMenuRequest.args[v] then 
			self.OnMenuRequest.args[v].hidden = true
		else
--			printc("  ->nil")
		end
	end
--	AceLibrary("AceConsole-2.0"):InjectAceOptionsTable(Chronometer, Chronometer.OnMenuRequest.args.fubar)
	
	
	self.groups = {}
	self.timers = {}
	self.bars = {}
	for i = 1, 20 do self.bars[i] = {} end

	for k, v in self.dataSetup do
		v(self)
	end

	-- On-Kill handling (should disable these when we turn off fadeonkill)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_COMBAT_FRIENDLY_DEATH", function (event, info) self:COMBAT_DEATH(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_COMBAT_HOSTILE_DEATH",  function (event, info) self:COMBAT_DEATH(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_COMBAT_XP_GAIN",        function (event, info) self:COMBAT_DEATH(event, info) end)	

	-- Spell fade handling (should be disabled when we turn off fadeonfade)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_AURA_GONE_SELF",  function (event, info) self:SPELL_FADE(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_AURA_GONE_OTHER", function (event, info) self:SPELL_FADE(event, info) end)

	-- Buff/Debuff gain handling
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE",       function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS",        function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS",   function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE",  function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",            function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE",           function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS",  function (event, info) self:SPELL_PERIODIC(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE", function (event, info) self:SPELL_PERIODIC(event, info) end)

	-- Refresh-on-melee hit/crit handling
	local enableRoM = false
	for n, t in pairs(self.timers[self.SPELL]) do
		if t.x.rom or t.x.romc then
			enableRoM = true
			break
		end
	end
	if not enableRom then
		for n, t in pairs(self.timers[self.EVENT]) do
			if t.x.rom or t.x.romc then
				enableRoM = true
				break
			end
		end
	end
	if enableRoM then
		self.parser:RegisterEvent("Chronometer", "CHAT_MSG_COMBAT_SELF_HITS", function (event, info) self:SELF_HITS(event, info) end)
		self.parser:RegisterEvent("Chronometer", "CHAT_MSG_COMBAT_SELF_HITS", function (event, info) self:SELF_CRITS(event, info) end)
	end

	-- Spellcast handling
	self.captive    = {}
	self.active     = {}
	self:Hook("UseAction")
	self:Hook("CastSpell")
	self:Hook("CastSpellByName")
	self:Hook("SpellTargetUnit")
	self:Hook("TargetUnit")
	self:Hook("SpellStopTargeting")
	self:Hook("SpellStopCasting")
	self:HookScript(WorldFrame, "OnMouseDown")
	self:RegisterEvent("SPELLCAST_INTERRUPTED")
	self:RegisterEvent("SPELLCAST_START")
	self:RegisterEvent("SPELLCAST_STOP")
    self:RegisterEvent("PLAYER_DEAD")
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_SELF_DAMAGE", function(event, info) self:SELF_DAMAGE(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF", function(event, info) self:SELF_DAMAGE(event, info) end)
	self.parser:RegisterEvent("Chronometer", "CHAT_MSG_SPELL_FAILED_LOCALPLAYER", function(event, info) self:SPELL_FAILED(event, info) end)
	
	
	-- Fill options with timers
	local _, class = UnitClass("player")
	if self.db.profile.disabledSpells[class] == nil then
		self.db.profile.disabledSpells[class] = {}
	end
	for k,v in pairs(self.timers) do
		local timer_type = k == 1 and "spellt" or "eventt"
		for k1, v1 in pairs(v) do
			local timer_grp, disabled_grp
			if v1.x.cl == "COMMON" then
				timer_grp = "common"
				disabled_grp = "COMMON"
			elseif v1.x.cl == "RACIAL" then
				timer_grp = "racial"
				disabled_grp = "RACIAL"
			else
				timer_grp = "class"
				disabled_grp = class
			end
			local timer_name = k1
			local section_name = string.gsub(timer_name,"(%s+)","_")
			timer_toggle = {
				name = timer_name, type = "toggle", desc = timer_name,
				get = function() return self.db.profile.disabledSpells[disabled_grp][timer_name]==nil and true or false end,
				set = function(f) self.db.profile.disabledSpells[disabled_grp][timer_name] = f==false and {} or nil end,
			}
			if timer_grp == "class" then
				options.args.timers.args[timer_type].args[section_name] = timer_toggle
			else
				options.args.timers.args[timer_grp].args[section_name] = timer_toggle
			end
		end
	end
	
end

function Chronometer:OnDisable()
	if self.bars then
		for i = 1, 20 do
			if self.bars[i].id then
				self:StopCandyBar(self.bars[i].id)
			end
		end
		self.bars = nil
	end
	if self.timers then self.timers = nil end
	if self.groups then self.groups = nil end

	-- Spell cast veriables
	if self.captive    then self.captive    = nil end
	if self.active     then self.active     = nil end

	self.parser:UnregisterAllEvents("Chronometer")
	self:UnregisterAllEvents()
	self:UnhookAll()
end

function Chronometer:RunTest()
	for i = 1, 5 do
		local name = L["Test"]..i
		local target = L["Test"]
		local rank = 1
		local id, slot = name.."-"..target
		for i = 20, 1, -1 do
			if self.bars[i].id == id then
				self:SetCandyBarFade(id, 0, false)
				self:StopCandyBar(self.bars[i].id)
				self:ReallyStopBar(self.bars[i].id)
				break
			end
		end
		for i = 1, 20 do if not self.bars[i].id then slot = i; break end end

		self.bars[slot].id     = id
		self.bars[slot].timer  = timer
		self.bars[slot].name   = name
		self.bars[slot].rank   = rank
		self.bars[slot].target = target
		self.bars[slot].group  = nil

		local duration = math.random() * 8.0 + 2.0
		local text = target == "none" and name or self.db.profile.text
		text = gsub(text, "%t", target)
		text = gsub(text, "%s", name)
		local icon = "Interface\\Icons\\Spell_Shadow_ManaBurn"
		local color = convertcolor(self.db.profile.barcolor)

		self:RegisterCandyBar(id, duration, text, icon, color[1], color[2], color[3], 1,0,0)
		self:RegisterCandyBarWithGroup(id, "Chronometer")
		if self.db.profile.barscale then self:SetCandyBarScale(id, self.db.profile.barscale) end
		if self.db.profile.barwidth then self:SetCandyBarWidth(id, self.db.profile.barwidth) end
		if self.db.profile.barheight then self:SetCandyBarHeight(id, self.db.profile.barheight) end
		if self.db.profile.iconposition then self:SetCandyBarIconPosition(id,self.db.profile.iconposition) end
		if self.db.profile.spacing then self:SetCandyBarGroupVerticalSpacing("Chronometer", self.db.profile.spacing) end
		if self.db.profile.textsize then self:SetCandyBarFontSize(id, self.db.profile.textsize) end
		if self.db.profile.bartex then self:SetCandyBarTexture(id, media:Fetch('statusbar', self.db.profile.bartex)) end
		if self.db.profile.textcolor then local c = convertcolor(self.db.profile.textcolor); self:SetCandyBarTextColor(id, c[1], c[2], c[3] ) end
		if self.db.profile.bgcolor then local c = convertcolor(self.db.profile.bgcolor); self:SetCandyBarBackgroundColor(id, c[1], c[2], c[3] , self.db.profile.bgalpha) end
		if self.db.profile.bordercolor then local c = convertcolor(self.db.profile.bordercolor); self:SetCandyBarBorderColor(id, c[1], c[2], c[3] ) end
		if self.db.profile.bordertex then self:SetCandyBarBorderTexture(id, media:Fetch('border', self.db.profile.bordertex)) end
		if self.db.profile.ghost then self:SetCandyBarFade(id, self.db.profile.ghost, true) end
		self:SetCandyBarCompletion(id, self.StopBar, self, id)
		self:SetCandyBarReversed(id, self.db.profile.reverse)
		self:SetCandyBarOnClick(id, function (...) self:CandyOnClick(unpack(arg)) end)
		self:StartCandyBar(id, true)
	end
end

--<< ====================================================================== >>--
-- Timer Processing                                                           --
--<< ====================================================================== >>--
function Chronometer:AddGroup(id, forall, color)
	if color then
		self.groups[id] = { fa=forall, cr=color }
	else
		self.groups[id] = { fa=forall }
	end
end

function Chronometer:AddTimer(kind, name, duration, targeted, isgain, selforselect, extra)
	if not self.timers[kind]       then self.timers[kind] = {}       end
	if not self.timers[kind][name] then self.timers[kind][name] = {} end
	if not extra then extra = {} end
	targeted = (targeted > 0 ) and 1 or nil
	isgain = (isgain > 0 ) and 1 or nil
	selforselect = (selforselect > 0 ) and 1 or nil
	if not extra.cr then
		if extra.gr and self.groups[extra.gr].cr then extra.cr = self.groups[extra.gr].cr
		else
			local ccode = (targeted and 2 or 0) + (isgain and 1 or 0)
			extra.cr = self.COLOR_MAP[ccode]
		end
	end
	self.timers[kind][name] = { d=duration, k={t=targeted,g=isgain,s=selforselect}, x=extra }
end

function Chronometer:StartTimer(timer, name, target, rank, durmod)
	target = self:DisambiguateTarget(timer, target)

	local id_target = target
	do
		local sp = (BS and BS["Scorpid Poison"]) or "Scorpid Poison"
		if name == sp and target and target ~= "none" then
			local label = tostring(target)
			local base  = label
			local p_hash = string.find(label, " #", 1, true)
			if p_hash then base = string.sub(base, 1, p_hash-1) end
			local p_rt = string.find(base, " {RT", 1, true)
			if p_rt   then base = string.sub(base, 1, p_rt-1) end

			local guid = self:SPGetGUIDForName(base)
			if guid then
				self._spGuidOrdinal = self._spGuidOrdinal or {}
				self._spGuidOrdinal[base] = self._spGuidOrdinal[base] or {}
				local ord = self._spGuidOrdinal[base][guid]
				if not ord then
					local used = {}
					for _,o in pairs(self._spGuidOrdinal[base]) do
						if type(o) == "number" then used[o] = true end
					end
					local n = 1
					while used[n] do n = n + 1 end
					ord = n
					self._spGuidOrdinal[base][guid] = ord
				end

				id_target = base.." #"..guid
				target    = base.." #"..ord
			end
		end
	end
	-- check if spell is disabled
	local _, class = UnitClass("player")
	local timer_class = timer.x.cl == nil and class or timer.x.cl
	if self.db.profile.disabledSpells[timer_class][name]~=nil then return end

	if not target then target = "none" end
	if not rank then rank = timer.r or 0 end
	if not durmod then durmod = 0 end
	if timer.x.gr then self:CleanGroup(timer.x.gr, target) end
	if timer.d == 0 then return end
	if (not self.db.profile.selfbars) and (target == UnitName("player") or (target == "none" and timer.k.g)) then return end
	if (self.db.profile.onlyself) and (timer.k.t ~= nil and target ~= UnitName("player")) then return end

	local id, slot = name.."-"..id_target

	for i = 20, 1, -1 do
		if self.bars[i].id == id then
			self:SetCandyBarFade(id, 0, false)
			self:StopCandyBar(self.bars[i].id)
			self:ReallyStopBar(self.bars[i].id)
			break
		end
	end
	for i = 1, 20 do if not self.bars[i].id then slot = i; break end end

	
	self.bars[slot].id     = id
	self.bars[slot].timer  = timer
	self.bars[slot].name   = name
	self.bars[slot].rank   = rank
	self.bars[slot].target = target
	self.bars[slot].group  = timer.x.gr

	local duration = (timer.x.d and self:GetDuration(timer.d, timer.x.d, rank, timer.cp) or timer.d) + durmod
	local text = target == "none" and name or self.db.profile.text
	text = gsub(text, "$t", target)
	text = gsub(text, "$s", name)
	local icon = timer.x.tx or self:GetTexture(name, timer.x)
	local color = timer.x.cr or self.db.profile.barcolor
	color = convertcolor(color)
	local fade = 0.5

	if timer.x.rc and self.db.profile.ghost then
		fade = self.db.profile.ghost
	end

	self:RegisterCandyBar(id, duration, text, icon, color[1], color[2], color[3], 1,0 ,0)
	self:RegisterCandyBarWithGroup(id, "Chronometer")
	if self.db.profile.barscale then self:SetCandyBarScale(id, self.db.profile.barscale) end
	if self.db.profile.barwidth then self:SetCandyBarWidth(id, self.db.profile.barwidth) end
	if self.db.profile.barheight then self:SetCandyBarHeight(id, self.db.profile.barheight) end
	if self.db.profile.iconposition then self:SetCandyBarIconPosition(id,self.db.profile.iconposition) end
	if self.db.profile.spacing then self:SetCandyBarGroupVerticalSpacing("Chronometer", self.db.profile.spacing) end
	if self.db.profile.textsize then self:SetCandyBarFontSize(id, self.db.profile.textsize) end
	if self.db.profile.bartex then self:SetCandyBarTexture(id, media:Fetch('statusbar', self.db.profile.bartex)) end
	if self.db.profile.textcolor then local c = convertcolor(self.db.profile.textcolor); self:SetCandyBarTextColor(id, c[1], c[2], c[3] ) end
	if self.db.profile.bgcolor then local c = convertcolor(self.db.profile.bgcolor); self:SetCandyBarBackgroundColor(id, c[1], c[2], c[3] , self.db.profile.bgalpha) end
	if self.db.profile.bordercolor then local c = convertcolor(self.db.profile.bordercolor); self:SetCandyBarBorderColor(id, c[1], c[2], c[3] ) end
	if self.db.profile.bordertex then self:SetCandyBarBorderTexture(id, media:Fetch('border', self.db.profile.bordertex)) end
	self:SetCandyBarFade(id, fade, true)
	self:SetCandyBarCompletion(id, self.StopBar, self, id)
	self:SetCandyBarReversed(id, self.db.profile.reverse)
	self:SetCandyBarOnClick(id, function (...) self:CandyOnClick(unpack(arg)) end, timer.x.rc, timer.x.mc)
	self:StartCandyBar(id, true)
end


function Chronometer:DisambiguateTarget(timer, t)
	if not timer or not timer.x or not timer.x.dn then return t end
	local base = tostring(t or "")
	if base == "" then return base end

	if string.find(base, " #", 1, true) or string.find(base, "{RT", 1, true) then
		return base
	end

	local unit
	if UnitExists("pettarget") and UnitName("pettarget") == base then unit = "pettarget" end
	if UnitExists("target") and UnitName("target") == base and not unit then unit = "target" end

	local withIcon
	if unit then
		local idx = GetRaidTargetIndex(unit)
		if idx then withIcon = base.." {RT"..idx.."}" end
	end

	local function used(lbl)
		for i=1,20 do
			local b = self.bars[i]
			if b and b.id and b.target == lbl then
				if not timer.x.gr or (b.timer and b.timer.x and b.timer.x.gr == timer.x.gr) then
					return true
				end
			end
		end
		return false
	end

	if withIcon and not used(withIcon) then
		return withIcon
	end

	if not used(base) then return base end
	for n = 2, 9 do
		local cand = base.." #"..n
		if not used(cand) then return cand end
	end

	return base.." #?"
end

function Chronometer:GetDuration(duration, record, rank, cp)
	if record.rt then duration = record.rt[rank] or duration end
	if record.rs then duration = duration + (rank-1) * record.rs end
	
	--local combopoints = GetComboPoints('player', 'target')
	--self:Print("CP" ..  cp)
	--self:Print("combopoints" ..  combopoints)

	if record.cp then duration = duration + (cp - 1) * record.cp end --or combopoints) - 1) * record.cp end
	
	
	
	if record.tn then
		if type(record.tn) == "string" then record.tn = self:GetTalentPosition(record.tn) end
		local _,_,_,_, tr = GetTalentInfo(unpack(record.tn))
		if tr > 0 then
			local gain = record.tt and record.tt[tr] or (record.tb + (tr-1) * (record.ts or record.tb))
			duration = duration + (record.tp and (duration/100) * gain or gain)
		end
	end
	return duration
end

function Chronometer:GetTexture(name, record)
	if record.xn then name = record.xn end
	record.tx = BS:GetSpellIcon(name)
	return record.tx
--[[	
	local i = 1
	while true do
		local nm = GetSpellName(i, BOOKTYPE_SPELL)
		if not nm then break
		elseif nm == name then
			record.tx = GetSpellTexture(i, BOOKTYPE_SPELL)
			return record.tx
		end
		i = i + 1
	end
	local tp = self:GetTalentPosition(name)
	if tp then
		local _, tx = GetTalentInfo(unpack(tp))
		record.tx = tx
		return record.tx
	end
	if HasPetSpells() then
		for i =1, NUM_PET_ACTION_SLOTS do
			local nm, _, tx = GetPetActionInfo(i)
			if nm == name then record.tx = tx; return record.tx end
		end
	end
]]
end

function Chronometer:GetTalentPosition(name)
	for i = 1, GetNumTalentTabs() do
		for j = 1, GetNumTalents(i) do
			if GetTalentInfo(i, j) == name then return {i, j} end
		end
	end
end

--<< ====================================================================== >>--
-- Bar Processing                                                             --
--<< ====================================================================== >>--

-- I hate having special-purpose stuff in here, but I guess banish is pretty unique as far as bar timers go
function Chronometer:IsBanished(target)
	for i = 1, 20 do
		if self.bars[i].id then
			if self.bars[i].target == target and self.bars[i].name == BS["Banish"] then
				return true
			end
		end
	end
	return false
end

function Chronometer:CleanGroup(group, target)
	local forall = self.groups[group].fa
	for i = 20, 1, -1 do
		if self.bars[i].group and self.bars[i].group == group then
			if forall then
				self:StopCandyBar(self.bars[i].id)
				self:StopBar(self.bars[i].id)
			elseif self.bars[i].target == target then
				self:StopCandyBar(self.bars[i].id)
				self:StopBar(self.bars[i].id)
				break
			end
		end
	end
end

function Chronometer:KillBar(name, unit)
	for i = 20, 1, -1 do
		if self.bars[i].id then
			if self.bars[i].name == name then
				if not unit then
					if self.bars[i].timer.k.t then unit = UnitName("player") else unit = "none" end
				end
				if self.bars[i].target == unit then
					self:StopCandyBar(self.bars[i].id)
					return self:StopBar(self.bars[i].id)
				end
			end
		end
	end
end

function Chronometer:KillBars(unit)
	if unit and UnitExists("target") and UnitName("target") == unit and not UnitIsDeadOrGhost("target") then return end
	for i = 20, 1, -1 do
		if self.bars[i].id then
			if not unit or self.bars[i].target == unit then
				self:SetCandyBarFade(self.bars[i].id, 0.5, true)
				self:StopCandyBar(self.bars[i].id)
				self:ReallyStopBar(self.bars[i].id)
			end
		end
	end
end

function Chronometer:StopBar(id)
	if self.db.profile.ghost and self.db.profile.ghost > 0 then
		self:ScheduleEvent("ChronometerReallyStop"..id, self.ReallyStopBar, self.db.profile.ghost, self, id)
	else
		self:ReallyStopBar(id)
	end
end

function Chronometer:ReallyStopBar(id)
	self:CancelScheduledEvent("ChronometerReallyStop"..id)
	for i = 1, 20 do
		if self.bars[i].id == id then
			for k in self.bars[i] do self.bars[i][k] = nil end
		end
	end
	for i = 1, 19 do
		if not self.bars[i].id then
			local temp = self.bars[i]
			for j = i + 1, 20 do
				if self.bars[j].id then
					self.bars[i] = self.bars[j]; self.bars[j] = temp; temp = nil
					break
				end
			end
			if temp then break end
		end
	end
end

function Chronometer:CandyOnClick(id, button, reactive, middlecast)
	if button == "RightButton" then
		MouselookStart()
		Chronometer.rightclick = true
		self:ScheduleEvent(function() Chronometer.rightclick = false;  Chronometer:CancelScheduledEvent("ChronometerCheckMouselook") end, 0.5)
		self:ScheduleRepeatingEvent("ChronometerCheckMouselook",Chronometer.onClickStopCandyBar, 0.06, self, id)
	elseif button == "MiddleButton" and middlecast then
		for i = 1, 20 do
			if self.bars[i].id == id then
				return self:CastSpellOnUnit(middlecast, self.bars[i].target)
			end
		end
	elseif button == "LeftButton" and reactive then
		for i = 1, 20 do
			if self.bars[i].id == id then
				if self.bars[i].rank > 0 then
					return self:CastSpellOnUnit(self.spellcache:GetSpellNameText(self.bars[i].name, self.bars[i].rank), self.bars[i].target)
				else
					return self:CastSpellOnUnit(self.bars[i].name, self.bars[i].target)
				end
			end
		end
	end
end

function Chronometer:onClickStopCandyBar(id)
	if Chronometer.rightclick and not IsMouselooking() then
		self:SetCandyBarFade(id, 0.5, true)
		self:StopCandyBar(id)
		self:StopBar(id)
	end
end

-- This is blatantly stolen from Clique
function Chronometer:CastSpellOnUnit(spell, unit)

	local restore = nil
	local hadtarget = UnitExists("target")
	
	if unit and unit ~= "none" then
		if hadtarget and UnitName("target") ~= unit then
			restore = true
		end

		TargetByName(unit, true)
	end
	
	CastSpellByName(spell)

	if restore then
		TargetLastTarget()
	elseif not hadtarget then
		ClearTarget()
	end
end

--<< ====================================================================== >>--
-- Anchor Processing                                                          --
--<< ====================================================================== >>--

-- Toggles the vis of the anchors
function Chronometer:ToggleAnchor()
	if self.anchor:IsVisible() then
		self.anchor:Hide()
	else
		self.anchor:Show()
	end
end

-- Creates the anchor frames
function Chronometer:CreateAnchor(text, cRed, cGreen, cBlue)
	local f = CreateFrame("Button", nil, UIParent)
	f:SetWidth(200)
	f:SetHeight(25)

	f.owner = self

	if self.db.profile.barposition.x and self.db.profile.barposition.y then
		f:ClearAllPoints()
		f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", self.db.profile.barposition.x, self.db.profile.barposition.y)
	else
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
	end

	f:SetScript("OnDragStart", function() this:StartMoving() end )
	f:SetScript("OnDragStop",
		function()
			this:StopMovingOrSizing()
			local _, _, _, x, y = this:GetPoint()
			this.owner.db.profile.barposition.x = math.floor(x)
			this.owner.db.profile.barposition.y = math.floor(y)
        end)

	f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                                            tile = false, tileSize = 16, edgeSize = 16,
                                            insets = { left = 5, right =5, top = 5, bottom = 5 }})
	f:SetBackdropColor(cRed,cGreen,cBlue,.6)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")

	f.Text = f:CreateFontString(nil, "OVERLAY")
	f.Text:SetFontObject(GameFontNormalSmall)
	f.Text:ClearAllPoints()
	f.Text:SetTextColor(1, 1, 1, 1)
	f.Text:SetWidth(200)
	f.Text:SetHeight(25)
	f.Text:SetPoint("TOPLEFT", f, "TOPLEFT")
	f.Text:SetJustifyH("CENTER")
	f.Text:SetJustifyV("MIDDLE")
	f.Text:SetText(text)

	f:Hide()

	return f
end

--<< ====================================================================== >>--
-- Event/Hook processing                                                         --
--<< ====================================================================== >>--

-- On-Kill processing
function Chronometer:COMBAT_DEATH(event, info)
	if not self.db.profile.fadeonkill then return end
	if info.type == "experience" then
		-- If it's banished, then it can't possibly die - must be a duplicate NPC name
		if info.source and not self:IsBanished(info.source) then
			self:ScheduleEvent(self.KillBars, 0.5, self, info.source)
			return
		end
	elseif info.victim ~= ParserLib_SELF then
		self:ScheduleEvent(self.KillBars, 0.5, self, info.victim)
		return
	end
end

-- On-Fade processing
function Chronometer:SPELL_FADE(event, info)
	if not self.db.profile.fadeonfade then return end
	-- I hate special casing stuff like this - but let's not ever let a banish bar fade
	if info.skill == BS["Banish"] then return end
	if info.type == "fade" then
		if info.victim == ParserLib_SELF then
			return self:KillBar(info.skill)
		else
			return self:KillBar(info.skill, info.victim)
		end
	end
end

-- Buff/Debuff handling
function Chronometer:SPELL_PERIODIC(event, info)
	local _, aura, rank, unit, isgain

	if info.type == "buff" then
		isgain = 1
	elseif info.type == "debuff" then
		isgain = nil
	elseif info.isDOT then
	else
		return
	end

	if info.victim ~= ParserLib_SELF then
		unit = info.victim
	end
	aura = info.skill
	_, _, rank = string.find(aura,"%s([IVX]+)[^u]")
	if rank then
		rank = latins[rank]
		aura = string.gsub(aura,"%s([IVX]+)[^u]","")
	end
	
	self:Debug(join({aura,rank}," | "))
	
	if aura == "Deep Wound" then aura = "Deep Wounds"  end   

	local timer = self.timers[self.EVENT][aura]	
	if timer and timer.k.g == isgain and not info.isDOT and (timer.x.a or (timer.v and timer.v > GetTime())) then
		if timer.k.t then
			if not unit then unit = UnitName("player") end
			if timer.k.s then
				if timer.t and timer.t ~= unit then return end
			else
				if not UnitExists("target") or unit ~= UnitName("target") then return end
			end
		else
			if not timer.k.s or not unit then unit = "none" else return end
		end
		timer.v = nil; timer.t = nil;
		self:StartTimer(timer, aura, unit, rank)
	elseif timer and  info.isDOT and not timer.x.a then
		timer.v = nil; timer.t = nil;
		self:StartTimer(timer, aura, "none")
	end
end


function Chronometer:SELF_CRITS(event, info)
		-- Process refresh-on-crit buffs (flurry)
	if info.type == "hit" and info.source == ParserLib_SELF and info.isCrit then
		for i = 1, 20 do
			if self.bars[i].id then
				if self.bars[i].timer.x.romc then
					self:StartTimer(self.bars[i].timer, self.bars[i].name, self.bars[i].target, self.bars[i].rank)
				end
			end
		end
	end
end

-- Now spellcast handling - the big one

--<< ====================================================================== >>--
-- Helpers                                                                    --
--<< ====================================================================== >>--

function Chronometer:PLAYER_DEAD()
	self.active = {}
	self.captive = {}

	local unit = UnitName("player")
	for i = 20, 1, -1 do
		if self.bars[i].id then
			if self.bars[i].target == unit or (self.bars[i].target == "none" and self.bars[i].timer.k.g) then
				self:SetCandyBarFade(self.bars[i].id, 0.5, true)
				self:StopCandyBar(self.bars[i].id)
				self:ReallyStopBar(self.bars[i].id)
			end
		end
	end
end

--<< ====================================================================== >>--
-- Catch Spellcast                                                            --
--<< ====================================================================== >>--
function Chronometer:UseAction(slot, clicked, onself)
	if not GetActionText(slot) and HasAction(slot) then
		self.gratuity:SetAction(slot)
		spellName = self.gratuity:GetLine(1)
		spellRank = self.gratuity:GetLine(1, true)
		local name, _, _, _, rank = self.spellcache:GetSpellData(spellName, spellRank)
		local timer = self.timers[Chronometer.SPELL][name]
		if timer then
			self:CatchSpellcast(timer, name, rank, onself)
		end
	end
	return self.hooks["UseAction"](slot, clicked, onself)
end

function Chronometer:CastSpell(index, booktype)
	local name, rank = GetSpellName(index, booktype)
	local timer = self.timers[Chronometer.SPELL][name]
	if timer then
		if not rank or rank == "" then
			rank = 0
		else
			rank = self.spellcache:GetRankNumber(rank)
		end
		self:CatchSpellcast(timer, name, rank)
	end
	return self.hooks["CastSpell"](index, booktype)
end

function Chronometer:CastSpellByName(text, onself)
	local name, _, _, _, rank = self.spellcache:GetSpellData(text, nil)
	local timer = self.timers[Chronometer.SPELL][name]
	if timer then
		self:CatchSpellcast(timer, name, rank, oneself)
	end
	return self.hooks["CastSpellByName"](text, onself)
end

function Chronometer:CatchSpellcast(timer, name, rank, onself)
	local unit
	if timer.k.t then
		if timer.k.s then
			if onself and onself == 1 then unit = UnitName("player")
			elseif UnitExists("target") then
				if timer.k.g then
					if UnitIsFriend("player", "target") then unit = UnitName("target") end
				else
					if UnitCanAttack("player", "target") then unit = UnitName("target") end
				end
			end
		else
			if UnitExists("target") then unit = UnitName("target") else return end
		end
	else
		unit = "none"
	end	
	local cp = GetComboPoints()
	if cp>0 then timer.cp = cp end
	table.insert(self.captive, {t=timer, n=name, u=unit, r=rank})
end

--<< ====================================================================== >>--
-- Catch Spellcast Target                                                     --
--<< ====================================================================== >>--
function Chronometer:SpellTargetUnit(unit)
	for k, captive in pairs(self.captive) do
		if not captive.u then
			captive.u = UnitName(unit)
		end
	end
	return self.hooks["SpellTargetUnit"](unit)
end

function Chronometer:TargetUnit(unit)
	for k, captive in pairs(self.captive) do
		if not captive.u then
			captive.u = UnitName(unit)
		end
	end
	return self.hooks["TargetUnit"](unit)
end

function Chronometer:OnMouseDown()
	for k, captive in pairs(self.captive) do
		if not captive.u and arg1 == "LeftButton" and UnitExists("mouseover") then
			captive.u = UnitName("mouseover")
		end
	end
	return self.hooks[WorldFrame]["OnMouseDown"](WorldFrame, arg1)
end

--<< ====================================================================== >>--
-- Complete Spellcast                                                         --
--<< ====================================================================== >>--
function Chronometer:SPELLCAST_START()
	
end

function Chronometer:SPELLCAST_STOP()
	--self:Print("--CP" .. GetComboPoints())
	local captive = self.captive[1]
	if captive then

		-- We don't know for sure that the spell hit yet, but go ahead and activate events or else we might miss them
		if captive.t and captive.t.x.ea then
			for name, valid in pairs(captive.t.x.ea) do
				local event = self.timers[Chronometer.EVENT][name]
				event.r = self.captive.r
				event.v = GetTime() + valid
				if captive.u ~= "none" then event.t = captive.u end
			end
		end

		if captive.u == "none" then
	--		self:Print("-_-CP" .. captive.cp)
			self:StartTimer(captive.t,captive.n, captive.u, captive.r)
		else
			self.active[captive.n] = {t=captive.t, n=captive.n, u=captive.u, r=captive.r}
			--self.active[captive.n].t.cp = captive.t.cp
			self:ScheduleEvent(self.CompleteCast, 0.5, self, captive.n)
		end
	end
	self.captive = {}
end

function Chronometer:CompleteCast(name)
	local active = self.active[name]
	if active and active.t then
		self:StartTimer(active.t, active.n, active.u, active.r, -0.5)
		self.active[name] = nil
	end
end

--<< ====================================================================== >>--
-- Drop Spellcast                                                             --
--<< ====================================================================== >>--
function Chronometer:SpellStopCasting()
	self.captive = {}
	return self.hooks["SpellStopCasting"]()
end

function Chronometer:SpellStopTargeting()
	self.captive = {}
	return self.hooks["SpellStopTargeting"]()
end

function Chronometer:SPELL_FAILED(event, info)
	for k, captive in pairs(self.captive) do
		if captive.n == info.skill then
			table.remove(self.captive, k)
			break
		end
	end
end

function Chronometer:SPELLCAST_INTERRUPTED()
	for k, active in pairs(self.active) do
		-- The spell missed - disable events activated by this spell
		if active.t and active.t.x.ea then
			for name, valid in pairs(active.t.x.ea) do
				local event = self.timers[Chronometer.EVENT][name]
				event.r = nil; event.v = nil; event.t = nil
			end
		end
	end

	self.active = {}
end

function Chronometer:SELF_DAMAGE(event, info)
	local active = self.active[info.skill]
	if active and info.type == "miss" and info.victim == active.u then

		-- The spell missed - disable events activated by this spell
		if active.t and active.t.x.ea then
			for name, valid in pairs(active.t.x.ea) do
				local event = self.timers[Chronometer.EVENT][name]
				event.r = nil; event.v = nil; event.t = nil
			end
		end
		self.active[info.skill] = nil
	elseif active and info.type == "hit" and info.victim == active.u then
		if active.t and active.t.x.ea then
			for name, valid in pairs(active.t.x.ea) do
				local event = self.timers[Chronometer.EVENT][name]
				for i = 1, 20 do
					if self.bars[i].id and self.bars[i].id == name.."-"..info.victim then
						self:StartTimer(self.bars[i].timer, self.bars[i].name, self.bars[i].target, self.bars[i].rank)
					end
				end
			end
		end
	end
end

function Chronometer:SELF_HITS(event, info)
	-- Process refresh-on-hit debuffs (judgements)
	if info.type == "hit" and info.source == ParserLib_SELF then
		for i = 1, 20 do
			if self.bars[i].id then
				if self.bars[i].target == info.victim and self.bars[i].timer.x.rom then
					self:StartTimer(self.bars[i].timer, self.bars[i].name, self.bars[i].target, self.bars[i].rank)
				end
			end
		end
	end
end

function Chronometer:SPGetGUIDForName(base)
  local name = tostring(base or "")
  if name == "" then return nil end

  local function guidOf(unit)
    local exists, guid = UnitExists(unit)  -- SuperWoW: 2º retorno = GUID
    if exists and guid and UnitName(unit) == name then
      return guid
    end
    return nil
  end

  return guidOf("pettarget") or guidOf("target") or guidOf("mouseover")
end