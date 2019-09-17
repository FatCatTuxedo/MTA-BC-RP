--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )
mainW = {}
------------------------------------------
function getMDCAccountID( )
	return getElementData( getLocalPlayer( ), "mdc_account" )
end

function getAdminLevel( )
	return tonumber( getElementData( getLocalPlayer( ), "mdc_admin" ) )
end

function main ( warrants, apb, impounds, calls )
	closeMainW()
	showCursor( true, true )
	local width = 700
	local height = 500
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	mainW.window = guiCreateWindow( x, y, width, height, tostring(getElementData(localPlayer, "mdc_org")).." - MDC Main", false )

	local spacer = 10
	local quarter = width / 3
	local button = { x = spacer, y = 30, width = quarter - spacer, height = 50 }

	--Search Button
	mainW.searchButton = guiCreateButton( button.x, button.y, button.width, button.height, "Search Database", false, mainW.window )
	addEventHandler( "onClientGUIClick", mainW.searchButton,
		function( )
			search()
		end
	, false )
	mainW.searchButtonImage = guiCreateStaticImage ( 5, 5, 40, 40, ":mdc-system/img/search.png", false, mainW.searchButton )

	if canSeeWarrants[getElementData(localPlayer, "mdc_org")] then
		--Add APB Button
		button.x = button.x + button.width + spacer
		mainW.addButton = guiCreateButton( button.x, button.y, button.width, button.height, "Add APB", false, mainW.window )
		addEventHandler( "onClientGUIClick", mainW.addButton,
			function( )
				guiSetVisible( mainW.window, false )
				destroyElement( mainW.window )
				window = { }
				add_apb()
			end
		, false )
		mainW.searchButtonImage = guiCreateStaticImage ( 5, 5, 40, 40, ":mdc-system/img/add.png", false, mainW.addButton )
	end

	--Account Settings Button
	button.x = button.x + button.width + spacer
	mainW.accountButton = guiCreateButton( button.x, button.y, button.width, button.height, "Account Settings", false, mainW.window )
	addEventHandler( "onClientGUIClick", mainW.accountButton,
		function( )
			guiSetVisible( mainW.window, false )
			destroyElement( mainW.window )
			window = { }
			account_settings()
		end
	, false )
	mainW.searchButtonImage = guiCreateStaticImage ( 5, 5, 40, 40, ":mdc-system/img/settings.png", false, mainW.accountButton )



	button.x = button.x + button.width + spacer
	mainW.tollsButton = guiCreateButton( button.x, button.y, button.width, button.height, "Tolls", false, mainW.window )
	addEventHandler( "onClientGUIClick", mainW.tollsButton,
		function ()
			guiSetVisible( mainW.window, false )
			destroyElement( mainW.window )
			window = { }
			triggerServerEvent( resourceName .. ":tolls", getLocalPlayer() )
		end
	, false )

	mainW.mainPanel	= guiCreateTabPanel ( 10, 90, width - 15, height - 150, false, mainW.window )

	mainW.apbTab		= guiCreateTab( "APB", mainW.mainPanel )
	mainW.apbTable		= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.apbTab )

	mainW.personCol	= guiGridListAddColumn( mainW.apbTable, "Person", 0.25 )
	mainW.wantedCol	= guiGridListAddColumn( mainW.apbTable, "APB", 0.5 )
	mainW.issuedByCol	= guiGridListAddColumn( mainW.apbTable, "Issued By", 0.25 )

	if ( #apb > 0 ) then
		for i = 1, #apb, 1 do
			local row = guiGridListAddRow ( mainW.apbTable )
			guiGridListSetItemText( mainW.apbTable, row, mainW.personCol, apb[ i ][ 1 ]:gsub( "_", " " ), false, false )
			guiGridListSetItemText( mainW.apbTable, row, mainW.wantedCol, apb[ i ][ 2 ], false, false )
			local issuedByText
			if(apb[ i ][ 5 ] == apb[ i ][ 3 ]) then
				issuedByText = apb[ i ][ 5 ]
			else
				issuedByText = apb[ i ][ 5 ] .. " (" .. apb[ i ][ 3 ] .. ")"
			end
			guiGridListSetItemText( mainW.apbTable, row, mainW.issuedByCol, issuedByText, false, false )
			guiGridListSetItemData( mainW.apbTable, row, mainW.personCol, apb[ i ][ 4 ] )
		end

		addEventHandler( "onClientGUIDoubleClick", mainW.apbTable,
			function ( )
				local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.apbTable )
				local characterName = guiGridListGetItemText( mainW.apbTable, selectedRow, mainW.personCol )
				local description = guiGridListGetItemText( mainW.apbTable, selectedRow, mainW.wantedCol )
				local issuedBy = guiGridListGetItemText( mainW.apbTable, selectedRow, mainW.issuedByCol )
				local id = guiGridListGetItemData( mainW.apbTable, selectedRow, mainW.personCol )
				--triggerServerEvent( resourceName .. ":search", getLocalPlayer(), characterName, 0 )
				view_apb( id, characterName, description, issuedBy )

				guiSetVisible( mainW.window, false )
				destroyElement( mainW.window )
				window = { }
			end
		, false )

	else
		local row = guiGridListAddRow ( mainW.apbTable )
		guiGridListSetItemText ( mainW.apbTable, row, mainW.personCol, "No APBs", false, false )
	end


	if canSeeWarrants[getElementData(localPlayer, "mdc_org")] then
		mainW.warrantTab	= guiCreateTab( "Warrants", mainW.mainPanel )
		mainW.warrantTable	= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.warrantTab )
		mainW.charCol		= guiGridListAddColumn( mainW.warrantTable, "Suspect", 0.25 )
		mainW.warrantCol	= guiGridListAddColumn( mainW.warrantTable, "Warrant", 0.45 )
		mainW.issuedCol	= guiGridListAddColumn( mainW.warrantTable, "Issued By", 0.25 )

		if ( #warrants > 0 ) then
			for i = 1, #warrants, 1 do
				local row = guiGridListAddRow ( mainW.warrantTable )
				guiGridListSetItemText( mainW.warrantTable, row, mainW.charCol, warrants[ i ][ 1 ]:gsub( "_", " " ), false, false )
				guiGridListSetItemText( mainW.warrantTable, row, mainW.warrantCol, warrants[ i ][ 2 ], false, false )
				local issuedByText
				if(warrants[ i ][ 4 ] == warrants[ i ][ 3 ]) then
					issuedByText = warrants[ i ][ 4 ]
				else
					issuedByText = warrants[ i ][ 4 ] .. " (" .. warrants[ i ][ 3 ] .. ")"
				end
				guiGridListSetItemText( mainW.warrantTable, row, mainW.issuedCol, issuedByText, false, false )
				--guiGridListSetItemData( mainW.warrantTable, row, mainW.propCol, warrants[ i ][ 1 ] )
			end

			addEventHandler( "onClientGUIDoubleClick", mainW.warrantTable,
				function ( )
					local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.warrantTable )
					local characterName = guiGridListGetItemText( mainW.warrantTable, selectedRow, mainW.charCol )
					triggerServerEvent( resourceName .. ":search", getLocalPlayer(), characterName, 0 )

					guiSetVisible( mainW.window, false )
					destroyElement( mainW.window )
					window = { }
				end
			, false )

		else
			local row = guiGridListAddRow ( mainW.warrantTable )
			guiGridListSetItemText ( mainW.warrantTable, row, mainW.charCol, "No Warrants", false, false )
		end
	end

	--Impounds / Maxime / 2015.2.1
	mainW.imps_lots	= guiCreateTab( "Impounds", mainW.mainPanel )
	mainW.imps_lots_list	= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.imps_lots )
	mainW.imps_lots_list_col_dep = guiGridListAddColumn( mainW.imps_lots_list, "Department", 0.1 )
	mainW.imps_lots_list_col_lane = guiGridListAddColumn( mainW.imps_lots_list, "Lane", 0.05 )
	mainW.imps_lots_list_col_days = guiGridListAddColumn( mainW.imps_lots_list, "Release Date", 0.2 )
	mainW.imps_lots_list_col_fine = guiGridListAddColumn( mainW.imps_lots_list, "Fine ($)", 0.1 )
	mainW.imps_lots_list_col_model = guiGridListAddColumn( mainW.imps_lots_list, "Model", 0.4 )

	mainW.imps_lots_list_col_plate = guiGridListAddColumn( mainW.imps_lots_list, "Plate", 0.1 )
	mainW.imps_lots_list_col_vin = guiGridListAddColumn( mainW.imps_lots_list, "VIN", 0.1 )

	mainW.imps_lots_list_col_id = guiGridListAddColumn( mainW.imps_lots_list, "((Veh ID))", 0.08 )

	for i, oneLane in pairs(impounds) do
		local row = guiGridListAddRow ( mainW.imps_lots_list )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_dep, oneLane.impounder == 1 and "LSPD" or oneLane.impounder == 59 and "SAHP" or "RT", false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_lane, oneLane.lane, false, true )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_model, oneLane.name or "-", false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_plate, oneLane.plate or "-", false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_vin, oneLane.vin or "-", false, false )
		local release = "Seized"
		local fine = oneLane.fine and exports.global:formatMoney(oneLane.fine) or "-"
		if oneLane.id then
			if not oneLane.release_date then
				release = "Seized"
				fine = "Irrelevant"
			else
				release = oneLane.release_date
			end
		else
			release = "-"
		end
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_days,release , false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_fine, fine, false, true )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_id, oneLane.id or "-", false, true )
	end
	addEventHandler( "onClientGUIDoubleClick", mainW.imps_lots_list,
		function ( )
			local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.imps_lots_list )
			local vehid = guiGridListGetItemText( mainW.imps_lots_list, selectedRow, mainW.imps_lots_list_col_vin )
			if vehid ~= "-" then
				triggerServerEvent( resourceName .. ":search", getLocalPlayer(), vehid, 3 )
				togWin( mainW.window, false )
			end
		end
	, false )
	--mainW.warrantCol	= guiGridListAddColumn( mainW.warrantTable, "Warrant", 0.45 )
	--mainW.issuedCol	= guiGridListAddColumn( mainW.warrantTable, "Issued By", 0.25 )


	if canSeeCalls[getElementData(localPlayer, "mdc_org")] then
		mainW.callsTab			= guiCreateTab( "911 Calls", mainW.mainPanel )
		mainW.callsTable		= guiCreateGridList( 10, 10, width - 35, height - 190, false, mainW.callsTab )
		mainW.callerCol		= guiGridListAddColumn( mainW.callsTable, "Caller", 0.2 )
		mainW.phoneCol			= guiGridListAddColumn( mainW.callsTable, "Phone Number", 0.12 )
		mainW.convoCol			= guiGridListAddColumn( mainW.callsTable, "Description", 0.5 )
		mainW.timeCol			= guiGridListAddColumn( mainW.callsTable, "Time", 0.1 )

		if not calls then calls = {} end
		if ( #calls > 0 ) then
			for i = 1, #calls, 1 do
				local row = guiGridListAddRow ( mainW.callsTable )
				guiGridListSetItemText( mainW.callsTable, row, mainW.callerCol, (calls[ i ][ 2 ] or "N/A"):gsub("_", " "), false, false )
				guiGridListSetItemData( mainW.callsTable, row, mainW.callerCol, calls[ i ][ 1 ] )
				guiGridListSetItemText( mainW.callsTable, row, mainW.phoneCol, calls[ i ][ 3 ], false, false )
				guiGridListSetItemText( mainW.callsTable, row, mainW.convoCol, calls[ i ][ 4 ], false, false )
				guiGridListSetItemText( mainW.callsTable, row, mainW.timeCol, calls[ i ][ 5 ], false, false )
			end

			addEventHandler( "onClientGUIDoubleClick", mainW.callsTable,
				function ( )
					local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.callsTable )
					local characterName = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.callerCol )
					if characterName ~= "N/A" then
						triggerServerEvent( resourceName .. ":search", getLocalPlayer(), characterName, 0 )

						guiSetVisible( mainW.window, false )
						destroyElement( mainW.window )
						window = { }
					end
				end
			, false )

		else
			local row = guiGridListAddRow ( mainW.callsTable )
			guiGridListSetItemText ( mainW.callsTable, row, mainW.callerCol, "No 911 Calls", false, false )
		end
	end


	mainW.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, mainW.window )
	addEventHandler( "onClientGUIClick", mainW.closeButton,
		function ()
			closeMainW()
		end
	, false )
end

function closeMainW()
	if mainW.window and isElement(mainW.window) then
		destroyElement(mainW.window)
		mainW.window = nil
		closeVehWin()
		closeSearchGui()
		showCursor( false, false )
		guiSetInputEnabled(false)
	end
end

------------------------------------------
addEvent( resourceName..":main", true )
addEventHandler( resourceName..":main", getRootElement(), main )

function togWin(element, state)
	if element and isElement(element) then
		guiSetEnabled(element, state)
	end
end
