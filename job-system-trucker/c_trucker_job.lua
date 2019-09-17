local blip, endblip, loadupBlip
local jobstate = 1
local route = 0
local oldroute = -1
local marker, endmarker, endmarker2, loadupMarker
local deliveryStopTimer = nil
local timerLoadUp, cancelRouteTimer

local staticMarkers = {}
local staticBlips = {}  
local staticPoints = {
	["loadupBlip"] = { 117.8330078125, 1442.5986328125, 10, 0 , 0},
	["loadup1"] = { 2159.6962890625, -2280.9267578125, 11.5, 0, 0},
	["loadup2"] = { 142.55859375, 1442.7421875, 10, 0, 0},
	["loadup3"] = { 159.099609375, 1441.890625, 10, 0, 0}, 
}
local truckerJobVehicleInfo = {
--  Model   (1)Capacity (2)Level (3)Price/Crate (4)CrateWeight (5)Earning/Crate
	[440] = {40, 1, 15, 20, 100}, -- Rumpo
	[499] = {80, 2, 35, 50, 150}, -- Benson
	[414] = {160, 3, 55, 100, 200}, -- Mule
	[498] = {200, 4, 75, 140, 250}, -- Boxville
	[456] = {300, 5, 75, 140, 300}, -- Yankee
}

function resetTruckerJob()
	jobstate = 1
	oldroute = -1
	
	if (isElement(marker)) then
		destroyElement(marker)
		marker = nil
	end
	
	if (isElement(blip)) then
		destroyElement(blip)
		blip = nil
	end
	
	if (isElement(endmarker)) then
		destroyElement(endmarker)
		endmarker = nil
	end
	
	if (isElement(endmarker2)) then
		destroyElement(endmarker2)
		endmarker2 = nil
	end
	
	if (isElement(endcolshape)) then
		destroyElement(endcolshape)
		endcolshape = nil
	end
	
	if (isElement(endblip)) then
		destroyElement(endblip)
		endblip = nil
	end
	
	for key, element in pairs(staticMarkers) do
		if (isElement(element)) then
			destroyElement(element)
			element = nil
		end
	end
	
	for key, element in pairs(staticBlips) do
		if (isElement(element)) then
			destroyElement(element)
			element = nil
		end
	end
	
	if (isElement(loadupBlip)) then
		destroyElement(loadupBlip)
		loadupBlip = nil
	end

	if deliveryStopTimer then
		killTimer(deliveryStopTimer)
		deliveryStopTimer = nil
	end
end
addEventHandler("onClientChangeChar", getRootElement(), resetTruckerJob)

function displayTruckerJob(notext, spwan)
	-- if (jobstate==0) then
		-- jobstate = 1 
		blip = createBlip(2221.1015625, -2228.7978515625, 13.546875, 51, 2, 255, 127, 255)
		
		if not notext then
			exports.hud:sendBottomNotification(getLocalPlayer(), "RS Haul Operator:", "Approach the Grey Truck Icon on your radar and enter the RS Haul's vehicle to start your job.")
		end
	-- end
end

addEvent("restoreTruckerJob", true)
addEventHandler("restoreTruckerJob", getRootElement(), function() displayTruckerJob(true) end )


