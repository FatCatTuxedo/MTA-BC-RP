local mysql = exports.mysql

-- towing impound lot
--local towSphere = createColPolygon(2512.4189453125, -2622.16015625, 2512.4189453125, -2622.16015625, 2651.7905273438, -2621.8083496094, 2652.5529785156, -2522.259765625,  2512.416015625, -2522.3994140625)
--createColPolygon(-2097.544921875, -110.19140625, -2155.9931640625, -110.19140625, -2155.9873046875, -159.1455078125, -2158.908203125, -173.857421875, -2167.888671875, -188.4033203125, -2180.955078125, -197.376953125, -2196.6479492188, -200.7822265625, -2200.9301757813, -200.8916015625, -2200.8256835938, -280.0537109375, -2097.5439453125, -280.072265625, -2097.5458984375, -110.1904296875)
local towSphere = createColPolygon(2624.94921875, -2566.130859375, 2624.94921875, -2566.130859375, -- left front
 2724.6640625, -2565.966796875, -- right front
 2724.3291015625, -2705.5166015625, -- back right
 2690.85546875, -2706.314453125, -- backparking right front
2690.791015625, -2784.85546875, -- backparking right back
2654.1484375, -2785.4375,  -- backparking left back
2654.30859375, -2706.2001953125, -- backparking left front
2625.2802734375, -2705.2607421875 -- left back
)

--local towImpoundSphere = createColPolygon( 2629.0341796875, -2583.2663574219, 2629.0341796875, -2583.2663574219, 2628.8203125, -2592.2888183594, 2647.3820800781, -2591.9611816406, 2647.9201660156, -2582.9826660156)
--createColPolygon(-2097.544921875, -110.19140625, -2155.9931640625, -110.19140625, -2155.9873046875, -159.1455078125, -2158.908203125, -173.857421875, -2167.888671875, -188.4033203125, -2180.955078125, -197.376953125, -2196.6479492188, -200.7822265625, -2200.9301757813, -200.8916015625, -2200.8256835938, -280.0537109375, -2097.5439453125, -280.072265625, -2097.5400390625, -154.9990234375, -2110.3388671875, -154.6435546875, -2110.3427734375, -110.259765625)
-- pd db impound lot
local towImpoundSphere = createColCircle ( 1767.0703125, -2040.3466796875, 6 )

local towSphere2 = createColPolygon(1245.8515625, -1651.591796875, 1279.8330078125, -1644.9619140625, 1279.8349609375, -1659.2939453125, 1268.767578125, -1659.517578125, 1268.771484375, -1677.0888671875, 1213.4970703125, -1677.193359375, 1213.4970703125, -1638.1162109375, 1268.7724609375, -1638.115234375, 1268.7939453125, -1644.833984375)

-- IGS - no /park zone
local towSphere3 = createColPolygon(1932.6806640625, -1778.4501953125, 1904.0517578125, -1762.48828125, 1950.74609375, -1761.9482421875, 1951.0078125, -1795.783203125, 1904.0517578125, -1796.248046875 )

-- RS Haul no /park zone
local RSHaulSphere = createColPolygon(-78.111328125, -1100.345703125,-78.111328125, -1100.345703125, -91.4736328125, -1136.875, -54.2373046875, -1154.4375, -72.560157775879, -1195.5007324219, -44.3681640625, -1206.439453125, -30.9501953125, -1173.603515625, -22.3837890625, -1171.2099609375, -21.838672637939, -1150.0283203125, -24.0087890625, -1145.3431396484, -17.029296875, -1121.83984375)

--[[
local releasePositions = {
                        { 2508.416015625, -2609.46484375, 13.527928352356, 0, 0, 90 },
                        { 2508.416015625, -2614.46484375, 13.527928352356, 0, 0, 90 },
                        { 2508.416015625, -2619.46484375, 13.527928352356, 0, 0, 90 },
                        { 2508.416015625, -2624.46484375, 13.527928352356, 0, 0, 90 },
                        { 2508.416015625, -2629.46484375, 13.527928352356, 0, 0, 90 },
             }
             ]]


