-- temporarily disable the engine - the server's event is triggered shortly after, though after some lag period.
addEventHandler('onClientPlayerVehicleEnter', localPlayer,
	function(vehicle, seat)
		if seat == 0 then
			--outputDebugString('client engine state')
			setVehicleEngineState(vehicle, false)
		end
	end)
