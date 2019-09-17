local localPlayer = getLocalPlayer()
local show = false
local width, height = 570,100
local woffset, hoffset = 0, 0
local sx, sy = guiGetScreenSize()
local content = {}
local timerClose = nil
local cooldownTime = 5 --seconds
local toBeDrawnWidth = width
local BizNoteFont18 = dxCreateFont ( ":resources/BizNote.ttf" , 18 )

function drawOverlayBottomCenter(info, widthNew, woffsetNew, hoffsetNew, cooldown)
	if timerClose and isTimer(timerClose) then
		killTimer(timerClose)
		timerClose = nil
	end
	content = info
	if widthNew then
		width = widthNew
	end
	if woffsetNew then
		woffset = woffsetNew
	end
	if hoffsetNew then
		hoffset = hoffsetNew
	end
	if cooldown then
		cooldownTime = cooldown
	end
	show = true
	playSoundFrontEnd ( 101 )
	timerClose = setTimer(function()
		show = false
	end, cooldownTime*1000, 1)
	
	toBeDrawnWidth = width
	
	for i=1, #info do
		outputConsole(info[i][1] or "")
	end
end
addEvent("hudOverlay:drawOverlayBottomCenter", true)
addEventHandler("hudOverlay:drawOverlayBottomCenter", localPlayer, drawOverlayBottomCenter)

addEventHandler("onClientRender",getRootElement(), function ()
	if show then 
		if ( getPedWeapon( localPlayer ) ~= 43 or not getControlState( "aim_weapon" ) ) then
			local w = toBeDrawnWidth
			local h = 16*(#content)+30
			local posX = (sx/2)-(w/2)+woffset
			local posY = sy-(h+30)+hoffset
			
			dxDrawImage(posX, posY , w, h , "images/hud/box2.png")
			
			for i=1, #content do
				if content[i] then
					local currentWidth = dxGetTextWidth ( (content[i][1] or "" ) , 1 , "default") + 30
					if currentWidth > toBeDrawnWidth then
						toBeDrawnWidth = currentWidth
					end
					dxDrawText( content[i][1] or "" , posX+16, posY+(16*i), w-5, 15, tocolor ( content[i][2] or 255, content[i][3] or 255, content[i][4] or 255, content[i][5] or 255 ), content[i][6] or 1, ( (i == 1) and ("default-bold")  or (content[i][7]) or ("default") ) )
				end
				
			end
			
		end
	end
end, false)