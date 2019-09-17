
-- // ADMIN COMMANDS
function createFaction(thePlayer, commandName, factionType, ...)
	if exports.integration:isPlayerAdmin(thePlayer) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction Type 0=GANG, 1=MAFIA, 2=LAW, 3=GOV, 4=MED, 5=OTHER, 6=NEWS, 7=MECHANIC] [Faction Name]", thePlayer, 255, 194, 14)
		else
			factionName = table.concat({...}, " ")
			factionType = tonumber(factionType)
			
			local theTeam = createTeam(tostring(factionName))
			if theTeam then
				if mysql:query_free("INSERT INTO factions SET name='" .. mysql:escape_string(factionName) .. "', bankbalance='0', type='" .. mysql:escape_string(factionType) .. "'") then
					local id = mysql:insert_id()
					exports.pool:allocateElement(theTeam, id)
					
					mysql:query_free("UPDATE factions SET rank_1='Dynamic Rank #1', rank_2='Dynamic Rank #2', rank_3='Dynamic Rank #3', rank_4='Dynamic Rank #4', rank_5='Dynamic Rank #5', rank_6='Dynamic Rank #6', rank_7='Dynamic Rank #7', rank_8='Dynamic Rank #8', rank_9='Dynamic Rank #9', rank_10='Dynamic Rank #10', rank_11='Dynamic Rank #11', rank_12='Dynamic Rank #12', rank_13='Dynamic Rank #13', rank_14='Dynamic Rank #14', rank_15='Dynamic Rank #15', rank_16='Dynamic Rank #16', rank_17='Dynamic Rank #17', rank_18='Dynamic Rank #18', rank_19='Dynamic Rank #19', rank_20='Dynamic Rank #20',  motd='Welcome to the faction.', note = '' WHERE id='" .. id .. "'")
					outputChatBox("Faction " .. factionName .. " created with ID #" .. id .. ".", thePlayer, 0, 255, 0)
					exports.anticheat:changeProtectedElementDataEx(theTeam, "type", tonumber(factionType))
					exports.anticheat:changeProtectedElementDataEx(theTeam, "id", tonumber(id))
					exports.anticheat:changeProtectedElementDataEx(theTeam, "money", 0)
					
					local factionRanks = {}
					local factionWages = {}
					for i = 1, 20 do
						factionRanks[i] = "Dynamic Rank #" .. i
						factionWages[i] = 100
					end
					exports.anticheat:changeProtectedElementDataEx(theTeam, "ranks", factionRanks, false)
					exports.anticheat:changeProtectedElementDataEx(theTeam, "wages", factionWages, false)
					exports.anticheat:changeProtectedElementDataEx(theTeam, "motd", "Welcome to the faction.", false)
					exports.anticheat:changeProtectedElementDataEx(theTeam, "note", "", false)
					exports.logs:dbLog(thePlayer, 4, theTeam, "MAKE FACTION")
					table.insert(dutyAllow, { row.id, row.name, { --[[Duty information]] } })
				else
					destroyElement(theTeam)
					outputChatBox("Error creating faction.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Faction '" .. tostring(factionName) .. "' already exists.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("makefaction", createFaction, false, false)

function adminRenameFaction(thePlayer, commandName, factionID, ...)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not (factionID) or not (...)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID] [Faction Name]", thePlayer, 255, 194, 14)
		else
			factionID = tonumber(factionID)
			if factionID and factionID > 0 then
				local theTeam = exports.pool:getElement("team", factionID)
				if (theTeam) then
					local factionName = table.concat({...}, " ")
					mysql:query_free("UPDATE factions SET name='" .. mysql:escape_string(factionName) .. "' WHERE id='" .. factionID .. "'")
					local oldName = getTeamName(theTeam)
					setTeamName(theTeam, factionName)
					
					exports.global:sendMessageToAdmins(exports.global:getPlayerFullIdentity(thePlayer).." renamed faction '" .. oldName .. "' to '" .. factionName .. "'.")
					exports.factions:sendNotiToAllFactionMembers(factionID, "Your faction '"..oldName.."' was renamed to '"..factionName.."' by "..exports.global:getPlayerFullIdentity(thePlayer,1,true))
				else
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("renamefaction", adminRenameFaction, false, false)

