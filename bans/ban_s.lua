--MAXIME / 2014.12.29
-- BAN
local mysql = exports.mysql
local lastBan = nil
local lastBanTimer = nil
function banAPlayer(thePlayer, commandName, targetPlayer, hours, ...)
	if exports["integration"]:isPlayerTrialAdmin(thePlayer) then
		if not (targetPlayer) or not (hours) or not tonumber(hours) or tonumber(hours)<0 or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Time in Hours, 0 = Infinite] [Reason]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			local targetPlayerSerial = getPlayerSerial(targetPlayer)
			local targetPlayerIP = getPlayerIP(targetPlayer)
			hours = tonumber(hours)

			if not (targetPlayer) then
			elseif (hours>168) then
				outputChatBox("You cannot ban for more than 7 days (168 Hours).", thePlayer, 255, 194, 14)
			else
				local thePlayerPower = exports.global:getPlayerAdminLevel(thePlayer)
				local targetPlayerPower = exports.global:getPlayerAdminLevel(targetPlayer)
				reason = table.concat({...}, " ")

				if (targetPlayerPower <= thePlayerPower) then -- Check the admin isn't banning someone higher rank them him
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local playerName = getPlayerName(thePlayer)
					local accountID = getElementData(targetPlayer, "account:id")
					local username = getElementData(targetPlayer, "account:username") or "N/A"

					local seconds = ((hours*60)*60)
					local rhours = hours
					-- text value
					if (hours==0) then
						hours = "Permanent"
					elseif (hours==1) then
						hours = "1 Hour"
					else
						hours = hours .. " Hours"
					end

					if hours == "Permanent" then
						reason = reason .. " (" .. hours .. ")"
					else
						reason = reason .. " (" .. hours .. ")"
					end

					
					exports['admin-system']:addAdminHistory(targetPlayer, thePlayer, reason, 2 , rhours)
					local banId = nil
					if (seconds == 0) then
						banId = addToBan(accountID, targetPlayerSerial, targetPlayerIP, getElementData(thePlayer, "account:id"), reason)
						if banId and tonumber(banId) then
							lastBan = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..banId.."'")
							if lastBanTimer and isTimer(lastBanTimer) then
								killTimer(lastBanTimer)
								lastBanTimer = nil
							end
							lastBanTimer = setTimer(function()
								lastBan = nil
							end, 1000*60*5,1) --5 minutes
						end
					else
						addBan(nil, nil, targetPlayerSerial, thePlayer, reason, seconds)
					end

					local adminUsername = getElementData(thePlayer, "account:username")
					local adminUserID = getElementData(thePlayer, "account:id")
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					--makeForumThread(targetPlayerName or "N/A", username, hours, adminTitle , playerName, thePlayer, reason, adminUsername, adminUserID, banId )
					for key, value in ipairs(getElementsByType("player")) do
						if getPlayerSerial(value) == targetPlayerSerial then
							kickPlayer(value, thePlayer, reason)
						end
					end

					adminTitle = exports.global:getAdminTitle1(thePlayer)
					if (hiddenAdmin==1) then
						adminTitle = "A hidden admin"
					end

					if string.lower(commandName) == "sban" then
						exports.global:sendMessageToAdmins("[SILENT-BAN] " .. adminTitle .. " silently banned " .. targetPlayerName .. ". (" .. hours .. ")")
						exports.global:sendMessageToAdmins("[SILENT-BAN] Reason: " .. reason .. ".")
					elseif string.lower(commandName) == "forceapp" then
						outputChatBox("[FA] "..adminTitle .. " " .. playerName .. " forced app " .. targetPlayerName .. ".", root, 255,0,0)
						hours = "Permanent"
						reason = "Failure to meet server standard. Please improve yourself then appeal on forums.owlgaming.net"
						outputChatBox("[FA]: Reason: " .. reason .. "." ,root, 255,0,0)
					else
						outputChatBox("[BAN] " .. adminTitle .. " banned " .. targetPlayerName .. ". (" .. hours .. ")", root, 255,0,0)
						outputChatBox("[BAN] Reason: " .. reason .. ".", root, 255,0,0)
					end
					exports.global:sendMessageToAdmins("/showban for details.")
				else
					outputChatBox(" This player is a higher level admin than you.", thePlayer, 255, 0, 0)
					outputChatBox(playerName .. " attempted to execute the ban command on you.", targetPlayer, 255, 0 ,0)
				end
			end
		end
	end
