function doCheck(sourcePlayer, command, ...)
	if (exports.integration:isPlayerTrialAdmin(sourcePlayer) or exports.integration:isPlayerSupporter(sourcePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. command .. " [Partial Player Name / ID]", sourcePlayer, 255, 194, 14)
		else
			local noob = exports.global:findPlayerByPartialNick(sourcePlayer, table.concat({...},"_"))
			if (noob) then
				local logged = getElementData(noob, "loggedin")
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", sourcePlayer, 255, 0, 0)
				else
					if noob and isElement(noob) then
						local ip = getPlayerIP(noob)
						local adminreports = tonumber(getElementData(noob, "adminreports"))
						local donPoints = nil
						
						-- get admin note
						local note = ""
						local warns = "?"
						local transfers = "?"
						local result = mysql:query_fetch_assoc("SELECT adminnote, warns, credits FROM accounts WHERE id = " .. mysql:escape_string(tostring(getElementData(noob, "account:id"))) )
						if result then
							local text = result["adminnote"]
							if text ~= mysql_null() then
								note = text
							end
							
							warns = result["warns"] or "?"
							donPoints = result["credits"] or "?"
						end
						
						-- count warns
						local result = mysql:query_fetch_assoc("SELECT SUM(`warns`) AS warns FROM `accounts` WHERE mtaserial='" .. mysql:escape_string( getPlayerSerial(noob) ) .."'")
						if result then
							-- has warns on other accounts?
							if result["warns"] ~= warns then
								-- show how many
								warns = warns .. " (" .. result["warns"] .. ")"
							end
						end
						
						-- get admin history count
						local history = {}
						local result = mysql:query("SELECT action, COUNT(*) as numbr FROM adminhistory WHERE user = " .. mysql:escape_string(tostring(getElementData(noob, "account:id"))) .. " GROUP BY action" )
						if result then
							repeat
								row = mysql:fetch_assoc(result)
								if row then
									table.insert(history, {tonumber(row.action), tonumber(row.numbr)})
								end
							until not row
							mysql:free_result(result)
						end
						
						-- hours played on all chars
						local hoursAcc = "N/A"
						local result = mysql:query_fetch_assoc("SELECT SUM(hoursPlayed) AS hours FROM `characters` WHERE account = " .. mysql:escape_string(tostring(getElementData(noob, "account:id"))))
						if result then
							hoursAcc = tonumber(result.hours)
						end
						
						local bankmoney = getElementData(noob, "bankmoney") or -1
						local money = getElementData(noob, "money") or -1
						
						local adminlevel = exports.global:getPlayerAdminTitle(noob)
						
						local hoursPlayed = getElementData( noob, "hoursplayed" )
						local username = getElementData( noob, "account:username" )
						triggerClientEvent( sourcePlayer, "onCheck", noob, ip, adminreports, donPoints, note, history, warns, transfers, bankmoney, money, adminlevel, hoursPlayed, username, hoursAcc)
					end
				end
				exports.logs:dbLog(thePlayer, 4, ..., "CHECK")
			end
		end
	end
end
addEvent("checkCommandEntered", true)
addEventHandler("checkCommandEntered", getRootElement(), doCheck)

function savePlayerNote( target, text )
	if exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client) then
		local account = getElementData(target, "account:id")
		if account then
			local result = mysql:query_free("UPDATE accounts SET adminnote = '" .. mysql:escape_string( text ) .. "' WHERE id = " .. mysql:escape_string(account) )
			if result then
				outputChatBox( "Note for the " .. getPlayerName( target ):gsub("_", " ") .. " (" .. getElementData( target, "account:username" ) .. ") has been updated.", client, 0, 255, 0 )
			else
				outputChatBox( "Note Update failed.", client, 255, 0, 0 )
			end
		else
			outputChatBox( "Unable to get Account ID.", client, 255, 0, 0 )
		end
	end
end
addEvent( "savePlayerNote", true )
addEventHandler( "savePlayerNote", getRootElement(), savePlayerNote )

