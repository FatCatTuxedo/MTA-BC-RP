--Maxime
mysql = exports.mysql

function givePmsToClient ()
	if getElementData(source,"loggedin") ~= 1 then
		return false
	end
	
    local userID = getElementData(source,"account:id") or false
	if not userID then
		return false 
	end

	local noties = {}
	local q = mysql:query("SELECT *, DATE_FORMAT(date,'%b %d, %Y %h:%i %p') AS fdate, TO_SECONDS(date) as datesec FROM notifications WHERE userid="..userID.." ORDER BY `read` ASC, date DESC LIMIT 15")
	while true do
		local row = mysql:fetch_assoc(q)
		if not row then break end
		table.insert(noties, row )
	end
	mysql:free_result(q)
	
	triggerClientEvent(source, "integration:getPmsFromServer", source, noties)
	--outputDebugString("integration:givePmsToClient - "..getPlayerName(source))  Uncomment if you actually need to debug.
end
addEvent( "integration:givePmsToClient", true )
addEventHandler( "integration:givePmsToClient", root, givePmsToClient )

function readNoti(i, opm)
	mysql:query_free("UPDATE notifications SET `read`=1 WHERE id="..i)
	if opm then
		makePlayerNotification(opm.sender, opm.receiver.." has seen your PM '"..opm.details.."'")
	end
end
addEvent( "readNoti", true )
addEventHandler( "readNoti", root, readNoti )

function deleteNoti(i)
	mysql:query_free("DELETE FROM notifications WHERE id="..i)
end
addEvent( "deleteNoti", true )
addEventHandler( "deleteNoti", root, deleteNoti )

function makePlayerNotification(player, title, details, opm)
	local id = nil
	local elementFound = nil
	if isElement(player) and getElementType(player) == "player" then
		id = getElementData(player, "account:id")
		elementFound = player
	elseif tonumber(player) then
		id = tonumber(player)
	end
	if not id then
		return false
	end
	if not elementFound then
		for i, p in pairs(getElementsByType("player")) do
			if getElementData(p, "account:id") == id then
				elementFound = p
				break
			end
		end
	end

	mysql:query_free("INSERT INTO notifications SET userid="..id..", title='"..mysql:escape_string(title).."', "..(details and string.len(details)>0 and ("details='"..mysql:escape_string(details).."',") or "").." offline_pm="..(opm or "NULL"))
	if elementFound and getElementData(elementFound, "loggedin") == 1 then
		triggerEvent("integration:givePmsToClient", elementFound)
	end
	return true
end