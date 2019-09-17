--MAXIME
local mysql = exports.mysql
local businessNameCache = {}
local searched = {}
local refreshCacheRate = 60 --Minutes
function getBusinessNameFromID( id )
	if not id or not tonumber(id) then
		outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if businessNameCache[id] then
		outputDebugString("Server cache: businessName found in cache - "..businessNameCache[id]) 
		return businessNameCache[id]
	end
	
	outputDebugString("Server cache: businessName not found in cache. Searching in all current online players.")
	for i, player in pairs(exports.pool:getPoolElementsByType('player')) do
		if id == getElementData(player, "dbid") then
			businessNameCache[id] = exports.global:getPlayerName(player)
			outputDebugString("Server cache: businessName found in current online players. - "..businessNameCache[id]) 
			return businessNameCache[id]
		end
	end
	
	if searched[id] then
		outputDebugString("Server cache: Previously requested for server's cache but not found. Searching cancelled.")
		return false
	end
	searched[id] = true

	outputDebugString("Server cache: businessName not found in all current online players. Searching in database.")
	local query = mysql:query_fetch_assoc("SELECT `title` AS `businessname` FROM `businesses` WHERE `id` = '" .. mysql:escape_string(id) .. "' LIMIT 1")
	if query and query["businessname"] and string.len(query["businessname"]) > 0 then
		local businessName = string.gsub(query["businessname"], "_", " ")
		businessNameCache[id] = businessName
		outputDebugString("Server cache: businessName found in database, added to cache. - "..query["businessname"])
		return businessNameCache[id]
	end

	setTimer(function()
		local index = id
		searched[index] = nil
	end, refreshCacheRate*1000*60, 1)

	outputDebugString("Server cache: businessName does not exist in database.")
	return false
end

function requestBusinessNameCacheFromServer(id)
	local found = getBusinessNameFromID( id )
	outputDebugString("Server cache: Checked server's cache and responding to client")
	triggerClientEvent(client, "retrieveBusinessNameCacheFromServer", client, found, id)
end
addEvent("requestBusinessNameCacheFromServer", true)
addEventHandler("requestBusinessNameCacheFromServer", root, requestBusinessNameCacheFromServer)
