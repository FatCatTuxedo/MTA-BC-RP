--MAXIME / 2015.1.10
local mysql = exports.mysql
function sendOpm(username, msg)
	local user = mysql:query_fetch_assoc("SELECT id, username FROM accounts WHERE username='"..mysql:escape_string(username).."'")
	if user and user.id then
		local read = mysql:query_fetch_assoc("SELECT DATE_FORMAT(date,'%b %d, %Y %h:%i %p') AS fdate FROM notifications WHERE userid="..user.id.." AND offline_pm="..getElementData(source, "account:id").." AND `read`=0 LIMIT 1")
		if read and read.fdate then
			outputChatBox("Opps, "..username.." has already received another unread PM from you at "..read.fdate..". They must read it before you can send them another one.", source, 255,0,0)
			return false
		else
			if makePlayerNotification(user.id, "You've got a new offline private message from "..getElementData(source, "account:username").."!", msg, getElementData(source, "account:id")) then
				outputChatBox("Your offline private message has been delivered to "..username, source, 0,255,0)
				return true
			else
				return false
			end
		end
	else
		outputChatBox("Opps, we couldn't find recipient '"..username.."'. Massage delivery has failed!", source, 255, 0, 0)
		return false
	end
end
addEvent( "opm:send", true )
addEventHandler( "opm:send", root, sendOpm )

function sendOpmFromCmd(player, cmd, username, ...)
	if exports.donators:hasPlayerPerk(player, 37) or exports.integration:isPlayerStaff(player) then
		if username and (...) then
			msg = table.concat({...}," ")
			triggerEvent("opm:send", player, username, msg)
		end
	end
end
addCommandHandler("opm", sendOpmFromCmd)

