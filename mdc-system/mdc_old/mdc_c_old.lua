--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize( )
local PD_VEHICLES = { 427, 490, 528, 523, 598, 596, 597, 599, 601 }
PD_ID = 1
FAA_ID = 47
GOV_ID = 3
SASD_ID = 59
local FAA_VEHICLES = { 596, 490, 426 }
local FAA_INTERIORS = {}
local resourceName = getResourceName( getThisResource( ) )
local filePath = ":"..resourceName.."/account.xml"
localPlayer = getLocalPlayer()

canSeeWarrants = {
	["LSPD"] = true,
	["FAA"] = true,
	["LSES"] = true,
	["GOV"] = true,
	["SASD"] = true,
}
canSeeCalls = {
	["LSPD"] = true,
	["FAA"] = false,
	["LSES"] = true,
	["GOV"] = false,
	["SASD"] = true,
}
canAddAPB = {
	["LSPD"] = true,
	["FAA"] = true,
	["LSES"] = false,
	["GOV"] = true,
	["SASD"] = true,
}
canSeeVehicles = {
	["LSPD"] = true,
	["FAA"] = true, --FAA only aircrafts
	["LSES"] = false,
	["GOV"] = true,
	["SASD"] = true,
}
canSeeProperties = {
	["LSPD"] = true,
	["FAA"] = false,
	["LSES"] = true,
	["GOV"] = true,
	["SASD"] = true,
}
canSeeLicenses = {
	["LSPD"] = true,
	["FAA"] = false,
	["LSES"] = false,
	["GOV"] = false,
	["SASD"] = true,
}
canSeePilotStuff = {
	["LSPD"] = true,
	["FAA"] = true,
	["LSES"] = false,
	["GOV"] = false,
	["SASD"] = true,
}

------------------------------------------
function hasMDCPermissions( )
	if isPedInVehicle( getLocalPlayer() ) then
		local vehicle = getPedOccupiedVehicle( getLocalPlayer() )
		local vehicleFaction = tonumber(getElementData(vehicle, "faction"))
		if (vehicleFaction == PD_ID) or (vehicleFaction == SASD_ID) then
			return true
		elseif (vehicleFaction == GOV_ID) then
			return true
		elseif(vehicleFaction == FAA_ID) then
			for k,v in ipairs(FAA_VEHICLES) do
				if(getElementModel(vehicle) == v) then
					return true
				end
			end
		elseif(vehicle == 596 or vehicle == 427 or vehicle == 490 or vehicle == 599 or vehicle == 601 or vehicle == 523 or vehicle == 597 or vehicle == 598 or exports.global:hasItem(vehicle, 143)) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function saveAccountData( username, password )
	local file = xmlLoadFile( filePath )
	if not file then
		file = xmlCreateFile( filePath, "account" )
	end
	xmlNodeSetValue ( xmlFindChild( file, "username", 0 ) or xmlCreateChild ( file, "username"), username ) 
	xmlNodeSetValue ( xmlFindChild( file, "password", 0 ) or xmlCreateChild ( file, "password"), password ) 
	
	xmlSaveFile( file )
	xmlUnloadFile( file )
end

function getAccountData( )
	local file = xmlLoadFile( filePath )
	if not file then
		return { username = "Username", password = "Password" }
	end
	local username = xmlNodeGetValue( xmlFindChild( file, "username", 0 ) ) or "Username"
	local password = xmlNodeGetValue( xmlFindChild( file, "password", 0 ) ) or "Password"
	
	xmlSaveFile( file )
	xmlUnloadFile( file )
	
	return { username = username, password = password }
end

------------------------------------------
function login ( )
	if hasMDCPermissions() then
		showCursor( true, true )
		guiSetInputEnabled ( true )
		local window = { }
		local width = 300
		local height = 190
		local x = SCREEN_X / 2 - width / 2
		local y = SCREEN_Y / 2 - height / 2
		window.window = guiCreateWindow( x, y, width, height, "MDC Login", false )
		
		--Fetch our account data
		local accountData = getAccountData( )
		
		window.userBox = guiCreateEdit( 10, 30, width - 20, 30, accountData.username, false, window.window )
		window.passBox = guiCreateEdit( 10, 70, width - 20, 30, accountData.password, false, window.window )
		window.rememberCheck = guiCreateCheckBox( 10, 110, width - 20, 30, "Remember Me", accountData.username ~= "Username", false, window.window )
		guiEditSetMasked( window.passBox, true )
		guiSetProperty(window.passBox, 'MaskCodepoint', '8226')		

		window.loginButton = guiCreateButton( 10, 150, ( width - 20 ) / 2, 30, "Login", false, window.window )
		addEventHandler( "onClientGUIClick", window.loginButton, 
			function ( )
				local user = guiGetText( window.userBox )
				local pass = guiGetText( window.passBox )
				if guiCheckBoxGetSelected ( window.rememberCheck ) then
					saveAccountData( user, pass )
				else
					saveAccountData( "Username", "Password" )
				end
				showCursor( false, false )
				guiSetInputEnabled ( false )
				guiSetVisible( window.window, false )
				destroyElement( window.window )
				window = { }
				triggerServerEvent( resourceName ..":login", getLocalPlayer(), user, pass )
			end
		)
		window.exitButton = guiCreateButton( ( width - 20 ) / 2 + 10, 150, ( width - 20 ) / 2, 30, "Exit", false, window.window )
		addEventHandler( "onClientGUIClick", window.exitButton, 
			function ( )
				showCursor( false, false )
				guiSetInputEnabled ( false )
				guiSetVisible( window.window, false )
				destroyElement( window.window )
				window = { }
			end
		)
	else
		outputChatBox( "You are not near a mobile data computer.", 255, 155, 155 )
	end
