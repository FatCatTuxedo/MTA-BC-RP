local DXMessages = {}

local sX,sY = guiGetScreenSize()
local aX,aY,aW,aH = sX*(0.25), (sY*0.02)-20, sX*0.75, sY*0.02
if (sX <= 1280) then
	aX,aY,aW,aH = (sX/2)-(1280/4), (sY*0.95)-20, (sX/2)+(1280/4), sY*0.95
end

local font = "default-bold"

local DISPLAY_TIME = 7500

function dm(text, r, g, b)
	if (type(text) ~= "string" or type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number") then return false end
	if (r > 255 or g > 255 or b > 255) then return false end
	
	if (#DXMessages == math.floor((sY*0.2)/20)) then
		table.remove(DXMessages, 1)
	end
	
	local tick = getTickCount()+DISPLAY_TIME
	dxTable = {text, r, g, b, tick}
	table.insert(DXMessages, dxTable)
	
	if (#DXMessages == 1) then
		addEventHandler("onClientRender", root, renderDXMessage)
	end
	playSoundFrontEnd(11)
	outputConsole(text)
	return true
end
addEvent("displayMesaage", true)
addEventHandler("displayMesaage", root, dm)

function renderDXMessage()
	if (#DXMessages == 0) then
		removeEventHandler("onClientRender", root, renderDXMessage)
	end
	
	local toRemove = 0
	for i,v in ipairs(DXMessages) do
		if (v[5] > getTickCount()) then
			dxDrawRectangle(aX, aY+( (i-1) *20), aW-aX, aH-aY, tocolor(0, 0, 0, 200))
			dxDrawText(v[1], aX, aY+( (i-1) *20), aW, aH+( (i-1) *20), tocolor(v[2], v[3], v[4], 255), 1, font, "center", "center")
		else
			toRemove = toRemove + 1
		end
	end
	if (toRemove > 0) then
		for i=1,toRemove do
			table.remove(DXMessages, 1)
		end
	end
	local i = #DXMessages-1
end
