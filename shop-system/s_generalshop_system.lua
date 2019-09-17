mysql = exports.mysql
local useShopsWithNoItems = false
local profitRate = tonumber(get( "profitRate" )) or 5

-- respawn dead npcs after two minute
--[[
addEventHandler("onPedWasted", getResourceRootElement(),
	function()
		setTimer(
			function( source )
				local x,y,z = getElementPosition(source)
				local rotation = getElementData(source, "rotation")
				local interior = getElementInterior(source)
				local dimension = getElementDimension(source)
				local dbid = getElementData(source, "dbid")
				local shoptype = getElementData(source, "shoptype")
				local skin = getElementModel(source)
				local sPendingWage = getElementData(source, "sPendingWage") 
				local sIncome = getElementData(source, "sIncome") 
				local sCapacity = getElementData(source, "sCapacity") 
				local currentCap = getElementData(source, "currentCap") 
				local sSales = getElementData(source, "sSales") 
				local pedName = getElementData(source, "name") 
				destroyElement(source)
				
				createShopKeeper(x,y,z,interior,dimension,dbid,shoptype,rotation,skins, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName)
			end,
			120000, 1, source
		)
	end
)
]]

local skins = { { 211, 217 }, { 179 }, false, { 178 }, { 82 }, { 80, 81 }, { 28, 29 }, { 169 }, { 171, 172 }, { 142 }, { 171 }, { 171, 172 }, {71}, { 50 }, { 1 }, { 118 }, {118} }