end
addCommandHandler("pban", banAPlayer, false, false)
addCommandHandler("sban", banAPlayer, false, false)

function makeForumThread(targetPlayerName, bannedUserName, hours, adminTitle , playerName, thePlayer, reason, adminUsername, adminUserID, banrecordId)
	bannedUserName = exports.mysql:escape_string(bannedUserName)
	targetPlayerName = exports.mysql:escape_string(string.gsub(targetPlayerName,"_"," "))
	adminUsername = string.gsub(adminUsername, "_", " ")
	adminUsername = mysql:escape_string(adminUsername)

	local forumTitle = "("..bannedUserName..") "..targetPlayerName.." - "..hours
	forumTitle = mysql:escape_string(forumTitle)

	reason = mysql:escape_string(reason)

	local content = "[CENTER][IMG]http://forums.owlgaming.net/images/metro/bw/misc/vbulletin4_logo.png[/IMG][/CENTER][CENTER][INDENT][/INDENT][SIZE=5][FONT=impact]Ban Log on ("..bannedUserName..") "..targetPlayerName.."[/FONT][/SIZE][/CENTER][B]Banned username:[/B][INDENT]"..bannedUserName.."[/INDENT][B]Character name: [/B][INDENT]"..targetPlayerName.."[/INDENT][B]Banned by: [/B][INDENT]"..adminUsername.."[/INDENT][B]Period: [/B][INDENT]"..hours..".[/INDENT][B]Reason: [/B][INDENT]"..reason.."[/INDENT][U][I]Note: Please make a reply to this post with any additional information you may have.[/I][/U]"

	content = mysql:escape_string(content)

	local firstID = exports.mysql:forum_query_insert_free("INSERT INTO post SET  parentid = '0', username = '"..adminUsername.."', userid = '"..adminUserID.."', title = '" .. forumTitle .. "', dateline = unix_timestamp(), pagetext = '"..content.."', allowsmilie = '0', showsignature = '0', ipaddress = '127.0.0.1', iconid = '0', visible = '1', attach = '0', infraction = '0', reportthreadid = '0'")

	local seccondID = exports.mysql:forum_query_insert_free("INSERT INTO thread SET title = '" .. forumTitle .. "', firstpostid = '" .. firstID .. "', lastpost = unix_timestamp(), forumid = '142', pollid = '0', open = '1', replycount = '0', postercount = '1', hiddencount = '0', deletedcount = '0', postusername = '"..adminUsername.."', postuserid = '"..adminUserID.."', lastposter = '"..adminUsername.."', lastposterid = '"..adminUserID.."', dateline = unix_timestamp(), views = '0', iconid = '0', visible = '1', sticky = '0', votenum = '0', votetotal = '0', attach = '0', `force_read_usergroups`='', `force_read_forums`='' ")

	exports.mysql:forum_query_free("UPDATE post SET threadid = '"..seccondID.."' WHERE postid = '"..firstID.."'")
	exports.mysql:forum_query_free("update `user` set posts = posts + 1 where userid = '"..adminUserID.."' ")
	exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = '"..adminUsername.."', lastposterid='"..adminUserID.."', lastpostid='"..firstID.."', lastthread='"..forumTitle.."', lastthreadid='"..seccondID.."', threadcount = threadcount + 1 WHERE forumid = 142")
	--exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = '"..adminUsername.."', lastposterid='"..adminUserID.."', lastpostid='"..firstID.."', lastthread='"..forumTitle.."' ,lastthreadid='"..seccondID.."', threadcount = threadcount + 1 WHERE forumid = 33")
	--exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = '"..adminUsername.."', lastposterid='"..adminUserID.."', lastpostid='"..firstID.."', lastthread='"..forumTitle.."' ,lastthreadid='"..seccondID.."', threadcount = threadcount + 1 WHERE forumid = 31")

	exports.global:sendMessageToAdmins("[BAN] Ban topic created: http://forums.owlgaming.net/showthread.php/"..seccondID)
	if banrecordId then 
		exports.mysql:query_free("UPDATE bans SET threadid="..seccondID.." WHERE id="..banrecordId)
	end
end

