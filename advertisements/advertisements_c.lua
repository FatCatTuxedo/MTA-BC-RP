--[[
--	Copyright (C) LettuceBoi Development - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, May 2013
]]--

--Helper variables to create the GUIs.
local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )

local ONE_HOUR = 3600

local SERVICES_SECTION = 1		--Places to offer services such as house cleaning or mechanics and whatnot
local CARS_VEHICLES_SECTION = 2	--Offer to buy or sell a vehicle in this section
local REAL_ESTATE_SECTION = 3	--Houses for sale go in this section
local COMMUNITY_SECTION = 4		--Advertisements about communities can go here, for example, palomino creek.
local JOBS_SECTION = 5 			--Advertisements about hiring people or looking for work will go in this section
local PERSONALS_SECTION = 6		--People looking for other people go in this section

local sections = { "Services", "Cars & Vehicles", "Real Estate", "Community", "Jobs", "Personals" }

local deleteAny = false
local window = { } -- Store all of our window elements
local viewad = {}
local postad = {}
--[[
	Takes a timestamp and returns the current time in string format of however you'd like it to look.
]]
function getTime( day, month, timestamp )
	local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
	local days = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
	local time = nil
	local ts = nil
	
	if timestamp then
		time = getRealTime( timestamp )
	else
		time = getRealTime( )
	end
	
	ts = ( tonumber( time.hour ) >= 12 and tostring( tonumber( time.hour ) - 12 ) or time.hour ) .. ":"..("%02d"):format(time.minute)..( tonumber( time.hour ) >= 12 and " PM" or " AM" )
	
	if month then
		ts =  months[ time.month + 1 ] .. " ".. time.monthday .. ", " .. ts
	end
	
	if day then
		ts = days[ time.weekday + 1 ].. ", " .. ts
	end
	
	return ts
end

--[[
	Creating the advertisement failed, output a message to the user.
]]

addEvent( resourceName .. ":ad_create_fail", true )
addEventHandler( resourceName .. ":ad_create_fail", root,
	function()
		local window = { } --Store all of our window elements
		local width = 230 -- The width of our window
		local height = 110 -- The height of our window
		local x = SCREEN_X / 2 - width / 2 --Where on the screen our window will be located
		local y = SCREEN_Y / 2 - height / 2
		window.window = guiCreateWindow( x, y, width, height, "Creation Error", false ) --Create the window.
		
		--Display the main message
		window.errorLabel = guiCreateLabel( 10, 30, width - 20, 20, "There was an error with your input.", false, window.window )
		
		--Include a close bar to return to the main menu.
		window.closeButton = guiCreateButton( 10, 60, width - 20, 40, "Close", false, window.window )
		addEventHandler( "onClientGUIClick", window.closeButton, 
			function ()
				guiSetVisible( window.window, false )
				destroyElement( window.window )
				window = { }
			end
		)
	end
)

