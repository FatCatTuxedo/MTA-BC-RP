--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Server side script: Special christmas season features
--Last updated 04.12.2014 by Exciter
--Copyright 2008, The Roleplay Project (www.roleplayproject.com)

--SETTINGS:
local colaTruckID = 11782
local colaTruckTrailerID = 11783
local santaCharID = 19379
local debugXmas = false

local colaTruck = false
local colaTruckTrailer = false
local santa = true
local santaTimer = false
local mysql = exports.mysql
local global = exports.global

function xmasDebug(thePlayer, commandName)
	if exports.integration:isPlayerAdmin(thePlayer) then
		debugXmas = not debugXmas
		outputChatBox("debugXmas set to "..tostring(debugXmas))
	end
end
addCommandHandler("debugxmas", xmasDebug)

function initiateSanta()
	local realtime = getRealTime()
	if(swag) then --and realtime.monthday > 21
		local minWait, maxWait = 50, 80 --minutes
		local time = math.random(60000*minWait,60000*maxWait) --between 50 and 120 minutes
		santaTimer = setTimer(santaArrives, time, 1)
		if not colaTruck then
			for k,v in ipairs(getElementsByType("Vehicle")) do
				if(getElementData(v, "dbid") == colaTruckID) then
					colaTruck = v
				elseif(getElementData(v, "dbid") == colaTruckTrailerID) then
					colaTruckTrailer = v
				end
				if colaTruck and colaTruckTrailer then
					break
				end
			end
		end
		if not colaTruck then
			if debugXmas then
				outputDebugString("xmas: Cola truck not found! Cancelling christmas.")
			end
			killTimer(santaTimer)
			return
		end
		setVehicleEngineState(colaTruck, false)
		if not santa or isPedDead(santa) then
			if santa then
				destroyElement(santa)
				santa = false
			end
			
			santa = createPed(245, 0, 0, 0)
			
			--exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", "santa")
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.name", "Santa Claus")
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.gender", 0)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", false)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.behav", 0)

			--owl specifics
			exports.anticheat:changeProtectedElementDataEx(santa, "nametag", false)
			exports.anticheat:changeProtectedElementDataEx(santa, "name", "Santa Claus")
			
			respawnVehicle(colaTruck)
			if colaTruckTrailer then
				respawnVehicle(colaTruckTrailer)
				fixVehicle(colaTruckTrailer)
				setVehicleOverrideLights(colaTruckTrailer, 1) --off
				setElementFrozen(colaTruckTrailer,true)
			end
			setVehicleLocked(colaTruck, false)
			warpPedIntoVehicle(santa, colaTruck, 0)
			setVehicleLocked(colaTruck, true)
			setVehicleOverrideLights(colaTruck, 1) --off
			fixVehicle(colaTruck)
			setElementFrozen(colaTruck,true)
			setVehicleEngineState(colaTruck, false)
		end
		if debugXmas then
			outputDebugString("xmas: Santa will go to work in "..tostring(math.floor(time/60000)).." minutes.")
		end
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), initiateSanta)

function santaArrives()
	if debugXmas then
		outputDebugString("xmas: Santa is coming to work.")
	end
	if santaTimer then
		killTimer(santaTimer)
		santaTimer = nil
	end
	respawnVehicle(colaTruck)
	if colaTruckTrailer then
		respawnVehicle(colaTruckTrailer)
		fixVehicle(colaTruckTrailer)
		setVehicleOverrideLights(colaTruckTrailer, 2) --on
		setElementFrozen(colaTruckTrailer,true)
	end
	fixVehicle(colaTruck)
	setElementFrozen(colaTruck,true)
	setVehicleOverrideLights(colaTruck, 2) --on
	santaTimer = setTimer(santaDeparts, 120000, 1) --2 minutes
	exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", true)
	exports.anticheat:changeProtectedElementDataEx(santa, "nametag", true)
	triggerClientEvent("xmas:santaSound", getRootElement(), "arrive", santa)
	setTimer(function()
		setVehicleLocked(colaTruck, true)
		if isPedInVehicle(santa) then
			setVehicleLocked(colaTruck, false)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", "santa")
			removePedFromVehicle(santa)
			local x,y,z = getElementPosition(colaTruck)
			setElementPosition(santa, x-0.5,y-2,z)
			setElementRotation(santa, 0, 0, 180)
			setVehicleLocked(colaTruck, true)
			setTimer(setElementFrozen,3000,1,santa,true)
		end
		exports.global:applyAnimation(santa, "DANCING", "DAN_Down_A", 8000, false, true, true)
	end, 5000, 1) --5 seconds
end

function santaDeparts()
	if santaTimer then
		killTimer(santaTimer)
		santaTimer = nil
	end
	setElementFrozen(santa, false)
	triggerClientEvent("xmas:santaSound", getRootElement(), "depart", santa)
	santaTimer = setTimer(
	function()
		if not isPedInVehicle(santa) then
			setVehicleLocked(colaTruck, false)
		end
	end, 29000, 1) --29 seconds
	setTimer(function()
		setVehicleLocked(colaTruck, true)
		exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", false)
		exports.anticheat:changeProtectedElementDataEx(santa, "nametag", false)
		if not isPedInVehicle(santa) then
			if colaTruckTrailer then
				fixVehicle(colaTruckTrailer)
				setVehicleOverrideLights(colaTruckTrailer, 1) --off
			end			
			setVehicleLocked(colaTruck, false)
			warpPedIntoVehicle(santa, colaTruck, 0)
			setVehicleLocked(colaTruck, true)
			setVehicleOverrideLights(colaTruck, 1) --off
			fixVehicle(colaTruck)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", false)
		end
		setVehicleEngineState(colaTruck, false)
	end, 35000, 1) --35 seconds
	initiateSanta()
