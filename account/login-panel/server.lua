--MAXIME / 2014.12.29
local mysql = exports.mysql
local accountCharacters = {}
function validateCredentials(username,password,checksave)
	if not (username == "") then
		if not (password == "") then
			if checksave == true then
				triggerClientEvent(client,"saveLoginToXML",client,username,password)
			else
				triggerClientEvent(client,"resetSaveXML",client,username,password)
			end
			return true
		else
			triggerClientEvent(client,"set_warning_text",client,"Login","Please enter your password!")
		end
	else
		triggerClientEvent(client,"set_warning_text",client,"Login","Please enter your username!")
	end
	return false
end
addEvent("onRequestLogin",true)
addEventHandler("onRequestLogin",getRootElement(),validateCredentials)

function playerLogin(username,password,checksave)
	local encryptionRuleData, encryptionRuleQuery, accountCheckQuery, preparedQuery, accountData,newAccountHash,safeusername,safepassword = nil

	if not validateCredentials(username,password,checksave) then
		return false
	end

	--Get Encyption Rule for user.
	preparedQuery = "SELECT * FROM `accounts` WHERE `username`='".. mysql:escape_string(username) .."'"
	encryptionRuleQuery = mysql:query(preparedQuery)
	if encryptionRuleQuery then
		--triggerClientEvent(client,"set_authen_text",client,"Login","Retrieving encryption rule for username '".. username  .."'..")
	else
		triggerClientEvent(client,"set_warning_text",client,"Login","Failed to connect to game server. Database error!")
		return false
	end

	if (mysql:num_rows(encryptionRuleQuery) > 0) then
		--triggerClientEvent(client,"set_authen_text",client,"Login","Encryption rule successfully retrieved!")
	else
		triggerClientEvent(client,"set_warning_text",client,"Login","Account name '".. username .."' doesn't exist!")
		return false
	end
	accountData = mysql:fetch_assoc(encryptionRuleQuery)
	mysql:free_result(encryptionRuleQuery)

	-- Check if the account is banned
	if exports.bans:checkAccountBan(accountData["id"]) then
		triggerClientEvent(client,"set_warning_text",client,"Login","Account is banned. Appeal at http://ProjectReality.cf")
		return false
	end

	--Now check if passwords are matched or the account is activated, this is to prevent user with fake emails.
	triggerClientEvent(client,"set_authen_text",client,"Login","Password Accepted! Authenticating..")
	local encryptionRule = accountData["salt"]
	local encryptedPW = string.lower(md5(string.lower(md5(password))..encryptionRule))

	if accountData["password"] ~= encryptedPW then
		triggerClientEvent(client,"set_warning_text",client,"Login","Password is incorrect for account name '".. username .."'!")
		return false
	end

	if accountData["activated"] == "0" then
		triggerClientEvent(client,"set_warning_text",client,"Login","Account '".. username .."' is not activated.")
		return false
	end
	
	if accountData["appstate"] == "0" then
		triggerClientEvent(client,"accounts:app:error",client, 0)
		return false
	end
	
	if accountData["appstate"] == "1" then
		triggerClientEvent(client,"accounts:app:error",client, 1)
		return false
	end

	if accountData["appstate"] == "3" then
		triggerClientEvent(client,"accounts:app:error",client, 3)
		return false
	end

	--Validation is done, fetching some more details
	triggerClientEvent(client,"set_authen_text",client,"Login","Account authenticated! Logging in..")

	-- Check the account is already logged in
	local found = false
	for _, thePlayer in ipairs(exports.pool:getPoolElementsByType("player")) do
		local playerAccountID = tonumber(getElementData(thePlayer, "account:id"))
		if (playerAccountID) then
			if (playerAccountID == tonumber(accountData["id"])) and (thePlayer ~= client) then
				kickPlayer(thePlayer, thePlayer, "Someone else has logged into your account.")
				triggerClientEvent(client,"set_authen_text",client,"Login","Account is currently online. Disconnecting other user..")
				break
			end
		end
	end


	-----------------------------------------------------------------------START THE MAGIC-----------------------------------------------------------------------------------
	triggerClientEvent(client, "items:inventory:hideinv", client)

	-- Start the magic
	setElementDataEx(client, "account:loggedin", true, true)
	setElementDataEx(client, "account:id", tonumber(accountData["id"]), true)
	setElementDataEx(client, "account:username", accountData["username"], true)
	setElementDataEx(client, "electionsvoted", accountData["electionsvoted"], true)

	--STAFF PERMISSIONS / MAXIME
	setElementDataEx(client, "admin_level", tonumber(accountData['admin']), true)
	setElementDataEx(client, "supporter_level", tonumber(accountData['supporter']), true)
	setElementDataEx(client, "vct_level", tonumber(accountData['vct']), true)
	setElementDataEx(client, "mapper_level", tonumber(accountData['mapper']), true)
	setElementDataEx(client, "scripter_level", tonumber(accountData['scripter']), true)

	--Admins serial whitelist
	--if not exports.serialwhitelist:check(client) then
		--triggerClientEvent(client,"set_warning_text",client,"Login","You're not allowed to connect to server from that PC, check UCP.")
		--REMOVE STAFF PERMISSIONS / MAXIME
		--setElementDataEx(client, "admin_level", 0, true)
		--setElementDataEx(client, "supporter_level", 0, true)
		--setElementDataEx(client, "vct_level", 0, true)
		--setElementDataEx(client, "mapper_level", 0, true)
		--setElementDataEx(client, "scripter_level", 0, true)
		--return false
	--end
	
	setElementDataEx(client, "adminreports", tonumber(accountData["adminreports"]), true)
	setElementDataEx(client, "adminreports_saved", tonumber(accountData["adminreports_saved"]))

	if tonumber(accountData['referrer']) and tonumber(accountData['referrer']) > 0 then
		setElementDataEx(client, "referrer", tonumber(accountData['referrer']), false, true)
	end

	if exports.integration:isPlayerLeadAdmin(client) then
		setElementDataEx(client, "hiddenadmin", accountData["hiddenadmin"], true)
	else
		setElementDataEx(client, "hiddenadmin", 0, true)
	end
	--fetchRemote ( "https://forums.owlgaming.net/image.php?u=" .. tonumber(accountData["id"]) .. "&type=thumb", myCallback, "", false, accountData["id"] )
	--[[
	--ADMINS
	local staffDuty = tonumber(accountData["duty_admin"]) or 0
	if exports.integration:isPlayerTrialAdmin(client) then
		setElementDataEx(client, "duty_admin", staffDuty , true)
		setElementDataEx(client, "wrn:style", tonumber(accountData["warn_style"]), true)
	end

	--GMs
	if exports.integration:isPlayerSupporter(client) then --GMs
		setElementDataEx(client, "duty_supporter", staffDuty , true)
	end
	]]

	--MAXIME / VEHICLECONSULTATIONTEAM / 18.02.14
	local vehicleConsultationTeam = exports.integration:isPlayerVehicleConsultant(client)
	setElementDataEx(client, "vehicleConsultationTeam", vehicleConsultationTeam, false)

	if  tonumber(accountData["adminjail"]) == 1 then
		setElementDataEx(client, "adminjailed", true, true)
	else
		setElementDataEx(client, "adminjailed", false, true)
	end
	setElementDataEx(client, "jailtime", tonumber(accountData["adminjail_time"]), true)
	setElementDataEx(client, "jailadmin", accountData["adminjail_by"], true)
	setElementDataEx(client, "jailreason", accountData["adminjail_reason"], true)

	if accountData["monitored"] ~= "" then
		setElementDataEx(client, "admin:monitor", accountData["monitored"], true)
	end

	exports.logs:dbLog("ac"..tostring(accountData["id"]), 27, "ac"..tostring(accountData["id"]), "Connected from "..getPlayerIP(client) .. " - "..getPlayerSerial(client) )
	mysql:query_free("UPDATE `accounts` SET `ip`='" .. mysql:escape_string(getPlayerIP(client)) .. "', `mtaserial`='" .. mysql:escape_string(getPlayerSerial(client)) .. "' WHERE `id`='".. mysql:escape_string(tostring(accountData["id"])) .."'")
	exports['report-system']:reportLazyFix(client)
	--[[
	local dataTable = { }
	table.insert(dataTable, { "account:characters", characterList( client ) } )
	accountCharacters[tonumber(accountData["id"])] = dataTable
	]]

	setElementDataEx(client, "jailreason", accountData["adminjail_reason"], true)
	
	triggerEvent("updateCharacters", client)

	exports.donators:loadAllPerks(client)
	local togNewsPerk, togNewsStatus = exports.donators:hasPlayerPerk(client, 3)
	if (togNewsPerk) then
		setElementDataEx(client, "tognews", tonumber(togNewsStatus), false, true)
	end

	--SETTINGS / MAXIME
	loadAccountSettings(client, accountData["id"])

	-- Check if player passed application
	--outputDebugString(type(accountData["appreason"]))

	triggerClientEvent(client, "vehicle_rims", client)
	triggerClientEvent(client, "accounts:login:attempt", client, 0 )
	triggerEvent( "social:account", client, tonumber( accountData.id ) )
	triggerClientEvent (client,"hideLoginWindow",client)
