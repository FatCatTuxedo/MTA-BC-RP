-- Misc
local function sortTable( a, b )
	if b[2] < a[2] then
		return true
	end

	if b[2] == a[2] and b[4] > a[4] then
		return true
	end

	return false
end

local function getPlayerScripterRank( player )
	if exports.integration:isPlayerLeadScripter( player ) then
		return "Lead Developer"
	elseif exports.integration:isPlayerScripter( player ) then
		return "Developer"
	else
		return ""
	end
end

local function getPlayerSupportRank( player )
	if exports.integration:isPlayerSupportManager( player ) then
		return "Senior Supporter"
	elseif exports.integration:isPlayerSupporter( player ) then
		return "Supporter"
	else
		return ""
	end
end

function showStaff( thePlayer, commandName )
	local logged = getElementData(thePlayer, "loggedin")
	local info = {}
	local isOverlayDisabled = getElementData(thePlayer, "hud:isOverlayDisabled")
	
		if(logged==1) then
		local players = exports.global:getAdmins()
		local counter = 0

		admins = {}

		if isOverlayDisabled then
			outputChatBox("SMT:", thePlayer, 193, 0, 8)
		else
			table.insert(info, {"Server Management Team:", 193, 0, 8, 255, 1, "title"})
		end

		for k, arrayPlayer in ipairs(players) do
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if tonumber(getElementData( arrayPlayer, "admin_level" )) > 4 then
					if exports.integration:isPlayerTrialAdmin(arrayPlayer) and hiddenAdmin == 0 then
						admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "admin_level" ), getElementData( arrayPlayer, "duty_admin" ), exports.global:getPlayerName( arrayPlayer ) }
					end
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getAdminTitle1(arrayPlayer)
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			if hiddenAdmin == 0 or exports.integration:isPlayerTrialAdmin(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"

				if(v[3]==1)then
					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 255, 255, 255, 255, 1, "default"})
					end
				else
					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
					end
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("     Currently no server management members online.", thePlayer)
			else
				table.insert(info, {"     Currently no server management members online.", 255, 255, 255, 255, 1, "default"})
			end
		end
		--outputChatBox("Use /gms to see a list of gamemasters.", thePlayer)
	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end
	
	if(logged==1) then
		local players = exports.global:getAdmins()
		local counter = 0

		admins = {}

		if isOverlayDisabled then
			outputChatBox("ADMINISTRATORS:", thePlayer, 14,194,255)
		else
			table.insert(info, {"Administration Team:", 14,194,255, 255, 1, "title"})
		end

		for k, arrayPlayer in ipairs(players) do
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if tonumber(getElementData( arrayPlayer, "admin_level" )) > 0 and tonumber(getElementData( arrayPlayer, "admin_level" )) < 5 then
					if exports.integration:isPlayerTrialAdmin(arrayPlayer) and hiddenAdmin == 0 then
						admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "admin_level" ), getElementData( arrayPlayer, "duty_admin" ), exports.global:getPlayerName( arrayPlayer ) }
					end
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getAdminTitle1(arrayPlayer)
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			if hiddenAdmin == 0 or exports.integration:isPlayerTrialAdmin(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"

				if(v[3]==1)then
					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 255, 255, 255, 255, 1, "default"})
					end
				else
					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
					end
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("     Currently no administrators online.", thePlayer)
			else
				table.insert(info, {"     Currently no administrators online.", 255, 255, 255, 255, 1, "default"})
			end
		end
		--outputChatBox("Use /gms to see a list of gamemasters.", thePlayer)
	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end

	--GMS--
	if(logged==1) then
		local players = exports.global:getGameMasters()
		local counter = 0

		admins = {}
		if isOverlayDisabled then
			outputChatBox("SUPPORTERS:", thePlayer, 70, 200, 30)
		else
			table.insert(info, {"Helpers:",70, 200, 30, 255, 1, "title"})
		end
		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if tonumber(getElementData( arrayPlayer, "supporter_level" )) > 0 then
					admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "account:gmlevel" ), getElementData( arrayPlayer, "duty_supporter" ), exports.global:getPlayerName( arrayPlayer ) }
				end
			end
		end

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local level = getElementData(arrayPlayer, "supporter_level")
			local adminTitle = "Player"
				if level == 1 then
					adminTitle = "Trial Helper"
				elseif level == 2 then
					adminTitle = "Helper"
								elseif level == 3 then
					adminTitle = "Helper Manager"
				end

			--if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"
			--end

			if(v[3] == 1)then
				if isOverlayDisabled then
					outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
				else
					table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 255, 255, 255, 255, 1, "default"})
				end
			else
				if isOverlayDisabled then
					outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
				else
					table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("     Currently no helpers online.", thePlayer)
			else
				table.insert(info, {"     Currently no helpers online.", 255, 255, 255, 255, 1, "default"})
			end
		end

	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end

	--VCTs--
	if(logged==1) then

