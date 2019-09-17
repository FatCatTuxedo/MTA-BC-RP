--MAXIME
function now()
	local timePassed = math.floor((getRealTime().timestamp - lastTime))
	--outputChatBox(timePassed)
	return serverCurrentTimeSec + timePassed
end

function formatTimeInterval( timeInseconds )
	if type( timeInseconds ) ~= "number" then
		return timeInseconds, 0
	end
	
	local seconds = now()-timeInseconds
	if seconds < 1 then
		return "Just now", 0
	end
	
	if seconds < 60 then
		return formatTimeString( seconds, "second" ).." ago", seconds
	end
	
	local minutes = math.floor( seconds / 60 )
	if minutes < 60 then
		return formatTimeString( minutes, "m" ) .. " " .. formatTimeString( seconds - minutes * 60, "s" ).." ago" , seconds
	end
	
	local hours = math.floor( minutes / 60 )
	if hours < 48 then
		return formatTimeString( hours, "h" ) .. " " .. formatTimeString( minutes - hours * 60, "m" ).." ago", seconds
	end
	
	local days = math.floor( hours / 24 )
	return formatTimeString( days, "day" ).." ago", seconds
end

function formatFutureTimeInterval( timeInseconds )
	if type( timeInseconds ) ~= "number" then
		return timeInseconds, 0
	end
	
	local seconds = timeInseconds-now()
	if seconds < 0 then
		return "0s", 0
	end
	
	if seconds < 60 then
		return formatTimeString( seconds, "second" ), seconds
	end
	
	local minutes = math.floor( seconds / 60 )
	if minutes < 60 then
		return formatTimeString( minutes, "m" ) .. " " .. formatTimeString( seconds - minutes * 60, "s" ), seconds
	end
	
	local hours = math.floor( minutes / 60 )
	if hours < 48 then
		return formatTimeString( hours, "h" ) .. " " .. formatTimeString( minutes - hours * 60, "m" ), seconds
	end
	
	local days = math.floor( hours / 24 )
	return formatTimeString( days, "day" ), seconds
end

function formatTimeString( time, unit )
	if time == 0 then
		return ""
	end
	if unit == "day" or unit == "hour" or unit == "minute" or unit == "second" then
		return time .. " " .. unit .. ( time ~= 1 and "s" or "" )
	else
		return time .. "" .. unit-- .. ( time ~= 1 and "s" or "" )
	end
end

function minutesToDays(minutes) 
	local oneDay = minutes*60*24
	return math.floor(minutes/oneDay)
end	

function formatSeconds(seconds)
	if type( seconds ) ~= "number" then
		return seconds
	end
	
	if seconds <= 0 then
		return "Now"
	end
	
	if seconds < 60 then
		return formatTimeString( seconds, "second" )
	end
	
	local minutes = math.floor( seconds / 60 )
	if minutes < 60 then
		return formatTimeString( minutes, "minute" ) .. " " .. formatTimeString( seconds - minutes * 60, "second" )
	end
	
	local hours = math.floor( minutes / 60 )
	if hours < 48 then
		return formatTimeString( hours, "hour" ) .. " " .. formatTimeString( minutes - hours * 60, "minute" )
	end
	
	local days = math.floor( hours / 24 )
	return formatTimeString( days, "day" )
end