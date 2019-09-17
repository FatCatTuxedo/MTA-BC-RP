--MAXIME

function savePerms(thePlayer, forumPerms)
	if not thePlayer or not isElement(thePlayer) or not forumPerms then
		return false
	end
	return setStaffLevel(thePlayer, forumPerms)
end

function getPermissions(userID)
	--outputDebugString("Server - getPermissions called")
	local result1 = exports.mysql:forum_query_fetch_assoc("SELECT userid, usergroupid, membergroupids FROM user WHERE userid='"..userID.."'")
	if not result1 then
		--outputDebugString("INTEGRATION / g_configs.lua / Can't fetch data from DB")
		return false
	end
	return result1.usergroupid..","..result1.membergroupids
end

function setStaffLevel(thePlayer, forumPerms)
	setElementData(thePlayer, "forum_perms", forumPerms)
		if string.find(forumPerms, SERVERMANAGEMENTTEAM) then
		return exports.anticheat:changeProtectedElementDataEx(thePlayer, "admin_level", 5, true)
	elseif string.find(forumPerms, LEADADMIN) then
		return exports.anticheat:changeProtectedElementDataEx(thePlayer, "admin_level", 4, true)
	elseif string.find(forumPerms, SENIORADMIN) then
		return exports.anticheat:changeProtectedElementDataEx(thePlayer, "admin_level", 3, true)
	elseif string.find(forumPerms, ADMIN) then
		return exports.anticheat:changeProtectedElementDataEx(thePlayer, "admin_level", 2, true)
	elseif string.find(forumPerms, TRIALADMIN) then
		return exports.anticheat:changeProtectedElementDataEx(thePlayer, "admin_level", 1, true)
	else
		return exports.anticheat:changeProtectedElementDataEx(thePlayer, "admin_level", 0, true)
	end
end