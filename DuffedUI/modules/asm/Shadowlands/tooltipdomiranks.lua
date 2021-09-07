local D, C, L = unpack(select(2, ...))
local Module = D:NewModule('TooltipDomiRanks', 'AceHook-3.0', 'AceEvent-3.0')

local _G = _G
local select = _G.select
local string_format = _G.string.format
local string_find = _G.string.find
local string_match = _G.string.match
local tonumber = _G.tonumber

local GetItemInfo = _G.GetItemInfo
local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink

local DOMI_RANK_STRING = '%s (%d/5)'
local nameCache = {}

Module.DomiRankData = {}
Module.DomiIndexData = {}
Module.DomiDataByGroup = {
	[1] = {
		[187079] = 1,
		[187292] = 2,
		[187301] = 3,
		[187310] = 4,
		[187320] = 5,
	},
	[2] = {
		[187076] = 1,
		[187291] = 2,
		[187300] = 3,
		[187309] = 4,
		[187319] = 5,
	},
	[3] = {
		[187073] = 1,
		[187290] = 2,
		[187299] = 3,
		[187308] = 4,
		[187318] = 5,
	},
	[4] = {
		[187071] = 1,
		[187289] = 2,
		[187298] = 3,
		[187307] = 4,
		[187317] = 5,
	},
	[5] = {
		[187065] = 1,
		[187288] = 2,
		[187297] = 3,
		[187306] = 4,
		[187316] = 5,
	},
	[6] = {
		[187063] = 1,
		[187287] = 2,
		[187296] = 3,
		[187305] = 4,
		[187315] = 5,
	},
	[7] = {
		[187061] = 1,
		[187286] = 2,
		[187295] = 3,
		[187304] = 4,
		[187314] = 5,
	},
	[8] = {
		[187059] = 1,
		[187285] = 2,
		[187294] = 3,
		[187303] = 4,
		[187313] = 5,
	},
	[9] = {
		[187057] = 1,
		[187284] = 2,
		[187293] = 3,
		[187302] = 4,
		[187312] = 5,
	},
}

local domiTextureIDs = {
	[457655] = true,
	[1003591] = true,
	[1392550] = true,
}

for index, value in pairs(Module.DomiDataByGroup) do
	for itemID, rank in pairs(value) do
		Module.DomiRankData[itemID] = rank
		Module.DomiIndexData[itemID] = index
	end
end

function Module:GetDomiName(itemID)
	local name = nameCache[itemID]
	if not name then
		name = GetItemInfo(itemID)
		nameCache[itemID] = name
	end
	return name
end

function Module:Domination_UpdateText(name, rank)
	local tex = _G[self:GetName()..'Texture1']
	local texture = tex and tex:IsShown() and tex:GetTexture()
	if texture and domiTextureIDs[texture] then
		local textLine = select(2, tex:GetPoint())
		local text = textLine and textLine:GetText()
		if text then
			textLine:SetText(text..'|n'..format(DOMI_RANK_STRING, name, rank))
		end
	end
end

function Module:Domination_CheckStatus()
	local _, link = self:GetItem()
	if not link then return end

	local itemID = GetItemInfoFromHyperlink(link)
	local rank = itemID and Module.DomiRankData[itemID]

	if rank then
		-- Domi rank on gems
		local textLine = _G[self:GetName()..'TextLeft2']
		local text = textLine and textLine:GetText()
		if text and strfind(text, '|cFF66BBFF') then
			textLine:SetFormattedText(DOMI_RANK_STRING, text, rank)
		end
	else
		-- Domi rank on gears
		local gemID = strmatch(link, 'item:%d+:%d*:(%d*):')
		itemID = tonumber(gemID)
		rank = itemID and Module.DomiRankData[itemID]
		if rank then
			local name = Module:GetDomiName(itemID)
			Module.Domination_UpdateText(self, name, rank)
		end
	end
end

function Module:OnEnable()
	if C['tooltip']['DomiRanks'] ~= true then return end

	GameTooltip:HookScript('OnTooltipSetItem', Module.Domination_CheckStatus)
	ItemRefTooltip:HookScript('OnTooltipSetItem', Module.Domination_CheckStatus)
	ShoppingTooltip1:HookScript('OnTooltipSetItem', Module.Domination_CheckStatus)
	EmbeddedItemTooltip:HookScript('OnTooltipSetItem', Module.Domination_CheckStatus)
end