function cannotVehpos(thePlayer, theVehicle)
    return isElementWithinColShape(thePlayer, towSphere) and getElementData(thePlayer,"faction") ~= 4 or isElementWithinColShape(thePlayer, towSphere3) or isElementWithinColShape(thePlayer, RSHaulSphere)
end

-- generic function to check if a guy is in the col polygon and the right team
function CanTowTruckDriverVehPos(thePlayer, commandName)
    local ret = 0
    if (isElementWithinColShape(thePlayer, towSphere) or isElementWithinColShape(thePlayer,towSphere2)) then
        if (getElementData(thePlayer,"faction") == 4) then
            ret = 2
        else
            ret = 1
        end
    end
    return ret
end

--Auto Pay for PD
function CanTowTruckDriverGetPaid(thePlayer, commandName)
    if (isElementWithinColShape(thePlayer,towSphere2)) then
        if (getElementData(thePlayer,"faction") == 4) then
            return true
        end
    end
    return false
end

-- towstats
local function insertTowRecord(player, vehicle)
    local plate = 'NULL'
    if exports['vehicle-system']:hasVehiclePlates(vehicle) and getElementData(vehicle, "show_plate") ~= 0 then
        plate = '"' .. mysql:escape_string(getVehiclePlateText(vehicle)) .. '"'
    end
    mysql:query_free('INSERT INTO towstats (`character`, vehicle, vehicle_plate) VALUES ("' .. mysql:escape_string(getElementData(player, 'dbid')) .. '", "' .. mysql:escape_string(getElementData(vehicle, 'dbid')) .. '", ' .. plate .. ')')
end

addEventHandler('onResourceStart', resourceRoot,
    function()
        mysql:query_free('DELETE FROM towstats WHERE date < NOW() - INTERVAL 6 WEEK')
    end, false)

--

function getAccFromCharID( id )
	local row = nil
	local result = exports.mysql:query( "SELECT account FROM characters WHERE `id` = '"..id.."'" )
	if exports.mysql:num_rows( result ) > 0 then
		row = exports.mysql:fetch_assoc( result )
		exports.mysql:free_result( result )
		return row.account
	else
		return false
	end
end

