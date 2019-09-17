--BY MAXIME 24/5/2013
mysql = exports.mysql
debugmode = false
local lockTimer = nil

MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if text then
		if string.len(text) > 128 then -- MTA Chatbox size limit
			MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
			outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
		else
			MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
		end 
	end
end

truckerJobVehicleInfo = {
--  Model   (1)Capacity (2)Level (3)CrateWeight
	[440] = {40, 1, 20}, -- Rumpo
	[499] = {80, 2, 40}, -- Benson
	[414] = {100, 3, 50}, -- Mule
	[498] = {150, 4, 75}, -- Boxville
	[456] = {200, 5, 100}, -- Yankee
}

level = {
	[1] = 50,
	[2] = 200,
	[3] = 1000,
	[4] = 3200,
}

routes = { -- (1,2,3)coordinates (4)RequiringWeight (5)DriverOnJog (6)Location Name (7)OrderID (8)OrderInterior 
}

function fetchActualOrders()
	local count = 0
	local actualOrders = {}
	local actualOrdersSQL = mysql:query("SELECT * FROM `jobs_trucker_orders`") or false
	while true do
		local row = mysql:fetch_assoc(actualOrdersSQL) or false
		if not row then 
			break 
		end
		table.insert(actualOrders, { tonumber(row["orderX"]), tonumber(row["orderY"]),tonumber(row["orderZ"]),math.floor(tonumber(row["orderWeight"])), false, row["orderName"],tonumber(row["orderID"]), tonumber(row["orderInterior"])} )
	end
	mysql:free_result(actualOrdersSQL)
	
	for key, order in pairs(actualOrders) do
		local existed = false
		for i = 1, #routes do
			if routes[i] and routes[i][7] and routes[i][7] == order[7] then
				existed = true
				break
			end
		end
		
		if not existed then
			table.insert(routes, order)
			count = count + 1
		end
	end

	outputDebugString("[JOB-SYSTEM-TRUCKER] Fetched "..count.." actual orders sucessfully from SQL")
	return count
end

function spawnRoute(thePlayer, spawnNewRoute)
	--local currentRoute = getElementData(thePlayer, "job-system-trucker:currentRoute") or false
	local currentSpot = handledSpot(thePlayer)
	if currentSpot and not spawnNewRoute then
		triggerClientEvent(thePlayer, "truckerjob:spawnRoute", thePlayer, currentSpot) -- CONTINUE THE CURRENT ROUTE.
	else
		local selectedRoute = false
		local timeOut = 0 
		while not selectedRoute do
			selectedRoute = selectAFreeSpot(thePlayer)
			if not selectedRoute then
				return false
			end
			timeOut = timeOut + 1
			if timeOut > 20 then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "There is no customer orders to do at the moment, please stand by...")
				return false
			end
		end
		
		setElementData(thePlayer, "job-system-trucker:currentRoute", selectedRoute, true)
		triggerClientEvent(thePlayer, "truckerjob:spawnRoute", thePlayer, selectedRoute)
		local pX, pY = getElementPosition(thePlayer)
		local distance = getDistanceBetweenPoints2D(pX, pY, selectedRoute[1], selectedRoute[2])
		if distance > 0 then
			triggerClientEvent(thePlayer, "job-system:trucker:killTimerCountDown", thePlayer)
			triggerClientEvent(thePlayer, "job-system:trucker:startTimeoutClock", thePlayer, distance)
		end
	end
	
	--local currentTruckRuns = getElementData(thePlayer, "job-system-trucker:truckruns") or 0
	
	triggerClientEvent(thePlayer, "spawnFinishMarkerTruckJob", thePlayer)
end
addEvent("job-system:trucker:spawnRoute", true)
addEventHandler("job-system:trucker:spawnRoute", getRootElement(), spawnRoute)

function handledSpot(thePlayer)
	for i = 1, #routes do
		if routes[i] and routes[i][5] == thePlayer then
			return routes[i], i
		end
	end
	return false, 0
end

