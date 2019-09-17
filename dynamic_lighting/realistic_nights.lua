-- local intens = 1700 -- Determines the maximum darkness

-- function checkTime()
	-- local hour, minutes = getTime()
	-- if (hour>=21 or hour<4) then
		-- setFogDistance(-intens)
		-- setSkyGradient(0, 0, 0, 0, 0, 0)
	-- else
		-- setFogDistance(0)
		-- resetSkyGradient()
	-- end
-- end

-- addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	-- setFogDistance(0)
	-- resetSkyGradient()
	-- checkTime()
	-- setTimer(checkTime, 3000, 0)
-- end
-- )


function isInNightTime()
	local hour, minutes = getTime()
	return (hour>=21 or hour<4)
end

setFogDistance(0)
		resetSkyGradient()