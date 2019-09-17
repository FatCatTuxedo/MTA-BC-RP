local mysql = exports.mysql
function getFactionName(factionID)
	local theTeam = getTeamFromFactionID(factionID)
	if theTeam then
		local name = getTeamName(theTeam)
		if name then
			name = tostring(name)
			return name
		end
	end
	return false
end
function getFactionType(factionID)
	local theTeam = getTeamFromFactionID(factionID)
	if theTeam then
		local ftype = tonumber(getElementData(theTeam, "type"))
		if ftype then
			return ftype
		end
	end
	return false
end

function getFactionFromName(factionName)
	for k,v in ipairs(exports.pool:getPoolElementsByType("team")) do
		if string.lower(getTeamName(v)) == string.lower(factionName) then
			return v
		end
	end
	return false
end
function getFactionIDFromName(factionName)
	local theTeam = getFactionFromName(factionName)
	if theTeam then
		local id = tonumber(getElementData(theTeam, "id"))
		if id then
			return id
		end
	end
	return false
end

function getAllPlayersFromFactionId(fId, groupByAccount, leaderOnly) --Maxime 2015.1.11
	local users = {}
	local q = mysql:query("SELECT a.id AS aid, c.id AS cid, charactername, username FROM accounts a LEFT JOIN characters c ON a.id = c.account WHERE "..(leaderOnly and "faction_leader=1 AND " or "").." faction_id ="..fId.." "..(groupByAccount and "GROUP BY (a.id)" or ''))
	while true do
		local row = mysql:fetch_assoc(q)
		if not row then break end
		table.insert(users, row)
	end
	mysql:free_result(q)
	return users
end

function sendNotiToAllFactionMembers(fId, title, details, leaderOnly) --Maxime 2015.1.11
	local members = getAllPlayersFromFactionId(fId, true, leaderOnly)
	for i, member in ipairs(members) do
		exports.announcement:makePlayerNotification(member.aid, title, details)
	end
end

function getTeamFromFactionID(factionID)
	if not tonumber(factionID) then
		return false
	else 
		factionID = tonumber(factionID)
	end
	return exports.pool:getElement("team", factionID)
end