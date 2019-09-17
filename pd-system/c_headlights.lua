-- Strobes
local strobeTimers = {}

function strobeRepeater(vehicle, mode)
	if (isTimer(strobeTimers[vehicle])) then killTimer(strobeTimers[vehicle]) end
	local mode = tonumber(mode)
	if (mode == 1) or (not mode) then
		setVehicleHeadLightColor(vehicle, 0, 0, 255)
		setVehicleLightState(vehicle, 0, 1)
		setVehicleLightState(vehicle, 2, 1)
		strobeTimers[vehicle] = setTimer(function(vehicle)
			if (not isElement(vehicle)) then
				killTimer(strobeTimers[vehicle])
				strobeTimers[vehicle] = nil
			end
			
			local r, g, b = getVehicleHeadLightColor(vehicle)
			if (r > 1) then
				setVehicleHeadLightColor(vehicle, 0, 0, 255)
				setVehicleLightState(vehicle, 0, 1)
				setVehicleLightState(vehicle, 2, 1)
				setVehicleLightState(vehicle, 1, 0)
				setVehicleLightState(vehicle, 3, 0)
			else
				if (getElementData(vehicle, "faction") ~= 1) then
					setVehicleHeadLightColor(vehicle, 255, 0, 0)
				else
					setVehicleHeadLightColor(vehicle, 2, 0, 255)
				end
				setVehicleLightState(vehicle, 0, 0)
				setVehicleLightState(vehicle, 2, 0)
				setVehicleLightState(vehicle, 1, 1)
				setVehicleLightState(vehicle, 3, 1)
			end
		end, 200, 0, vehicle)
	elseif (mode == 3) then
		setVehicleHeadLightColor(vehicle, 0, 0, 255)
		setVehicleLightState(vehicle, 0, 1)
		setVehicleLightState(vehicle, 2, 1)
		strobeTimers[vehicle] = setTimer(function(vehicle)
			if (not isElement(vehicle)) then
				killTimer(strobeTimers[vehicle])
				strobeTimers[vehicle] = nil
			end
			
			local r, g, b = getVehicleHeadLightColor(vehicle)
			if (r == 254) then
				setVehicleHeadLightColor(vehicle, 255, 128, 0)
				setVehicleLightState(vehicle, 0, 1)
				setVehicleLightState(vehicle, 2, 1)
				setVehicleLightState(vehicle, 1, 0)
				setVehicleLightState(vehicle, 3, 0)
			else
				setVehicleHeadLightColor(vehicle, 254, 128, 0)
				setVehicleLightState(vehicle, 0, 0)
				setVehicleLightState(vehicle, 2, 0)
				setVehicleLightState(vehicle, 1, 1)
				setVehicleLightState(vehicle, 3, 1)
			end
		end, 200, 0, vehicle)
	elseif (mode == 4) then
		setVehicleHeadLightColor(vehicle, 0, 0, 255)
		setVehicleLightState(vehicle, 0, 1)
		setVehicleLightState(vehicle, 2, 1)
		strobeTimers[vehicle] = setTimer(function(vehicle)
			if (not isElement(vehicle)) then
				killTimer(strobeTimers[vehicle])
				strobeTimers[vehicle] = nil
			end
			
			local r, g, b = getVehicleHeadLightColor(vehicle)
			if (b == 1) then
				setVehicleHeadLightColor(vehicle, 255, 0, 0)
				setVehicleLightState(vehicle, 0, 1)
				setVehicleLightState(vehicle, 2, 1)
				setVehicleLightState(vehicle, 1, 0)
				setVehicleLightState(vehicle, 3, 0)
			else
				setVehicleHeadLightColor(vehicle, 255, 0, 1)
				setVehicleLightState(vehicle, 0, 0)
				setVehicleLightState(vehicle, 2, 0)
				setVehicleLightState(vehicle, 1, 1)
				setVehicleLightState(vehicle, 3, 1)
			end
		end, 200, 0, vehicle)
	elseif (mode == 5) then
		setVehicleHeadLightColor(vehicle, 0, 0, 255)
		setVehicleLightState(vehicle, 0, 1)
		setVehicleLightState(vehicle, 2, 1)
		strobeTimers[vehicle] = setTimer(function(vehicle)
			if (not isElement(vehicle)) then
				killTimer(strobeTimers[vehicle])
				strobeTimers[vehicle] = nil
			end
			
			local r, g, b = getVehicleHeadLightColor(vehicle)
			if (g == 1) then
				setVehicleHeadLightColor(vehicle, 255, 0, 255)
				setVehicleLightState(vehicle, 0, 1)
				setVehicleLightState(vehicle, 2, 1)
				setVehicleLightState(vehicle, 1, 0)
				setVehicleLightState(vehicle, 3, 0)
			else
				setVehicleHeadLightColor(vehicle, 255, 1, 255)
				setVehicleLightState(vehicle, 0, 0)
				setVehicleLightState(vehicle, 2, 0)
				setVehicleLightState(vehicle, 1, 1)
				setVehicleLightState(vehicle, 3, 1)
			end
		end, 200, 0, vehicle)
	elseif (mode) and (mode == 2) then
		setVehicleHeadLightColor(vehicle, 255, 255, 255)
		setVehicleLightState(vehicle, 0, 1)
		setVehicleLightState(vehicle, 2, 1)
		strobeTimers[vehicle] = setTimer(function(vehicle)
			if (not isElement(vehicle)) then
				killTimer(strobeTimers[vehicle])
				strobeTimers[vehicle] = nil
			end
			
			local state = getVehicleLightState(vehicle, 0)
			if (state == 0) then
				setVehicleLightState(vehicle, 0, 1)
				setVehicleLightState(vehicle, 2, 1)
				setVehicleLightState(vehicle, 1, 0)
				setVehicleLightState(vehicle, 3, 0)
			else
				setVehicleLightState(vehicle, 0, 0)
				setVehicleLightState(vehicle, 2, 0)
				setVehicleLightState(vehicle, 1, 1)
				setVehicleLightState(vehicle, 3, 1)
			end
		end, 100, 0, vehicle)
	end
end


addEvent("toggleEmergencyStrobes", true)
addEventHandler("toggleEmergencyStrobes", getRootElement(),
	function(vehicle)
		if (strobeTimers[vehicle]) then
			killTimer(strobeTimers[vehicle])
			strobeTimers[vehicle] = nil
		end
		
		if (getElementData(vehicle, "roleplay:vehicles.strobe.emergency")) then
			strobeRepeater(vehicle, 1)
		elseif (getElementData(vehicle, "roleplay:vehicles.strobe.orange")) then
			strobeRepeater(vehicle, 3)
		elseif (getElementData(vehicle, "roleplay:vehicles.strobe.medical")) then
			strobeRepeater(vehicle, 4)
		elseif (getElementData(vehicle, "roleplay:vehicles.strobe.funeral")) then
			strobeRepeater(vehicle, 5)
		else
			setVehicleHeadLightColor(vehicle, 255, 255, 255)
			setVehicleLightState(vehicle, 0, 0)
			setVehicleLightState(vehicle, 2, 0)
			setVehicleLightState(vehicle, 1, 0)
			setVehicleLightState(vehicle, 3, 0)
		end
	end
)