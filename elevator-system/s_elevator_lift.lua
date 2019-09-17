-- Script: elevator-system -> Lifts
-- Description: Adds a new elevator type, lift, that gives you a GUI that lets you choose what floor to go to.
-- Server-Side
-- Created by Exciter for Owl Gaming, 16.05.2014 (DD/MM/YYYY)
-- Based on the script from RPP.
-- License: BSD

mysql = exports.mysql
null = mysql_null()

local toLoad = { }
local threads = { }

function createLift(thePlayer, commandName, lift, floor, ...)
	--if (exports.integration:isPlayerTrialAdmin(thePlayer)) or (exports.donators:hasPlayerPerk(thePlayer,14) and exports.integration:isPlayerTrialAdmin(thePlayer) or tostring(getElementData(thePlayer, "account:username")) == "Exciter") then
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		local name = table.concat({...}, " ")
		if(not lift or not floor or not name) then
			outputChatBox("SYNTAX: /" .. commandName .. " [lift ID] [floor] [name]", thePlayer, 255, 194, 14)
			outputChatBox("Set lift ID to 0 to create a new lift. Use ID to add a floor to existing lift.", thePlayer, 255, 194, 14)
			return false
		end
		if(string.len(floor) > 3) then
			outputChatBox("AddLift: floor must be 1-3 characters. E.g. '1', '203' or 'U1'.", thePlayer, 255, 0, 0)
			return false
		end
		
		local lift = tonumber(lift)
		
		local x, y, z = getElementPosition(thePlayer)
		local interior = getElementInterior(thePlayer)
		local dimension = getElementDimension(thePlayer)
		
		if(lift == 0) then
			id = SmallestLiftID()
			if id then
				local comment = tostring(getPlayerName(thePlayer))..":"..tostring(now())..": "..tostring(name)
				local query = mysql:query_free("INSERT INTO lifts SET id='" .. mysql:escape_string(id) .. "', comment='" .. mysql:escape_string(comment) .. "'")
				if (query) then
					local floorID = SmallestLiftFloorID()
					local query2 = mysql:query_free("INSERT INTO lift_floors SET id='" .. mysql:escape_string(floorID) .. "', lift='" .. mysql:escape_string(id) .. "', x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dimension) .. "', interior='" .. mysql:escape_string(interior) .. "', floor='" .. mysql:escape_string(floor) .. "', name='" .. mysql:escape_string(name) .. "'")
					if(query2) then
						loadOneLiftFloor(floorID)
						outputChatBox("Lift created with ID #" .. id .. ".", thePlayer, 0, 255, 0)
					end
				end
			else
				outputChatBox("There was an error while creating a lift. Try again.", thePlayer, 255, 0, 0)
			end
		elseif(lift > 0) then
			id = SmallestLiftFloorID()
			if id then
				local query = mysql:query_free("INSERT INTO lift_floors SET id='" .. mysql:escape_string(id) .. "', lift='" .. mysql:escape_string(lift) .. "', x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dimension) .. "', interior='" .. mysql:escape_string(interior) .. "', floor='" .. mysql:escape_string(floor) .. "', name='" .. mysql:escape_string(name) .. "'")
				if (query) then
					loadOneLiftFloor(id)
					outputChatBox("Floor with ID #"..id.." added to lift #".. lift ..".", thePlayer, 0, 255, 0)
				end
			else
				outputChatBox("There was an error while creating a lift. Try again.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("addlift", createLift, false, false)


function findLift(id)
	id = tonumber(id)
	if id > 0 then
		local possibleInteriors = getElementsByType("lift")
		for _, elevator in ipairs(possibleInteriors) do
			local eleID = getElementData(elevator, "dbid")
			if eleID == id then
				local elevatorStatus = getElementData(elevator, "status")
				
				return id, elevatorStatus, elevator
			end
		end
	end
	return 0
end

function findLiftElement(id)
	id = tonumber(id)
	if id > 0 then
		local possibleInteriors = getElementsByType("lift")
		for _, elevator in ipairs(possibleInteriors) do
			local eleID = getElementData(elevator, "dbid")
			if eleID == id then
				return  elevator
			end
		end
	end
	return false
end

function reloadOneLift(elevatorID, skipcheck)
	local dbid, status, elevatorElement = findLift( elevatorID )
	if (dbid > 0 or skipcheck)then
		local realElevatorElement = findLiftElement(dbid)
		if not realElevatorElement then
			outputDebugString("elevator-system/s_elevator_lift.lua: [reloadOneLift] Can't find element")
		end
		triggerClientEvent("deleteInteriorElement", realElevatorElement, tonumber(dbid))
		destroyElement(realElevatorElement)
		loadOneLift(tonumber(dbid), false)
	else
		outputDebugString("elevator-system/s_elevator_lift.lua: Tried to reload elevator without ID.")
	end
end

function loadOneLift(elevatorID, hasCoroutine)
	if (hasCoroutine==nil) then
		hasCoroutine = false
	end
	--outputDebugString("elevatorID="..tostring(elevatorID))
	local result = mysql:query("SELECT id, x, y, z, dimension, interior FROM `lift_floors` WHERE lift = "..elevatorID.." ORDER BY `id` ASC")
	if result then
		while true do
			local row = mysql:fetch_assoc(result)
			if not row then outputDebugString("row="..tostring(row).." result="..tostring(result)) break end
			for k, v in pairs( row ) do
				if v == null then
					row[k] = nil
				else
					row[k] = tonumber(v) or v
				end
			end
			local elevatorElement = createElement("lift", "lif"..tostring(row.id))
			setElementDataEx(elevatorElement, "dbid", row.id, true)
			setElementDataEx(elevatorElement, "liftset", elevatorID, true)
			setElementDataEx(elevatorElement, "status", row.disabled == 1, true)
			local pickup = createPickup(row.x, row.y, row.z, 3,  1318)
			--outputDebugString("pickup "..tostring(pickup))
		end
		mysql:free_result(result)
	else
		outputDebugString("elevator-system/s_elevator_lift.lua: loadOneLift failed")
	end
end

function loadOneLiftFloor(id, hasCoroutine)
	if (hasCoroutine==nil) then
		hasCoroutine = false
	end
	
	local row = mysql:query_fetch_assoc("SELECT id, lift, x, y, z, dimension, interior, floor, name FROM `lift_floors` WHERE id = " .. mysql:escape_string(id) .. " LIMIT 1" )
	if row then
		if (hasCoroutine) then
			coroutine.yield()
		end
		
		for k, v in pairs( row ) do
			if v == null then
				row[k] = nil
			else
				row[k] = tonumber(row[k]) or row[k]
			end
		end
		
		local liftElement = findLiftElement(row.lift)
		if not liftElement then
			liftElement = createElement("lift", "lif"..tostring(row.lift))
			setElementDataEx(liftElement, "dbid", row.lift, true)
		end	
		local pickup = createPickup(row.x, row.y, row.z, 3,  1318)
		setElementParent(pickup, liftElement)
		setElementInterior(pickup, row.interior)
		setElementDimension(pickup, row.dimension)
		setElementDataEx(pickup, "rpp.lift.floor.id", row.id, true)
		--setElementDataEx(pickup, "rpp.lift.set", row.lift, true)
		setElementDataEx(pickup, "rpp.lift.floor.floor", row.floor, true)
		setElementDataEx(pickup, "rpp.lift.floor.name", row.name, true)
		addEventHandler("onPickupHit", pickup, pickupHit)
		addEventHandler("onPickupLeave", pickup, pickupLeave)
		--setPickupRespawnInterval(pickup, 1)
	end
end

function pickupHit(thePlayer)
	triggerClientEvent(thePlayer, "lift:hit", source, thePlayer)
	cancelEvent()
end

function pickupLeave(thePlayer)
	--outputDebugString("pickupHit()")
	triggerClientEvent(thePlayer, "lift:leave", source, thePlayer)
	cancelEvent()
end

function loadAllLifts(res)
	local result = mysql:query("SELECT id FROM `lift_floors` ORDER BY `id` ASC")
	if result then
		while true do
			local row = mysql:fetch_assoc(result)
			if not row then break end

			toLoad[tonumber(row["id"])] = true
		end
		mysql:free_result(result)

		for id in pairs( toLoad ) do

			local co = coroutine.create(loadOneLiftFloor)
			coroutine.resume(co, id, true)
			table.insert(threads, co)
		end
		setTimer(resume, 1000, 4)
	else
		local result = mysql:query_free("CREATE TABLE IF NOT EXISTS `lifts` (`id` int(11) NOT NULL AUTO_INCREMENT, `disabled` tinyint(1) NOT NULL DEFAULT '0', `comment` varchar(255) DEFAULT NULL, PRIMARY KEY (`id`));")
		if result then
			local result2 = mysql:query_free("CREATE TABLE IF NOT EXISTS `lift_floors` (`id` int(11) NOT NULL AUTO_INCREMENT, `lift` int(11) NOT NULL, `x` float(10,6) DEFAULT '0.000000', `y` float(10,6) DEFAULT '0.000000', `z` float(10,6) DEFAULT '0.000000', `dimension` int(5) DEFAULT '0', `interior` int(5) DEFAULT '0', `floor` varchar(3) NOT NULL, `name` varchar(100) NOT NULL, PRIMARY KEY (`id`));")
			if result2 then
				loadAllLifts(res)
			else
				outputDebugString("elevator-system/s_elevator_lift.lua: loadAllLifts failed")
			end
		else
			outputDebugString("elevator-system/s_elevator_lift.lua: loadAllLifts failed")
		end
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllLifts)

function resume()
	for key, value in ipairs(threads) do
		coroutine.resume(value)
	end
end

function enterLiftFloor(id)
	local player = client
	local element = findLiftElement(id)
	local dimension = getElementDimension(element)
	local interior = getElementInterior(element)
	local x, y, z = getElementPosition(element)
	
	local lifttable = {x, y, z, interior, dimension}
	
	if(not isInteriorLocked(dimension)) then	
		if isElement(player) then
			triggerClientEvent(player, "setPlayerInsideInterior", element or getRootElement(), lifttable, element  or getRootElement())
		end
	else
		outputChatBox("You push the elevator button, but nothing happens.", player, 255, 0,0, true)
	end
	
end
addEvent("lift:use", true)
addEventHandler("lift:use", getRootElement(), enterLiftFloor)

function deleteLift(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or tostring(getElementData(thePlayer, "account:username")) == "Exciter") then
		if not (tonumber(id)) then
			outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			id = tonumber(id)
			
			local dbid, status, element = findLift( id )
			
			if element then
				local queryFloors = mysql:query_free("DELETE FROM lift_floors WHERE lift='" .. mysql:escape_string(dbid) .. "'")
				local query = mysql:query_free("DELETE FROM lifts WHERE id='" .. mysql:escape_string(dbid) .. "'")
				if query then
					reloadOneLift(dbid)
					outputChatBox("Elevator #" .. id .. " Deleted!", thePlayer, 0, 255, 0)
				else
					outputChatBox("ELE0015 Error, please report to a scripter.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Elevator ID does not exist!", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("dellift", deleteLift, false, false)

function getNearbyLifts(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or tostring(getElementData(thePlayer, "account:username")) == "Exciter") then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		outputChatBox("Nearby Lifts:", thePlayer, 255, 126, 0)
		local found = false
		
		local possibleElevators = getElementsByType("lift")
		for _, elevator in ipairs(possibleElevators) do
			local x, y, z = getElementPosition(elevator)
			if (getElementDimension(elevator) == dimension) then
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
				if (distance <= 11) then
					local dbid = getElementData(elevator, "dbid")
					outputChatBox(" ID " .. dbid, thePlayer, 255, 126, 0)
					found = true
				end
			end
		end
		if not found then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbylifts", getNearbyLifts, false, false)

function SmallestLiftID()
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM lifts AS e1 LEFT JOIN lifts AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		if result["nextID"] == null then
			return 1
		else
			return tonumber(result["nextID"])
		end
	end
	return false
end
function SmallestLiftFloorID()
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM lift_floors AS e1 LEFT JOIN lift_floors AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		if result["nextID"] == null then
			return 1
		else
			return tonumber(result["nextID"])
		end
	end
	return false
end

function toggleLift( thePlayer, commandName, id )
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or tostring(getElementData(thePlayer, "account:username")) == "Exciter") then
		id = tonumber( id )
		if not id then
			outputChatBox( "SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14 )
		else
			local dbid, status, element = findLift( id )
			
			if element then
				if status == 1 then
					mysql:query_free("UPDATE lifts SET disabled = 0 WHERE id = " .. mysql:escape_string(dbid) )
				else
					mysql:query_free("UPDATE lifts SET disabled = 1 WHERE id = " .. mysql:escape_string(dbid) )
				end
				reloadOneLift(dbid)
				
			else
				outputChatBox( "Elevator not found.", thePlayer, 255, 194, 14 )
			end
		end
	end
end
addCommandHandler( "togglelift", toggleLift )

function liftOutputMe(text)
	if text then
		exports.global:sendLocalMeAction(client, tostring(text))
	end	
end
addEvent("lift:me", true)
addEventHandler("lift:me", getRootElement(), liftOutputMe)

local time = 0
local timeSet = 0
function now()
	-- MTA precision sucks.
	local ticksec = ( getTickCount( ) - timeSet ) / 1000
	return math.floor( time + ticksec )
end