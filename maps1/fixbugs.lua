local glitch = createColCuboid ( 1928, -1596.2001953125, 15.8, 93, 57, 3 )

function glitchEnter ( thePlayer, matchingDimension )
        if getElementType ( thePlayer ) == "player" then --if the element that entered was player
	        outputChatBox ( "Do not try and glitch!", thePlayer, 255, 0, 0 )
			setElementHealth ( thePlayer, 0 )
			local username = getPlayerName(thePlayer)
			exports.global:sendMessageToStaff("[GLITCH] " .. username .. " was killed for attempting a map glitch!", true)
        end
end
addEventHandler ( "onColShapeHit", glitch, glitchEnter )