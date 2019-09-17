--MAXIME
local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()

-- dx stuff
local textString = ""
local admstr = ""
local show = false
local r, b, g = 255, 255, 255
local posX = sx
local stringLegth = 0
local speed = 1
local alphaBG = 0
local fadeSpeed = 0.5
local height = 25

function drawAnnText ( ) 
	if show then
		setElementData(localPlayer, "annHeight", height)
		if ( getPedWeapon( localPlayer ) ~= 43 or not getControlState( "aim_weapon" ) ) then
			dxDrawRectangle(0, 0, sx, height, tocolor(0, 0, 0, 200), false)
			dxDrawText( textString, posX, 5, stringLegth, sy, tocolor ( r, b, g, 255 ), 1, "default")
		end
		
		if alphaBG < 100 then
			alphaBG = alphaBG + fadeSpeed
		end
		
		if (posX+stringLegth) < 0 then
			if alphaBG < 0 then
				alphaBG = alphaBG - fadeSpeed
			else
				show = false
				setElementData(localPlayer, "annHeight", 0)
			end
		else
			posX = math.floor(posX - speed)
		end
	end
end
addEventHandler("onClientRender",getRootElement(), drawAnnText)

local function handleClick(button, state, absX, absY)
	if button == 'left' and state == 'down' and show and #textString > 0 then
		-- make sure it's not just at the border, since that might sometimes be buggy.
		if absX > 0 and absX < sx and absY > 0 and absY <= height then
			-- check if it contains an URL
			local url = exports.global:getUrlFromString(textString)
			if url and setClipboard(url) then
				outputChatBox('Copied "' .. url .. '".')
			end
		end
	end
end
addEventHandler('onClientClick', root, handleClick)

function postAnn(msg, r1,b1,g1, playsound)
	if msg and (string.len(msg)>0) then
		if playsound and tonumber(playsound) and (tonumber(playsound)>0) then
			playSound(playsound..".mp3")
		end
		alphaBG = 0
		textString = msg
		stringLegth = string.len(textString)*11
		posX = sx
		if r1 and b1 and g1 then
			r, b, g = r1, b1, g1
		end
		show = true
	end
end
addEvent( "announcement:post", true )
addEventHandler( "announcement:post", getRootElement(), postAnn)

function sendTopNotification( msg, r1, b1, g1, playsound)
	postAnn(msg, r1,b1,g1, playsound)
end