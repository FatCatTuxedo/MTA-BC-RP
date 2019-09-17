maxdistance = 350
defaultdistance = 50

--//Dont edit these!
triggerServerEvent ("clientIsReady", getRootElement())
width, height = guiGetScreenSize ()
speakers = {}

function startScript ()
	--//Create main GUI
	mainWindow = guiCreateWindow ((width/2) - (500/2), (height/2) - (417/2), 435, 200, "San Andreas Speaker", false)
	guiWindowSetSizable (mainWindow, false)
	--Buttons and event handlers
	closeButton = guiCreateButton (290, 87, 120, 60, "CLOSE", false, mainWindow)
	addEventHandler ("onClientGUIClick", closeButton, closeGUI)
	
	createButton = guiCreateButton (30, 87, 120, 60, "Create Speaker", false, mainWindow)
	addEventHandler ("onClientGUIClick", createButton, onCreateSpeakerClick)
	
	destroyButton = guiCreateButton (160, 87, 120, 60, "Delete Speaker", false, mainWindow)
	addEventHandler ("onClientGUIClick", destroyButton, onDestroySpeakerClick)

	--URL Stuff
	guiCreateLabel (120, 23, 100, 30, "Radio URL:", false, mainWindow)
	urlEdit = guiCreateEdit (52, 44, 200, 35, "", false, mainWindow) --50
	--Max distance
	guiCreateLabel (294, 23, 200, 30, "Distance (1 - " .. tostring(maxdistance) .. "):", false, mainWindow)
	distanceEdit = guiCreateEdit (325, 44, 50, 35, tostring(defaultdistance), false, mainWindow)
	--
	guiSetVisible (mainWindow, false)
	
	--Add some events
	addEvent ("speakerStuffFromServer", true)
	addEventHandler ("speakerStuffFromServer", getRootElement(), createSpeaker)
	
	addEvent ("destroySpeaker", true)
	addEventHandler ("destroySpeaker", getRootElement(), destroySpeaker)
	
	addEvent ("onPQuit", true)
	addEventHandler ("onPQuit", getRootElement(), onPlayerQuit)
end
addEventHandler ("onClientResourceStart", getResourceRootElement(), startScript)


function openOrCloseGUI ()
	if not exports.integration:isPlayerTrialAdmin(localPlayer) then
			return nil
	end
		if guiGetVisible (mainWindow) then
			guiSetVisible (mainWindow, false)
			showCursor (false)
		else
			guiSetVisible (mainWindow, true)
			showCursor (true)
		end
end
addCommandHandler ("speaker", openOrCloseGUI)


function closeGUI ()
	if source == closeButton then
		guiSetVisible (mainWindow, false)
		showCursor (false)
	end
end


function onCreateSpeakerClick ()
	if source == createButton then
		if speakers[player] then
			outputChatBox ("You already have a speaker!", 255, 0, 0)
		else
			local guiText = guiGetText (urlEdit)
			if guiText == "" then
				outputChatBox ("You need to type radio url!", 255, 0, 0)
			else
				local distance = guiGetText (distanceEdit)
				distance = tonumber (distance)
				if type (distance) ~= "number" then
					outputChatBox ("Distance have to be number!", 255, 0, 0)
				else
					if distance > maxdistance then
						outputChatBox ("Distance have to be between 1 - " .. maxdistance .. "!", 255, 0, 0)
						return false
					else
						if distance < 1 then
							outputChatBox ("Distance have to be between 1 - " .. maxdistance .. "!", 255, 0, 0)
							return false
						else
							player = localPlayer
							local url = guiGetText (urlEdit)
							local distance = guiGetText (distanceEdit)
							guiSetProperty(createButton, "Disabled", "True")
							triggerServerEvent ("onSpeakerCreate", getRootElement(), player, url, distance)
						end
					end
				end
			end
		end
	end
end


function onDestroySpeakerClick()
	if source == destroyButton then
		if not speakers[player] then
			outputChatBox ("You dont have a speaker!", 255, 0, 0)
		else
			guiSetProperty(createButton, "Disabled", "False")
			triggerServerEvent ("onSpeakerDestroy", getRootElement(), player)
		end
	end