function showSupplySpot()
	local localPlayer = getLocalPlayer()
	--Bip on top of warehouse
	if not isElement(staticBlips["loadupBlip"]) then
		staticBlips["loadupBlip"] = createBlip(staticPoints["loadupBlip"][1], staticPoints["loadupBlip"][2], staticPoints["loadupBlip"][3], 0, 2, 0, 255, 0)
		-- Loadup 1
		staticMarkers["loadup1"] = createMarker(staticPoints["loadup1"][1], staticPoints["loadup1"][2], staticPoints["loadup1"][3], "cylinder", 3, 0, 255, 0, 100,localPlayer)
		setElementInterior(staticMarkers["loadup1"], staticPoints["loadup1"][4])
		setElementDimension(staticMarkers["loadup1"], staticPoints["loadup1"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadup1"], waitAtStationLoadup)
		addEventHandler("onClientMarkerLeave", staticMarkers["loadup1"], leaveStationLoadup)
		-- Loadup 2
		staticMarkers["loadup2"] = createMarker(staticPoints["loadup2"][1], staticPoints["loadup2"][2], staticPoints["loadup2"][3], "cylinder", 3, 0, 255, 0, 100,localPlayer)
		setElementInterior(staticMarkers["loadup2"], staticPoints["loadup2"][4])
		setElementDimension(staticMarkers["loadup2"], staticPoints["loadup2"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadup2"], waitAtStationLoadup)
		addEventHandler("onClientMarkerLeave", staticMarkers["loadup2"], leaveStationLoadup)
		staticMarkers["loadup3"] = createMarker(staticPoints["loadup3"][1], staticPoints["loadup3"][2], staticPoints["loadup3"][3], "cylinder", 3, 0, 255, 0, 100,localPlayer)
		setElementInterior(staticMarkers["loadup3"], staticPoints["loadup3"][4])
		setElementDimension(staticMarkers["loadup3"], staticPoints["loadup3"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadup3"], waitAtStationLoadup)
		addEventHandler("onClientMarkerLeave", staticMarkers["loadup3"], leaveStationLoadup)
	end
end
addEvent("job-system:trucker:showSupplySpot", true)
addEventHandler("job-system:trucker:showSupplySpot", getLocalPlayer(), showSupplySpot)

function leaveStationLoadup(thePlayer, destroyBlip)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if vehicle and getVehicleController(vehicle) == getLocalPlayer() and isTimer(timerLoadUp) then
		killTimer(timerLoadUp)
		timerLoadUp = nil
		--[[if destroyBlip then
			if isElement(staticMarkers["loadupEntrance2"]) then
				destroyElement(loadupMarker)
			end
			if isElement(loadupBlip) then
				destroyElement(loadupBlip)
			end
		end]]
	end
end
addEvent("job-system:trucker:leaveStationLoadup", true)
addEventHandler("job-system:trucker:leaveStationLoadup", getRootElement(), leaveStationLoadup)

function startTruckerJob(routeid)
	
end
addEvent("startTruckJob", true)
addEventHandler("startTruckJob", getRootElement(), startTruckerJob)

function waitAtStationLoadup(thePlayer)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if thePlayer == getLocalPlayer() and vehicle and getVehicleController(vehicle) == getLocalPlayer() then
		if getElementHealth(vehicle) < 350 then
			exports.hud:sendBottomNotification(getLocalPlayer(), "RS Haul Operator:", "You need to get your truck repaired first..")
		else
			if not timerLoadUp then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "Now waiting a moment while your truck is being loaded up with supply crates.")
				timerLoadUp = setTimer(function ()
					triggerServerEvent("job-system:trucker:startLoadingUp", thePlayer)
				end, 2000, 0)
				
			end
			--
			--addEventHandler("onClientMarkerLeave", marker, checkWaitAtDelivery)
		end
	end
end

function drawBuyLoadWindow(thePlayer)
	wRSHaulLoadup = guiCreateWindow(312,344,204,149,"RS Haul Delivery Station",false)
	guiWindowSetSizable(wRSHaulLoadup,false)
	lNumberOfCrates = guiCreateLabel(13,25,176,19,"Number of Supply Crates: 0",false,wRSHaulLoadup)
	guiSetFont(lNumberOfCrates,"default-bold-small")
	lCost = guiCreateLabel(13,68,176,19,"Cost: $0",false,wRSHaulLoadup)
	guiSetFont(lCost,"default-bold-small")
	scrollbar = guiCreateScrollBar(13,44,176,20,true,false,wRSHaulLoadup)
	lMoney = guiCreateLabel(13,87,176,19,"Your money: $0",false,wRSHaulLoadup)
	guiSetFont(lMoney,"default-bold-small")
	bBuyLoad = guiCreateButton(9,111,94,28,"Buy & Load up",false,wRSHaulLoadup)
	bCancel = guiCreateButton(107,111,88,28,"Cancel",false,wRSHaulLoadup)
end



function getCurrentCrates(vehicle)
	local count = 0
	for key, item in pairs(exports["item-system"]:getItems(vehicle)) do 
		if item[1] == 121 then -- supply box
			count = count + 1
		end
	end
	return count
end

function spawnFinishMarkerTruckJob()
	if not endmarker then
		endblip = createBlip(118.5048828125, 1442.3095703125, 10.623874664307, 13.6, 0, 2, 255, 0, 0)
		
		endmarker2 = createMarker(118.5048828125, 1442.3095703125, 10.623874664307, "checkpoint", 4, 255, 0, 0, 150)
		setMarkerIcon(endmarker2, "finish")
		
		addEventHandler("onClientMarkerHit", endmarker2, endDelivery)
	end
end
addEvent("spawnFinishMarkerTruckJob", true)
addEventHandler("spawnFinishMarkerTruckJob", getRootElement(), spawnFinishMarkerTruckJob)

function loadNewCheckpointTruckJob()
	
end

addEvent("loadNewCheckpointTruckJob", true)
addEventHandler("loadNewCheckpointTruckJob", getRootElement(), loadNewCheckpointTruckJob)

function endDelivery(thePlayer)
	if thePlayer == getLocalPlayer() then
		local vehicle = getPedOccupiedVehicle(getLocalPlayer())
		local id = getElementModel(vehicle) or 0
		if not vehicle or getVehicleController(vehicle) ~= getLocalPlayer() or  getElementData(vehicle, "job") ~= 1 then
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You must be in a RS Haul's vehicle to complete deliveries.")
		else
			local health = getElementHealth(vehicle)
			if health <= 700 then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "This truck is damaged, fix it first.")
			else
				triggerServerEvent("giveTruckingMoney", getLocalPlayer(), vehicle)
				resetTruckerJob()
				displayTruckerJob(true)
			end
		end
	end
end

function clearRoute()
	
	if isElement(marker) then
		destroyElement(marker)
	end
	
	if isElement(blip) then
		destroyElement(blip)
	end
	
end
addEvent( "truckerjob:clearRoute", true)
addEventHandler("truckerjob:clearRoute", getRootElement() , clearRoute)

function spawnRoute(route)
	local x, y, z = route[1], route[2], route[3]
	local radius, r, g, b, trans = 4, 255, 200, 0, 100
	
	if tonumber(route[8]) and (tonumber(route[8]) > 0) then
		radius, r, g, b, trans = 20, 219, 48, 0, 200
	end
	
	if isElement(marker) then
		destroyElement(marker)
	end
	
	if isElement(blip) then
		destroyElement(blip)
	end
	
	blip = createBlip(x, y, z, 0, 2, r, g, b)
	marker = createMarker(x, y, z, "checkpoint", radius, r, g, b, trans)
	addEventHandler("onClientMarkerHit", marker, waitAtDelivery)
end
addEvent( "truckerjob:spawnRoute", true)
addEventHandler("truckerjob:spawnRoute", getRootElement() , spawnRoute)
 
function waitAtDelivery(thePlayer)
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if thePlayer == getLocalPlayer() and vehicle and getVehicleController(vehicle) == getLocalPlayer() then
		if getElementHealth(vehicle) < 350 then
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You need to get your truck repaired.")
		else
			deliveryStopTimer = setTimer(checkIfPlayerTruckHasEnoughtShit, 5000, 1)
			killTimerCountDown()
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "Wait a moment while your truck is processed.")
			addEventHandler("onClientMarkerLeave", marker, checkWaitAtDelivery)
		end 
	end
end

function checkWaitAtDelivery(thePlayer)
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if vehicle and thePlayer == getLocalPlayer() and getVehicleController(vehicle) == getLocalPlayer() then
		if getElementHealth(vehicle) >= 350 then
			--outputChatBox("You didn't wait at the dropoff point.", 255, 0, 0)
			if deliveryStopTimer then
				killTimer(deliveryStopTimer)
				deliveryStopTimer = nil
			end
			removeEventHandler("onClientMarkerLeave", source, checkWaitAtDelivery)
		end
	end
end

function checkIfPlayerTruckHasEnoughtShit()
	deliveryStopTimer = nil
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if vehicle and getVehicleController(vehicle) == getLocalPlayer()  then
		if getElementData(vehicle, "job") ~= 1 then
			exports.hud:sendBottomNotification(getLocalPlayer(), "RS Haul Operator:", "Man..You have to use RS Haul vehicle.")
			return false
		end
		--spawnFinishMarkerTruckJob()
		triggerServerEvent("truckerjob:checkIfPlayerTruckHasEnoughtShit", getLocalPlayer())	
	else
		exports.hud:sendBottomNotification(getLocalPlayer(), "RS Haul Operator:", "You must be in the Truck to complete deliverys.")
	end
end