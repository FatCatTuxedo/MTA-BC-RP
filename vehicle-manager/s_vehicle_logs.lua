local mysql = exports.mysql
	
function addVehicleLogs(vehID, action, actor, clearPreviousLogs)
	if vehID and action then
		if clearPreviousLogs then
			if not mysql:query_free("DELETE FROM `vehicle_logs` WHERE `vehID`='"..tostring(vehID).. "'") then
				outputDebugString("[VEHICLE MANAGER] Failed to clean previous logs #"..vehID.." from `vehicle_logs`.")
				return false
			end
			if not mysql:query_free("DELETE FROM `logtable` WHERE `affected`='ve"..tostring(vehID).. ";'") then
				outputDebugString("[VEHICLE MANAGER] Failed to clean previous logs #"..vehID.." from `logtable`.")
				return false
			end
		end

		local adminID = nil
		if actor and isElement(actor) and getElementType(actor) == "player" then
		 	adminID = getElementData(actor, "account:id") 
		end
		
		local addLog = mysql:query_free("INSERT INTO `vehicle_logs` SET `vehID`= '"..tostring(vehID).."', `action` = '"..mysql:escape_string(action).."' "..(adminID and (", `actor` = '"..adminID.."' ") or "")) or false

		if not addLog then
			outputDebugString("[VEHICLE MANAGER] Failed to add VEHICLE logs.")
			return false
		else
			return true
		end
	else
		outputDebugString("[VEHICLE MANAGER] Lack of agruments #1 or #2 for the function addVEHICLELogs().")
		return false
	end
end

function getVehicleOwner(vehicle)
	local faction = tonumber(getElementData(vehicle, 'faction')) or 0
	if faction > 0 then
		return getTeamName(exports.pool:getElement('team', faction))
	else
		return call(getResourceFromName("cache"), "getCharacterName", getElementData(vehicle, "owner")) or "N/A"
	end
end

function createForumThread(fTitle, fContent)
	local createInForumID = 104
	
	local link = exports["integration"]:createForumThread(nil, nil, createInForumID, fTitle, fContent)
	
	--local firstID = exports.mysql:forum_query_insert_free("INSERT INTO post SET  parentid = '0', username = '"..posterUsername.."', userid = '"..posterID.."', title = '" .. fTitle .. "', dateline = unix_timestamp(), pagetext = '"..content.."', allowsmilie = '0', showsignature = '0', ipaddress = '127.0.0.1', iconid = '0', visible = '1', attach = '0', infraction = '0', reportthreadid = '0'")
	
	--local seccondID = exports.mysql:forum_query_insert_free("INSERT INTO thread SET `force_read_usergroups`='', `force_read_forums`='', title = '" .. fTitle .. "', firstpostid = '" .. firstID .. "', lastpost = unix_timestamp(), forumid = '"..createInForumID.."', pollid = '0', open = '1', replycount = '0', postercount = '1', hiddencount = '0', deletedcount = '0', postusername = '"..posterUsername.."', postuserid = '"..posterID.."', lastposter = '"..posterUsername.."', lastposterid = '"..posterID.."', dateline = unix_timestamp(), views = '0', iconid = '0', visible = '1', sticky = '0', votenum = '0', votetotal = '0', attach = '0' ")
	
	--exports.mysql:forum_query_free("UPDATE post SET threadid = '"..seccondID.."' WHERE postid = '"..firstID.."'")
	--exports.mysql:forum_query_free("update `user` set posts = posts + 1 where userid = '"..posterID.."' ")
	--exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = '"..posterUsername.."', lastposterid='"..posterID.."', lastpostid='"..firstID.."', lastthread='"..fTitle.."', lastthreadid='"..seccondID.."', threadcount = threadcount + 1 WHERE forumid = '"..createInForumID.."'")
	return link
end
