local pedTable = { }
local characterSelected, characterElementSelected, newCharacterButton, bLogout = nil
selectionScreenID = 3
function Characters_showSelection()
	characters_destroyDetailScreen()
	triggerEvent("onSapphireXMBShow", getLocalPlayer())
	showPlayerHudComponent("radar", false)

	guiSetInputEnabled(false)

	showCursor(true)

	setElementDimension ( getLocalPlayer(), 1 )
	setElementInterior( getLocalPlayer(), 0 )

	for _, thePed in ipairs(pedTable) do
		if isElement(thePed) then
			destroyElement(thePed)
		end
	end

	selectionScreenID = 3

	startCam[selectionScreenID] = originalStartCam[selectionScreenID]

	local x, y, z, rot =  pedPos[selectionScreenID][1], pedPos[selectionScreenID][2], pedPos[selectionScreenID][3], pedPos[selectionScreenID][4]
	local characterList = getElementData(getLocalPlayer(), "account:characters")
	if (characterList) then
		-- Prepare the peds
		local count = 0
		local oldPos = y
		for _, v in ipairs(characterList) do
			local thePed = createPed( tonumber( v[9]), x, y, z)
			setPedRotation(thePed, rot)
			setElementDimension(thePed, 1)
			setElementInterior(thePed, 0)
			setElementData(thePed,"account:charselect:id", v[1], false)
			setElementData(thePed,"account:charselect:name", v[2]:gsub("_", " "), false)
			setElementData(thePed,"account:charselect:cked", v[3], false)
			setElementData(thePed,"account:charselect:lastarea", v[4], false)
			setElementData(thePed,"account:charselect:lastseen", v[10], false)
			setElementData(thePed,"account:charselect:age", v[5], false)
			setElementData(thePed,"account:charselect:weight", v[11], false)
			setElementData(thePed,"account:charselect:height", v[12], false)
			--setElementData(thePed,"account:charselect:desc", v[13], false)
			setElementData(thePed,"account:charselect:age", v[5], false)
			setElementData(thePed,"account:charselect:gender", v[6], false)
			setElementData(thePed,"account:charselect:faction", v[7] or "", false)
			setElementData(thePed,"account:charselect:factionrank", v[8] or "", false)
			setElementData(thePed,"clothing:id", v[15] or "", false)

			setElementData(thePed,"account:charselect:month", v[13], false)
			setElementData(thePed,"account:charselect:day", v[14], false)

			local randomAnimation = getRandomAnim( v[3] == 1 and 4 or 2 )
			setPedAnimation ( thePed , randomAnimation[1], randomAnimation[2], -1, true, false, false, false )


            if selectionScreenID == 0 then
                y = y - 3
                count = count + 1
                if count >= 4 then
                    count = 0
                    y = oldPos
                	x = x - 3
                end
			elseif selectionScreenID == 1 then
				y = y + 3
				count = count + 1
				if count >= 6 then
					count = 0
					y = oldPos
					x = x - 3
				end
			elseif selectionScreenID == 2 then
				y = y + 3
				count = count + 1
				if count >= 6 then
					count = 0
					y = oldPos
					x = x - 3
				end
			elseif selectionScreenID == 3 then
				y = y - 3
				count = count + 1
				if count >= 6 then
					count = 0
					y = oldPos
					x = x - 3
				end
			end

			table.insert(pedTable, thePed)
		end

		-- Cam magic
		fadeCamera ( false, 0, 0,0,0 )
		setCameraMatrix (originalStartCam[selectionScreenID][1], originalStartCam[selectionScreenID][2], originalStartCam[selectionScreenID][3], originalStartCam[selectionScreenID][4], originalStartCam[selectionScreenID][5], originalStartCam[selectionScreenID][6])
		setTimer(function ()
			fadeCamera ( true, 1, 0,0,0 )
		end, 1000, 1)

		setTimer(function ()
			showCursor(true)
			addEventHandler("onClientRender", getRootElement(), Characters_updateSelectionCamera)
			addEventHandler("onClientRender", getRootElement(), renderNametags)
			
			local selectionSound = playSound ( "selection_screen.mp3")
			setSoundVolume(selectionSound, 0.3)
			setElementData(localPlayer, "selectionSound", selectionSound)
			
		end, 2000, 1)


	end