function UnlockVehicle(element, matchingdimension) 
    if (getElementType(element) == "vehicle" and getVehicleOccupant(element) and getElementData(getVehicleOccupant(element),"faction") == 4 and getElementModel(element) == 525 and getVehicleTowedByVehicle(element)) then
        local temp = element
        while (getVehicleTowedByVehicle(temp)) do
            temp = getVehicleTowedByVehicle(temp)
            local owner = getElementData(temp, "owner")
            local faction = getElementData(temp, "faction")
            local dbid = getElementData(temp, "dbid")
            local impounded = getElementData(temp, "Impounded")
            local thePlayer = getVehicleOccupant(element)
            if (owner > 0) then
                if (faction > 3 or faction < 0) then
                    if (source == towSphere2) then
                        --PD make sure its not marked as impounded so it cannot be recovered and unlock/undp it
                        setVehicleLocked(temp, false)
                        exports.anticheat:changeProtectedElementDataEx(temp, "Impounded", 0)
                        exports.anticheat:changeProtectedElementDataEx(temp, "enginebroke", 0, false)
                        setVehicleDamageProof(temp, false)
                        setVehicleEngineState(temp, false)
                        outputChatBox("((Please remember to /park and /handbrake your vehicle in our car park.))", thePlayer, 255, 194, 14)
                    else
                        if (getElementData(temp, "faction") ~= 4) then
                            if (impounded == 0) then
								local freeLane, used, total = getRTFreeLane()
								if not freeLane or freeLane.veh ~= "0" then
									outputChatBox("(( No Free Lanes Contact Dev))", thePlayer, 255, 194, 14)
								else
								exports.anticheat:changeProtectedElementDataEx(temp, "Impounded", getRealTime().yearday)
								setVehicleLocked(temp, false)
								exports.anticheat:changeProtectedElementDataEx(temp, "enginebroke", 1, false)
								setVehicleEngineState(temp, false)
									
								local time = getRealTime()
								local hour = tostring(time.hour)
								local mins = tostring(time.minute)
									
								if ( time.hour < 10 ) then
									hour = "0" .. hour
								end
									
								if ( time.minute < 10 ) then
									mins = "0" .. mins
								end
								if ( isElementAttached( temp ) ) then -- If the specified element is attached to something
									detachElements ( temp )
								end
								local datestr = time.monthday .. "/" .. time.month .." " .. hour .. ":" .. mins
								local vehid = getElementData(temp, "dbid")
								local theTeam = exports.pool:getElement("team", 4)
								local factionRanks = getElementData(theTeam, "ranks")
								local factionRank = factionRanks[ getElementData(thePlayer, "factionrank") ] or ""
								exports.global:giveItem(temp, 72, "Towing Notice: Impounded by ".. factionRank .." '".. getPlayerName(thePlayer) .."' at "..datestr)
								exports.announcement:makePlayerNotification(getAccFromCharID(owner), "Your "..exports.global:getVehicleName(temp).." was impounded by LS City Maintenance", "Visit the T on the map to get it back")
								insertTowRecord(thePlayer, temp)
								local sql = "UPDATE vehicles SET x='" .. mysql:escape_string(freeLane.x) .. "', y='" .. mysql:escape_string(freeLane.y) .."', z='" .. mysql:escape_string(freeLane.z) 
								.. "',   	rotx='" .. mysql:escape_string(freeLane.rx) .. "', roty='" .. mysql:escape_string(freeLane.ry) .. "', rotz='" .. mysql:escape_string(freeLane.rz) 
								.. "',     	currx='" .. mysql:escape_string(freeLane.x) .. "', curry='" .. mysql:escape_string(freeLane.y) .. "', currz='" .. mysql:escape_string(freeLane.z) 
								.. "',     	currrx='" .. mysql:escape_string(freeLane.rx) .. "', currry='" .. mysql:escape_string(freeLane.ry) .. "', currrz='" .. mysql:escape_string(freeLane.rz) 
								.. "',     	interior='" .. mysql:escape_string(freeLane.int) .. "', currinterior='" .. mysql:escape_string(freeLane.int) .. "', dimension='" .. mysql:escape_string(freeLane.dim) 
								.. "',     	currdimension='" .. mysql:escape_string(freeLane.dim) .. "', Impounded="..(time.yearday).." WHERE id='" .. mysql:escape_string(vehid) 
								.. "'"
								mysql:query_free(sql)
								setVehicleRespawnPosition(temp, freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz)
								exports.anticheat:changeProtectedElementDataEx(temp, "respawnposition", {freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz}, false)
								exports.anticheat:changeProtectedElementDataEx(temp, "interior", freeLane.int)
								exports.anticheat:changeProtectedElementDataEx(temp, "dimension", freeLane.dim)
								--Remove everyone from vehicles
								local players = getVehicleOccupants ( temp  )
								for seat, player in pairs(players) do
									removePedFromVehicle(player)
								end

								exports.anticheat:changeProtectedElementDataEx(temp, 'i:left')
								exports.anticheat:changeProtectedElementDataEx(temp, 'i:right')
								triggerEvent("vehicle-manager:respawnRT", thePlayer, temp)

								--Make sure it's unlocked and /handbrake in the lot
								setVehicleLocked(temp, false)
								exports.anticheat:changeProtectedElementDataEx(temp, "handbrake", 1, true)
								setElementFrozen(temp, true)
								end
                            end
                        end
                    end
                else
                    outputChatBox("This faction's vehicle cannot be impounded.", thePlayer, 255, 194, 14)
                end
            end
        end
    end
end
addEventHandler("onColShapeHit", towImpoundSphere, UnlockVehicle)
addEventHandler("onColShapeHit", towSphere2, UnlockVehicle)