function createAdvertisement( )
	closePostAd()
	if window and window.window and isElement(window.window) then
		guiSetEnabled(window.window, false)
	end
	guiSetInputEnabled ( true )
	local window = { } -- Store all of our window elements
	local width = 400 -- The width of our window
	local height = 440 -- The height of our window
	local x = SCREEN_X / 2 - width / 2 --Where on the screen our window will be located
	local y = SCREEN_Y / 2 - height / 2
	
	
	postad.window = guiCreateWindow( x, y, width, height, "Create Advertisement", false ) --Create the postad.
	postad.label = { } --This will hold our label elements
	
	
	local labels = { "Phone", "Name", "Address", "Expires", "Section", "Advertisement" } --This holds all of the labels we will create here
	local y = 35 --We'll set y to 30, which is the y coordinate of where our first label will go.
	for label = 1, #labels do
		postad.label[ label ] = guiCreateLabel( 10, y * label, 100, 30, labels[ label ], false, postad.window )
	end
	
	postad.input = { } -- Will hold all of our input elements.
	y = 30 -- We'll start y off at 25 here to stay even with the inputs.
	
	postad.input[ 1 ] = guiCreateEdit( 100, y, width - 120, 30, "", false, postad.window ) --Phone input
	y = y + 35
	postad.input[ 2 ] = guiCreateEdit( 100, y, width - 120, 30, "", false, postad.window ) --Name Input
	y = y + 35
	postad.input[ 3 ] = guiCreateEdit( 100, y, width - 120, 30, "", false, postad.window ) --Address input
	y = y + 40
	postad.input[ 4 ] = guiCreateComboBox( 100, y, width - 120, 95, "", false, postad.window ) --Expiry
	guiComboBoxAddItem( postad.input[ 4 ], "One Hour" )
	guiComboBoxAddItem( postad.input[ 4 ], "Two Hours" )
	guiComboBoxAddItem( postad.input[ 4 ], "Six Hours" )
	guiComboBoxAddItem( postad.input[ 4 ], "One Day" )
	
	y = y + 34
	postad.input[ 5 ] = guiCreateComboBox( 100, y, width - 120, 125, "", false, postad.window ) --Section
	for i = 1, #sections do --Loop through each of the 6 advertisement sections.
		guiComboBoxAddItem( postad.input[ 5 ], sections[ i ] )
	end
	
	postad.input[ 6 ] = guiCreateMemo( 10, y + 60, width - 20, 90, "", false, postad.window ) --Advertisement
	
	for i = 1, 6 do
		addEventHandler(getElementType( postad.input[i] ) == 'gui-combobox' and 'onClientGUIComboBoxAccepted' or 'onClientGUIChanged', postad.input[i],
			function( )
				for i = 1, 6 do
					if getElementType( postad.input[i] ) == 'gui-combobox' then
						if guiComboBoxGetSelected( postad.input[i] ) == -1 then
							guiSetEnabled( postad.postButton, false )
							return
						end
					else
						local text = ( guiGetText( postad.input[i] ) or '' ):gsub("\n", ''):gsub("\r", '')
						if #text == 0 then
							guiSetEnabled( postad.postButton, false )
							return
						end
					end
				end

				guiSetEnabled( postad.postButton, true )
			end, false
		)
	end
	
	--We'll need a button to send the form details to the server.
	postad.postButton = guiCreateButton( 10, height - 100, width - 20, 40, "Post Advertisement", false, postad.window )
	guiSetEnabled( postad.postButton, false )
	addEventHandler( "onClientGUIClick", postad.postButton, 
		function ()
			--First we'll call to the server and send all of our data there
			local phone = guiGetText( postad.input[ 1 ] ) or ""
			local name = guiGetText( postad.input[ 2 ] ) or ""
			local address = guiGetText( postad.input[ 3 ] ) or ""
			local advertisement = guiGetText( postad.input[ 6 ] )
			
			local expirySelected = guiComboBoxGetSelected( postad.input[ 4 ] )
			local expires = nil
			if expirySelected == -1 or expirySelected == 0 then
				--One hour
				expires = ONE_HOUR
			elseif	expirySelected == 1 then
				--Two hours
				expires = ONE_HOUR * 2
			elseif expirySelected == 2 then
				--Six hours
				expires = ONE_HOUR * 6
			else
				--One Day
				expires = ONE_HOUR * 24
			end
			
			local section = tostring( guiComboBoxGetSelected( postad.input[ 5 ] ) + 1 )
			
			
			--Clear all GUI elements and remove the cursor.
			--[[
			guiSetInputEnabled ( false )
			showCursor( false, false )
			guiSetVisible( postad.window, false )
			destroyElement( postad.window )
			window = { }
			]]
			closePostAd()
			triggerServerEvent( resourceName .. ":create_advertisement", getLocalPlayer(), phone, name, address, advertisement, expires, section )
		end
	, false )
	
	--Include a close button to exit the form.
	postad.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, postad.window )
	addEventHandler( "onClientGUIClick", postad.closeButton, 
		function ()
			if source == postad.closeButton then
				closePostAd()
			end
		end
	, false )
	
end
addCommandHandler( "postad", createAdvertisement, false, false )

function closePostAd()
	if postad and postad.window and isElement(postad.window) then
		--Clear all GUI elements and remove the cursor.
		guiSetInputEnabled ( false )
		
		--guiSetVisible( postad.window, false )
		destroyElement( postad.window )
		postad = { }
		if window and window.window and isElement(window.window) then
			guiSetEnabled(window.window, true)
		else
			showCursor( false, false )
		end
		--triggerServerEvent( resourceName .. ":open_ads", localPlayer ) --Call the server to open the advertisement window again.
	end
end