--OFFLINE BAN BY MAXIME
function offlineBanAPlayer(thePlayer, commandName, targetUsername, hours, ...)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if not (targetUsername) or not (hours) or not tonumber(hours) or (tonumber(hours)<0) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Username] [Time in Hours, 0 = Infinite] [Reason]", thePlayer, 255, 194, 14)
		else
			hours = tonumber(hours) or 0
			if (hours>168) then
				outputChatBox("You cannot ban for more than 7 days (168 Hours).", thePlayer, 255, 194, 14)
				return false
			end

			local user = mysql:query_fetch_assoc("SELECT * FROM `accounts` WHERE `username`='".. mysql:escape_string( targetUsername ) .."' LIMIT 1")
			if user and user['id'] and tonumber(user['id']) then
				targetUsername = user['username']
				local ban = mysql:query_fetch_assoc("SELECT * FROM bans WHERE account='"..user['id'].."' LIMIT 1")
				if ban and ban['id'] and tonumber(ban['id']) then
					printBanInfo(thePlayer, ban)
					return false
				end

				local thePlayerPower = exports.global:getPlayerAdminLevel(thePlayer)
				local adminTitle = exports.global:getAdminTitle1(thePlayer)
				local adminUsername = getElementData(thePlayer, "account:username" )
				if (tonumber(user['admin']) > thePlayerPower) then
					outputChatBox(" '"..targetUsername.."' is a higher level admin than you.", thePlayer, 255, 0, 0)
					exports.global:sendMessageToAdmins("AdmWrn: "..adminTitle.." attempted to execute the ban command on higher admin '"..targetUsername.."'.")
					return false
				end

				--check online players
				for i, player in pairs(getElementsByType("player")) do
					if getElementData(player, "account:id") == tonumber(user['id'])  then
						local cmd = "pban"
						if string.lower(commandName) == "soban" then
							cmd = "sban"
						end
						banAPlayer(thePlayer, cmd, getElementData(player, "playerid"), hours, (...))
						return true
					end
				end

				local reason = table.concat({...}, " ")
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				local playerName = getPlayerName(thePlayer)

				local seconds = ((hours*60)*60)
				local rhours = hours
				-- text value
				if (hours==0) then
					hours = "Permanent"
				elseif (hours==1) then
					hours = "1 Hour"
				else
					hours = hours .. " Hours"
				end
				reason = reason .. " (" .. hours .. ")"
				exports['admin-system']:addAdminHistory(user['id'], thePlayer, reason, 2, rhours)

				local targetSerial = nil
				if user['mtaserial'] ~= mysql_null() then
					targetSerial = user['mtaserial']
				end
				local banId = nil
				if seconds == 0 then
					banId = addToBan(user['id'], user['mtaserial'], user['ip'], getElementData(thePlayer, "account:id"), reason)
					if banId and tonumber(banId) then
						lastBan = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..banId.."'")
						if lastBanTimer and isTimer(lastBanTimer) then
							killTimer(lastBanTimer)
							lastBanTimer = nil
						end
						lastBanTimer = setTimer(function()
							lastBan = nil
						end, 1000*60*5,1) --5 minutes
					end
				elseif targetSerial then
					addBan(nil, nil, targetSerial, thePlayer, reason, seconds)
				end
				local adminUsername = getElementData(thePlayer, "account:username")
				local adminUserID = getElementData(thePlayer, "account:id")
				adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				makeForumThread("N/A", targetUsername, hours, adminTitle , playerName, thePlayer, reason, adminUsername, adminUserID, banId )
				if targetSerial then
					for key, value in ipairs(getElementsByType("player")) do
						if getPlayerSerial(value) == targetSerial then
							kickPlayer(value, thePlayer, reason)
						end
					end
				end

				if (hiddenAdmin==1) then
					adminTitle = "A hidden admin"
				end
				if string.lower(commandName) == "soban" then
					exports.global:sendMessageToAdmins("[OFFLINE-BAN]: " .. adminTitle .. " " .. adminUsername .. " silently banned " .. targetUsername .. ". (" .. hours .. ")")
					exports.global:sendMessageToAdmins("[OFFLINE-BAN]: Reason: " .. reason .. ".")
				else
					outputChatBox("[OFFLINE-BAN]: " .. adminTitle .. " " .. adminUsername .. " banned " .. targetUsername .. ". (" .. hours .. ")", getRootElement(), 255, 0, 51)
					outputChatBox("[OFFLINE-BAN]: Reason: " .. reason .. ".", getRootElement(), 255, 0, 51)
				end

				exports.global:sendMessageToAdmins("/showban for details.")
			else
				outputChatBox("Player Username not found!", thePlayer, 255, 194, 14)
				return false
			end
		end
	end
end
addCommandHandler("oban", offlineBanAPlayer, false, false)
addCommandHandler("soban", offlineBanAPlayer, false, false)

