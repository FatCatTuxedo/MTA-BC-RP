ggun_enabled = {}

function togglePlayerGravityGun(player,on)
	if not (isElement(player) and getElementType(player) == "player") then return false end
	if on ~= true and on ~= false then return false end
	if ggun_enabled[player] == (on == true) then return false end
	ggun_enabled[player] = on == true
	if on then
		setElementData(player,"ggun_taken",true)
	else
		removeElementData(player,"ggun_taken")
	end
	toggleControl(player,"fire",not on)
	return true
end

function gguncmd(thePlayer, commandName)
	if exports.integration:isPlayerScripter(thePlayer) then
		
		if (isGravityGunEnabled(thePlayer)) then
			togglePlayerGravityGun (thePlayer, false)
			outputChatBox("GG disabled", thePlayer, 255,0 ,0 )
			return false
		else
			togglePlayerGravityGun (thePlayer, true)
			outputChatBox("GG enabled", thePlayer, 0,255 ,0 )
			return true
		end
	end
end
addCommandHandler("ggun", gguncmd, false, false)

function musc(thePlayer, cmd)
	if exports.integration:isPlayerScripter(thePlayer) then
		setPedStat(thePlayer, 23, 1000)
	end
end
addCommandHandler("musc", musc, false, false)

function fat(thePlayer, cmd)
	if exports.integration:isPlayerScripter(thePlayer) then
		setPedStat(thePlayer, 21, 1000)
	end
end
addCommandHandler("fat", fat, false, false)

function week(thePlayer, cmd)
	if exports.integration:isPlayerScripter(thePlayer) then
		setPedStat(thePlayer, 23, 100)
	end
end
addCommandHandler("week", week, false, false)

function slim(thePlayer, cmd)
	if exports.integration:isPlayerScripter(thePlayer) then
		setPedStat(thePlayer, 21, 100)
	end
end
addCommandHandler("slim", slim, false, false)

function isGravityGunEnabled(player)
	return ggun_enabled[player] or false
end

addEventHandler("onPlayerQuit",root,function()
	ggun_enabled[source] = nil
end)

addEvent("ggun_take",true)
addEventHandler("ggun_take",root,function()
	if not isElement(getElementData(source,"ggun_taker")) and not isElement(getElementData(client,"ggun_taken")) then
	
		setElementData(client,"ggun_taken",source)
		setElementData(source,"ggun_taker",client)
	end
end)

addEvent("ggun_drop",true)
addEventHandler("ggun_drop",root,function()
	removeElementData(getElementData(client,"ggun_taken"),"ggun_taker")
	setElementData(client,"ggun_taken",true)
end)

addEvent("ggun_push",true)
addEventHandler("ggun_push",root,function(vx,vy,vz)
	local taker = getElementData(source,"ggun_taker")
	if isElement(taker) then setElementData(taker,"ggun_taken",true) end
	removeElementData(source,"ggun_taker")
	setElementVelocity(source,vx,vy,vz)
end)