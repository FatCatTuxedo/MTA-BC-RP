--Maxime

function setEld(thePlayer, index, newvalue, sync)
	local sync2 = false
	local nosyncatall = true
	if sync == "one" then
		sync2 = false
		nosyncatall = false
		setElementdata(thePlayer, index, newvalue)
	elseif sync == "all" then
		sync2 = true
		nosyncatall = false
	else
		return setElementdata(thePlayer, index, newvalue)
	end
	return triggerServerEvent("anticheat:changeEld", thePlayer, index, newvalue, sync2, nosyncatall)
end