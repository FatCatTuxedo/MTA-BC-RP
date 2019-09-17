function givedonPoint(thePlayer, commandName, targetPlayer, donPoints, ...)
	if exports.integration:isPlayerSeniorAdmin(thePlayer) then
		if (not targetPlayer or not donPoints or not (...)) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player] [GCs] [Reason]", thePlayer, 255, 194, 14)
		else
			
			local tplayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if (tplayer) then
				local loggedIn = getElementData(tplayer, "loggedin")
				if loggedIn == 1 then
					donPoints = tonumber(donPoints)
					if not donPoints or donPoints <= 0 then
						outputChatBox("You can not give a negative amount of GCs.", thePlayer, 255, 0, 0)
						return false
					end
					donPoints = math.floor(donPoints)
					local reasonStr = table.concat({...}, " ")
					local accountID = getElementData(tplayer, "account:id")
					
					local playerName = exports.global:getPlayerFullIdentity(thePlayer,1)
					local targetName = exports.global:getPlayerFullIdentity(tplayer, 1)
					local targetNameFull = exports.global:getPlayerFullIdentity(tplayer)
					
					exports.achievement:awardPlayer(tplayer, "FREE GAMECOINS AWARD! ("..string.upper(playerName)..")", reasonStr, donPoints)
					
					outputChatBox("You gave "..targetName.." "..donPoints.." GameCoins for: ".. reasonStr, thePlayer)
					
					local targetUsername = string.gsub(getElementData(tplayer, "account:username"), "_", " ")
					local username = string.gsub(getElementData(thePlayer, "account:username"), "_", " ")
					targetUsername = mysql:escape_string(targetUsername)
					local targetCharacterName = mysql:escape_string(targetPlayerName)
					
					local title = "[GAMECOINS] " .. username .. " has given " .. donPoints .. " GC to " .. targetNameFull .. "."
					local content = "<b>Admin:</b>" .. username .. "<br><b>Gave Game Coins money to username:</b>" .. targetUsername .. "<br><b>Character Name:</b>" .. targetCharacterName .. "<br><b>Amount:</b>" .. donPoints .. " GC<br><b>Reason:</b>" .. mysql:escape_string(reasonStr) .. "<br><br><u><i>Note: " .. username .. ", please reply to this post with additional information. This is mandatory.</i></u>"
					exports["integration"]:createForumThread(thePlayer, thePlayer, 103, title, content, "Please make a reply to this post with any additional information you may have") 
					exports.global:sendMessageToAdmins("[GAMECOINS] " .. playerName .. " has given "..donPoints.." GC to "..targetNameFull..".")
					exports.global:sendMessageToAdmins("Reason: "..reasonStr..".")
					exports.global:sendMessageToAdmins("Info: https://projectreality.site/forumdisplay.php?fid=103")
				else
					outputChatBox("This player is not logged in.", thePlayer)
				end
			else
				outputChatBox("Something went wrong with picking the player.", thePlayer)
			end
		end
	end
end
addCommandHandler("givegc", givedonPoint, false, false)
addCommandHandler("givegamecoins", givedonPoint, false, false)
addCommandHandler("givegamecoin", givedonPoint, false, false)