function selectAFreeSpot(thePlayer)
	local randIndex = math.random(1, #routes)
	if routes[randIndex] then
		if routes[randIndex][5] then
			return false --selectAFreeSpot(thePlayer)
		else
			freeSpot(thePlayer)
			routes[randIndex][5] = thePlayer
			
			if routes[randIndex][4] and tonumber(routes[randIndex][4]) and tonumber(routes[randIndex][4]) > 0 then
				--
			else
				local vehicle = getPedOccupiedVehicle(thePlayer)
				if not vehicle then 
					return false
				end
				local truckModel = getElementModel(vehicle)
				local truck = truckerJobVehicleInfo[truckModel]
				local requiringWeight = math.random(truck[3]-math.ceil(truck[3]/2), truck[3] + math.ceil(truck[3]*2))
				routes[randIndex][4] = requiringWeight
			end
			
			
			
			if debugmode then
				local isActualOrder = "Generic Marker"
				if routes[randIndex][8] and routes[randIndex][8] > 0 then
					isActualOrder = "Yes (For interior ID#"..routes[randIndex][8]..")"
				end
				outputDebugString("[TRUCKER] Player "..getPlayerName(thePlayer):gsub("_", " ").." accepted order '"..routes[randIndex][6].."' , Marker Type: "..isActualOrder)
			end
			
			return routes[randIndex]
		end
	else
		return false --selectAFreeSpot(thePlayer)
	end
end

function freeSpot(thePlayer)
	for i = 1, #routes do
		if routes[i] and routes[i][5] == thePlayer then
			routes[i][5] = nil
		end
	end
	setElementData(thePlayer, "job-system-trucker:currentRoute", false, true) 
end

function cleanUp(reason)
	if getElementData(source, "job") == 1 then
		freeSpot(source)
		local truckingRuns = getElementData(source, "job-system-trucker:truckruns") or false
		if truckingRuns and truckingRuns ~= 0 then
			mysql:query_free("UPDATE `jobs` SET `jobTruckingRuns`='"..tostring(truckingRuns).."' WHERE `jobCharID`='"..tostring(getElementData(source, "dbid")).."' AND `jobID`='1' " )
		end
	end
end
addEventHandler("onPlayerQuit", getRootElement(), cleanUp)

function getTruckCapacity(element)
	if truckerJobVehicleInfo[getElementModel(element)] then
		return truckerJobVehicleInfo[getElementModel(element)][1] -- Weight
	else
		return false
	end
end

function giveTruckingMoney(vehicle)
	local takenWeight = takeRemainingCrates(vehicle)
	if takenWeight then
		exports.hud:sendBottomNotification(source, "RS Haul Operator:", "RS Haul has unloaded "..takenWeight.." Kg(s) of supplies remaining in the back. ")
	end
	
	-- level up and reset runs/wage
	local vehicle = getPedOccupiedVehicle(source)
	if getElementData(vehicle, "job") ~= 1 then
		exports.hud:sendBottomNotification(source, "RS Haul Operator:", "Man..You have to use RS Haul vehicle.")
	else
		local truckModel = getElementModel(vehicle)
		local truck = truckerJobVehicleInfo[truckModel]
		if truck then
			local charID = getElementData(source, "dbid")
			local currentProgress = getElementData(source, "jobProgress") or 0
			local truckruns = getElementData(source, "job-system-trucker:truckruns") or 0
			local truckrunsTilNextLevel = level[getElementData(source, "jobLevel")] or false
			
			local notified = false
			
			if truckruns > 0 then
				if truckrunsTilNextLevel then
					local truckrunCarry = (currentProgress + truckruns) - truckrunsTilNextLevel 
					if truckrunCarry >= 0 then -- level up
						local currentJobLevel = getElementData(source, "jobLevel")
						mysql:query_free("UPDATE `jobs` SET `jobLevel`='"..tostring(currentJobLevel+1).."', `jobProgress`='"..(tostring(truckrunCarry)).."', `jobTruckingRuns`='0' WHERE `jobID`='1' AND `jobCharID` = '" ..tostring(charID).."' " )
						
						--outputChatBox("Congratulations! You've just obtained new Delivery Driver Certificate Level "..tostring(currentJobLevel+1)..".", source, 0, 255, 0, true)
						local info = {
							{string.upper("Delivery Job New Achievement!"), 255,194,14,255,1,"default-bold"},
							{""},
							{"Congratulations! You've just obtained new Delivery Driver Certificate Level "..tostring(currentJobLevel+1)..".", 0,255,0,255,1,"default"},
						}
						triggerClientEvent(source, "hudOverlay:drawOverlayBottomCenter", source, info )
						notified = true
					else
						mysql:query_free("UPDATE `jobs` SET `jobProgress`='"..tostring(currentProgress+truckruns).."', `jobTruckingRuns`='0' WHERE `jobID`='1' AND `jobCharID` = '" ..tostring(charID).."' " )
					end
				else
					mysql:query_free("UPDATE `jobs` SET `jobProgress`='"..tostring(currentProgress+truckruns).."', `jobTruckingRuns`='0' WHERE `jobID`='1' AND `jobCharID` = '" ..tostring(charID).."' " )
				end
				
				exports["job-system"]:fetchJobInfoForOnePlayer(source)
				
				if not notified then
					if not truckrunsTilNextLevel then
						exports.hud:sendBottomNotification(source, "Delivery Job New Achievement!", "Progress: "..(getElementData(source, "jobProgress") or 0).." truck runs (You mastered this job).")
					else
						exports.hud:sendBottomNotification(source, "Delivery Job New Achievement!", "Progress: "..math.floor((getElementData(source, "jobProgress") or 0)/truckrunsTilNextLevel*100).."%")
					end
				end
				playSoundFX(vehicle)
			end
			
		else
			exports.hud:sendBottomNotification(source, "RS Haul Operator:", "Man..You have to use RS Haul vehicle.")
		end
	end
	
	-- RESET SHIT
	freeSpot(source)
	setElementData(source, "job-system-trucker:currentRoute", false , true)
	setElementData(source, "job-system-trucker:truckruns", 0 , true)
	setElementData(source, "job-system-trucker:currentRouteID", -1, true)
	triggerClientEvent(source, "job-system:trucker:showSupplySpot", source)
	triggerClientEvent(source,"truckerjob:clearRoute", source)
	triggerClientEvent(source,"job-system:trucker:killTimerCountDown", source)
	
	-- respawn the vehicle
	setTimer(respawnTruck, 1000, 1, source, vehicle)
	setTimer(updateOverLay, 1000*3, 1, source)
end
addEvent("giveTruckingMoney", true)
addEventHandler("giveTruckingMoney", getRootElement(), giveTruckingMoney)

function respawnTruck(source, vehicle)
	exports['anticheat']:changeProtectedElementDataEx(source, "realinvehicle", 0, false)
	removePedFromVehicle(source, vehicle)
	respawnVehicle(vehicle)
	setVehicleLocked(vehicle, false)
	setElementVelocity(vehicle,0,0,0)
	
	setElementDimension ( vehicle, 0 )
	setElementInterior ( vehicle, 0 )
end

function takeRemainingCrates(vehicle)
	if vehicle then
		local weight = 0
		for key, item in pairs(exports["item-system"]:getItems(vehicle)) do 
			if tonumber(item[1]) == 121 then
				if exports.global:takeItem(vehicle, item[1], item[2]) then
					weight = weight + (tonumber(item[2]) or 0)
				end
			end
		end
		setElementData(vehicle, "job-system-trucker:loadedSupplies",0, true )
		if weight > 0 then
			playSoundFX(vehicle)
			return weight
		else
			return false
		end
	else
		if debugmode then
			outputDebugString("[TRUCKER JOB] / elements not found.")
		end
		return false
	end
end

-- PREVENT DRIVER WITH LOWER SKILL GETTING VEHICLE WITH THE HIGHER LEVEL SKILL
function startEnterTruck(thePlayer, seat, jacked) 
	local truckModel = getElementModel(source)
	if getElementData(source,"job") == 1 and truckerJobVehicleInfo[truckModel] then
		local truckLevelRequire = truckerJobVehicleInfo[truckModel][2]
		local playerJobLevel = getElementData(thePlayer, "jobLevel") or 0
		if playerJobLevel < truckLevelRequire then
			local truckName = getVehicleNameFromModel(truckModel)
			if truckLevelRequire == 1 then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You're not RS Haul Employee, please register for this job at City Hall.")
			else
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You're required Delivery Driver Level "..truckLevelRequire.." Certificate to drive this "..truckName..".")
			end
			if isTimer(lockTimer) then
				killTimer(lockTimer)
				lockTimer = nil
			end
			setVehicleLocked(source, true)
			lockTimer = setTimer(setVehicleLocked, 5000, 1, source, false)
		end
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), startEnterTruck)

