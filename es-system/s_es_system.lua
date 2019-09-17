mysql = exports.mysql

function playerDeath(totalAmmo, killer, killerWeapon)
	if getElementData(source, "dbid") then
		if getElementData(source, "adminjailed") then
			local team = getPlayerTeam(source)
			spawnPlayer(source, 263.821807, 77.848365, 1001.0390625, 270) --, team)
			
			setElementModel(source,getElementModel(source))
			setPlayerTeam(source, team)
			setElementInterior(source, 6)
			setElementDimension(source, getElementData(source, "playerid")+65400)
			
			setCameraInterior(source, 6)
			setCameraTarget(source)
			fadeCamera(source, true)
			
			exports.logs:dbLog(source, 34, source, "died in admin jail")
		elseif getElementData(source, "jailed") then
			exports["prison-system"]:checkForRelease(source)
			--[[ local x, y, z = getElementPosition(source)
			local int = getElementInterior(source)
			local dim = getElementDimension(source)
			spawnPlayer(source, x, y, z, 270, getElementModel(source), int, dim, getPlayerTeam(source))
			setCameraInterior(source, int)
			setCameraTarget(source)--]]
			
			exports.logs:dbLog(source, 34, source, "died in police jail")
		else
			local affected = { }
			table.insert(affected, source)
			local killstr = ' died'
			if (killer) then
				if getElementType(killer) == "player" then
					if (killerWeapon) then
						killstr = ' got killed by '..getPlayerName(killer):gsub("_", " ").. ' ('..getWeaponNameFromID ( killerWeapon )..')'
					else
						killstr = ' died'
					end
					table.insert(affected, killer)
				else
				killstr = ' got killed by an unknown source'
				table.insert(affected, "Unknown")
				end
			end
			-- Remove seatbelt if theres one on
			if 	(getElementData(source, "seatbelt") == true) then
				exports.anticheat:changeProtectedElementDataEx(source, "seatbelt", false, true)
			end
			
			--Maxime
			setElementData(source, "dead", 1)
			local victimDropItem = false
			
			-- if killer and (getElementData(killer, "hoursplayed" ) >= 20) then
				-- victimDropItem = true
			-- end
			changeDeathViewTimer = setTimer(changeDeathView, 3000, 1, source, victimDropItem)
			
			outputChatBox("If you were killed due to DM or anything similar, /report to get an admin to revive you.", source)
			outputChatBox("If you accept your death, you may lose some of your items - unless revived.", source)
			
			--outputChatBox("Respawn in 10 seconds.", source)
			--setTimer(respawnPlayer, 10000, 1, source)
			
			exports.logs:dbLog(source, 34, affected, killstr)
			exports.anticheat:changeProtectedElementDataEx(source, "lastdeath", " [KILL] "..getPlayerName(source):gsub("_", " ") .. killstr, true)
			--logMe(" [KILL] "..getPlayerName(source) .. killstr)
			
		end
	end
end
addEventHandler("onPlayerWasted", getRootElement(), playerDeath)

--Maxime
function changeDeathView(source, victimDropItem)
	if isPedDead(source) then
		local x, y, z = getElementPosition(source)
		local rx, ry, rz = getElementRotation(source)
		setCameraMatrix(source, x+6, y+6, z+3, x, y, z)
		triggerClientEvent(source,"es-system:showRespawnButton",source, victimDropItem)
	end
end
addEvent("changeDeathView", true)
addEventHandler("changeDeathView", getRootElement(), changeDeathView)

function acceptDeath(thePlayer, victimDropItem)
	if getElementData(thePlayer, "dead") == 1 then
		if victimDropItem then
			local x, y, z = getElementPosition(thePlayer)
			for key, item in pairs(exports["item-system"]:getItems(thePlayer)) do 
				itemID = tonumber(item[1])
				local ammo = false
				if itemID == 116 then 
					ammo = exports.global:explode( ":", item[2]  )[2]
				end
				local keepammo = false
				if itemID == 116 or itemID == 115 or itemID == 134 then
					triggerEvent("dropItemOnDead", thePlayer, itemID, item[2], x, y, z, ammo, false)
				end
			end
		end
		
		fadeCamera(thePlayer, true)
		outputChatBox("Respawning...", thePlayer)
		if isTimer(changeDeathViewTimer) == true then
			killTimer(changeDeathViewTimer)
		end
		respawnPlayer(thePlayer, victimDropItem)
	else
		outputChatBox("You aren't dead!", thePlayer, 255, 0, 0)
	end
