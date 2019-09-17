local floor = math.floor
route = { }
targetx, targety, targetz = nil

addCommandHandler('gps', 
	function(command, tox, toy, toz)
		if not exports.integration:isPlayerScripter(getLocalPlayer()) then
			return
		end
		if not tonumber(tox) or not tonumber(toy) then
			outputChatBox("Usage: /gps x y z (z is optional)", 255, 0, 0)
			return
		end
		local x,y,z = getElementPosition(getLocalPlayer())
		route = server.calculatePathByCoords(x, y, z, tox, toy, toz)
		targetx, targety, targetz = tox, toy, toz
		if not route then
			outputChatBox("no path found", 255, 0, 0)
			return
		end
		
		removeLinePoints ( )
		for i,node in ipairs(route) do
			addLinePoint ( node.x, node.y )
		end
	end
)

local function getAreaID(x, y)
	return math.floor((y + 3000)/750)*8 + math.floor((x + 3000)/750)
end

local function getNodeByID(db, nodeID)
	local areaID = floor(nodeID / 65536)
	return db[areaID][nodeID]
end

--[[
addEventHandler('onClientRender', getRootElement(),
	function()
		local db = vehicleNodes
		
		local camX, camY, camZ = getCameraMatrix()
		local x, y, z = getElementPosition(getLocalPlayer())
		local areaID = getAreaID(x, y)
		local drawn = {}
		for id,node in pairs(db[areaID]) do
			if getDistanceBetweenPoints3D(x, y, z, node.x, node.y, z) < 300 then
				--[/[
				local screenX, screenY = getScreenFromWorldPosition(node.x, node.y, node.z)
				if screenX then
					dxDrawText(tostring(id), screenX - 10, screenY - 5)
				end
				--]/]
				--[/[
				for neighbourid,distance in pairs(node.neighbours) do
					if not drawn[neighbourid .. '-' .. id] then
						local neighbour = getNodeByID(db, neighbourid)
						dxDrawLine3D(node.x, node.y, node.z + 1, neighbour.x, neighbour.y, neighbour.z + 1, tocolor(0, 0, 200, 255), 3)
						drawn[id .. '-' .. neighbourid] = true
					end
				end
				--]/]
			end
		end
	end
)
--]]

local localPlayer = getLocalPlayer()
local iMap = nil
local helpLabel = nil
local vehicle = nil
local seat = nil

function displayGPS()
	vehicle = source
	if (iMap) then
		hideGUI()
	else
		showGUI()
	end
end
addEvent("displayGPS", true)
addEventHandler("displayGPS", getRootElement(), displayGPS)

function hideGUI()
	showCursor(false)
	
	if (isElement(iMap)) then
		destroyElement(iMap)
	end
	iMap = nil
	
	if (isElement(helpLabel)) then
		destroyElement(helpLabel)
	end
	helpLabel = nil
	
	vehicle = nil
	
	call(getResourceFromName("realism-system"), "showSpeedo")
end

function onVehicleEnter(player, nseat)
	if (player==localPlayer) then
		vehicle = source
		seat = nseat
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), onVehicleEnter)

function showGUI()
	resetRoute()
	
	local width, height = 700, 700
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)

	iMap = guiCreateStaticImage(x, y, width, height, "map.jpg", false) -- Map
	
	local height = 50
	local y = scrHeight - (height/1.5)
	helpLabel = guiCreateLabel(x, y, width, height, "Left click to set GPS Target - Right click to disable GPS", false)
	guiLabelSetHorizontalAlign(helpLabel, "center")
	guiSetFont(helpLabel, "default-bold-small")
	
	call(getResourceFromName("realism-system"), "hideSpeedo")
	
	addEventHandler("onClientGUIClick", iMap, calculateRouteOnClick, false)
	showCursor(true)
end

function resetRoute()
	route = { }
end


function resetRouteOnExit(player)
	if (player==localPlayer) then
		resetRoute()
		hideGUI()
	end
end
addEventHandler("onClientVehicleExit", getRootElement(), resetRouteOnExit)


function convert2DMapCoordToWorld(relX, relY)
	local scrWidth, scrHeight = guiGetScreenSize()
	local relX, relY, wx, wy, wz = getCursorPosition()

	local ax, ay = guiGetPosition( iMap, true )
	local bx, by = guiGetSize( iMap, true )
	local cx, cy = getCursorPosition()
	cxr = ( cx - ax ) / bx
	cyr = ( cy - ay ) / by
	
	local x = cxr*6000 - 3000
	local y = 3000 - cyr*6000
	
	local z = getGroundPosition(x, y, 1500)
	return x, y, z
end

function calculateRouteOnClick(button, state, absx, absy)
	if (button=="left")  then
		tx, ty, tz = convert2DMapCoordToWorld(absx, absy)
		targetx, targety, targetz = convert2DMapCoordToWorld(absx, absy)
		local x, y, z = getElementPosition(localPlayer)
		route = server.calculatePathByCoords(tx, ty, tz, x, y, z)

		if not route then
			hideGUI()
			outputConsole('No path found')
			return
		end
		
		removeLinePoints ( )
		for i,node in ipairs(route) do
			addLinePoint ( node.x, node.y )
		end
		
		hideGUI()
	else
		resetRoute()
		hideGUI()
	end
end

function recalcRoute()
	local x, y, z = getElementPosition(localPlayer)
	
	--soundPlayed = false
	
	route = calculatePathByCoords(targetx, targety, targetz, x, y, z)
	
	if ( route ) then
		removeLinePoints ( )
		for i,node in ipairs(route) do
			addLinePoint ( node.x, node.y )
		end
	end
end

function check()
	if (route) then
		for k,node in ipairs(route) do
			if (#route==1) then
				removeLinePoints ( )
				outputChatBox("GPS: You have arrived!", 255, 0, 0)
				route = { }
			end
		end
		if (k==#route) then
			local px, py, pz = getElementPosition(getLocalPlayer())
			distance = getDistanceBetweenPoints2D(px, py, node.x, node.y)

			if (distance<10) then
				table.remove(route, k) -- pop this one off the route
			elseif (distance>50) then
				recalcRoute()
			end
		end
	end
end
addEventHandler("onClientRender", getRootElement(), check)