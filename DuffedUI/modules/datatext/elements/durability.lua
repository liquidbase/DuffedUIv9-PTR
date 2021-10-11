local D, C, L = unpack(select(2, ...))

local InCombatLockdown = InCombatLockdown
local ToggleCharacter = ToggleCharacter
local IsShiftKeyDown = IsShiftKeyDown

local _G = _G
local select = select
local wipe = wipe
local format, pairs = format, pairs
local GetInventoryItemDurability = GetInventoryItemDurability
local ToggleCharacter = ToggleCharacter
local InCombatLockdown = InCombatLockdown
local IsShiftKeyDown = IsShiftKeyDown
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemLink = GetInventoryItemLink
local GetMoneyString = GetMoneyString

local DURABILITY = DURABILITY
local REPAIR_COST = REPAIR_COST
local tooltipString = '%d%%'
local totalDurability = 0
local invDurability = {}
local totalRepairCost

local DataText = D['DataTexts']
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local slots = {
	[1] = _G.INVTYPE_HEAD,
	[3] = _G.INVTYPE_SHOULDER,
	[5] = _G.INVTYPE_CHEST,
	[6] = _G.INVTYPE_WAIST,
	[7] = _G.INVTYPE_LEGS,
	[8] = _G.INVTYPE_FEET,
	[9] = _G.INVTYPE_WRIST,
	[10] = _G.INVTYPE_HAND,
	[16] = _G.INVTYPE_WEAPONMAINHAND,
	[17] = _G.INVTYPE_WEAPONOFFHAND,
}

local OnMouseDown = function(self, btn) ToggleCharacter('PaperDollFrame') end

local OnEnter = function(self)
	if not C['datatext']['ShowInCombat'] then
		if InCombatLockdown() then return end
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(DURABILITY)
	GameTooltip:AddLine(' ')

	for slot, durability in pairs(invDurability) do
		GameTooltip:AddDoubleLine(format('|T%s:14:14:0:0:64:64:4:60:4:60|t  %s', GetInventoryItemTexture('player', slot), GetInventoryItemLink('player', slot)), format(tooltipString, durability), 1, 1, 1, D['ColorGradient'](durability * 0.01, 1, .1, .1, 1, 1, .1, .1, 1, .1))
	end

	if totalRepairCost > 0 then
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(REPAIR_COST, GetMoneyString(totalRepairCost), .6, .8, 1, 1, 1, 1)
	end

	if IsShiftKeyDown() then D['DTConduit']() end

	GameTooltip:AddLine(' ')
	GameTooltip:AddDoubleLine(KEY_BUTTON1..':', L['dt']['durabilityleft'], 1, 1, 1)
	GameTooltip:AddDoubleLine(L['dt']['holdshift'], L['dt']['showconduits'], 1, 1, 1)
	GameTooltip:Show()
end

local function Update(self, event)
	totalDurability = 100
	totalRepairCost = 0

	wipe(invDurability)

	for index in pairs(slots) do
		local currentDura, maxDura = GetInventoryItemDurability(index)
		if currentDura and maxDura > 0 then
			local perc = (currentDura/maxDura)*100
			invDurability[index] = perc

			if perc < totalDurability then
				totalDurability = perc
			end

			totalRepairCost = totalRepairCost + select(3, D['ScanTooltip']:SetInventoryItem('player', index))
		end
	end

	local r, g, b = D['ColorGradient'](totalDurability * .01, 1, .1, .1, 1, 1, .1, .1, 1, .1)
	local hex = D['RGBToHex'](r, g, b)

	self.Text:SetFormattedText(NameColor .. DURABILITY ..  '|r: %s%d%%|r', hex, totalDurability)

	if event == 'MODIFIER_STATE_CHANGED' and not IsAltKeyDown() and GetMouseFocus() == self then OnEnter(self) end
end

local function Enable(self)
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
	self:RegisterEvent('MODIFIER_STATE_CHANGED')
	self:SetScript('OnEvent', Update)
	self:SetScript('OnEnter', OnEnter)
	self:SetScript('OnLeave', GameTooltip_Hide)
	self:SetScript('OnMouseDown', OnMouseDown)
	self:Update()
end

local function Disable(self)
	self.Text:SetText('')
	self:UnregisterAllEvents()
	self:SetScript('OnEvent', nil)
	self:SetScript('OnEnter', nil)
	self:SetScript('OnLeave', nil)
	self:SetScript('OnMouseDown', nil)
end

DataText:Register(DURABILITY, Enable, Disable, Update)