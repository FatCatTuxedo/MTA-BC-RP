--MAXIME

function blinkLightsAndSoundOnLockUnlock(theVehicle) -- maxime
	if getVehicleType(theVehicle) == "Automobile" then
		local speed = 500
		setVehicleOverrideLights ( theVehicle, 1 )
		setTimer(setVehicleOverrideLights, speed, 1, theVehicle, 2 )
		setTimer(setVehicleOverrideLights, speed*2, 1, theVehicle, 1)
		local x, y, z = getElementPosition(theVehicle)
		local int = getElementInterior(theVehicle)
		local dim = getElementDimension(theVehicle)
		triggerClientEvent("playCarToglockSoundFX", resourceRoot, {x, y, z, int, dim})
	end
end

function playCarToglockSoundFxInside(theVehicle, lockState)
	if getVehicleType(theVehicle) == "Automobile" then
		for i = 0, getVehicleMaxPassengers( theVehicle ) do
			local player = getVehicleOccupant( theVehicle, i )
			if player then
				triggerClientEvent(player, "playCarToglockSoundFxInside", player, lockState)
			end
		end
	end
end

local function playHorn ( thePlayer, key, keyState )
    local theVehicle = getPedOccupiedVehicle ( thePlayer )
    if ( not theVehicle ) then
       return
    end
     
    if ( getElementModel ( theVehicle ) == 537 ) or ( getElementModel( theVehicle ) == 538 ) then
        triggerClientEvent ( "vehicleHorn", root, ( keyState == "down" and true or false ), theVehicle )
    end
end

addEventHandler ( "onResourceStart", resourceRoot,
    function ( )
        for _, player in ipairs ( getElementsByType ( "player" ) ) do
            bindKey ( player, "H", "down", playHorn )
            bindKey ( player, "H", "up", playHorn )
        end
    end
    )
     
addEventHandler ( "onPlayerJoin", root,
    function ( )
        bindKey ( source, "H", "down", playHorn )
        bindKey ( source, "H", "up", playHorn )
    end
)