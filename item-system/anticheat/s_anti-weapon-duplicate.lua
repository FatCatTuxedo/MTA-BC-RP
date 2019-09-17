local mysql = exports.mysql
function isThisGunDuplicated(itemValue, fromPlayer)
	--outputDebugString(itemValue)
	--local cheaterNames = {"Unknown", "Unknown"}
	local itemCheckExplode = exports.global:explode(":", itemValue)
	-- itemCheckExplode: [1] = gta weapon id, [2] = serial number, [3] = weapon name
	local serial = itemCheckExplode and itemCheckExplode[2] or false
	
	if string.len(serial) < 5 then
		return false
	end
	
	
	
	local row1 = mysql:query_fetch_assoc("SELECT COUNT(*) AS 'inv' FROM `items` WHERE `itemValue` LIKE '%" .. mysql:escape_string(serial) .. "%' " ) or false
	if row1 and tonumber(row1.inv) then
		row1 = tonumber(row1.inv)
	else
		row1 = 0
	end
	
	--outputChatBox(row1)
	
	local row2 = mysql:query_fetch_assoc("SELECT COUNT(*) AS 'world' FROM `worlditems` WHERE `itemvalue` LIKE '%" .. mysql:escape_string(serial) .. "%' " ) or false
	if row2 and tonumber(row2.world) then
		row2 = tonumber(row2.world)
	else
		row2 = 0
	end
	
	if (row1+row2) > 1 then
		--[[local ownerName = mysql:query_fetch_assoc("SELECT `charactername` FROM `characters` WHERE `id` = (SELECT `owner` FROM `items` WHERE `index`= '"..mysql:escape_string(index).."' LIMIT 1 ) " ) or false
		if ownerName and ownerName.charactername then
			cheaterNames[1] = ownerName.charactername
		end
		ownerName = mysql:query_fetch_assoc("SELECT `charactername` FROM `characters` WHERE `id` = (SELECT `creator` FROM `worlditems` WHERE `id`= '"..mysql:escape_string(index).."' LIMIT 1) " ) or false
		if ownerName and ownerName.charactername then
			cheaterNames[2] = ownerName.charactername
		end]]
		
		exports.global:sendMessageToAdmins("[ITEM SYSTEM] Weapon duplicate detected and deleted from player " ..(fromPlayer and exports.global:getPlayerName(fromPlayer) or "Unknown").. "." )
		return true
	end
	
	return false
end