function banPlayerSerial(thePlayer, commandName, serial, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not serial or not string.len(serial) or not string.len(serial) == 32 or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Serial Number] [Reason]", thePlayer, 255, 194, 14)
		else

			local reason = table.concat({...}, " ")
			serial = string.upper(serial)
			local id = addToBan(nil, serial, nil, getElementData(thePlayer,"account:id"), reason)
			if id and tonumber(id) then
				local ban = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..id.."'")
				if ban and tonumber(ban['id']) then
					lastBan = ban
					if lastBanTimer and isTimer(lastBanTimer) then
						killTimer(lastBanTimer)
						lastBanTimer = nil
					end
					lastBanTimer = setTimer(function()
						lastBan = nil
					end, 1000*60*5,1) --5 minutes
					for key, value in ipairs(getElementsByType("player")) do
						if getPlayerSerial(value) == serial then
							kickPlayer(value, thePlayer, reason)
						end
					end
					exports.global:sendMessageToAdmins("[BAN] "..exports.global:getPlayerFullIdentity(thePlayer).." has banned serial number '"..serial.."' permanently for '"..reason.."'. /showban for details.")
				end
			else

			end
		end
	end
end
addCommandHandler("banserial", banPlayerSerial, false, false)
addCommandHandler("serialban", banPlayerSerial, false, false)

function banPlayerIP(thePlayer, commandName, ip, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not ip or not string.len(ip) or string.len(ip) > 15 or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [IP Address] [Reason]", thePlayer, 255, 194, 14)
			outputChatBox("You can use * for IP range ban. For example: 192.168.*.*", thePlayer, 255, 194, 14)
		else
			local reason = table.concat({...}, " ")
			local id = addToBan(nil, nil, ip, getElementData(thePlayer,"account:id"), reason)
			if id and tonumber(id) then
				local ban = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..id.."'")
				if ban and tonumber(ban['id']) then
					lastBan = ban
					if lastBanTimer and isTimer(lastBanTimer) then
						killTimer(lastBanTimer)
						lastBanTimer = nil
					end
					lastBanTimer = setTimer(function()
						lastBan = nil
					end, 1000*60*5,1) --5 minutes
					for key, value in ipairs(getElementsByType("player")) do
						if getPlayerIP(value) == ip then
							kickPlayer(value, thePlayer, reason)
						end
					end
					exports.global:sendMessageToAdmins("[BAN] "..exports.global:getPlayerFullIdentity(thePlayer).." has banned IP Address '"..ip.."' permanently for '"..reason.."'. /showban for details.")
				end
			end
		end
	end
end
addCommandHandler("ipban", banPlayerIP, false, false)
addCommandHandler("banip", banPlayerIP, false, false)

function banPlayerAccount(thePlayer, commandName, account, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not account or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Username] [Reason]", thePlayer, 255, 194, 14)
		else
			local account = exports.mysql:query_fetch_assoc("SELECT id, username from accounts WHERE username='"..exports.mysql:escape_string(account).."' LIMIT 1")
			if not account or account.id == mysql_null() then
				outputChatBox("Account '"..account.."' does not existed.", thePlayer, 255, 0, 0)
				return false
			end
			local reason = table.concat({...}, " ")
			local id = addToBan(account.id, nil, nil, getElementData(thePlayer,"account:id"), reason)
			if id and tonumber(id) then
				local ban = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..id.."'")
				if ban and tonumber(ban['id']) then
					lastBan = ban
					if lastBanTimer and isTimer(lastBanTimer) then
						killTimer(lastBanTimer)
						lastBanTimer = nil
					end
					lastBanTimer = setTimer(function()
						lastBan = nil
					end, 1000*60*5,1) --5 minutes
					for key, value in ipairs(getElementsByType("player")) do
						if getElementData(value, "account:id") == tonumber(account.id) then
							kickPlayer(value, thePlayer, reason)
						end
					end
					exports.global:sendMessageToAdmins("[BAN] "..exports.global:getPlayerFullIdentity(thePlayer).." has banned account '"..(account.username).."' permanently for '"..reason.."'. /showban for details.")
				end
			end
		end
	end
end
addCommandHandler("banaccount", banPlayerAccount, false, false)
addCommandHandler("accountban", banPlayerAccount, false, false)

