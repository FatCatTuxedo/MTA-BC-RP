function nudgeNoise()
   local sound = playSound("Player/nudge.wav")   
   setSoundVolume(sound, 0.5) -- set the sound volume to 50%
end
addEvent("playNudgeSound", true)
addEventHandler("playNudgeSound", getLocalPlayer(), nudgeNoise)
addCommandHandler("playthenoise", nudgeNoise)

function doEarthquake()
	local x, y, z = getElementPosition(getLocalPlayer()) 
	createExplosion(x, y, z, -1, false, 3.0, false)
end
addEvent("doEarthquake", true)
addEventHandler("doEarthquake", getLocalPlayer(), doEarthquake)

function streamASound(link)
	playSound(link)
end
addEvent("playSound", true)
addEventHandler("playSound", getRootElement(), streamASound)

function develop()
	if exports.integration:isPlayerScripter(getLocalPlayer()) then
		setDevelopmentMode( true )
		outputChatBox("Development Mode Enabled. /showcol, /showsound", 0, 255, 0)
	end
end
addCommandHandler("devmode", develop)

function seeFar(localPlayer, value)
	if not value then outputChatBox("SYNTAX: /seefar [value or -1 to reset it]") end
	if value and tonumber(value) >= 250 and tonumber(value) <= 20000 then
		setFarClipDistance(value)
		outputChatBox("Clip distance set to "..value..".")
	elseif value and tonumber(value) == -1 then
		resetFarClipDistance()
	else
		outputChatBox("Maximum value for render distance is 20000 and minimum is 250.")
	end
end
addCommandHandler("seefar", seeFar) 

local cargogui = {}
function buildCargoGUI()
	
	cargogui._placeHolders = {}

	if cargogui["_root"] and isElement(cargogui["_root"]) then destroyElement(cargogui["_root"]) end

	guiSetInputMode("no_binds_when_editing")
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 384, 210
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	cargogui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Los Santos Express", false)
	guiWindowSetSizable(cargogui["_root"], false)
	
	cargogui["pushButton"] = guiCreateButton(250, 165, 75, 23, "Close", false, cargogui["_root"])
	addEventHandler("onClientGUIClick", cargogui["pushButton"], function ()
		destroyElement(cargogui["_root"])
		showCursor(false)
		guiSetInputMode("allow_binds")
	end, false)
	
	cargogui["label"] = guiCreateLabel(20, 25, 301, 16, "This GUI is only availabe to Los Santos Express Employees. ", false, cargogui["_root"])
	guiLabelSetHorizontalAlign(cargogui["label"], "left", false)
	guiLabelSetVerticalAlign(cargogui["label"], "center")
	
	cargogui["label_2"] = guiCreateLabel(20, 45, 371, 16, "Put in realistic prices. They are logged and notified to staff.", false, cargogui["_root"])
	guiLabelSetHorizontalAlign(cargogui["label_2"], "left", false)
	guiLabelSetVerticalAlign(cargogui["label_2"], "center")
	
	cargogui["lineEdit_name"] = guiCreateEdit(20, 95, 320, 21, "", false, cargogui["_root"])
	guiEditSetMaxLength(cargogui["lineEdit_name"], 32767)
	
	cargogui["lineEdit_price"] = guiCreateEdit(20, 145, 151, 21, "", false, cargogui["_root"])
	guiEditSetMaxLength(cargogui["lineEdit_price"], 32767)
	
	cargogui["label_3"] = guiCreateLabel(20, 75, 180, 16, "Item name (name:model)", false, cargogui["_root"])
	guiLabelSetHorizontalAlign(cargogui["label_3"], "left", false)
	guiLabelSetVerticalAlign(cargogui["label_3"], "center")
	
	cargogui["label_4"] = guiCreateLabel(20, 125, 46, 13, "Price", false, cargogui["_root"])
	guiLabelSetHorizontalAlign(cargogui["label_4"], "left", false)
	guiLabelSetVerticalAlign(cargogui["label_4"], "center")
	
	cargogui["pushButton_2"] = guiCreateButton(220, 130, 131, 30, "Create", false, cargogui["_root"])
	addEventHandler("onClientGUIClick", cargogui["pushButton_2"], function ()
		local price = tostring(guiGetText(cargogui["lineEdit_price"]))
		local name = tostring(guiGetText(cargogui["lineEdit_name"]))
		triggerServerEvent("createCargoGeneric", getResourceRootElement(), localPlayer, "cmg", price, name)
		end, false)
	
	return cargogui, windowWidth, windowHeight
end
addEvent("createCargoGUI", true)
addEventHandler("createCargoGUI", getRootElement(), buildCargoGUI)