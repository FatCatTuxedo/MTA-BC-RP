-- MAXIME 2015.1.26

function getTeamFromFactionID(factionID)
	if not tonumber(factionID) then
		return false
	end
	for i, faction in pairs(getElementsByType("team")) do
		if(tonumber(getElementData(faction, "id")) == tonumber(factionID)) then
			--outputDebugString(factionID.."-"..getTeamName(faction))
			return faction
		end
	end
	return false
end