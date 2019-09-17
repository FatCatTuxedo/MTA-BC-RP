mysql = exports.mysql
anticheat = exports.anticheat
items = exports['item-system']
itemtexture = exports['item-texture']
global = exports.global
integration = exports.integration

function createItem(id, itemID, itemValue, ...)
	local o = createObject(...)
	if o then
		anticheat:changeProtectedElementDataEx(o, "id", id)
		anticheat:changeProtectedElementDataEx(o, "itemID", itemID)
		anticheat:changeProtectedElementDataEx(o, "itemValue", itemValue, itemValue ~= 1)

		local scale = items:getItemScale(itemID)
		if scale then
			setObjectScale(o, scale)
		end
		local dblSided = items:getItemDoubleSided(itemID)
		if dblSided then
			setElementDoubleSided(o, dblSided)
		end
		local texture = items:getItemTexture(itemID, itemValue)
		if texture then
			for k,v in ipairs(texture) do
				itemtexture:addTexture(o, v[2], v[1])
			end
		end

		return o
	else
		if mysql:query_free("DELETE FROM `worlditems` WHERE `id` = '" .. mysql:escape_string(id).."'" ) then
			outputDebugString("Deleted bugged Item ID #"..id)
		else
			outputDebugString("Failed to delete bugged Item ID #"..id)
		end
		return false
	end
end

function updateItemValue(element, newValue)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local id = tonumber(getElementData(element, "id")) or 0
		if mysql:query_free("UPDATE `worlditems` SET `itemvalue`='"..mysql:escape_string(tostring(newValue)).."' WHERE `id`='"..mysql:escape_string(tostring(id)).."'") then
			anticheat:changeProtectedElementDataEx(element, "itemValue", newValue)
			return true
		end
	end
	return false
end

function setData(element, key, value)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local id = tonumber(getElementData(element, "id")) or 0
		local result = mysql:query("SELECT `id` FROM `worlditems_data` WHERE `item`='"..mysql:escape_string(tostring(id)).."' AND `key`='"..mysql:escape_string(tostring(key)).."' LIMIT 1")
		if result then
			local numRows = mysql:num_rows(result)
			mysql:free_result(result)
			result = nil
			local valueInsert
			if type(value) == "table" then
				valueInsert = toJSON(value)
			else
				valueInsert = value
			end
			if numRows > 0 then
				result = mysql:query_free("UPDATE `worlditems_data` SET `value`='"..mysql:escape_string(tostring(valueInsert)).."' WHERE `item`='"..mysql:escape_string(tostring(id)).."' AND `key`='"..mysql:escape_string(tostring(key)).."'")
				if result then
					anticheat:changeProtectedElementDataEx(element, "worlditemData."..tostring(key), value)
					return true
				end
			else
				result = mysql:query_free("INSERT INTO `worlditems_data` (`item`, `key`, `value`) VALUES ('"..mysql:escape_string(tostring(id)).."', '"..mysql:escape_string(tostring(key)).."', '"..mysql:escape_string(tostring(valueInsert)).."');")
				if result then
					anticheat:changeProtectedElementDataEx(element, "worlditemData."..tostring(key), value)
					return true
				end
			end
		end
	end
	return false
end

function getData(element, key, format)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		if getElementData(element, "worlditems.loaded.data."..tostring(key)) then
			return getElementData(element, "worlditemData."..tostring(key)) or false
		else
			return getDataFromDB(element, key, format)
		end
	end
	return false
end

function getDataFromDB(element, key, format)
	if getElementParent(getElementParent(element)) ~= getResourceRootElement(getThisResource()) then
		return false
	end
	id = tonumber(getElementData(element, "id")) or 0
	if id < 1 then return false end
	local value
	local result = mysql:query("SELECT `value` FROM `worlditems_data` WHERE `item`='"..mysql:escape_string(tostring(id)).."' AND `key`='"..mysql:escape_string(tostring(key)).."' LIMIT 1")
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		value = row.value
	end
	if value and format then
		if format == "table" or format == "json" then
			value = fromJSON(value)
		elseif format == "number" then
			value = tonumber(value)
		elseif format == "bool" or format == "boolean" then
			if type(value) == "string" then
				if value == "false" then
					value = false
				elseif value == "true" then
					value = true
				end
			else
				value = false
			end
		end
	end
	anticheat:changeProtectedElementDataEx(element, "worlditemData."..tostring(key), value)
	anticheat:changeProtectedElementDataEx(element, "worlditems.loaded.data."..tostring(key), true)
	mysql:free_result(result)
	return value
end

function getAllDataFromDB(id, element)
	if element then
		if getElementParent(getElementParent(element)) ~= getResourceRootElement(getThisResource()) then
			return false
		end
	end
	if not id and element then
		id = tonumber(getElementData(element, "id")) or 0
		if id < 1 then return false end
	end
	if not id then return false end
	local table = {}
	local result = mysql:query("SELECT `key`, `value` FROM `worlditems_data` WHERE `item`='"..mysql:escape_string(tostring(id)).."'")
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		table[tostring(row.key)] = row.value
		if element then
			anticheat:changeProtectedElementDataEx(element, "worlditemData."..tostring(row.key), row.value)
		end
	end
	mysql:free_result(result)
	return table
end

function setPermissions(element, permissions)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local id = tonumber(getElementData(element, "id")) or 0
		result = mysql:query_free("UPDATE `worlditems` SET `perm_use`='"..mysqL:escape_string(tostring(permissions.use)).."', `perm_move`='"..mysqL:escape_string(tostring(permissions.move)).."', `perm_pickup`='"..mysqL:escape_string(tostring(permissions.pickup)).."', `perm_use_data`='"..mysqL:escape_string(tostring(toJSON(permissions.useData))).."', `perm_move_data`='"..mysqL:escape_string(tostring(toJSON(permissions.moveData))).."', `perm_pickup_data`='"..mysqL:escape_string(tostring(toJSON(permissions.pickupData))).."' WHERE `id`='"..mysql:escape_string(tostring(id)).."'")
		if result then
			anticheat:changeProtectedElementDataEx(element, "worlditem.permissions", permissions)
			return true
		end
	end
	return false
end

function getPermissions(element)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local perm = getElementData(element, "worlditem.permissions")
		if perm then
			return perm
		else
			return getPermissionsFromDB(element)
		end
	end
	return false
end

function getPermissionsFromDB(element)
	if getElementParent(getElementParent(element)) ~= getResourceRootElement(getThisResource()) then
		return false
	end
	id = tonumber(getElementData(element, "id")) or 0
	if id < 1 then return false end
	local permissions
	local result = mysql:query("SELECT `perm_use`, `perm_move`, `perm_pickup`, `perm_use_data`, `perm_move_data`, `perm_pickup_data` FROM `worlditems` WHERE `id`='"..mysql:escape_string(tostring(id)).."' LIMIT 1")
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		permissions = { use = tonumber(row.perm_use), move = tonumber(row.perm_move), pickup = tonumber(row.perm_pickup), useData = fromJSON(row.perm_use_data), moveData = fromJSON(row.perm_move_data), pickupData = fromJSON(row.perm_pickup_data) }
	end
	anticheat:changeProtectedElementDataEx(element, "worlditem.permissions", permissions)
	mysql:free_result(result)
	return permissions
end