function checkTruckingEnterVehicle(thePlayer, seat)
	--if getElementData(source, "owner") == -1 and getElementData(source, "faction") == -1 and seat == 0 and truck[getElementModel(source)] and getElementData(source,"job") == 1 and getElementData(thePlayer,"job") == 1 then
	if seat == 0 and getElementData(source,"job") == 1 and getElementData(thePlayer,"job") == 1 then
		if true then --exports.global:isPlayerScripter(thePlayer) then
			local curentCrates = getCurrentCrates(source)
			triggerClientEvent(thePlayer, "job-system:trucker:showSupplySpot", thePlayer)
			if curentCrates <= 0 then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: Your truck is empty!", "Return to RS Haul station to reload your truck with supplies crates!")
			else
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: ", "Your vehicle has "..curentCrates.." Kg(s) of supplies in the back. Deliver them to our customer's places!")
				spawnRoute(thePlayer)
			end
			local currentTruckRuns = getElementData(thePlayer, "job-system-trucker:truckruns") or 0
			
			if currentTruckRuns > 0 then
				triggerClientEvent(thePlayer, "spawnFinishMarkerTruckJob", thePlayer)
			end
		else
			outputChatBox("", thePlayer, 255, 0, 0)
			exports.hud:sendBottomNotification(thePlayer, "Maxime: ", "We're upgrading trucker job system. Please try another job in the meantime.")
		end
		
		updateOverLay(thePlayer)
	end