function showAdminHistory( target )
	if source and isElement(source) and getElementType(source) == "player" then
		client = source
	end
	
	if not (exports.integration:isPlayerTrialAdmin( client ) or exports.integration:isPlayerSupporter( client )) then
		if client ~= target then
			return false
		end
	end
	
	local targetID = getElementData( target, "account:id" )
	if targetID then
		local result = mysql:query("SELECT DATE_FORMAT(date,'%b %d, %Y at %h:%i %p') AS date, action, h.admin AS hadmin, reason, duration, a.username as username, c.charactername AS user_char, h.id as recordid FROM adminhistory h LEFT JOIN accounts a ON a.id = h.admin LEFT JOIN characters c ON h.user_char=c.id WHERE user = " .. mysql:escape_string(targetID) .. " ORDER BY h.id DESC" )
		if result then
			local info = {}
			local continue = true
			while continue do
				local row = mysql:fetch_assoc(result)
				if not row then break end
				local record = {}
				
				record[1] = row["date"]
				record[2] = row["action"]
				record[3] = row["reason"]
				record[4] = row["duration"]
				record[5] = row["username"] == mysql_null() and "SYSTEM" or row["username"]
				record[6] = row["user_char"] == mysql_null() and "N/A" or row["user_char"]
				record[7] = row["recordid"]
				record[8] = row["hadmin"]
				
				table.insert( info, record )
			end
			
			triggerClientEvent( client, "cshowAdminHistory", target, info, tostring( getElementData( target, "account:username" ) ) )
			mysql:free_result( result )
		else
			outputChatBox( "Failed to retrieve history.", client, 255, 0, 0)
		end
	else
		outputChatBox("Unable to find the account id.", client, 255, 0, 0)
	end
end
addEvent( "showAdminHistory", true )
addEventHandler( "showAdminHistory", getRootElement(), showAdminHistory )

function showOfflineAdminHistory( gameaccountid, name )
	if (exports.integration:isPlayerTrialAdmin( source ) or exports.integration:isPlayerSupporter( source )) and tonumber(gameaccountid) then
		local targetID = gameaccountid
		local result = mysql:query("SELECT DATE_FORMAT(date,'%b %d, %Y at %h:%i %p') AS date, action, h.admin AS hadmin, reason, duration, a.username as username, c.charactername AS user_char, h.id as recordid FROM adminhistory h LEFT JOIN accounts a ON a.id = h.admin LEFT JOIN characters c ON h.user_char=c.id WHERE user = " .. mysql:escape_string(targetID) .. " ORDER BY h.id DESC" )
		if result then
			local info = {}
			local continue = true
			while continue do
				local row = mysql:fetch_assoc(result)
				if not row then break end
				local record = {}
				record[1] = row["date"]
				record[2] = row["action"]
				record[3] = row["reason"]
				record[4] = row["duration"]
				record[5] = row["username"] == mysql_null() and "SYSTEM" or row["username"]
				record[6] = row["user_char"] == mysql_null() and "N/A" or row["user_char"]
				record[7] = row["recordid"]
				record[8] = row["hadmin"]
				
				table.insert( info, record )
			end
			triggerClientEvent( source, "cshowAdminHistory", source, info, name or gameaccountid )
			mysql:free_result( result )
		else
			outputDebugString( "admin-system\showOfflineAdminHistory: Error." )
			outputChatBox( "Failed to retrieve history.", source, 255, 0, 0)
		end
	end
end
addEvent( "showOfflineAdminHistory", true )
addEventHandler( "showOfflineAdminHistory", getRootElement(), showOfflineAdminHistory )

