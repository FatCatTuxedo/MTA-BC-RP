local wheelchairArray = { }

function hasPlayerwheelchairSpawned( playerElement )
	return isElement(playerElement) and wheelchairArray[playerElement] and true or false
end
addEvent( "wheelchair:hasPlayerwheelchairSpawned", true )
addEventHandler( "wheelchair:hasPlayerwheelchairSpawned", getRootElement( ), hasPlayerwheelchairSpawned )

function isPedwheelchairOccupied( playerElement )
	return (getElementData(  wheelchairArray[ playerElement ], "realism:wheelchair:playerOnIt") and isElement(getElementData(  wheelchairArray[ playerElement ], "realism:wheelchair:playerOnIt"))) --and getElementAttachedTo ( wheelchairArray[ playerElement ] ) == getElementData(  wheelchairArray[ playerElement ], "realism:wheelchair:playerOnIt")
end
addEvent( "wheelchair:isPedwheelchairOccupied", true )
addEventHandler( "wheelchair:isPedwheelchairOccupied", getRootElement( ), isPedwheelchairOccupied )

function destroywheelchair( playerElement, vehicle )

	if not playerElement and source then
		playerElement = source
	end
	
	if  wheelchairArray[ playerElement ] then
		if vehicle and isElement(vehicle) then
			local patient = getElementData(wheelchairArray[playerElement], "realism:wheelchair:playerOnIt")
			--outputDebugString("patient="..tostring(patient).." element="..tostring(isElement(patient)))
			--outputDebugString("attachedTo="..tostring(getElementAttachedTo(wheelchairArray[playerElement])))
			if(isElement(patient)) then --and getElementAttachedTo(wheelchairArray[playerElement]) == patient
				takePedFromwheelchair(patient, playerElement)
				local patientSeats = {2,3,4,5,1}
				local warpResult = false
				for k,v in ipairs(patientSeats) do
					warpResult = warpPedIntoVehicle(patient, vehicle, v)
					if warpResult then
						break
					end
				end
				--outputDebugString("warpResult="..tostring(warpResult))
				if not warpResult then
					outputChatBox("The "..tostring(exports.global:getVehicleName(vehicle)).." does not have space for any more patients.", playerElement, 255, 0, 0)
				else
					setElementData(patient, "realism:wheelchair:isInAmbulanceOnwheelchair", true, true)
				end
			end
		end
		detachElements( wheelchairArray[ playerElement ], playerElement )
		destroyElement( wheelchairArray[ playerElement ] )
		wheelchairArray[ playerElement ] = false
		setElementData(playerElement, "realism:wheelchair:haswheelchair", false, true)
		return true
	end
	return false
end
addEvent( "wheelchair:destroywheelchair", true )
addEventHandler( "wheelchair:destroywheelchair", getRootElement( ), destroywheelchair )

function leavewheelchair( playerElement )

	if not playerElement and source then
		playerElement = source
	end
	
	if  wheelchairArray[ playerElement ] then
		triggerClientEvent( playerElement, "wheelchair:getPositionInFrontOfElement", getRootElement( ), playerElement, false, "leave" )
	end
end
addEvent( "wheelchair:leavewheelchair", true )
addEventHandler( "wheelchair:leavewheelchair", getRootElement( ), leavewheelchair )

function takewheelchair( wheelchair, playerElement )

	if not playerElement and source then
		playerElement = source
	end
	
	if  isElement(wheelchair) and getElementType(wheelchair) == "object" then
		if not wheelchairArray[playerElement] then
			wheelchairArray[ playerElement ] = wheelchair
			triggerClientEvent( playerElement, "wheelchair:getPositionInFrontOfElement", getRootElement( ), playerElement, false, "take" ) 
		end
	end
end
addEvent( "wheelchair:takewheelchair", true )
addEventHandler( "wheelchair:takewheelchair", getRootElement( ), takewheelchair )

function createwheelchair( playerElement, vehicle )
	if not playerElement and source then
		playerElement = source
	end
	
	if (getPedOccupiedVehicle(playerElement)) then
		return
	end	

	if hasPlayerwheelchairSpawned( playerElement ) then
		if vehicle then
			exports.global:sendLocalMeAction(playerElement, "puts the wheelchair inside the "..tostring(exports.global:getVehicleName(vehicle))..".")
		else
			exports.global:sendLocalMeAction(playerElement, "puts the wheelchair inside.")
		end
		destroywheelchair( playerElement, vehicle )
	else
		if vehicle then
			exports.global:sendLocalMeAction(playerElement, "takes out a wheelchair from the "..tostring(exports.global:getVehicleName(vehicle))..".")
		else
			exports.global:sendLocalMeAction(playerElement, "takes out a wheelchair.")
		end
		triggerClientEvent( playerElement, "wheelchair:getPositionInFrontOfElement", getRootElement( ), playerElement, vehicle ) 
	end