end

function Characters_characterSelectionVisisble()
	addEventHandler("onClientClick", getRootElement(), Characters_onClientClick)

	local swidth, sheight = guiGetScreenSize()
	local width, height = 300, 50


	bLogout = guiCreateStaticImage(swidth-width, 0, width, height, ":resources/window_body.png" , false, nil)
	local text1= guiCreateLabel (0,0,1,1, "Logout", true, bLogout)
	guiLabelSetHorizontalAlign(text1, "center", true)
	guiLabelSetVerticalAlign(text1, "center", true)

	addEventHandler("onClientGUIClick", bLogout, function ()
		removeEventHandler("onClientRender", getRootElement(), renderNametags)
		fadeCamera ( false, 2, 0,0,0 )
		setTimer(function()
			triggerServerEvent("accounts:reconnectMe", localPlayer)
		end, 2000,1)

	end)

	newCharacterButton = guiCreateStaticImage(swidth-width, 53, width, height, ":resources/window_body.png" , false, nil)
	local text2= guiCreateLabel (0,0,1,1, "Create a new character!", true, newCharacterButton)
	guiLabelSetHorizontalAlign(text2, "center", true)
	guiLabelSetVerticalAlign(text2, "center", true)
	addEventHandler("onClientGUIClick", newCharacterButton, Characters_newCharacter)
end

function getCamSpeed( index1, startCam1, endCam1, globalspeed1)
	return (math.abs(startCam1[index1]-endCam1[index1])/globalspeed1)
end

--Check c_login.lua for settings block
function Characters_updateSelectionCamera ()
	for var = 1, 6, 1 do
		if not doneCam[selectionScreenID][var] then
			--outputDebugString("if not doneCam[selectionScreenID][var] then")
			if (math.abs(startCam[selectionScreenID][var] - endCam[selectionScreenID][var]) > 0.2) then
				if startCam[selectionScreenID][var] > endCam[selectionScreenID][var] then
					startCam[selectionScreenID][var] = startCam[selectionScreenID][var] - getCamSpeed( var, startCam[selectionScreenID], endCam[selectionScreenID], globalspeed)
				else
					startCam[selectionScreenID][var] = startCam[selectionScreenID][var] + getCamSpeed( var, startCam[selectionScreenID], endCam[selectionScreenID], globalspeed)
				end
			else
				doneCam[selectionScreenID][var] = true
			end
		end
	end

	setCameraMatrix (startCam[selectionScreenID][1], startCam[selectionScreenID][2], startCam[selectionScreenID][3], startCam[selectionScreenID][4], startCam[selectionScreenID][5], startCam[selectionScreenID][6])
	if doneCam[selectionScreenID][1] and doneCam[selectionScreenID][2] and doneCam[selectionScreenID][3] and doneCam[selectionScreenID][4] and doneCam[selectionScreenID][5] and doneCam[selectionScreenID][6] then
		stopMovingCam()
	end
end

function stopMovingCam()
	--playSound ( "WindowsMillenniumEdition.mp3")
	removeEventHandler("onClientRender",getRootElement(),Characters_updateSelectionCamera)
	Characters_characterSelectionVisisble()
end

