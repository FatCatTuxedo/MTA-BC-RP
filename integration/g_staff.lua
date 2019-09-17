--MAXIME
function isPlayerLeadAdmin(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	if isPlayerLeadScripter(player) then
		return true
	end
	local adminLevel = getElementData(player, "admin_level") or 0
	return (adminLevel >= 5)
end

function isPlayerSeniorAdmin(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	if isPlayerLeadScripter(player) then
		return true
	end
	local adminLevel = getElementData(player, "admin_level") or 0
	return (adminLevel >= 3)
end

function isPlayerAdmin(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	if isPlayerLeadScripter(player) then
		return true
	end
	local adminLevel = getElementData(player, "admin_level") or 0
	return (adminLevel >= 2)
end

function isPlayerTrialAdmin(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	if isPlayerLeadScripter(player) then
		return true
	end
	local adminLevel = getElementData(player, "admin_level") or 0
	return (adminLevel >= 1)
end

function isPlayerSupporter(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local supporter_level = getElementData(player, "supporter_level") or 0
	return (supporter_level >= 1)
end

function isPlayerSupportManager(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local supporter_level = getElementData(player, "supporter_level") or 0
	return (supporter_level >= 3)
end

function isPlayerScripter(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local scripter_level = getElementData(player, "scripter_level") or 0
	return (scripter_level >= 3)
end

function isPlayerDev(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local scripter_level = getElementData(player, "scripter_level") or 0
	return (scripter_level >= 2)
end

function isPlayerWebDev(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local scripter_level = getElementData(player, "scripter_level") or 0
	return (scripter_level == 1) or (scripter_level == 4)
end

function isPlayerLeadScripter(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
		local accid = getElementData(player, "account:id")
	if accid == 1 then
		return true
	else
		local scripter_level = getElementData(player, "scripter_level") or 0
		return (scripter_level >= 4)
	end
end

--LEADER
function isPlayerVehicleConsultant(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local vct_level = getElementData(player, "vct_level") or 0
	return (vct_level >= 2)
end

--MEMBERS
function isPlayerVCTMember(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	if isPlayerLeadAdmin(player) then
		return true
	end
	local vct_level = getElementData(player, "vct_level") or 0
	return (vct_level >= 2)
end

--LEADER
function isPlayerMappingTeamLeader(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local mapper_level = getElementData(player, "mapper_level") or 0
	return (mapper_level >= 2)
end

function isPlayerMappingTeamMember(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local vct_level = getElementData(player, "vct_level") or 0
	return (vct_level == 1)
end

function isPlayerStaff(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	return 	isPlayerTrialAdmin(player)
	or		isPlayerSupporter(player)
	or 		isPlayerScripter(player)
	or 		isPlayerMappingTeamMember(player)
	or 		isPlayerDev(player)
	or 		isPlayerWebDev(player)
end

function getAdminGroups() -- this is used in c_adminstats to correspond levels to forum usergroups
	return { SUPPORTER, TRIALADMIN, ADMIN, SENIORADMIN, LEADADMIN, SERVERMANAGEMENTTEAM }
end

-- internal affairs
function isPlayerIA( player )
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	return false
end

supporterTitles = {
	[1] = "Trial Helper",
	[2] = "Helper",
	[3] = "Helper Manager",
}

vmtTitles = {
	[1] = "Mapper",
	[2] = "Temp Vehicle Access",
}

devTitles = {
	[1] = "Web Developer",
	[2] = "Trial Developer",
	[3] = "Developer",
	[4] = "Lead Developer",
}

adminTitles = {
	[1] = "Trial Administrator",
	[2] = "Administrator",
	[3] = "Senior Administrator",
	[4] = "Lead Administrator",
	[5] = "Server Management Team",
	[10] = "Secret Admin",
}

function getAdminTitles()
	return adminTitles
end

function getDevTitles()
	return devTitles
end

function getVMTTitles()
	return vmtTitles
end

function getSupporterTitles()
	return supporterTitles
end

function getSupporterNumber()
	return SUPPORTER
end

function getAuxiliaryStaffNumbers()
	return table.concat(AUXILIARY_GROUPS, ",")
end

function getAdminStaffNumbers()
	return table.concat(ADMIN_GROUPS, ",")
end

function getFullTitle(admin, supporter, vmt, scripter)
    text = ''
    if (admin > 0) then
        text = adminTitles[admin]
    end
    if (supporter > 0) then
        if (string.len(text) > 0) then
            text = text..', '
        end
        text = text..supporterTitles[supporter]
    end
    if (vmt > 0) then
        if (string.len(text) > 0) then
            text = text..', '
        end
        text = text..vmtTitles[vmt]
    end
    if (scripter > 0) then
        if (string.len(text) > 0) then
            text = text..', '
        end
        text = text..devTitles[scripter]
    end
    return text
end
