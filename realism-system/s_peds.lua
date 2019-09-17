-- old one with CJ walk | local validWalkingStyles = { [0]=true, [54]=true, [55]=true, [56]=true, [57]=true, [58]=true, [59]=true, [60]=true, [61]=true, [62]=true, [63]=true, [64]=true, [65]=true, [66]=true, [67]=true, [68]=true, [69]=true, [118]=true, [119]=true, [120]=true, [121]=true, [122]=true, [123]=true, [124]=true, [125]=true, [126]=true, [127]=true, [128]=true, [129]=true, [130]=true, [131]=true, [132]=true, [133]=true, [134]=true, [135]=true, [136]=true, [137]=true, [138]=true }
validWalkingStyles = {[57]=true, [58]=true, [59]=true, [60]=true, [61]=true, [62]=true, [63]=true, [64]=true, [65]=true, [66]=true, [67]=true, [68]=true, [118]=true, [119]=true, [120]=true, [121]=true, [122]=true, [123]=true, [124]=true, [125]=true, [126]=true, [128]=true, [129]=true, [130]=true, [131]=true, [132]=true, [133]=true, [134]=true, [135]=true, [136]=true, [137]=true, [138]=true }

function setWalkingStyle(thePlayer, commandName, walkingStyle)
	if not walkingStyle or not validWalkingStyles[tonumber(walkingStyle)] or not tonumber(walkingStyle) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Walking Style ID]", thePlayer, 255, 194, 14)
		outputChatBox("'/walklist' to list all valid walking style IDs.", thePlayer, 255, 194, 14)
	else
		local dbid = getElementData(thePlayer, "dbid")
		local updateWalkingStyleSQL = exports.mysql:query_free("UPDATE `characters` SET `walkingstyle`='" .. exports.mysql:escape_string(tonumber(walkingStyle)) .. "' WHERE `id`='".. exports.mysql:escape_string(tostring(dbid)) .."'")
		if updateWalkingStyleSQL then
			--setElementData(thePlayer, "walkingstyle", walkingStyle)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "walkingstyle", walkingStyle, true)
			setPedWalkingStyle(thePlayer, tonumber(walkingStyle))
			outputChatBox("Walking style successfully set to: " .. walkingStyle, thePlayer, 0, 255, 0)
		else
			outputChatBox("Walking style could not be set. Error 1337 - Report on forums.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("setwalkingstyle", setWalkingStyle)
addCommandHandler("setwalk", setWalkingStyle)

function applyWalkingStyle(style, ignoreSQL)
	local gender = getElementData(source, "gender")
	local charid = getElementData(source, "dbid")
	if not style or not validWalkingStyles[tonumber(style)] then
		outputDebugString("Invalid Walking style detected on "..getPlayerName(source))
		if gender == 1 then
			style = 129
		else
			style = 128
		end
		ignoreSQL = true
	else
		ignoreSQL = false
	end

	if not ignoreSQL then
		--outputDebugString("Updated walking style to SQL.")
		exports.mysql:query_free("UPDATE `characters` SET `walkingstyle`='" .. exports.mysql:escape_string(style) .. "' WHERE `id`='".. exports.mysql:escape_string(charid) .."'")
	end
	exports.anticheat:changeProtectedElementDataEx(source, "walkingstyle", tonumber(style), true)
	setPedWalkingStyle(source, tonumber(style))
end
addEvent("realism:applyWalkingStyle", true)
addEventHandler("realism:applyWalkingStyle", root, applyWalkingStyle)

function switchWalkingStyle()
	--local gender = getElementData(source, "gender")
	--local charid = getElementData(source, "dbid")
	local walkingStyle = getElementData(client, "walkingstyle")
	walkingStyle = tonumber(walkingStyle) or 57
	local nextStyle = getNextValidWalkingStype(walkingStyle)
	if not nextStyle then
		nextStyle = getNextValidWalkingStype(56)
	end
	triggerEvent("realism:applyWalkingStyle", client, nextStyle)
end
addEvent("realism:switchWalkingStyle", true)
addEventHandler("realism:switchWalkingStyle", root, switchWalkingStyle)

function getNextValidWalkingStype(cur)
	cur = tonumber(cur)
	local found = false
	for i = cur, 138 do
		if validWalkingStyles[i+1] then
			found = i+1
			break
		end
	end
	
	return found
end

function forceSetWalkingStyle(thePlayer, theCommand, walkingStyle)
	if exports.integration:isPlayerLeadAdmin(thePlayer) then
		if not walkingStyle or not tonumber(walkingStyle) then
			outputChatBox("SYNTAX: /" .. theCommand .. " [Walking Style ID]", thePlayer, 255, 194, 14)
			outputChatBox("'/walklist' to list all valid walking style IDs.", thePlayer, 255, 194, 14)
		else
			local dbid = getElementData(thePlayer, "dbid")
			local updateWalkingStyleSQL = exports.mysql:query_free("UPDATE `characters` SET `walkingstyle`='" .. exports.mysql:escape_string(tonumber(walkingStyle)) .. "' WHERE `id`='".. exports.mysql:escape_string(tostring(dbid)) .."'")
			if updateWalkingStyleSQL and setPedWalkingStyle(thePlayer, tonumber(walkingStyle)) then
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "walkingstyle", tonumber(walkingStyle), true)
				outputChatBox("Your walking style has been set to " .. tonumber(walkingStyle), thePlayer, 255, 0, 0)
			else
				outputChatBox("Invalid walking style ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("adminwalk", forceSetWalkingStyle)

function forceSetWalkingStyle(thePlayer, theCommand)
	if getElementModel(thePlayer) == 75 then
			local dbid = getElementData(thePlayer, "dbid")
			local updateWalkingStyleSQL = exports.mysql:query_free("UPDATE `characters` SET `walkingstyle`='" .. exports.mysql:escape_string(0) .. "' WHERE `id`='".. exports.mysql:escape_string(tostring(dbid)) .."'")
			if updateWalkingStyleSQL and setPedWalkingStyle(thePlayer, 0) then
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "walkingstyle", 0, true)
				outputChatBox("Dog Walking enabled.", thePlayer, 255, 0, 0)
			else
				outputChatBox("Invalid walking style ID.", thePlayer, 255, 0, 0)
			end
	end
end
addCommandHandler("dogwalk", forceSetWalkingStyle)

function tempWalkingStyle(walkingStyle)
	if not walkingStyle or not validWalkingStyles[tonumber(walkingStyle)] or not tonumber(walkingStyle) then
		return
	else
		setPedWalkingStyle(source, tonumber(walkingStyle))
	end
end
addEvent("realism:tempWalkingStyle", true)
addEventHandler("realism:tempWalkingStyle", root, tempWalkingStyle)