function renderNametags()
	for key, player in ipairs(getElementsByType("ped")) do
		if (isElement(player))then
			if (getElementData(player,"account:charselect:id")) then
				local lx, ly, lz = getElementPosition( getLocalPlayer() )
				local rx, ry, rz = getElementPosition(player)
				local distance = getDistanceBetweenPoints3D(lx, ly, lz, rx, ry, rz)
				if  (isElementOnScreen(player)) then
					local lx, ly, lz = getCameraMatrix()
					local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, rx, ry, rz+1, true, true, true, true, false, false, true, false, nil)
					if not (collision) then
						local x, y, z = getElementPosition(player)
						local sx, sy = getScreenFromWorldPosition(x, y, z+0.45, 100, false)
						if (sx) and (sy) then
							if (distance<=2) then
								sy = math.ceil( sy - ( 2 - distance ) * 40 )
							end
							sy = sy - 20
							if (sx) and (sy) then
								distance = 1.5
								local offset = 75 / distance
								dxDrawText(getElementData(player,"account:charselect:name"), sx-offset+2, sy+2, (sx-offset)+130 / distance, sy+20 / distance, tocolor(0, 0, 0, 220), 0.6 / distance, "bankgothic", "center", "center", false, false, false)
								dxDrawText(getElementData(player,"account:charselect:name"), sx-offset, sy, (sx-offset)+130 / distance, sy+20 / distance, tocolor(255, 255, 255, 220), 0.6 / distance, "bankgothic", "center", "center", false, false, false)
							end
						end
					end
				end
			end
		end
	end
end

function Characters_onClientClick(mouseButton, buttonState, alsoluteX, alsoluteY, worldX, worldY, worldZ, theElement)
	if (theElement) and (buttonState == "down") then
		if (getElementData(theElement,"account:charselect:id")) then
			characterSelected = getElementData(theElement,"account:charselect:id")
			characterElementSelected = theElement

			Characters_updateDetailScreen(theElement)

			local randomAnimation = nil
			for _, thePed in ipairs(pedTable) do
				if isElement(thePed) then
					local deceased = getElementData(thePed,"account:charselect:cked")
					if deceased ~= 1 then
						if thePed == theElement then
							randomAnimation = getRandomAnim( 1 )
						else
							randomAnimation = getRandomAnim( 2 )
						end
					else
						randomAnimation = getRandomAnim( 4 )
					end
					if randomAnimation then
						local anim1, anim2 = getPedAnimation(thePed)
						if randomAnimation[1] ~= anim1 or randomAnimation[2] ~= anim2 then
							setPedAnimation ( thePed , randomAnimation[1], randomAnimation[2], -1, true, false, false, false )
						end
					end
				end
			end
		end
	end
end

--- Character detail screen
local wDetailScreen, lDetailScreen, iCharacterImage, bPlayAs,cFadeOutTime = nil
function Characters_createDetailScreen()
	if wDetailScreen  then
		return true
	end

	local swidth, sheight = guiGetScreenSize()
	local width, height = 300, 250
	wDetailScreen = guiCreateStaticImage(swidth-width, 53*2, width, height, ":resources/window_body.png", false)
	--guiWindowSetSizable(wDetailScreen, false)
	--guiSetProperty(wDetailScreen,"TitlebarEnabled","false")
	local offsetx, offety, offsetyy= 0.05, 0, 1.5
	lDetailScreen = {

		[1] = guiCreateLabel(0.03+offsetx,0.07+offety,0.95,0.0887,"Name: N/A",true,wDetailScreen),
		[2] = guiCreateLabel(0.03+offsetx,0.11*offsetyy+offety,0.96,0.0887,"Gender: N/A",true,wDetailScreen),
		[3] = guiCreateLabel(0.03+offsetx,0.15*offsetyy+offety,0.96,0.0887,"Status: N/A",true,wDetailScreen),
		[4] = guiCreateLabel(0.03+offsetx,0.19*offsetyy+offety,0.96,0.0887,"Age: N/A",true,wDetailScreen),
		[7] = guiCreateLabel(0.03+offsetx,0.19*offsetyy+offety+0.06,0.96,0.0887,"Date of birth: N/A",true,wDetailScreen),
		[5] = guiCreateLabel(0.03+offsetx,0.23*offsetyy+offety+0.06,0.96,0.0887,"Faction: N/A",true,wDetailScreen),
		[6] = guiCreateLabel(0.03+offsetx,0.30*offsetyy+offety+0.07,0.96,0.0887,"Last seen: N/A",true,wDetailScreen),
	}
	bPlayAs = guiCreateButton(0.36, 0.65, 0.6, 0.3, "Play as N/A", true, wDetailScreen)
	addEventHandler("onClientGUIClick", bPlayAs, Characters_selectCharacter, false)

	guiSetEnabled(bPlayAs, true)
	guiSetEnabled(wDetailScreen, true)
	guiSetEnabled( newCharacterButton, true )
	guiSetEnabled( bLogout, true )

	return true
