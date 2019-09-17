local alarmSync = 60
local alarmTimers = {}

function carAlarm()
	if (isTimer(alarmTimers[source]) or not isVehicleLocked(source) or not exports['global']:hasItem(source, 130)) then return end
	local vx, vy, vz = getElementPosition(source)
	for i, player in pairs(getElementsByType("player")) do
		local px, py, pz = getElementPosition(player)
		local distance = getDistanceBetweenPoints3D(vx, vy, vz, px, py, pz)
		if (distance <= alarmSync) then
			triggerClientEvent(player, "onVehicleAlarm", source)
		end
	end
	alarmTimers[source] = setTimer(function() end, 10000, 1)
end
addEvent("checkCarAlarm", true)
addEventHandler("checkCarAlarm", root, carAlarm)
addEventHandler("onVehicleDamage", getRootElement(), carAlarm)

function stopCarAlarm(vehicle, player)
	if (isTimer(alarmTimers[source or player])) then return end
	if (not isElement(vehicle)) then return end
	local vx, vy, vz = getElementPosition(vehicle)
	for i, player in pairs(getElementsByType("player")) do
		local px, py, pz = getElementPosition(player)
		local distance = getDistanceBetweenPoints3D(vx, vy, vz, px, py, pz)
		if (distance <= alarmSync) then
			triggerClientEvent(player, "removeCarAlarm", vehicle)
		end
	end
	alarmTimers[source or player] = nil
end
addEvent("stopCarAlarm", true)
addEventHandler("stopCarAlarm", root, stopCarAlarm)