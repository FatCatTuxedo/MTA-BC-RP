----MAXIME
function addPurchaseHistory(thePlayer, perkName, cost)
	return exports.donators:addPurchaseHistory(thePlayer, perkName, -cost)
end

function fetchStations()
	local preparedQ = "SELECT `id`, `station_name`, `source`, (SELECT `username` FROM `accounts` WHERE `accounts`.`id`=`owner`) AS `owner`, `register_date`, `expire_date`, `enabled`, `order` FROM `radio_stations` WHERE (`expire_date` IS NULL) OR (`expire_date` > NOW()) ORDER BY `order` "
	local mQuery = mysql:query(preparedQ)
	local defaultStations = {}
	local donorStations = {}
	while true do
		local row = mysql:fetch_assoc(mQuery)
		if not row then break end
		--outputChatBox(type(row["owner"]))
		if type(row["owner"]) == "string" then
			table.insert(donorStations, row )
		else
			table.insert(defaultStations, row )
		end
	end
	mysql:free_result(mQuery)
	return defaultStations, donorStations
end

function openRadioManager()
	if source then
		client = source
	end
	local defaultStations, donorStations = fetchStations()
	triggerClientEvent(client, "openRadioManager", client, defaultStations, donorStations)
end
addEvent("openRadioManager", true)
addEventHandler("openRadioManager", root, openRadioManager)

function createNewStation(name, ip, donorStation)
	if name and ip then
		if donorStation then
			if not exports.donators:takeGC(client, 10) then
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "You lack of GameCoins to purchase this perk. Please visit F10 menu -> Premium Features to get more GCs.")
				return false
			end
			addPurchaseHistory(client, "Purchased new radio station (Name: '"..name.."', URL: '"..ip.."')", 10)
			local smallestID = SmallestID()
			mysql:query_free("INSERT INTO `radio_stations` SET `id`='"..smallestID.."', `station_name`='"..exports.global:toSQL(name).."', `source`='"..exports.global:toSQL(ip).."', `order`='"..smallestID.."', `owner`='"..getElementData(client, "account:id").."', `expire_date`=(NOW() + interval 30 day) ")
			exports.hud:sendBottomNotification(client, "Radio Station Manager", "New radio station has been successfully created! (Name: "..name..", URL: "..ip..")")
			setElementData(client, "gui:ViewingRadioManager", true, true)
			forceUpdateClientsGUI()
		else
			local maxStations = mysql:query_fetch_assoc("SELECT COUNT(*) AS `max` FROM `radio_stations` WHERE `owner`='0' ")
			if tonumber(maxStations["max"]) >= 30 then
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "Server's max default stations has reach limit of 30. Delete some before adding more.")
				return false
			end
			local smallestID = SmallestID()
			mysql:query_free("INSERT INTO `radio_stations` SET `id`='"..smallestID.."', `station_name`='"..exports.global:toSQL(name).."', `source`='"..exports.global:toSQL(ip).."', `order`='"..smallestID.."' ")
			exports.hud:sendBottomNotification(client, "Radio Station Manager", "New radio station has been successfully created! (Name: "..name..", URL: "..ip..")")
			forceUpdateClientsGUI()
		end
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not create new radio station.")
	end
end
addEvent("createNewStation", true)
addEventHandler("createNewStation", root, createNewStation)

function editStation(id, name, ip)
	if id and name and ip and mysql:query_free("UPDATE `radio_stations` SET `station_name`='"..exports.global:toSQL(name).."', `source`='"..exports.global:toSQL(ip).."' WHERE `id`='"..id.."' ") then
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Updated radio station #"..id.." successfully!")
		forceUpdateClientsGUI()
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not update radio station #"..id)
	end
end
addEvent("editStation", true)
addEventHandler("editStation", root, editStation)

function deleteStation(id)
	if id and mysql:query_free("DELETE FROM `radio_stations` WHERE `id`='"..id.."' ") then
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Deleted radio station #"..id..".")
		forceUpdateClientsGUI()
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not delete radio station #"..id..".")
	end
end
addEvent("deleteStation", true)
addEventHandler("deleteStation", root, deleteStation)

function togStation(id, state)
	if id and state and mysql:query_free("UPDATE `radio_stations` SET `enabled`='"..(state == "Activated" and "1" or "0").."' WHERE `id`='"..id.."' ") then
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Radio station #"..id.." has been "..state.."!")
		forceUpdateClientsGUI()
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not update radio station #"..id)
	end
end
addEvent("togStation", true)
addEventHandler("togStation", root, togStation)

function moveStationPosition(id, name, order, movingUp, donorStation)
	if id and tonumber(id) and order and tonumber(order)  then
		id = tonumber(id)
		order = tonumber(order)
		if donorStation then
			if not exports.donators:takeGC(client, 1) then
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "You lack of GameCoins to purchase this perk. Please visit F10 menu -> Premium Features to get more GCs.")
				return false
			end
			addPurchaseHistory(client, "Moved radio station position (Name: '"..name.."', Direction: '"..(movingUp and "Up" or "Down").."')", 1)
		end
		
		
		
		if movingUp then
			if order < 2 then
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "This radio station is already on top.")
				return false
			end
			if mysql:query_free("UPDATE `radio_stations` SET `order`=`order`-1 WHERE `id`='"..(id).."' ") then
				forceUpdateClientsGUI()
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "Radio station '"..name.."' has been moved up!")
			else
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not move radio station.")
			end
		else
			if mysql:query_free("UPDATE `radio_stations` SET `order`=`order`+1 WHERE `id`='"..(id).."' ") then
				forceUpdateClientsGUI()
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "Radio station '"..name.."' has been moved down!")
			else
				exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not move radio station.")
			end
		end
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not move radio station's position.")
	end
end
addEvent("moveStationPosition", true)
addEventHandler("moveStationPosition", root, moveStationPosition)

function renewStation(station, duration)
	if station and duration and tonumber(duration) then
		local id = station[1]
		local cost = nil
		if duration == 7 then
			cost = 3
		elseif duration == 30 then
			cost = 10
		elseif duration == 90 then
			cost = 25
		else
			exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not renew radio station #"..id)
			return false
		end
		
		if not exports.donators:takeGC(client, cost) then
			exports.hud:sendBottomNotification(client, "Radio Station Manager", "You lack of GameCoins to purchase this perk. Please visit F10 menu -> Premium Features to get more GCs.")
			return false
		end
		addPurchaseHistory(client, "Renewed radio station (ID: '"..id.."', Name: '"..station[2].."', Duration: '"..duration.." days')", cost)
		
		if not mysql:query_free("UPDATE `radio_stations` SET `expire_date`=(`expire_date` + interval "..duration.." day) WHERE `id`='"..(id).."' ") then
			return false
		end
		
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "You have successfully renewed Radio Station ID#"..id.."!")
		forceUpdateClientsGUI()
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not renew radio station #"..id)
	end
end
addEvent("renewStation", true)
addEventHandler("renewStation", root, renewStation)

function forceUpdateClientsGUI()
	local defaultStations, donorStations = fetchStations()
	for i, player in pairs(getElementsByType("player")) do
		if getElementData(player, "gui:ViewingRadioManager") then
			triggerClientEvent(player, "openRadioManager", player, defaultStations, donorStations)
		end
	end
end

function SmallestID( ) -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM radio_stations AS e1 LEFT JOIN radio_stations AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end