-- /UNBAN
function unbanPlayer(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not id or not tonumber(id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Ban ID]", thePlayer, 255, 194, 14)
			outputChatBox("/showban [Username or serial or IP] to retrieve ban ID.", thePlayer, 255, 194, 14)
		else
			if getElementData(thePlayer, "cmd:unban") ~= id then
				local ban = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..id.."'")
				if ban and ban['id'] and tonumber(ban['id']) then
					printBanInfo(thePlayer,ban)
					outputChatBox("You're about to remove this ban record. Please type /unban "..ban['id'].." once again to proceed.", thePlayer, 255, 194, 14)
					setElementData(thePlayer, "cmd:unban", ban['id'])
				end
			else
				local ban = mysql:query_fetch_assoc("SELECT * FROM bans WHERE id='"..id.."'")
				if ban and ban['id'] and tonumber(ban['id']) then
					lastBan = ban
					if lastBanTimer and isTimer(lastBanTimer) then
						killTimer(lastBanTimer)
						lastBanTimer = nil
					end
					lastBanTimer = setTimer(function()
						lastBan = nil
					end, 1000*60*5,1) --5 minutes
					if mysql:query_free("DELETE FROM bans WHERE id='"..id.."'") then
						for _, banElement in ipairs(getBans()) do
							if getBanSerial(banElement) == ban['serial'] or getBanIP(banElement) == ban['ip'] then
								removeBan(banElement)
								break
							end
						end
						if ban['account'] ~=mysql_null() then
							exports['admin-system']:addAdminHistory(ban['account'], thePlayer, "UNBAN", 2 , 0)
						end
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						exports.global:sendMessageToAdmins("[UNBAN] "..exports.global:getPlayerFullIdentity(thePlayer).." has removed ban record #"..ban['id']..". /showban for details.")
					end
				else
					outputChatBox("Opps, sorry that ban must have been lifted.", thePlayer, 255, 194, 14)
				end
			end
		end
	end
end
addCommandHandler("unban", unbanPlayer, false, false)

function checkForSerialOrIpBan(playerNick, playerIP, playerUsername, playerSerial, playerVersionNumber, playerVersionString)
	--serial + IP ban.
	local result = exports.mysql:query_fetch_assoc("SELECT * FROM bans WHERE serial='"..playerSerial.."' OR ip='"..playerIP.."' LIMIT 1")
	if result and result['id'] ~= mysql_null() then
		lastBan = result
		if lastBanTimer and isTimer(lastBanTimer) then
			killTimer(lastBanTimer)
			lastBanTimer = nil
		end
		lastBanTimer = setTimer(function()
			lastBan = nil
		end, 1000*60*5,1) --5 minutes
		local banText = "You are banned. Please appeal on https://ProjectReality.site"
		local bannedSerial = false
		local bannedIp = false
		if result['serial'] == playerSerial then
		 	banText = "Your serial is banned. Please appeal on https://ProjectReality.site"
		 	bannedSerial = playerSerial
		end
		if result['ip'] == playerIP then
			bannedIp = playerIP
			banText = "Your IP address is banned. Please appeal on https://ProjectReality.site"
		end
		cancelEvent(true, banText)
		exports.global:sendMessageToAdmins("[BAN] Rejected connection from"..(bannedSerial and (" serial: '"..tostring(bannedSerial).."'") or "" ).." "..(bannedIp and (" IP: '"..tostring(bannedIp).."'") or "")..". /showban for details.")
		return true
	end
	--IP range ban
	result = mysql:query("SELECT * FROM bans WHERE ip LIKE '%*%' ")
	while true do
		local ban = mysql:fetch_assoc(result)
		if not ban then break end
		if string.find( playerIP, "^" .. ban.ip .. "$" ) then
			lastBan = ban
			if lastBanTimer and isTimer(lastBanTimer) then
				killTimer(lastBanTimer)
				lastBanTimer = nil
			end
			lastBanTimer = setTimer(function()
				lastBan = nil
			end, 1000*60*5,1) --5 minutes
			cancelEvent(true, "Your IP address is rangebanned. Please appeal on https://ProjectReality.site")
			exports.global:sendMessageToAdmins("[RANGE-BAN] Rejected connection from IP: '"..playerIP.."' as range IP '"..ban.ip.."' is banned. /showban for details.")
			return true
		end
	end
	exports.mysql:free_result(result)
	return false
end
addEventHandler("onPlayerConnect", getRootElement(), checkForSerialOrIpBan)

