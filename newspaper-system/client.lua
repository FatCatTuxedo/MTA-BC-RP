jij = getLocalPlayer()
setElementData(getLocalPlayer(), "newspaper", false)

--NEWS STAND GUI
function standGUIFunc(text)
if (guiGetVisible(newsImg)) then
showCursor(false)
guiSetVisible(newsImg, false)
guiSetVisible(closeButt, false)
guiSetVisible(newsLabel, false)
else
showCursor(true)

newsLabel = guiCreateLabel(254,284,488,240,tostring(text),false)
guiLabelSetColor(newsLabel,77,77,77)
guiLabelSetVerticalAlign(newsLabel,"top")
guiLabelSetHorizontalAlign(newsLabel,"left",false)
guiSetFont(newsLabel,"clear-normal")

closeButt = guiCreateButton(261,661,39,19,"Close",false)

newsImg = guiCreateStaticImage(144,123,728,578,"BlankPaper.png",false)
guiMoveToBack(newsImg)

addEventHandler("onClientGUIClick", closeButt, closeFunc, false)
addEventHandler("onClientGUIClick", newsImg, moveToBackAgain, false)

outputChatBox("* Type: /readnewspaper to (re)read the news paper or type /dropnewspaper to drop it", 255, 200, 0, false)
setElementData(getLocalPlayer(), "newspaper", true)

addCommandHandler("readnewspaper", readNewsPaperFunc)
addCommandHandler("dropnewspaper", dropNewsPaperFunc)
end
end
addEvent("showStandGUI", true)
addEventHandler("showStandGUI", getLocalPlayer(), standGUIFunc)

function readNewsPaperFunc()
local player = getLocalPlayer()
triggerServerEvent("loadNewsText", getLocalPlayer(), player)
end

function dropNewsPaperFunc()
jij = getLocalPlayer()
setElementData(getLocalPlayer(), "newspaper", false)
outputChatBox("* You dropped your news paper!", 255, 200, 0, false)
removeCommandHandler("dropnewspaper")
removeCommandHandler("readnewspaper")
end

function moveToBackAgain(button, state)
	if (state == "up" or "down") then
	guiMoveToBack(newsImg)
	end
end


--TRIGGERED WHEN THE PLAYER CLICKS ON THE EXIT BUTTON
function closeFunc()
showCursor(false)
guiSetVisible(newsImg, false)
guiSetVisible(closeButt, false)
guiSetVisible(newsLabel, false)
end

-------------EDITOR

function newsPaperEdit()
local newsTeam = getTeamFromName("Global Media News")
if (newsTeam) and (getPlayerTeam(jij) == newsTeam ) then
	if (guiGetVisible(newsPaperEdit)) then
	guiSetVisible(newsWnd, false)
	guiSetInputEnabled(false)
	showCursor(false)
	else
	showCursor(true)
	guiSetInputEnabled(true)
newsWnd = guiCreateWindow(494,144,523,496,"Fort Carson GMN Editor",false)
guiWindowSetSizable(newsWnd,false)
changeButt = guiCreateButton(13,460,157,25,"Change",false,newsWnd)
closeButt = guiCreateButton(357,460,157,25,"Close",false,newsWnd)

local readTxt = fileOpen("text.txt", true)
local messageShit = fileRead(readTxt, 500)
editMemo = guiCreateMemo(10,24,504,436,tostring(messageShit),false,newsWnd)
fileClose(readTxt)

addEventHandler("onClientGUIClick", closeButt, closeEditorWnd, false)
addEventHandler("onClientGUIClick", changeButt, changeNewsPaper, false)
	end
	else
	outputChatBox("* In order to edit the news paper you must be a member of the fort carson news faction.", 255, 200, 0, false)
end
end
addCommandHandler("editnewspaper", newsPaperEdit)

function changeNewsPaper()
	local message = guiGetText(editMemo)
	triggerServerEvent("saveNewsText", getRootElement(), jij, message)
	outputChatBox("* News paper text saved and changed!", 0, 255, 0, false)
end

function closeEditorWnd()
showCursor(false)
guiSetVisible(newsWnd, false)
guiSetInputEnabled(false)
end