end
addEvent("es-system:acceptDeath", true)
addEventHandler("es-system:acceptDeath", getRootElement(), acceptDeath)
--addCommandHandler("acceptdeath", acceptDeath)
--addCommandHandler("spawn", acceptDeath)

function logMe( message )
	local logMeBuffer = getElementData(getRootElement(), "killog") or { }
	local r = getRealTime()
	exports.global:sendMessageToAdmins(message)
	table.insert(logMeBuffer,"["..("%02d:%02d"):format(r.hour,r.minute).. "] " ..  message)
	
	if #logMeBuffer > 30 then
		table.remove(logMeBuffer, 1)
	end
	setElementData(getRootElement(), "killog", logMeBuffer)
end

function logMeNoWrn( message )
	local logMeBuffer = getElementData(getRootElement(), "killog") or { }
	local r = getRealTime()
	table.insert(logMeBuffer,"["..("%02d:%02d"):format(r.hour,r.minute).. "] " ..  message)
	
	if #logMeBuffer > 30 then
		table.remove(logMeBuffer, 1)
	end
	setElementData(getRootElement(), "killog", logMeBuffer)
end

function readLog(thePlayer)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		local logMeBuffer = getElementData(getRootElement(), "killog") or { }
		outputChatBox("Recent kill list:", thePlayer, 205, 201, 165)
		for a, b in ipairs(logMeBuffer) do
			outputChatBox("- "..b, thePlayer, 205, 201, 165, true)
		end
		outputChatBox("  END", thePlayer, 205, 201, 165)
	end
end
addCommandHandler("showkills", readLog)

