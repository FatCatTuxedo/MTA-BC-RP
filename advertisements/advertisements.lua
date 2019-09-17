--[[
--	Copyright (C) LettuceBoi Development - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, May 2013
]]--

local SERVICES_SECTION = 1		--Places to offer services such as house cleaning or mechanics and whatnot
local CARS_VEHICLES_SECTION = 2	--Offer to buy or sell a vehicle in this section
local REAL_ESTATE_SECTION = 3	--Houses for sale go in this section
local COMMUNITY_SECTION = 4		--Advertisements about communities can go here, for example, palomino creek.
local JOBS_SECTION = 5 			--Advertisements about hiring people or looking for work will go in this section
local PERSONALS_SECTION = 6		--People looking for other people go in this section
local COOLDOWN_MINUTES = 5 		--Number of minutes between push alerts being sent by players
local resourceName = getResourceName( getThisResource( ) )

local sections = { "Services", "Cars & Vehicles", "Real Estate", "Community", "Jobs", "Personals" }

--[[
	Small function to shorten the escaping of strings.
]]
function escape( value )
	return exports.mysql:escape_string( value )
end

function now( )
	return tonumber( getRealTime().timestamp )
end
--[[
	Triggered when a user completes the form to create an advertisement.
]]
addEvent( resourceName .. ":create_advertisement", true )
addEventHandler( resourceName .. ":create_advertisement", root, 
	function( phone, name, address, advertisement, expires, section )
		--Check if all fields have been entered by the user.
		
		if not ( phone == nil or name == nil or address == nil or advertisement == nil ) then
			--Fetch the created by 
			local createdBy = tostring( getElementData( source, "dbid" ) )
			
			--Get the current server time to store as our start time
			local start = getRealTime().timestamp
			--Add the time until expiry to the start time to get the actual time it will expire.
			local expiry = start + expires
			
			--Check if our query went into the database successfully.
			if exports.mysql:insert( 'advertisements', { phone = phone, name = name, address = address, advertisement = advertisement, start = start, expiry = expiry, section = section, created_by = createdBy } ) then
				--We'll send something to the client side so they can close the add form and reopen the main advertisements form.
				--openAdvertisements( source, nil )
			else
				--If the database query was unsucessful, alert the end user.
				outputChatBox( "SQL Error.", source )
				triggerClientEvent( source, resourceName .. ":ad_create_fail", root )
			end
		else
			--If all fields were not entered, alert the user.
			outputChatBox( "Field Error.", source )
			triggerClientEvent( source, resourceName .. ":ad_create_fail", root )
		end
	end
)

local coolDown = {}

addEvent( resourceName .. ":push_advertisement", true )
addEventHandler( resourceName .. ":push_advertisement", root, 
	function( id )
		local advertisement = exports.mysql:select_one( "advertisements", { id = id } )
		advertisement.author = exports.mysql:select_one( "characters", { id = advertisement.created_by } ).charactername
		if not coolDown[ id ] or ( coolDown[ id ] < now() - ( 60 * COOLDOWN_MINUTES ) ) then
			if exports.bank:takeBankMoney( client, 50) then
				coolDown[ id ] = now()
				for i, k in pairs( getElementsByType( 'player' ) ) do
					if exports.integration:isPlayerTrialAdmin( k ) then
						outputChatBox( "ADVERT: " .. advertisement.advertisement .. " | Ph: " .. advertisement.phone .. " | Cat: " .. sections[ tonumber( advertisement.section ) ] .. " (( " .. advertisement.author:gsub("_", " ") .." )) .", k, 0, 255, 0 )
					else
						outputChatBox( "ADVERT: " .. advertisement.advertisement .. " | Ph: " .. advertisement.phone .. " | Cat: " .. sections[ tonumber( advertisement.section ) ] .. ".", k, 0, 255, 0 )
					end
				end
			else
				outputChatBox( "You do not have enough money in the bank to push this advertisement.", client, 255, 155, 155 )
			end
		else
			outputChatBox( "You can only push your advertisement once every " .. COOLDOWN_MINUTES .. " minutes.", client, 255, 155, 155 )
		end
	end
)

--[[
	Called when the delete button on the view advertisement page is clicked
]]

function deleteAdvertisement( id )
	return exports.mysql:delete('advertisements', {id = id})
end

addEvent( resourceName .. ":delete_advertisement", true )
addEventHandler( resourceName .. ":delete_advertisement", root, 
	function( id )
		if deleteAdvertisement( id ) then
			--openAdvertisements( source )
		else
			outputChatBox( "An error occured with deleting that ad.", source, 255, 100, 100 )
		end
	end
)

--[[
	The main function to open the entire advertisements system.
]]
function openAdvertisements( player, command )
	local advertisements = { } --These will hold our advertisements to send to the client and populate our advertisement tables.

	if not player then player = source end

	--Fetch all of the advertisements from the database
	for _, ad in ipairs( exports.mysql:select('advertisements') ) do
		if tonumber( ad.expiry ) >= tonumber( getRealTime().timestamp ) then --Check if the advertisement has expired, delete it if so.
			ad.author = exports.mysql:select_one( "characters", { id = ad.created_by } ).charactername
			table.insert( advertisements, ad )
		else
			deleteAdvertisement( ad.id )
		end
	end

	triggerClientEvent( player, resourceName .. ":display_all", root, advertisements, exports.integration:isPlayerAdmin( player ) ) --Send the advertisements to the client to create the GUI.
end
addCommandHandler( "advertisements", openAdvertisements, false, false )
addCommandHandler( "ads", openAdvertisements, false, false )
addCommandHandler( "classifieds", openAdvertisements, false, false )
addEvent( resourceName .. ":open_ads", true )
addEventHandler( resourceName .. ":open_ads", root, openAdvertisements )