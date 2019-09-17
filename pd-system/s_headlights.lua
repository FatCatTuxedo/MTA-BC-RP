local function getFactionType(vehicle)
	local vehicleFactionID = getElementData(vehicle, "faction")
	local vehicleFactionElement = exports.pool:getElement("team", vehicleFactionID)
	if vehicleFactionElement then
		local type = getElementData(vehicleFactionElement, "type")
		if tonumber(type) then
			return getElementData(vehicleFactionElement, "type"), vehicleFactionID
		end
	end
	return 100, 100
end

function turnOnELS(thePlayer)
	local veh = getPedOccupiedVehicle(thePlayer)
	if not veh then return end
	if getPedOccupiedVehicleSeat(thePlayer) > 1 then return end
	local id = getElementModel(veh)
	if (exports.global:hasItem(veh, 61)) then
			if (getElementData(veh, "roleplay:vehicles.strobe.emergency")) then
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , false )
				setVehicleOverrideLights ( veh, 0 )
				removeElementData(veh, "roleplay:vehicles.strobe.emergency")
			else
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , true )
				setVehicleOverrideLights ( veh, 2 ) 
				setElementData(veh, "roleplay:vehicles.strobe.emergency", true, true)
			end
			triggerClientEvent(root, "toggleEmergencyStrobes", root, veh)
	elseif (exports.global:hasItem(veh, 218)) then
			if (getElementData(veh, "roleplay:vehicles.strobe.medical")) then
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , false )
				setVehicleOverrideLights ( veh, 0 ) 
				removeElementData(veh, "roleplay:vehicles.strobe.medical")
			else
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , true )
				setVehicleOverrideLights ( veh, 2 ) 
				setElementData(veh, "roleplay:vehicles.strobe.medical", true, true)
			end
			triggerClientEvent(root, "toggleEmergencyStrobes", root, veh)
	elseif (exports.global:hasItem(veh, 219)) then
			if (getElementData(veh, "roleplay:vehicles.strobe.funeral")) then
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , false )
				setVehicleOverrideLights ( veh, 0 ) 
				removeElementData(veh, "roleplay:vehicles.strobe.funeral")
			else
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , true )
				setVehicleOverrideLights ( veh, 2 ) 
				setElementData(veh, "roleplay:vehicles.strobe.funeral", true, true)
			end
			triggerClientEvent(root, "toggleEmergencyStrobes", root, veh)
	elseif (exports.global:hasItem(veh, 140)) then
			if (getElementData(veh, "roleplay:vehicles.strobe.orange")) then
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , false )
				setVehicleOverrideLights ( veh, 0 ) 
				removeElementData(veh, "roleplay:vehicles.strobe.orange")
			else
				playSoundFrontEnd (thePlayer, 42)
				triggerEvent('sendAme', thePlayer, "presses a button on their dashboard")
				setVehicleSirensOn ( veh , true )
				setVehicleOverrideLights ( veh, 2 ) 
				setElementData(veh, "roleplay:vehicles.strobe.orange", true, true)
			end
			triggerClientEvent(root, "toggleEmergencyStrobes", root, veh)
	else
		outputChatBox("This vehicle does not have any strobes installed.", thePlayer, 255, 194, 14)
	end
end
addEvent("turnOnELS", true)
addEventHandler ( "turnOnELS", getRootElement(), turnOnELS)

function bindOnVehicleEnter(thePlayer, seat, jacked)
	if getElementType(thePlayer) == "player" then
		bindKey( thePlayer, "p", "down", turnOnELS)
	end
end
addEventHandler("onVehicleEnter", root, bindOnVehicleEnter)

function bindOnVehicleExit(thePlayer, seat, jacked)
	if getElementType(thePlayer) == "player" then
		unbindKey( thePlayer, "p", "down", turnOnELS)
	end
end
addEventHandler("onVehicleExit", root, bindOnVehicleExit)