function checkActiveRoutes(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local count = 0
		outputChatBox("All active Routes:", thePlayer)
		for i = 1, #routes do
			if routes[i] and routes[i][5] then
				outputChatBox("    "..getPlayerName(routes[i][5]):gsub("_", " ").." is working in Route #"..i.." - "..(routes[i][6] or "Unknown").." ("..(routes[i][4] or "0").." kg)", thePlayer)
				count = count + 1
			end
		end
		outputChatBox(count.." active Routes.", thePlayer)
	else
		outputChatBox("Only Full Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("checkactiveroutes", checkActiveRoutes, false, false)

function showActualOrders(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local count = 0
		local tempRoutes = {}
		outputChatBox("[TRUCKER] All Actual Orders:", thePlayer)
		for i = 1, #routes do
			if routes[i] and tonumber(routes[i][8]) and (tonumber(routes[i][8]) > 0) then
				table.insert(tempRoutes, routes[i])
				outputChatBox("     Order ID #"..routes[i][7].." - "..(routes[i][6] or "Unknown").." (Int ID#"..routes[i][8]..", "..(routes[i][4] or "0").." kg)", thePlayer)
				if debugmode then
					outputDebugString("     Order ID #"..routes[i][7].." - "..(routes[i][6] or "Unknown").." (Int ID#"..routes[i][8]..", "..(routes[i][4] or "0").." kg)")
				end
				count = count + 1
			end
		end
		outputChatBox(count.." actual orders", thePlayer)
		if debugmode then
			outputDebugString(count.." actual orders")
		end
		if count > 0 then
			triggerClientEvent(thePlayer, "job-system-trucker:displayAllMarkers", thePlayer, tempRoutes)
		end
	else
		outputChatBox("Only Full Admins can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("showActualOrders", showActualOrders, false, false)

function showAllTruckMarkers(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local count = 0
		local tempRoutes = {}
		outputChatBox("[TRUCKER] All Truck Markers:", thePlayer)
		for i = 1, #routes do
			if routes[i] then
				table.insert(tempRoutes, routes[i])
				outputChatBox("Order ID #"..routes[i][7]..", Name: "..(routes[i][6] or " ")..", Worker: "..(routes[i][5] and getPlayerName(routes[i][5]) or " ")..", Kg: "..(routes[i][4] or "0")..", To Int ID#: "..(routes[i][8] == 0 and "Generic" or routes[i][8]), thePlayer)
				if debugmode then
					outputDebugString("Order ID #"..routes[i][7]..", Name: "..(routes[i][6] or " ")..", Worker: "..(routes[i][5] and getPlayerName(routes[i][5]) or " ")..", Kg: "..(routes[i][4] or "0")..", To Int ID#: "..(routes[i][8] == 0 and "Generic" or routes[i][8]))
				end
				count = count + 1
			end
		end
		outputChatBox(count.." Markers", thePlayer)
		if debugmode then
			outputDebugString(count.." Markers")
		end
		if count > 0 then
			triggerClientEvent(thePlayer, "job-system-trucker:displayAllMarkers", thePlayer, tempRoutes)
		end
	else
		outputChatBox("Only Full Admins can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("showAllTruckMarkers", showAllTruckMarkers, false, false)

function scripterFetchActualOrders(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		outputChatBox("Fetched "..fetchActualOrders().." actual orders from SQL.", thePlayer)
	else
		outputChatBox("Only Full Admins can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("fetchActualOrders", scripterFetchActualOrders, false, false)

function addOrderManually(thePlayer, commandName , ...)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not (...) then
			outputChatBox( "SYNTAX: /" .. commandName .. " [Location Name]", thePlayer, 255, 194, 14 )
			return false
		end
		local orderName = table.concat({...}, " ")
		local x, y, z = getElementPosition(thePlayer)
		if mysql:query_free("INSERT INTO `jobs_trucker_orders` SET `orderX`='"..tostring(x).."', `orderY`='"..tostring(y).."', `orderZ`='"..tostring(z).."', `orderName`='"..tostring(orderName):gsub("'","''").."' ") then
			outputChatBox("Successfully added order '"..orderName.."' into SQL manuanlly.", thePlayer, 0,255,0)
			fetchActualOrders()
			if debugmode then
				outputDebugString("Successfully added order '"..orderName.."' into SQL manuanlly.")
			end
		else
			outputChatBox("Failed to add order '"..orderName.."' into SQL manuanlly.", thePlayer, 255,0,0)
			if debugmode then
				outputDebugString("Failed to add order '"..orderName.."' into SQL manuanlly.")
			end
		end
	else
		outputChatBox("Only Full Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("addtruckerjobmarker", addOrderManually, false, false)

function delMarker(id)
	if mysql:query_free("DELETE FROM `jobs_trucker_orders` WHERE `orderID`='"..tostring(id).."' ") then
		local deleted = false
		for i = 1, #routes do
			if routes[i] and (routes[i][7] == tonumber(id)) then
				if isElement(routes[5]) then
					outputChatBox(getPlayerName(routes[5]):gsub("_", " ").." is currently working on this route. Please wait for him to complete it.", thePlayer, 255,0,0)
					return false
				end
				
				routes[i] = nil
				deleted = true
				break
			end
		end
		if deleted then
			outputChatBox("Deleted marker ID #"..id..".", thePlayer, 0,255,0)
		else
			outputChatBox("Faled to delete marker ID #"..id..".", thePlayer, 255,0,0)
		end
	end
end
addEvent("truckerjob:delMarker", true)
addEventHandler("truckerjob:delMarker", getRootElement(), delMarker)