end
addEventHandler("onVehicleEnter", getRootElement(), checkTruckingEnterVehicle)

function exitJobVeh(thePlayer, seat)
	if seat == 0 and getElementData(source,"job") == 1 and getElementData(thePlayer,"job") == 1 then
		updateOverLay(thePlayer)
	end
end
addEventHandler("onVehicleExit", getRootElement(), exitJobVeh)

function startLoadingUp(thePlayer)
	if not thePlayer then
		thePlayer = source
	end
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: ", "Man, where is your truck?")
		return false
	end
	if getElementData(vehicle, "job") ~= 1 then
		exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: ", "Man..You have to use RS Haul vehicle.")
		triggerClientEvent(thePlayer, "job-system:trucker:leaveStationLoadup", thePlayer, thePlayer, true)
		return false
	end
	local truckModel = getElementModel(vehicle)
	local truck = truckerJobVehicleInfo[truckModel]
	if truck then
	
		local crateWeight = truck[3]
		
		if exports["item-system"]:giveItem( vehicle, 121, crateWeight) then
			local curentCrates = getCurrentCrates(vehicle)
			playSoundFX(vehicle)
			if curentCrates > 0 and not getElementData(thePlayer, "job-system-trucker:currentRoute") then
				spawnRoute(thePlayer)
			end
		else
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: ", "Your truck is full and can not load anymore of supplies! Drive to the yellow blips to complete deliveries.")
			triggerClientEvent(thePlayer, "job-system:trucker:leaveStationLoadup", thePlayer, thePlayer, true)
		end
		
		updateOverLay(thePlayer)
		
	end
end
addEvent("job-system:trucker:startLoadingUp", true)
addEventHandler("job-system:trucker:startLoadingUp", getRootElement(), startLoadingUp)

function updateOverLay(thePlayer)
	-- if getElementData(thePlayer, "job-system:trucker:updateOverLay") then
		-- setElementData(thePlayer, "job-system:trucker:updateOverLay", false, true)
	-- else
		-- setElementData(thePlayer, "job-system:trucker:updateOverLay", true, true)
	-- end
	triggerClientEvent(thePlayer, "job-system:trucker:UpdateOverLay", thePlayer)
end

function getCurrentCrates(vehicle)
	local count = 0
	for key, item in pairs(exports["item-system"]:getItems(vehicle)) do 
		if item[1] == 121 then -- supply box
			count = count + (tonumber(item[2]) or 0)
		end
	end
	setElementData(vehicle, "job-system-trucker:loadedSupplies",count, true )
	return count
end

function startEnterTruck(thePlayer, seat, jacked) 
	if seat == 0 and truckerJobVehicleInfo[getElementModel(source)] and getElementData(thePlayer,"job") == 1 and jacked then -- if someone try to jack the driver stop him
		if isTimer(lockTimer) then
			killTimer(lockTimer)
			lockTimer = nil
		end
		setVehicleLocked(source, true)
		lockTimer = setTimer(setVehicleLocked, 5000, 1, source, false)
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), startEnterTruck)