function removeAdminHistoryLine(ID)
	if not ID then return end

	local sqlQuery = mysql:query_fetch_assoc("SELECT * FROM `adminhistory` WHERE `id`='".. mysql:escape_string(tostring(ID)).."'")
	if sqlQuery then
		if (tonumber(sqlQuery["action"]) == 4) then -- Warning
			local accountNumber = tostring(sqlQuery["user"])
			mysql:query_free("UPDATE `accounts` SET `warns`=warns-1 WHERE `ID`='"..mysql:escape_string(accountNumber).."' AND `warns` > 0")
			for i, player in pairs(getElementsByType("player")) do
				if getElementData(player, "account:id") == tonumber(accountNumber) then
					local warns = getElementData(player, "warns") - 1
					exports.anticheat:changeProtectedElementDataEx(player, "warns", warns, false)
					break
				end
			end
			
		end
	
		mysql:query_free("DELETE FROM `adminhistory` WHERE `id`='".. mysql:escape_string(tostring(ID)) .."'")
		if source then
			outputChatBox("Admin history entry #"..ID.." removed", source, 0, 255, 0)
		end
	end
end
addEvent( "admin:removehistory", true)
addEventHandler( "admin:removehistory", getRootElement(), removeAdminHistoryLine )

addCommandHandler( "history", 
	function( thePlayer, commandName, ... )
		if not (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
			if (...) then
				outputChatBox("Only Admins or Supporters can check other's player admin history.", thePlayer, 255, 0, 0)
				return false
			end
		end
		
		local targetPlayer = thePlayer
		if (...) then
			targetPlayer = exports.global:findPlayerByPartialNick(thePlayer, table.concat({...},"_"))
		end
		
		if targetPlayer then
			local logged = getElementData(targetPlayer, "loggedin")
			if (logged==0) then
				outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
			else
				triggerEvent("showAdminHistory", thePlayer, targetPlayer)
			end
		else
			local targetPlayerName = table.concat({...},"_")
			-- select by charactername
			local result = mysql:query("SELECT account FROM characters WHERE charactername = '" .. mysql:escape_string(targetPlayerName ) .. "'" )
			if result then
				if mysql:num_rows( result ) == 1 then
					local row = mysql:fetch_assoc(result)
					local id = row["account"] or '0'
					triggerEvent("showOfflineAdminHistory", thePlayer, id, targetPlayerName)
					mysql:free_result( result )
					return
				else
					-- select by account
					local targetPlayerName = table.concat({...}," ")
					local result2 = mysql:query("SELECT id FROM accounts WHERE username = '" .. mysql:escape_string( targetPlayerName ) .. "'" )
					if result2 then
						if mysql:num_rows( result2 ) == 1 then
							local row2 = mysql:fetch_assoc(result2)
							local id = tonumber( row2["id"] ) or '0'
							triggerEvent("showOfflineAdminHistory", thePlayer, id, targetPlayerName)
							mysql:free_result( result2 )
							return
						end
						mysql:free_result( result2 )
					end
				end
				mysql:free_result( result )
			end
			mysql:free_result( result )
			outputChatBox("Player not found or multiple were found.", thePlayer, 255, 0, 0)
		end
	end
)


addEvent("admin:showInventory", true)
addEventHandler("admin:showInventory", getRootElement(), 
	function ()
		 executeCommandHandler( "showinv", client, getElementData(source, "playerid") )
	end
)

function addAdminHistory(user, admin, reason, action, duration)
	local user_char = 0
	if not action or not tonumber(action) then
		action = getHistoryAction(action)
	end
	if not action then
		action = 6
	end
	if not duration or not tonumber(duration) then
		duration = 0
	end
	if isElement(user) then
		user_char = getElementData(user, "dbid") or 0
		user = getElementData(user, "account:id") or 0
	end
	if isElement(admin) then
		admin = getElementData(admin, "account:id")
	end
	if not tonumber(user) or not tonumber(admin) or not reason then
		outputDebugString("addAdminHistory failed.")
		return false
	end
	return mysql:query_free("INSERT INTO adminhistory SET admin="..admin..", user="..user..", user_char="..user_char..", action="..action..", duration="..duration..", reason='"..mysql:escape_string(reason).."' ")
end