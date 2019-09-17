--MAXIME
local mysql = exports.mysql
local factionNameCache = {}
local searched = {}
local refreshCacheRate = 60 --Minutes
function getFactionNameFromId( id )
	if not id or not tonumber(id) then
		outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if factionNameCache[id] then
		outputDebugString("Server cache: factionName found in cache - "..factionNameCache[id]) 
		return factionNameCache[id]
	end
	
	outputDebugString("Server cache: factionName not found in cache. Searching in all current online factions.")
	local faction = exports.factions.getTeamFromFactionID(id)
	if faction then
		factionNameCache[id] = getTeamName(faction)
		outputDebugString("Server cache: factionName found in current online factions. - "..factionNameCache[id]) 
		return factionNameCache[id]
	end
	
	if searched[id] then
		outputDebugString("Server cache: Previously requested for server's cache but not found. Searching cancelled.")
		return false
	end
	searched[id] = true

	outputDebugString("Server cache: factionName not found in all current online factions. Searching in database.")
	local query = mysql:query_fetch_assoc("SELECT `name` FROM `factions` WHERE `id` = '" .. id .. "' LIMIT 1")
	if query and query["name"] and string.len(query["name"]) > 0 then
		local factionName = query["name"]
		factionNameCache[id] = factionName
		outputDebugString("Server cache: factionName found in database, added to cache. - "..factionNameCache[id])
		return factionNameCache[id]
	end

	setTimer(function()
		local index = id
		searched[index] = nil
	end, refreshCacheRate*1000*60, 1)

	outputDebugString("Server cache: factionName does not exist in database.")
	return false
end

function requestFactionNameCacheFromServer(id)
	local found = getFactionNameFromId( id )
	outputDebugString("Server cache: Checked server's cache and responding to client")
	triggerClientEvent(client, "retrieveFactionNameCacheFromServer", client, found, id)
end
addEvent("requestFactionNameCacheFromServer", true)
addEventHandler("requestFactionNameCacheFromServer", root, requestFactionNameCacheFromServer)
