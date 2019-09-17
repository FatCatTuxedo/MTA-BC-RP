local outboundPhoneNumber = "Hidden Number"

function promptGUI(thePlayer)
	if exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) then
		triggerClientEvent(thePlayer, "buildGUI_npc911", getResourceRootElement())
	end
end
addCommandHandler("911", promptGUI)

function doTheCall(thePlayer, location, message)

	local playerStack = { }

	for key, value in ipairs( getPlayersInTeam(exports.factions:getTeamFromFactionID(80)) ) do
		table.insert(playerStack, value)
	end
	
	for key, value in ipairs( getPlayersInTeam(exports.factions:getTeamFromFactionID(1)) ) do
		table.insert(playerStack, value)
	end

	for key, value in ipairs( getPlayersInTeam(exports.factions:getTeamFromFactionID(2)) ) do
		table.insert(playerStack, value)
	end



	local affectedElements = { }

	for key, value in ipairs( playerStack ) do
		for _, itemRow in ipairs(exports['item-system']:getItems(value)) do
			local setIn = false
			if (not setIn) and (itemRow[1] == 6) then
				table.insert(affectedElements, value)
				setIn = true
				break
			end
		end
	end
	local query = exports.mysql:query_insert_free("INSERT INTO `mdc_calls` (`caller`,`number`,`description`) VALUES ('Unknown Person','"..outboundPhoneNumber.."','"..exports.mysql:escape_string(tostring(location) .. " - " .. message ).."')")
	local debug = exports.logs:dbLog(thePlayer, 4, "N/A", "911 NPC CALL - SIT: "..message.." -- LOC: "..tostring(location))
	for key, value in ipairs( affectedElements ) do
		triggerClientEvent(value, "phones:radioDispatchBeep", value)
		outputChatBox("[RADIO] This is dispatch, We've got an incident call from [NPC] #" .. outboundPhoneNumber .. ", over.", value, 0, 183, 239)
		outputChatBox("[RADIO] Situation: '" .. message .. "', over.", value, 0, 183, 239)
		outputChatBox("[RADIO] Location: '" .. tostring(location) .. "', out.", value, 0, 183, 239)
	end
end
addEvent("npc911", true)
addEventHandler("npc911", getResourceRootElement(), doTheCall)