function checkIfPlayerTruckHasEnoughtShit()
	local vehicle = getPedOccupiedVehicle(source)
	if getElementData(vehicle, "job") ~= 1 then
		exports.hud:sendBottomNotification(client, "RS Haul Operator: ", "Man..You have to use RS Haul vehicle.")
		return false
	end 
	
	local truckModel = getElementModel(vehicle)
	local truck = truckerJobVehicleInfo[truckModel]
	if not truck then
		exports.hud:sendBottomNotification(client, "RS Haul Operator: ", "Man..RS Haul doesn't allow this model of vehicle.")
		return false
	end
	local success, droppedWeight = unloadCrates(client, vehicle)
	if success then
		local earned = droppedWeight * 2
		local formartedEarned = exports.global:formatMoney(tostring(earned))
		
		exports.global:giveMoney(client, earned)	
		setElementData(client, "job-system-trucker:truckruns",(getElementData(client, "job-system-trucker:truckruns") or 0) + 1 , true)
	
		exports.hud:sendBottomNotification(client, "RS Haul Operator: ", "Customer paid you $"..formartedEarned.." for "..droppedWeight.." Kg of supplies you unloaded from the truck.")
		
		playSoundFX(vehicle)
		
	else
		exports.hud:sendBottomNotification(client, "RS Haul Operator: ", droppedWeight.." Return to RS Haul's warehouse first.")
	end
	
	local curentCrates = getCurrentCrates(vehicle)	
	if curentCrates > 0 then
		spawnRoute(client, true)
	else
		triggerClientEvent(client,"truckerjob:clearRoute", client)
		freeSpot(client)
	end
end
addEvent("truckerjob:checkIfPlayerTruckHasEnoughtShit", true)
addEventHandler("truckerjob:checkIfPlayerTruckHasEnoughtShit", getRootElement(), checkIfPlayerTruckHasEnoughtShit)

function unloadCrates(thePlayer, veh)
	if getVehicleOccupant(veh) == thePlayer then
		local truckModel = getElementModel(veh)
		local truck = truckerJobVehicleInfo[truckModel]
		if not truck then
			return false, "RS Haul doesn't allow this vehicle model."
		end	
		--local currentRoute = getElementData(thePlayer, "job-system-trucker:currentRoute") or false
		local currentSpot = handledSpot(thePlayer)
		if currentSpot then
			local requiredWeight = math.random(truck[3]-math.ceil(truck[3]/2), truck[3] + math.ceil(truck[3]/2))
			if currentSpot[4] then --Weight Required
				requiredWeight = currentSpot[4]
			else
				currentSpot[4] = requiredWeight
				setElementData(thePlayer, "job-system-trucker:currentRoute", currentSpot, true)
			end
			
			local whatPlayerHas = 0
			for key, item in pairs(exports["item-system"]:getItems(veh)) do 
				if item[1] == 121 then
					if tonumber(item[2]) then
						whatPlayerHas = whatPlayerHas + tonumber(item[2])
					end
				end
			end
			
			if whatPlayerHas > 0 then
				for key, item in pairs(exports["item-system"]:getItems(veh)) do 
					if item[1] == 121 then
						if tonumber(item[2]) then
							exports["item-system"]:takeItem(veh, 121,item[2])
						end
					end
				end
				playSoundFX(veh)
			else
				return false, "Your truck is empty."
			end
			
			local carry = whatPlayerHas - requiredWeight
			if currentSpot[8] and currentSpot[8] > 0 then --This is actual order from other player
				if carry >= 0 then -- If truck has enough supplies to solved the spot fully
					if carry > 0 then
						exports["item-system"]:giveItem(veh, 121,tostring(carry))
					end
					removeActualRouteAndOrder(currentSpot[7], currentSpot[8], currentSpot[4], false)
					return true, requiredWeight
				else
					removeActualRouteAndOrder(currentSpot[7], currentSpot[8], currentSpot[4], requiredWeight-whatPlayerHas, whatPlayerHas )
					return true, whatPlayerHas
				end
			else
				if carry >= 0 then
					if carry > 0 then
						exports["item-system"]:giveItem(veh, 121,tostring(carry))
					end
					return true, requiredWeight
				else
					return true, whatPlayerHas
				end
			end
			return false
		end
	else
		return false, "You can not use other people's vehicle."
	end
end

