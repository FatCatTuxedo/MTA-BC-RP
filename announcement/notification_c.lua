--MAXIME / 2015.1.9
local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()
local font = dxCreateFont (":resources/cartwheel.otf" , 10 )
local unreads = 0
local notis = {}
--SETTINGS
local imgw, imgh = 51, 32 --icon size
local bulletW, bulletH = 16,16--bullet size
local bgw, bgh = 110, 15 --bg size
local bgDetailOffsetX, bgDetailOffsetY = 0, 20
local thumpOffsetX, thumpOffsetY = 100, -6
local globalOffSetX, globalOffSetY = (getElementData(localPlayer, "hud:whereToDisplay") or 0 ) - 200, getElementData(localPlayer, "hud:whereToDisplayY") or 0
local refreshRate1, refreshRate2 = 5, 10 --minutes
local showPreview = false
--[[
local invisibleArea = guiCreateWindow ( thumpOffsetX+globalOffSetX, thumpOffsetY+globalOffSetY, imgw+bgw , imgh+bgh , "" ,false)
guiSetAlpha(invisibleArea, 0)
guiWindowSetMovable ( invisibleArea, false )
guiWindowSetSizable ( invisibleArea, false )
]]
local justClicked_title = false
function drawPmThump()
	if exports.hud:isActive() and getElementData(localPlayer, "loggedin") == 1 and not isPlayerMapVisible() then
		globalOffSetX = (getElementData(localPlayer, "hud:whereToDisplay") or 0 ) - 75
		globalOffSetY = getElementData(localPlayer, "hud:whereToDisplayY") or 0
		local posxIcon = globalOffSetX

		if unreads > 0 then
			dxDrawImage ( posxIcon+thumpOffsetX, 5+globalOffSetY, imgw, imgh, "unread.png")
		else
			dxDrawImage ( posxIcon+thumpOffsetX, 5+globalOffSetY, imgw, imgh, "read.png")
		end

		if isCursorShowing() then
			local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition()
			cursorX, cursorY = cursorX * sx, cursorY * sy
			if isInBox( cursorX, cursorY, posxIcon+thumpOffsetX, posxIcon+thumpOffsetX+2+imgw, 12+globalOffSetY, 12+globalOffSetY+imgh) then
				if justClicked_title then
					playSFX("genrl", 52, 10, false)
					if justClicked_title == "left" then
			            if (#notis > 0) then
							toggleNotiDetail()
						end
					end
					
				end
			end
		end
		justClicked_title = false
	end
end
addEventHandler("onClientRender",getRootElement(), drawPmThump)

local justClicked_preview = false
function drawPmPreviews()
	if exports.hud:isActive() and showPreview and #notis>0 and getElementData(localPlayer, "loggedin") == 1 and not isPlayerMapVisible() then
		local count = 0
		for i, noti in ipairs(notis) do
			local margin = 3
			local lineH = 15
			local bgDetailsW, bgDetailsH =  300,36--bg detail size
			
			local titleText = "◊ "..noti.title
			local titleWith = dxGetTextWidth(titleText)
			local dateText = "  » "..exports.datetime:formatTimeInterval(tonumber(noti.datesec))..". "..noti.fdate
			if titleWith > bgDetailsW-margin*2 then
				bgDetailsW = titleWith+margin*2
			end
			local dBoxX = sx-bgDetailsW-margin*4

			local ax, ay = bgDetailOffsetX+dBoxX, 10+bgh+bgDetailOffsetY+globalOffSetY+count*(bgDetailsH+margin*2)
			local bx, by = ax+bgDetailsW, ay+bgDetailsH
			local mhover = false
			if isCursorShowing() then
				local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition()
				cursorX, cursorY = cursorX * sx, cursorY * sy
				if isInBox( cursorX, cursorY, ax, bx, ay, by) then
					mhover = true
					if justClicked_preview then
						playSFX("genrl", 52, 10, false)
						if justClicked_preview == "left" then
							openNoti(noti)
						else
							deleteNoti(noti)
						end
						
					end
				end
			end
			local alpha = 150
			if mhover then
				alpha = 50
			end
			local bgColor = tocolor(0, 0, 0,alpha)
			if noti.read == "0" then
				bgColor = tocolor(66, 153, 78,alpha)
			end
			dxDrawRectangle(ax, ay, bgDetailsW, bgDetailsH, bgColor, false)
			dxDrawRectangleBorder(ax, ay, bgDetailsW, bgDetailsH, 1, tocolor(255, 255, 255, 100), true)
			dxDrawText(titleText, ax+margin, ay+margin, bgDetailsW-margin*2, lineH, tocolor(255, 255, 255, 255), 1, "default")
			dxDrawText(dateText, ax+margin, 10+bgh+bgDetailOffsetY+globalOffSetY+margin+lineH+count*(bgDetailsH+margin*2), bgDetailsW-margin*2, lineH, tocolor(255, 255, 255, 200), 1, "default-small")
			count = count + 1
		end
		justClicked_preview = false
	end
end
addEventHandler("onClientRender",getRootElement(), drawPmPreviews)

local GUIEditor = {
    button = {},
    window = {},
    memo = {}
}

function openNoti(noti)
	closeNoti()
	playSFX("genrl", 53, 7, false)
	GUIEditor.window[1] = guiCreateWindow(631, 387, 474, 215, "Notification", false)
	guiWindowSetSizable(GUIEditor.window[1], false)
	exports.global:centerWindow(GUIEditor.window[1])
	GUIEditor.memo[1] = guiCreateMemo(9, 23, 455, 152, noti.title.."\n\n"..(noti.details and noti.details or ""), false, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(12, 181, 452, 24, "Close", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
		if source == GUIEditor.button[1] then
			closeNoti()
		end
	end)
	if noti.read == "0" then
		unreads = unreads -1
		noti.read="1"
		table.sort(notis, function(a, b) 
			if tonumber(a.read) == tonumber(b.read) then
				return tonumber(a.datesec) > tonumber(b.datesec)
			else
			 	return tonumber(a.read) < tonumber(b.read)	
			end
		end)
		local opm = nil
		if noti.offline_pm and tonumber(noti.offline_pm) then
			opm = {}
			opm.sender = noti.offline_pm
			opm.sentdate = noti.fdate
			local text = noti.details and noti.details or nil 
			if text then
				if string.len(text) > 20 then
					text = string.sub(text, 1, 20)..".."
				end
			end
			opm.details = text
			opm.receiver = getElementData(localPlayer, "account:username")
		end
		triggerServerEvent("readNoti", localPlayer, noti.id, opm)
	end
end

function closeNoti()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
	end
end

function deleteNoti(noti)
	triggerServerEvent("deleteNoti", localPlayer, noti.id)
	noti.deleted = true
	if noti.read == "0" then
		unreads = unreads -1
	end
	local newNotis = {}
	for i, noti2 in ipairs(notis) do
		if not noti2.deleted then
			table.insert(newNotis, noti2)
		end
	end
	notis = newNotis
	if #notis < 1 then
		showPreview = false
		setElementData(localPlayer, "integration:previewPMShowing", false)
	end
end

function isInBox( x, y, xmin, xmax, ymin, ymax )
	--outputDebugString(tostring(x)..", "..tostring(y)..", "..tostring(xmin)..", "..tostring(xmax)..", "..tostring(ymin)..", "..tostring(ymax))
	return x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

addEventHandler( "onClientClick", root,
	function( button, state )
		if exports.hud:isActive() and state == "down" and #notis>0 and getElementData(localPlayer, "loggedin") == 1 and not isPlayerMapVisible() then
			if showPreview then
				justClicked_preview = button
			end
			justClicked_title = button
		end
	end
)
--[[
addEventHandler( "onClientGUIMouseDown", getRootElement( ),
    function ( btn, x, y )
        if btn == "left" and source == invisibleArea then
        	playSound(":resources/toggle.mp3")
            if (#notis > 0) then
				toggleNotiDetail()
			end
        end
    end
)
]]

function toggleNotiDetail()
	if not showPreview and #notis < 1 then return false end
	showPreview = not showPreview
	setElementData(localPlayer, "integration:previewPMShowing", showPreview)
end

function getPmsFromServer(notis1)
	if notis1 and #notis1 > 0 then
		notis = notis1
		local unreads2 = 0
		for i, noti in ipairs(notis) do
			if noti.read == "0" then
				unreads2 = unreads2 + 1
			end
		end
		if unreads2 > unreads and getElementData(localPlayer, "loggedin") == 1 then
			exports.global:playSoundAlert()
		end
		unreads = unreads2
	end
end
addEvent( "integration:getPmsFromServer", true )
addEventHandler( "integration:getPmsFromServer", localPlayer, getPmsFromServer )

local theTimer = nil
function requestPmsFromServer()
	local minutes = math.random(refreshRate1, refreshRate2)
	if theTimer and isTimer(theTimer) then
		killTimer(theTimer)
	end
	theTimer = setTimer ( requestPmsFromServer, 1000*60*minutes , 1)
	outputDebugString("[CLIENT] - requestNotiFromServer again in "..minutes.." minutes.")
	if getElementData(localPlayer,"loggedin") ~= 1 then
		return false
	end
	triggerServerEvent ( "integration:givePmsToClient", localPlayer )
end
addEventHandler("onClientResourceStart",resourceRoot,requestPmsFromServer)
addEvent("accounts:character:select", true)
addEventHandler( "accounts:character:select", root, requestPmsFromServer )

function dxDrawRectangleBorder(x, y, width, height, borderWidth, color, out, postGUI)
	if out then
		--[[Left]]	dxDrawRectangle(x - borderWidth, y, borderWidth, height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width, y, borderWidth, height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x - borderWidth, y - borderWidth, width + (borderWidth * 2), borderWidth, color, postGUI)
		--[[Botm]]	dxDrawRectangle(x - borderWidth, y + height, width + (borderWidth * 2), borderWidth, color, postGUI)
	else
		local halfW = width / 2
		local halfH = height / 2
		--[[Left]]	dxDrawRectangle(x, y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width - math.clip(0, borderWidth, halfW), y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y, width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
		--[[Botm]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y + height - math.clip(0, borderWidth, halfH), width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
	end
end