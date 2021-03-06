local _, ns = ...
local oUF = ns.oUF

local UnitIsUnit = UnitIsUnit;
local UnitGUID = UnitGUID;
local UnitExists = UnitExists;
local UnitIsConnected = UnitIsConnected;
local UnitIsVisible = UnitIsVisible;
local SetPortraitTexture = SetPortraitTexture;

local function Update(self, event, unit)
	if(not unit or not UnitIsUnit(self.unit, unit)) then return end

	local element = self.Portrait

	if(element.PreUpdate) then element:PreUpdate(unit) end

	local modelUpdated = false
	local guid = UnitGUID(unit)
	local isAvailable = UnitIsConnected(unit) and UnitIsVisible(unit)
	if(event ~= 'OnUpdate' or element.guid ~= guid or element.state ~= isAvailable) then
		if(element:IsObjectType('PlayerModel')) then
			if(not isAvailable) then
				element:SetCamDistanceScale(0.25)
				element:SetPortraitZoom(0)
				element:SetPosition(0, 0, 0.25)
				element:ClearModel()
				element:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
				modelUpdated = true
			else
				element:SetCamDistanceScale(1)
				element:SetPortraitZoom(1)
				element:SetPosition(0, 0, 0)
				element:ClearModel()
				element:SetUnit(unit)
				modelUpdated = true
			end
		else
			SetPortraitTexture(element, unit)
		end
		element.guid = guid
		element.state = isAvailable
	end

	if(element.PostUpdate) then
		return element:PostUpdate(unit, event, modelUpdated)
	end
end

local function Path(self, ...)
	return (self.Portrait.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local element = self.Portrait
	if(element) then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_MODEL_CHANGED', Path)
		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)

		if(unit == 'party') then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Path)
		end

		element:Show()

		return true
	end
end

local function Disable(self)
	local element = self.Portrait
	if(element) then
		element:Hide()

		self:UnregisterEvent('UNIT_MODEL_CHANGED', Path)
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)