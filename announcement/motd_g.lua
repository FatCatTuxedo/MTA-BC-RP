--MAXIME 2015.1.8

function canPlayerAccessMotdManager(player)
	return exports.integration:isPlayerTrialAdmin(player) or exports.integration:isPlayerSupporter(player) or exports.integration:isPlayerScripter(player)
end

staffTitles = exports.integration:getStaffTitles()