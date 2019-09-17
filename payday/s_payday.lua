local mysql = exports.mysql

local incomeTax = 0.25
local taxVehicles = {}
local insuranceVehicles = {}
local vehicleCount = {}
local taxHouses = {}
local threads = { }
local threadTimer = nil
local govAmount = 10000000
local unemployedPay = 400

function payWage(player, pay, faction, tax)
	local dbid = tonumber(getElementData(player, "dbid"))
	local governmentIncome = 0
	local bankmoney = getElementData(player, "bankmoney")
	local noWage = pay == 0
	local donatormoney = 0
	local startmoney = bankmoney

	if (exports.donators:hasPlayerPerk(player, 4)) then
		donatormoney = donatormoney + 25
	end

	if (exports.donators:hasPlayerPerk(player, 5)) then
		donatormoney = donatormoney + 75
	end

 	local interest = 0
 	local cP = 0
 	if bankmoney > 0 then
		interest = math.min(5000, math.floor(3 * math.sqrt(bankmoney)))
		if (interest > 500) then
			interest = 500
		end
		cP = interest / bankmoney * 100
	end

	if interest ~= 0 then
		mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (-57, " .. dbid .. ", " .. interest .. ", 'BANKINTEREST', 6)" )
	end

	-- business money
	local profit = getElementData(player, "businessprofit")
	exports.anticheat:changeProtectedElementDataEx(player, "businessprofit", 0, false)
	bankmoney = bankmoney + math.max( 0, pay ) + interest + profit + donatormoney

	-- rentable houses
	local rent = 0
	local rented = nil -- store id in here

	for key, value in ipairs(getElementsByType("interior")) do -- Who the hell made this bullsit lol / MAXIME
		local interiorStatus = getElementData(value, "status")
		local owner = tonumber( interiorStatus[4] )

		if (owner) and (owner == dbid) and (getElementData(value, "status")) and (tonumber(interiorStatus[1]) == 3) and (tonumber(interiorStatus[5]) > 0) then
			rent = rent + tonumber(interiorStatus[5])
			rented = tonumber(getElementData(value, "dbid"))
		end
	end

	if not faction then
		if bankmoney > 25000 then
			noWage = true
			pay = 0
		elseif pay > 0 then
			governmentIncome = governmentIncome - pay
			mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (-3, " .. dbid .. ", " .. pay .. ", 'STATEBENEFITS', 6)" )
		else
			pay = 0
		end
	else
		if pay > 0 then
			local teamid = getElementData(player, "faction")
			if teamid <= 0 then
				teamid = 0
			else
				teamid = -teamid
			end
			mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. teamid .. ", " .. dbid .. ", " .. pay .. ", 'WAGE', 6)" )
		else
			pay = 0
		end
	end

	if tax > 0 then
		pay = pay - tax
		bankmoney = bankmoney - tax
		governmentIncome = governmentIncome + tax
		mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. dbid .. ", -3, " .. tax .. ", 'INCOMETAX', 6)" )
	end

	local vtax = taxVehicles[ dbid ] or 0
	if vtax > 0 then
		vtax = math.min( vtax, bankmoney )
		bankmoney = bankmoney - vtax
		governmentIncome = governmentIncome + vtax
		mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. dbid .. ", -3, " .. vtax .. ", 'VEHICLETAX', 6)" )
	end

	--vehicle insurance

	local totalInsFee, totalInsFeePerVehicles, totalInsFeePerFactions = 0, {}, {}
	if exports.global:isResourceRunning("insurance") and  exports.global:isResourceRunning("factions") then
		--outputDebugString("Payday insurance running")
		totalInsFee, totalInsFeePerVehicles, totalInsFeePerFactions = exports.insurance:analyzeInsurance(insuranceVehicles[ dbid ], getElementData(player, "dbid"))
		if totalInsFee > 0 then
			if bankmoney >= totalInsFee then
				bankmoney = bankmoney - totalInsFee
				for factionId, data in pairs(totalInsFeePerFactions) do
					if data.fee > 0 then
						local theFaction = exports.factions:getTeamFromFactionID(factionId)
						if exports.bank:giveBankMoney(theFaction, data.fee) then
							exports.bank:addBankTransactionLog(dbid, -factionId, data.fee, 2, "Insurance fees for "..(#(data.vehs)).." vehicles.")
						end
					end
				end
			else
				if  exports.global:isResourceRunning("announcement") then
					local customerName = getPlayerName(player):gsub("_", " ")
					for factionId, data in pairs(totalInsFeePerFactions) do
						local details = 'List of insuranced vehicles from customer '..customerName..":\n\n"
						for i, vehid in pairs(data.vehs) do
							details = details..'Vehicle VIN #'..vehid.."\n"
						end
						details = details.."\nTotal: $"..exports.global:formatMoney(data.fee)
						exports.factions:sendNotiToAllFactionMembers(factionId, customerName.." has failed to pay his total insurance fees of $"..exports.global:formatMoney(data.fee).." over his "..(#(data.vehs)).." vehicles.", details)
					end
				end
			end
		end
	end

	local ptax = taxHouses[ dbid ] or 0
	if ptax > 0 then
		ptax = math.floor( ptax )
		ptax = math.min( ptax, bankmoney )
		bankmoney = bankmoney - ptax
		governmentIncome = governmentIncome + ptax
		mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. dbid .. ", -3, " .. ptax .. ", 'PROPERTYTAX', 6)" )
	end

	if (rent > 0) then
		if (rent > bankmoney)   then
			rent = -1
			call( getResourceFromName( "interior-system" ), "publicSellProperty", player, rented, false, true )
		else
			bankmoney = bankmoney - rent
			mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. dbid .. ", 0, " .. rent .. ", 'HOUSERENT', 6)" )
		end
	end

	-- save the bankmoney
	exports.anticheat:changeProtectedElementDataEx(player, "bankmoney", bankmoney, true)

	-- let the client tell them the (bad) news
	local grossincome = pay+profit+interest+donatormoney-rent-vtax-ptax
	triggerClientEvent(player, "cPayDay", player, faction, noWage and -1 or pay, profit, interest, donatormoney, tax, incomeTax, vtax, ptax, rent, grossincome, cP)
	return governmentIncome
end

function payAllWages(isForcePayday)
	if not isForcePayday then
		local mins = getRealTime().minute
		local minutes = 60 - mins
		if (minutes < 15) then
			minutes = minutes + 60
		end
		setTimer(payAllWages, 60000*minutes, 1, false)
	end
	loadWelfare( )
	threads = { }
	taxVehicles = {}
	vehicleCount = {}
	insuranceVehicles = {}

	for _, veh in pairs(getElementsByType("vehicle")) do
		if isElement(veh) then
			local owner, faction, registered = tonumber(getElementData(veh, "owner")) or 0, tonumber(getElementData(veh, "faction")) or 0, tonumber(getElementData(veh, "registered")) or 0
			local vehid = getElementData(veh, "dbid") or 0
			if vehid >0 and faction <= 0 and owner > 0 then
				-- Vehicle inactivity scanner / MAXIME / 2015.1.11

				local deletedByScanner = nil
				local active, reason = exports['vehicle-system']:isActive(veh)
				if not active and not exports['vehicle-system']:isProtected(veh) then
					local name = exports.global:getVehicleName(veh)
					if exports['vehicle-manager']:systemDeleteVehicle(vehid, "Deleted by Inactivity Scanner. Reason: "..reason) then
						local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
						local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"

						if owner > 0 and account then
							exports.announcement:makePlayerNotification(account.id, "Vehicle ID #"..vehid.." ("..name..") was taken away from "..characterName.."'s possession by the vehicle inactivity scanner.", "Reason: "..reason..". Your vehicle was marked as inactive because your character hasn't been logged in game for longer than 30 days or no body has ever started its engine for longer than 14 days while parking outdoor. \n\nAn inactive vehicle is a waste of resources and thus far the vehicle's ownership was removed or stripped from your possession to give other players opportunities to buy and use it more efficiently.\n\nThis vehicle wasn't unprotected. To prevent this to happen again to other vehicles of yours, you may want to spend your GC(s) to protect it from the inactive vehicle scanner on UCP.")
						end
						exports.global:sendMessageToAdmins("[VEHICLE] Vehicle ID #"..vehid.." ("..name..", owner: "..characterName.." - "..account.username..") has been deleted by the vehicle inactivity scanner. "..reason)
						deletedByScanner = true
					end
				end


				if registered == 1 and not deletedByScanner then
					--Taxes
					local tax = tonumber(getElementData(veh, "carshop:taxcost")) or 25
					if tax > 0 then
						taxVehicles[owner] = ( taxVehicles[owner] or 0 ) + ( tax * 1 )
						--[[vehicleCount[owner] = ( vehicleCount[owner] or 0 ) + 1
						if vehicleCount[owner] > 3 then -- $75 for having too much vehicles, per vehicle more than 3
							taxVehicles[owner] = taxVehicles[owner] + 50
						end]]
					end

					--Insurance
					if  exports.global:isResourceRunning("insurance") then
						local insuranceFee = getElementData(veh, "insurance:fee") or 0
						insurancefee = tonumber(insurancefee)
						local insuranceFaction = getElementData(veh, "insurance:faction") or 0
						insuranceFaction = tonumber(insuranceFaction)
						if insuranceFee > 0 and insuranceFaction > 0 then
							if not insuranceVehicles[owner] then insuranceVehicles[owner] = {} end
							if not insuranceVehicles[owner][vehid] then insuranceVehicles[owner][vehid] = {} end
							if not insuranceVehicles[owner][vehid][insuranceFaction] then insuranceVehicles[owner][vehid][insuranceFaction] = 0 end
							insuranceVehicles[owner][vehid][insuranceFaction] = insuranceVehicles[owner][vehid][insuranceFaction] + insuranceFee
						end
					end
				end
			end
		end
	end

	-- count all player props
	taxHouses = { }
	for _, property in pairs( getElementsByType( "interior" ) ) do
		local interiorStatus = getElementData(property, "status")
		local cost = tonumber(interiorStatus[5]) or 0
		local owner = tonumber(interiorStatus[4]) or 0
		local type = tonumber(interiorStatus[1])
		local intid = getElementData(property, "dbid")
		local name = getElementData(property, "name")
		if cost > 0 and owner > 0 and type < 2 then
			-- MAXIME
			local propertyTax = getPropertyTaxRate(interiorStatus[1])
			taxHouses[ interiorStatus[4] ] = ( taxHouses[ interiorStatus[4] ] or 0 ) + propertyTax * interiorStatus[5]
		end

		-- Interior inactivity scanner / MAXIME / 2015.1.11
		local active, reason = exports['interior-system']:isActive(property)
		if not active and not exports['interior-system']:isProtected(property) then
			if exports['interior-system']:unownProperty(intid, "Forcesold by Inactivity Scanner. Reason: "..reason) then
				local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
				local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"
				if owner > 0 and account then
					exports.announcement:makePlayerNotification(account.id, "Interior ID #"..intid.." ("..name..") was taken away from "..characterName.."'s possession by the interior inactivity scanner.", "Reason: "..reason..". Your interior was marked as inactive because no body has ever entered it for the last 14 days or your character(who owns it) hasn't been logged in game for 30 days.\n\nAn inactive interior is a waste of resources and thus far the interior's ownership was stripped from your possession to give other players opportunities to buy and use it more efficiently.\n\nThis interior wasn't unprotected. To prevent this to happen again to other interiors of yours, you may want to spend your GC(s) to protect it from the inactive interior scanner on UCP.")
				end
				exports.global:sendMessageToAdmins("[INTERIOR] Interior ID #"..intid.." ("..name..", owner: "..characterName.." - "..account.username..") has been forcesold by the interior inactivity scanner. "..reason)
			end
		end

		-- Internal Affairs / COURTEZBOI / 2015.2.4
		if getRealTime().weekday == 0 and getRealTime().hour == 0 then -- only run on sunday at midnight
			triggerEvent( "internal-affairs:submit", root )
		end
	end

	-- Get some data
	local players = exports.pool:getPoolElementsByType("player")
	govAmount = 1000000 --exports.global:getMoney(getTeamFromName("Fort Carson Municipal Government"))
	incomeTax = exports.global:getIncomeTaxAmount()

	-- Pay Check tooltip
	if(getResourceFromName("tooltips-system"))then
		triggerClientEvent("tooltips:showHelp", getRootElement(),12)
	end

	for _, value in ipairs(players) do
		if (tonumber(getElementData(value, "loggedin")) == 1) then
			local co = coroutine.create(doPayDayPlayer)
			coroutine.resume(co, value, isForcePayday)
			table.insert(threads, co)
		end
	end

	threadTimer = setTimer(resumeThreads, 100, 0)
end

function resumeThreads()
	local inFor = false
	--outputDebugString("resumeThreadsCalled")
	for threadRow, threadValue in ipairs(threads) do
		inFor = true
		coroutine.resume(threadValue)
		table.remove(threads,threadRow)
		break
	end

	if not inFor then
		-- Store the government money
		--exports.global:setMoney(getTeamFromName("Fort Carson Municipal Government"), govAmount)

		killTimer(threadTimer)
	end
end

function doPayDayPlayer(value, isForcePayday)
	if not isForcePayday then
		coroutine.yield()
	end
	if isForcePayday then
		exports.global:sendMessageToAdmins("[PAYDAY]: An admin has forced payday for player " .. getPlayerName(value))
	end
	if not ( isElement( value ) and getElementType( value ) == 'player' ) then -- only run payday for players?
		return
	end

	local sqlupdate = ""
	local logged = getElementData(value, "loggedin")
	local timeinserver = getElementData(value, "timeinserver")
	local dbid = getElementData( value, "dbid" )
	if ((logged==1) and (timeinserver>=58) and (getPlayerIdleTime(value) < 600000)) or isForcePayday then
		local carLicense = getElementData(value, "license.car")
		if carLicense and carLicense < 0 then
			exports.anticheat:changeProtectedElementDataEx(value, "license.car", carLicense + 1, true)
			sqlupdate = sqlupdate .. ", car_license = car_license + 1"
		end

		local gunLicense = getElementData(value, "license.gun")
		if gunLicense and gunLicense < 0 then
			exports.anticheat:changeProtectedElementDataEx(value, "license.gun", gunLicense + 1, true)
			sqlupdate = sqlupdate .. ", gun_license = gun_license + 1"
		end

		local playerFaction = getElementData(value, "faction")
		if (playerFaction~=-1) then --if has faction
			local theTeam = getPlayerTeam(value)
			local factionType = getElementData(theTeam, "type")

			if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Factions with wages
				local wages = getElementData(theTeam,"wages")

				local factionRank = getElementData(value, "factionrank")
				local rankWage = tonumber( wages[factionRank] )

				local taxes = 0
				if not exports.global:takeMoney(theTeam, rankWage) then
					rankWage = -1
				else
					taxes = math.ceil( incomeTax * rankWage )
				end

				govAmount = govAmount + payWage( value, rankWage, true, taxes )
			else
				if unemployedPay >= govAmount then
					unemployedPay = -1
				end
				govAmount = govAmount + payWage( value, unemployedPay, false, 0 )
			end
		else
			if unemployedPay >= govAmount then
				unemployedPay = -1
			end
			govAmount = govAmount + payWage( value, unemployedPay, false, 0 )
			--outputDebugString(unemployedPay.." "..govAmount)
		end
		exports.anticheat:changeProtectedElementDataEx(value, "timeinserver", math.max(0, timeinserver-60), false, true)
		local hoursplayed = getElementData(value, "hoursplayed") or 0
		setPlayerAnnounceValue ( value, "score", hoursplayed+1 )
		exports.anticheat:changeProtectedElementDataEx(value, "hoursplayed", hoursplayed+1, false, true)
		mysql:query_free( "UPDATE characters SET hoursplayed = hoursplayed + 1, bankmoney = " .. getElementData( value, "bankmoney" ) .. sqlupdate .. " WHERE id = " .. dbid )
		--Referring
		if getElementData(value, "referrer") and getElementData(value, "referrer") > 0 and getElementData(value, "hoursplayed") == 50 then
			if mysql:query_free("UPDATE `accounts` SET `credits`=`credits`+10 WHERE `id`='"..getElementData(value, "referrer").."'" ) then
				mysql:query_free("INSERT INTO `don_purchases` SET `name`='"..exports.global:toSQL("Referring reward - Your friend '"..getElementData(value, "account:username").."' who has reached 50 hoursplayed on character '"..exports.global:getPlayerName(value).."'").."', `cost`=10, `account`='"..getElementData(value, "referrer").."'" )
				exports.global:sendMessageToAdmins("[ACHIEVEMENT] Player '"..exports.cache:getUsernameFromId(getElementData(value, "referrer")).."' has been rewarded with 10 GC(s) for referring his friend '"..getElementData(value, "account:username").."' who has reached 50 hoursplayed on character '"..exports.global:getPlayerName(value).."'! ")
				exports.announcement:makePlayerNotification(getElementData(value, "referrer"), "Congratulations! You were rewarded with 10 GC(s) for referring your friend "..getElementData(value, "account:username").." who has reached 50 hoursplayed on character "..exports.global:getPlayerName(value).."!")
				exports.announcement:makePlayerNotification(getElementData(value, "account:id"), exports.cache:getUsernameFromId(getElementData(value, "referrer")).." was rewarded with 10 GC(s) for referring you who has reached 50 hoursplayed on character "..exports.global:getPlayerName(value).."!")
			end
		end
	elseif (getPlayerIdleTime(value) > 600000) then
		--exports.global:sendMessageToAdmins("[PAYDAY] No payday for '"..getPlayerName(value):gsub("_", " ").."' as they've gone 10 minutes without movement.")
	elseif (logged==1) and (timeinserver) and (timeinserver<60) then
		outputChatBox("You have not played long enough to receive a payday. (You require another " .. 60-timeinserver .. " minutes of play.)", value, 255, 0, 0)
	end
end

function adminDoPaydayAll(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if (exports.integration:isPlayerAdmin(thePlayer)) then
			outputChatBox("Pay day has been successfully forced for all players", thePlayer, 0, 255, 0)
			payAllWages(true)
		end
	end
end
addCommandHandler("forcepaydayall", adminDoPaydayAll)

function adminDoPaydayOne(thePlayer, commandName, targetPlayerName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not targetPlayerName then
			outputChatBox("SYNTAX: /".. commandName .. " [Partial Player Nick / ID]", thePlayer, 255, 194, 14)
		else
			local logged = getElementData(thePlayer, "loggedin")
			if (logged==1) then
				targetPlayer = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
				if targetPlayer then
					if getElementData(targetPlayer, "loggedin") == 1 then
						outputChatBox("Pay day successfully forced for player " .. getPlayerName(targetPlayer):gsub("_", " "), thePlayer, 0, 255, 0)
						doPayDayPlayer(targetPlayer, true)
					else
						outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
						return
					end
				else
					outputChatBox("Failed to force payday.", thePlayer, 255, 0, 0)
					return
				end
			end
		end
	end
end
addCommandHandler("forcepayday", adminDoPaydayOne)

function timeSaved(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		local timeinserver = getElementData(thePlayer, "timeinserver")

		if (timeinserver>60) then
			timeinserver = 60
		end

		outputChatBox("You currently have " .. timeinserver .. " Minutes played.", thePlayer, 255, 195, 14)
		outputChatBox("You require another " .. 60-timeinserver .. " Minutes to obtain a payday.", thePlayer, 255, 195, 14)
	end
end
addCommandHandler("timesaved", timeSaved)

function loadWelfare( )
	local result = mysql:query_fetch_assoc( "SELECT value FROM settings WHERE name = 'welfare'" )
	if result then
		if not result.value then
			mysql:query_free( "INSERT INTO settings (name, value) VALUES ('welfare', " .. unemployedPay .. ")" )
		else
			unemployedPay = tonumber( result.value ) or 200
		end
	end
end

function startResource()
	local mins = getRealTime().minute
	local minutes = 60 - mins
	setTimer(payAllWages, 60000*minutes, 1, false)
	loadWelfare( )
end
addEventHandler("onResourceStart", getResourceRootElement(), startResource)