function ImpoundFlatbed(element, matchingdimension)
	if (getElementType(element) == "vehicle" and getVehicleOccupant(element) and getElementData(getVehicleOccupant(element),"faction") == 4 and (getElementModel(element) == 578 or getElementModel(element) == 443)) then
		local attachedElements = getAttachedElements(element)
		local thePlayer = getVehicleOccupant(element)
		if (attachedElements) then
			for key, temp in ipairs (attachedElements) do
				if (getElementType(temp) == "vehicle") then
					local impounded = getElementData(temp, "Impounded")
					if (getElementData(temp, "faction") ~= 4) then
						if (impounded == 0) then
							local freeLane, used, total = getRTFreeLane()
							local owner = getElementData(temp, "owner")
							local faction = getElementData(temp, "faction")
							local dbid = getElementData(temp, "dbid")
							if not freeLane or freeLane.veh ~= "0" then
								outputChatBox("(( No Free Lanes Contact Dev))", thePlayer, 255, 194, 14)
							else
								exports.anticheat:changeProtectedElementDataEx(temp, "Impounded", getRealTime().yearday)
								setVehicleLocked(temp, false)
								exports.anticheat:changeProtectedElementDataEx(temp, "enginebroke", 1, false)
								setVehicleEngineState(temp, false)
									
								local time = getRealTime()
								local hour = tostring(time.hour)
								local mins = tostring(time.minute)
									
								if ( time.hour < 10 ) then
									hour = "0" .. hour
								end
									
								if ( time.minute < 10 ) then
									mins = "0" .. mins
								end
								local datestr = time.monthday .. "/" .. time.month .." " .. hour .. ":" .. mins
								local vehid = getElementData(temp, "dbid")
								local theTeam = exports.pool:getElement("team", 4)
								local factionRanks = getElementData(theTeam, "ranks")
								local factionRank = factionRanks[ getElementData(thePlayer, "factionrank") ] or ""
								exports.global:giveItem(temp, 72, "Towing Notice: Impounded by ".. factionRank .." '".. getPlayerName(thePlayer) .."' at "..datestr)
								exports.announcement:makePlayerNotification(getAccFromCharID(owner), "Your "..exports.global:getVehicleName(temp).." was impounded by LS City Maintenance", "Visit the T on the map to get it back")
								insertTowRecord(thePlayer, temp)
								local sql = "UPDATE vehicles SET x='" .. mysql:escape_string(freeLane.x) .. "', y='" .. mysql:escape_string(freeLane.y) .."', z='" .. mysql:escape_string(freeLane.z) 
								.. "',   	rotx='" .. mysql:escape_string(freeLane.rx) .. "', roty='" .. mysql:escape_string(freeLane.ry) .. "', rotz='" .. mysql:escape_string(freeLane.rz) 
								.. "',     	currx='" .. mysql:escape_string(freeLane.x) .. "', curry='" .. mysql:escape_string(freeLane.y) .. "', currz='" .. mysql:escape_string(freeLane.z) 
								.. "',     	currrx='" .. mysql:escape_string(freeLane.rx) .. "', currry='" .. mysql:escape_string(freeLane.ry) .. "', currrz='" .. mysql:escape_string(freeLane.rz) 
								.. "',     	interior='" .. mysql:escape_string(freeLane.int) .. "', currinterior='" .. mysql:escape_string(freeLane.int) .. "', dimension='" .. mysql:escape_string(freeLane.dim) 
								.. "',     	currdimension='" .. mysql:escape_string(freeLane.dim) .. "', Impounded="..(time.yearday).." WHERE id='" .. mysql:escape_string(vehid) 
								.. "'"
								mysql:query_free(sql)
								setVehicleRespawnPosition(temp, freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz)
								exports.anticheat:changeProtectedElementDataEx(temp, "respawnposition", {freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz}, false)
								exports.anticheat:changeProtectedElementDataEx(temp, "interior", freeLane.int)
								exports.anticheat:changeProtectedElementDataEx(temp, "dimension", freeLane.dim)
								--Remove everyone from vehicles
								local players = getVehicleOccupants ( temp  )
								for seat, player in pairs(players) do
									removePedFromVehicle(player)
								end

								exports.anticheat:changeProtectedElementDataEx(temp, 'i:left')
								exports.anticheat:changeProtectedElementDataEx(temp, 'i:right')
								triggerEvent("vehicle-manager:respawnRT", thePlayer, temp)

								--Make sure it's unlocked and /handbrake in the lot
								setVehicleLocked(temp, false)
								exports.anticheat:changeProtectedElementDataEx(temp, "handbrake", 1, true)
								setElementFrozen(temp, true)

								exports.global:sendLocalDoAction(thePlayer, "Vehicle was impounded")
							end
						end
					end
				end
			end
		else
			outputChatBox("(( no vehicles attached ))", thePlayer, 255, 194, 14)
		end
	end