end

------------------------------------------
addCommandHandler( "mdc", login, false, false )

function createLoginWindow()
	local window = { }
	local width = 300
	local height = 190
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.window = guiCreateWindow( x, y, width, height, "MDC Login", false )
	
	--Fetch our account data
	local accountData = getAccountData( )
	
	window.userBox = guiCreateEdit( 10, 30, width - 20, 30, accountData.username, false, window.window )
	window.passBox = guiCreateEdit( 10, 70, width - 20, 30, accountData.password, false, window.window )
	window.rememberCheck = guiCreateCheckBox( 10, 110, width - 20, 30, "Remember Me", accountData.username ~= "Username", false, window.window )
	guiEditSetMasked( window.passBox, true )
	guiSetProperty(window.passBox, 'MaskCodepoint', '8226')		
	
	window.loginButton = guiCreateButton( 10, 150, ( width - 20 ) / 2, 30, "Login", false, window.window )
	addEventHandler( "onClientGUIClick", window.loginButton, 
		function ( )
			local user = guiGetText( window.userBox )
			local pass = guiGetText( window.passBox )
			if guiCheckBoxGetSelected ( window.rememberCheck ) then
				saveAccountData( user, pass )
			else
				saveAccountData( "Username", "Password" )
			end
			showCursor( false, false )
			guiSetInputEnabled ( false )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			triggerServerEvent( resourceName ..":login", getLocalPlayer(), user, pass )
		end
	)
	window.exitButton = guiCreateButton( ( width - 20 ) / 2 + 10, 150, ( width - 20 ) / 2, 30, "Exit", false, window.window )
	addEventHandler( "onClientGUIClick", window.exitButton, 
		function ( )
			showCursor( false, false )
			guiSetInputEnabled ( false )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	)
end

function showLoginWindow()
	createLoginWindow()
	showCursor(true)
	guiSetInputEnabled ( true ) 
end

function mdc_errorWin ( text )
	if window then
		if window.dialog then
			if window.dialog.window then
				destroyElement(window.dialog.window)
				window.dialog = { }
			end
		end
	else
		window = {}
	end
	window.dialog = { }
	local width = 250
	local height = 110
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.dialog.window = guiCreateWindow( x, y, width, height, "MDC Error", false )
	
	window.dialog.errorLabel = guiCreateLabel( 10, 30, width - 20, 20, tostring(text), false, window.dialog.window )
	
	window.dialog.closeButton = guiCreateButton( 10, 60, width - 20, 40, "Close", false, window.dialog.window )
	addEventHandler( "onClientGUIClick", window.dialog.closeButton, 
		function ()
			guiSetVisible( window.dialog.window, false )
			destroyElement( window.dialog.window )
			window.dialog = { }
		end
	, false )
end

function mdc_confirmWin ( text )
	if window then
		if window.confirmWin then
			if window.confirmWin.window then
				if isElement(window.confirmWin.window) then
					destroyElement(window.confirmWin.window)
				end
			end
			window.confirmWin = { }
		end
	else
		window = {}
	end
	window.confirmWin = { }
	local width = 250
	local height = 130
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.confirmWin.window = guiCreateWindow( x, y, width, height, "MDC Confirm", false )
	
	window.confirmWin.label = guiCreateLabel( 10, 30, width - 20, 40, tostring(text), false, window.confirmWin.window )
	guiLabelSetHorizontalAlign(window.confirmWin.label, "center", true)
	
	window.confirmWin.bYes = guiCreateButton( 10, 80, 110, 40, "Yes", false, window.confirmWin.window )
	window.confirmWin.bNo = guiCreateButton( 130, 80, 110, 40, "No", false, window.confirmWin.window )
	
	return window.confirmWin.window, window.confirmWin.bYes, window.confirmWin.bNo, window.confirmWin.label
end

function mdc_confirmWin_destroy()
	if window then
		if window.confirmWin then
			if window.confirmWin.window then
				if isElement(window.confirmWin.window) then
					destroyElement(window.confirmWin.window)
				end
			end
			window.confirmWin = {}
		end
	end
end