function adminSetPlayerFaction(thePlayer, commandName, partialNick, factionID)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		factionID = tonumber(factionID)
		if not (partialNick) or not (factionID) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID] [Faction ID (-1 for none)]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)
			
			if targetPlayer then
				local theTeam = exports.pool:getElement("team", factionID)
				if not theTeam and factionID ~= -1 then
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
					return
				end
				
				if mysql:query_free("UPDATE characters SET faction_leader = 0, faction_id = " .. factionID .. ", faction_rank = 1, faction_phone = NULL, duty = 0 WHERE id=" .. getElementData(targetPlayer, "dbid")) then
					setPlayerTeam(targetPlayer, theTeam)
					if factionID > 0 then
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", factionID, true)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionrank", 1, true)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionphone", nil, true)
						--triggerClientEvent(targetPlayer, "updateFactionInfo", targetPlayer, factionID, 1)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionleader", 0, true)
						triggerEvent("duty:offduty", targetPlayer)
						
						outputChatBox("Player " .. targetPlayerNick .. " is now a member of faction '" .. getTeamName(theTeam) .. "' (#" .. factionID .. ").", thePlayer, 0, 255, 0)
						
						triggerEvent("onPlayerJoinFaction", targetPlayer, theTeam)
						outputChatBox("You were set to Faction '" .. getTeamName(theTeam) .. "'.", targetPlayer, 255, 194, 14)
						
						exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "SET TO FACTION")
					else
						-- Citizen bug fix by Anthony
						local citizenTeam = getTeamFromName("Citizen")
						setPlayerTeam(targetPlayer, citizenTeam)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", -1, true)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionrank", 1, true)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionphone", nil, true)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionleader", 0, true)
						--triggerClientEvent(targetPlayer, "updateFactionInfo", targetPlayer, -1, 1)
						if getElementData(targetPlayer, "duty") and getElementData(targetPlayer, "duty") > 0 then
							takeAllWeapons(targetPlayer)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty", 0, true)
						end
						
						outputChatBox("Player " .. targetPlayerNick .. " was set to no faction.", thePlayer, 0, 255, 0)
						outputChatBox("You were removed from your faction.", targetPlayer, 255, 0, 0)
						
						exports.logs:dbLog(thePlayer, 4, { targetPlayer }, "REMOVE FROM FACTION")
					end
				end
			end
		end
	end
end
addCommandHandler("setfaction", adminSetPlayerFaction, false, false)

function adminSetFactionLeader(thePlayer, commandName, partialNick, factionID)
	if exports.integration:isPlayerAdmin(thePlayer) then
		factionID = tonumber(factionID)
		if not (partialNick) or not (factionID)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name] [Faction ID]", thePlayer, 255, 194, 14)
		elseif factionID > 0 then
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)
			
			if targetPlayer then
				local theTeam = exports.pool:getElement("team", factionID)
				if not theTeam then
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
					return
				end
				
				if mysql:query_free("UPDATE characters SET faction_leader = 1, faction_id = " .. tonumber(factionID) .. ", faction_rank = 1, faction_phone = NULL, duty = 0 WHERE id = " .. getElementData(targetPlayer, "dbid")) then
					setPlayerTeam(targetPlayer, theTeam)
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", factionID, true)
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionrank", 1, true)
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionleader", 1, true)
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionphone", nil, true)
					--triggerClientEvent(targetPlayer, "updateFactionInfo", targetPlayer, factionID, 1)
					triggerEvent("duty:offduty", targetPlayer)
					
					outputChatBox("Player " .. targetPlayerNick .. " is now a leader of faction '" .. getTeamName(theTeam) .. "' (#" .. factionID .. ").", thePlayer, 0, 255, 0)
						
					triggerEvent("onPlayerJoinFaction", targetPlayer, theTeam)
					outputChatBox("You were set to the leader of Faction '" .. getTeamName(theTeam) .. "'.", targetPlayer, 255, 194, 14)
					
					exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "SET TO FACTION LEADER")
					exports.factions:sendNotiToAllFactionMembers(factionID, targetPlayerNick .. " is now a leader of your faction '" .. getTeamName(theTeam) .. "'!", "Set by "..exports.global:getPlayerFullIdentity(thePlayer))
				else
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("setfactionleader", adminSetFactionLeader, false, false)

function adminTogLeader(thePlayer, commandName)
	if exports.integration:isPlayerAdmin(thePlayer) then
				
				if mysql:query_free("UPDATE characters SET faction_leader = 1 WHERE id = " .. getElementData(thePlayer, "dbid")) then
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionleader", 1, true)
				else
					outputChatBox("SQL Error", thePlayer, 255, 0, 0)
				end
	end
