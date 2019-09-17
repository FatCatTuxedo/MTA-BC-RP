--MAXIME
function canPlayerCall(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local restrain = getElementData(thePlayer, "restrain") or 0
	local injuriedanimation = getElementData(thePlayer, "injuriedanimation")
	local reconx = getElementData(thePlayer, "reconx") 
	local calling = getElementData(thePlayer, "calling")
	local loggedin = getElementData(thePlayer, "loggedin")
	if restrain ~= 0 or phoneState > 0 or injuriedanimation or reconx or calling or isPedDead(thePlayer) or loggedin~=1 then
		return false
	end 
	return true
end

function canPlayerPhoneRing(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local reconx = getElementData(thePlayer, "reconx") 
	local calling = getElementData(thePlayer, "calling")
	if phoneState > 0 or reconx or calling then
		return false
	end 
	return true
end
function canPlayerAnswerCall(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local restrain = getElementData(thePlayer, "restrain") or 0
	local injuriedanimation = getElementData(thePlayer, "injuriedanimation")
	local reconx = getElementData(thePlayer, "reconx") 
	local called = getElementData(thePlayer, "called")
	local loggedin = getElementData(thePlayer, "loggedin")
	--outputDebugString(tostring(restrain))
	if restrain ~= 0 or phoneState ~= 3 or injuriedanimation or reconx or not called or isPedDead(thePlayer) or loggedin~=1 then
		return false
	end 
	return true
end

function canPlayerSlidePhoneIn(thePlayer)
	local phoneState = getElementData(thePlayer, "phonestate") or 0
	local restrain = getElementData(thePlayer, "restrain") or 0
	local injuriedanimation = getElementData(thePlayer, "injuriedanimation")
	local reconx = getElementData(thePlayer, "reconx") 
	local called = getElementData(thePlayer, "called")
	local loggedin = getElementData(thePlayer, "loggedin")
	--outputDebugString(tostring(restrain))
	if restrain ~= 0 or injuriedanimation or isPedDead(thePlayer) or loggedin~=1 then
		return false
	end 
	return true
end

function setED(e, i, n, s) 
	return setElementData(e, i, n, s)
end

function getED(e, i)
	return getElementData(e, i)
end

function isQuitType(action)
	return action == "Unknown" or action == "Quit" or action == "Kicked" or action == "Banned" or action == "Bad Connection" or action == "Timed out"
end

ringtones = {
	[1]	= "sounds/ringtones/viberate.mp3",
	[2]	= "sounds/ringtones/fireflies.mp3",
	[3] = "sounds/ringtones/turn_down_for_what.mp3",
	[4] = "sounds/ringtones/winggle_wiggle.mp3",
	[5]	= "sounds/ringtones/Standard_1.mp3",
	[6]	= "sounds/ringtones/Standard_2.mp3",
	[7] = "sounds/ringtones/bell.mp3",
	[8] = "sounds/ringtones/whistle.mp3",
	[9]	= "sounds/ringtones/good_news.mp3",
	[10]	= "sounds/ringtones/fuck_it_all.mp3",
	[11] = "sounds/ringtones/iphone_remix.mp3",
	[12] = "sounds/ringtones/idiot_calling.mp3",
	[13]	= "sounds/ringtones/popcorn.mp3",
	[14]	= "sounds/ringtones/smoke_weed.mp3",
	[15] = "sounds/ringtones/worth_it.mp3",
}

function removeNewLine(string)
	return string.gsub(string, "\n", " ")
end