local intens = 1500 -- Determines the maximum darkness

setFogDistance(0)
resetSkyGradient()
lock_color = false
bx, by, bz, ax, ay, az =  168, 135, 84, 136, 91, 61

function clr(a, t)
	return (a - (a*(t-20)/3))
end

function uclr(a, t)
	return (a*(t-2)/3)
end

function timeInterval()
	if (getMinuteDuration() >= 100) then
		return getMinuteDuration()
	else
		return 100
	end
end

setTimer(function()
	local h, m = getTime()
	local th = h + (m /60)
	local tm = m + (h * 60)
	if (th >= 21 and th <= 3) then
		setFogDistance(-intens)
		setSkyGradient(0, 0, 0, 0, 0, 0)
	else
		resetSkyGradient()
		setFogDistance(0)
	end
end, timeInterval(), 0)