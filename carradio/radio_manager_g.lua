function canAccessManager(thePlayer)
	if not thePlayer then
		thePlayer = localPlayer
	end
	
	if not localPlayer then
		return false
	end
	
	if exports.integration:isPlayerSeniorAdmin(thePlayer) then
		return true
	end
	
	return exports.donators:hasPlayerPerk(thePlayer, 28) 
end