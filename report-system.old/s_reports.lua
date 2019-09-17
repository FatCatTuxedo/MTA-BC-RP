mysql = exports.mysql

reports = { }


local getPlayerName_ = getPlayerName
getPlayerName = function( ... )
	s = getPlayerName_( ... )
	return s and s:gsub( "_", " " ) or s
end


function resourceStart(res)
	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		exports.anticheat:changeProtectedElementDataEx(value, "report", false, false)
		exports.anticheat:changeProtectedElementDataEx(value, "reportadmin", false, false)
	end	
end
addEventHandler("onResourceStart", getResourceRootElement(), resourceStart)

function getAdminCount()
	local online, duty, lead, leadduty, gm, gmduty = 0, 0, 0, 0,0,0
	for key, value in ipairs(getElementsByType("player")) do
		if (isElement(value)) then
			local level = getElementData( value, "admin_level" ) or 0
			if level >= 1 then
				online = online + 1
				
				local aod = getElementData( value, "duty_admin" ) or 0
				if aod == 1 then
					duty = duty + 1
				end
				
				if level >= 4 then
					lead = lead + 1
					if aod == 1 then
						leadduty = leadduty + 1
					end
				end
			end
			
			local level = getElementData( value, "supporter_level" ) or 0
			if level >= 1 then
				gm = gm + 1
				
				local aod = getElementData( value, "duty_supporter" )
				if aod == true then
					gmduty = gmduty + 1
				end
			end
		end
	end
	return online, duty, lead, leadduty, gm, gmduty
end

function updateReportCount()
	local open = 0
	local handled = 0
	
	local unanswered = {}
	local byadmin = {}
	
	for key, value in pairs(reports) do
		if not value[8] then
			open = open + 1
			if value[5] then
				handled = handled + 1
				if not byadmin[value[5]] then
					byadmin[value[5]] = { key }
				else
					table.insert(byadmin[value[5]], key)
				end
			else
				table.insert(unanswered, tostring(key)) 
			end
		else
			if not value[5] then
				table.insert(unanswered, "HP"..tostring(key)) 
			end
		end
	end
	
	local gmopen = 0
	local gmhandled = 0
	local gmunanswered = {}
	
	for key, value in pairs(reports) do
		if value[8] then
			gmopen = gmopen + 1
			if value[5] then
				gmhandled = gmhandled + 1
				if not byadmin[value[5]] then
					byadmin[value[5]] = { key }
				else
					table.insert(byadmin[value[5]], key)
				end
			else
				table.insert(gmunanswered, tostring(key)) 
			end
		end
	end
end

addEventHandler( "onElementDataChange", getRootElement(), 
	function(n)
		if getElementType(source) == "player" and ( n == "admin_level" or n == "duty_admin" or  n == "duty_supporter" or n == "supporter_level" ) then
			updateReportCount()
		end
	end
)

