--[[
	iag.lua
	Internal Affairs system for keeping track of administrator statistics and faults.

	Author: CourtezBoi
	Since: 1/6/2015
]]

-- imports
local mysql = exports.mysql
local integration = exports.integration

function getAccountHours( id )
	local query = mysql:query( "SELECT `hoursplayed` FROM `characters` WHERE `account` = " .. id )
	local hours = 0
	while true do
		local character = mysql:fetch_assoc( query )
		if not character then break end
		hours = hours + tonumber( character.hoursplayed )
	end
	mysql:free_result( query )
	return hours
end

function updateIA()
	-- fetch the data from our game db
	local query = mysql:query( "SELECT `id`, `adminreports`, `username`, `admin`, `supporter` FROM `accounts` WHERE `admin` > 0 OR `supporter` > 0")
	while true do
		local admin = mysql:fetch_assoc( query )
		if not admin then break end

		local hoursplayed = getAccountHours( admin.id )
		local data = "http://courtezboi.com/ia/admin/addinfo/" .. table.concat( { admin.username, admin.adminreports, hoursplayed }, "/")
		fetchRemote( data, 
			function ( responseData, errno ) 
				outputDebugString( "IA: " .. responseData )
			end 
		) -- we forget about the callback function because we aren't trying to really fetch anything but moreso just send data.
	end
	mysql:free_result( query )
end

addEvent( "internal-affairs:submit", true)
addEventHandler( "internal-affairs:submit", root, updateIA )

addCommandHandler( "updateIA",
	function (player, command)
		if exports.integration:isPlayerLeadAdmin( player ) then
			updateIA()
			outputChatBox( "Updating IA.", player, 255, 255, 255 )
		end
	end, false, false
)