function respawnPlayer(thePlayer, victimDropItem)
	if (isElement(thePlayer)) then
		
		if (getElementData(thePlayer, "loggedin") == 0) then
			exports.global:sendMessageToAdmins("AC0x0000004: "..getPlayerName(thePlayer):gsub("_", " ").." died while not in character, triggering blackfade.")
			return
		end
		
		setPedHeadless(thePlayer, false)	
		
		local cost = math.random(175, 500)		
		local tax = exports.global:getTaxAmount()
		
		exports.global:giveMoney( getTeamFromName("Bone County Emergency Services"), math.ceil((1-tax)*cost) )
		exports.global:takeMoney( getTeamFromName("Fort Carson Municipal Government"), math.ceil((1-tax)*cost) )
			
		mysql:query_free("UPDATE characters SET deaths = deaths + 1 WHERE charactername='" .. mysql:escape_string(getPlayerName(thePlayer)) .. "'")

		setCameraInterior(thePlayer, 0)

		setCameraTarget(thePlayer, thePlayer)

		outputChatBox("You have recieved treatment from the Bone County Emergency Services.", thePlayer, 255, 255, 0)
		
		-- take all drugs
		local count = 0
		for i = 30, 43 do
			while exports.global:hasItem(thePlayer, i) do
				local number = exports['item-system']:countItems(thePlayer, i)
				exports.global:takeItem(thePlayer, i)
				exports.logs:logMessage("[ES Death] " .. getElementData(thePlayer, "account:username") .. "/" .. getPlayerName(thePlayer) .. " lost "..number.."x item "..tostring(i), 28)
				exports.logs:dbLog(thePlayer, 34, thePlayer, "lost "..number.."x item "..tostring(i))
				count = count + 1
			end
		end
		if count > 0 then
			outputChatBox("ES Employee: We handed your drugs over to the Bone County Sheriff's Office. (( deleted ))", thePlayer, 255, 194, 14)
		end
		
		-- take guns
		local removedWeapons = nil
		if not victimDropItem then
			local gunlicense = tonumber(getElementData(thePlayer, "license.gun"))
			local gunlicense2 = tonumber(getElementData(thePlayer, "license.gun2"))
			local team = getPlayerTeam(thePlayer)
			local factiontype = getElementData(team, "type")
			local items = exports['item-system']:getItems( thePlayer ) -- [] [1] = itemID [2] = itemValue
			
			local formatedWeapons
			local correction = 0
			for itemSlot, itemCheck in ipairs(items) do
				if (itemCheck[1] == 115) or (itemCheck[1] == 116) then -- Weapon
					-- itemCheck[2]: [1] = gta weapon id, [2] = serial number/Amount of bullets, [3] = weapon/ammo name
					local itemCheckExplode = exports.global:explode(":", itemCheck[2])
					local weapon = tonumber(itemCheckExplode[1])
					local ammountOfAmmo
					if (((weapon >= 16 and weapon <= 40 and (gunlicense == 0 and gunlicense2 == 0)) or (weapon == 29 or weapon == 30 or weapon == 32 or weapon ==31 or weapon == 34) and (gunlicense2 == 0)) and factiontype ~= 2) or (weapon >= 35 and weapon <= 38)  then -- (weapon == 4 or weapon == 8)
						exports['item-system']:takeItemFromSlot(thePlayer, itemSlot - correction)
						correction = correction + 1
						
						if (itemCheck[1] == 115) then
							exports.logs:dbLog(thePlayer, 34, thePlayer, "lost a weapon (" ..  itemCheck[2] .. ")")
							
							for k = 1, 12 do
								triggerEvent("createWepObject", thePlayer, thePlayer, k, 0, getSlotFromWeapon(k))
							end
						else
							exports.logs:dbLog(thePlayer, 34, thePlayer, "lost a magazine of ammo (" ..  itemCheck[2] .. ")")
							local splitArray = split(itemCheck[2], ":")
							ammountOfAmmo = splitArray[2]
						end
						
						if (removedWeapons == nil) then
							if ammountOfAmmo then
								removedWeapons = ammountOfAmmo .. " " .. itemCheckExplode[3]
								formatedWeapons = ammountOfAmmo .. " " .. itemCheckExplode[3]
							else
								removedWeapons = itemCheckExplode[3]
								formatedWeapons = itemCheckExplode[3]
							end
						else
							if ammountOfAmmo then
								removedWeapons = removedWeapons .. ", " .. ammountOfAmmo .. " " .. itemCheckExplode[3]
								formatedWeapons = formatedWeapons .. "\n" .. ammountOfAmmo .. " " .. itemCheckExplode[3]
							else
								removedWeapons = removedWeapons .. ", " .. itemCheckExplode[3]
								formatedWeapons = formatedWeapons .. "\n" .. itemCheckExplode[3]
							end
						end
					end
				end
			end
		end
		if (removedWeapons~=nil) then
			if gunlicense == 0 and factiontype ~= 2 then
				outputChatBox("LSFD Employee: We have given the LSPD the weapons which you did not have a license for. (" .. removedWeapons .. ").", thePlayer, 255, 194, 14)
			else
				outputChatBox("LSFD Employee: We have given the LSPD the weapons which you are not allowed to carry. (" .. removedWeapons .. ").", thePlayer, 255, 194, 14)
			end
		end
		
		local death = getElementData(thePlayer, "lastdeath")
		if removedWeapons ~= nil then
			logMe(death)
			exports.global:sendMessageToAdmins("/showkills to view lost weapons.")
			logMeNoWrn("#FF0033 Lost Weapons: " .. removedWeapons)
		else
			logMe(death)
		end
		
		local theSkin = getPedSkin(thePlayer)
		local theTeam = getPlayerTeam(thePlayer)
		
		local fat = getPedStat(thePlayer, 21)
		local muscle = getPedStat(thePlayer, 23)

		setElementData(thePlayer, "dead", 0)
		 
		spawnPlayer(thePlayer, 85.2890625, 1170.953125, 18.6704654693, 275)--, theTeam)
		setElementModel(thePlayer,theSkin)
		setPlayerTeam(thePlayer, theTeam)
		setElementInterior(thePlayer, 0)
		setElementDimension(thePlayer, 0)
				
		setPedStat(thePlayer, 21, fat)
		setPedStat(thePlayer, 23, muscle)

		fadeCamera(thePlayer, true, 6)
		triggerClientEvent(thePlayer, "fadeCameraOnSpawn", thePlayer)
		triggerEvent("updateLocalGuns", thePlayer)
	end
end

