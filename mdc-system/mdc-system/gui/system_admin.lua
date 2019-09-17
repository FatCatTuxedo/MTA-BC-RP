--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )
------------------------------------------

function system_admin ( users, count )
	local window = { }
	local width = 400
	local height = 400
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.window = guiCreateWindow( x, y, width, height, "MDC System Administrator", false )
	
	window.usersTable	= guiCreateGridList ( 10, 90, width - 20, height - 90 - 60, false, window.window )
	window.userCol		= guiGridListAddColumn( window.usersTable, "User", 0.45 )
	window.levelCol		= guiGridListAddColumn( window.usersTable, "Level", 0.25 )
	window.orgCol		= guiGridListAddColumn( window.usersTable, "Org.", 0.25 )
	
	window.usersRows = { }
	for i = 1, count - 1, 1 do
		local level = tonumber( users[ i ][ 3 ] )
		local levelText = ""
		if level == 1 then
			levelText = "Regular"
		elseif level == 2 then
			levelText = "Admin"
		elseif level == 3 then
			levelText = "Moderator"
		end
		window.usersRows[ i ] = guiGridListAddRow ( window.usersTable )
		guiGridListSetItemText ( window.usersTable, window.usersRows[ i ], window.userCol, users[ i ][ 2 ], false, false )
		guiGridListSetItemText ( window.usersTable, window.usersRows[ i ], window.levelCol, levelText, false, false )
		guiGridListSetItemText ( window.usersTable, window.usersRows[ i ], window.orgCol, users[ i ][ 4 ], false, false )
		guiGridListSetItemData ( window.usersTable, window.usersRows[ i ], window.userCol, users[ i ][ 1 ] )

	end
	
	window.createButton = guiCreateButton( 10, 30, ( width / 3 ) - 15, 50, "Create Account", false, window.window )
	addEventHandler( "onClientGUIClick", window.createButton, 
		function( )
			guiSetVisible( window.window, false )
			create()
		end
	, false )
	
	window.editButton = guiCreateButton( width / 3 + 5, 30, ( width / 3 ) - 10, 50, "Edit Account", false, window.window )
	addEventHandler( "onClientGUIClick", window.editButton, 
		function( )
			local row, col = guiGridListGetSelectedItem ( window.usersTable )
			local accountID =  guiGridListGetItemData ( window.usersTable, row, window.userCol )
			local user =  guiGridListGetItemText ( window.usersTable, row, window.userCol )
			local level =  guiGridListGetItemText ( window.usersTable, row, window.levelCol )
			local organization =  guiGridListGetItemText ( window.usersTable, row, window.orgCol )
			if accountID then
				edit( accountID, user, level, organization )
				guiSetVisible( window.window, false )
				destroyElement( window.window )
				window = { }
			end
		end
	, false )
	
	window.deleteButton = guiCreateButton( ( width / 3 * 2 ) + 5, 30, ( width / 3 ) - 15, 50, "Delete Account", false, window.window )
	addEventHandler( "onClientGUIClick", window.deleteButton,
		function( )
			local row, col = guiGridListGetSelectedItem ( window.usersTable )
			local accountID =  guiGridListGetItemData ( window.usersTable, row, window.userCol )
			if accountID then
				local organization = guiGridListGetItemText ( window.usersTable, row, window.orgCol )
				if organization == getElementData(localPlayer, "mdc_org") then
					if tonumber(accountID) == tonumber(getElementData(localPlayer, "mdc_account")) then
						mdc_errorWin("Cannot delete yourself.")
					else
						local user =  guiGridListGetItemText ( window.usersTable, row, window.userCol )
						local cfWin, cfYes, cfNo, cfLbl = mdc_confirmWin("Do you want to DELETE user '"..tostring(user).."'?")
						confirmDeleteAccount = accountID
						addEventHandler( "onClientGUIClick", cfYes,
							function( )
								local accountID = confirmDeleteAccount
								confirmDeleteAccount = nil
								mdc_confirmWin_destroy()
								triggerServerEvent( resourceName..":delete_account", localPlayer, accountID )
								guiSetVisible( window.window, false )
								destroyElement( window.window )
								window = { }
							end
						, false )
						addEventHandler( "onClientGUIClick", cfNo,
							function( )
								confirmDeleteAccount = nil
								mdc_confirmWin_destroy()
							end
						, false )						
					end
				else
					mdc_errorWin("Cannot delete user. Not your organization.")
				end
			end
		end
	, false )
	
	window.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, window.window )
	addEventHandler( "onClientGUIClick", window.closeButton, 
		function ()
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			triggerServerEvent( resourceName .. ":main", getLocalPlayer() )
		end
	, false )
