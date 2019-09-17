function showBox(player, value, str)
	if isElement(player) then
		triggerClientEvent(player, "CreateBox", getRootElement(), value, str)
	end
end

function alertPlayer(thePlayer, commandName, targetPlayer, message)
	if not (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		outputChatBox("No access.", thePlayer)
	else
		if not (targetPlayer) or not (message) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Message]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				--showBox(targetPlayer, "Alert from: "..exports.global:getPlayerAdminTitle(thePlayer), message)
				triggerClientEvent(targetPlayer, "CreateBox", thePlayer, "Alert from: "..exports.global:getPlayerAdminTitle(thePlayer), message)
			end
		end
	end
end
addCommandHandler("alert", alertPlayer)