function viewAdvertisement( advertisement )
	closeViewAd()
	if window and window.window and isElement(window.window) then
		guiSetEnabled(window.window, false)
	end
	guiSetInputEnabled ( false )
	local window = { } -- Store all of our window elements
	local width = 400 -- The width of our window
	local height = 530 -- The height of our window
	local x = SCREEN_X / 2 - width / 2 --Where on the screen our window will be located
	local y = SCREEN_Y / 2 - height / 2
	
	
	viewad.window = guiCreateWindow( x, y, width, height, "View Advertisement", false ) --Create the viewad.
	viewad.label = { } --This will hold our label elements
	
	
	local labels = { "Phone", "Name", "Address", "Start", "Expires", "Section", "Advertisement" } --This holds all of the labels we will create here
	local y = 35 --We'll set y to 30, which is the y coordinate of where our first label will go.
	for label = 1, #labels do
		viewad.label[ label ] = guiCreateLabel( 10, y * label, 100, 30, labels[ label ], false, viewad.window )
	end
	
	viewad.input = { } -- Will hold all of our input elements.
	y = 30 -- We'll start y off at 25 here to stay even with the inputs.
	
	viewad.input[ 1 ] = guiCreateEdit( 100, y, width - 120, 30, advertisement.phone, false, viewad.window ) --Phone input
	guiEditSetReadOnly( viewad.input[ 1 ], true )
	y = y + 35
	viewad.input[ 2 ] = guiCreateEdit( 100, y, width - 120, 30, advertisement.name, false, viewad.window ) --Name Input
	guiEditSetReadOnly( viewad.input[ 2 ], true )
	y = y + 35
	viewad.input[ 3 ] = guiCreateEdit( 100, y, width - 120, 30, advertisement.address, false, viewad.window ) --Address input
	guiEditSetReadOnly( viewad.input[ 3 ], true )
	y = y + 35
	viewad.input[ 4 ] = guiCreateEdit( 100, y, width - 120, 30, getTime( true, true, advertisement.start ), false, viewad.window ) --Start
	guiEditSetReadOnly( viewad.input[ 4 ], true )
	y = y + 35
	viewad.input[ 5 ] = guiCreateEdit( 100, y, width - 120, 30, getTime( true, true, advertisement.expiry ), false, viewad.window ) --Expiry
	guiEditSetReadOnly( viewad.input[ 5 ], true )
	y = y + 35
	viewad.input[ 6 ] = guiCreateEdit( 100, y, width - 120, 30, sections[ tonumber( advertisement.section ) ], false, viewad.window ) --Section
	guiEditSetReadOnly( viewad.input[ 6 ], true )
	
	viewad.input[ 7 ] = guiCreateMemo( 10, y + 60, width - 20, 90, advertisement.advertisement, false, viewad.window ) --Advertisement
	guiMemoSetReadOnly( viewad.input[ 7 ], true )
	
	if tonumber( getElementData( localPlayer, "dbid" ) ) == tonumber( advertisement.created_by ) or deleteAny then --Only display delete if they created the advert.
		-- Show the author's name to the author/admins
		guiCreateLabel( 100, 245, 200, 25, "Created By: " .. advertisement.author:gsub("_", " "), false, viewad.window )
		-- Allow the creator to repush the advert.
		viewad.pushButton = guiCreateButton( 10, height - 150, width - 20, 40, "Push Advertisement ($100)", false, viewad.window )
		
		if tonumber( getElementData( localPlayer, "dbid" ) ) ~= tonumber( advertisement.created_by ) then
			guiSetProperty( viewad.pushButton, 'NormalTextColour', 'FFFF0000' )
		end

		addEventHandler( "onClientGUIClick", viewad.pushButton, 
			function ()
				triggerServerEvent( resourceName .. ":push_advertisement", localPlayer, advertisement.id )
			end
		, false )
	end
	
	if tonumber( getElementData( localPlayer, "dbid" ) ) == tonumber( advertisement.created_by ) or deleteAny then --Only display delete if they created the advert.
		--We'll need a button to delete this if the player is the creator.
		viewad.deleteButton = guiCreateButton( 10, height - 100, width - 20, 40, "Delete Advertisement", false, viewad.window )
		
		if tonumber( getElementData( localPlayer, "dbid" ) ) ~= tonumber( advertisement.created_by ) then
			guiSetProperty( viewad.deleteButton, 'NormalTextColour', 'FFFF0000' )
		end

		addEventHandler( "onClientGUIClick", viewad.deleteButton, 
			function ()
				closeViewAd()
				triggerServerEvent( resourceName .. ":delete_advertisement", localPlayer, advertisement.id )
			end
		, false )
	end
	--Include a close button to exit the form.
	viewad.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, viewad.window )
	addEventHandler( "onClientGUIClick", viewad.closeButton, 
		function ()
			if source == viewad.closeButton then
				closeViewAd()
			end
		end
	, false )
end

