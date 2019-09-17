
function loadOneWorldItem(id1)
	local row = exports.mysql:query_fetch_assoc("SELECT `id`, `itemid`, `itemvalue`, `x`, `y`, `z`, `dimension`, `interior`, `rx`, `ry`, `rz`, `creator`, `creationdate`, `protected`, `perm_use`, `perm_move`, `perm_pickup`, `perm_use_data`, `perm_move_data`, `perm_pickup_data` FROM `worlditems` WHERE `id`='"..id1.."' ")

	if row then
		local id = tonumber(row["id"])
		local itemID = tonumber(row["itemid"])
		local itemValue = tonumber(row["itemvalue"]) or row["itemvalue"]
		local x = tonumber(row["x"])
		local y = tonumber(row["y"])
		local z = tonumber(row["z"])
		local dimension = tonumber(row["dimension"])
		local interior = tonumber(row["interior"])
		local rx2 = tonumber(row["rx"]) or 0
		local ry2 = tonumber(row["ry"]) or 0
		local rz2 = tonumber(row["rz"]) or 0
		local creator = tonumber(row["creator"])
		local createdDate = tostring(row["creationdate"])
		local protected = tonumber(row["protected"])
		local permUse = tonumber(row["perm_use"])
		local permMove = tonumber(row["perm_move"])
		local permPickup = tonumber(row["perm_pickup"])
		local permUseData = fromJSON(type(row["perm_use_data"])== "string" and row["perm_use_data"] or "")
		local permMoveData = tonumber(row["perm_use_data"])
		local permPickupData = tonumber(row["perm_pickup_data"])
		if itemID < 0 then -- weapon
			itemID = -itemID
			local modelid = 2969
			-- MODEL ID
			if itemValue == 100 then
				modelid = 1242
			elseif itemValue == 42 then
				modelid = 2690
			else
				modelid = weaponmodels[itemID]
			end
		
			local obj = createItem(id, -itemID, itemValue, modelid, x, y, z - 0.1, 75, -10, rz2)
			exports.pool:allocateElement(obj)
			setElementDimension(obj, dimension)
			setElementInterior(obj, interior)
			exports.anticheat:changeProtectedElementDataEx(obj, "creator", creator)
			exports.anticheat:changeProtectedElementDataEx(obj, "createdDate", createdDate)
			
			if protected and protected ~= 0 then
				exports.anticheat:changeProtectedElementDataEx(obj, "protected", protected)
			end
		else
			local modelid = exports['item-system']:getItemModel(itemID, itemValue)
			
			if (itemID==80) then
				local text = tostring(itemValue)
				local pos = text:find( ":" )
				if (text) and (pos) then
					text = text:sub( pos+1 )
					if tonumber(text) then
						modelid = tonumber(text)
					else
						modelid = 1241
					end
				end
			end
			
			local rx, ry, rz, zoffset = exports['item-system']:getItemRotInfo(itemID)
			local obj = createItem(id, itemID, itemValue, modelid, x, y, z + ( zoffset or 0 ), rx+rx2, ry+ry2, rz+rz2)
			
			if isElement(obj) then
				exports.pool:allocateElement(obj, itemID, true)
				setElementDimension(obj, dimension)
				setElementInterior(obj, interior)
				exports.anticheat:changeProtectedElementDataEx(obj, "creator", creator)
				exports.anticheat:changeProtectedElementDataEx(obj, "createdDate", createdDate)
				
				if protected and protected ~= 0 then
					exports.anticheat:changeProtectedElementDataEx(obj, "protected", protected)
				end

				local permissions = { use = permUse, move = permMove, pickup = permPickup, useData = permUseData, moveData = permMoveData, pickupData = permPickupData }
				anticheat:changeProtectedElementDataEx(obj, "worlditem.permissions", permissions)
			else
				outputDebugString(id .. "/" .. itemID .. "/" .. itemValue .. "/" .. modelid)
			end
		end
		--outputDebugString("loaded - "..id)
	end
end


function loadWorldItems(res)
	local ticks = getTickCount( )
	-- delete items too old
	--exports.mysql:query_free("DELETE FROM `worlditems` WHERE DATEDIFF(NOW(), creationdate) > 30 AND `itemID` != 80 AND `itemID` != 81 AND `itemID` != 103 AND protected = 0" )
	
	exports.mysql:query_free("DELETE FROM `worlditems` WHERE `protected`='0' AND `itemID` NOT IN(81, 103, 169) AND ( (DATEDIFF(NOW(), creationdate) > 30 ) OR (DATEDIFF(NOW(), creationdate) > 7 AND `itemID` = 72) ) " )
	
	-- actually load items
	local result = exports.mysql:query("SELECT `id` FROM `worlditems`")
	
	local timerDelay = 50
	while true do
		local row = exports.mysql:fetch_assoc(result)
		if not row then break end
		
		setTimer(loadOneWorldItem, timerDelay, 1, tonumber(row["id"]))
		timerDelay = timerDelay + 50
	end
	exports.mysql:free_result(result)
	outputDebugString("[ITEM WORLD] Loading "..(timerDelay/50-1).." world items will be finished in approximately "..(timerDelay/1000).." seconds.")
	setTimer(restartResource, timerDelay+60000, 1, getResourceFromName("item-texture")) -- Restart item texture resource 60 seconds after all world items loading done. / Maxime
end
addEventHandler("onResourceStart", resourceRoot, loadWorldItems)