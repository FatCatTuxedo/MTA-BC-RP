setBlurLevel(0)

local sounds = { }
local localPlayer = getLocalPlayer ( )
-- Bind Keys required
function bindKeys(res)
	bindKey("n", "down", toggleSirens)
	bindKey(",", "down", cycleSirens)
	for key, value in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(value) then
			if (getElementData(value, "lspd:siren") == nil) and getElementData(value, "lspd:siren") ~= 0 then
				sounds[value] = playSound3D("siren" .. getElementData( v, "lspd:siren" ) ..".wav", 0, 0, 0, true)
				attachElements( sounds[value], value )
				setSoundVolume(sounds[value], 0.65)
				setSoundMaxDistance(sounds[value], 275)
				setElementDimension(sounds[value], getElementDimension(value))
				setElementInterior(sounds[value], getElementInterior(value))

			end
		end
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), bindKeys)

function toggleSirens()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if getPedOccupiedVehicleSeat(getLocalPlayer()) > 1 then return end
	if (theVehicle) then
		triggerServerEvent("lspd:setSirenState", theVehicle, localPlayer)
	end
end
addCommandHandler("togglesirens", toggleSirens, false)

function cycleSirens()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if getPedOccupiedVehicleSeat(getLocalPlayer()) > 1 then return end
	if (theVehicle) then
		triggerServerEvent("lspd:cycleSirenState", theVehicle, localPlayer)
	end
end
addCommandHandler("cyclesirens", cycleSirens, false)

function streamIn()
	if (getElementData(source, "lspd:siren") == nil) and getElementData(source, "lspd:siren") ~= 0 and not sounds[ source ] then
		sounds[source] = playSound3D("siren" .. getElementData( source, "lspd:siren" ) ..".wav", 0, 0, 0, true)
		attachElements( sounds[source], source )
		setSoundVolume(sounds[source], 0.65)
		setSoundMaxDistance(sounds[source], 275)
		setElementDimension(sounds[source], getElementDimension(source))
		setElementInterior(sounds[source], getElementInterior(source))
	end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamIn)

function streamOut()
	if getElementType( source ) == "vehicle" and sounds[source] then
		destroyElement( sounds[ source ] )
		sounds[ source ] = nil
	end
end
addEventHandler("onClientElementStreamOut", getRootElement(), streamOut)

function UpdateSiren( name )
	if name == "lspd:siren" and getElementType( source ) == "vehicle" then
		if getElementData( source, name ) == 0 then
			if sounds[ source ] then
				destroyElement( sounds[ source ] )
				sounds[ source ] = nil
			end
		else
			if sounds[ source ] then
				destroyElement( sounds[ source ] )
				sounds[ source ] = nil
			end
			sounds[source] = playSound3D("siren" .. getElementData( source, "lspd:siren" ) ..".wav", 0, 0, 0, true)
			attachElements( sounds[source], source )
			setSoundVolume(sounds[source], 0.65)
			setSoundMaxDistance(sounds[source], 275)
			setElementDimension(sounds[source], getElementDimension(source))
			setElementInterior(sounds[source], getElementInterior(source))
		end
	end
end
addEventHandler("onClientElementDataChange", getRootElement(), UpdateSiren)