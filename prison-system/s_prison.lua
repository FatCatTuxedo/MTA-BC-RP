mysql = exports.mysql

local JFOX_MDC = 532

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end

addEventHandler("onResourceStart", resourceRoot, function()
	local result = mysql:query( "SELECT * FROM jailed ORDER BY id ASC" )
	if result then
			 	t = { }
				while true do
					local row = mysql:fetch_assoc( result )
					if row then
						table.insert(t, { row.id, row.charid, row.charactername, row.jail_time, row.convictionDate, row.updatedBy, row.charges, row.cell, row.fine })
					else
						break
					end
				end
				mysql:free_result( result )
			end
			timeReleaseCheck()
			setTimer(timeReleaseCheck, 300000, 0)
		end
	)

function startGUI(player)
	local logged = getElementData(player, "loggedin")
	if (logged==1) then
		local theTeam = getPlayerTeam(player)
		local factionType = getElementData(theTeam, "type")
		if factionType==2 or exports.integration:isPlayerTrialAdmin(player) then
			triggerClientEvent(player, "PrisonGUI", player, t)
		end
	end
end
addCommandHandler("arrest", startGUI)
addEvent("startPrisonGUI", true)
addEventHandler("startPrisonGUI", root, startGUI)

addEvent("removePrisoner", true)
addEventHandler("removePrisoner", resourceRoot,
	function( row, removeid, fromGUI )
			local result = mysql:query_free( "DELETE FROM jailed WHERE id=" .. mysql:escape_string(removeid) .. "" )
			local charID = tonumber(t[row][2])
			if result then
				if not fromGUI then
					local query = mysql:query_free("UPDATE characters SET pdjail=0 WHERE id="..mysql:escape_string(charID))
					exports.logs:dbLog(client, 35, charID, "Removed from jail CharacterID= "..tostring(t[row][2]))
				else
					sendPrisonMsg(getPlayerName(client).." removed "..t[row][3].." from jail.")
					local players = exports.pool:getPoolElementsByType("player")
					for key, value in ipairs(players) do
						if getElementData(value, "dbid") == tonumber(t[row][2]) then
							outputChatBox("You were removed from jail by ".. string.gsub(getPlayerName(client), "_", " "), value, 0, 255, 0)

							setElementPosition(value, x, y, z)
    						setElementDimension(value, dim)
    						setElementInterior(value, int)
    						removeElementData(value, "jailed")
							removeElementData(value, "jail_time")

							assignSkin(value)
    					end
    				end
    			end
				table.remove(t, row)
				if fromGUI then
					triggerClientEvent(client, "PrisonGUI:Refresh", client, t)
            	end
            else
                outputChatBox("Error, PS#01. Report on Mantis: bugs.owlgaming.net", client, 255, 0, 0)
			end
		end
)