end
addEvent( "wheelchair:createwheelchair", true )
addEventHandler( "wheelchair:createwheelchair", getRootElement( ), createwheelchair )

function getPositionInFrontOfElement( playerElement, x, y, z, vehicle, action )
	if(action == "leave") then
		if(isElement(wheelchairArray[playerElement])) then
			setElementCollisionsEnabled(wheelchairArray[ playerElement ], true)
			detachElements( wheelchairArray[ playerElement ], playerElement )
			setElementPosition(wheelchairArray[playerElement], x, y, z - 0.5)
			local rz, rx, ry = getElementRotation(playerElement, "ZXY")
			setElementRotation(wheelchairArray[playerElement], rz, rx, ry, "ZXY")
			
			wheelchairArray[ playerElement ] = false
			setElementData(playerElement, "realism:wheelchair:haswheelchair", false, true)
		else
			wheelchairArray[playerElement] = false
		end
	elseif(action == "take") then
		if(isElement(wheelchairArray[playerElement])) then
			setElementPosition(wheelchairArray[playerElement], x, y, z - 0.5)
			setElementRotation(wheelchairArray[playerElement], 0, 0, 0)
			attachElements(wheelchairArray[playerElement], playerElement, 0, 0, -0.5)
			local attach_x, attach_y, attach_z = getElementPosition( wheelchairArray[ playerElement ] )
			detachElements( wheelchairArray[ playerElement ], playerElement )
			distance = getDistanceBetweenPoints2D( x, y, attach_x, attach_y )
			attachElements( wheelchairArray[ playerElement ], playerElement, 0, distance, -0.5 )
			setElementCollisionsEnabled(wheelchairArray[ playerElement ], false)
			-- Used for tracking clientside
			setElementData(playerElement, "realism:wheelchair:haswheelchair",  wheelchairArray[ playerElement ], true)
			setElementData(wheelchairArray[ playerElement ], "realism:wheelchair:ownedBy", playerElement, true)
		else
			wheelchairArray[playerElement] = false
		end
	else
		if not hasPlayerwheelchairSpawned( playerElement ) then
			wheelchairArray[ playerElement ] = createObject ( 2146, x, y, z - 0.5, 0, 0, 0 )
			attachElements( wheelchairArray[ playerElement ], playerElement, 0, 0, -0.5 )
			local attach_x, attach_y, attach_z = getElementPosition( wheelchairArray[ playerElement ] )
			detachElements( wheelchairArray[ playerElement ], playerElement )
			distance = getDistanceBetweenPoints2D( x, y, attach_x, attach_y )
			attachElements( wheelchairArray[ playerElement ], playerElement, 0, distance, -0.5 )
			setElementCollisionsEnabled(wheelchairArray[ playerElement ], false)
			-- Used for tracking clientside
			--outputDebugString(tostring(wheelchairArray[playerElement]))
			setElementData(playerElement, "realism:wheelchair:haswheelchair",  wheelchairArray[ playerElement ], true)
			setElementData(  wheelchairArray[ playerElement ], "realism:wheelchair:ownedBy", playerElement, true)

			if vehicle and isElement(vehicle) then
				local patient = false
				local passengers = getVehicleOccupants(vehicle)
				--outputDebugString("#passengers="..tostring(#passengers).." : "..tostring(passengers))
				for k,v in pairs(passengers) do
					if(k ~= 0) then
						--outputDebugString("k is not 0 but "..tostring(k))
						--outputDebugString(tostring(getElementData(v, "realism:wheelchair:isInAmbulanceOnwheelchair")))
						if getElementData(v, "realism:wheelchair:isInAmbulanceOnwheelchair") then
							patient = v
							break
						end
					end
				end
				if patient then
					removePedFromVehicle(patient)
					movePedOntowheelchair(patient, playerElement)
					setElementData(patient, "realism:wheelchair:isInAmbulanceOnwheelchair", false, true)
				end
			end
		end
	end
end
addEvent( "wheelchair:getPositionInFrontOfElement", true )
addEventHandler( "wheelchair:getPositionInFrontOfElement", getRootElement( ), getPositionInFrontOfElement )

function setwheelchairInterior(player, interior, dimension)
	if wheelchairArray[player] then
		--outputDebugString("is wheelchair")
		if(isElement(wheelchairArray[player])) then
			--outputDebugString("is wheelchair element")
			if interior then
				--outputDebugString("int")
				setElementInterior(wheelchairArray[player], interior)
			end
			if dimension then
				--outputDebugString("dim")
				setElementDimension(wheelchairArray[player], dimension)
			end
			--outputDebugString("occupied="..tostring(isPedwheelchairOccupied(player)))
			if isPedwheelchairOccupied(player) then
				--outputDebugString("is occupied")
				local patient = getElementData(wheelchairArray[player], "realism:wheelchair:playerOnIt")
				if(isElement(patient)) then --and getElementAttachedTo(wheelchairArray[player]) == patient
					--outputDebugString("patient is element")
					--if interior then
					--	setElementInterior(patient, interior)
					--end
					--if dimension then
					--	setElementDimension(patient, dimension)
					--end
					local interiortable = {false, false, false, interior, dimension}
					triggerClientEvent(patient, "setPlayerInsideInterior", getRootElement(), interiortable, getRootElement())
					--triggerEvent("onPlayerInteriorChange", patient, 0, 0, dimension, interior)
				end
			end
		end
	end
end

addEventHandler("onPlayerInteriorChange", getRootElement( ),
	function( a, b, toDimension, toInterior)	
		setwheelchairInterior(source, toInterior, toDimension)
	end
)


function checkPedEnterVehicleWithwheelchair( clientid )
	if hasPlayerwheelchairSpawned( clientid ) then
		cancelEvent( ) -- Cannot enter a vehicle with a wheelchair
	end
end
addEventHandler ( "onVehicleStartEnter", getRootElement(), checkPedEnterVehicleWithwheelchair )

function movePedOntowheelchair(	targetElement, playerElement )
	if not source and playerElement then
		source = playerElement
	end
	if not targetElement or not isElement(targetElement) then 
		return false -- Target player does not exist
	end
	
	if not hasPlayerwheelchairSpawned( source ) then 
		return false -- wheelchair does not exist
	end
	if getPedOccupiedVehicle( targetElement ) then
		return false -- Target player is in a vehicle :(
	end
	if isPedwheelchairOccupied( source ) then
		return false -- wheelchair already in use.
	end


	local sourceX, sourceY, sourceZ = getElementPosition(source)
	local targetX, targetY, targetZ = getElementPosition(targetElement)
	if getDistanceBetweenPoints3D(sourceX, sourceY, sourceZ, targetX, targetY, targetZ ) > 10 then
		return false -- Far distance between the two players
	end
	
	attachElements( targetElement, wheelchairArray[ source ], 0, 0, 1.5 )
	exports.global:applyAnimation( targetElement, "CRACK", "crckdeth2", -1, true )
	setElementData(  wheelchairArray[ source ], "realism:wheelchair:playerOnIt", targetElement, true )
	
end
addEvent( "wheelchair:movePedOntowheelchair", true )
addEventHandler( "wheelchair:movePedOntowheelchair", getRootElement( ), movePedOntowheelchair )

function takePedFromwheelchair(	targetElement, playerElement )
	if not source and playerElement then
		source = playerElement
	end
	if not targetElement or not isElement(targetElement) then 
		return false -- Target player does not exist
	end
	
	if not hasPlayerwheelchairSpawned( source ) then 
		return false -- wheelchair does not exist
	end
	
	if getPedOccupiedVehicle( targetElement ) then
		return false -- Target player is in a vehicle :(
	end
	
	local sourceX, sourceY, sourceZ = getElementPosition(source)
	local targetX, targetY, targetZ = getElementPosition(targetElement)
	if getDistanceBetweenPoints3D(sourceX, sourceY, sourceZ,  targetX, targetY, targetZ ) > 10 then
		return false -- Far distance between the two players
	end
	
	detachElements( targetElement, wheelchairArray[ source ], 0, 0, 1.5 )
	exports.global:removeAnimation(targetElement)
	setElementData(  wheelchairArray[ source ], "realism:wheelchair:playerOnIt", false, false )
end
addEvent( "wheelchair:takePedFromwheelchair", true )
addEventHandler( "wheelchair:takePedFromwheelchair", getRootElement( ), takePedFromwheelchair )
