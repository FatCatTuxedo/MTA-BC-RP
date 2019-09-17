function updateBlips()
	for keyValue, theArrayPlayer in ipairs( getElementsByType("player") ) do
		triggerClientEvent("streamLawBlips", theArrayPlayer)
	end
end
addEvent( "updateLawBlips", true )
addEventHandler( "updateLawBlips", resourceRoot, updateBlips) -- Bound to this resource only, saves on CPU usage.