function createShopKeeper(x,y,z,interior,dimension,id,shoptype,rotation, skin, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName, sContactInfo, faction_belong, faction_access) 
	if not g_shops[shoptype] then
		outputDebugString("Trying to locate shop #" .. id .. " with invalid shoptype " .. shoptype)
		return
	end
	
	if shoptype == 17 then
		if tonumber(dimension) == 0 and tonumber(interior) == 0 then
			return false
		end
	end
	
	if not skin then
		skin = 0
		
		if shoptype == 3 then
			skin = 168
			-- needs differences for burgershot etc
			if interior == 5 then
				skin = 155
			elseif interior == 9 then
				skin = 167
			elseif interior == 10 then
				skin = 205
			end
			-- interior 17 = donut shop
		elseif shoptype == 16 then
			skin = 27
		else
			-- clothes, interior 5 = victim
			-- clothes, interior 15 = binco
			-- clothes, interior 18 = zip
			skin = skins[shoptype][math.random( 1, #skins[shoptype] )]
		end
	end 
	
	local ped = createPed(skin, x, y, z)
	setElementRotation(ped, 0, 0, rotation)
	setElementDimension(ped, dimension)
	setElementInterior(ped, interior)
	exports.pool:allocateElement(ped)
	
	if shoptype == 17 then
		setElementData(ped, "customshop", true)
	elseif shoptype == 18 or shoptype == 19 then --Faction Drop NPCs
		exports.anticheat:changeProtectedElementDataEx(ped, "faction_belong", faction_belong, true)
		exports.anticheat:changeProtectedElementDataEx(ped, "faction_access", faction_access, true)
	end 
	
	setElementData(ped, "talk", 1, true)
	setElementData(ped, "name", pedName, true) 
	setElementData(ped, "shopkeeper", true)
		
	setElementFrozen(ped, true)
	
	setElementData(ped, "dbid", tonumber(id), true)
	setElementData(ped, "ped:type", "shop", false)
	setElementData(ped, "shoptype", shoptype, false)
	setElementData(ped, "rotation", rotation, false)
	setElementData(ped, "sPendingWage", sPendingWage, true)
	setElementData(ped, "sIncome", (shoptype == 14 and 0 or tonumber(sIncome)), true)
	setElementData(ped, "sCapacity", sCapacity, true)
	setElementData(ped, "currentCap", currentCap, true) 
	setElementData(ped, "sSales", sSales, true) 
	setElementData(ped, "sContactInfo", sContactInfo, true) 
end

function delNearbyGeneralshops(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Deleting Nearby Shop NPC(s):", thePlayer, 255, 126, 0)
		local count = 0
		
		local dimension = getElementDimension(thePlayer)
		
		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local x, y = getElementPosition(thePed)
					local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
					local cdimension = getElementDimension(thePed)
					if (distance<=10) and (dimension==cdimension) then
						local dbid = getElementData(thePed, "dbid")
						local shoptype = getElementData(thePed, "shoptype")
						if deleteGeneralShop(thePlayer, "delshop" , dbid) then
							--outputChatBox("   Deleted Shop with ID #" .. dbid .. " and type "..shoptype..".", thePlayer, 255, 126, 0)
							count = count + 1
						end
					end
				end
			end
		end
		
		if (count==0) then
			outputChatBox("   Deleted None.", thePlayer, 255, 126, 0)
		else
			outputChatBox("   Deleted "..count.." None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("delnearbyshops", delNearbyGeneralshops, false, false)
addCommandHandler("delnearbynpcs", delNearbyGeneralshops, false, false)

-- function createDynamic(x,y,z,interior,dimension,id,rotation,skin ~= -1 and skin, products)
	-- if not skin then
		-- skin = skins[8][math.random( 1, #skins[8] )]
	-- end
	-- local ped = createPed(skin, x, y, z)
	-- setElementDimension(ped, dimension)
	-- setElementInterior(ped, interior)
	-- exports.pool:allocateElement(ped)
	
	-- setElementData(ped, "shopkeeper", true)
	-- setElementFrozen(ped, true)
	-- setElementData(ped, "dbid", id, false)
	-- setElementData(ped, "ped:type", "shop", false)
	-- setElementData(ped, "shoptype", 0, false)
	-- setElementData(ped, "rotation", rotation, false)
-- end

function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result1 = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM shops AS e1 LEFT JOIN shops AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result1 then
		local id1 = tonumber(result1["nextID"]) or 1
		return id1
	end
	return false
end

function createGeneralshop(thePlayer, commandName, shoptype, skin, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local shoptype = tonumber(shoptype)
		if not shoptype or not g_shops[shoptype] then
			outputChatBox("SYNTAX: /" .. commandName .. " [shop type] [skin, -1 = random] [Firstname Lastname, -1 = random]", thePlayer, 255, 194, 14)
			for k, v in ipairs(g_shops) do
				outputChatBox("TYPE " .. k .. " = " .. v.name, thePlayer, 200, 200, 200)
			end
			return false
		end

		local skin = tonumber(skin)
		
		if not skin or skin == -1 then --Random
			skin = exports.global:getRandomSkin()
		end
		
		if skin then
			local ped = createPed(skin, 0, 0, 3)
			if not ped then
				outputChatBox("Invalid Skin.", thePlayer, 255, 0, 0)
				return
			else
				destroyElement(ped)
			end
		else
			skin = -1
		end
		
		local x, y, z = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		local interior = getElementInterior(thePlayer)
		local _, _, rotation = getElementRotation(thePlayer)
		
		if shoptype == 17 then
			if dimension == 0 and interior == 0 then
				outputChatBox("Custom shop must be created in a business interior.", thePlayer, 255, 0, 0)
				return false
			end
		end
		
		local pedName = table.concat({...}, "_") or false
		
		if not pedName or pedName=="" or (tonumber(pedName) and tonumber(pedName) == -1) then
			pedName = exports.global:createRandomMaleName()
			pedName = string.gsub(pedName, " ", "_")
		end
		
		local iCan, why = canIUseThisName(pedName)
		if not iCan then
			outputChatBox(why, thePlayer, 255, 0, 0)
			return false
		end
		
		local id = false
		id = mysql:query_insert_free("INSERT INTO shops SET pedName='"..exports.global:toSQL(pedName).."', x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dimension) .. "', interior='" .. mysql:escape_string(interior) .. "', shoptype='" .. mysql:escape_string(shoptype) .. "', rotationz='" .. mysql:escape_string(rotation) .. "', skin='".. mysql:escape_string(skin).."' ")
		
		if (id) then
			createShopKeeper(x,y,z,interior,dimension,id,tonumber(shoptype),rotation,skin ~= -1 and skin, 0, 0, 10, 0, "", pedName, {"", "", "", ""}, 0, 0)
			exports.logs:logMessage("[/makeshop] " .. getElementData(thePlayer, "account:username") .. "/".. getPlayerName(thePlayer) .." did make shop id " .. id .. " with type " .. shoptype, 4)
		else
			outputChatBox("Error creating shop.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("makeshop", createGeneralshop, false, false)

function getNearbyGeneralshops(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Shop NPC(s):", thePlayer, 255, 126, 0)
		local count = 0
		
		local dimension = getElementDimension(thePlayer)
		
		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local x, y = getElementPosition(thePed)
					local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
					local cdimension = getElementDimension(thePed)
					if (distance<=10) and (dimension==cdimension) then
						local dbid = getElementData(thePed, "dbid")
						local shoptype = getElementData(thePed, "shoptype")
						local pedName = getElementData(thePed, "name") or "Unnamed"
						outputChatBox("   Shop ID #" .. dbid .. ", type "..shoptype..", name: "..tostring(pedName):gsub("_", " "), thePlayer, 255, 126, 0)
						count = count + 1
					end
				end
			end
		end
		
		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbyshops", getNearbyGeneralshops, false, false)
addCommandHandler("nearbynpcs", getNearbyGeneralshops, false, false)

function moveNPCshop(thePlayer, commandName, value)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
	
	if not tonumber(value) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID]", thePlayer, 255, 194, 14)
		return
	end

	local dimension = getElementDimension(thePlayer)

	local possibleShops = getElementsByType("ped", resourceRoot)
	local foundShop = false
		for _, shop in ipairs(possibleShops) do
			if getElementData(shop,"shopkeeper") and (tonumber(getElementData(shop, "dbid")) == tonumber(value)) then
				foundShop = shop
				break
			end
		end

	if not foundShop then 
		outputChatBox("No shop founded with ID #"..value, thePlayer, 255, 0, 0)
		return
	end

	local x, y, z = getElementPosition(thePlayer)
	local dim = getElementDimension(thePlayer)
	local int = getElementInterior(thePlayer)
	local rot, rot1, rot2 = getElementRotation(thePlayer)

	change = mysql:query_insert_free("UPDATE shops SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dim) .. "', interior='" .. mysql:escape_string(int) .. "', rotationz='" .. mysql:escape_string(rot2) .. "' WHERE id=".. mysql:escape_string(tonumber(value)))

	setElementPosition(foundShop, x, y, z)
	setElementDimension(foundShop, dim)
	setElementInterior(foundShop, int)
	setElementRotation(foundShop, rot, rot1, rot2)

	outputChatBox("Updated shop position.", thePlayer, 0, 255, 0)

	end
end
addCommandHandler("moveshop", moveNPCshop)
addCommandHandler("moveNPC", moveNPCshop)
addCommandHandler("movenpc", moveNPCshop)

function gotoShop(thePlayer, commandName, shopID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not tonumber(shopID) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID]", thePlayer, 255, 194, 14)
		else
			local possibleShops = getElementsByType("ped", resourceRoot)
			local foundShop = false
			for _, shop in ipairs(possibleShops) do
				if getElementData(shop,"shopkeeper") and (tonumber(getElementData(shop, "dbid")) == tonumber(shopID)) then
					foundShop = shop
					break
				end
			end
			
			if not foundShop then
				outputChatBox("No shop founded with ID #"..shopID, thePlayer, 255, 0, 0)
				return false
			end
				
			local x, y, z = getElementPosition(foundShop)
			local dim = getElementDimension(foundShop)
			local int = getElementInterior(foundShop)
			local _, _, rot = getElementRotation(foundShop)
			startGoingToShop(thePlayer, x,y,z,rot,int,dim,shopID)
		end
	end
end
addCommandHandler("gotoshop", gotoShop, false, false)

function startGoingToShop(thePlayer, x,y,z,r,interior,dimension,shopID)
	-- Maths calculations to stop the player being stuck in the target
	x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
	y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )
	
	setCameraInterior(thePlayer, interior)
	
	if (isPedInVehicle(thePlayer)) then
		local veh = getPedOccupiedVehicle(thePlayer)
		setVehicleTurnVelocity(veh, 0, 0, 0)
		setElementInterior(thePlayer, interior)
		setElementDimension(thePlayer, dimension)
		setElementInterior(veh, interior)
		setElementDimension(veh, dimension)
		setElementPosition(veh, x, y, z + 1)
		warpPedIntoVehicle ( thePlayer, veh ) 
		setTimer(setVehicleTurnVelocity, 50, 20, veh, 0, 0, 0)
	else
		setElementPosition(thePlayer, x, y, z)
		setElementInterior(thePlayer, interior)
		setElementDimension(thePlayer, dimension)
	end
	outputChatBox(" You have teleported to shop ID#"..shopID, thePlayer)
end

function restoreGeneralShop(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (id) then
			id = getElementData(thePlayer, "shop:mostRecentDeleteShop") or false
			if not id then
				outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
				return false
			end
		end
		
		local dbid = id
	
		local checkExist = mysql:query("SELECT `id` FROM `shops` WHERE `id`='"..tostring(dbid).."' AND `deletedBy` != '0'")
		
		local row = exports.mysql:fetch_assoc(checkExist)
		if not (row) then
			outputChatBox("Shop ID #" .. dbid .. " isn't found in deleted shop database.", thePlayer, 255, 0, 0)
			return false
		end
		
		mysql:query_free("UPDATE `shops` SET `deletedBy` = '0' WHERE id='" .. mysql:escape_string(dbid) .. "' LIMIT 1")
		loadOneShop(dbid)
		outputChatBox("Restored shop with ID #" .. dbid .. ".", thePlayer, 0, 255, 0)
			
	end
end
addCommandHandler("restoreshop", restoreGeneralShop, false, false)
addCommandHandler("restorenpc", restoreGeneralShop, false, false)
addCommandHandler("restoreped", restoreGeneralShop, false, false)


function deleteGeneralShop(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			local counter = 0
			
			for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
				local pedType = getElementData(thePed, "ped:type")
				if (pedType) then
					if (pedType=="shop") then
						local dbid = getElementData(thePed, "dbid")
						if (tonumber(id)==dbid) then
							destroyElement(thePed)
							local adminID = getElementData(thePlayer,"account:id")
							mysql:query_free("UPDATE `shops` SET `deletedBy` = '"..tostring(adminID).."' WHERE id='" .. mysql:escape_string(dbid) .. "' LIMIT 1")
							--mysql:query_free("DELETE FROM shop_products WHERE npcID='" .. mysql:escape_string(dbid) .. "' ")
							--mysql:query_free("DELETE FROM shop_contacts_info WHERE npcID='" .. mysql:escape_string(dbid) .. "' ")
							outputChatBox("      Deleted shop with ID #" .. id .. ".", thePlayer, 0, 255, 0)
							counter = counter + 1
							setElementData(thePlayer, "shop:mostRecentDeleteShop",dbid, true )
						end
					end
				end
			end
			
			if (counter==0) then
				outputChatBox("No shops with such an ID exists.", thePlayer, 255, 0, 0)
				return false
			end
			return true
		end
	end
end
addCommandHandler("delshop", deleteGeneralShop, false, false)
addCommandHandler("deleteshop", deleteGeneralShop, false, false)

function removeGeneralShop(thePlayer, commandName, id)
	if (exports.integration:isPlayerSeniorAdmin(thePlayer)) then
		if not (id) then
			id = getElementData(thePlayer, "shop:mostRecentDeleteShop") or false
			if not id then
				outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
				return false
			end
		end
		
		local dbid = id
		
		local checkExist = mysql:query("SELECT `id` FROM `shops` WHERE `id`='"..tostring(dbid).."' AND `deletedBy` != '0'")
		
		local row = exports.mysql:fetch_assoc(checkExist) 
		if not (row) then
			outputChatBox("Shop ID #" .. dbid .. " isn't found in deleted shop database, /delshop first.", thePlayer, 255, 0, 0)
			return false
		end
		
		
		if mysql:query_free("DELETE FROM shops WHERE id='" .. mysql:escape_string(dbid) .. "' LIMIT 1") and	mysql:query_free("DELETE FROM shop_products WHERE npcID='" .. mysql:escape_string(dbid) .. "' ") and mysql:query_free("DELETE FROM shop_contacts_info WHERE npcID='" .. mysql:escape_string(dbid) .. "' ") then
			outputChatBox("Removed shop ID #" .. dbid .. " from SQL.", thePlayer, 0, 255, 0)
			setElementData(thePlayer, "shop:mostRecentDeleteShop",false, true )
		else
			outputChatBox("No shops with such an ID exists.", thePlayer, 255, 0, 0)
		end
		
	end
end
addCommandHandler("removeshop", removeGeneralShop, false, false)
addCommandHandler("removenpc", removeGeneralShop, false, false)
addCommandHandler("removeped", removeGeneralShop, false, false)

function loadAllGeneralshops(res)
	local result = mysql:query("SELECT `shops`.`id` AS `id`, `x`, `y`, `z`, `dimension`, `interior`, `shoptype`, `rotationz`, `skin`, `sPendingWage`, `sIncome`, `sCapacity`, `sSales`, `pedName`, `sOwner`, `sPhone`, `sEmail`, `sForum`, `faction_belong`, `faction_access` FROM `shops` LEFT JOIN `shop_contacts_info` ON `shops`.`id` = `shop_contacts_info`.`npcID` WHERE `shops`.`deletedBy` = '0'")
	
	while true do
		local row = exports.mysql:fetch_assoc(result)
		if not (row) then
			break
		end
		
		local id = tonumber(row["id"]) 
		local x = tonumber(row["x"])
		local y = tonumber(row["y"])
		local z = tonumber(row["z"])
			
		local dimension = tonumber(row["dimension"])
		local interior = tonumber(row["interior"])
		local shoptype = tonumber(row["shoptype"])
		local rotation = tonumber(row["rotationz"])
		local skin = tonumber(row["skin"])
		local sPendingWage = tonumber(row["sPendingWage"])
		local sIncome = tonumber(row["sIncome"])
		local sCapacity = tonumber(row["sCapacity"])
		local currentCap = 0
		local sSales = row["sSales"]
		local pedName = row["pedName"] or false
		
		local result1 = mysql:query("SELECT COUNT(*) as `currentCap` FROM `shop_products` WHERE `npcID` = '"..tostring(id).."' ") or false
		if result1 then
			local row1 = exports.mysql:fetch_assoc(result1)
			currentCap = tonumber(row1["currentCap"]) or 0
			mysql:free_result(result1)
		end 
		
		local sContactInfo = {row["sOwner"],row["sPhone"],row["sEmail"],row["sForum"]}
		local faction_belong = tonumber(row["faction_belong"])
		local faction_access = tonumber(row["faction_access"])
		
		createShopKeeper(x,y,z,interior,dimension,id,shoptype,rotation,skin ~= -1 and skin, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName, sContactInfo, faction_belong, faction_access)
	end
	mysql:free_result(result)
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllGeneralshops)

function loadOneShop(shopID)
	local result = mysql:query("SELECT `shops`.`id` AS `id`, `x`, `y`, `z`, `dimension`, `interior`, `shoptype`, `rotationz`, `skin`, `sPendingWage`, `sIncome`, `sCapacity`, `sSales`, `pedName`, `sOwner`, `sPhone`, `sEmail`, `sForum`, `faction_belong`, `faction_access` FROM `shops` LEFT JOIN `shop_contacts_info` ON `shops`.`id` = `shop_contacts_info`.`npcID` WHERE `shops`.`deletedBy` = '0' AND `shops`.`id` = '"..tostring(shopID).."' LIMIT 1")
	
	
	local row = exports.mysql:fetch_assoc(result)
	if not (row) then
		return false
	end
	
	local id = tonumber(row["id"])
	local x = tonumber(row["x"])
	local y = tonumber(row["y"])
	local z = tonumber(row["z"])
		
	local dimension = tonumber(row["dimension"])
	local interior = tonumber(row["interior"])
	local shoptype = tonumber(row["shoptype"])
	local rotation = tonumber(row["rotationz"])
	local skin = tonumber(row["skin"])
	local sPendingWage = tonumber(row["sPendingWage"])
	local sIncome = tonumber(row["sIncome"])
	local sCapacity = tonumber(row["sCapacity"])
	local currentCap = 0
	local sSales = row["sSales"]
	local pedName = row["pedName"] or false
	
	local result1 = mysql:query("SELECT COUNT(*) as `currentCap` FROM `shop_products` WHERE `npcID` = '"..tostring(id).."' ") or false
	if result1 then
		local row1 = exports.mysql:fetch_assoc(result1)
		currentCap = tonumber(row1["currentCap"]) or 0
		mysql:free_result(result1)
	end 
	
	local sContactInfo = {row["sOwner"],row["sPhone"],row["sEmail"],row["sForum"]}
	local faction_belong = tonumber(row["faction_belong"])
	local faction_access = tonumber(row["faction_access"])
	
	createShopKeeper(x,y,z,interior,dimension,id,shoptype,rotation,skin ~= -1 and skin, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName, sContactInfo, faction_belong, faction_access)
	
	mysql:free_result(result)
	return true
end

function reloadGeneralShop(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (id) then
			id = getElementData(thePlayer, "shop:mostRecentDeleteShop") or false
			if not id then
				outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
				return false
			end
		end
		
		if loadOneShop(id) then
			outputChatBox("Reloaded shop ID#"..id..".",thePlayer, 0,255,0)
		else
			outputChatBox("Reloaded shop ID#"..id..".",thePlayer, 255,0,0)
		end
	end
end
addCommandHandler("reloadshop", reloadGeneralShop, false, false)
addCommandHandler("reloadnpc", reloadGeneralShop, false, false)
addCommandHandler("reloadped", reloadGeneralShop, false, false)

function renamePed(thePlayer, commandName, id, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not tonumber(id) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID] [Firstname LastName]", thePlayer, 255, 194, 14)
			return false
		end
		id = math.floor(tonumber(id))
		local pedName = table.concat({...}, "_")
		
		if pedName == "" then
			outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID] [Firstname LastName]", thePlayer, 255, 194, 14)
			return false
		end
		
		local iCan, why = canIUseThisName(pedName)
		if not iCan then
			outputChatBox(why, thePlayer, 255, 0, 0)
			return false
		end
		
		if not mysql:query_free("UPDATE `shops` SET `pedName`='"..tostring(pedName):gsub("'","''").."' WHERE `id`='"..tostring(id).."' ") then
			outputChatBox("Failed to rename this NPC, please contact Maxime.",thePlayer, 255,0,0)
			return false
		end
		
		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local dbid = getElementData(thePed, "dbid")
					if (tonumber(id)==dbid) then
						destroyElement(thePed)
					end
				end
			end
		end
		
		if loadOneShop(id) then
			outputChatBox("Renamed shop ID#"..id.." to '"..tostring(pedName):gsub("_"," ").."'.",thePlayer, 0,255,0)
		else
			outputChatBox("Failed to reload this NPC, please contact Maxime.",thePlayer, 255,0,0)
		end
	end
end
addCommandHandler("renameped", renamePed, false, false)
addCommandHandler("renamenpc", renamePed, false, false)
addCommandHandler("renameshop", renamePed, false, false)

-- end of loading shops, this be store keeper thing below --
local function getDiscount( player, shoptype )
	local discount = 1
	if shoptype == 7 and tonumber( getElementData( player, "faction" ) ) == 125 then
		discount = discount * 0.5
	elseif shoptype == 14 and tonumber( getElementData( player, "faction" ) ) == 30 then
		discount = discount * 0.5
	end
	
	if exports.donators:hasPlayerPerk( player, 8 ) then
		discount = discount * 0.8
	end
	return discount
end

function clickStoreKeeper()
	local success, currentUser = canIAccessThisShop(source, client)
	if not success then
		outputChatBox(currentUser.." is currently using this NPC, please wait a moment.", client, 255,0,0)
		return false
	end
	
	local shoptype = getElementData(source, "shoptype")
	local id = getElementData(source, "dbid")
	
	local race, gender = nil, nil
	if(shoptype == 5) then -- if its a clothes shop, we also need the players race
		gender = getElementData(client,"gender")
		race = getElementData(client,"race")
	end
	
	if tonumber(shoptype) == 17 then
		local products = {}
		local shopProducts = mysql:query("SELECT * FROM `shop_products` WHERE `npcID`='"..id.."' ORDER BY `pDate` DESC")
		while true do
			local pRow = mysql:fetch_assoc(shopProducts)
			if not pRow then break end
			table.insert(products, { id, pRow["pItemID"], pRow["pItemValue"], pRow["pDesc"], pRow["pPrice"], pRow["pDate"], pRow["pID"] } )
		end
		mysql:free_result(shopProducts) 
		--[[
		local shopInfo = {}
		local shopInfos = mysql:query("SELECT `sPendingWage`, `sIncome`, `sCapacity`, `sSales` FROM `shops` WHERE `id`='"..id.."' LIMIT 1")
		local pRow1 = mysql:fetch_assoc(shopInfos) or false
		if pRow1 then
			table.insert(shopInfo, { id, pRow1["sPendingWage"], pRow1["sIncome"], pRow1["sCapacity"], pRow1["sSales"] } )
			mysql:free_result(shopInfos) 
		end]]
		if setShopCurrentUser(source, client) then
			triggerClientEvent(client, "showGeneralshopUI", source, shoptype, race, gender, 0, products)
		else
			outputDebugString("setShopCurrentUser failed.")
		end
	elseif tonumber(shoptype) == 18 then --Faction Drop NPC - General Items
		
	elseif tonumber(shoptype) == 19 then -- Faction Drop NPC - WEAPONS
		local products = {}
		local shopProducts = mysql:query("SELECT `npcID`, `pItemID`, `pItemValue`, `pDesc`, `pPrice`, `pDate`, `pID`, `pQuantity`, `pSetQuantity`, `pRestockInterval`, `pRestockedDate`, DATEDIFF((`pRestockedDate` + interval `pRestockInterval` day),NOW()) AS `pRestockIn` FROM `shop_products` WHERE `npcID`='"..id.."' ORDER BY `pID` DESC")
		while true do
			local pRow = mysql:fetch_assoc(shopProducts)
			if not pRow then break end
			table.insert(products, pRow )
		end
		mysql:free_result(shopProducts) 

		if setShopCurrentUser(source, client) then
			triggerClientEvent(client, "showGeneralshopUI", source, shoptype, race, gender, 0, products)
		else
			outputDebugString("setShopCurrentUser failed.")
		end
	else
		if setShopCurrentUser(source, client) then
			-- perk 8 = 20% discount in shops
			triggerClientEvent(client, "showGeneralshopUI", source, shoptype, race, gender, getDiscount(client, shoptype))
		else
			outputDebugString("setShopCurrentUser failed.")
		end
	end
	
end
addEvent("shop:keeper", true)
addEventHandler("shop:keeper", getResourceRootElement(), clickStoreKeeper)


function calcSupplyCosts(thePlayer, itemID, isWeapon, supplyCost)
	if not isweapon and id ~= 68 then
		if exports.donators:hasPlayerPerk(thePlayer, 8) then
			return math.ceil( 0.8 * supplyCost )
		end
	end
	return supplyCost
end

function getInteriorOwner( dimension )
	if dimension == 0 then
		return nil, nil
	end
	
	local dbid, theEntrance, theExit, interiorType, interiorElement = exports["interior-system"]:findProperty(source)
	interiorStatus = getElementData(interiorElement, "status")
	local owner = interiorStatus[4]
	
	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		local id = getElementData(value, "dbid")
		if (id==owner) then
			return owner, value
		end
	end
	return owner, nil -- no player found
end

-- source = the ped clicked
-- client = the player
-- this has no code for the out-of-date lottery.
addEvent("shop:buy", true)
addEventHandler( "shop:buy", resourceRoot, function( index )
	local shoptype = getElementData( source, "shoptype")
	local error = "S-" .. tostring( shoptype ) .. "-" .. tostring( getElementData( source, "dbid") )

	local shop = g_shops[ shoptype or -1 ]
	_G['shop'] = shop
	if not shop then
		outputChatBox("Error " .. error .. "-NE, report at www.owlgaming.net/mantis.", client, 255, 0, 0 )
		return
	end
	
	local race = getElementData( client, "race" )
	local gender = getElementData( client, "gender" )
	updateItems( shoptype, race, gender ) -- should modify /shop/ too, as shop is a reference to g_shops[type].
	
	-- fetch the selected item
	local item = getItemFromIndex( shoptype, index )
	if not item then
		outputChatBox("Error " .. error .. "-NEI-" .. index .. ", report at www.owlgaming.net/mantis.", client, 255, 0, 0 )
		return
	end
	
	if item.minimum_age and getElementData(client, "age") < item.minimum_age then
		outputChatBox( "You need to be " .. item.minimum_age .. " years or older to buy this.", client, 255, 0, 0 )
		return
	end
	
		--[[Check if its a generic, and if they have approval yet
	if item.name == "Other" and item.itemID == 80 and not getElementData(client, "shop:generic:pending") then
		triggerClientEvent(client, "shop:generic:buy", client, index)
		return
	end]]
	
	-- check for monies
	local price = math.ceil( getDiscount( client, shoptype ) * item.price )
	if not exports.global:hasMoney( client, price ) then
		outputChatBox( "You lack the money to buy this " .. item.name .. ".", client, 255, 0, 0 )
		return
	end
	
	-- @@ -- 
	-- do some item-specific stuff, such as assigning a serial.
	-- @@ --
	local wonTheLottery = false
	local itemID, itemValue = item.itemID, item.itemValue or 1
	if itemID == 2 then
		local attempts = 0
		while true do
			-- generate a larger phone number if we're totally out of numbers and/or too lazy to perform more than 20+ checks.
			attempts = attempts + 1
			itemValue = math.random(311111, attempts < 20 and 899999 or 8999999)
			
			local mysqlQ = mysql:query("SELECT `phonenumber` FROM `phones` WHERE `phonenumber` = '" .. itemValue .. "'")
			if mysql:num_rows(mysqlQ) == 0 then
				mysql:free_result(mysqlQ)
				break
			end
			mysql:free_result(mysqlQ)
		end
	elseif itemID == 68 then -- Lottery Tickets
		--[[
		if not exports.integration:isPlayerScripter(client) then
			outputChatBox( "This item is temporarily disabled by scripters.", client, 255, 0, 0 )
			return
		end
		]]
		local dimension = getElementDimension( source )
		local suppliesToTake = 0
		suppliesToTake = item.supplies or math.ceil( 3.5 * exports['item-system']:getItemWeight( itemID, itemValue ) )
		
		if not suppliesToTake then
			outputChatBox( "Error " .. error .. "-SE-I" .. index .. "-" .. tostring( suppliesToTake ) )
			return false
		end

		local success, why = solveSupplies(source, client, suppliesToTake, dimension)
		if not success then
			outputChatBox( why, client, 255, 0, 0 )
			return false
		end

		if not exports["lottery-system"]:canThisPlayerBuyTicket(client) then
			outputChatBox( "One player now can only buy one lottery ticket every 20 minutes.", client, 255, 0, 0 )
			outputChatBox( "You've already bought another lottery ticket not long ago, please try again later.", client, 255, 0, 0 )
			return false
		end

		local lotteryJackpot = exports['lottery-system']:getLotteryJackpot()
		if tonumber(lotteryJackpot) == -1 then
			outputChatBox( "Sorry, someone already won the lottery. Please wait for the next draw.", client, 255, 0, 0 )
			return
		elseif not exports.global:hasSpaceForItem( client, itemID, itemValue ) then
			outputChatBox("Your inventory is full.", client, 255, 0, 0)
		else
			local updatedJackpot = tonumber(lotteryJackpot) + math.ceil(price * 2 / 3)
			exports['lottery-system']:updateLotteryJackpot(updatedJackpot)
		
			local lotteryTicketNumber = 0
			local lotteryTicketNumber = getElementData(client, 'test:nextPickedLotteryNumber') or math.random(2,48) -- Pick a random number for the lottery ticket number between 2 and 48
			itemValue = tonumber(lotteryTicketNumber)
			
			if tonumber(lotteryTicketNumber) == tonumber(exports['lottery-system']:getLotteryNumber()) then
				setTimer(function(player, jp) exports['global']:giveMoney(player, jp) end, 100, 1, client, updatedJackpot)
				outputChatBox( "You won! Jackpot: $" .. exports.global:formatMoney(updatedJackpot) .. ".", client, 0, 255, 0 )

				exports['lottery-system']:lotteryDraw()

				for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
					if (getElementData(value, "loggedin")==1) then
						outputChatBox("[NEWS] " .. getPlayerName(client):gsub("_"," ") .. " won the lottery jackpot of $" .. exports.global:formatMoney(updatedJackpot) .. ".", value, 200, 100, 200)
					end
				end
				exports['lottery-system']:updateLotteryJackpot(-1)
				-- Timer to re-enable lottery 10 minutes after a ticket has been drawn.
				setTimer(function ()
					exports['lottery-system']:updateLotteryJackpot(0)
				end, 600000, 1)

				wonTheLottery = true
			else
				outputChatBox( "Sorry, your number did not get picked. You lost. You got number " .. lotteryTicketNumber .. ".", client, 255, 0, 0 )
			end
			lotteryTicketNumber = 0
		end
	elseif itemID == 115 or itemID == 116 then -- now here's the trick. If item.license is set, it checks for a gun license, if item.ammo is set it gives as much ammo
		if item.license and getElementData( client, "license.gun" ) ~= 1 then
			outputChatBox( "You lack a weapon license.", client, 255, 0, 0 )
			return
		else
			local w = itemValue
			if itemID == 115 then
				local serial = "1"
				if item.license then -- licensed weapon, thus needs a serial
					local characterDatabaseID = getElementData(client, "account:character:id")
					serial = exports.global:createWeaponSerial( 3, characterDatabaseID, characterDatabaseID )
				end
				itemValue = itemValue .. ":" .. serial .. ":" .. getWeaponNameFromID( itemValue )

				addPurchaseLogs(tonumber(getElementData(source, "dbid")), client, tostring( getWeaponNameFromID( w ) ), itemValue, price, serial, "N/A", FORUM_AMMUNATION)
			elseif itemID == 116 then
				local amount = item.ammo or exports.weaponcap:getGTACap( itemValue ) or 1
				itemValue = itemValue .. ":" .. amount .. ":" .. getWeaponNameFromID( itemValue )

				addPurchaseLogs(tonumber(getElementData(source, "dbid")), client, "Ammo for " .. tostring( getWeaponNameFromID( w ) ), amount .. " Ammo for " .. tostring( getWeaponNameFromID( w ) ), price, nil, "N/A", FORUM_AMMUNATION)
			end
		end
	end
	
	local dimension = getElementDimension( source )
	local suppliesToTake = 0
	
	if wonTheLottery or exports.global:giveItem( client, itemID, itemValue ) then
		-- Money
		local playerMoney = getElementData(client, "money")
		for i = 134, 134 do
			while exports['item-system']:takeItem(client, i) do
			end
		end
		if tonumber(playerMoney) > 0 then
			exports.global:giveItem(client, 134, tonumber(playerMoney)-tonumber(price))
		end
		exports.global:takeMoney( client, price ) -- this is assumed not to fail as we checked with :hasMoney before.
		-- and now for what happens after buying?
		outputChatBox( "You bought this " .. item.name .. " for $" .. exports.global:formatMoney( price ) .. ".", client, 0, 255, 0 )
		
		-- some post-buying things, item-specific
		if itemID == 2 then
			mysql:query_free("INSERT INTO `phones` (`phonenumber`, `boughtby`) VALUES ('"..tostring(itemValue).."', '"..mysql:escape_string(tostring(getElementData(client, "account:character:id") or 0)).."')")
			outputChatBox("Your number is #" .. itemValue .. ".", client, 255, 194, 14 )
		elseif itemID == 16 and item.fitting then -- it's a skin, so set it.
			setElementModel( client, itemValue )
			mysql:query_free("UPDATE characters SET skin = " .. mysql:escape_string( itemValue ) .. " WHERE id = " .. mysql:escape_string(getElementData( client, "dbid" )) )
		elseif itemID == 114 then -- vehicle mods
			outputChatBox("To add this item to any vehicle, go into a garage and double-click the item while sitting inside.", client, 255, 194, 14 )
		elseif itemID == 115 then -- log weapon purchases
			exports.logs:dbLog( client, 36, client, "bought WEAPON - " .. itemValue )
			
			local govMoney = math.floor( price / 2 )
			exports.global:giveMoney(getTeamFromName("Fort Carson Municipal Government"), govMoney)
			price = price - govMoney -- you'd obviously get less if the gov asks for percentage.
		elseif itemID == 116 then -- log weapon purchases
			exports.logs:dbLog( client, 36, client, "bought AMMO - " .. itemValue )
			
			local govMoney = math.floor( price / 2 )
			exports.global:giveMoney(getTeamFromName("Fort Carson Municipal Government"), govMoney)
			price = price - govMoney -- you'd obviously get less if the gov asks for percentage.
		end
		
		-- What's left undone? Giving shop owner money!
		
		if price > 0 and dimension > 0 then
			local currentIncome = tonumber(getElementData(source, "sIncome")) or 0
			setElementData(source, "sIncome", currentIncome + price, true)
			playBuySound(source)
			local playerGender = getElementData(client,"gender")
			local pedName = tostring(getElementData(source, "name"))
			if string.sub(pedName, 1, 8) == "userdata" then
				pedName = "The Storekeeper"
			end
			pedName = string.gsub(pedName,"_", " ")
			local playerName = getPlayerName(client):gsub("_", " ")
			if playerGender == 0 then
				triggerEvent('sendAme', client, "takes out a couple of dollar notes from his wallet, hands it over to "..pedName)
			else					
				triggerEvent('sendAme', client, "takes out a couple of dollar notes from her wallet, hands it over to "..pedName)
			end
			local r = getRealTime()
			local timeString = ("%02d/%02d/%04d %02d:%02d"):format(r.monthday, r.month + 1, r.year+1900, r.hour, r.minute)
			local ownerNoti = "A customer bought a "..item.name.." for $"..exports.global:formatMoney(price).."."
			local logString = "- "..timeString.." : A customer bought a "..item.name.." for $"..exports.global:formatMoney(price)..".\n"
			
			exports.global:sendLocalText(client, "* "..pedName.." gave "..playerName.." a "..item.name..".", 255, 51, 102, 30, {}, true)
			storeKeeperSay(client, "Here you are. And..", pedName)
			if playerGender == 0 then
				storeKeeperSay(client, "Thank you sir, Have a nice day!", pedName)
			else
				storeKeeperSay(client, "Thank you ma'ma, Have a nice day!", pedName)
			end
			
			--notifyAllShopOwners(source, ownerNoti.." Come and collect the money when you got time ;)")
			
			local previousSales = getElementData(source, "sSales") or ""
			logString = string.sub(logString..previousSales,1,5000)
			setElementData(source, "sSales", logString, true)
			mysql:query_free("UPDATE `shops` SET `sIncome` = `sIncome` + '" .. tostring(price) .. "', `sSales` = '"..logString:gsub("'","''").."' WHERE `id` = '"..tostring(getElementData(source,"dbid")).."'")
		end
	else
		outputChatBox( "You do not have enough space to carry this " .. item.name .. ".", client, 255, 0, 0 )
	end
end )

function solveSupplies(source, client, suppliesToTake, dimension)
	for key, interior in pairs(getElementsByType("interior")) do
		if getElementData(interior, "dbid") == dimension then
			local status = getElementData(interior, "status")
			local currentSupplies = status[6] or 0
			local ownerID = status[4]
			local interiorType = tonumber(status[1] or 2)
			if ownerID == getElementData(client, "dbid") then
				--suppliesToTake = suppliesToTake*profitRate
				--ownerPlayer = ownerID
				--outputChatBox( "Buying items from your own shop will not make you profit.", client, 255, 0, 0 )
			end
			local remainingSupplies = currentSupplies - suppliesToTake
			--outputDebugString(currentSupplies.."-"..suppliesToTake)
			if remainingSupplies < 0 and (interiorType ~= 2) then 
				return false, "This item is out of stock."
			else
				status[6] = remainingSupplies
				setElementData(interior, "status", status, true)
				if remainingSupplies < 50 and ownerID == getElementData(client, "dbid") then
					outputChatBox( "Supplies in your business #" .. dimension .. " are low. Fill 'em up. ((use /ordersupplies))", client, 255, 194, 14 )
				end
				
				-- take the outstanding supplies
				mysql:query_free("UPDATE `interiors` SET `supplies` = '"..remainingSupplies.."' WHERE id = " .. mysql:escape_string(dimension))
				
				return true, "Cool."
			end
			return false, "Error code 'ESDAFE1241', please report to Maxime"
		end
	end
end

globalSupplies = 0

function updateGlobalSupplies(value)
	globalSupplies = globalSupplies + value
	mysql:query_free("UPDATE settings SET value='" .. mysql:escape_string(tostring(globalSupplies)) .. "' WHERE name='globalsupplies'")
end
addEvent("updateGlobalSupplies", true)
addEventHandler("updateGlobalSupplies", getRootElement(), updateGlobalSupplies)

function checkSupplies(thePlayer)
	local dbid, entrance, exit, inttype,interiorElement = exports['interior-system']:findProperty( thePlayer )
	
	if (dbid==0) then
		outputChatBox("You are not in a business.", thePlayer, 255, 0, 0)
	else
		local interiorStatus = getElementData(interiorElement, "status")
		local owner = interiorStatus[4]
		
		if exports.integration:isPlayerTrialAdmin(thePlayer) or tonumber(owner)==getElementData(thePlayer, "dbid") or exports.global:hasItem(thePlayer, 4, dbid) or exports.global:hasItem(thePlayer, 5, dbid) then
			local query = mysql:query_fetch_assoc("SELECT supplies FROM interiors WHERE id='" .. mysql:escape_string(dbid) .. "' LIMIT 1")
			local supplies = query["supplies"]
			outputChatBox("This business has " .. supplies .. " supplies.", thePlayer, 255, 194, 14)
		else
			outputChatBox("You are not in a business or do you do own the business.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("checksupplies", checkSupplies, false, false)

		--triggerEvent("shop:handleSupplies", source, element, slot, event)
		--triggerClientEvent( source, event or "finishItemMove", source )

addEvent("shop:handleSupplies", true)

function handleSupplies(element, slot, event, worldItem)
	--[[
	local id, itemID, itemValue, item = nil
	
	if worldItem then
		id = getElementData( worldItem, "id" )
		itemID = getElementData( worldItem, "itemID" )
		itemValue = getElementData( worldItem, "itemValue" )
	end	

	if slot ~= -1 then
		item = exports['item-system']:getItems( source )[ slot ]
	end
	
	if (item and item [1] ~= 121) and (itemID and itemID ~= 121) then
		outputChatBox("You cannot use this item for restocking, sorry.", source, 255,0,0)
		triggerClientEvent( source, event or "finishItemMove", source )
		return
	end
	
	local dbid, entrance, exit, inttype,interiorElement = exports['interior-system']:findProperty( source )
	if (dbid==0) then
		outputChatBox("You are not in a business.", source, 255, 0, 0)
		triggerClientEvent( source, event or "finishItemMove", source )
		return
	end
	
	local interiorStatus = getElementData(interiorElement, "status")
	local owner = interiorStatus[4]
	if not (inttype==1) then -- ((tonumber(owner)==getElementData(source, "dbid") or exports.global:hasItem(source, 4, dbid) or exports.global:hasItem(source, 5, dbid)) and (inttype==1)) then
		outputChatBox("You can not restock a non-business property.", source, 255, 0, 0)
		triggerClientEvent( source, event or "finishItemMove", source )
		return
	end
	
	amount = item and tonumber(item[2]) or itemValue and tonumber(itemValue) or 0
	if not amount or amount < 1 then
		outputChatBox("This item is not compatible, please contact an admin.", source, 255, 0, 0)
		triggerClientEvent( source, event or "finishItemMove", source )
		return
	end
	
	local result = mysql:query_free("UPDATE interiors SET supplies= supplies + " .. mysql:escape_string(amount) .. " where id='" .. mysql:escape_string(dbid) .. "'")
	if result then
		if slot == -1 and worldItem and id and isElement(worldItem) then
			outputChatBox("You've added ".. amount .." supplies to this business.", source, 0, 240, 0)
			
			mysql:query_free("DELETE FROM worlditems WHERE id='" .. id .. "'")
			destroyElement(worldItem)
		else
			outputChatBox("You've added ".. amount .." supplies to this business.", source, 0, 240, 0)
			exports['item-system']:takeItemFromSlot( source, slot )
		end
		triggerClientEvent( source, event or "finishItemMove", source )
		return
	end
	]]
	return false
end
addEventHandler("shop:handleSupplies", getRootElement(), handleSupplies)

function canIUseThisName(pedName)
	local checkName = mysql:query("SELECT `id` FROM `characters` WHERE `charactername`='".. mysql:escape_string( pedName ) .."'")
	local row3 = {}
	if checkName then
		row3 = mysql:fetch_assoc(checkName) or false
		mysql:free_result(checkName)
	end
	if row3 then
		return false, "An other player's character has already used this name '"..pedName.."'."
	end
	
	local checkName2 = mysql:query("SELECT `id` FROM `shops` WHERE `pedName`='".. mysql:escape_string( pedName ) .."'")
	local row33 = {}
	if checkName2 then
		row33 = mysql:fetch_assoc(checkName2) or false
		mysql:free_result(checkName2)
	end
	if row33 then
		return false, "An other shop has already used this name '"..pedName.."'."
	end
	return true, "This name is cool"
end

function shopRemoteOrderSupplies(thePlayer, dim, weight)
	local success, why1, why2 = exports["job-system-trucker"]:remoteOrderSupplies(thePlayer, dim, weight)
	outputChatBox(why1,thePlayer, 255, 194, 14)
	outputChatBox(why2,thePlayer, 255, 194, 14)
	return success
end
addEvent("shop:shopRemoteOrderSupplies", true)
addEventHandler("shop:shopRemoteOrderSupplies", getRootElement(), shopRemoteOrderSupplies)

function resStart()
	local result = mysql:query_fetch_assoc("SELECT value FROM settings WHERE name='globalsupplies' LIMIT 1")
	if result then
		globalSupplies = tonumber(result["value"]) or 0
	else
		globalSupplies = 0
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), resStart)