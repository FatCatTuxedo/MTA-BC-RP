
thisResource = getResourceRootElement (getThisResource())

--LOAD ALL NEWS STANDS AROUND FORT CARSON WHEN THE SCRIPT IS LOADED.
function createStandFunc()
local standMachines = getElementsByType ("stand", thisResource)
num=0
mnum=0
id=0
standMachine = { }
standMarker = { }
standID = { }
	for key,val in ipairs(standMachines) do
		num=num+1
		mnum=mnum+1
		id=id+1
		standX= getElementData(val, "posX")
		standY= getElementData(val, "posY")
		standZ= getElementData(val, "posZ")
		standRotZ= getElementData(val, "standRotZ")
		standMachine[num] = createObject (1285, standX, standY, standZ-0.45, 0, 0, standRotZ)
		standMarker[mnum] = createMarker(standX, standY, standZ-1, "cylinder", 1.5, 255, 200, 0, 0, getRootElement())
		setElementRotation(standMachine[num], 0, 0, standRotZ)
		setElementData(standMachine[num], "id", tonumber(id), true)
		setElementData(standMarker[mnum], "newsMarker", true)
	end
end
addEventHandler("onResourceStart", thisResource, createStandFunc)

function newsStuff(hitElement, matchingDimension)
	if (getElementType(hitElement) == "player" ) and (getElementData(source, "newsMarker") == true ) then
	outputChatBox("* Press 'H' to buy a news paper (Cost: 4$)", hitElement, 0, 255, 0, false)
	bindKey(hitElement, "h", "down", loadDaNewsText)
	end
end
addEventHandler("onMarkerHit", getRootElement(), newsStuff)

function newspaperLeave(hitElement, matchingDimension)
if (getElementType(hitElement) == "player" ) and (getElementData(source, "newsMarker") == true ) then
--outputChatBox("* Unbinded H key", hitElement, 0, 255, 0, false)
unbindKey(hitElement, "h", "down", loadDaNewsText)
end
end
addEventHandler("onMarkerLeave", getRootElement(), newspaperLeave)

function setDaNewsText(jij, message)
local newsTxd = fileOpen("text.txt", false)
	if newsTxd then
	fileWrite(newsTxd, "")
	fileWrite(newsTxd, tostring(message))
	fileClose(newsTxd)
	else
	outputChatBox("* Error, couldn't open text.txt, creating new txt file...", jij, 255, 00, 0, false)
	fileCreate("text.txt")
	fileOpen("text.txt", false)
	fileWrite(newsTxd, "")
	fileWrite(newsTxd, tostring(message))
	fileClose(newsTxd)
	outputChatBox("* text.txt successfully created. News paper text saved!", jij, 0, 255, 0, false)
	end
end
addEvent("saveNewsText", true)
addEventHandler("saveNewsText", getRootElement(), setDaNewsText)

function loadDaNewsText(player)
	playerAcc = getPlayerAccount(player)
	if (getElementType(player) == "player") and getElementData(player, "newspaper") == false then
		if exports.global:takeMoney(player, 4) then
			local textFile = fileOpen("text.txt", true)
			local text = fileRead(textFile, 500) 
			triggerClientEvent(player, "showStandGUI", player, text)
			fileClose(textFile)
			unbindKey(player, "h", "down", loadDaNewsText)	
		else
			outputChatBox("* You don't have enough money! Really? You don't have 4$ Required", player, 255, 0, 0, false)	
		end
	elseif (getElementData(player, "newspaper") == true ) then
	outputChatBox("* You've already got a news paper! Type: /readnewspaper to (re)read it or type /dropnewspaper to drop it.", player, 255, 0, 0, false)
	end
end

function showAgain(player)
	local textFile = fileOpen("text.txt", true)
    local text = fileRead(textFile, 500) 
	triggerClientEvent(player, "showStandGUI", player, text)
	fileClose(textFile)
end
addEvent("loadNewsText", true)
addEventHandler("loadNewsText", getRootElement(), showAgain)

meep = createTeam("Global Media News", 0, 255, 0)