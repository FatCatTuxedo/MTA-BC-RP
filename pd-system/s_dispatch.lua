local allowedFactions = {
	[1] = true,
	[80] = true
}

function isInAllowedFactions(element)
	for k,v in pairs(allowedFactions) do
		if getElementData(element, "faction") == k then
			return true
		end
	end
end

function isSameFaction(player1, player2)
	return (getElementData(player2, "faction") == getElementData(player1, "faction")) or getElementData(root, "dispatch:joint")
end



addEvent("dispatch:onDutyChange", true)
addEventHandler("dispatch:onDutyChange", resourceRoot, 
	function(data)
	    for k, thePlayer in ipairs ( getElementsByType( "player" ) ) do
	        if (getElementData(thePlayer, "dispatch:onDuty") and isInAllowedFactions(thePlayer) and isSameFaction(thePlayer, source)) then
				triggerClientEvent(thePlayer, "dispatch:onDutyChange", source, data, source)
			end
		end
	end
)

addEvent("dispatch:callsignChange", true)
addEventHandler("dispatch:callsignChange", resourceRoot, 
	function(data)
	    for k, thePlayer in ipairs ( getElementsByType( "player" ) ) do
	        if (getElementData(thePlayer, "dispatch:onDuty") and isInAllowedFactions(thePlayer) and isSameFaction(thePlayer, source)) then
				triggerClientEvent(thePlayer, "dispatch:callsignChange", source, data, source)
			end
		end
	end
)