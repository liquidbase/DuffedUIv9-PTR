local D, C, L = unpack(select(2, ...))

local L_MAIL_STOPPED = ERR_INV_FULL
local L_MAIL_COMPLETE = DONE
local L_MAIL_NEED = 'Need a mainbox.'
local L_MAIL_MESSAGES = 'Posts'
local deletedelay, t = 0.5, 0
local takingOnlyCash = false
local button, waitForMail, doNothing, openAllCash, openMail, lastopened, stopOpening, onEvent, needsToWait, copper_to_pretty_money, total_cash
local _G = _G
local baseInboxFrame_OnClick
function doNothing() end

function openAll()
	if GetInboxNumItems() == 0 then return end
	button:SetScript('OnClick', nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick
	InboxFrame_OnClick = doNothing
	button:RegisterEvent('UI_ERROR_MESSAGE')
	openMail(GetInboxNumItems())
end

function openAllCash()
	takingOnlyCash = true
	openAll()
end

function openMail(index)
	if not InboxFrame:IsVisible() then return stopOpening('|cffffff00'..L_MAIL_NEED) end
	if index == 0 then MiniMapMailFrame:Hide() stopOpening('|cffffff00'..L_MAIL_COMPLETE) return end
	local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(index)
		if money > 0 then
			TakeInboxMoney(index)
			needsToWait = true
			if total_cash then total_cash = total_cash - money end
		elseif (not takingOnlyCash) and numItems and (numItems > 0) and COD <= 0 then
			TakeInboxItem(index)
			needsToWait = true
		end
		
	local items = GetInboxNumItems()
	if (numItems and numItems > 1) or (items > 1 and index <= items) then
		lastopened = index
		t = 0
		button:SetScript('OnUpdate', waitForMail)
	else
		stopOpening('|cffffff00'..L_MAIL_COMPLETE)
		MiniMapMailFrame:Hide()
	end
end

function waitForMail(self,elapsed)
	t = t + elapsed
	if (not needsToWait) or (t > deletedelay) then
		needsToWait = false
		button:SetScript('OnUpdate', nil)
		local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(lastopened)
		if money > 0 or ((not takingOnlyCash) and COD <= 0 and numItems and (numItems > 0)) then openMail(lastopened) else openMail(lastopened - 1) end
	end
end

function stopOpening(msg, ...)
	button:SetScript('OnClick', openAllCash)
	if baseInboxFrame_OnClick then InboxFrame_OnClick = baseInboxFrame_OnClick end
	button:UnregisterEvent('UI_ERROR_MESSAGE')
	takingOnlyCash = false
	total_cash = nil
	if msg then DEFAULT_CHAT_FRAME:AddMessage(msg, ...) end
end

function onEvent(frame, event, arg1, arg2, arg3, arg4)
	if event == 'UI_ERROR_MESSAGE' then
		if arg1 == ERR_INV_FULL then stopOpening('|cffffff00'..L_MAIL_STOPPED) end
	end
end

local function makeButton(id, text, w, h, x, y)
	local button = CreateFrame('Button', id, InboxFrame, 'UIPanelButtonTemplate')
	button:SetWidth(w)
	button:SetHeight(h)
	button:SetPoint('BOTTOM', MailFrame, 'BOTTOM', x, y)
	button:SetText(text)
	return button
end
button = makeButton('OpenAllButton', 'Gold', 70, 25, 25, 8)
button:SetScript('OnClick', openAllCash)
OpenAllButton:SkinButton()
OpenAllMail:SkinButton()
OpenAllMail:ClearAllPoints()
OpenAllMail:SetWidth(70)
OpenAllMail:SetHeight(25)
OpenAllMail:SetPoint('RIGHT', OpenAllButton, 'LEFT', -2, 0)

function copper_to_pretty_money(c)
	if c > 10000 then
		return ('%d|cffffd700g|r %d|cffc7c7cfs|r %d|cffeda55fc|r'):format(c/10000, (c/100)%100, c%100)
	elseif c > 100 then
		return ('%d|cffc7c7cfs|r %d|cffeda55fc|r'):format((c/100)%100, c%100)
	else
		return ('%d|cffeda55fc|r'):format(c%100)
	end
end

button:SetScript('OnEnter', function()
	if not total_cash then
		total_cash = 0
		for index=0, GetInboxNumItems() do total_cash = total_cash + select(5, GetInboxHeaderInfo(index)) end
	end
	GameTooltip:SetOwner(button, 'ANCHOR_RIGHT')
	GameTooltip:AddLine(copper_to_pretty_money(total_cash), 1, 1, 1)
	GameTooltip:Show()
end)
button:SetScript('OnLeave', function() GameTooltip:Hide() end)