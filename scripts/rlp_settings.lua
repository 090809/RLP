local env = env
local t = mods.RussianLanguagePack

GLOBAL.setfenv(1, GLOBAL)

--Для тех, кто пользуется ps4 или NACL должна быть возможность сохранять не в ини файле, а в облаке.
--Для этого дорабатываем функционал стандартного класса PlayerProfile

do 
	local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"
	
	local function SetLocalizaitonValue(self, name, value) --Метод, сохраняющий опцию с именем name и значением value
		-- print("SetLocalizaitonValue", name, value, CalledFrom())
		if USE_SETTINGS_FILE then
			TheSim:SetSetting("translation", name, tostring(value))
		else
			self:SetValue(tostring(name), value)
			self.dirty = true
			self:Save() --Сохраняем сразу, поскольку у нас нет кнопки "применить"
		end
	end
	
	local function GetLocalizaitonValue(self, name) --Метод, возвращающий значение опции name
		-- print("GetLocalizaitonValue", name, CalledFrom())
		local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"
		if USE_SETTINGS_FILE then
			return TheSim:GetSetting("translation", name)
		end
		return self:GetValue(name)
	end
	
	local function GetTranslationType(self)
		local val = self:GetLocalizaitonValue("translation_type")
		if not val or not tonumber(val) then
			self:SetLocalizaitonValue("translation_type", t.TranslationTypes.Full)
			return t.TranslationTypes.Full
		end
		return val
	end
	
	local function GetModTranslationEnabled(self)
		local val = self:GetLocalizaitonValue("mod_translation_type")
		if not val or not tonumber(val) then
			self:SetLocalizaitonValue("mod_translation_type", t.ModTranslationTypes.enabled)
			return t.ModTranslationTypes.enabled
		end
		return val
	end

	--Расширяем функционал PlayerProfile дополнительной инициализацией двух методов и заданием дефолтных значений опций нашего перевода.
	--После обновления ни один из этих способов не работает, поэтому делаем тупо через require.
	local self = require "playerprofile"
	
	self.SetLocalizaitonValue = SetLocalizaitonValue
	self.GetLocalizaitonValue = GetLocalizaitonValue
	
	self.GetTranslationType = GetTranslationType
	self.GetModTranslationEnabled = GetModTranslationEnabled
end

t.CurrentTranslationType = Profile:GetTranslationType()

local TEMPLATES = require "widgets/redux/templates"
local LanguageOptions = require "screens/LanguageOptions"
local UpdateChecker = require "widgets/update_checker"

env.AddClassPostConstruct("screens/redux/multiplayermainscreen", function(self, ...)
	--Кнопка настойки в главном меню
	if not self.rlp_settings then
		self.rlp_settings = self:AddChild(TEMPLATES.IconButton("images/rus_button_icon.xml", "rus_button_icon.tex", "RLP", false, true, function() 
			TheFrontEnd:GetSound():KillSound("FEMusic")
			TheFrontEnd:GetSound():KillSound("FEPortalSFX")
			TheFrontEnd:GetSound():PlaySound("dontstarve/music/gramaphone_ragtime", "rlp_ragtime") 
			
			TheFrontEnd:FadeToScreen(TheFrontEnd:GetActiveScreen(), function() return LanguageOptions() end, nil, "swipe")
		end, {font=NEWFONT_OUTLINE}))
		self.submenu:AddCustomItem(self.rlp_settings)
		local _pos = self.submenu:GetPosition()
		self.submenu:SetPosition(_pos.x - 50, _pos.y)
	end
	
	-- Проверка версии
	self.rlp_update_checker = self.fixed_root:AddChild(UpdateChecker())
	self.rlp_update_checker:SetScale(.7)
	self.rlp_update_checker:SetPosition(500, -100)
end)