end

function create( )
	guiSetInputEnabled ( true )
	local window = { }
	local width = 400
	local height = 240
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.window = guiCreateWindow( x, y, width, height, "MDC Create Account", false )
	
	window.userLabel	= guiCreateLabel( 10, 37, 70, 20, "Username: ", false, window.window )
	window.passLabel	= guiCreateLabel( 10, 76, 100, 20, "Password: ", false, window.window )
	window.levelLabel	= guiCreateLabel( 10, 110, 100, 20, "Level: ", false, window.window )
	
	window.userEdit	= guiCreateEdit( 80, 30, width - 90, 30, "", false, window.window )
	window.passEdit	= guiCreateEdit( 80, 70, width - 90, 30, "", false, window.window )
	
	window.levelCombo = guiCreateComboBox ( 80, 110, width - 90, 65, "Select a level", false, window.window )
	guiComboBoxAddItem( window.levelCombo, "Regular" )
	guiComboBoxAddItem( window.levelCombo, "Administrator" )
	guiComboBoxAddItem( window.levelCombo, "Moderator" )
	
	window.editButton = guiCreateButton( 10, height - 100, width - 20, 40, "Create!", false, window.window )
	addEventHandler( "onClientGUIClick", window.editButton, 
		function ()
			guiSetInputEnabled ( false )
			local user = guiGetText( window.userEdit )
			local pass = guiGetText( window.passEdit )
			local level = guiComboBoxGetSelected ( window.levelCombo )
			local org = getElementData(localPlayer, "mdc_org")
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			triggerServerEvent( resourceName .. ":create_account", getLocalPlayer(), user, pass, level, org )
		end
	, false )
	
	window.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, window.window )
	addEventHandler( "onClientGUIClick", window.closeButton, 
		function ()
			guiSetInputEnabled ( false )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			triggerServerEvent( resourceName .. ":system_admin", getLocalPlayer() )
		end
	, false )
end

function edit( accountID, user, level, org )
	guiSetInputEnabled ( true )
	local window = { }
	local width = 400
	local height = 240
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.window = guiCreateWindow( x, y, width, height, "MDC Edit Account: "..user, false )
	
	window.userLabel	= guiCreateLabel( 10, 37, 70, 20, "Username: ", false, window.window )
	window.passLabel	= guiCreateLabel( 10, 76, 100, 20, "Password: ", false, window.window )
	window.levelLabel	= guiCreateLabel( 10, 110, 100, 20, "Level: ", false, window.window )
	
	window.userEdit	= guiCreateEdit( 80, 30, width - 90, 30, user, false, window.window )
	window.passEdit	= guiCreateEdit( 80, 70, width - 90, 30, "", false, window.window )
	
	window.levelCombo = guiCreateComboBox ( 80, 110, width - 90, 65, level, false, window.window )
	guiComboBoxAddItem( window.levelCombo, "Regular" )
	guiComboBoxAddItem( window.levelCombo, "Administrator" )
	guiComboBoxAddItem( window.levelCombo, "Moderator" )
	
	local myOrg = getElementData(localPlayer, "mdc_org")
	if(myOrg ~= org) then
		window.editButton = guiCreateLabel( 10, height - 100, width - 20, 40, "Cannot edit: This member is not part of your organization ("..tostring(myOrg).."), but "..tostring(org)..".", false, window.window )
		guiSetEnabled(window.userEdit, false)
		guiSetEnabled(window.passEdit, false)
		guiSetEnabled(window.levelCombo, false)
		guiLabelSetHorizontalAlign(window.editButton, "left", true)
	else
		window.editButton = guiCreateButton( 10, height - 100, width - 20, 40, "Edit!", false, window.window )
		addEventHandler( "onClientGUIClick", window.editButton, 
			function ()
				guiSetInputEnabled ( false )
				local user = guiGetText( window.userEdit )
				local pass = guiGetText( window.passEdit )
				local level = guiComboBoxGetSelected ( window.levelCombo )
				guiSetVisible( window.window, false )
				destroyElement( window.window )
				window = { }
				triggerServerEvent( resourceName .. ":edit_account", getLocalPlayer(), accountID, user, pass, level, org )
			end
		, false )
	end
	
	window.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, window.window )
	addEventHandler( "onClientGUIClick", window.closeButton, 
		function ()
			guiSetInputEnabled ( false )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			triggerServerEvent( resourceName .. ":system_admin", getLocalPlayer() )
		end
	, false )
end



------------------------------------------
addEvent( resourceName..":system_admin", true )
addEventHandler( resourceName..":system_admin", getRootElement(), system_admin )