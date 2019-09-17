-- WATCH


local watcher = { }
local watched = { }
local watchTimers = { }


function takeScreen( )
	for i, k in pairs( watched ) do
		if isElement( i ) then
			takePlayerScreenShot( i, 200, 200, getPlayerName( i ), 50, 1000000 )
		end
	end
end
setTimer( takeScreen, 50, 0 )

addEventHandler( "onPlayerScreenShot", root,
	function ( theResource, status, imageData, timestamp, tag )
		if status == "ok" then
			if watched[ source ] then
				for i, k in pairs( watched[ source ] ) do
					if not isElement( k ) then
						watched[ source ][ i ] = nil
						watcher[ k ] = nil
						if watchTimers[ k ] then
							killTimer( watchTimers[ k ])
						end
					else
						triggerClientEvent( k, "updateScreen", k, imageData, source )
					end
				end
			end
		end
	end
)

function setWatch( player, other )
	if watcher[ player ] then
		if watched[ watcher[ player ] ] then
			for i, k in pairs( watched[ watcher[ player ] ] ) do
				if k == player then
					watched[ watcher[ player ] ][ i ] = nil
				end
			end
		end
	end
	watcher[ player ] = other
	if not watched[ other ] then
		watched[ other ] = { }
	end
	table.insert( watched[ other ], player )
end


function updateAutoWatch( player )
	local nextIncrement = 0
	for index, other in ipairs( getElementsByType( 'player' )) do
		if nextIncrement == 1 then
			setWatch( player, other )
			return
		elseif watcher[ player ] == other then
			nextIncrement = 1
		end
	end
	setWatch( player, getElementsByType( 'player' )[ 1 ])
end

addCommandHandler( 'autowatch',
	function ( player, command, interval )
		if exports.integration:isPlayerTrialAdmin( player ) then
			interval = tonumber( interval )
			if interval then
				watchTimers[ player ] = setTimer( updateAutoWatch, interval * 1000, 0, player )
				setWatch( player, getElementsByType( 'player' )[ 1 ])
			else
				outputChatBox( "/" .. command .. " [time interval]", player, 255, 255, 255 )
			end
		end
	end
)

addCommandHandler( 'pausewatch',
	function (player, command)
		if exports.integration:isPlayerTrialAdmin( player ) then
			if watchTimers[ player ] then
				killTimer( watchTimers[ player])
				outputChatBox( 'Watch timer paused.', player, 255, 102, 0 )
			else
				outputChatBox( 'You do not have watch enabled!', player, 255, 155, 155 )
			end
		end
	end
)

addCommandHandler( 'resumewatch',
	function ( player, command, interval )
		if exports.integration:isPlayerTrialAdmin( player ) then
			interval = tonumber( interval )
			if interval then
				watchTimers[ player ] = setTimer( updateAutoWatch, interval * 1000, 0, player )
			else
				outputChatBox( "/" .. command .. " [time interval]", player, 255, 255, 255 )
			end
		end
	end
)


addCommandHandler( 'stopwatch',
	function( player, command )
		if watcher[ player ] and watched[ watcher[ player ] ] then
			for i, k in pairs( watched[ watcher[ player ] ] ) do
				if k == player then
					watched[ watcher[ player ] ][ i ] = nil
				end
			end
			watcher[ player ] = nil
			killTimer( watchTimers[ player ] ) -- stop the auto updating timer
			outputChatBox( "You are no longer watching anyone.", player, 255, 155, 155 )
		end
		triggerClientEvent( player, "stopScreen", player )
	end
)

addCommandHandler( "watch",
	function( player, command, other )
		if exports.integration:isPlayerTrialAdmin( player ) then
			if other then
				local other, name = exports.global:findPlayerByPartialNick( player, other )
				if other then
					-- remove the original watch before moving to a new one
					if watcher[ player ] and watched[ watcher[ player ] ] then
						for i, k in pairs( watched[ watcher[ player ] ] ) do
							if k == player then
								watched[ watcher[ player ] ][ i ] = nil
							end
						end
					end
					watcher[ player ] = other
					if not watched[ other ] then
						watched[ other ] = { }
					end
					table.insert( watched[ other ], player )
					outputChatBox( "You are now watching " .. name .. ".", player, 155, 255, 155 )
				end
			else
				if watcher[ player ] and watched[ watcher[ player ] ] then
					for i, k in pairs( watched[ watcher[ player ] ] ) do
						if k == player then
							watched[ watcher[ player ] ][ i ] = nil
						end
					end
					watcher[ player ] = nil
					triggerClientEvent( player, "stopScreen", player )
					outputChatBox( "You are no longer watching anyone.", player, 255, 155, 155 )
				else
					triggerClientEvent( player, "stopScreen", player )
					outputChatBox( "SYNTAX: /"..command.." [Player]", player, 255, 255, 255 )
				end
			end
		end
	end, false, false
)

addEventHandler( "onPlayerQuit", root,
	function()
		watcher[ source ] = nil
		for i, k in pairs( watched ) do
			for l, m in pairs( k ) do
				if source == m then
					watched[ i ][ l ] = nil
				end
			end
		end
		watched[ source ] = nil
	end
)

