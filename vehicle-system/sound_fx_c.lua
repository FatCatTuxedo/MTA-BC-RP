--MAXIME

function playCarToglockSoundFX(location)
	local sound = playSound3D("CarAlarmChirp.mp3", location[1], location[2], location[3]) 
	if sound then
		setSoundMaxDistance( sound, 50 )
		setSoundVolume(sound, 0.7)
		setElementInterior(sound, location[4])
		setElementDimension(sound, location[5])
	end
end
addEvent("playCarToglockSoundFX", true)
addEventHandler("playCarToglockSoundFX", resourceRoot, playCarToglockSoundFX) 

function playCarToglockSoundFxInside(lockState)
	local sound = playSound(lockState and "car_lock_inside.mp3" or "car_unlock_inside.mp3") 
	--[[
	if sound then
		setSoundVolume(sound, 0.7)
	end
	]]
end
addEvent("playCarToglockSoundFxInside", true)
addEventHandler("playCarToglockSoundFxInside", localPlayer, playCarToglockSoundFxInside) 

addEvent ( "vehicleHorn", true )
addEventHandler ( "vehicleHorn", root,
    function ( state, theVehicle )
        if isElement ( TrainSound ) and ( state ) then
        	if isTimer(decrease) then
        		killTimer(decrease)
        	end
        	destroyElement(TrainSound)
        end

        if not ( state ) then
        	decrease = setTimer(function() 
        		local time, final = getTimerDetails(decrease)
        		if isElement(TrainSound) then
        			if final ~= 1 then
        				local volume = getSoundVolume(TrainSound); 
        				setSoundVolume(TrainSound, volume-0.5); 
        			else
        				destroyElement(TrainSound)
        			end
        		end

        		end, 300, 10)
        end
            --stopSound ( TrainSound )
        if ( state ) then
            local x, y, z = getElementPosition ( theVehicle )
            TrainSound = playSound3D ( 'trainHorn.mp3', x, y, z )
            setSoundVolume ( TrainSound, 5.0 )
            setSoundMaxDistance ( TrainSound, 190 )
            attachElements ( TrainSound, theVehicle )
        end
    end
)