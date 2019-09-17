local distance = 50

function clearAme ( thePlayer )
	triggerClientEvent("clearAme", getRootElement(), thePlayer)
end
addCommandHandler("clear", clearAme, false, false)
addCommandHandler("clearame", clearAme, false, false)

function sendAme( thePlayer, commandName, ... )
	if not (...) then
		outputChatBox("SYNTAX: /ame [Action]", thePlayer, 255, 194, 14)
		return false
	end
	
	local name = getPlayerName(thePlayer)
	local message = table.concat({...}, " ")



	if getElementData(thePlayer, "ameSpam") == message then
		outputChatBox("SPAM: Your /ame has not been shown to prevent spam. Try again in a few seconds.", thePlayer, 255, 0, 0)
		return nil
	else
		setElementData(thePlayer, "ameSpam", message)
		setTimer( function()
			setElementData(thePlayer, "ameSpam", nil)
		end, 5000, 1)
		local state, affectedPlayers = sendToNearByClients(thePlayer, "*" ..  name.. ( message:sub( 1, 1 ) == "'" and "" or " " ) .. message.."*")
		return state, affectedPlayers
	end
end
addCommandHandler("ame", sendAme)
addEvent("sendAme", true)
addEventHandler("sendAme", getRootElement(),
	function(message)
		return sendToNearByClients(source, "*" ..  getPlayerName(source) .. ( message:sub( 1, 1 ) == "'" and "" or " " ) .. message.."*")
	end)

function sendToNearByClients(root, message)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(root)
	
	if getElementType(root) == "player" and exports['freecam-tv']:isPlayerFreecamEnabled(root) then return end
	
	local shownto = 0
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < ( distance or 20 ) then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(root) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer,"onClientAme", root, message)
				table.insert(affectedPlayers, nearbyPlayer)
				shownto = shownto + 1
				if nearbyPlayer~=root then
					outputConsole(message, nearbyPlayer)
				end
			end
		end
	end
	
	outputChatBox(message, root)
	
	if shownto > 0  then 
		exports.logs:dbLog(root, 40, affectedPlayers, message)
		return true, affectedPlayers
	else
		return false, false
	end
	
end
addEvent("sendToNearByClients", true)
addEventHandler("sendToNearByClients", getRootElement(), sendToNearByClients)

local gpn = getPlayerName
function getPlayerName(p)
	local name = getElementData(p, "fakename") or gpn(p) or getElementData(p, "name")
	return string.gsub(name, "_", " ")
end