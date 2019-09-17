function toggleWindow(thePlayer)
	if not thePlayer then
		thePlayer = source
	end
	
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if theVehicle then
		if hasVehicleWindows(theVehicle) then
			if (getVehicleOccupant(theVehicle) == thePlayer) or (getVehicleOccupant(theVehicle, 1) == thePlayer) then
				if not (isVehicleWindowUp(theVehicle)) then
					exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:windowstat", 0, true)
					triggerEvent('sendAme', thePlayer, "rolls their windows up.")
					for i = 0, getVehicleMaxPassengers(theVehicle) do
						local player = getVehicleOccupant(theVehicle, i)
						if (player) then
							triggerClientEvent(player, "updateWindow", theVehicle)
							triggerEvent("setTintName", player)
						end
					end
				else
					exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:windowstat", 1, true)
					triggerEvent('sendAme', thePlayer, "rolls their windows down.")
					for i = 0, getVehicleMaxPassengers(theVehicle) do
						local player = getVehicleOccupant(theVehicle, i)
						if (player) then
							triggerClientEvent(player, "updateWindow", theVehicle)
							triggerEvent("resetTintName", theVehicle, player)
						end
					end
				end
			end
		end
	end
end
addEvent("vehicle:togWindow", true)
addEventHandler("vehicle:togWindow", root, toggleWindow)
addCommandHandler("togwindow", toggleWindow)