end

function Characters_updateDetailScreen(thePed)
	if Characters_createDetailScreen() then
		if (iCharacterImage ~= nil) then
			destroyElement(iCharacterImage)
		end




		local skin = getElementModel(thePed)
		iCharacterImage = guiCreateStaticImage ( 0.025 , 0.65 , 0.3, 0.3, "img/" .. ("%03d"):format(skin) .. ".png", true, wDetailScreen)

		guiSetText ( lDetailScreen[1], "Name: " .. getElementData(thePed,"account:charselect:name") )
		local characterGender = getElementData(thePed, "account:charselect:gender")
		local characterGenderStr = "Female"
		if (characterGender == 0) then
			characterGenderStr = "Male"
		end
		guiSetText ( lDetailScreen[2], "Gender: " .. characterGenderStr )

		local characterStatus = getElementData(thePed, "account:charselect:cked")
		local characterStatusStr = "Dead"
		if (characterStatus ~= 1) then
			characterStatusStr = "Alive"
		end

		guiSetText ( lDetailScreen[3], "Status: " .. characterStatusStr )
		guiSetText ( lDetailScreen[4], "Age: " .. tostring(getElementData(thePed, "account:charselect:age")) )
		guiSetText ( lDetailScreen[5], "Faction: " .. getElementData(thePed, "account:charselect:factionrank") .. " - " .. getElementData(thePed, "account:charselect:faction") )
		guiSetText ( lDetailScreen[6], "Last seen at " .. getElementData(thePed, "account:charselect:lastarea") )
		guiSetText ( lDetailScreen[7], "Date of birth: "..monthNumberToName(getElementData(thePed, "account:charselect:month")).." "..getBetterDay(getElementData(thePed, "account:charselect:day"))..", "..getBirthday(getElementData(thePed, "account:charselect:age")))

		guiSetText ( bPlayAs, "Play as "..getElementData(thePed,"account:charselect:name") )
		if getElementData(thePed, "account:charselect:cked") == 1 then
			guiSetEnabled(bPlayAs, false)
		else
			guiSetEnabled(bPlayAs, true)
		end
	end
end

function Characters_deactivateGUI()
	if isElement(bPlayAs) then
		guiSetEnabled(bPlayAs, false)
		guiSetEnabled(wDetailScreen, false)
		guiSetEnabled( newCharacterButton, false )
		guiSetEnabled( bLogout, false )

	end
	removeEventHandler("onClientRender", getRootElement(), renderNametags)
	removeEventHandler("onClientClick", getRootElement(), Characters_onClientClick)
end

function Characters_selectCharacter()
	if (characterSelected ~= nil) then
		Characters_deactivateGUI()
		local randomAnimation = getRandomAnim(3)
		setPedAnimation ( characterElementSelected, randomAnimation[1], randomAnimation[2], -1, true, false, false, false )
		guiSetText ( bPlayAs, "Please wait.." )
		cFadeOutTime = 254
		addEventHandler("onClientRender", getRootElement(), Characters_FadeOut)
		fadeCamera ( false, 1, 0,0,0 )
		setTimer(function()
			triggerServerEvent("accounts:characters:spawn", getLocalPlayer(), characterSelected)
		end, 1000,1)

	end
end

function Characters_FadeOut()
	cFadeOutTime = cFadeOutTime -3
	if (cFadeOutTime <= 0) then
		removeEventHandler("onClientRender", getRootElement(), Characters_FadeOut)
	else
		for _, thePed in ipairs(pedTable) do
			if isElement(thePed) and (thePed ~= characterElementSelected) then
				setElementAlpha(thePed, cFadeOutTime)
			end
		end
	end
end

