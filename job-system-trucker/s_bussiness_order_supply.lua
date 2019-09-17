--BY MAXIME 24/5/2013
profitRate = tonumber(get( getResourceName( getResourceFromName("shop-system") ).. '.profitRate' )) or 5

function orderSupplies(thePlayer, commandName, weight)
	if not tonumber(weight) or not (tonumber(weight)%1==0) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Kilogram(s) of supplies] - Place an order of supplies for RS Haul to maintain your business.", thePlayer, 255, 194, 14)
		return false
	end
	 
	weight = tonumber(weight)
	 
	if weight <= 0 then
		outputChatBox("Kilogram(s) of supplies must be greater than 0.", thePlayer, 255, 0, 0)
		return false
	end
	
	local dim = getElementDimension(thePlayer)
	
	if dim <= 0 then
		outputChatBox("You must be inside a property to order supplies.", thePlayer, 255, 0, 0)
		return false
	end
	
	local isAdmin = false
	if string.lower(commandName) == "aordersupplies" then
		isAdmin = true
	end
	
	local success, msg1, msg2 = remoteOrderSupplies(thePlayer, dim, weight, isAdmin)
	if string.lower(commandName) ~= "aordersupplies" then
		outputChatBox(msg1,thePlayer, 255, 194, 14)
	end
	outputChatBox(msg2,thePlayer, 255, 194, 14)
	if success then
		return true
	else
		return false
	end
end
addCommandHandler("ordersupplies", orderSupplies, false, false)

function adminOrderSupplies(thePlayer, commandName, weight)
	if not exports.global:isPlayerAdmin(thePlayer) and not exports.global:isPlayerGameMaster(thePlayer) then
		outputChatBox("Only Admins and GameMasters can access /"..commandName..".", thePlayer, 255,0,0)
		return false
	end
	orderSupplies(thePlayer, commandName, weight)
end
addCommandHandler("aordersupplies", adminOrderSupplies, false, false)

function remoteOrderSupplies(thePlayer, dim, weight, isAdmin)
	if isAdmin or exports.global:hasItem(thePlayer,4, dim) or exports.global:hasItem(thePlayer,5, dim) then
		local price = math.ceil(tonumber(weight)*0.75)
		
		if isAdmin then
			if weight > 300 then
				weight = 300
			end
		end
		
		if isAdmin or exports.global:takeMoney(thePlayer, price) then
			local success, msg = orderSuppliesForInterior(thePlayer,dim, weight)
			if success then
				if isAdmin then
					exports["interior-manager"]:addInteriorLogs(dim, "aordersupplies "..weight, thePlayer)
				end
				return true, weight.." kg(s) of supplies will cost you $"..exports.global:formatMoney(price)..".", msg
			else
				return false, weight.." kg(s) of supplies will cost you $"..exports.global:formatMoney(price)..".", msg
			end
		else
			return false, weight.." kg(s) of supplies will cost you $"..exports.global:formatMoney(price)..". But apparently you don't have enough here...", ""
		end
	else
		return false, "You must must have pair of keys to be able to order more supplies.", ""
	end
end


local function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result1 = mysql:query_fetch_assoc("SELECT MIN(e1.orderID+1) AS nextID FROM jobs_trucker_orders AS e1 LEFT JOIN jobs_trucker_orders AS e2 ON e1.orderID +1 = e2.orderID WHERE e2.orderID IS NULL")
	if result1 then
		local id1 = result1["nextID"] or "1"
		return id1
	end
	return false
end

function orderSuppliesForInterior(thePlayer,dim, weight)
	local int = getElementInterior(thePlayer)
	if int == 0 and dim == 0 then
		
	end
	
	local safeCount = 0 -- To prevent freezing server in the worst case.
	local x, y, z, name = findRootInteriorMarker(dim)
	while not x do
		x, y, z, name = findRootInteriorMarker(y)
		safeCount = safeCount + 1
		if safeCount >= 100 then
			break
		end
	end
	
	if not x then
		return false, "Your interior has no entrance from world map. Therefore, RS Haul Driver will not be able to reach here. Please report this to admins via F2."
	end
	
	if mysql:query_free("INSERT INTO `jobs_trucker_orders` SET `orderID`='"..SmallestID().."', `orderX`='"..tostring(x).."', `orderY`='"..tostring(y).."', `orderZ`='"..tostring(z).."', `orderWeight`='"..tostring(math.floor(tonumber(weight))).."', `orderName`='"..tostring(name):gsub("'","''").."', `orderInterior`='"..tostring(math.floor(tonumber(dim))).."' ") then
		if debugmode then
			outputDebugString("[SUPPLIES ORDER] "..getPlayerName(thePlayer).." has successfully placed an order on '"..name.."'.")
		end
		return true, "Your supplies order has been sent to RS Haul. They will dispatch a driver to get here ASAP."
	else
		if debugmode then
			outputDebugString("[SUPPLIES ORDER] Database Error Code [346213] -Maxime")
		end
		return false, "Database Error Code [346213], please report this to 'Maxime'."
	end
end

function findRootInteriorMarker(dim)
	local foundRootInterior = false
	for key, interior in pairs(getElementsByType("interior")) do
		if dim == getElementData(interior, "dbid") then
			local marker = getElementData(interior, "entrance")
			if marker[4] == 0 and marker[5] == 0 then
				return marker[1], marker[2], marker[3], getElementData(interior, "name") or "Unknown"
			else
				return false, marker[5]
			end
			break
		end
	end
end