end


function createSpeaker (player, url, distance, x, y, z, rotation)
	local url = tostring (url)
	speakers[player] = {}
	speakers[player]["sound"] = playSound3D (url, x, y, z)
	setSoundMaxDistance (speakers[player]["sound"], distance)
		local veh = getPedContactElement(player)
		if getElementType(veh) == "vehicle" then
			local px, py, pz = getElementPosition(player)
			local vx, vy, vz = getElementPosition(veh)
			local sx = px - vx
			local sy = py - vy
			local sz = pz - vz
			
			local rotpX = 0
			local rotpY = 0
			local rotpZ = getPedRotation(player)
			
			local rotvX,rotvY,rotvZ = getElementRotation(veh)
			
			local t = math.rad(rotvX)
			local p = math.rad(rotvY)
			local f = math.rad(rotvZ)
			
			local ct = math.cos(t)
			local st = math.sin(t)
			local cp = math.cos(p)
			local sp = math.sin(p)
			local cf = math.cos(f)
			local sf = math.sin(f)
			
			local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
			local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
			local y = st*sz - sf*ct*sx + cf*ct*sy
			
			local rotX = rotpX - rotvX
			local rotY = rotpY - rotvY
			local rotZ = rotpZ - rotvZ
		speakers[player]["object"] = createObject (2232, 0, 0, 0, 0, 0, rotation, true)
		setElementDimension ( speakers[player]["object"], getElementDimension(player) )
		setElementInterior ( speakers[player]["object"], getElementInterior(player) )
		setElementDimension ( speakers[player]["sound"], getElementDimension(player) )
		setElementInterior ( speakers[player]["sound"], getElementInterior(player) )
		attachElements(speakers[player]["object"], veh, x, y, z - 0.4, rotX, rotY, rotZ)
		attachElements(speakers[player]["sound"], speakers[player]["object"])
	else
		speakers[player]["object"] = createObject (2232, x, y, z, 0, 0, rotation)
		setElementDimension ( speakers[player]["object"], getElementDimension(player) )
		setElementInterior ( speakers[player]["object"], getElementInterior(player) )
		setElementDimension ( speakers[player]["sound"], getElementDimension(player) )
		setElementInterior ( speakers[player]["sound"], getElementInterior(player) )
		attachElements(speakers[player]["sound"], speakers[player]["object"])
	end
end


function destroySpeaker (player)
	destroyElement (speakers[player]["sound"])
	destroyElement (speakers[player]["object"])
	speakers[player] = false
end


function onPlayerQuit (player)
	if speakers[player] then
		destroyElement (speakers[player]["sound"])
		if speakers[player]["invehicle"] == "false" then
			destroyElement (speakers[player]["object"])
		end
		speakers[player] = false
	end
end

addEventHandler ( "onClientPreRender", root,
    function ( )
        for i,v in pairs ( speakers ) do
            if not v or not v["sound"] or getElementDimension ( localPlayer ) ~= getElementDimension ( v["sound"] ) then return end
            
            local x, y, z = getElementPosition ( v["sound"] )
            local px, py, pz = getElementPosition ( localPlayer )
            local distance = getDistanceBetweenPoints3D ( px, py, pz, x, y, z)
            local sx, sy = getScreenFromWorldPosition ( x, y, z + 0.7 )
			
            if sx and distance <= 20 then
                
                if isElement ( v["sound"] ) then
                    song = getSoundMetaTags ( v["sound"] )["stream_title"]
                end
                
                if type ( song ) == "string" then
					local stringLegth = string.len(song)*6
					dxDrawRectangle ( sx - (stringLegth / 2), sy, stringLegth + 15, 17.5, tocolor ( 0, 0, 0, 150 ) )
                    dxDrawText ( song, sx, sy, sx + 15, sy, tocolor ( 255, 255, 255, 255 ), 1, "default-bold", "center" )
                end
            end
        end
    end )