addEvent("addPrisoner", true)
addEventHandler("addPrisoner", resourceRoot,
	function( name, cell, days, hours, charges, fine, online )
		local r = getRealTime()
		if days=="" then
			local days = 0
		end
		if online then
			if not isInArrestColshape(name) then
				outputChatBox("The target player must be within the processing area.", client, 255, 0, 0)
				return
			end
		else
			if not isInArrestColshape(client) then
				outputChatBox("You must be within the processing area to add a prisoner.", client, 255, 0, 0)
			end
		end
		if duplicateCheck(returnWhat(name, online)) then
			outputChatBox("This player is already serving a sentence, use update prisoner instead.", client, 255, 0, 0)
			return
		end
		local days = tonumber(days)*24
		local jailTime = ( r.timestamp + (tonumber(hours) + days) * 60 * 60  )
		local query = mysql:query_free("INSERT INTO jailed SET charid=(SELECT id FROM characters WHERE charactername='".. mysql:escape_string(returnWhat(name, online)) .. "'), charactername='" .. mysql:escape_string(returnWhat(name, online)) .. "', jail_time=".. mysql:escape_string(jailTime) ..", updatedBy='".. mysql:escape_string(updatedWho(client, online)) .."', charges='" .. mysql:escape_string(charges) .. "', cell='" .. mysql:escape_string(cell) .. "', fine='" .. mysql:escape_string(fine) .. "'")
		if query then
			mysql:query_free("UPDATE characters SET pdjail=1 WHERE charactername='".. mysql:escape_string(returnWhat(name, online)) .. "'")


			local result = mysql:query( "SELECT * FROM jailed WHERE id=LAST_INSERT_ID()")
			local row = mysql:fetch_assoc( result )
			if row then
				table.insert(t, #t+1, { row.id, row.charid, row.charactername, row.jail_time, row.convictionDate, row.updatedBy, row.charges, row.cell, row.fine })

				-- attempt to find mdc account, otherwise use John Fox
				local account = JFOX_MDC
				local playerName = getPlayerName( client ):split( "_" )
				local firstLetter = string.sub( playerName[ 1 ], 1, 1 )
				local playerName = firstLetter .. playerName[ 2 ]
				local findAccountID = exports.mysql:query( "SELECT `id` FROM `mdc_users` WHERE `user` = '"..playerName.."'")
				local accountID = mysql:fetch_assoc(findAccountID)
				if accountID then
					account = accountID.id
				end
				mysql:free_result( findAccountID )

				-- automatically submit to MDC
				local charID = getElementData( name, 'dbid' )
				setElementData( client, 'mdc_account', account ) -- set it so it appears as JFox who posted the paperwork to the MDC
				triggerEvent( 'mdc-system:add_crime', client, charID, getPlayerName( name ), charges, 'Fine: ' .. fine .. ' & Prison: ' .. ( days + hours ) .. ' hours.' )

				triggerClientEvent(client, "PrisonGUI:Close", client, t) -- close the prison window as it will open MDC window
				exports.logs:dbLog(client, 35, returnWhat(name, online), "Added to jail cell: "..row.cell.." character: "..row.charactername.." JailStamp: "..row.jail_time.." Charges: "..row.charges.." Fine: "..row.fine)
				if online then
					outputChatBox("You have been placed in jail by "..string.gsub(getPlayerName(client), "_", " ")..".", name, 0, 255, 0)
					sendPrisonMsg(getPlayerName(client).." added "..getPlayerName(name).." to jail cell: "..row.cell)

					if tonumber(fine)>0 then -- Issue Fine
						local amount = tonumber(fine) -- Math
						local bankmoney = getElementData(name, "bankmoney")
						
						exports.anticheat:changeProtectedElementDataEx(name, "bankmoney", bankmoney-amount) -- Take from player
						mysql:query_free("UPDATE characters SET bankmoney=bankmoney-" .. mysql:escape_string(amount) .." WHERE charactername='".. mysql:escape_string(returnWhat(name, online)) .. "'")
						
						local tax = exports.global:getTaxAmount() -- Split between gov and PD
						local theTeam = getPlayerTeam(client) 
						exports.global:giveMoney(getTeamFromName("Fort Carson Municipal Government"), amount*tax)
						exports.global:giveMoney(theTeam, math.ceil((1-tax)*amount))

						outputChatBox("Fine of $"..amount.." issued.", name, 0, 255, 0)
					end
					local restrainedObj = getElementData(name, "restrainedObj") -- Remove restraints
					if restrainedObj then
						toggleControl(name, "sprint", true)
						toggleControl(name, "jump", true)
						toggleControl(name, "accelerate", true)
						toggleControl(name, "brake_reverse", true)
						exports.anticheat:changeProtectedElementDataEx(name, "restrain", 0, true)
						exports.anticheat:changeProtectedElementDataEx(name, "restrainedBy", false, true)
						exports.anticheat:changeProtectedElementDataEx(name, "restrainedObj", false, true)
						if restrainedObj == 45 then -- If handcuffs.. take the key
							local dbid = getElementData(name, "dbid")
							exports['item-system']:deleteAll(47, dbid)
						end
						exports.global:giveItem(thePlayer, restrainedObj, 1)
						mysql:query_free("UPDATE characters SET cuffed = 0, restrainedby = 0, restrainedobj = 0 WHERE id = " .. mysql:escape_string(getElementData( name, "dbid" )) )
					end
					setPedWeaponSlot(name,0)
					activateJail(row.charid, name)
				end
				mysql:free_result(result)
			else
				outputChatBox("Error, PS#02. Report on Mantis: bugs.owlgaming.net", client, 255, 0, 0)
			end
		else
			outputChatBox("No character found with that name.", client, 255, 0, 0)
		end
	end
)

addEvent("changePrisoner", true)
addEventHandler("changePrisoner", resourceRoot,
	function( name, cell, days, hours, charges, row1, online )
		local r = getRealTime()
		if days=="" then
			days = 0
		elseif days=="Life" and hours=="Sentence" then
			days = 9999
			hours = 999
		elseif days=="Awaiting" and hours=="Release" then
			days = 0
			hours = 0
		end
		local days = tonumber(days)*24
		local jailTime = ( r.timestamp + (tonumber(hours) + days) * 60 * 60  )
		local query = mysql:query_free("UPDATE jailed SET jail_time=".. mysql:escape_string(jailTime) ..", updatedBy='".. mysql:escape_string(updatedWho(client, online)) .."', charges='" .. mysql:escape_string(charges) .. "', cell='" .. mysql:escape_string(cell) .. "' WHERE charactername='".. mysql:escape_string(returnWhat(name, online)).."'")
		if query then
			local result = mysql:query( "SELECT * FROM jailed WHERE charactername='"..mysql:escape_string(returnWhat(name, online)).."'")
			local row = mysql:fetch_assoc( result )
			if row then
				table.remove(t, row1)
				table.insert(t, #t+1, { row.id, row.charid, row.charactername, row.jail_time, row.convictionDate, row.updatedBy, row.charges, row.cell, row.fine })
				triggerClientEvent(client, "PrisonGUI:Refresh", client, t)
				exports.logs:dbLog(client, 35, returnWhat(name, online), "Updated prisoner data. New data: "..row.cell.." character: "..row.charactername.." JailStamp: "..row.jail_time.." Charges: "..row.charges.." Fine: "..row.fine)

				if online then
					outputChatBox("Your prisoner details has been updated.", name, 0, 255, 0)
					activateJail(row.charid, name)
				end
			else
				outputChatBox("Error, PS#02. Report on Mantis: bugs.owlgaming.net", client, 255, 0, 0)
			end
			mysql:free_result(result)
		else
			outputChatBox("No character found with that name.", client, 255, 0, 0)
		end
	end
)

function returnWhat(name, online)
	if online then
		return getPlayerName(name)
	else
		return string.gsub(name, " ", "_")
	end
end

function activateJail(id, target)
	if not id then return end
	for key, value in ipairs(t) do
		if value[2] == id then
			setElementData(target, "jailed", 1)
			setElementData(target, "jail_time", value[4])
			setElementData(target, "jail:id", value[1])
			setElementData(target, "jail:cell", value[8])

			local cell = cells[value[8]]
			setElementPosition(target, cell[1], cell[2], cell[3])
    		setElementDimension(target, cell[5])
    		setElementInterior(target, cell[4])

    		assignSkin(target) -- Assign Prisoner Skins
    	end
    end
end

function assignSkin(source)
	skin, skinID = nil, nil
	if getElementData(source, "jailed") then
	-- I put all the id's in g_prison for you.
		local race = getElementData(source, "race")
    	if getElementData(source, "gender") == 1 then
    		-- Female
	    	if race == 0 then
				-- Black Female
				skin = bFemale
				skinID = bFemaleID
			elseif race == 1 then
				-- White Female
				skin = wFemale
				skinID = wFemaleID
			else
				-- Asian Female
				skin = aFemale
				skinID = aFemaleID
			end
		else
			-- Male
			if race == 0 then
				-- Black Male
				skin = bMale
				skinID = bMaleID
			elseif race == 1 then
				-- White Male
				skin = wMale
				skinID = wMaleID
			else
				-- Asian Male
				skin = aMale
				skinID = aMaleID
			end
		end
	else
		local items = exports['item-system']:getItems( source ) -- [] [1] = itemID [2] = itemValue
		for itemSlot, itemCheck in ipairs(items) do
			if itemCheck[1] == 16 then
				local skinData = split(tostring(itemCheck[2]), ':')
				skin = tonumber(skinData[1])
				skinID = tonumber(skinData[2])
			end
		end
	end

	if skin then
		setElementModel(source, skin)
		setElementData(source, "clothing:id", skinID or nil)
		mysql:query_free( "UPDATE characters SET skin = '" .. exports.mysql:escape_string(skin) .. "', clothingid = '" .. exports.mysql:escape_string(skinID or 0) .. "' WHERE id = '" .. exports.mysql:escape_string(getElementData( source, "dbid" )).."'" )
	end
end

function duplicateCheck(name)
	if not name then return end
	for key, value in ipairs(t) do
		if value[3] == name then
			return true
		end
		return false
	end
end

function checkForRelease(client)
	local found = false
	for key, value in ipairs(t) do
		if tonumber(value[2]) == tonumber(getElementData(client, "dbid")) then
			local found = true
			local days, hours, remainingtime = cleanMath(value[4])
    		if remainingtime<=0 then
    			triggerEvent("removePrisoner", resourceRoot, key, value[1])
    			if getElementData(client, "jailed") then
					removeElementData(client, "jailed")
					removeElementData(client, "jail_time")
					removeElementData(client, "jail:id")
				end
    				setElementPosition(client, x, y, z)
    				setElementDimension(client, dim)
    				setElementInterior(client, int)
    				assignSkin(client)
					outputChatBox("Your time has been served!", client, 0, 255, 0)
					return
				else
					outputChatBox("You are currently in PD jail. /jailtime to review your sentence.", client, 255, 0, 0)
					setElementData(client, "jailed", 1)
					setElementData(client, "jail_time", value[4])
					setElementData(client, "jail:id", value[1])
					setElementData(client, "jail:cell", value[8])
					local cell = cells[value[8]]
					if isPedDead(client) then
						spawnPlayer(client, cell[1], cell[2], cell[3], 0, getElementModel(client))
						setCameraTarget(client)
					else
						setElementPosition(client, cell[1], cell[2], cell[3])
					end
					assignSkin(client)
    				setElementDimension(client, cell[5])
    				setElementInterior(client, cell[4])
    		return end
    	end
    end
    if not found then
    	local charID = getElementData(client, "dbid")
    	local query = mysql:query_free("UPDATE characters SET pdjail=0 WHERE id="..mysql:escape_string(charID))
    		setElementPosition(client, x, y, z)
    		setElementDimension(client, dim)
    		setElementInterior(client, int)
    	if getElementData(client, "jailed") then
			removeElementData(client, "jailed")
			removeElementData(client, "jail_time")
			removeElementData(client, "jail:id")
		end
		assignSkin(client)
	end
end
--addEventHandler("jail:onCharacterLogin", getRootElement(), checkForRelease)

addCommandHandler("jailtime", function(thePlayer)
		local days, hours, remainingtime = cleanMath(getElementData(thePlayer, "jail_time"))
		if not remainingtime then
			outputChatBox("You are not serving a jail sentence.", thePlayer, 255, 0, 0)
		elseif remainingtime<=0  then
			for key, value in ipairs(t) do
				if tonumber(value[2]) == tonumber(getElementData(thePlayer, "dbid")) then
				triggerEvent("removePrisoner", resourceRoot, key, value[1])
    			if getElementData(thePlayer, "jailed") then -- If called from /jailtime
					removeElementData(thePlayer, "jailed")
					removeElementData(thePlayer, "jail_time")
				end
				assignSkin(client)
    			setElementPosition(thePlayer, x, y, z)
    			setElementDimension(thePlayer, dim)
    			setElementInterior(thePlayer, int)
				outputChatBox("Your time has been served!", thePlayer, 0, 255, 0)
				end
			end
		else
			if tonumber(hours) < 1 and tonumber(days) <= 0 then
				local minutes = ("%.1f"):format(remainingtime/60)
				outputChatBox("You currently have ".. minutes .. " minutes remaining in your sentence. You are prisoner ID "..getElementData(thePlayer, "jail:id")..", in cell "..getElementData(thePlayer, "jail:cell"), thePlayer, 255, 255, 0)
			else
				outputChatBox("You currently have ".. days .. " days and " .. hours .. " hours remaining in your sentence. You are prisoner ID ".. getElementData(thePlayer, "jail:id")..", in cell "..getElementData(thePlayer, "jail:cell"), thePlayer, 255, 255, 0)
			end
		end
end )

function timeReleaseCheck()
	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do
		if getElementData(value, "loggedin")==1 then
		for _,res in ipairs(t) do
			if tonumber(res[2]) == tonumber(getElementData(value, "dbid")) then
				local days, hours, remainingtime = cleanMath(res[4])
    			if remainingtime<=0 then
    				outputDebugString("JAIL: Timer removed " .. string.gsub(tostring(res[3]), "_", " ") .. " from jail.")
    				outputChatBox("Your time has been served!", value, 0, 255, 0)
    				triggerEvent("removePrisoner", resourceRoot, _, res[1])
    				setElementPosition(value, x, y, z)
    				setElementDimension(value, dim)
    				setElementInterior(value, int)
    				assignSkin(client)
				else
					local minutes = ("%.1f"):format(remainingtime/60)
					outputDebugString("JAIL: Player remaining in jail ".. string.gsub(tostring(res[3]), "_", " ") .." Minutes: ".. tostring(minutes) .. ".")
					--outputChatBox("You are currently in PD jail. /jailtime to review your sentence.", value, 255, 0, 0)
					setElementData(value, "jailed", 1)
					setElementData(value, "jail_time", res[4])
					setElementData(value, "jail:id", res[1])
					setElementData(value, "jail:cell", res[8])
    			end
    		end
    	end
    end
    end
end

function sendPrisonMsg(string)
    local string = string.gsub(string, "_", " ")
    for _, v in ipairs(exports.pool:getPoolElementsByType("player")) do
        local team = getPlayerTeam( v )
        if getTeamFromName("Bone County Sheriff's Office") == team or getTeamFromName("San Andreas Superior Court") == team then
        	outputChatBox(string, v, 255, 0, 0)
        end
    end
end

function updatedWho(client, online)
	if online then
 		return getElementData(client, "account:username")
	else
 		return getPlayerName(client)
 	end
end

-- Speaker through all interiors/dimensions of the prison.
function processSpeakerMessage(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("SYNTAX: /"..commandName.." [message] - Sends a speaker-like message through the prison.", thePlayer)
		outputChatBox("You must be in the prison or in the courtyard. SASD usage only.", thePlayer)
	else
		local px, py, pz = getElementPosition(thePlayer)
		if (getElementInterior(thePlayer) == speakerInt and speakerDimensions[getElementDimension(thePlayer)] and exports.factions:isPlayerInFaction(thePlayer, 1)) or (getDistanceBetweenPoints3D( px, py, pz, speakerOutX, speakerOutY, speakerOutZ ) < 100 and exports.factions:isPlayerInFaction(thePlayer, 1)) then
			for k, v in ipairs(exports.pool:getPoolElementsByType("player")) do
				local arrayInt = getElementInterior(v)
				local arrayDim = getElementDimension(v)
				local aX, aY, aZ = getElementPosition(v) -- used for the courtyard message

				local message = table.concat({...}, " ")
				if arrayInt == speakerInt and speakerDimensions[arrayDim] then -- speakerInt and speakerDimensions are set in g_ config file
					if exports.factions:isPlayerInFaction(v, 1) then
						outputChatBox("PRISON INTERCOM ("..string.gsub(getPlayerName(thePlayer), "_", " ")..") o< "..message, v, 218, 165, 32)
					else
						outputChatBox("PRISON INTERCOM o< "..message, v, 218, 165, 32)
					end
				elseif getDistanceBetweenPoints3D( aX, aY, aZ, speakerOutX, speakerOutY, speakerOutZ ) < 100 then -- 100 meters from center of courtyard = you can hear it speakers
					if exports.factions:isPlayerInFaction(v, 1) then
						outputChatBox("PRISON INTERCOM ("..string.gsub(getPlayerName(thePlayer), "_", " ")..") o< "..message, v, 218, 165, 32)
					else
						outputChatBox("PRISON INTERCOM o< "..message, v, 218, 165, 32)
					end
				end
			end
		end
	end
end
addCommandHandler("intercom", processSpeakerMessage)
