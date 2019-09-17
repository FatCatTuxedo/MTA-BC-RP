--BY MAXIME 24/5/2013
function givePlayerJob(thePlayer, commandName, targetPlayer, jobID, jobLevel, jobProgress)
	jobID = tonumber(jobID)
	if exports.integration:isPlayerAdmin(thePlayer) then
		local jobTitle = getJobTitleFromID(jobID)
		if not (targetPlayer) then
			printSetJobSyntax(thePlayer, commandName)
			return
		else
			
			if jobTitle == "Unemployed" then
				jobID = 0
			end
			
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local username = getPlayerName(thePlayer)
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					if (jobID==4) then -- CITY MAINTENANCE
						exports.global:giveItem(targetPlayer, 115, "41:1:Spraycan", 2500)
						outputChatBox("Use this spray to paint over the graffiti you find.", targetPlayer, 255, 194, 14)
						exports['anticheat-system']:changeProtectedElementDataEx(targetPlayer, "tag", 9, true)
						mysql:query_free("UPDATE characters SET tag=9 WHERE id = " .. mysql:escape_string(getElementData(targetPlayer, "dbid")) )
					end
					
					if (jobID==7) then
						triggerEvent("onPlayerGetJobMiner.JobStart", targetPlayer)
					end
					
					mysql:query_free("UPDATE `characters` SET `job`='" .. mysql:escape_string(jobID) .. "' WHERE `id`='"..tostring(getElementData(targetPlayer, "dbid")).."' " )
					
					exports["job-system"]:fetchJobInfoForOnePlayer(targetPlayer)
					
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					if hiddenAdmin == 0 then
						outputChatBox("Your job has been set to '" .. jobTitle .. "' by "..tostring(adminTitle) .. " " .. getPlayerName(thePlayer)..". ", targetPlayer, 0, 255,0)
					else
						outputChatBox("Your job has been set to '" .. jobTitle .. "' by a hidden admin. ", targetPlayer, 0, 255,0)
					end
					outputChatBox("You have set " .. targetPlayerName .. "'s job to '"..jobTitle.."'.", thePlayer)
				end
			end
		end
	end
end
addCommandHandler("setjob", givePlayerJob, false, false)

function printSetJobSyntax(thePlayer, commandName)
	outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Job ID, 0 = Unemployed]", thePlayer, 255, 194, 14)
	outputChatBox("ID#1: Delivery Driver", thePlayer)
	outputChatBox("ID#2: Taxi Driver", thePlayer)
	outputChatBox("ID#3: Bus Driver", thePlayer)
	outputChatBox("ID#4: City Maintenance", thePlayer)
	outputChatBox("ID#5: Mechanic", thePlayer)
	outputChatBox("ID#6: Locksmith", thePlayer)
	outputChatBox("ID#7: Miner", thePlayer)
end

function getJobTitleFromID(jobID)
	if (tonumber(jobID)==1) then
		return "Delivery Driver"
	elseif (tonumber(jobID)==2) then
		return "Taxi Driver"
	elseif  (tonumber(jobID)==3) then
		return "Bus Driver"
	elseif (tonumber(jobID)==4) then
		return "City Maintenance"
	elseif (tonumber(jobID)==5) then
		return "Mechanic"
	elseif (tonumber(jobID)==6) then
		return "Locksmith"
	elseif (tonumber(jobID)==7) then
		return "Miner"
	else
		return "Unemployed"
	end
end

function setjobLevel(thePlayer, commandName, target, level, progress )
	if exports.integration:isPlayerAdmin(thePlayer) then
		if not target or not tonumber(level) or (tonumber(level) < 1) then
			outputChatBox( "SYNTAX: /" .. commandName .. " [player ID or Name] [Level] [Progress, optional]", thePlayer, 255, 194, 14 )
			return false
		end
		
		if not tonumber(progress) or (tonumber(progress) < 0) then
			progress = 0
		end
		
		level = math.floor(tonumber(level))
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
		if not targetPlayer then
			outputChatBox("Player '"..target.."' not found.", thePlayer, 255,0,0)
			return false
		end
		
		jobID = getElementData(targetPlayer, "job")
		
		if jobID <=0 then
			outputChatBox("Player is currently unemployed, please use /setjob first.", thePlayer, 255,0,0)
			return false
		end
		
		local sucess, msg = setPlayerJobLevel(targetPlayer, jobID, level, progress)
		if (getPlayerName(thePlayer) ~= getPlayerName(targetPlayer)) then
			outputChatBox(msg, thePlayer, 255, 194, 14)
			outputChatBox(msg, targetPlayer, 255, 194, 14)
		else
			outputChatBox(msg, targetPlayer, 255, 194, 14)
		end
		
		if sucess then
			return true
		else
			return false
		end
	else
		outputChatBox("Only Super Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("setjoblevel", setjobLevel, false, false)

function setPlayerJobLevel(targetPlayer, jobID, level, progress)
	if mysql:query_free("UPDATE `jobs` SET `jobLevel`='"..level.."', `jobProgress`='"..progress.."' WHERE `jobCharID`='"..getElementData(targetPlayer, "dbid").."' AND `jobID`='"..jobID.."' " ) then
		exports["job-system"]:fetchJobInfoForOnePlayer(targetPlayer)
		return true, getPlayerName(targetPlayer):gsub("_", " ").." now has '"..getJobTitleFromID(jobID).."' job (Level: "..level..", Progress: "..progress..")"
	else
		return false, "Database Error, please report to Maxime"
	end
end

function delJob( thePlayer, commandName, targetPlayerName )
	if (exports.global:isPlayerAdmin(thePlayer) or exports.global:isPlayerGameMaster(thePlayer)) then
		if targetPlayerName then
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayerName )
			if targetPlayer then
				if getElementData( targetPlayer, "loggedin" ) == 1 then
					local result = mysql:query_free("UPDATE `characters` SET `job`='0' WHERE `id`='"..tostring(getElementData(targetPlayer, "dbid")).."' " )
					
					exports["job-system"]:fetchJobInfoForOnePlayer(targetPlayer)
					if result then
						outputChatBox( "Deleted job for " .. targetPlayerName..".", thePlayer)
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						if hiddenAdmin == 0 then
							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							outputChatBox("Your job has been deleted by "..tostring(adminTitle) .. " " .. getPlayerName(thePlayer)..". Please relog (F10) to get it affected.", targetPlayer, 0, 255,0)
						else
							outputChatBox("Your job has been deleted by a hidden admin.", targetPlayer, 0, 255,0)
						end
					else
						outputChatBox( "Failed to delete job.", thePlayer, 255, 0, 0 )
					end
				else
					outputChatBox( "Player is not logged in.", thePlayer, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "SYNTAX: /" .. commandName .. " [player]", thePlayer, 255, 194, 14 )
		end
	end
end
addCommandHandler("deljob", delJob, false, false)

function adminRespawnAllTrucks(thePlayer, commandName)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		outputChatBox("Respawned " .. tostring(respawnAllTrucks()) .. " Trucks.", thePlayer)
	else
		outputChatBox("Only Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("respawntrucks", adminRespawnAllTrucks, false, false)

function scripterSkipRoute(thePlayer, commandName)
	if not exports.global:isPlayerSuperAdmin(thePlayer) then
		outputChatBox("Only Super Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
		return false
	end
	spawnRoute(thePlayer, true)
end
addCommandHandler("skiproute", scripterSkipRoute, false, false)
