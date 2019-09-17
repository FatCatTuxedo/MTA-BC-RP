function playSoundFX(theTruck)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(theTruck)
	
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 30 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(theTruck) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "truckerjob:playSoundFX", theTruck)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end