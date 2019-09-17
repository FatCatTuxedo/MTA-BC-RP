local carAlarms = {}
local lightTimers = {}
local antiSpam

local oldTask = ""
local theVehicle = nil
function checkAlarm()
	task = getPedSimplestTask(getLocalPlayer())
	if task ~= oldTask then
		if theVehicle then
			if task == "TASK_SIMPLE_CAR_OPEN_LOCKED_DOOR_FROM_OUTSIDE" then
				triggerServerEvent("checkCarAlarm", theVehicle)
				theVehicle = nil
			elseif task == "TASK_SIMPLE_PLAYER_ON_FOOT" or task == "TASK_SIMPLE_CAR_GET_IN" then
				theVehicle = nil
			end
		end
		oldTask = task
	end
end
addEventHandler("onClientRender", getRootElement(), checkAlarm)

function updateCar(thePlayer)
	if thePlayer == getLocalPlayer() then
		theVehicle = source
	end
end
addEventHandler("onClientVehicleStartEnter", getRootElement(), updateCar)

function carAlarm()
	local vx, vy, vz = getElementPosition(source)
	carAlarms[source] = playSound3D("carAlarm.mp3", vx, vy, vz, true)
	setSoundMaxDistance(carAlarms[source], 75)
	setSoundVolume(carAlarms[source], 0.4)
	attachElements(carAlarms[source], source)
	addEventHandler("onClientElementDestroy", source, stopCarAlarm)
	lightTimers[source] = setTimer(toggleLights, 1000, 10, source)
	setTimer(stopCarAlarm, 10000, 1, source)
end
addEvent("onVehicleAlarm", true)
addEventHandler("onVehicleAlarm", root, carAlarm)

function stopCarAlarm(vehicle)
	if (not (isElement(vehicle or source) and carAlarms[vehicle or source])) then return end
	if (isTimer(lightTimers[vehicle or source])) then
		killTimer(lightTimers[vehicle or source])
	end
	if (isElement(carAlarms[vehicle or source])) then
		stopSound(carAlarms[vehicle or source])
	end
	removeEventHandler("onClientElementDestroy", vehicle or source, stopCarAlarm)
end
addEvent("removeCarAlarm", true)
addEventHandler("removeCarAlarm", root, stopCarAlarm)

function toggleLights(theVehicle)
	if (not isElement(theVehicle)) then return end
	local lightState = getVehicleOverrideLights(theVehicle)
	if (lightState == 0 or lightState == 1) then
		setVehicleOverrideLights(theVehicle, 2)
	else
		setVehicleOverrideLights(theVehicle, 1)
	end
end