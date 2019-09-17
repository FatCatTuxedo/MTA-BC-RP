function getAdminTitles()
	return exports.integration:getAdminTitles()
end

function getAdmins()
	local players = exports.pool:getPoolElementsByType("player")

	local admins = { }

	for key, value in ipairs(players) do
		if exports.integration:isPlayerTrialAdmin(value) then
			table.insert(admins,value)
		end
	end
	return admins
end

function getPlayerAdminLevel(thePlayer)
	return (isElement( thePlayer ) and getElementData(thePlayer, "admin_level")) or 0
end

function getPlayerAdminTitle(thePlayer)
	if isElement(thePlayer) then
		local rank = exports.integration:getFullTitle(getElementData(thePlayer, "admin_level"), getElementData(thePlayer, "supporter_level"), getElementData(thePlayer, "vct_level"), getElementData(thePlayer, "scripter_level"))
		if (rank) == "" then
			return "Player"
		else
			return rank.." "..getElementData( thePlayer, "account:username" )
		end
	end
end

--[[ GM ]]--
function getGameMasters()
	local players = exports.pool:getPoolElementsByType("player")
	local gameMasters = { }
	for key, value in ipairs(players) do
		if exports.integration:isPlayerSupporter(value) or exports.integration:isPlayerTrialAdmin(value) then
			table.insert(gameMasters, value)
		end
	end
	return gameMasters
end

--[[ /GM ]]--

local scripters = {
}

local lvl2scripters = {

}

local internalaffairs = {

}

function isPlayerLvl2Scripter(thePlayer)
	return lvl2scripters[thePlayer] or lvl2scripters[ getElementData(thePlayer, "account:username") or "nobody" ] or false
end

function isPlayerIA(thePlayer)
	return internalaffairs[thePlayer] or internalaffairs[ getElementData(thePlayer, "account:username") or "nobody" ] or false
end

function isPlayerScripter(thePlayer)
	return exports["integration"]:isPlayerScripter(thePlayer)
end

function getAdminTitle1(thePlayer)
	local adminTitles = getAdminTitles()
	local title = adminTitles[getPlayerAdminLevel(thePlayer)] or "Error"
	return title
end

function isStaffOnDuty(thePlayer)
	return isScripterOnDuty(thePlayer) or isAdminOnDuty(thePlayer) or isSupporterOnDuty(thePlayer)
end

function isStaff(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		return exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerMappingTeamMember(thePlayer)
	else
		return false
	end
end

function isAdminOnDuty(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		return (exports.integration:isPlayerTrialAdmin(thePlayer) and (getElementData(thePlayer, "duty_admin") == 1))
	else
		return false
	end
end

function isScripterOnDuty(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		return exports.integration:isPlayerScripter(thePlayer) and (getElementData(thePlayer, "duty_dev") == 1)
	else
		return false
	end
end

function isSupporterOnDuty(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		return exports.integration:isPlayerSupporter(thePlayer) and (getElementData(thePlayer, "duty_supporter") == 1)
	else
		return false
	end
end