function checkAccountBan(userid)
	local result = exports.mysql:query_fetch_assoc("SELECT * FROM bans WHERE account='"..userid.."' LIMIT 1")
	if result and result['id'] ~= mysql_null() then
		lastBan = result
		if lastBanTimer and isTimer(lastBanTimer) then
			killTimer(lastBanTimer)
			lastBanTimer = nil
		end
		lastBanTimer = setTimer(function()
			lastBan = nil
		end, 1000*60*5,1) --5 minutes
		exports.global:sendMessageToAdmins("[BAN] Rejected connection from account "..exports.cache:getUsernameFromId(userid).." as account is banned. /showban for details.")
		return true
	end
	return false
end

function showBanDetails(thePlayer, commandName, clue)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if clue then
			clue = exports.global:toSQL(clue)
			local bans = {}
			local banQuery = exports.mysql:query("SELECT * FROM bans WHERE id='"..clue.."' OR serial='"..clue.."' OR ip='"..clue.."' OR account=(SELECT a.id FROM accounts a WHERE a.username='"..clue.."')  ORDER BY date DESC")
			local count = 0
			while true do
				local row = exports.mysql:fetch_assoc(banQuery)
				if not row then break end
				table.insert(bans, row )
				count = count + 1
			end
			exports.mysql:free_result(banQuery)

			if count > 0 then
				outputChatBox("Found "..count.." ban records with keyword '"..clue.."'. Now fetching..", thePlayer, 255, 194, 14)
			else
				outputChatBox("There is no ban records with serial or IP or account name matched the keyword '"..clue.."'.", thePlayer, 255, 194, 14)
				return false
			end

			for i = 1, #bans do
				local result = bans[i]
				if result and result['id'] and tonumber(result['id']) then
					printBanInfo(thePlayer, result)
				else
					outputChatBox("Sorry, the ban you're looking for must have been lifted.", thePlayer, 255, 194, 14)
				end
			end
		elseif lastBan then
			printBanInfo(thePlayer, lastBan)
		else
			outputChatBox("SYNTAX: /" .. commandName .. " [Serial or IP or Username]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("showban", showBanDetails, false, false)
addCommandHandler("findban", showBanDetails, false, false)

function printBanInfo(thePlayer, result)
	outputChatBox("===========BAN RECORD #"..result['id'].."============", thePlayer, 255, 194, 14)

	local bannedAccount = exports.cache:getUsernameFromId(result['account'])
	outputChatBox("Account: "..(bannedAccount and bannedAccount or "N/A"), thePlayer, 255, 194, 14)

	local bannedSerial = nil
	if result['serial'] ~= mysql_null() then
		bannedSerial = result['serial']
	end
	outputChatBox("Serial: "..(bannedSerial and bannedSerial or "N/A"), thePlayer, 255, 194, 14)

	local bannedIp = nil
	if result['ip'] ~= mysql_null() then
		bannedIp = result['ip']
	end
	outputChatBox("IP: "..(bannedIp and bannedIp or "N/A"), thePlayer, 255, 194, 14)

	local banningAdmin = exports.cache:getUsernameFromId(result['admin'])
	outputChatBox("Banned by admin: "..(banningAdmin and banningAdmin or "N/A"), thePlayer, 255, 194, 14)

	local bannedDate = nil
	if result['date'] ~= mysql_null() then
		bannedDate = result['date']
	end
	outputChatBox("Banned Date: "..(bannedDate and bannedDate or "N/A"), thePlayer, 255, 194, 14)
	local bannedReason = nil
	if result['reason'] ~= mysql_null() then
		bannedReason = result['reason']
	end
	outputChatBox("Reason: "..(bannedReason and bannedReason or "N/A"), thePlayer, 255, 194, 14)
	local banThread = nil
	if result['threadid'] ~= mysql_null() then
		banThread = "http://forums.owlgaming.net/showthread.php/"..result['threadid']
	end
	outputChatBox("Ban thread: "..(banThread and banThread or "N/A"), thePlayer, 255, 194, 14)
end

function addToBan(account, serial, ip, admin, reason)
	local tail = ''
	if serial then
		tail = tail..", serial='"..serial.."'"
	end
	if ip then
		tail = tail..", ip='"..ip.."'"
	end
	if admin and tonumber(admin) then
		tail = tail..", admin='"..admin.."'"
	end
	if reason then
		tail = tail..", reason='"..exports.global:toSQL(reason).."'"
	else
		tail = tail..", reason='"..exports.global:toSQL("N/A").."'"
	end
	if account and tonumber(account) then
		tail = tail..", account='"..account.."'"
	end
	return mysql:query_insert_free("INSERT INTO bans SET date=NOW() "..tail)
end
