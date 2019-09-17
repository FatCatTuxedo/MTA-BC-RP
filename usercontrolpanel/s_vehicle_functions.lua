function getVehicleName(vehID)
	--outputDebugString("0")
	if not vehID then
		--outputDebugString("1")
		return "?"
	end
	if not tonumber(vehID) then
		--outputDebugString("2")
		return "?"
	end
	
	vehID = tonumber(vehID)
	local theVehicle = exports.pool:getElement("vehicle", vehID)
	if not theVehicle then
		--outputDebugString("3")
		return "?"
	end
	--outputDebugString("4")
	return exports.global:getVehicleName(theVehicle)
end