end
addCommandHandler("togleader", adminTogLeader, false, false)

function adminSetFactionRank(thePlayer, commandName, partialNick, factionRank)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		factionRank = math.ceil(tonumber(factionRank) or -1)
		if not (partialNick) or not (factionRank)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name] [Faction Rank, 1-20]", thePlayer, 255, 194, 14)
		elseif factionRank >= 1 and factionRank <= 20 then
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)
			
			if targetPlayer then
				local theTeam = getPlayerTeam(targetPlayer)
				if not theTeam or getTeamName( theTeam ) == "Citizen" then
					outputChatBox("Player is not in a faction.", thePlayer, 255, 0, 0)
					return
				end
				
				if mysql:query_free("UPDATE characters SET faction_rank = " .. factionRank .. " WHERE id = " .. getElementData(targetPlayer, "dbid")) then
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "factionrank", factionRank, true)
					
					outputChatBox("Player " .. targetPlayerNick .. " is now rank " .. factionRank .. ".", thePlayer, 0, 255, 0)
					outputChatBox("Admin " .. getPlayerName(thePlayer):gsub("_"," ") .. " set you to rank " .. factionRank .. ".", targetPlayer, 0, 255, 0)
					
					exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "SET TO FACTION RANK " .. factionRank)
				else
					outputChatBox("Error #125151 - Report on Mantis.", thePlayer, 255, 0, 0)
				end
			end
		else
			outputChatBox( "Invalid Rank - valid ones are 1 to 20", thePlayer, 255, 0, 0 )
		end
	end
end
addCommandHandler("setfactionrank", adminSetFactionRank, false, false)

function adminDeleteFaction(thePlayer, commandName, factionID)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not (factionID)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID]", thePlayer, 255, 194, 14)
		else
			factionID = tonumber(factionID)
			if factionID and factionID > 0 then
				local theTeam = exports.pool:getElement("team", factionID)
				
				if (theTeam) then
					
					mysql:query_free("DELETE FROM factions WHERE id='" .. factionID .. "'")
					
					outputChatBox("Faction #" .. factionID .. " was deleted.", thePlayer, 0, 255, 0)
					exports.logs:dbLog(thePlayer, 4, theTeam, "DELETE FACTION")
					exports.factions:sendNotiToAllFactionMembers(factionID, "Your faction '"..getTeamName( theTeam ).."' was deleted by "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).."!")
					local civTeam = getTeamFromName("Citizen")
					for key, value in pairs( getPlayersInTeam( theTeam ) ) do
						setPlayerTeam( value, civTeam )
						exports.anticheat:changeProtectedElementDataEx( value, "faction", -1, true )
						--triggerClientEvent(targetPlayer, "updateFactionInfo", targetPlayer, -1, 1)
					end
					destroyElement( theTeam )
				
				else
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("delfaction", adminDeleteFaction, false, false)