function removeActualRouteAndOrder(orderID, intID, orderWeight, remainingOrder, addToInt )
	if not remainingOrder then --Clear all
		if not updateInteriorSupply(intID, orderWeight) then 
			return false
		end
		
		if not mysql:query_free("DELETE FROM `jobs_trucker_orders` WHERE `orderID`='"..orderID.."' " ) then
			if debugmode then
				outputDebugString("[JOB-SYSTEM-TRUCKER] removeActualRouteAndOrder / Failed to clear actual order #"..orderID.." from SQL / DB Error")
			end
			return false
		end
		
		local success = false
		for i = 1, #routes do
			if routes[i] and routes[i][7] == orderID then
				success = true
				routes[i] = nil
				break
			end
		end
		
		if not success then 
			if debugmode then
				outputDebugString("[JOB-SYSTEM-TRUCKER] removeActualRouteAndOrder / Failed to clear actual order #"..orderID.." IG Routes")
			end
			return false
		end
		
		if debugmode then
			outputDebugString("[JOB-SYSTEM-TRUCKER] removeActualRouteAndOrder / Cleared actual order #"..orderID.." from SQL and IG Routes")
		end
		
		return true
	else
		remainingOrder = tostring(math.floor(tonumber(remainingOrder)))
		addToInt = tostring(math.floor(tonumber(addToInt)))
		
		if not updateInteriorSupply(intID, addToInt) then
			return false
		end
		
		if not mysql:query_free("UPDATE `jobs_trucker_orders` SET `orderWeight`='"..remainingOrder.."' WHERE `orderID`='"..orderID.."' " ) then
			if debugmode then
				outputDebugString("[JOB-SYSTEM-TRUCKER] removeActualRouteAndOrder / Failed to update order #"..orderID.." from SQL")
			end
			return false
		end
		
		local success = false
		for i = 1, #routes do
			if routes[i] and routes[i][7] == orderID then
				routes[i][4] = remainingOrder
				success = true
				break
			end
		end
		
		if not success then 
			if debugmode then
				outputDebugString("[JOB-SYSTEM-TRUCKER] removeActualRouteAndOrder / Failed to update actual order #"..orderID.." from IG Routes")
			end
			return false
		end
		
		return true
	end
end

function updateInteriorSupply(intID, supplies)
	intID = tostring(intID)
	if mysql:query_free("UPDATE `interiors` SET `supplies`=`supplies`+'"..tostring(supplies).."' WHERE `id`='"..intID.."' " ) then
		exports["interior-system"]:realReloadInterior(tonumber(intID))
		if debugmode then
			outputDebugString("[JOB-SYSTEM-TRUCKER] updateInteriorSupply / Updated supplies for interior#"..intID..".")
		end
		return true
	else
		if debugmode then
			outputDebugString("[JOB-SYSTEM-TRUCKER] updateInteriorSupply / Failed to update supplies for interior#"..intID..".")
		end
		return false
	end
end

function updateNextCheckpoint(pointid)
	if not pointid then pointid = -1 end
	setElementData(source, "job-system-trucker:currentRouteID",pointid, true )
end
addEvent("updateNextCheckpoint", true)
addEventHandler("updateNextCheckpoint", getRootElement(), updateNextCheckpoint)

function restoreTruckingJob()
	if getElementData(source, "job") == 1 then
		triggerClientEvent(source, "restoreTruckerJob", source)
	end
end
addEventHandler("restoreJob", getRootElement(), restoreTruckingJob)

function respawnAllTrucks()
	local vehicles = exports.pool:getPoolElementsByType("vehicle")
	local counter = 0
	
	for k, theVehicle in ipairs(vehicles) do
		local dbid = getElementData(theVehicle, "dbid")
		if dbid and dbid > 0 then
			if getElementData(theVehicle, "job") == 1 then
				local driver = getVehicleOccupant(theVehicle)
				local pass1 = getVehicleOccupant(theVehicle, 1)
				local pass2 = getVehicleOccupant(theVehicle, 2)
				local pass3 = getVehicleOccupant(theVehicle, 3)

				if not pass1 and not pass2 and not pass3 and not driver and not getVehicleTowingVehicle(theVehicle) and #getAttachedElements(theVehicle) == 0 then				
					if isElementAttached(theVehicle) then
						detachElements(theVehicle)
					end
					exports['anticheat']:changeProtectedElementDataEx(theVehicle, 'i:left')
					exports['anticheat']:changeProtectedElementDataEx(theVehicle, 'i:right')
					respawnVehicle(theVehicle)
					setVehicleLocked(theVehicle, false)
					setElementInterior(theVehicle, getElementData(theVehicle, "interior"))
					setElementDimension(theVehicle, getElementData(theVehicle, "dimension"))
					exports['anticheat']:changeProtectedElementDataEx(theVehicle, "vehicle:radio", 0, true)
					counter = counter + 1
				end
			end
		end
	end
	outputDebugString("[TRUCKER JOB] Respawned " .. counter .. " Trucks.")
	return counter
