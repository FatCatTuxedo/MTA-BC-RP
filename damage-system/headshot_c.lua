function headshot ( attacker, weapon, bodypart )
	if bodypart == 9 then
		setElementHealth(getLocalPlayer(), 0)
	end
end
addEventHandler ( "onClientPlayerDamage", getLocalPlayer(), headshot )