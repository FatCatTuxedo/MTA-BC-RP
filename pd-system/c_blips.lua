local blips = { }

function canPlayerSeeBlips()
	local theTeam = getPlayerTeam(getLocalPlayer())
	local factionType = getElementData(theTeam, "type")
	local duty = tonumber(getElementData(getLocalPlayer(), "duty"))
	if factionType == 2 and duty > 0 then
		return true
	else
		return false
	end
end

function isPlayerPD(player)
	local faction = getElementData(player, "faction")
	local duty = tonumber(getElementData(player, "duty"))
	if faction == 2 and duty > 0 then
		return true
	else
		return false
	end
end
addEvent("streamLawBlips", true)
addEventHandler( "streamLawBlips", getRootElement(),
	function ()
		for keyValue, theArrayPlayer in ipairs( getElementsByType("player") ) do
				local pTheTeam = getPlayerTeam(theArrayPlayer)
				if pTheTeam then
					local pFactionType = getElementData(pTheTeam, "type")
					if pFactionType == 2 then
						local duty = tonumber(getElementData(theArrayPlayer, "duty"))
						if (duty > 0) then
							blips[theArrayPlayer] = createBlipAttachedTo( theArrayPlayer, 0, 1.5, 0,100,255 )
							setBlipVisibleDistance( blips[theArrayPlayer], 99999999 )
						end
					end	
				end
			end
	end
)

addEventHandler ( "onClientElementDataChange", getRootElement(),
function ( dataName )
	if getElementType ( source ) == "player" and dataName == "duty" or dataName == "faction" then
		triggerServerEvent("updateLawBlips", getLocalPlayer())
	end
end )