function recoveryPlayer(thePlayer, commandName, targetPlayer, duration)
	if not (targetPlayer) or not (duration) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Mintues]", thePlayer, 255, 194, 14)
	else
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			local logged = getElementData(thePlayer, "loggedin")
	
			if (logged==1) then
				local theTeam = getPlayerTeam(thePlayer)
				local factionType = getElementData(theTeam, "type")
				
				if (factionType==4) or (exports.integration:isPlayerTrialAdmin(thePlayer) == true) then
					--if (targetPlayer == thePlayer) then
						local dimension = getElementDimension(thePlayer)
						--if (dimesion==9) then
							totaltime = tonumber(duration)
							if totaltime < 121 then
								local money = exports.bank:takeBankMoney(targetPlayer, 100*totaltime)
								if not money then
									outputChatBox("This player does not have enough money in their bank to be placed in recovery.", thePlayer, 255, 0, 0)
									return 
								end
								exports.global:giveMoney( getTeamFromName("Bone County Emergency Services"), 100*totaltime )
								local dbid = getElementData(targetPlayer, "dbid")
								mysql:query_free("UPDATE characters SET recovery='1' WHERE id = " .. dbid)
								setElementFrozen(targetPlayer, true)
								outputChatBox("You have successfully put " .. targetPlayerName .. " in recovery for " .. duration .. " mintue(s) and charged $".. 100*totaltime ..".", thePlayer, 255, 0, 0)
								exports.global:sendMessageToAdmins("AdmWrn: " .. targetPlayerName .. " was put in recovery for " .. duration .. " minute(s) by " .. getPlayerName(thePlayer):gsub("_"," ") .. ".")
								outputChatBox("You were put in recovery by " .. getPlayerName(thePlayer) .. " for " .. duration .. " minute(s) and charged $".. 100*totaltime ..".", targetPlayer, 255, 0, 0)
								exports.logs:dbLog(thePlayer, 4, targetPlayer, "RECOVERY " .. duration)
								local r = getRealTime()
								if r.hour + duration >= 24 then
									local timeString = ("%04d%02d%02d%02d%02d%02d"):format(r.year+1900, r.month + 1, r.monthday + 1, r.hour + duration - 24,r.minute, r.second)
									mysql:query_free("UPDATE characters SET recoverytime='" ..timeString.. "' WHERE id = " .. dbid)
								else
									local timeString = ("%04d%02d%02d%02d%02d%02d"):format(r.year+1900, r.month + 1, r.monthday, r.hour + duration,r.minute, r.second)
									mysql:query_free("UPDATE characters SET recoverytime='" ..timeString.. "' WHERE id = " .. dbid) 
								end
							else
								outputChatBox("You cannnot put someone in recovery for that much time.", thePlayer, 255, 0, 0)
							end
						--[[else
							outputChatBox("You must be in the hospital to do this command.", thePlayer, 255, 0, 0)
						end]]
					--[[else
						outputChatBox("You cannot recover yourself.", thePlayer, 255, 0, 0)
					end]]
				else
					outputChatBox("You have no basic medic skills, contact the LSFD.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("The player is not logged in.", thePlayer, 255,0,0)
			end
		end
	end
end
addCommandHandler("recovery", recoveryPlayer)

function scanForRecoveryRelease(player, eventname)
	local tick = getTickCount()
	local counter = 0
	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do 
		local logged = getElementData(value, "loggedin")
		if (logged==1) then -- Check all logged in players.
			local dbid = getElementData(value, "dbid")
			local result1 = mysql:query_fetch_assoc( "SELECT `recovery` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
			local mm = tonumber(result1["recovery"])
			if (mm==1) then
				local result2 = mysql:query_fetch_assoc( "SELECT `recoverytime` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
				local nn = tonumber(result2["recoverytime"])
				local currenttime = getRealTime()
				local currenttimereal = ("%04d%02d%02d%02d%02d%02d"):format(currenttime.year+1900, currenttime.month + 1, currenttime.monthday, currenttime.hour,currenttime.minute, currenttime.second)
				local bb = tonumber(currenttimereal)
				if (nn<bb) then -- Is the time up? If yes:
					setElementFrozen(value, false)
					mysql:query_free("UPDATE characters SET recovery='0' WHERE id = " .. dbid) -- Allow them to move, and revert back to recovery type set to 0.
					mysql:query_free("UPDATE characters SET recoverytime=NULL WHERE id = " .. dbid)
					outputChatBox("You are no longer in recovery!", value, 0, 255, 0) -- Let them know about it!
				else
					setElementFrozen(value, true) -- If they are still in recovery, then make sure they are frozen (if they login).
					if (player==value) and (eventname=="accounts:characters:spawn") then
						outputChatBox("You are still in recovery.", value, 255,0,0)
					end
				end
			end
		end
	end
	local tickend = getTickCount()
end
setTimer(scanForRecoveryRelease, 100000, 0) -- Check every 1 minute.

function scanForRecoveryReleaseF10(player, eventname)
	local tick = getTickCount()
	local counter = 0
	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do 
		local logged = getElementData(value, "loggedin")
		if (logged==1) then -- Check all logged in players.
			local dbid = getElementData(value, "dbid")
			local result1 = mysql:query_fetch_assoc( "SELECT `recovery` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
			local mm = tonumber(result1["recovery"])
			if (mm==1) then
				local result2 = mysql:query_fetch_assoc( "SELECT `recoverytime` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
				local nn = tonumber(result2["recoverytime"])
				local currenttime = getRealTime()
				local currenttimereal = ("%04d%02d%02d%02d%02d%02d"):format(currenttime.year+1900, currenttime.month + 1, currenttime.monthday, currenttime.hour,currenttime.minute, currenttime.second)
				local bb = tonumber(currenttimereal)
				if (nn<bb) then -- Is the time up? If yes:
					setElementFrozen(value, false)
					mysql:query_free("UPDATE characters SET recovery='0' WHERE id = " .. dbid) -- Allow them to move, and revert back to recovery type set to 0.
					mysql:query_free("UPDATE characters SET recoverytime=NULL WHERE id = " .. dbid)
					outputChatBox("You are no longer in recovery!", value, 0, 255, 0) -- Let them know about it!
				else
					setElementFrozen(value, true) -- If they are still in recovery, then make sure they are frozen (if they login).
					if (player==value) and (eventname=="accounts:characters:spawn") then
						outputChatBox("You are still in recovery.", value, 255,0,0)
					end
				end
			end
		end
	end
	local tickend = getTickCount()
end
addEventHandler("accounts:characters:spawn", getRootElement(), scanForRecoveryReleaseF10)

function prescribe(thePlayer, commandName, ...)
    local team = getPlayerTeam(thePlayer)
	if (getTeamName(team)=="Bone County Emergency Services") then
		if not (...) then
			outputChatBox("SYNTAX /" .. commandName .. " [prescription value]", thePlayer, 255, 184, 22)
		else
			local itemValue = table.concat({...}, " ")
			itemValue = tonumber(itemValue) or itemValue
			if not(itemValue=="") then
				exports.global:giveItem( thePlayer, 132, itemValue )
				outputChatBox("The prescription '" .. itemValue .. "' has been processed.", thePlayer, 0, 255, 0)
				exports.global:sendMessageToAdmins(getPlayerName(thePlayer):gsub("_"," ") .. " has made a prescription with the value of: " .. itemValue .. ".")
				exports.logs:dbLog(thePlayer, 4, thePlayer, "PRESCRIPTION " .. itemValue)
			end
		end
	end
end
addCommandHandler("prescribe", prescribe)

-- /revive
function revivePlayerFromPK(thePlayer, commandName, targetPlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			
			if targetPlayer then
				if getElementData(targetPlayer, "dead") == 1 then
					triggerClientEvent(targetPlayer,"es-system:closeRespawnButton",targetPlayer)
					--fadeCamera(thePlayer, true)
					--outputChatBox("Respawning...", thePlayer)
					if isTimer(changeDeathViewTimer) == true then
						killTimer(changeDeathViewTimer)
					end
					
					local x,y,z = getElementPosition(targetPlayer)
					local int = getElementInterior(targetPlayer)
					local dim = getElementDimension(targetPlayer)
					local skin = getElementModel(targetPlayer)
					local team = getPlayerTeam(targetPlayer)
					
					setPedHeadless(targetPlayer, false)
					setCameraInterior(targetPlayer, int)
					setCameraTarget(targetPlayer, targetPlayer)
					setElementData(targetPlayer, "dead", 0)	 
					spawnPlayer(targetPlayer, x, y, z, 0)--, team)
					
					setElementModel(targetPlayer,skin)
					setPlayerTeam(targetPlayer, team)
					setElementInterior(targetPlayer, int)
					setElementDimension(targetPlayer, dim)
					triggerEvent("updateLocalGuns", targetPlayer)
					local adminTitle = tostring(exports.global:getPlayerAdminTitle(thePlayer))
					outputChatBox("You have been revived by "..tostring(exports.global:getPlayerAdminTitle(thePlayer)).." "..tostring(getPlayerName(thePlayer):gsub("_"," "))..".", targetPlayer, 0, 255, 0)
					outputChatBox("You have revived "..tostring(getPlayerName(targetPlayer):gsub("_"," "))..".", thePlayer, 0, 255, 0)
					exports.global:sendMessageToAdmins("AdmCmd: "..tostring(exports.global:getPlayerAdminTitle(thePlayer)).." "..getPlayerName(thePlayer).." revived "..tostring(getPlayerName(targetPlayer))..".")
					exports.logs:dbLog(thePlayer, 4, targetPlayer, "REVIVED from PK")
				else
					outputChatBox(tostring(getPlayerName(targetPlayer):gsub("_"," ")).." is not dead.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("revive", revivePlayerFromPK, false, false)