end
addEventHandler("onColShapeHit", towImpoundSphere, ImpoundFlatbed)

function payRelease(vehID)
    if exports.global:takeMoney(source, 250) then
        exports.global:giveMoney(getTeamFromName("Los Santos City Maintenance"), 250)
        exports.mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. exports.mysql:escape_string(getElementData(source, "dbid")) .. ", " .. -getElementData(getTeamFromName("Los Santos City Maintenance"), "id") .. ", " .. 250 .. ", 'Vehicle Release', 5)" )
        setElementFrozen(vehID, false)
        local x, y, z, int, dim, rotation = getReleasePosition()
        setElementPosition(vehID, x, y, z)
        setVehicleRotation(vehID, 0, 0, rotation)
        setElementInterior(vehID, int)
        setElementDimension(vehID, dim)
        setVehicleLocked(vehID, true)
        exports.anticheat:changeProtectedElementDataEx(vehID, "enginebroke", 0, true)
        setVehicleDamageProof(vehID, false)
        setVehicleEngineState(vehID, false)
        exports.anticheat:changeProtectedElementDataEx(vehID, "handbrake", 0, true)
        exports.anticheat:changeProtectedElementDataEx(vehID, "Impounded", 0)

        outputChatBox("Your vehicle has been released, it's out front. (( Please remember to /park your vehicle so it does not respawn back here. ))", source, 255, 194, 14)
    else
        outputChatBox("Insufficient funds.", source, 255, 0, 0)
    end
end
addEvent("releaseCar", true)
addEventHandler("releaseCar", getRootElement(), payRelease)

function unimpoundVeh(thePlayer, commandName, vehid)
    if thePlayer then
        if not vehid then
            outputChatBox("SYNTAX: /" .. commandName .. " [Vehicle ID]", thePlayer, 255, 194, 14)
        else
            local vehID = exports.pool:getElement("vehicle", tonumber(vehid))
            if not vehID then
                outputChatBox("Invalid Vehicle.", thePlayer, 255, 0, 0)
            else
                if getElementData(vehID, "Impounded") and getElementData(vehID, "Impounded") ~= 0 then
                    if commandName == "unimpound" then
                        if (getElementData(thePlayer,"faction") == 4) then
                            if(getElementData(thePlayer, "factionleader") == 1) then
                                setElementFrozen(vehID, false)
                                local x, y, z, int, dim, rotation = getReleasePosition()
                                setElementPosition(vehID, x, y, z)
                                setVehicleRotation(vehID, 0, 0, rotation)
                                setElementInterior(vehID, int)
                                setElementDimension(vehID, dim)
                                setVehicleLocked(vehID, true)
                                exports.anticheat:changeProtectedElementDataEx(vehID, "enginebroke", 0, true)
                                setVehicleDamageProof(vehID, false)
                                setVehicleEngineState(vehID, false)
                                exports.anticheat:changeProtectedElementDataEx(vehID, "handbrake", 0, true)
                                exports.anticheat:changeProtectedElementDataEx(vehID, "Impounded", 0)
                                updateVehPos(vehID)
                                triggerEvent("parkVehicle", thePlayer, vehID)

                                outputChatBox("You have unimpounded vehicle #" .. vehid .. ".", thePlayer, 0, 255, 0)
                                
                                local theTeam = exports.pool:getElement("team", 4)
                                local teamPlayers = getPlayersInTeam(theTeam)
                                local username = getPlayerName(thePlayer):gsub("_", " ")
                                for key, value in ipairs(teamPlayers) do
                                    outputChatBox(username .. " has unimpounded vehicle #" .. vehid .. ".", value, 0, 255, 0)
                                end
                                
                                exports.logs:logMessage("[SFTR-UNIMPOUND] " .. username .. " has unimpounded vehicle #" .. vehid .. ".", 9)
                            else
                                outputChatBox("You must be the faction leader.", thePlayer, 255, 0, 0)
                            end
                        end
                    elseif commandName == "aunimpound" then
                        if exports.integration:isPlayerTrialAdmin(thePlayer)  then
                            local impounder = getElementData(vehID, "impounder")
                            if impounder == 1 or impounder == 59 then
                                local state, reason = unimpVeh(getElementData(vehID, "dbid"))
                                outputChatBox(reason, thePlayer)
                            else
                                setElementFrozen(vehID, false)
                                local x, y, z, int, dim, rotation = getReleasePosition(getElementData(vehID, "impounder"))
                                setElementPosition(vehID, x, y, z)
                                setVehicleRotation(vehID, 0, 0, rotation)
                                setElementInterior(vehID, int)
                                setElementDimension(vehID, dim)
                                setVehicleLocked(vehID, true)
                                exports.anticheat:changeProtectedElementDataEx(vehID, "enginebroke", 0, true)
                                setVehicleDamageProof(vehID, false)
                                setVehicleEngineState(vehID, false)
                                exports.anticheat:changeProtectedElementDataEx(vehID, "handbrake", 0, true)
                                exports.anticheat:changeProtectedElementDataEx(vehID, "Impounded", 0)
                                updateVehPos(vehID)
                                triggerEvent("parkVehicle", thePlayer, vehID)
                                
                                local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
                                local playerName = getPlayerName(thePlayer):gsub("_", " ")
                                outputChatBox("You have unimpounded vehicle #" .. vehid .. ".", thePlayer, 0, 255, 0)
                                exports.global:sendMessageToAdmins("AdmCmd: " .. adminTitle .. " " .. playerName .. " unimpounded vehicle #" .. vehid .. ".")
                                
                                exports.logs:logMessage("[ADMIN-UNIMPOUND] " .. playerName .. " has unimpounded vehicle #" .. vehid .. ".", 9)
                            end
                        end
                    end
                else
                    outputChatBox("Vehicle #" .. vehid .. " is not currently impounded.", thePlayer, 255, 0, 0)
                end
            end
        end
    end
