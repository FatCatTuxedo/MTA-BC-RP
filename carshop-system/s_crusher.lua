-- reverse carshop
local mysql = exports.mysql
local cOutsideCol = createColTube (0.0107421875, 1524.4716796875, 10, 30, 7)
setElementID(cOutsideCol, 'crusher')
createBlip(-39.0615234375, 1520.59765625, 12.756023406982, 11, 2, 255, 0, 0, 255, 0, 300) -- Crusher
local cOutsideColBoat =  createColCuboid (162.3037109375, 617.9375, -2, 29, 36, 20 )
setElementID(cOutsideColBoat, 'boat_crusher')
createBlip(179.6533203125, 610.2548828125, 0.15252202749252, 11, 2, 255, 0, 0, 255, 0, 300) -- Boat Crusher



function resetPrice(theVehicle, matching)
	if isElement(theVehicle) and getElementType(theVehicle) == "vehicle" then
		if getElementData(theVehicle, "crushing") then
			exports.anticheat:changeProtectedElementDataEx(theVehicle, "crushing")
			
			local thePlayer = getVehicleOccupant(theVehicle)
			if thePlayer then
				outputChatBox("Come back when you've thought about it!", thePlayer, 255, 194, 14)
				triggerClientEvent(thePlayer, 'crusher:hide', thePlayer)
			end
		end
	end
end
addEventHandler( "onColShapeLeave", cOutsideCol, resetPrice)
addEventHandler( "onColShapeLeave", cOutsideColBoat, resetPrice)
--

function getVehiclePrice(theVehicle)
	local model = getElementModel(theVehicle)
	if model then
		if model == 481 or model == 510 or model == 509 then
			return 50
		else
			local handlingTable = getModelHandling(model)
			local mass = handlingTable["mass"]
			if mass then
				local temp = math.floor(mass * 3)
				local price = getElementData(theVehicle, "carshop:cost")
				if price then
					price = tonumber(price)
					if temp >= price then
						return price / 2
					else
						return temp
					end
				else
					return temp
				end
				
				
			else
				return 0
			end
		end
	end
end

function showMoreInformation(thePlayer, matching, theVehicle)
	if isElement(thePlayer) and matching and getElementType(thePlayer) == "player" then
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if theVehicle and getVehicleOccupant(theVehicle) == thePlayer then -- player is driver
			if getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid") then
				local price = getVehiclePrice(theVehicle)
				if getElementData(theVehicle, "requires.vehpos") then
					outputChatBox("(( Please park your vehicle and come back. ))", thePlayer, 255, 0, 0)
				elseif price == 0 then
					outputChatBox("This " .. exports.global:getVehicleName(theVehicle) .. " ain't worth anything.", thePlayer, 255, 0, 0 )
					outputChatBox("(( Contact an admin to sell your special vehicle. ))", thePlayer, 255, 194, 14)
				else
					setElementData(theVehicle, "crushing", price, false)
					triggerClientEvent(thePlayer, 'crusher:show', theVehicle, price)
				end
			else
				outputChatBox("Got the Registration for that? Sorry, Bro', can't touch it then.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addEventHandler( "onColShapeHit", cOutsideCol, showMoreInformation)
addEventHandler( "onColShapeHit", cOutsideColBoat, showMoreInformation)

function crushCar()
	local thePlayer = client
	local theVehicle = source
	if theVehicle and thePlayer then
		if getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid") then
			local price = getElementData(theVehicle, "crushing")
			if price and price > 0 then
				local dbid = getElementData(theVehicle, "dbid")			
				local result = mysql:query_free("UPDATE `vehicles` SET `owner`='-1', `faction`='5', `enginebroke`='1', `locked`='0', `engine`='0', `lights`='0', `wheelStates`='[ [ 2, 2, 2, 2 ] ]', `panelStates`='[ [ 3, 3, 3, 3, 3, 3, 3 ] ]', `doorStates`='[ [ 4, 4, 4, 4, 4, 4 ] ]' WHERE id = '" .. mysql:escape_string(dbid) .. "'")
				if result and dbid > 0 then
					setElementData(theVehicle, "crushing", 0, false)
					triggerClientEvent(thePlayer, 'crusher:hide', thePlayer)
					exports['vehicle-manager']:addVehicleLogs(dbid, 'crushed', thePlayer)

					exports.anticheat:changeProtectedElementDataEx(theVehicle, "owner", -1, true)
					exports.anticheat:changeProtectedElementDataEx(theVehicle, "faction", 5, true)
					exports.global:giveMoney(thePlayer, price)
					call( getResourceFromName( "item-system" ), "deleteAll", 3, dbid )
					call( getResourceFromName( "item-system" ), "clearItems", theVehicle )
					exports['global']:takeItem(thePlayer, 3, tonumber(dbid))
					
					for k, theObject in ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
						local itemID = getElementData(theObject, "itemID")
						local itemValue = getElementData(theObject, "itemValue")
						if itemID == 3 and itemValue == dbid then
							destroyElement(theObject)
							mysql:query_free("DELETE FROM worlditems WHERE itemid='3' AND itemvalue='" .. mysql:escape_string(dbid) .. "'")
						end
					end
					
					outputChatBox("You crushed your " .. exports.global:getVehicleName(theVehicle) .. " for $" .. exports.global:formatMoney(price) .. ".", thePlayer, 0, 255, 0)	
					exports.global:sendMessageToAdmins("Removing vehicle #" .. dbid .. " (Crushed by " .. getPlayerName(thePlayer):gsub("_", " ") .. ").")	
					exports.logs:dbLog(thePlayer, 6, (theVehicle), "CRUSHERDELETED ".. price)
					removePedFromVehicle(thePlayer)
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "realinvehicle", 0)	
					--mysql:query_free("DELETE FROM vehicles WHERE id='" .. mysql:escape_string(dbid) .. "'")
					mysql:query_free("UPDATE `vehicles` SET `deleted`='1' WHERE `id`='" .. mysql:escape_string(dbid) .. "'")
					destroyElement(theVehicle)
				else
					outputChatBox("Error 9004 - Report on Forums.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addEvent('crusher:delete', true)
addEventHandler('crusher:delete', root, crushCar)