function showReports(thePlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		outputChatBox("~~~~~~~~~ Reports ~~~~~~~~~", thePlayer, 255, 194, 15)
		
		local count = 0
		for i = 1, 300 do
			local report = reports[i]
			if report then
				local reporter = report[1]
				local reported = report[2]
				local timestring = report[4]
				local admin = report[5]
				local isGMreport = report[8]
				
				local handler = ""
				if (isElement(admin)) then
					handler = tostring(getPlayerName(admin))
				else
					handler = "None."
				end
				if isGMreport then
					outputChatBox("#" .. tostring(i) .. ": '" .. tostring(getPlayerName(reporter)) .. "' at " .. timestring .. ". Handler: " .. handler .. ".", thePlayer, 255, 195, 15)
				end
				if not (isGMreport  and exports.integration:isPlayerTrialAdmin(thePlayer)) then
					outputChatBox("Report #" .. tostring(i) .. ": '" .. tostring(getPlayerName(reporter)) .. "' reporting '" .. tostring(getPlayerName(reported)) .. "' at " .. timestring .. ". Handler: " .. handler .. ".", thePlayer, 255, 195, 15)
				end
				count = count + 1
			end
		end
		
		if count == 0 then
			outputChatBox("None.", thePlayer, 255, 194, 15)
		else
			outputChatBox("Type /ri [id] to obtain more information about the report.", thePlayer, 255, 194, 15)
		end
	end
end
addCommandHandler("reports", showReports, false, false)

function reportInfo(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: " .. commandName .. " [ID]", thePlayer, 255, 194, 15)
		else
			id = tonumber(id)
			if reports[id] then
				local reporter = reports[id][1]
				local reported = reports[id][2]
				local reason = reports[id][3]
				local timestring = reports[id][4]
				local admin = reports[id][5]
				local isGMreport = reports[id][8]
				
				local playerID = getElementData(reporter, "playerid")
				local reportedID = getElementData(reported, "playerid")
				
				if isGMreport then
					outputChatBox(" [ #" .. id .."] (" .. playerID .. ") " .. tostring(getPlayerName(reporter)) .. " requires assistance since " .. timestring .. ".", thePlayer, 255, 195, 15)
				else
					outputChatBox(" [#" .. id .."] (" .. playerID .. ") " .. tostring(getPlayerName(reporter)) .. " reported (" .. reportedID .. ") " .. tostring(getPlayerName(reported)) .. " at " .. timestring .. ".", thePlayer, 255, 195, 15)
				end
				
				local reason1 = reason:sub( 0, 70 )
				local reason2 = reason:sub( 71 )
				outputChatBox(" [#" .. id .."] Reason: " .. reason1, thePlayer, 255, 195, 15)
				if reason2 and #reason2 > 0 then
					outputChatBox(" [#" .. id .."] " .. reason2, thePlayer, 255, 195, 15)
				end
				
				local handler = ""
				if (isElement(admin)) then
					outputChatBox(" [#" .. id .."] This report is being handled by " .. getPlayerName(admin) .. ".", thePlayer, 255, 195, 15)
				else
					outputChatBox(" [#" .. id .."] Type /ar " .. id .. " to accept this report.", thePlayer, 255, 195, 15)
				end
			else
				outputChatBox("Invalid Report ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("reportinfo", reportInfo, false, false)
addCommandHandler("ri", reportInfo, false, false)

function playerQuit()
	local report = getElementData(source, "report")
	local update = false
	
	if report and reports[report] then
		local theAdmin = reports[report][5]
		local isGMreport = reports[report][8]
		
		if (isElement(theAdmin)) then
			if isGMreport then
				outputChatBox(" [ #" .. report .."] Player " .. getPlayerName(source) .. " left the game.", theAdmin, 255, 195, 15)
			else
				outputChatBox(" [#" .. report .."] Player " .. getPlayerName(source) .. " left the game.", theAdmin, 255, 195, 15)
			end
		else
			if isGMreport then
				for key, value in ipairs(exports.global:getAdmins()) do
					local adminduty = getElementData(value, "duty_admin")
					if adminduty == 1 then
						outputChatBox(" [#" .. report .."] Player " .. getPlayerName(source) .. " left the game.", value, 255, 195, 15)
						update = true
					end
				end
			else
				for key, value in ipairs(exports.global:getGameMasters()) do
					local adminduty = exports.global:isStaffOnDuty(value)
					if adminduty == true then
						outputChatBox(" [#" .. report .."] Player " .. getPlayerName(source) .. " left the game.", value, 255, 195, 15)
						update = true
					end
				end			
			end
		end
		
		local alertTimer = reports[report][6]
		
		if isTimer(alertTimer) then
			killTimer(alertTimer)
		end
		
		reports[report] = nil -- Destroy any reports made by the player
		update = true
	end
	
	-- check for reports assigned to him, unassigned if neccessary
	if isGMreport then
		for i = 1, 300 do
			if reports[i] then
				if reports[i][5] == source then
					reports[i][5] = nil
					for key, value in ipairs(exports.global:getGameMasters()) do
						local adminduty = exports.global:isStaffOnDuty(value)
						if adminduty == true then
							outputChatBox(" [ #" .. i .."] Report is unassigned (" .. getPlayerName(source) .. " left the game)", value, 255, 195, 15)
							update = true
						end
					end
				end
				if reports[i][2] == source then
					for key, value in ipairs(exports.global:getGameMasters()) do
						local adminduty = exports.global:isStaffOnDuty(value)
						if adminduty == true then
							outputChatBox(" [ #" .. i .."] Reported Player " .. getPlayerName(source) .. " left the game.", value, 255, 195, 15)
							update = true
						end
					end
					
					local reporter = reports[i][1]
					if reporter ~= source then
						outputChatBox("Your report #" .. i .. " has been closed (" .. getPlayerName(source) .. " left the game)", reporter, 255, 194, 14)
						exports.anticheat:changeProtectedElementDataEx(reporter, "report", false, false)
						exports.anticheat:changeProtectedElementDataEx(reporter, "reportadmin", false, false)
					end
					
					local alertTimer = reports[i][6]

					if isTimer(alertTimer) then
						killTimer(alertTimer)
					end


					reports[i] = nil -- Destroy any reports made by the player
				end
			end
		end
	else
		for i = 1, 300 do -- Support 128 reports at any one time, since each player can only have one report
			if reports[i] then
				if reports[i][5] == source then
					reports[i][5] = nil
					for key, value in ipairs(exports.global:getAdmins()) do
						local adminduty = getElementData(value, "duty_admin")
						if adminduty == 1 then
							outputChatBox(" [#" .. i .."] Report is unassigned (" .. getPlayerName(source) .. " left the game)", value, 255, 195, 15)
							update = true
						end
					end
				end
				if reports[i][2] == source then
					for key, value in ipairs(exports.global:getAdmins()) do
						local adminduty = getElementData(value, "duty_admin")
						if adminduty == 1 then
							outputChatBox(" [#" .. i .."] Reported Player " .. getPlayerName(source) .. " left the game.", value, 255, 195, 15)
							update = true
						end
					end
					
					local reporter = reports[i][1]
					if reporter ~= source then
						outputChatBox("Your report #" .. i .. " has been closed (" .. getPlayerName(source) .. " left the game)", reporter, 255, 194, 14)
						exports.anticheat:changeProtectedElementDataEx(reporter, "report", false, false)
						exports.anticheat:changeProtectedElementDataEx(reporter, "reportadmin", false, false)
					end
					
					local alertTimer = reports[i][6]

					if isTimer(alertTimer) then
						killTimer(alertTimer)
					end


					reports[i] = nil -- Destroy any reports made by the player
				end
			end
		end	
	end
	
	if update then
		updateReportCount()
	end
end
addEventHandler("onPlayerQuit", getRootElement(), playerQuit)
	
function handleReport(reportedPlayer, reportedReason, isGMreport)
	if not isGMreport then
		isGMreport = false
	end
	
	if getElementData(reportedPlayer, "loggedin") ~= 1 then
		outputChatBox("The Player you're reporting is not logged in.", source, 255, 0, 0)
		return
	end
	-- Find a free report slot
	local slot = nil
	
	for i = 1, 300 do 
		if not reports[i] then
			slot = i
			break
		end
	end
	
	local hours, minutes = getTime()
	
	-- Fix hours
	if (hours<10) then
		hours = "0" .. hours
	end
	
	-- Fix minutes
	if (minutes<10) then
		minutes = "0" .. minutes
	end
	
	local timestring = hours .. ":" .. minutes
	

	local alertTimer = setTimer(alertPendingReport, 120000, 2, slot)
	-- Store report information
	reports[slot] = { }
	reports[slot][1] = source -- Reporter
	reports[slot][2] = reportedPlayer -- Reported Player
	reports[slot][3] = reportedReason -- Reported Reason
	reports[slot][4] = timestring -- Time reported at
	reports[slot][5] = nil -- Admin dealing with the report
	reports[slot][6] = alertTimer -- Alert timer of the report
	reports[slot][7] = nil
	reports[slot][8] = isGMreport -- Type report
	
	local playerID = getElementData(source, "playerid")
	local reportedID = getElementData(reportedPlayer, "playerid")
	
	exports.anticheat:changeProtectedElementDataEx(source, "report", slot, false)
	exports.anticheat:changeProtectedElementDataEx(source, "reportadmin", false)
	local count = 0
	local skipadmin = false
	if isGMreport then
		exports.anticheat:changeProtectedElementDataEx(source, "gmreport", slot, false)
		local GMs = exports.global:getGameMasters()
		
		-- Show to GMs
		local reason1 = reportedReason:sub( 0, 70 )
		local reason2 = reportedReason:sub( 71 )
		for key, value in ipairs(GMs) do
			local gmDuty = exports.global:isStaffOnDuty(value)
			local aDuty = getElementData(value, "duty_admin")
			if (gmDuty or aDuty) then
				outputChatBox(" [ #" .. slot .. "] (" .. playerID .. ") " .. tostring(getPlayerName(source)) .. " asked for assistance. Reason:", value, 255, 195, 15)
				outputChatBox(" [ #" .. slot .. "] " .. reason1, value, 255, 195, 15)
				if reason2 and #reason2 > 0 then
					outputChatBox(" [ #" .. slot .. "] " .. reason2, value, 255, 195, 15)
				end
				skipadmin = true
			end
			count = count + 1
		end

		
		outputChatBox("[" .. timestring .. "] Thank you for submitting your report, Your report reference number is #" .. tostring(slot) .. ".", source, 255, 194, 14)
		outputChatBox("[" .. timestring .. "] A Helper or Administrator will will accept your report soon.", source, 255, 194, 14)
		
		outputChatBox("[" .. timestring .. "] You can close this report at any time by typing /er", source, 255, 194, 14)
		
	else
		local admins = exports.global:getAdmins()
		local count = 0
		-- Show to admins
		local reason1 = reportedReason:sub( 0, 70 )
		local reason2 = reportedReason:sub( 71 )
		for key, value in ipairs(admins) do
			local adminduty = getElementData(value, "duty_admin")
			if (adminduty==1) then
				outputChatBox(" [#" .. slot .. "] (" .. playerID .. ") " .. tostring(getPlayerName(source)) .. " reported (" .. reportedID .. ") " .. tostring(getPlayerName(reportedPlayer)) .. " at " .. timestring .. ".", value, 255, 195, 15)
				outputChatBox(" [#" .. slot .. "] Reason: " .. reason1, value, 255, 195, 15)
				if reason2 and #reason2 > 0 then
					outputChatBox(" [#" .. slot .. "] " .. reason2, value, 255, 195, 15)
				end
			end
			if getElementData(value, "hiddenadmin") ~= 1 then
				count = count + 1
			end
		end
		
		outputChatBox("[" .. timestring .. "] Thank you for submitting your admin report, Your report reference number is #" .. tostring(slot) .. ".", source, 255, 194, 14)
		outputChatBox("[" .. timestring .. "] You reported (" .. reportedID .. ") " .. tostring(getPlayerName(reportedPlayer)) .. ". Reason: ", source, 255, 194, 14 )
		outputChatBox("[" .. timestring .. "] " .. reason1, source, 255, 194, 14)
		if reason2 and #reason2 > 0 then
			outputChatBox("[" .. timestring .. "] " .. reason2, source, 255, 194, 14)
		end
		outputChatBox("[" .. timestring .. "] An admin will respond to your report ASAP.", source, 255, 194, 14)
		outputChatBox("[" .. timestring .. "] You can close this report at any time by typing /er", source, 255, 194, 14)
	end
	updateReportCount()
end

function GMhandleReport(reportedReason)
	handleReport(client, reportedReason, true)
end
addEvent("GMclientSendReport", true)
addEventHandler("GMclientSendReport", getRootElement(), GMhandleReport)

addEvent("clientSendReport", true)
addEventHandler("clientSendReport", getRootElement(), handleReport)





function alertPendingReport(id)
	if (reports[id]) then
		local reportingPlayer = reports[id][1]
		local reportedPlayer = reports[id][2]
		local reportedReason = reports[id][3]
		local timestring = reports[id][4]
		local isGMreport = reports[id][8]
		local playerID = getElementData(reportingPlayer, "playerid")
		local reportedID = getElementData(reportedPlayer, "playerid")
		
		if isGMreport then
			local GMs = exports.global:getGameMasters()
			local reason1 = reportedReason:sub( 0, 70 )
			local reason2 = reportedReason:sub( 71 )
			for key, value in ipairs(GMs) do
				local gmduty = exports.global:isStaffOnDuty(value)
				if (gmduty== true) then
					outputChatBox(" [#" .. id .. "] is still not answered: (" .. playerID .. ") " .. tostring(getPlayerName(reportingPlayer)) .. " since " .. timestring .. ".", value, 255, 195, 15)
					--outputChatBox(" [#" .. id .. "] " .. "Reason: " .. reason1, value, 255, 195, 15)
					--if reason2 and #reason2 > 0 then
					--	outputChatBox(" [#" .. id .. "] " .. reason2, value, 255, 195, 15)
					--end
				end
			end
		else
			local admins = exports.global:getAdmins()
			-- Show to admins
			local reason1 = reportedReason:sub( 0, 70 )
			local reason2 = reportedReason:sub( 71 )
			for key, value in ipairs(admins) do
				local adminduty = getElementData(value, "duty_admin")
				if (adminduty==1) then
					outputChatBox(" [#" .. id .. "] is still not answered: (" .. playerID .. ") " .. tostring(getPlayerName(reportingPlayer)) .. " reported (" .. reportedID .. ") " .. tostring(getPlayerName(reportedPlayer)) .. " at " .. timestring .. ".", value, 255, 195, 15)
					--outputChatBox(" [#" .. id .. "] " .. "Reason: " .. reason1, value, 255, 195, 15)
					--if reason2 and #reason2 > 0 then
					--	outputChatBox(" [#" .. id .. "] " .. reason2, value, 255, 195, 15)
					--end
				end
			end
		end
	end
end

function falseReport(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Report ID]", thePlayer, 255, 194, 14)
		else
			local id = tonumber(id)
			if not (reports[id]) then
				outputChatBox("Invalid report ID.", thePlayer, 255, 0, 0)
			else
				local reportHandler = reports[id][5]
				
				if (reportHandler) then
					outputChatBox("Report #" .. id .. " is already being handled by " .. getPlayerName(reportHandler) .. ".", thePlayer, 255, 0, 0)
				else
					local reportingPlayer = reports[id][1]
					local alertTimer = reports[id][6]
					local isGMreport = reports[id][8]
					
					if isTimer(alertTimer) then
						killTimer(alertTimer)
					end
					


					reports[id] = nil
					
					local hours, minutes = getTime()
					
					-- Fix hours
					if (hours<10) then
						hours = "0" .. hours
					end
					
					-- Fix minutes
					if (minutes<10) then
						minutes = "0" .. minutes
					end
					
					local timestring = hours .. ":" .. minutes
					
					exports.anticheat:changeProtectedElementDataEx(reportingPlayer, "reportadmin", false, false)
					outputChatBox("[" .. timestring .. "] Your report (#" .. id .. ") was marked as false by " .. exports.global:getPlayerAdminTitle(thePlayer) .. ".", reportingPlayer, 255, 194, 14)
					
					if isGMreport then
						exports.anticheat:changeProtectedElementDataEx(reportingPlayer, "gmreport", false, false)
						local admins = exports.global:getGameMasters()
						for key, value in ipairs(admins) do
							local adminduty = exports.global:isStaffOnDuty(value)
							if (adminduty== true) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has marked report #" .. id .. " as false. -", value, 255, 195, 15)
							end
						end					
					else
						exports.anticheat:changeProtectedElementDataEx(reportingPlayer, "report", false, false)
						local admins = exports.global:getAdmins()
						for key, value in ipairs(admins) do
							local adminduty = getElementData(value, "duty_admin")
							if (adminduty==1) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has marked report #" .. id .. " as false. -", value, 255, 195, 15)
							end
						end
					end
					
					updateReportCount()
				end
			end
		end
	end
end
addCommandHandler("fr", falseReport, false, false)

function arBind()
	for k, arrayPlayer in ipairs(exports.global:getAdmins()) do
		local logged = getElementData(arrayPlayer, "loggedin")
		if (logged) then
			if exports.integration:isPlayerLeadAdmin(arrayPlayer) then
				outputChatBox( "LeadAdmWarn: " .. getPlayerName(client) .. " has accept report bound to keys. ", arrayPlayer, 255, 194, 14)
			end
		end
	end
end
addEvent("arBind", true)
addEventHandler("arBind", getRootElement(), arBind)

function acceptReport(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Report ID]", thePlayer, 255, 194, 14)
		else
			local id = tonumber(id)
			if not (reports[id]) then
				outputChatBox("Invalid report ID.", thePlayer, 255, 0, 0)
			else
				local reportHandler = reports[id][5]
				
				if (reportHandler) then
					outputChatBox("Report #" .. id .. " is already being handled by " .. getPlayerName(reportHandler) .. ".", thePlayer, 255, 0, 0)
				else
					local reportingPlayer = reports[id][1]
					local reportedPlayer = reports[id][2]
					local alertTimer = reports[id][6]
					local isGMreport = reports[id][8]
					
					if isTimer(alertTimer) then
						killTimer(alertTimer)
					end
					
					reports[id][5] = thePlayer -- Admin dealing with this report
					
					local hours, minutes = getTime()
					
					-- Fix hours
					if (hours<10) then
						hours = "0" .. hours
					end
					
					-- Fix minutes
					if (minutes<10) then
						minutes = "0" .. minutes
					end
					
					local adminreports = getElementData(thePlayer, "adminreports")
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "adminreports", adminreports+1, false)
					mysql:query_free("UPDATE accounts SET adminreports=adminreports+1 WHERE id = " .. mysql:escape_string(getElementData( thePlayer, "account:id" )) )
					exports.anticheat:changeProtectedElementDataEx(reportingPlayer, "reportadmin", thePlayer, false)
					
					local timestring = hours .. ":" .. minutes
					local playerID = getElementData(reportingPlayer, "playerid")

					outputChatBox("[" .. timestring .. "] " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has accepted your report (#" .. id .. "), Please wait for him/her to contact you.", reportingPlayer, 255, 194, 14)
					outputChatBox("You have accepted report #" .. id .. ". Please proceed to contact the player ( (" .. playerID .. ") " .. getPlayerName(reportingPlayer) .. ").", thePlayer, 255, 194, 14)
					setElementData(thePlayer, "targetPMer", reportingPlayer)
					if isGMreport then
						local admins = exports.global:getGameMasters()
						for key, value in ipairs(admins) do
							local adminduty = exports.global:isStaffOnDuty(value)
							if (adminduty==true) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has accepted report #" .. id .. " -", value, 255, 195, 15)
							end
						end
					else
						local admins = exports.global:getAdmins()
						for key, value in ipairs(admins) do
							local adminduty = getElementData(value, "duty_admin")
							if (adminduty==1) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has accepted report #" .. id .. " -", value, 255, 195, 15)
							end
						end					
					end
					
					updateReportCount()
				end
			end
		end
	end
end
addCommandHandler("ar", acceptReport, false, false)

function acceptAdminReport(thePlayer, commandName, id, ...)
	local adminName = table.concat({...}, " ")
	if (exports.integration:isPlayerLeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Report ID] [Adminname]", thePlayer, 255, 194, 14)
		else
			local targetAdmin, username = exports.global:findPlayerByPartialNick(thePlayer, adminName)
			if targetAdmin then
				local id = tonumber(id)
				if not (reports[id]) then
					outputChatBox("Invalid report ID.", thePlayer, 255, 0, 0)
				else
					local reportHandler = reports[id][5]
					
					if (reportHandler) then
						outputChatBox("Report #" .. id .. " is already being handled by " .. exports.global:getPlayerAdminTitle(reportHandler) .. ".", thePlayer, 255, 0, 0)
					else
						local reportingPlayer = reports[id][1]
						local reportedPlayer = reports[id][2]
						local alertTimer = reports[id][6]
						local isGMreport = reports[id][8]
						if isTimer(alertTimer) then
							killTimer(alertTimer)
						end
						
						reports[id][5] = targetAdmin -- Admin dealing with this report
						
						local hours, minutes = getTime()
						
						-- Fix hours
						if (hours<10) then
							hours = "0" .. hours
						end
						
						-- Fix minutes
						if (minutes<10) then
							minutes = "0" .. minutes
						end
						
						local adminreports = getElementData(targetAdmin, "adminreports")
						exports.anticheat:changeProtectedElementDataEx(targetAdmin, "adminreports", adminreports+1, false)
						mysql:query_free("UPDATE accounts SET adminreports=adminreports+1 WHERE id = " .. mysql:escape_string(getElementData( targetAdmin, "account:id" )) )
						exports.anticheat:changeProtectedElementDataEx(reportingPlayer, "reportadmin", targetAdmin, false)
						
						local timestring = hours .. ":" .. minutes
						local playerID = getElementData(reportingPlayer, "playerid")
						
						outputChatBox("[" .. timestring .. "] " .. exports.global:getPlayerAdminTitle(targetAdmin) .. " has accepted your report (#" .. id .. "), Please wait for him/her to contact you.", reportingPlayer, 255, 194, 14)
						outputChatBox("Someone has assigned report #" .. id .. " to you. Please proceed to contact the player ( (" .. playerID .. ") " .. getPlayerName(reportingPlayer) .. ").", targetAdmin, 255, 194, 14)
						
						if isGMreport then
							local admins = exports.global:getGameMasters()
							for key, value in ipairs(admins) do
								local adminduty = exports.global:isStaffOnDuty(value)
								if (adminduty==true) then
									outputChatBox(" [ #" .. id .. "] - " .. exports.global:getPlayerAdminTitle(theAdmin) .. " has accepted report #" .. id .. " (Assigned) -", value, 255, 195, 15)
								end
							end
						else
							local admins = exports.global:getAdmins()
							for key, value in ipairs(admins) do
								local adminduty = getElementData(value, "duty_admin")
								if (adminduty==1) then
									outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(theAdmin) .. " has accepted report #" .. id .. " (Assigned) -", value, 255, 195, 15)
								end
							end
						end
						
						updateReportCount()
					end
				end
			end
		end
	end
end
addCommandHandler("art", acceptAdminReport, false, false)


function transferReport(thePlayer, commandName, id, ...)
	local adminName = table.concat({...}, " ")
	if (exports.global:isPlayerHeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Report ID] [Adminname]", thePlayer, 255, 194, 14)
		else
			local targetAdmin, username = exports.global:findPlayerByPartialNick(thePlayer, adminName)
			if targetAdmin then
				local id = tonumber(id)
				if not (reports[id]) then
					outputChatBox("Invalid report ID.", thePlayer, 255, 0, 0)
				elseif (reports[id][5] ~= thePlayer) and not (exports.global:isPlayerLeadAdmin(thePlayer)) then
					outputChatBox("This is not your report, pal.", thePlayer, 255, 0, 0)
				else
					local reportingPlayer = reports[id][1]
					local reportedPlayer = reports[id][2]
					local isGMreport = reports[id][8]
					reports[id][5] = targetAdmin -- Admin dealing with this report
					
					local hours, minutes = getTime()
					
					-- Fix hours
					if (hours<10) then
						hours = "0" .. hours
					end
					
					-- Fix minutes
					if (minutes<10) then
						minutes = "0" .. minutes
					end
							
					local timestring = hours .. ":" .. minutes
					local playerID = getElementData(reportingPlayer, "playerid")
					
					outputChatBox("[" .. timestring .. "] " .. exports.global:getPlayerAdminTitle(thePlayer) .. " handed your report to ".. exports.global:getPlayerAdminTitle(targetAdmin) .." (#" .. id .. "), Please wait for him/her to contact you.", reportingPlayer, 255, 194, 14)
					outputChatBox(exports.global:getPlayerAdminTitle(thePlayer) .. " handed report #" .. id .. " to you. Please proceed to contact the player ( (" .. playerID .. ") " .. getPlayerName(reportingPlayer) .. ").", targetAdmin, 255, 194, 14)
					
					if isGMreport then
						local admins = exports.global:getGameMasters()
						for key, value in ipairs(admins) do
							local adminduty = exports.global:isStaffOnDuty(value)
							if (adminduty==true) then
								outputChatBox(" [ #" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " handed report #" .. id .. " over to  ".. exports.global:getPlayerAdminTitle(targetAdmin) , value, 255, 195, 15)
							end
						end					
					else
						local admins = exports.global:getAdmins()
						for key, value in ipairs(admins) do
							local adminduty = getElementData(value, "duty_admin")
							if (adminduty==1) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " handed report #" .. id .. " over to  ".. exports.global:getPlayerAdminTitle(targetAdmin) , value, 255, 195, 15)
							end
						end
					end
						
					updateReportCount()
				end
			end
		end
	end
end
addCommandHandler("tr", transferReport, false, false)

function closeReport(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: " .. commandName .. " [ID]", thePlayer, 255, 195, 14)
		else
			id = tonumber(id)
			if (reports[id]==nil) then
				outputChatBox("Invalid Report ID.", thePlayer, 255, 0, 0)
			elseif (reports[id][5] ~= thePlayer) then
				outputChatBox("This is not your report, pal.", thePlayer, 255, 0, 0)
			else
				local reporter = reports[id][1]
				local alertTimer = reports[id][6]
				local isGMreport = reports[id][8]
				
				if isTimer(alertTimer) then
					killTimer(alertTimer)
				end
			
				
				reports[id] = nil

				if (isElement(reporter)) then
					exports.anticheat:changeProtectedElementDataEx(reporter, "report", false, false)
					exports.anticheat:changeProtectedElementDataEx(reporter, "reportadmin", false, false)
					outputChatBox(exports.global:getPlayerAdminTitle(thePlayer) .. " has closed your report.", reporter, 255, 195, 15)
				end
				
				if not isGMreport then
					local admins = exports.global:getAdmins()
					for key, value in ipairs(admins) do
						local adminduty = getElementData(value, "duty_admin")
						if (adminduty==1) then
							outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has closed the report #" .. id .. ". -", value, 255, 195, 15)
						end
					end					
				else
					local admins = exports.global:getGameMasters()
					for key, value in ipairs(admins) do
						local adminduty = exports.global:isStaffOnDuty(value)
						if (adminduty==true) then
							outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has closed the report #" .. id .. ". -", value, 255, 195, 15)
						end
					end
				end
				updateReportCount()
			end
		end
	end
end
addCommandHandler("cr", closeReport, false, false)

function dropReport(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: " .. commandName .. " [ID]", thePlayer, 255, 195, 14)
		else
			id = tonumber(id)
			if (reports[id] == nil) then
				outputChatBox("Invalid Report ID.", thePlayer, 255, 0, 0)
			else
				if (reports[id][5] ~= thePlayer) then
					outputChatBox("You are not handling this report.", thePlayer, 255, 0, 0)
				else
					local alertTimer = setTimer(alertPendingReport, 120000, 2, id)

					reports[id][5] = nil
					reports[id][6] = alertTimer

					local reporter = reports[id][1]
					if (isElement(reporter)) then
						exports.anticheat:changeProtectedElementDataEx(reporter, "report", false, false)
						exports.anticheat:changeProtectedElementDataEx(reporter, "reportadmin", false, false)
						outputChatBox(exports.global:getPlayerAdminTitle(thePlayer) .. " has released your report. Please wait until another Admin accepts your report.", reporter, 255, 195, 15)
					end
					
					if reports[id][8] then
						local admins = exports.global:getGameMasters()
						for key, value in ipairs(admins) do
							local adminduty = exports.global:isStaffOnDuty(value)
							if (adminduty==true) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has dropped report #" .. id .. ". -", value, 255, 195, 15)
							end
						end
					else
						local admins = exports.global:getAdmins()
						for key, value in ipairs(admins) do
							local adminduty = getElementData(value, "duty_admin")
							if (adminduty==1) then
								outputChatBox(" [#" .. id .. "] - " .. exports.global:getPlayerAdminTitle(thePlayer) .. " has dropped report #" .. id .. ". -", value, 255, 195, 15)
							end
						end
					end

					updateReportCount()
				end
			end
		end
	end
end
addCommandHandler("dr", dropReport, false, false)

function endReport(thePlayer, commandName)
	local report = getElementData(thePlayer, "report")
	
	if not (report) or not reports[report] then
		outputChatBox("You have no pending reports. Press F2 to create one.", thePlayer, 255, 0, 0)
	else
		local hours, minutes = getTime()
					
		-- Fix hours
		if (hours<10) then
			hours = "0" .. hours
		end
					
		-- Fix minutes
		if (minutes<10) then
			minutes = "0" .. minutes
		end
					
		local timestring = hours .. ":" .. minutes
		local reportHandler = reports[report][5]
		local alertTimer = reports[report][6]
		
		if isTimer(alertTimer) then
			killTimer(alertTimer)
		end

		reports[report] = nil
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "report", false, false)
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "reportadmin", false, false)
		
		outputChatBox("[" .. timestring .. "] You have closed your report (#" .. report .. ").", thePlayer, 255, 194, 14)
		
		if (isElement(reportHandler)) then
			outputChatBox(getPlayerName(thePlayer) .. " has closed the report (#" .. report .. "). Thank you for dealing with this report.", reportHandler, 255, 195, 15)
		end
		
		updateReportCount()
	end
end
addCommandHandler("er", endReport, false, false)