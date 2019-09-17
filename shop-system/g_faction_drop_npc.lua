--MAXIME
function canPlayerViewShop(thePlayer, theShop)
	local faction_access = getElementData(theShop, "faction_access") or 0
	if faction_access <= 0 then
		return isPlayerLeadAdmin(thePlayer)
	end
	local faction_belong = getElementData(theShop, "faction_belong") or 0
	local player_faction = getElementData(thePlayer, "faction") or -1
	if faction_belong == player_faction then
		if faction_access == 2 then
			return true
		elseif faction_access == 1 then
			local player_faction_leader = getElementData(thePlayer, "factionleader") or 0
			outputDebugString("player_faction_leader = "..tostring(player_faction_leader))
			if player_faction_leader == 1 then
				return true
			else
				return isPlayerLeadAdmin(thePlayer)
			end
		else
			return isPlayerLeadAdmin(thePlayer)
		end
	else
		return isPlayerLeadAdmin(thePlayer)
	end
	return false
end

function isPlayerLeadAdmin(thePlayer)
	if exports.integration:isPlayerSeniorAdmin(thePlayer) then
		outputChatBox("[SHOP] You have by-passed a security check. Reason: Lead Admin status", thePlayer, 255, 0 , 0)
		return true
	else
		return false
	end
end

function canPlayerAdminShop(thePlayer)
	return exports.integration:isPlayerSeniorAdmin(thePlayer)
end

function getFactionNameFromID(id)
	if not id or not tonumber(id) then
		return false
	end
	for i, faction in pairs(getElementsByType("team")) do
		if getElementData(faction, "id") == tonumber(id) then
			return getTeamName(faction)
		end
	end
	return false
end

function getFactionID(factionName)
	if factionName and isElement(factionName) and getElementType(factionName) == "team" then
		return getTeamName(faction)
	end
	
	for i, faction in pairs(getElementsByType("team")) do
		if getElementData(faction, "id") == tonumber(id) then
			return getTeamName(faction)
		end
	end
	return false
end

function getComboIndexFromFactionID(comboIndex, factionID)
	for i = 0, #comboIndex do
		if comboIndex[i][2] == factionID then
			return i
		end
	end
	return 0
end