--MAXIME

local usernameCache = {}
local searched = {}
local refreshCacheRate = 10 --Minutes
function getUsername( clue )
	if not clue or string.len(clue) < 1 then
		outputDebugString("Client cache: clue is empty.")
		return false
	end
 
	for i, username in pairs(usernameCache) do
		if username and string.lower(username) == string.lower(clue) then
			outputDebugString("Client cache: Username found in cache - "..username) 
			return username
		end
	end
	
	outputDebugString("Client cache: Username not found in cache. Searching in all current online players.")
	for i, player in pairs(getElementsByType("player")) do
		local username = getElementData(player, "account:username")
		if username and string.lower(username) == string.lower(clue) then
			table.insert(usernameCache, username)
			outputDebugString("Client cache: Username found in current online players. - "..username) 
			return username
		end
	end
	
	outputDebugString("Client cache: Username not found in all current online players. ")
	if not searched[clue] then
		outputDebugString("Client cache: Requesting for server's cache.")
		triggerServerEvent("requestUsernameCacheFromServer", resourceRoot, clue) 
		searched[clue] = true
		setTimer(function()
			local index = clue
			searched[index] = nil
		end, refreshCacheRate*1000*60, 1)
	else
		outputDebugString("Client cache: Previously requested for server's cache. Searching cancelled within refresh rate ("..refreshCacheRate.." minutes).")
	end
	
	return false
end
--addCommandHandler("max", getUsername)

function checkUsernameExistance(clue)
	if not clue or string.len(clue) < 1 then
		return false, "Please enter account name."
	end 
	local found = getUsername( clue )
	if found then
		return true, "Account name '"..found.."' is existed and valid!", found
	else
		return false, "Account name '"..clue.."' does not exist."
	end
end

function retrieveUsernameCacheFromServer(clue)
	outputDebugString("Client cache: Retrieving data from server and adding to client's cache.")
	if clue then
		table.insert(usernameCache, clue)
	end
end
addEvent("retrieveUsernameCacheFromServer", true)
addEventHandler("retrieveUsernameCacheFromServer", root, retrieveUsernameCacheFromServer)