function characters_destroyDetailScreen()
	lDetailScreen = { }
	if isElement(wDetailScreen) then
		destroyElement(iCharacterImage)
		destroyElement(bPlayAs)
		destroyElement(wDetailScreen)
		iCharacterImage = nil
		iPlayAs = nil
		wDetailScreen = nil

	end
	for _, thePed in ipairs(pedTable) do
		if isElement(thePed) then
			destroyElement(thePed)
		end
	end
	pedTable = { }
	cFadeOutTime = 0
	if isElement(newCharacterButton) then
		destroyElement( newCharacterButton )
	end
	if isElement(bLogout) then
		destroyElement( bLogout )
	end
end
--- End character detail screen

function characters_onSpawn(fixedName, adminLevel, gmLevel, factionID, factionRank)
	clearChat()
	showChat(true)
	guiSetInputEnabled(false)
	showCursor(false)
	--outputChatBox("You are now playing as '" .. fixedName .. "'.", 0, 255, 0)
	outputChatBox("Need Help? /helpme", 255, 194, 14)
	outputChatBox("You can visit the Options menu by pressing 'F10' or /home.", 255, 194, 15)
	outputChatBox(" ")
	characters_destroyDetailScreen()
	setElementData(getLocalPlayer(), "admin_level", adminLevel, false)
	setElementData(getLocalPlayer(), "account:gmlevel", gmLevel, false)
	setElementData(getLocalPlayer(), "faction", factionID, false)
	setElementData(getLocalPlayer(), "factionrank", factionrank, false)

	-- Adams
	local dbid = getElementDimension(localPlayer)
	triggerServerEvent("frames:loadInteriorTextures", getLocalPlayer(), dbid)
	options_enable()
	--Stop bgMusic + spawning sound fx / maxime
	local bgMusic = getElementData(localPlayer, "bgMusic")
	if bgMusic and isElement(bgMusic) then
		setTimer(startSoundFadeOut, 2000, 1, bgMusic, 100, 30, 0.04, "bgMusic")
	end
	local selectionSound = getElementData(localPlayer, "selectionSound")
	if selectionSound and isElement(selectionSound) then
		destroyElement(selectionSound)
		bgMusic = nil
	end

	setTimer(function ()
		local spawnCharSound = playSound("spawn_char.mp3")
		setSoundVolume(spawnCharSound, 0.3)
	end, 2000, 1)
	
end
addEventHandler("accounts:characters:spawn", getRootElement(), characters_onSpawn)

function soundFadeOut(sound, decrease, dataKey)
	if sound and isElement(sound) then
		local oldVol = getSoundVolume(sound)
		if oldVol <= 0 then
			if soundFadeTimer and isElement(soundFadeTimer) then
				killTimer(soundFadeTimer)
				soundFadeTimer = nil
			end
			destroyElement(sound)
			if dataKey then
				setElementData(localPlayer, dataKey, false)
			end
		else
			if not decrease then decrease = 0.05 end
			local newVol = oldVol - decrease
			setSoundVolume(sound, newVol)
		end
	end
end
function startSoundFadeOut(sound, timeInterval, timesToExecute, decrease, dataKey)
	if not sound or not isElement(sound) then return false end
	if not tonumber(timeInterval) then timeInterval = 100 end
	if not tonumber(timesToExecute) then timesToExecute = 30 end
	if not tonumber(decrease) then decrease = 0.05 end
	soundFadeTimer = setTimer(soundFadeOut, timeInterval, timesToExecute, sound, decrease, dataKey)
	setTimer(forceStopSound, 4000, 1, sound, dataKey)
end
function forceStopSound(sound, dataKey)
	if sound and isElement(sound) then
		destroyElement(sound)
		if dataKey then
			setElementData(localPlayer, dataKey, false)
		end		
	end
end

function Characters_newCharacter()
	Characters_deactivateGUI()
	characters_destroyDetailScreen()
	newCharacter_init()
end

function playerLogout()
	Characters_deactivateGUI()
	characters_destroyDetailScreen()
	for _, thePed in ipairs(pedTable) do
		destroyElement(thePed, 0)
	end
end
