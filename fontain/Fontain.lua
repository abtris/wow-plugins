-- Mostly derived from Tekkub's tekticles, with permission

Fontain = LibStub("AceAddon-3.0"):NewAddon("Fontain", "AceEvent-3.0", "AceConsole-3.0")

local _G = getfenv(0)
local media = LibStub("LibSharedMedia-3.0")
local mod = Fontain
local db
local fontList = {}
local fontDefaults = {}
local type, pairs, ipairs, getmetatable = _G.type, _G.pairs, _G.ipairs, _G.getmetatable
local tinsert, unpack = _G.tinsert, _G.unpack

local defaults = {
	profile = {
		font = media:Fetch("font", media.DefaultMedia.font),
		fonts = {},
		sizes = {},
		flags = {},
		enabled = true
	}
}

mod.fontList = fontList
mod.fontDefaults = fontDefaults

function mod:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("FontainDB", defaults)
	db = self.db.profile
	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profile.order = 101
	self:ApplyFonts()
	
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}
end

function mod:ADDON_LOADED()
	if not db then return end	
	UNIT_NAME_FONT     = media:Fetch("font", db.fonts["UnitNames"]) or UNIT_NAME_FONT
	NAMEPLATE_FONT     = media:Fetch("font", db.fonts["Nameplates"]) or NAMEPLATE_FONT
	DAMAGE_TEXT_FONT   = media:Fetch("font", db.fonts["DamageText"]) or DAMAGE_TEXT_FONT
	STANDARD_TEXT_FONT = media:Fetch("font", db.fonts["StandardText"]) or STANDARD_TEXT_FONT
end
mod:RegisterEvent("ADDON_LOADED")

function mod:OnEnable()
	if not db.enabled then
		self:Disable()
		return
	end
	
	if db.override then
		media:SetGlobal("font", db.font)
	end	
	
	media.RegisterCallback(mod, "LibSharedMedia_Registered")
	media.RegisterCallback(mod, "LibSharedMedia_SetGlobal", "ApplyFonts")
	self:LibSharedMedia_Registered()
	
	for k, v in pairs(_G) do
		-- pcall needed to protect against tables with metatables.
		if type(v) == "table" then
			local meta = getmetatable(v)
			if meta and meta.__index and type(meta.__index) == "table" and meta.__index.GetFont and v:GetObjectType() == "Font" then
				tinsert(fontList, v)
			end
		end
	end
	table.sort(fontList, function(a, b) return #(a:GetName()) > #(b:GetName()) end)
	self:BuildFontMenus()
	self:ApplyFonts()
	
	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")
	
end

function mod:ProfileChanged()
	db = self.db.profile
	if db.override then
		media:SetGlobal("font", db.font)
	end	
	self:RevertFonts()
	self:ApplyFonts()
end

function mod:OnDisable()
	self.db.UnregisterCallback(self, "OnProfileChanged")
	self.db.UnregisterCallback(self, "OnProfileCopied")
	self.db.UnregisterCallback(self, "OnProfileReset")

	media.UnregisterCallback(mod, "LibSharedMedia_Registered")
	media:SetGlobal("font", nil)
	self:RevertFonts()	
end

do
	local fonts, sizes, flags, NORMAL
	
	local function setFont(f, key)
		local n = f:GetName()
		if not fontDefaults[n] then
			fontDefaults[n] = {f:GetFont()}
		end
		key = key or n
		f:SetFont(key and fonts[key] and media:Fetch("font", fonts[key]) or NORMAL, sizes[key] or fontDefaults[n][2], flags[key] or fontDefaults[n][3])
	end

	function mod:ApplyFonts(fontName)
		if not self:IsEnabled() then return end
		fonts = db.fonts
		sizes = db.sizes
		flags = db.flags
		NORMAL = media:Fetch("font", db.font)
		
		self:ADDON_LOADED()
		
		if fontName then
			for _, f in ipairs(fontList) do
				if f:GetName():match("^" .. fontName) then
					setFont(f, fontName)
				end
			end
		else			
			for _, f in ipairs(fontList) do
				local n = f:GetName()
				local keyMatch
				for k, v in pairs(db.fonts) do
					-- Find the shortest key matching the font
					if n:match("^" .. k) and (not keyMatch or #k < #keyMatch) then
						keyMatch = k
					end
				end
				setFont(f, keyMatch)
			end
		end
	end
end

function mod:Dump()
	db.defaults = {}
	db.replaced = {}
	
	db.defaults = fontDefaults
	for _, f in ipairs(fontList) do
		local n = f:GetName()
		db.replaced[n] = {f:GetFont()}
	end
end

function mod:RevertFonts()
	for k, v in pairs(fontDefaults) do
		_G[k]:SetFont(unpack(v))
	end
end
