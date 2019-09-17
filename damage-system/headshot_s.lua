function MakePlayerHeadshot( attacker, weapon, bodypart, loss )
	if bodypart == 9 then
			triggerEvent( "onPlayerHeadshot", source, attacker, weapon, loss )
			setPedHeadless ( source, true )
			killPed( source, attacker, weapon, bodypart )
	end
end

addEventHandler( "onPlayerDamage", getRootElement(), MakePlayerHeadshot )

