--MAXIME
local factionNameCache = {}
local searched = {}
local refreshCacheRate = 10 --Minutes
function getFactionNameFromId( id )
	if not id or not tonumber(id) then
		outputDebugString("Client cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if factionNameCache[id] then
		outputDebugString("Client cache: faction name found in cache - "..factionNameCache[id]) 
		return factionNameCache[id]
	end
	
	outputDebugString("Client cache: faction name not found in cache. Searching in all current online factions.")
	local faction = exports.factions.getTeamFromFactionID(id)
	if faction then
		factionNameCache[id] = getTeamName(faction)
		outputDebugString("Client cache: faction name found in current online factions. - "..factionNameCache[id]) 
		return factionNameCache[id]
	end
	
	if searched[id] then
		outputDebugString("Client cache: Previously requested for server's cache but not found. Searching cancelled.")
		return false
	end
	searched[id] = true
	
	outputDebugString("Client cache: Faction name not found in all current online factions. Requesting for server's cache.")
	triggerServerEvent("requestFactionNameCacheFromServer", localPlayer, id)
	
	setTimer(function()
		local index = id
		searched[index] = nil
	end, refreshCacheRate*1000*60, 1)

	return "Loading.."
end

function retrieveFactionNameCacheFromServer(factionName, id)
	outputDebugString("Client cache: Retrieving data from server and adding to client's cache.")
	if factionName and id then
		factionNameCache[id] = factionName
	end
end
addEvent("retrieveFactionNameCacheFromServer", true)
addEventHandler("retrieveFactionNameCacheFromServer", root, retrieveFactionNameCacheFromServer)