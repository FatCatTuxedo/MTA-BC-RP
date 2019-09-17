mysql = exports.mysql

function giveBoatLicense(usingGC)
	if usingGC then
		local success, reason = exports.donators:takeGC(source, 1)
		if not success then
			exports.hud:sendBottomNotification(source, "Department of Motor Vehicles", "Could not take 1GC from your account. Reason: "..reason.."." )
			return false
		end
	end
	
	mysql:query_free("UPDATE characters SET boat_license='1' WHERE charactername='" .. mysql:escape_string(getPlayerName(source)) .. "' LIMIT 1")
	exports.anticheat:changeProtectedElementDataEx(source, "license.boat", 1)
	exports.hud:sendBottomNotification(source, "Department of Motor Vehicles", "Congratulations! You are now fully licensed captain a boat on the water." )
	exports.global:giveItem(source, 155, getPlayerName(source):gsub("_"," "))
	executeCommandHandler("stats", source, getPlayerName(source))
end
addEvent("acceptBoatLicense", true)
addEventHandler("acceptBoatLicense", getRootElement(), giveBoatLicense)