--client
function notifyAnFdMember() 
	outputChatBox("[BEEPER] " .. exports.global:getPlayerName(source) .. " has triggered the LSFD-wide alarm.",245, 40, 135)
end
addEvent("notifyAnFdMember", true)
addEventHandler("notifyAnFdMember", root, notifyAnFdMember) 

function playAlarmAroundTheArea()
	playSound3D("alarm.mp3", 1721.361328125, -1120.359375, 24.085935592651)
end
addEvent("playAlarmAroundTheArea", true)
addEventHandler("playAlarmAroundTheArea", root, playAlarmAroundTheArea)

function playPagerSfxAround()
	local x, y, z = getElementPosition(source)
	local pagerSound = playSound3D("pager.mp3", x, y, z) -- Here. Doesnt get the x y z.
	setSoundVolume(pagerSound, 0.8)
end
addEvent("playPagerSfxAround", true)
addEventHandler("playPagerSfxAround", root, playPagerSfxAround)  

--
-- This is where I get most problems. What it is supposed to do: play alarm.mp3 at fire station, and play pager.mp3 at every FD members coordinates (as well as outputChatBox to all FD members)

-- What it does right now: plays sound at FD, sends outputChatBox TWICE and doesn't play pager because it does not get the fd members coordinates.k