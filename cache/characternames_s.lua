--MAXIME
local mysql = exports.mysql
local characterNameCache = {}
local searched = {}
local refreshCacheRate = 60 --Minutes
function getCharacterNameFromID( id )
	if not id or not tonumber(id) then
		outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if characterNameCache[id] then
		outputDebugString("Server cache: characterName found in cache - "..characterNameCache[id]) 
		return characterNameCache[id]
	end
	
	outputDebugString("Server cache: characterName not found in cache. Searching in all current online players.")
	for i, player in pairs(exports.pool:getPoolElementsByType('player')) do
		if id == getElementData(player, "dbid") then
			characterNameCache[id] = exports.global:getPlayerName(player)
			outputDebugString("Server cache: characterName found in current online players. - "..characterNameCache[id]) 
			return characterNameCache[id]
		end
	end
	
	if searched[id] then
		outputDebugString("Server cache: Previously requested for server's cache but not found. Searching cancelled.")
		return false
	end
	searched[id] = true

	outputDebugString("Server cache: characterName not found in all current online players. Searching in database.")
	local query = mysql:query_fetch_assoc("SELECT `charactername` FROM `characters` WHERE `id` = '" .. mysql:escape_string(id) .. "' LIMIT 1")
	if query and query["charactername"] and string.len(query["charactername"]) > 0 then
		local characterName = string.gsub(query["charactername"], "_", " ")
		characterNameCache[id] = characterName
		outputDebugString("Server cache: characterName found in database, added to cache. - "..query["charactername"])
		return characterNameCache[id]
	end

	setTimer(function()
		local index = id
		searched[index] = nil
	end, refreshCacheRate*1000*60, 1)

	outputDebugString("Server cache: characterName does not exist in database.")
	return false
end

function requestCharacterNameCacheFromServer(id)
	local found = getCharacterNameFromID( id )
	outputDebugString("Server cache: Checked server's cache and responding to client")
	triggerClientEvent(client, "retrieveCharacterNameCacheFromServer", client, found, id)
end
addEvent("requestCharacterNameCacheFromServer", true)
addEventHandler("requestCharacterNameCacheFromServer", root, requestCharacterNameCacheFromServer)