end
addEvent("accounts:login:attempt",true)
addEventHandler("accounts:login:attempt",getRootElement(),playerLogin)

function myCallback( responseData, errno, id )
    if errno == 0 then
        --Cache it
        exports.cache:addImage(id, responseData)
	end
end

function playerFinishApps()
	if source then
		client = source
	end
	local index = getElementData(client, "account:id")
	triggerClientEvent(client, "accounts:login:attempt", client, 0)--, accountCharacters[index] )
	triggerEvent( "social:account", client, index )
	triggerClientEvent (client,"hideLoginWindow",client)
	triggerClientEvent (client,"apps:destroyGUIPart3",client)
	--accountCharacters[index] = nil
end
addEvent("accounts:playerFinishApps",true)
addEventHandler("accounts:playerFinishApps",getRootElement(),playerFinishApps)

--local lastClient = nil
function playerRegister(username,password,confirmPassword, email)
	--CHECK FOR EXISTANCE OF USERNAME AND EMAIL ADDRESS / MAXIME
	local preparedQuery1 = "SELECT `id` FROM `accounts` WHERE `username`='".. mysql:escape_string(username) .."' OR `email`='".. mysql:escape_string(email) .."' "
	local Q1 = mysql:query(preparedQuery1)
	if not Q1 then
		triggerClientEvent(client,"set_warning_text",client,"Register","Error code 0002 occurred.")
		return false
	end

	if (mysql:num_rows(Q1) > 0) then
		triggerClientEvent(client,"set_warning_text",client,"Register","Username or email existed.")
		mysql:free_result(Q1)
		return false
	end

	--CHECK FOR EXISTANCE OF MTA SERIAL TO ENCOUNTER MULTIPLE ACCOUNTS PER USER / MAXIME.
	local mtaSerial = getPlayerSerial(client)
	local preparedQuery2 = "SELECT `mtaserial`, `username`, `id` FROM `accounts` WHERE `mtaserial`='".. toSQL(mtaSerial) .."' LIMIT 1"
	local Q2 = mysql:query(preparedQuery2)
	if not Q2 then
		triggerClientEvent(client,"set_warning_text",client,"Register","Error code 0003 occurred.")
		return false
	end

	local usernameExisted = mysql:fetch_assoc(Q2)
	if (mysql:num_rows(Q2) > 0) and usernameExisted["id"] ~= "1" then
		triggerClientEvent(client,"set_warning_text",client,"Register","Multiple Accounts is not allowed (Existed: "..tostring(usernameExisted["username"])..")")
		return false
	end
	mysql:free_result(Q2)

	--START CREATING ACCOUNT.
	local encryptionRule = tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))
	local encryptedPW = string.lower(md5(string.lower(md5(password))..encryptionRule))
	local ipAddress = getPlayerIP(client)
	preparedQuery3 = "INSERT INTO `accounts` SET `username`='"..toSQL(username).."', `password`='"..toSQL(encryptedPW).."', `email`='"..toSQL(email).."', `registerdate`=NOW(), `ip`='"..toSQL(ipAddress).."', `salt`='"..toSQL(encryptionRule).."', `mtaserial`='"..mtaSerial.."', `activated`='1' "
	local id = mysql:query_insert_free(preparedQuery3)
	if id and tonumber(id) then
		triggerClientEvent(client,"accounts:register:complete",client, username, password)
		return true
	else
		triggerClientEvent(client,"set_warning_text",client,"Register","Could not create new account.")
		return false
	end
	--[[
	local token = exports.usercontrolpanel:makeToken(id, "INGAME_ACC_REGISTRATION")
	lastClient = client
	callRemote( "http://www.owlgaming.net/mta/functions.php", function(error)
		outputDebugString(tostring(error))
		if error == "ok" then
			triggerClientEvent(lastClient,"accounts:register:complete",lastClient, username, password)
			return true
		else
			if error == nil or error == "ERROR" then --In case webserver is not available.
				--mysql:query_free("UPDATE accounts SET activated=1 WHERE id='"..id.."'")
				--triggerClientEvent(lastClient,"accounts:register:complete",lastClient, "Account has been created and activated.")
				return true
			else
				triggerClientEvent(lastClient,"set_warning_text",lastClient,"Register",error)
				return false
			end
		end
	end, token, id, username, email)
	--]]

end
addEvent("accounts:register:attempt",true)
addEventHandler("accounts:register:attempt",getRootElement(),playerRegister)

function toSQL(stuff)
	return mysql:escape_string(stuff)
end