function closeViewAd()
	if viewad and viewad.window and isElement(viewad.window) then
		--Clear all GUI elements and remove the cursor.
		guiSetInputEnabled ( false )
		--showCursor( false, false )
		guiSetVisible( viewad.window, false )
		destroyElement( viewad.window )
		viewad = { }
		if window and window.window and isElement(window.window) then
			guiSetEnabled(window.window, true)
		else
			showCursor( false, false )
		end
		--triggerServerEvent( resourceName .. ":open_ads", localPlayer ) --Call the server to open the advertisement window again.
	end
end


addEvent( resourceName .. ":display_all", true )
addEventHandler( resourceName .. ":display_all", root, 
	function( advertisements, canDeleteAnyAd )
		closeAds()
		deleteAny = canDeleteAnyAd
		showCursor( true, true )
		
		local width = 500 -- The width of our window
		local height = 500 -- The height of our window
		local x = SCREEN_X / 2 - width / 2 --Where on the screen our window will be located
		local y = SCREEN_Y / 2 - height / 2
		window.window = guiCreateWindow( x, y, width, height, "Advertisements", false ) --Create the window.
		
		--First we'll include a nice big button at the top for users to create an advertisement
		window.closeButton = guiCreateButton( 10, 30, width - 20, 40, "Create Advertisement", false, window.window )
		addEventHandler( "onClientGUIClick", window.closeButton, 
			function ()
				--Clear all GUI elements and open the creation dialog.
				--guiSetVisible( window.window, false )
				--destroyElement( window.window )
				--window = { }
				createAdvertisement( )
			end
		, false )
		
		
		window.mainPanel	= guiCreateTabPanel ( 10, 90, width - 15, height - 150, false, window.window ) --Create the panel to hold the different sections of advertisement
		
		--Variables to hold our GUI elements
		window.tab		= { }
		window.table	= { }
		window.colPhone = { }
		window.colName 	= { }
		window.colAd 	= { }
		
		for i = 1, #sections do --Loop through each of the 6 advertisement sections.
			
			window.tab[ i ]		= guiCreateTab( sections[ i ], window.mainPanel ) --Create a tab for each section
			window.table[ i ]	= guiCreateGridList ( 10, 10, width - 35, height - 190, false, window.tab[ i ] ) --In each tab include a table
			
			window.colPhone[ i ]= guiGridListAddColumn( window.table[ i ], "Phone", 0.2 ) --We'll just display phone, name and advertisement on the main page
			window.colName[ i ]	= guiGridListAddColumn( window.table[ i ], "Name", 0.2 )
			window.colAd[ i ]	= guiGridListAddColumn( window.table[ i ], "Advertisement", 0.5 )

			for ad = 1, #advertisements do --Loop through each advertisement
				if tonumber( advertisements[ ad ].section ) == i then
					local row = guiGridListAddRow ( window.table[ i ] ) --Add a row to the table.
					
					guiGridListSetItemText( window.table[ i ], row, window.colPhone[ i ], advertisements[ ad ].phone, false, false )
					guiGridListSetItemText( window.table[ i ], row, window.colName[ i ], advertisements[ ad ].name, false, false )
					guiGridListSetItemText( window.table[ i ], row, window.colAd[ i ], advertisements[ ad ].advertisement, false, false )
					
					--Include the advertisement key in the data for reference later.
					guiGridListSetItemData( window.table[ i ], row, window.colPhone[ i ], ad )
					
					--When the grid is double clicked, view the selected advertisement.
					addEventHandler( "onClientGUIDoubleClick", window.table[ i ],
						function ( button, state )
							if button == 'left' and state == 'up' and window and window.table then
								local selectedRow, selectedCol = guiGridListGetSelectedItem( window.table[ i ] )
								local key = guiGridListGetItemData( window.table[ i ], selectedRow, window.colPhone[ i ] )
								if advertisements[ key ] then
									viewAdvertisement( advertisements[ key ] )
								end
							end
						end
					, false )
				end
			end

			if guiGridListGetRowCount( window.table[ i ] ) == 0 then
				--If there are no current advertisements, leave a note for the user.
				local row = guiGridListAddRow ( window.table[ i ] )
				guiGridListSetItemText ( window.table[ i ], row, window.colPhone[ i ], "No Ads", false, false )
			end
		end
		
		--Include a close button to exit the form.
		window.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, window.window )
		addEventHandler( "onClientGUIClick", window.closeButton, 
			function ()
				if source == window.closeButton then
					closeAds()
				end
			end
		, false )
	end
)

function closeAds()
	if window and window.window and isElement(window.window) then
		--Clear all GUI elements and remove the cursor.
		showCursor( false, false )
		--guiSetVisible( window.window, false )
		destroyElement( window.window )
		window = { }
		closePostAd()
	end
end