-- scripters --
	if(logged==1) then
		local players = exports.pool:getPoolElementsByType("player")
		local counter = 0

		admins = {}

		if isOverlayDisabled then
			outputChatBox("Developers:", thePlayer, 255,20,147)
		else
			table.insert(info, {"Development Team:", 255,20,147, 255, 1, "title"})
		end

		for k, arrayPlayer in ipairs(players) do
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if tonumber(getElementData( arrayPlayer, "scripter_level" )) > 0 then
					if hiddenAdmin == 0 then
						admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "scripter_level" ), getElementData( arrayPlayer, "duty_dev" ), exports.global:getPlayerName( arrayPlayer ) }
					end
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = "Dev"
			if v[2] == 1 then
				adminTitle = "Web Developer"
			elseif v[2] == 2 then
				adminTitle = "Trial Developer"
			elseif v[2] == 3 then
				adminTitle = "Developer"
			else
				adminTitle = "Lead Developer"
			end
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			if hiddenAdmin == 0 then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"

				if(v[3] == 1)then
					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 255, 255, 255, 255, 1, "default"})
					end
				else
					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
					end
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("     Currently no developers online.", thePlayer)
			else
				table.insert(info, {"     Currently no developers online.", 255, 255, 255, 255, 1, "default"})
			end
		end
		
		if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
		end
		--outputChatBox("Use /gms to see a list of gamemasters.", thePlayer)
	end
	
	if(logged==1) then
		local players = exports.pool:getPoolElementsByType("player")
		local counter = 0

		admins = {}

		if isOverlayDisabled then
			outputChatBox("Other:", thePlayer,255,255,0)
		else
			table.insert(info, {"Other:", 255,255,0, 255, 1, "title"})
		end

		for k, arrayPlayer in ipairs(players) do
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if tonumber(getElementData( arrayPlayer, "vct_level" )) > 0 then
					if hiddenAdmin == 0 then
						admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "vct_level" ), 0, exports.global:getPlayerName( arrayPlayer ) }
					end
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = "Unknown"
			if v[2] == 1 then
				adminTitle = "Mapper"
			elseif v[2] == 2 then
				adminTitle = "Handling Editor"
			end
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			if hiddenAdmin == 0 then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"

					if isOverlayDisabled then
						outputChatBox("     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," "), thePlayer, 100, 100, 100)
					else
						table.insert(info, {"     " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," "), 255, 255, 255, 255, 1, "default"})
					end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("     Currently no other staff online.", thePlayer)
			else
				table.insert(info, {"     Currently no other staff online.", 255, 255, 255, 255, 1, "default"})
			end
		end
		--outputChatBox("Use /gms to see a list of gamemasters.", thePlayer)
	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end	

	end

	if logged == 1 then
		if not isOverlayDisabled then
			exports.hud:sendTopRightNotification(thePlayer, info, 350)
		end
	end
end
addCommandHandler("admins", showStaff, false, false)
addCommandHandler("gms", showStaff, false, false)
addCommandHandler("staff", showStaff, false, false)

function toggleOverlay(thePlayer, commandName)
	if getElementData(thePlayer, "hud:isOverlayDisabled") then
		setElementData(thePlayer, "hud:isOverlayDisabled", false)
		outputChatBox("You enabled overlay menus.",thePlayer)
	else
		setElementData(thePlayer, "hud:isOverlayDisabled", true)
		outputChatBox("You disabled overlay menus.", thePlayer)
	end
end
addCommandHandler("toggleOverlay", toggleOverlay, false, false)
addCommandHandler("togOverlay", toggleOverlay, false, false)
