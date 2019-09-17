local fireModel = 2023

function startTheFire (fX,fY,fZ)
    setTimer ( function()
		createFire(fX,fY,fZ,60)
	end, 420000, 1)
    outputDebugString("Creating Fire at x:"..fX.." y:"..fY.." z:"..fZ)

	local fire = engineLoadDFF("fire.dff",1)
	engineReplaceModel(fire,fireModel)
end
addEvent("startTheFire",true)
addEventHandler( "startTheFire", getRootElement(), startTheFire)
