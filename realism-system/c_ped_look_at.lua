--MAXIME
local viewDistance = 50
local lookTimer = nil

function onClientLookAtRender()
	if getElementData(localPlayer, "head_turning") == "2" then
		local rotcam = math.rad (360 - getPedCameraRotation (localPlayer))
		local xpos,ypos,zpos = getPedBonePosition (localPlayer, 8)
		local xlook,ylook,zlook = xpos - 300*math.sin(rotcam), ypos + 300*math.cos(rotcam), zpos
		setPedLookAt (localPlayer, xlook, ylook, zlook, -1)
		--outputDebugString("onClientLookAtRender")
	end
end

function lookAtClosestElement()
	local player = getClosestPlayer()
	local vehicle = getClosestVehicle()
	if (player and isElement(player)) or (vehicle and isElement(vehicle)) then
		setPedLookAt (localPlayer, 0, 0, 0, 3000, 1000, player or vehicle)
		--outputDebugString(player and getElementData(player, "dbid") or getElementData(vehicle, "dbid"))
	end
end
--addCommandHandler("cmd1", lookAtClosestElement)

function getClosestPlayer()
	local playersOnsight = {}
	for key, player in ipairs(getElementsByType("player")) do
		local x,y,z = getElementPosition(player)			
		local cx,cy,cz = getCameraMatrix()
		local distance = getDistanceBetweenPoints3D(cx,cy,cz,x,y,z)
		if distance <= viewDistance and (player~=localPlayer) then --Within radius viewDistance
			local px,py,pz = getScreenFromWorldPosition(x,y,z,0.05)
			if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
				if isElement(player) then
					table.insert(playersOnsight, {player, distance})
				end
			end
		end
	end
	
	local closest = 0
	for i = 1, #playersOnsight do
		if playersOnsight[i+1] and (playersOnsight[i][2] < playersOnsight[i+1][2]) then
			local temp = playersOnsight[i]
			playersOnsight[i] = playersOnsight[i+1]
			playersOnsight[i+1] = temp
		end
	end
	
	if #playersOnsight > 0 then
		return playersOnsight[#playersOnsight][1] 
	else
		return false
	end
end

function getClosestVehicle()
	local vehsOnsight = {}
	for key, vehicle in ipairs(getElementsByType("vehicle")) do
		local x,y,z = getElementPosition(vehicle)			
		local cx,cy,cz = getCameraMatrix()
		local distance = getDistanceBetweenPoints3D(cx,cy,cz,x,y,z)
		if distance <= viewDistance then --Within radius viewDistance
			local px,py,pz = getScreenFromWorldPosition(x,y,z,0.05)
			if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
				if isElement(vehicle) then
					table.insert(vehsOnsight, {vehicle, distance})
				end
			end
		end
	end
	
	local closest = 0
	for i = 1, #vehsOnsight do
		if vehsOnsight[i+1] and (vehsOnsight[i][2] < vehsOnsight[i+1][2]) then
			local temp = vehsOnsight[i]
			vehsOnsight[i] = vehsOnsight[i+1]
			vehsOnsight[i+1] = temp
		end
	end
	
	if #vehsOnsight > 0 then
		return vehsOnsight[#vehsOnsight][1] 
	else
		return false
	end
end

function updateLookAt()
	if isTimer(lookTimer) then
		killTimer(lookTimer)
	end
	setPedLookAt (localPlayer, 0, 0, 0, 0 )
	
	local state = getElementData(localPlayer, "head_turning") or "0"
	
	if state == "1" then
		lookTimer = setTimer(lookAtClosestElement, 4000, 0)	
	end
end
addEvent("realism:updateLookAt", false)
addEventHandler( "realism:updateLookAt", root, updateLookAt )

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()),
    function ( startedRes )
        addEventHandler ("onClientRender", root, onClientLookAtRender)
		updateLookAt()
    end
)