function adminShowFactions(thePlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		local result = mysql:query("SELECT id, name, type, (SELECT COUNT(*) FROM characters c WHERE c.faction_id = f.id) AS members FROM factions f ORDER BY id ASC")
		if result then
			local factions = { }
			
			while true do
				local row = mysql:fetch_assoc(result)
				if not row then break end
				
				table.insert( factions, { row.id, row.name, row.type, ( getTeamFromName( row.name ) and #getPlayersInTeam( getTeamFromName( row.name ) ) or "?" ) .. " / " .. row.members } )
			end
			
			mysql:free_result(result)
			triggerClientEvent(thePlayer, "showFactionList", getRootElement(), factions)
		else
			outputChatBox("Error 300001 - Report on forums.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("showfactions", adminShowFactions, false, false)

function adminShowFactionOnlinePlayers(thePlayer, commandName, factionID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not (factionID)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID]", thePlayer, 255, 194, 14)
		else
			factionID = tonumber(factionID)
			if factionID and factionID > 0 then
				local theTeam = exports.pool:getElement("team", factionID)
				local theTeamName = getTeamName(theTeam)
				local teamPlayers = getPlayersInTeam(theTeam)
				
				if #teamPlayers == 0 then
					outputChatBox("There are no players online in faction '".. theTeamName .."'", thePlayer, 255, 194, 14)
				else
					local teamRanks = getElementData(theTeam, "ranks")
					outputChatBox("Players online in faction '".. theTeamName .."':", thePlayer, 255, 194, 14)
					for k, teamPlayer in ipairs(teamPlayers) do
						local leader = ""
						local playerRank = teamRanks [ getElementData(teamPlayer, "factionrank") ]
						if (getElementData(teamPlayer, "factionleader") == 1) then
							leader = "LEADER "
						end
						outputChatBox("  "..leader.." ".. getPlayerName(teamPlayer) .." - "..playerRank, thePlayer, 255, 194, 14)
					end
				end
			else
				outputChatBox("Faction not found.", thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("showfactionplayers", adminShowFactionOnlinePlayers, false, false)

function callbackAdminPlayersFaction(teamID)
	adminShowFactionOnlinePlayers(client, "showfactionplayers", teamID)
end
addEvent("faction:admin:showplayers", true )
addEventHandler("faction:admin:showplayers", getRootElement(), callbackAdminPlayersFaction)

addEvent('faction:admin:showf3', true)
addEventHandler('faction:admin:showf3', root,
	function(id, fromF3)
		if exports.integration:isPlayerTrialAdmin(client) --[[or exports.integration:isPlayerSupporter(client)]] then
			showFactionMenuEx(client, id, fromF3)
		end
	end)

function setFactionMoney(thePlayer, commandName, factionID, amount)
	if (exports.integration:isPlayerSeniorAdmin(thePlayer)) then
		if not (factionID) or not (amount)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID] [Money]", thePlayer, 255, 194, 14)
		else
			factionID = tonumber(factionID)
			if factionID and factionID > 0 then
				local theTeam = exports.pool:getElement("team", factionID)
				amount = tonumber(amount) or 0
				if amount and amount > 500000*2 then
					outputChatBox("For security reason, you're not allowed to set more than $1,000,000 at once to a faction.", thePlayer, 255, 0, 0)
					return false
				end
				
				if (theTeam) then
					if exports.global:setMoney(theTeam, amount) then
						outputChatBox("Set faction '" .. getTeamName(theTeam) .. "'s money to " .. amount .. " $.", thePlayer, 255, 194, 14)
						exports.factions:sendNotiToAllFactionMembers(factionID, exports.global:getPlayerFullIdentity(thePlayer, 1).." has set your faction bank to $"..exports.global:formatMoney(amount)..".", nil, true)
					else
						outputChatBox("Could not set money to that faction.", thePlayer, 255, 194, 14)
					end
				else
					outputChatBox("Invalid faction ID.", thePlayer, 255, 194, 14)
				end
			else
				outputChatBox("Invalid faction ID.", thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("setfactionmoney", setFactionMoney, false, false)


-----

function loadWelfare( )
	local result = exports.mysql:query_fetch_assoc( "SELECT value FROM settings WHERE name = 'welfare'" )
	if result then
		if not result.value then
			mysql:query_free( "INSERT INTO settings (name, value) VALUES ('welfare', " .. unemployedPay .. ")" )
		else
			unemployedPay = tonumber( result.value ) or 150
		end
	end
end
addEventHandler( "onResourceStart", resourceRoot, loadWelfare )

function getTax(thePlayer)
	loadWelfare( )
	outputChatBox( "Welfare: $" .. exports.global:formatMoney(unemployedPay), thePlayer, 255, 194, 14 )
	outputChatBox( "Tax: " .. ( exports.global:getTaxAmount(thePlayer) * 100 ) .. "%", thePlayer, 255, 194, 14 )
	outputChatBox( "Income Tax: " .. ( exports.global:getIncomeTaxAmount(thePlayer) * 100 ) .. "%", thePlayer, 255, 194, 14 )
end
addCommandHandler("gettax", getTax, false, false)

--

function respawnFactionVehicles(thePlayer, commandName, factionID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local factionID = tonumber(factionID)
		if (factionID) and (factionID > 0) then
			local theTeam = exports.pool:getElement("team", factionID)
			if (theTeam) then
				for key, value in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
					local faction = tonumber(getElementData(value, "faction"))
					if (faction == factionID and not getVehicleOccupant(value, 0) and not getVehicleOccupant(value, 1) and not getVehicleOccupant(value, 2) and not getVehicleOccupant(value, 3) and not getVehicleTowingVehicle(value)) then
						respawnVehicle(value)
						setElementInterior(value, getElementData(value, "interior"))
						setElementDimension(value, getElementData(value, "dimension"))
					end
				end
				
				local hiddenAdmin = tonumber(getElementData(thePlayer, "hiddenadmin"))
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer):gsub("_"," ")
				
				for k,v in ipairs(getPlayersInTeam(theTeam)) do
					outputChatBox((hiddenAdmin == 0 and adminTitle .. " " .. username or "Hidden Admin") .. " respawned all unoccupied faction vehicles.", v)
				end
				
				exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. username .. " respawned all unoccupied faction vehicles for faction ID " .. factionID .. ".")
				exports.logs:dbLog(thePlayer, 4, theTeam, "FACTION RESPAWN for " .. factionID)
			else
				outputChatBox("Invalid faction ID.", thePlayer, 255, 0, 0, false)
			end
		else
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID]", thePlayer, 255, 194, 14, false)
		end
	end
end
addCommandHandler("respawnfaction", respawnFactionVehicles, false, false)

-- // Chaos - Script stealers go away, make something for yourself.
function adminDutyStart()
	local result = mysql:query("SELECT id, name FROM factions WHERE type > 1 ORDER BY id ASC")
	local max = mysql:query("SELECT id FROM duty_allowed ORDER BY id DESC LIMIT 0, 1")
	if result and max then
		dutyAllow = { }
		dutyAllowChanges = { }
		i = 0

		local maxrow = mysql:fetch_assoc(max)
		maxIndex = tonumber(maxrow.id) or 0
			
		while true do
			local row = mysql:fetch_assoc(result)
			if not row then break end

			table.insert(dutyAllow, tonumber(row.id), { tonumber(row.id), row.name, { --[[Duty information]] } })
				
			local result1 = mysql:query("SELECT * FROM duty_allowed WHERE faction="..tonumber(row.id))
			if result1 then
				while true do
					local row1 = mysql:fetch_assoc(result1)
					if not row1 then break end

					table.insert(dutyAllow[tonumber(row.id)][3], { row1.id, tonumber(row1.itemID), row1.itemValue })
				end
			end
		end

		setElementData(resourceRoot, "maxIndex", maxIndex)
		setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
		mysql:free_result(result)
		mysql:free_result(result1)
		mysql:free_result(max)
	else
		outputDebugString("[Factions] ERROR: Duty allow permissions failed.")
	end
end
addEventHandler("onResourceStart", resourceRoot, adminDutyStart)

function getAllowList(factionID)
	local factionID = tonumber(factionID)
	if factionID then
		for k,v in pairs(dutyAllow) do
			if tonumber(v[1]) == factionID then
				key = k
				break
			end
		end
		return dutyAllow[key][3]
	end
end

function adminDuty(thePlayer)
	if (exports.integration:isPlayerSeniorAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		if not getElementData(resourceRoot, "dutyadmin") and type(dutyAllow) == "table" then
			triggerClientEvent(thePlayer, "adminDutyAllow", resourceRoot, dutyAllow, dutyAllowChanges)
			setElementData( resourceRoot, "dutyadmin", true )
		elseif type(dutyAllow) ~= "table" then
			outputChatBox("There was a issue with the startup caching of this resource. Contact a Scripter.", thePlayer, 255, 0, 0)
		else
			outputChatBox("Oops! Someone is already editing duty permissions. Sorry!", thePlayer, 255, 0, 0) -- No time to set up proper syncing + kinda not needed.
		end
	end
end
addCommandHandler("dutyadmin", adminDuty, false, false)

function saveChanges()
	outputDebugString("[Factions] Saving duty allow changes...")
	local tick = getTickCount()

	for key,value in pairs(dutyAllowChanges) do
		if value[2] == 0 then -- Delete row
			mysql:query_free("DELETE FROM duty_allowed WHERE id="..mysql:escape_string(tonumber(value[3])))
		elseif value[2] == 1 then
			mysql:query_free("INSERT INTO duty_allowed SET id="..mysql:escape_string(tonumber(value[3]))..", faction="..mysql:escape_string(tonumber(value[1]))..", itemID="..mysql:escape_string(tonumber(value[4]))..", itemValue='"..mysql:escape_string(value[5]).."'")
		end
	end

	outputDebugString("[Factions] Completed in ".. math.floor((getTickCount()-tick)/60) .." seconds.")
end
addEventHandler("onResourceStop", resourceRoot, saveChanges)

function updateTable(newTable, changesTable)
	dutyAllow = newTable
	dutyAllowChanges = changesTable
	removeElementData(resourceRoot, "dutyadmin")
	setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
end
addEvent("dutyAdmin:Save", true)
addEventHandler("dutyAdmin:Save", resourceRoot, updateTable)