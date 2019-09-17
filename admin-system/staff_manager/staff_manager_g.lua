--MAXIME / 2015.1.8

function canPlayerAccessStaffManager(player)
	return exports.integration:isPlayerTrialAdmin(player) or exports.integration:isPlayerSupportManager(player) or exports.integration:isPlayerLeadScripter(player)
end
	