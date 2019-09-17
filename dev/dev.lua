
addCommandHandler( 'countobjects',
	function( player, command )
		local objects = getElementsByType( 'object' )
		local vehicles = getElementsByType( 'vehicle' )
		local peds = getElementsByType( 'ped' )
		local genericsQuery = exports.mysql:query("SELECT COUNT(id) AS number FROM `worlditems` WHERE itemid = 80 AND dimension = 0")
		local inactiveVehiclesQuery = exports.mysql:query("SELECT COUNT(id) AS number FROM `vehicles` WHERE lastused < DATE_SUB(NOW(), INTERVAL 14 DAY)")
		local generics = exports.mysql:fetch_assoc( genericsQuery )
		local inactiveVehicles = exports.mysql:fetch_assoc( inactiveVehiclesQuery )
		outputChatBox( 'Objects Count: ', player, 155, 255, 155 )
		outputChatBox( 'Objects: ' .. table.getn( objects ), player, 155, 255, 155 )
		outputChatBox( 'Vehicles: ' .. table.getn( vehicles ), player, 155, 255, 155 )
		outputChatBox( 'Peds: ' .. table.getn( peds ), player, 155, 255, 155 )
		outputChatBox( 'Generics (World 0): ' .. generics.number, player, 155, 255, 155 )
		outputChatBox( 'Inactive Vehicles: ' .. inactiveVehicles.number, player, 155, 255, 155 )
		exports.mysql:free_result(genericsQuery)
		exports.mysql:free_result(inactiveVehiclesQuery)
	end
)

addCommandHandler( 'getresourcestate',
	function( player, command, resource )
		outputChatBox( 'Resource state of ' .. resource .. ': ' ..  getResourceState ( getResourceFromName( resource ) ), player, 155, 255, 155 )
	end
)