end
addCommandHandler("unimpound", unimpoundVeh)
addCommandHandler("aunimpound", unimpoundVeh)

function disableEntryToTowedVehicles(thePlayer, seat, jacked, door) 
    if (getVehicleTowingVehicle(source)) then
        if seat == 0 then
            outputChatBox("You cannot enter a vehicle being towed!", thePlayer, 255, 0, 0)
            cancelEvent()
        end
    end
end
addEventHandler("onVehicleStartEnter", getRootElement(), disableEntryToTowedVehicles)

function releaseHandbrake(theTruck) -- Release handbrake on the vehicle being attached or being towed / Maxime
    if getElementData(source, "handbrake") ~= 0 then
        exports.anticheat:changeProtectedElementDataEx(source, "handbrake", 0, true)
        setElementFrozen(source, false) 
        triggerEvent("vehicle:handbrake:lifted", source)
    end
end
addEventHandler("onTrailerAttach", getRootElement(), releaseHandbrake)

function triggerShowImpound()
    local vehElements = {}
    local count = 1
    for key, value in pairs(getElementsByType("vehicle")) do
        local dbid = getElementData(value, "dbid")
        local impounded = getElementData(value, "Impounded") or 0
        local impounder = getElementData(value, "impounder") or 4
        local owner = getElementData(value, "owner")
        local charId = getElementData(source, "dbid")
        if dbid > 0 and impounded ~= 0 and impounder == 4 and owner == charId then
            vehElements[count] = value
            count = count + 1
        end
    end
    triggerClientEvent( source, "ShowImpound", source, vehElements)
end
addEvent("onTowMisterTalk", true)
addEventHandler("onTowMisterTalk", getRootElement(), triggerShowImpound)