end
--setTimer(respawnAllTrucks, 60000*5, 0) -- Check and respawn every 5 minutes.

function restartResource()
	for key,player in pairs (getElementsByType("player")) do
		if getElementData(player, "job") == 1 and getPedOccupiedVehicle(player) and getElementData(getPedOccupiedVehicle(player), "job") == 1 then		
			checkTruckingEnterVehicle(player, 0)
		end
	end
end
addEventHandler("onResourceStart", getRootElement(), restartResource)

function enteringRSHaulWarehouse1()
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setVehicleTurnVelocity(veh, 0, 0, 0)
		setElementPosition(veh, 1540.7763671875, 1610.8740234375, 15.559964179993)
		setElementRotation(veh,0, 0, 180)
		setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 66)
	end
	--fadeCamera (source, true , 1)
end
addEvent("job-system:trucker:enteringRSHaulWarehouse1", true)
addEventHandler("job-system:trucker:enteringRSHaulWarehouse1", getRootElement(), enteringRSHaulWarehouse1)

function enteringRSHaulWarehouse2()
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setVehicleTurnVelocity(veh, 0, 0, 0)
		setElementPosition(veh, 1534.1630859375, 1611.2021484375, 15.560300827026)
		setElementRotation(veh,0, 0, 180)
		setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 66)
	end
	--fadeCamera (source, true , 1)
end
addEvent("job-system:trucker:enteringRSHaulWarehouse2", true)
addEventHandler("job-system:trucker:enteringRSHaulWarehouse2", getRootElement(), enteringRSHaulWarehouse2)

function exitingRSHaulWarehouse1()
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setVehicleTurnVelocity(veh, 0, 0, 0)
		setElementPosition(veh, -66.40234375, -1120.1865234375, 1.1872147321701 )
		setElementRotation(veh,0, 0, 70)
		setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 0)
	end
	--fadeCamera (source, true , 1)
end
addEvent("job-system:trucker:exitingRSHaulWarehouse1", true)
addEventHandler("job-system:trucker:exitingRSHaulWarehouse1", getRootElement(), exitingRSHaulWarehouse1)

function exitingRSHaulWarehouse2(player)
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setVehicleTurnVelocity(veh, 0, 0, 0)
		setElementPosition(veh, -63.0458984375, -1111.25, 1.1973638534546 )
		setElementRotation(veh,0, 0, 70)
		setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 0)
	end
	--fadeCamera (veh, true , 1)
end
addEvent("job-system:trucker:exitingRSHaulWarehouse2", true)
addEventHandler("job-system:trucker:exitingRSHaulWarehouse2", getRootElement(), exitingRSHaulWarehouse2)

function toggleDebugMode(thePlayer, commandName)
	if exports.global:isPlayerScripter(thePlayer) then
		local targetRes = getResourceFromName(commandName) or false
		if targetRes and targetRes == getThisResource() then
			debugmode = not debugmode
			outputChatBox("Debug Mode for '"..commandName.."' : "..tostring(debugmode), thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler(getResourceName(getThisResource()), toggleDebugMode)

function cleanup ()
	for key, thePlayer in pairs(getTruckers()) do
		exports.hud:sendBottomNotification(thePlayer, "Delivery Job Script Update", "A Developer has updated the trucker job system. Please re-enter the truck if you're currently in one.")
		setElementData(thePlayer, "job-system-trucker:currentRoute", false, true)
	end
	fetchActualOrders()
	setTimer(fetchActualOrders, 60000*10, 0) -- Every 10 mins
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), cleanup)

function getTruckers()
	local truckers = {}
	for key, thePlayer in pairs(getElementsByType("player")) do
		if getElementData(thePlayer, "job") == 1 then
			table.insert(truckers, thePlayer)
		end
	end
	return truckers
end