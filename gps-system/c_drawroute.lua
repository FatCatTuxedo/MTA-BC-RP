local ENABLE_FAILISH_ATTEMPT_AT_ANTI_ALIASING = false

local OVERLAY_WIDTH      = 256
local OVERLAY_HEIGHT     = 256
local OVERLAY_LINE_WIDTH = 5
local OVERLAY_LINE_COLOR = tocolor ( 0, 200, 0, 255 )
local OVERLAY_LINE_AA    = tocolor ( 0, 200, 0, 200 )

local linePoints  = { }
local renderStuff = { }

function removeLinePoints ( )
	linePoints = { }
	for name, data in pairs ( renderStuff ) do
		unloadTile ( name )
	end
end

function addLinePoint ( posX, posY )
	-- Calculate the row and column of the radar tile we will be targeting
	local row = 11 - math.floor  ( ( posY + 3000 ) / 500 )
	local col =      math.floor ( ( posX + 3000 ) / 500 )
	
	-- If it's off the map, don't bother
	if row < 0 or row > 11 or col < 0 or col > 11 then
		return false
	end
	
	-- Check the start position of the tile
	local startX = col * 500 - 3000
	local startY = 3000 - row * 500
	
	-- Now get the tile position (We don't want to calculate this for every point on render)
	local tileX = ( posX - startX ) / 500 * OVERLAY_WIDTH
	local tileY = ( startY - posY ) / 500 * OVERLAY_HEIGHT
	
	-- Now calulcate the ID and get the name of the tile
	local id   = col + row * 12
	local name = string.format ( "radar%02d", id )
	
	-- Make sure the line point table exists
	if not linePoints [ name ] then
		linePoints [ name ] = { }
	end
	
	-- Now add this point
	table.insert ( linePoints[name], { posX = tileX, posY = tileY } )
	
	-- Success!
	return true
end

function loadTile ( name )
	-- Create our fabulous shader. Abort on failure
	local shader = dxCreateShader ( "overlay.fx" )
	if not shader then
		return false
	end
	
	-- Create a render target. Again, abort on failure (don't forget to delete the shader!)
	local rt = dxCreateRenderTarget ( OVERLAY_WIDTH, OVERLAY_HEIGHT, true )
	if not rt then
		destroyElement ( shader )
		return false
	end
	
	-- Mix 'n match
	dxSetShaderValue ( shader, "gOverlay", rt )
	
	-- Start drawing
	dxSetRenderTarget ( rt )
	
	-- Get the points involved, and get the starting position
	local points = linePoints [ name ]
	local prevX, prevY = points [ 1 ].posX, points [ 1 ] .posY
	
	-- Loop through all points we have to draw, and draw them
	for index, point in ipairs ( points ) do
		local newX = point.posX
		local newY = point.posY
		
		if ENABLE_FAILISH_ATTEMPT_AT_ANTI_ALIASING then
			dxDrawLine ( prevX - 1, prevY - 1, newX - 1, newY - 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
			dxDrawLine ( prevX + 1, prevY - 1, newX + 1, newY - 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
			dxDrawLine ( prevX - 1, prevY + 1, newX - 1, newY + 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
			dxDrawLine ( prevX + 1, prevY + 1, newX + 1, newY + 1, OVERLAY_LINE_AA, OVERLAY_LINE_WIDTH )
		end
		
		dxDrawLine ( prevX, prevY, newX, newY, OVERLAY_LINE_COLOR, OVERLAY_LINE_WIDTH )
		
		prevX = newX
		prevY = newY
	end
	
	-- Now let's show our fabulous work to the commoners!
	engineApplyShaderToWorldTexture ( shader, name )
	
	-- Store the stuff in memories
	renderStuff [ name ] = { shader = shader, rt = rt }
	
	-- We won
	return true
end

function unloadTile ( name )
	destroyElement ( renderStuff[name].shader )
	destroyElement ( renderStuff[name].rt )
	renderStuff[name] = nil
	return true
end

addEventHandler ( "onClientRender", getRootElement ( ),
	function ( )
		local visibleTileNames = table.merge ( engineGetVisibleTextureNames ( "radar??" ), engineGetVisibleTextureNames ( "radar???" ) )
		
		for name, data in pairs ( renderStuff ) do
			if not table.find ( visibleTileNames, name ) then
				unloadTile ( name )
			end
		end
		
		for index, name in ipairs ( visibleTileNames ) do
			if linePoints [ name ] and not renderStuff [ name ] then
				loadTile ( name )
			end
		end
	end
)

local g_screenX,g_screenY = guiGetScreenSize()
local localPlayer = getLocalPlayer()

--Radar position/size 
local rel = { 	pos_x = 0.0625,
				pos_y = 0.76333333333333333333333333333333,
				size_x = 0.15,
				size_y = 0.175
}

local abs = { 	pos_x = math.floor(rel.pos_x * g_screenX),
				pos_y = math.floor(rel.pos_y * g_screenY),
				size_x = math.floor(rel.size_x * g_screenX),
				size_y = math.floor(rel.size_y * g_screenY)
}
abs.half_size_x =  abs.size_x/2
abs.half_size_y =  abs.size_y/2
abs.center_x = abs.pos_x + abs.half_size_x
abs.center_y = abs.pos_y +abs.half_size_y
local minBound = 0.1*g_screenY

addEvent ( "drawGPS", true )
route = {}
targetx, targety, targetz = nil
vehicle = nil
vehiclerot = nil
vehicleoffset = nil

function drawGPS ( newroute, tx, ty, tz, nvehicle )
	route = newroute
	
	targetx = tx
	targety = ty
	targetz = tz
	
	soundPlayed = false
	
	vehicle = nvehicle
	removeLinePoints ( )
	table.each(getElementsByType('marker'), destroyElement)
	for k,node in ipairs(newroute) do
		createMarker(node.x, node.y, node.z, 'corona', 5, 50, 0, 255, 200)
		addLinePoint ( node.x, node.y )
	end
end
addEventHandler ( "drawGPS", getRootElement(), drawGPS )

function getVehicleOffset(pos)
	local m = getElementMatrix ( vehicle )
	
	-- Substract the vehicle position from the player position
	pos[1] = pos[1]-m[4][1]
	pos[2] = pos[2]-m[4][2]
	pos[3] = pos[3]-m[4][3]
	
	-- Multiply the offsetted player position by the inverse vehicle rotation matrix
	local newPos = {}
	newPos[1] = pos[1] * m[1][1] + pos[2] * m[1][2] + pos[3] * m[1][3]
	--newPos[2] = pos[1] * m[2][1] + pos[2] * m[2][2] + pos[3] * m[2][3] We don't need the Y component (remove the comment to use for in front - in back
	--newPos[3] = pos[1] * m[3][1] + pos[2] * m[3][2] + pos[3] * m[3][3] We don't need the Z component
	
	if ( newPos[1] > 0 ) then
		return 2 -- right
	elseif ( newPos[1] < 0 ) then
		return 1 -- left
	else
		return 0 -- aligned
	end
end
local soundPlayer = false

function recalcRoute()
	local x, y, z = getElementPosition(localPlayer)
	
	--soundPlayed = false
	
	local newroute = calculatePathByCoords(targetx, targety, targetz, x, y, z)
	
	if ( newroute ) then
		drawGPS ( newroute, targetx, targety, targetz, vehicle )
	end
end

addEventHandler ( "onClientRender", getRootElement(),
	function()
		if (route) then
			for k,node in ipairs(route) do
				local bDraw = true
				if (#route==1) then -- reached our destination
					drawGPS(nil, nil, nil, nil, nil)
					
					if (vehicleoffset==0) then
						outputChatBox("GPS: Arriving at destination on Right", 255, 194, 15)
					else
						outputChatBox("GPS: Arriving at destination on Right", 255, 194, 15)
					end
					return
				end
				
				if (k==#route) then
					local px, py, pz = getElementPosition(getLocalPlayer())
					distance = getDistanceBetweenPoints2D(px, py, node.x, node.y)

					if (distance<10) then
						bDraw = false
						table.remove(route, k) -- pop this one off the route
						--soundPlayed = false
					elseif (distance>50) then
						bDraw = false
						recalcRoute()
						--soundPlayed = false
					end
				end
			
				vx, vy, vz = getElementRotation(vehicle)
				local x = node.x
				local y =  node.y
				local pos = { x, y, 0 }
				vehicleoffset = getVehicleOffset(pos)
				
				
				if (vehiclerot) then
					if ( vz >= vehiclerot + 80  and vehicleoffset==0) then
						soundPlayed = false
						vehiclerot = vz
					elseif ( vz <= vehiclerot - 80  and vehicleoffset==1) then
						soudPlayed = false
						vehiclerot = vz
					end
				end
			
				if not (soundPlayed) then
					soundPlayed = true
					
					vehiclerot = vz
					if (vehicleoffset==2) then -- RIGHT
						playSound("Right.wav")
					elseif (vehicleoffset==1) then
						playSound("Left.wav")
					else
						soundPlayed = false
					end
				end
			
				if ( bDraw ) then
					local x,y = getScreenRadarPositionFromWorld ( node.x, node.y )
					if x and y then
						local previousNode = route[k-1]
						if previousNode then
							endX,endY = getScreenRadarPositionFromWorld ( previousNode.x, previousNode.y )
							if endX and endY then
								dxDrawLine ( x, y, endX, endY, tocolor(251,139,0,180), 5 )
							end
						end
					end
				end
			end
		end
	end
)

function getRadarScreenRadius ( angle ) --Since the radar is not a perfect ciricle, we work out the screen size of the radius at a certain angle
	return math.abs((math.sin(angle)*(abs.half_size_x - abs.half_size_y))) + abs.half_size_y
end


function getScreenRadarPositionFromWorld (posX,posY)
	if not isPlayerMapVisible() then --Render to the radar
		return false
	else --Render to f11 map
		local minX,minY,maxX,maxY = getPlayerMapBoundingBox()
		local sizeX = maxX - minX
		local sizeY = maxY - minY
		--
		sizeX = sizeX/6000
		sizeY = sizeY/6000
		--
		local mapX = posX + 3000
		local mapY = posY + 3000
		mapX = mapX*sizeX + minX
		mapY = maxY - mapY*sizeY
		return mapX,mapY
	end
end

--Simple RotZ calc (Only need RotZ since we're in 2D)
function getVectorRotation (px, py, lx, ly )
	local rotz = 6.2831853071796 - math.atan2 ( ( lx - px ), ( ly - py ) ) % 6.2831853071796
 	return -rotz
end

