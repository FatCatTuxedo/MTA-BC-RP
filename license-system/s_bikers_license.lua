mysql = exports.mysql

function giveBikeLicense(usingGC)
	if usingGC then
		local success, reason = exports.donators:takeGC(source, 1)
		if not success then
			exports.hud:sendBottomNotification(source, "Department of Motor Vehicles", "Could not take 1GC from your account. Reason: "..reason.."." )
			return false
		end
	end
	
	local theVehicle = getPedOccupiedVehicle(source)
	exports.anticheat:changeProtectedElementDataEx(source, "realinvehicle", 0, false)
	removePedFromVehicle(source)
	if theVehicle then
		respawnVehicle(theVehicle)
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "handbrake", 1, false)
		setElementFrozen(theVehicle, true)
	end
	
	exports.anticheat:changeProtectedElementDataEx(source, "license.bike", 1)
	mysql:query_free("UPDATE characters SET bike_license='1' WHERE charactername='" .. mysql:escape_string(getPlayerName(source)) .. "' LIMIT 1")
	exports.hud:sendBottomNotification(source, "Department of Motor Vehicles", "Congratulations! You've passed your motorcycle examination!" )
	exports.global:giveItem(source, 153, getPlayerName(source):gsub("_"," "))
	executeCommandHandler("stats", source, getPlayerName(source))
end
addEvent("acceptBikeLicense", true)
addEventHandler("acceptBikeLicense", getRootElement(), giveBikeLicense)

function passTheory()
	exports.anticheat:changeProtectedElementDataEx(source,"license.bike.cangetin",true, false)
	exports.anticheat:changeProtectedElementDataEx(source,"license.bike",3) -- Set data to "theory passed"
	mysql:query_free("UPDATE characters SET bike_license='3' WHERE charactername='" .. mysql:escape_string(getPlayerName(source)) .. "' LIMIT 1")
	exports.global:giveItem(source, 90, 1)
end
addEvent("theoryBikeComplete", true)
addEventHandler("theoryBikeComplete", getRootElement(), passTheory)

function checkDoLBikes(player, seat)
	if getElementData(source, "owner") == 0 and getElementData(source, "faction") == -1 and getElementModel(source) == 468 then
		if getElementData(player,"license.bike") == 3 then
			if getElementData(player, "license.bike.cangetin") then
				exports.hud:sendBottomNotification(player, "Department of Motor Vehicles", "You can use 'J' to start the engine and /kickstand prior to driving." )
			else
				exports.hud:sendBottomNotification(player, "Department of Motor Vehicles", "This vehicle is for the Driving Test only, please see the NPC inside first." )
				cancelEvent()
			end
		elseif seat > 0 then
			exports.hud:sendBottomNotification(player, "Department of Motor Vehicles", "This vehicle is for the Driving Test only." )
			--cancelEvent()
		else
			exports.hud:sendBottomNotification(player, "Department of Motor Vehicles", "This vehicle is for the Driving Test only." )
			cancelEvent()
		end
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), checkDoLBikes)