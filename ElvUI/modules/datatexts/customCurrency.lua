﻿local E, L, V, P, G = unpack(select(2, ...));
local DT = E:GetModule("DataTexts")

local select, pairs = select, pairs
local format = string.format

local GetCurrencyInfo = GetCurrencyInfo
local GetCurrencyListInfo = GetCurrencyListInfo
local GetCurrencyListSize = GetCurrencyListSize

local CustomCurrencies = {}
local CurrencyListNameToIndex = {}
local currency, currencyAmount, currencyMax, _

local function OnEvent(self)
	currency = CustomCurrencies[self.name]
	if currency then
		_, currencyAmount, _, _, _, currencyMax = GetCurrencyInfo(currency.ID)
		if currency.DISPLAY_STYLE == "ICON" then
			if currency.SHOW_MAX then
				self.text:SetFormattedText("%s %d / %d", currency.ICON, currencyAmount, currencyMax)
			else
				self.text:SetFormattedText("%s %d", currency.ICON, currencyAmount)
			end
		elseif currency.DISPLAY_STYLE == "ICON_TEXT" then
			if currency.SHOW_MAX then
				self.text:SetFormattedText("%s %s %d / %d", currency.ICON, currency.NAME, currencyAmount, currencyMax)
			else
				self.text:SetFormattedText("%s %s %d", currency.ICON, currency.NAME, currencyAmount)
			end
		else
			if currency.SHOW_MAX then
				self.text:SetFormattedText("%s %s %d / %d", currency.ICON, E:AbbreviateString(currency.NAME), currencyAmount, currencyMax)
			else
				self.text:SetFormattedText("%s %s %d", currency.ICON, E:AbbreviateString(currency.NAME), currencyAmount)
			end
		end
	end
end

local function OnEnter(self)
	if not CustomCurrencies[self.name].USE_TOOLTIP then return; end
	local index = CurrencyListNameToIndex[self.name]
	if not index then return; end

	DT:SetupTooltip(self)
	DT.tooltip:SetCurrencyToken(index)
	DT.tooltip:Show()
end

local function AddCurrencyNameToIndex(name)
	for index = 1, GetCurrencyListSize() do
		local currencyName = GetCurrencyListInfo(index)
		if currencyName == name then
			CurrencyListNameToIndex[name] = index
			break;
		end
	end
end

local function RegisterNewDT(currencyID)
	local name, _, icon = GetCurrencyInfo(currencyID)

	if name then
		CustomCurrencies[name] = {NAME = name, ID = currencyID, ICON = format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t", icon, 16, 16), DISPLAY_STYLE = "ICON", USE_TOOLTIP = true, SHOW_MAX = false, DISPLAY_IN_MAIN_TOOLTIP = true}
		DT:RegisterDatatext(name, {"PLAYER_ENTERING_WORLD", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, nil, OnEnter)
		E.global.datatexts.customCurrencies[currencyID] = CustomCurrencies[name]
		AddCurrencyNameToIndex(name)
	end
end

function DT:RegisterCustomCurrencyDT(currencyID)
	if currencyID then
		RegisterNewDT(currencyID)
	else
		for currencyID, info in pairs(E.global.datatexts.customCurrencies) do
			CustomCurrencies[info.NAME] = {NAME = info.NAME, ID = info.ID, ICON = info.ICON, DISPLAY_STYLE = info.DISPLAY_STYLE, USE_TOOLTIP = info.USE_TOOLTIP, SHOW_MAX = info.SHOW_MAX, DISPLAY_IN_MAIN_TOOLTIP = info.DISPLAY_IN_MAIN_TOOLTIP}
			DT:RegisterDatatext(info.NAME, {"PLAYER_ENTERING_WORLD", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, OnEvent, nil, nil, OnEnter)
			AddCurrencyNameToIndex(info.NAME)
		end
	end
end

function DT:UpdateCustomCurrencySettings(currencyName, option, value)
	if not currencyName or not option then return; end

	if option == "DISPLAY_STYLE" then
		CustomCurrencies[currencyName].DISPLAY_STYLE = value
	elseif option == "USE_TOOLTIP" then
		CustomCurrencies[currencyName].USE_TOOLTIP = value
	elseif option == "SHOW_MAX" then
		CustomCurrencies[currencyName].SHOW_MAX = value
	elseif option == "DISPLAY_IN_MAIN_TOOLTIP" then
		CustomCurrencies[currencyName].DISPLAY_IN_MAIN_TOOLTIP = value
	end
end

function DT:RemoveCustomCurrency(currencyName)
	CustomCurrencies[currencyName] = nil
end