end

function doNotEnterColaTruck(thePlayer, seat, jacked, door)
	if colaTruck then
		if source == colaTruck then
			if not exports.integration:isPlayerAdmin(thePlayer) then
				outputChatBox("That truck is for santa only!",thePlayer,255,0,0)
				cancelEvent()
				if isPedInVehicle(thePlayer) then
					removePedFromVehicle(thePlayer)
				end
			else
				outputChatBox("Please don't bother santa.",thePlayer,255,0,0)
			end
		end
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), doNotEnterColaTruck)

function checkPrizeCar(thePlayer, seat, jacked)
	if(seat == 0) then
		if(tonumber(getElementData(source,"owner")) == santaCharID and getElementData(source,"faction") == -1) then --if it's santa's car
			local dbid = tonumber(getElementData(source,"dbid"))
			local hasItem, itemSlot, itemValue = exports.global:hasItem(thePlayer, 3, dbid) --has player key to the car
			if hasItem then
				if(getElementData(thePlayer,"dbid") ~= santaCharID) then
					local query = mysql:query_free("UPDATE vehicles SET owner = '" .. mysql:escape_string(getElementData(thePlayer, "dbid")) .. "' WHERE id='" .. mysql:escape_string(dbid) .. "'")
					if query then
						exports.anticheat:changeProtectedElementDataEx(source, "owner", getElementData(thePlayer, "dbid"))
						local adminID = getElementData(thePlayer, "account:id")	
						local addLog = mysql:query_free("INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"..tostring(dbid).."', 'Won vehicle from Santas Christmas Lottery.', '"..adminID.."')") or false
						if not addLog then
							outputDebugString("xmas/s_xmas: Failed to add vehicle logs.")
						end
						exports.global:sendMessageToAdmins(tostring(getPlayerName(thePlayer)).." won a "..tostring(getVehicleName(source)).." in Santa's Christmas Lottery!")

						--exports.logs:logMessage( "[VEHICLE] xmas script changed the lock for Vehicle #" .. dbid .. " (" .. getVehicleName( source ) .. ")", 16) 
						exports['item-system']:deleteAll(3, dbid)
						exports['item-system']:giveItem(thePlayer, 3, dbid)
						
						outputChatBox("Congratulations! You won this "..tostring(getVehicleName(source)).." in Santa's Christmas Lottery!",thePlayer,0,255,0)
						outputChatBox("You are now the owner of this wonderful car.",thePlayer,0,255,0)
						outputChatBox("Remember to /park it!",thePlayer,0,255,0)
					end
				end
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), checkPrizeCar)

function forceSanta(thePlayer, commandName)
	if(exports.integration:isPlayerAdmin(thePlayer)) then
		if santa then
			outputChatBox("Forcing Santa to go to work...",thePlayer)
			santaArrives()
		else
			outputChatBox("Sorry. Santa is at the north pole!",thePlayer,255,0,0)
		end
	end
end
addCommandHandler("forcesanta", forceSanta)

function getSantaWait(thePlayer, commandName)
	if(exports.integration:isPlayerSciper(thePlayer) or exports.integration:isPlayerAdmin(thePlayer)) then
		if santa then
			local timeLeft = getTimerDetails(santaTimer)	
			outputChatBox(tostring(math.floor(timeLeft/60000)).." minutes left for Santa.",thePlayer)
		else
			outputChatBox("Sorry. Santa is at the north pole!",thePlayer,255,0,0)
		end
	end
end
addCommandHandler("howlongsanta", getSantaWait)

function fixSanta(thePlayer, commandName)
	if(exports.integration:isPlayerAdmin(thePlayer) or exports.integration:isPlayerAdmin(thePlayer)) then
		if santa then
			if debugXmas then
				outputDebugString("xmas: Resetting Santa.")
			end
			if santaTimer then
				killTimer(santaTimer)
				santaTimer = nil
			end
			respawnVehicle(colaTruck)
			if colaTruckTrailer then
				respawnVehicle(colaTruckTrailer)
				setElementFrozen(colaTruckTrailer,true)
			end
			setElementFrozen(colaTruck,true)
			
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", false)
			exports.anticheat:changeProtectedElementDataEx(santa, "nametag", false)
			if not isPedInVehicle(santa) then
				if colaTruckTrailer then
					fixVehicle(colaTruckTrailer)
					setVehicleOverrideLights(colaTruckTrailer, 1) --off
				end			
				setVehicleLocked(colaTruck, false)
				warpPedIntoVehicle(santa, colaTruck, 0)
				setVehicleLocked(colaTruck, true)
				setVehicleOverrideLights(colaTruck, 1) --off
				fixVehicle(colaTruck)
				exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", false)
			end
			setVehicleEngineState(colaTruck, false)
			outputChatBox("Santa was reset.",thePlayer)
		else
			outputChatBox("Sorry. Santa is at the north pole!",thePlayer,255,0,0)
		end
	end
end
addCommandHandler("fixsanta", fixSanta)