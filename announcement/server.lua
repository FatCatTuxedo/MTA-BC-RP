--MAXIME
mysql = exports.mysql

function setServerIP(thePlayer, commandName, ...)
	if (exports.integration:isPlayerSeniorAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: " .. commandName .. " [message]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local query = mysql:query_free("UPDATE `settings` SET `value`='" .. mysql:escape_string(message) .. "' WHERE `name`='serverip'")
			if (query) then
				outputChatBox("Server IP is set to '" .. message .. "'.", thePlayer, 0, 255, 0)
				exports.logs:dbLog(thePlayer, 4, thePlayer, "SETSERVERIP "..message)
				exports.anticheat:changeProtectedElementDataEx(getRootElement(), "serverip", message, false )
			else
				outputChatBox("Failed to set server IP.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("setserverip", setServerIP, false, false)

function adminAnnouncement(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")
	
	if(logged==1) and (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer))  then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			if (getElementData(thePlayer, "hiddenadmin") == 0) then
				message = table.concat({...}, " ") .. " - " .. exports.global:getPlayerAdminTitle(thePlayer)
			end
			local players = exports.pool:getPoolElementsByType("player")
			local username = getPlayerName(thePlayer)

			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				if exports.integration:isPlayerScripter(thePlayer) then
					triggerClientEvent(arrayPlayer,"announcement:post", arrayPlayer, "Developer Announcement: " .. message, 255,20,147, 1)
				elseif exports.integration:isPlayerLeadAdmin(thePlayer) then
					triggerClientEvent(arrayPlayer,"announcement:post", arrayPlayer, "SMT Announcement: " .. message, 255,0,0, 1)
				elseif exports.integration:isPlayerTrialAdmin(thePlayer) then
					triggerClientEvent(arrayPlayer,"announcement:post", arrayPlayer, "Admin Announcement: " .. message, 14,194,255, 1)
				elseif exports.integration:isPlayerSupporter(thePlayer) then
					triggerClientEvent(arrayPlayer,"announcement:post", arrayPlayer, "Helper Announcement: " .. message, 70, 200, 30, 1)
				end
				local url = exports.global:getUrlFromString(message)
				if url then
					exports.help:startUrlSender(thePlayer, "url", arrayPlayer, url)
				end
			end
			exports.logs:dbLog(thePlayer, 4, thePlayer, "ANN "..message)
			--exports.text2speech:convertTextToSpeech(root, message, "en", nil, 1, 50, 1) 
		end
	end
end
addCommandHandler("ann", adminAnnouncement, false, false)

function sendTopNotification(sendTo, msg, r, b, g, playsound)
	triggerClientEvent(sendTo,"announcement:post", sendTo, msg, r, b, g, playsound)
end