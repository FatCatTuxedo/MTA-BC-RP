local gui_base = nil
local root = getRootElement()
local localPlayer = getLocalPlayer()
local routes = { }
local selectedRoute = nil
local currentstop = nil

function showBusControl()
	if gui_base then
		destroyElement(gui_base)
		gui_base = nil
	end
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	routes = getElementData(theVehicle, "bus.routes")
	local screenX, screenY = guiGetScreenSize()
	local width, height = 400, 200
	local x, y
	local speedowidth = 280
 	x = screenX-speedowidth-width
	y = screenY-height-60
	gui_base = guiCreateStaticImage(x,y,width,height,"images/bus.png",false,nil)
	gui_label_pstop = guiCreateLabel(120, 75, 139, 15, "HQ", false, gui_base)
	gui_label_nstop = guiCreateLabel(90, 105, 139, 15, "Loading...", false, gui_base)
	gui_route = guiCreateComboBox(70, 37.5, 200, 100, "Please Select a route.", false, gui_base)
	for i, route in ipairs ( routes ) do
		guiComboBoxAddItem ( gui_route, route[1] )
	end
	gui_startroute = guiCreateButton( 50, 140, 75, 45, "Start Route", false, gui_base)
		addEventHandler("onClientGUIClick", gui_startroute, startRoute, false)
	gui_nextstop = guiCreateButton( 150, 140, 35, 45, ">", false, gui_base)
		addEventHandler("onClientGUIClick", gui_nextstop, nextStop, false)
	gui_notice = guiCreateButton( 200, 140, 75, 45, "Announce", false, gui_base)
		addEventHandler("onClientGUIClick", gui_notice, sendNotice, false)
	guiSetEnabled(gui_notice, false)
	guiSetEnabled(gui_nextstop, false)
	selectedRoute = nil
	currentstop = nil
end

addEvent("bus:start", true)
addEventHandler("bus:start", root, showBusControl)

function hideBusGui()
	if gui_base then
		destroyElement(gui_base)
		gui_base = nil
	end
	selectedRoute = nil
	currentstop = nil
end

function nextStop()
	if (currentstop ~= nil) then
		local pstop = currentstop
		currentstop = currentstop + 1
		if (routes[selectedRoute][2][currentstop]) then
			guiSetText(gui_label_pstop, routes[selectedRoute][2][pstop])
			guiSetText(gui_label_nstop, routes[selectedRoute][2][currentstop])
		else
			guiSetEnabled(gui_notice, false)
			guiSetEnabled(gui_nextstop, false)
			local tts = playTTS(theVehicle, "Announcement. This is the end of the line. Please exit the bus.")
			selectedRoute = nil
			currentstop = nil
			guiSetText(gui_startroute, "Start Route")
			guiSetText(gui_label_pstop, "HQ")
			guiSetText(gui_label_nstop, "Loading...")
		end
	end
end

function startRoute()
	if (selectedRoute == nil) then
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		local routeBox = guiComboBoxGetSelected(gui_route)
		selectedRoute = tonumber(guiComboBoxGetItemText(gui_route, routeBox))
		if (selectedRoute > 0) then
			guiSetText(gui_label_nstop, routes[selectedRoute][2][1])
			currentstop = 1
			guiSetEnabled(gui_notice, true)
			guiSetEnabled(gui_nextstop, true)
			guiSetText(gui_startroute, "Stop Route")
		else
			outputChatBox("[SAPT-SYSTEM] You did not select a route.", 255, 0, 0)
		end
	else
		guiSetEnabled(gui_notice, false)
		guiSetEnabled(gui_nextstop, false)
		local tts = playTTS(theVehicle, "Announcement. This is the end of the line. Please exit the bus.")
		selectedRoute = nil
		currentstop = nil
		guiSetText(gui_startroute, "Start Route")
		guiSetText(gui_label_pstop, "HQ")
		guiSetText(gui_label_nstop, "Loading...")
	end
end

function sendNotice()
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	local tts = playTTS(theVehicle, "Announcement. The next stop is " .. guiGetText(gui_label_nstop))
end

function playTTS(theVehicle, text)
	local URL = "http://translate.google.com/translate_tts?tl=" .. "en" .. "&q=" .. text
	local x, y, z = getElementPosition(theVehicle)
	local speech = playSound3D(URL, x, y, z)
	attachElements(speech, theVehicle) -- Make the sound follow the bus
	setSoundMaxDistance(speech, 50)
	setElementDimension(speech, getElementDimension(theVehicle))
	setElementInterior(speech, getElementInterior(theVehicle))
	if (getElementData(getPedOccupiedVehicle(localPlayer), "vehicle:windowstat") == 0) then
		setSoundEffectEnabled(speech, "distortion", true)
		setSoundVolume(speech, 0.5)
	else
		setSoundEffectEnabled(speech, "distortion", false)
		setSoundVolume(speech, 1)
	end
	setSoundSpeed (speech, 1)
	return speech
end

addEventHandler("onClientVehicleExit", root,
		function (player, seat)
			if(player == localPlayer) then
				local model = getElementModel(source)
				if model == 431 or model == 437 then
					hideBusGui()
				end
			end
		end
)
