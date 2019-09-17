--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )

------------------------------------------
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

function getShortTime( timestamp )
	local months = { "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC" }
	local time = nil
	local ts = nil
	
	if timestamp then
		time = getRealTime( timestamp )
	else
		time = getRealTime( )
	end
	
	ts = time.hour .. ":"..("%02d"):format(time.minute)
	ts =  months[ time.month + 1 ] .. " ".. time.monthday .. ", " .. tostring( tonumber( time.year ) + 1900 ) .. " " .. ts
	
	return ts
end

function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end

------------------------------------------
function display_property ( id, interiorType, owner, cost, name, district )
	local width = 400
	local height = 220
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window = { }
	window.window = guiCreateWindow( x, y, width, height, "MDC Search - Property: ".. id, false )
	
	window.zipLabel		= guiCreateLabel( 10, 30, 180, 20, "ZIP Code: ", false, window.window )
	window.typeLabel 	= guiCreateLabel( 10, 50, 180, 20, "Type: ", false, window.window )
	window.ownerLabel	= guiCreateLabel( 10, 70, 180, 20, "Owner: ", false, window.window )
	window.costLabel	= guiCreateLabel( 10, 90, 180, 20, "Cost: ", false, window.window )
	window.nameLabel	= guiCreateLabel( 10, 110, 180, 20, "Name: ", false, window.window )
	window.districtLabel= guiCreateLabel( 10, 130, 220, 20, "District: ", false, window.window )
	
	window.zipLabel		= guiCreateLabel( 105, 30, 180, 20, tostring( id ), false, window.window )
	window.typeLabel 	= guiCreateLabel( 105, 50, 180, 20, interiorType, false, window.window )
	window.ownerButton	= guiCreateButton( 105, 70, 180, 20, owner, false, window.window )
	window.costLabel	= guiCreateLabel( 105, 90, 180, 20, cost, false, window.window )
	window.nameLabel	= guiCreateLabel( 105, 110, 180, 20, name, false, window.window )
	window.districtLabel= guiCreateLabel( 105, 130, 220, 20, district, false, window.window )
	
	addEventHandler( "onClientGUIClick", window.ownerButton, 
	function ()
		guiSetInputEnabled ( false )
		guiSetVisible( window.window, false )
		destroyElement( window.window )
		window = { }
		triggerServerEvent( resourceName .. ":search", getLocalPlayer(), owner )
	end
	, false )
	
	window.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, window.window )
	addEventHandler( "onClientGUIClick", window.closeButton, 
		function ()
			guiSetInputEnabled ( false )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			if getElementData( getLocalPlayer(), "mdc_close_to" ) then
				triggerServerEvent( resourceName .. ":search", getLocalPlayer(), getElementData( getLocalPlayer(), "mdc_close_to" ), getElementData( getLocalPlayer(), "mdc_close_type" ) )
				setElementData( getLocalPlayer(), "mdc_close_to", nil )
			else
				triggerServerEvent( resourceName .. ":main", getLocalPlayer() )
			end
		end
	, false )
end
------------------------------------------
addEvent( resourceName .. ":display_property", true )
addEventHandler( resourceName .. ":display_property", getRootElement(), display_property )