function updateVehPos(veh)
    local x, y, z = getElementPosition(veh)
    local rx, ry, rz = getVehicleRotation(veh)
        
    local interior = getElementInterior(veh)
    local dimension = getElementDimension(veh)
    local dbid = getElementData(veh, "dbid")
    mysql:query_free("UPDATE vehicles SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .."', z='" .. mysql:escape_string(z) .. "', rotx='" .. mysql:escape_string(rx) .. "', roty='" .. mysql:escape_string(ry) .. "', rotz='" .. mysql:escape_string(rz) .. "', currx='" .. mysql:escape_string(x) .. "', curry='" .. mysql:escape_string(y) .. "', currz='" .. mysql:escape_string(z) .. "', currrx='" .. mysql:escape_string(rx) .. "', currry='" .. mysql:escape_string(ry) .. "', currrz='" .. mysql:escape_string(rz) .. "', interior='" .. mysql:escape_string(interior) .. "', currinterior='" .. mysql:escape_string(interior) .. "', dimension='" .. mysql:escape_string(dimension) .. "', currdimension='" .. mysql:escape_string(dimension) .. "' WHERE id='" .. mysql:escape_string(dbid) .. "'")
    setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
    exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
end

function updateTowingVehicle(theTruck)
    local thePlayer = getVehicleOccupant(theTruck)
    if (thePlayer) then
        if (getElementData(thePlayer,"faction") == 4) or (getElementData(thePlayer,"faction") == 42) then
            local owner = getElementData(source, "owner")
            local faction = getElementData(source, "faction")
            local carName = exports.global:getVehicleName(source)
            
            if owner < 0 and faction == -1 then
                outputChatBox("(( This " .. carName .. " is a civilian vehicle. ))", thePlayer, 255, 195, 14)
            elseif (faction==-1) and (owner>0) then
                local ownerName = exports["cache"]:getCharacterName(owner)
                outputChatBox("(( This " .. carName .. " belongs to " .. ownerName .. ". ))", thePlayer, 255, 195, 14)
            else
                local row = mysql:query_fetch_assoc("SELECT name FROM factions WHERE id='" .. mysql:escape_string(faction) .. "' LIMIT 1")
            
                if not (row == false) then
                    local ownerName = row.name
                    outputChatBox("(( This " .. carName .. " belongs to the " .. ownerName .. " faction. ))", thePlayer, 255, 195, 14)
                end
            end
            
            if (getElementData(source, "Impounded") > 0) then
                local output = getRealTime().yearday-getElementData(source, "Impounded")
                outputChatBox("(( This " .. carName .. " has been impounded for: " .. output .. (output == 1 and " Day." or " Days.") .. " ))", thePlayer, 255, 195, 14)
            end
            
            -- fix for handbraked vehicles
            local handbrake = getElementData(source, "handbrake")
            if (handbrake == 1) then
                exports.anticheat:changeProtectedElementDataEx(source, "handbrake",0,true)
                setElementFrozen(source, false)
            end
        end
        if thePlayer then
            exports.logs:logMessage("[TOW] " .. getPlayerName( thePlayer ) .. " started towing vehicle #" .. getElementData(source, "dbid") .. ", owned by " .. tostring(exports['cache']:getCharacterName(getElementData(source,"owner"))) .. ", from " .. table.concat({exports.global:getElementZoneName(source)}, ", ") .. " (pos = " .. table.concat({getElementPosition(source)}, ", ") .. ", rot = ".. table.concat({getVehicleRotation(source)}, ", ") .. ", health = " .. getElementHealth(source) .. ")", 14)
        end
    end
end

addEventHandler("onTrailerAttach", getRootElement(), updateTowingVehicle)

function updateCivilianVehicles(theTruck)
    if (isElementWithinColShape(theTruck, towSphere)) then
        local owner = getElementData(source, "owner")
        local faction = getElementData(source, "faction")
        local dbid = getElementData(source, "dbid")

        if (dbid >= 0 and faction == -1 and owner < 0) then
            exports.global:giveMoney(exports.pool:getElement("team", 4), 200)
            outputChatBox("The state has unimpounded the vehicle you were towing.", getVehicleOccupant(theTruck), 255, 194, 14)
            respawnVehicle(source)
        end
    end
    
    if getVehicleOccupant(theTruck) then
        exports.logs:logMessage("[TOW STOP] " .. getPlayerName( getVehicleOccupant(theTruck) ) .. " stopped towing vehicle #" .. getElementData(source, "dbid") .. ", owned by " .. tostring(exports['cache']:getCharacterName(getElementData(source,"owner"))) .. ", in " .. table.concat({exports.global:getElementZoneName(source)}, ", ") .. " (pos = " .. table.concat({getElementPosition(source)}, ", ") .. ", rot = ".. table.concat({getVehicleRotation(source)}, ", ") .. ", health = " .. getElementHealth(source) .. ")", 14)
    end
end
addEventHandler("onTrailerDetach", getRootElement(), updateCivilianVehicles)
