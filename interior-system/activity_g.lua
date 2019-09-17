--MAXIME / 2015.01.07
function isActive(interiorElement)
	return true 
end

function isProtected(interiorElement)
	local interiorStatus = getElementData(interiorElement, "status")
	local interiorType = interiorStatus[INTERIOR_TYPE] or 2
	local interiorOwner = interiorStatus[INTERIOR_OWNER] or 0
	local interiorFaction = interiorStatus[INTERIOR_FACTION] or 0
	if interiorType == 2 or interiorFaction > 0  or interiorOwner < 1 then
		return false
	end
	local protected_until = getElementData(interiorElement, "protected_until") or -1
	local protectText, protectSeconds = exports.datetime:formatFutureTimeInterval(protected_until)
	return protectSeconds > 0, protectText, protectSeconds
end