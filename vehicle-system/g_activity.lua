--MAXIME / 2015.1.29

function isActive(veh)
	return true 
end

function isProtected(veh)
	local job = getElementData(veh, "job") or 0
	local owner = getElementData(veh, "owner") or -1
	local faction = getElementData(veh, "faction") or -1
	if job ~= 0 or owner <= 0 or faction ~= -1 then
		return false
	end
	local protected_until = getElementData(veh, "protected_until") or -1
	local protectText, protectSeconds = exports.datetime:formatFutureTimeInterval(protected_until)
	return protectSeconds > 0, protectText, protectSeconds
end