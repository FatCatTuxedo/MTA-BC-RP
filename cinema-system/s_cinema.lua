local cinemaZone = createColCuboid ( 1042.1748046875, -1139.3544921875, 1993.6887207031, 70, 120, 50 )
setElementDimension (cinemaZone, 86)
setElementInterior (cinemaZone, 3)
local link = "https://google.com/?t=1"
local currentTime = 0
local youTubeTimer = nil

function EnterCinemaZone(thePlayer, matchingDimension)
	if getElementType ( thePlayer ) == "player" then
		triggerClientEvent ( thePlayer, "cinema:show", thePlayer)
		triggerClientEvent ( thePlayer, "cinema:loadLink", thePlayer, link .. "&t=" .. currentTime )
	end
end
addEventHandler ( "onColShapeHit", cinemaZone, EnterCinemaZone )

function ExitCinemaZone(thePlayer, matchingDimension)
	if getElementType ( thePlayer ) == "player" then
		triggerClientEvent ( thePlayer, "cinema:destroyBrowser", thePlayer)
	end
end
addEventHandler ( "onColShapeLeave", cinemaZone, ExitCinemaZone )

function YouTubeCounter()
	currentTime = currentTime + 1
end

function loadYouTubeVid(videoID)
	resetCinema()
	link = "https://www.youtube.com/tv#/watch/video/idle?v="..videoID
	youTubeTimer = setTimer(YouTubeCounter, 1000, 0)
	local players = getElementsWithinColShape (cinemaZone, "player")
	for theKey,thePlayer in ipairs(players) do                           
		triggerClientEvent(thePlayer, "cinema:loadLink", thePlayer, "https://www.youtube.com/tv#/watch/video/idle?v="..videoID)
	end
end
addEvent("cinema:loadVideo", true)
addEventHandler("cinema:loadVideo", getRootElement(), loadYouTubeVid)

function resetCinema()
	if (youTubeTimer) then
		killTimer(youTubeTimer)
	end
	currentTime = 0
	link = "https://google.com/?t=1"
	local players = getElementsWithinColShape (cinemaZone, "player")
	for theKey,thePlayer in ipairs(players) do                           
		triggerClientEvent(thePlayer, "cinema:loadLink", thePlayer, link)
	end
end
addEvent("cinema:reset", true)
addEventHandler("cinema:reset", getRootElement(), resetCinema)

function commandVideo(player, cmd, id)
	if exports.integration:isPlayerScripter(player) then
		loadYouTubeVid(id)
	end
end
addCommandHandler("cinema", commandVideo)

function commandReset(player, cmd, id)
	if exports.integration:isPlayerScripter(player) then
		resetCinema()
		local players = getElementsWithinColShape (cinemaZone, "player")
		for theKey,thePlayer in ipairs(players) do                           
			triggerClientEvent(thePlayer, "cinema:loadLink", thePlayer, link)
		end
	end
end
addCommandHandler("resetcinema", commandReset)

addEvent("astro:ped:start", true)
function guardPedStart(pedName)
	exports['global']:sendLocalText(client, "[English] "..pedName.." says: Hello, how can I help you today?", 255, 255, 255, 10)
end
addEventHandler("astro:ped:start", getRootElement(), guardPedStart)

addEvent("astro:ped:help", true)
function PedHelp(ped, pedName)
	exports['global']:sendLocalText(client, "[English] "..pedName.." says: Let me contact someone for you.", 255, 255, 255, 10)
	exports['global']:sendLocalMeAction(ped, "sends a text message.", false, false)
	for key, value in ipairs( getPlayersInTeam( getTeamFromName("Astro Corporation") ) ) do
		exports['global']:sendLocalMeAction(value, "receives a new text message.", false, false)
		outputChatBox("[English] SMS from '"..tostring(pedName).."': Someone is requesting to talk to someone at our HQ  ((" .. getPlayerName(client):gsub("_"," ") .. "))", value, 0, 183, 239)
	end
end
addEventHandler("astro:ped:help", getRootElement(), PedHelp)

addEvent("astro:pay:start", true)
function payPedStart(pedName)
	exports['global']:sendLocalText(client, "[English] "..pedName.." says: Hello, would you like to pass?", 255, 255, 255, 10)
end
addEventHandler("astro:pay:start", getRootElement(), payPedStart)

addEvent("astro:ped:pay", true)
function PedPay(ped, pedName)
	exports['global']:sendLocalText(ped, "[English] "..pedName.." says: Alright, thats 10 dollars please.", 255, 255, 255, 10)
	if (exports.global:hasMoney(client, 10)) then
		local gender = getElementData(client, "gender")
		local genderm = "his"
		if (gender == 1) then
			genderm = "her"
		end
		exports.global:takeMoney(client, 10)
		triggerEvent('sendAme', client, "takes some dollar notes from " .. genderm .. " wallet and gives them to " .. pedName .. ".")
		exports['global']:sendLocalText(client, "[English] "..pedName.." shouts: Thanks, have a nice day!", 255, 255, 255, 10)
		for _, theGate in ipairs(getElementsByType("object")) do
			local isGate = getElementData(theGate, "gate")
			if isGate then
				if (getElementData(theGate, "gate:id") == "1") then
					triggerEvent('gate:move', theGate)
				end
			end
		end
	else
		exports['global']:sendLocalText(client, "[English] "..pedName.." shouts: If your not gonna pay then fuck off!", 255, 255, 255, 10)
		outputChatBox("You do not have enough money.", client, 255, 0, 0)
	end
end
addEventHandler("astro:ped:pay", getRootElement(), PedPay)