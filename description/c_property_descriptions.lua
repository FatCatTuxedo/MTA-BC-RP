--MAXIME
local properties = { }
local localPlayer = getLocalPlayer()
local viewDistance = 30
local heightOffset = 3
local refreshingInterval = 2
local showing = false
local timerRefresh = nil

local BizNoteFont18 = "default-bold"

fontType = {-- (1)font (2)scale offset
	["default"] = {"default", 1},
	["default-bold"] = {"default-bold",1},
	["clear"] = {"clear",1.1},
	["arial"] = {"arial",1},
	["sans"] = {"sans",1.2},
	["pricedown"] = {"pricedown",3},
	["bankgothic"] = {"bankgothic",4},
	["diploma"] = {"diploma",2},
	["beckett"] = {"beckett",2},
	["BizNoteFont18"] = {"default-bold",1},
}

function getOverLayFonts()
	return fontType
end

function bindProD()
	--bindKey ( "lalt", "down", showNearbyProD )
	--bindKey ( "lalt", "up", removeProD )
	bindKey ( "ralt", "down", togglePin )
	addEventHandler("onClientRender", getRootElement(), showTextProD)
end
addEventHandler ( "onClientResourceStart", resourceRoot, bindProD )

function removeProD ( key, keyState )
	--[[local enableOverlayDescription = getElementData(localPlayer, "enableOverlayDescription")
	local enableOverlayDescriptionPro = getElementData(localPlayer, "enableOverlayDescriptionPro")
	if enableOverlayDescription ~= "0" and enableOverlayDescriptionPro ~= "0" then]]
		local enableOverlayDescriptionProPin = getElementData(localPlayer, "enableOverlayDescriptionProPin")
		if enableOverlayDescriptionProPin == "1" then
			return false
		end
		if showing then
			--removeEventHandler ( "onClientRender", getRootElement(), showTextProD )
			showing = false
		end
	--end
end

function getNearByInteriors()
	local posX, posY, posZ = getElementPosition(localPlayer)
	local dimension = getElementDimension(localPlayer)
	local int1 = getElementInterior(localPlayer)
	local possibleInteriors = getElementsByType("interior")
	local result = {}
	local count = 0
	for _, interior in ipairs(possibleInteriors) do
		if getElementData(interior, "status")[2] ~= 1 then --If not disabled.
			local entrance = getElementData(interior, "entrance")
			local x, y, z, int, dim = entrance[1], entrance[2], entrance[3], entrance[4], entrance[5]
			if (dim == dimension) and (int == int1) then
				if (getDistanceBetweenPoints3D(posX, posY, posZ, x, y , z) <= viewDistance) then
					table.insert(result, interior)
					count = count + 1
				end
			end
		end
	end
	
	if count > 0 then
		return result
	else
		return false
	end
end

function showNearbyProD()
	local enableOverlayDescription = getElementData(localPlayer, "enableOverlayDescription")
	local enableOverlayDescriptionPro = getElementData(localPlayer, "enableOverlayDescriptionPro")
	if enableOverlayDescription ~= "0" and enableOverlayDescriptionPro ~= "0" then
		local enableOverlayDescriptionProPin = getElementData(localPlayer, "enableOverlayDescriptionProPin")
		if enableOverlayDescriptionProPin == "1" then
			if showing then
				--removeEventHandler ( "onClientRender", getRootElement(), showTextProD )
				showing = false
			end
		end
		
		if not showing then
			local nearByInteriors = getNearByInteriors()
			if nearByInteriors then
				for index, nearbyPro in ipairs( nearByInteriors ) do
					if isElement(nearbyPro) then
						properties[index] = nearbyPro
					end
				end
				--addEventHandler("onClientRender", getRootElement(), showTextProD)
			end
			showing = true
		end
	end
end

function togglePin()
	local enableOverlayDescription = getElementData(localPlayer, "enableOverlayDescription")
	local enableOverlayDescriptionPro = getElementData(localPlayer, "enableOverlayDescriptionPro")
	if enableOverlayDescription ~= "0" and enableOverlayDescriptionPro ~= "0" then
		local enableOverlayDescriptionProPin = getElementData(localPlayer, "enableOverlayDescriptionProPin")
		if enableOverlayDescriptionProPin == "1" then
			setElementData(localPlayer, "enableOverlayDescriptionProPin", "0")
			--exports.hud:sendBottomNotification(localPlayer, "Property Description", "You have removed Vehicle, Property & Player Overlay Description from your screen.")
			--exports.account:appendSavedData("enableOverlayDescriptionProPin", "0")
			if isTimer(timerRefresh) then
				killTimer(timerRefresh)
				timerRefresh = nil
			end
			if showing then
				--removeEventHandler ( "onClientRender", getRootElement(), showTextProD )
				showing = false
			end
		else
			setElementData(localPlayer, "enableOverlayDescriptionProPin", "1")
			--exports.hud:sendBottomNotification(localPlayer, "Property Description", "You stuck Vehicle, Property & Player Overlay Description onto your screen. Hit 'F10' for advance settings.")
			--exports.account:appendSavedData("enableOverlayDescriptionProPin", "1")
			
			timerRefresh = setTimer(refreshNearByPros, 1000*refreshingInterval, 0)
			
			if not showing then
				local nearByInteriors = getNearByInteriors()
				if nearByInteriors then
					for index, nearbyPro in ipairs( nearByInteriors ) do
						if isElement(nearbyPro) then
							properties[index] = nearbyPro
						end
					end
					--addEventHandler("onClientRender", getRootElement(), showTextProD)
				end
				showing = true
			end
		end
	end
end

function showTextProD()
	if not showing then
		if getKeyState('lalt') then
			showNearbyProD()
		end
		return false
	end
	if not getKeyState('lalt') and getElementData(localPlayer, "enableOverlayDescriptionProPin") ~= "1" then
		removeProD()
		return
	end
	for i = 1, #properties, 1 do
		local theProperty = properties[i]
		if isElement(theProperty) then
			local entrance = getElementData(theProperty, "entrance")	
			local x, y, z, int, dim = entrance[1], entrance[2], entrance[3], entrance[4], entrance[5]
			local cx,cy,cz = getCameraMatrix()
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= viewDistance then --Within radius viewDistance
				local px,py,pz = getScreenFromWorldPosition(x,y,z+heightOffset,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
					local fontString = getElementData(localPlayer, "cFontPro") or "BizNoteFont18"
					local fontElement = fontString
					if fontElement == "BizNoteFont18" then
						BizNoteFont18 = "default-bold"
						fontElement = BizNoteFont18
					end
					local toBeShowed = ""
					local fontWidth = 90
					local toBeAdded = ""
					
					local lines = 0
					local pstatus = getElementData(theProperty, "status")
					local ptype = pstatus[1]
					local pdisabled = pstatus[2]
					local plocked = pstatus[3]
					local powner = pstatus[4]
					local pfaction = pstatus[7]
					local pcost = pstatus[5]
					local pname = getElementData(theProperty, "name")
					
					toBeAdded = pname
					toBeShowed = toBeShowed..pname.."\n"
					local len = dxGetTextWidth(toBeAdded)
					if len > fontWidth then
						fontWidth = len
					end
					lines = lines + 1
					
					if powner < 1 and pfaction < 1 and ptype ~= 2 then -- IF FOR SALE
						if ptype == 3 then -- RENTABLE
							toBeAdded = "For lease: $"..exports.global:formatMoney(pcost).."\n"
							toBeShowed = toBeShowed..toBeAdded
							local len = dxGetTextWidth(toBeAdded)
							if len > fontWidth then
								fontWidth = len
							end
							lines = lines + 1
						else
							toBeAdded = "For sale: $"..exports.global:formatMoney(pcost).."\n"
							toBeShowed = toBeShowed..toBeAdded
							local len = dxGetTextWidth(toBeAdded)
							if len > fontWidth then
								fontWidth = len
							end
							lines = lines + 1
						end
					else
						if ptype == 1 then -- BUSINESS
							toBeAdded = getElementData(theProperty, "business:note")
							if toBeAdded and toBeAdded ~= "" then
								toBeShowed = toBeShowed..toBeAdded.."\n"
								local len = dxGetTextWidth(toBeAdded)
								if len > fontWidth then
									fontWidth = len
								end
								lines = lines + 1
							end
						end
						
						if (exports.integration:isPlayerTrialAdmin(localPlayer) and (getElementData(localPlayer, "duty_admin") == 1)) or (exports.integration:isPlayerScripter(localPlayer) and (getElementData(localPlayer, "duty_script") == 1)) then
							local ownerName = 'No-one'
							if powner > 0 then
								ownerName = exports.cache:getCharacterNameFromID(powner)
							elseif pfaction > 0 then
								ownerName = exports.cache:getFactionNameFromId(pfaction)
							end
							toBeAdded = "Owner: "..(ownerName or "Loading..").."\n"
							toBeShowed = toBeShowed..toBeAdded
							local len = dxGetTextWidth(toBeAdded)
							if len > fontWidth then
								fontWidth = len
							end
							lines = lines + 1
						end
					end

					--Determine the text color / MAXIME
					local textColor = tocolor(255,255,255,255)
					local protectedText, inactiveText = nil
					if powner > 0 then --and (exports['interior-system']:canPlayerKnowInteriorOwner(theProperty) or exports['interior-system']:canPlayerSeeInteriorID(theProperty)) then
						local protected, details = exports['interior-system']:isProtected(theProperty) 
			            if protected then
			                textColor = tocolor(0, 255, 0,255)
			                protectedText = "[Inactivity protection remaining: "..details.."]"
			                toBeAdded = protectedText.."\n"
							toBeShowed = toBeShowed..toBeAdded
							local len = dxGetTextWidth(toBeAdded)
							if len > fontWidth then
								fontWidth = len
							end
							lines = lines + 1
			            else
			                local active, details2, secs = exports['interior-system']:isActive(theProperty)
			                if active and (powner == getElementData(localPlayer, "dbid") or exports.integration:isPlayerStaff(localPlayer)) then
			                    --textColor = tocolor(150,150,150,255)
			                    inactiveText = "[Active | "
			                    local owner_last_login = getElementData(theProperty, "owner_last_login")
								if owner_last_login and tonumber(owner_last_login) then
									local owner_last_login_text, owner_last_login_sec = exports.datetime:formatTimeInterval(owner_last_login)
									inactiveText = inactiveText.." Owner last seen "..owner_last_login_text.." "
								else
									inactiveText = inactiveText.." Owner last seen is irrelevant | "
								end
			                    local lastused = getElementData(theProperty, "lastused")
								if lastused and tonumber(lastused) then
									local lastusedText, lastusedSeconds = exports.datetime:formatTimeInterval(lastused)
									inactiveText = inactiveText.."Last used "..lastusedText.."]"
								else
									inactiveText = inactiveText.."Last used is irrelevant]"
								end
				                toBeAdded = inactiveText.."\n"
								toBeShowed = toBeShowed..toBeAdded
								local len = dxGetTextWidth(toBeAdded)
								if len > fontWidth then
									fontWidth = len
								end
								lines = lines + 1
							elseif not active then
								textColor = tocolor(150,150,150,255)
			                    inactiveText = "["..details2.."]"
				                toBeAdded = inactiveText.."\n"
								toBeShowed = toBeShowed..toBeAdded
								local len = dxGetTextWidth(toBeAdded)
								if len > fontWidth then
									fontWidth = len
								end
								lines = lines + 1
			                end
			            end
				    end

				    if exports['interior-system']:canPlayerSeeInteriorID(theProperty) then
						toBeAdded = "(( ID: "..getElementData(theProperty,"dbid").." ))\n"
						toBeShowed = toBeShowed..toBeAdded
						local len = dxGetTextWidth(toBeAdded)
						if len > fontWidth then
							fontWidth = len
						end
						lines = lines + 1
				    end
					
					
					--START DRAWING
					local marg = 5
					local oneLineHeight = dxGetFontHeight(1, fontElement)
					local fontHeight = oneLineHeight * lines
					fontWidth = fontWidth*fontType[fontString][2] --Fix custom fonts
					px = px-(fontWidth/2)
					if getElementData(localPlayer, "bgPro") ~= "0" then
						dxDrawImage(px-marg, py-marg, fontWidth+(marg*2), fontHeight+(marg*2), ":hud/images/hud/box5.png")
					end
					dxDrawText(toBeShowed, px, py, px + fontWidth, (py + fontHeight), textColor, 1, fontElement, "center")
				end
			end
		end
	end
end

--MAXIME
function dxDrawRectangleBorder(x, y, width, height, borderWidth, color, out, postGUI)
	if out then
		--[[Left]]	dxDrawRectangle(x - borderWidth, y, borderWidth, height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width, y, borderWidth, height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x - borderWidth, y - borderWidth, width + (borderWidth * 2), borderWidth, color, postGUI)
		--[[Botm]]	dxDrawRectangle(x - borderWidth, y + height, width + (borderWidth * 2), borderWidth, color, postGUI)
	else
		local halfW = width / 2
		local halfH = height / 2
		--[[Left]]	dxDrawRectangle(x, y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width - math.clip(0, borderWidth, halfW), y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y, width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
		--[[Botm]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y + height - math.clip(0, borderWidth, halfH), width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
	end
end

function refreshNearByPros()
	local nearByInteriors = getNearByInteriors()
	if nearByInteriors then
		for index, nearbyPro in ipairs( nearByInteriors ) do
			if isElement(nearbyPro) then
				properties[index] = nearbyPro
			end
		end
		removeEventHandler ( "onClientRender", getRootElement(), showTextProD )
		addEventHandler("onClientRender", getRootElement(), showTextProD)
	end
end

--OK I LEAVE YOUR OLD SCRIPT HERE IN CASE YOU WILL EVER WANT IT LATER, BTW NEXT TIME ADD SOME <tab> TO YOUR IF-ELSE PLEASE :< - MAXIME
--[[function showTextProD()
	for i = 1, #properties, 1 do
		if isElement(properties[i]) then
		if getElementModel(properties[i]) == 481 or getElementModel(properties[i]) == 509 or getElementModel(properties[i]) == 510 then
		local descriptions = {}
		for j = 1, 5 do
			descriptions[j] = getElementData(properties[i], "description:"..j)
		end
		local x,y,z = getElementPosition(properties[i])			
        local cx,cy,cz = getCameraMatrix()
		if descriptions[1] and descriptions[2] and descriptions[3] and descriptions[4] and descriptions[5] then
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= 40 then
				local px,py,pz = getScreenFromWorldPosition(x,y,z+1,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then
					dxDrawText(descriptions[1].."\n"..descriptions[2].."\n"..descriptions[3].."\n"..descriptions[4].."\n"..descriptions[5], px, py, px, py, tocolor(0, 255, 0, 255), 1, "default-bold", "center", "center", false, false)
				end
			end
		end
		elseif isElement(properties[i]) then
		local plate
		local vin = getElementData(properties[i], "dbid")
		if vin < 0 then
			plate = getVehiclePlateText(properties[i])
		else
			plate = getElementData(properties[i], "plate")
		end
		local descriptions = {}
		for j = 1, 5 do
			descriptions[j] = getElementData(properties[i], "description:"..j)
		end
		local x,y,z = getElementPosition(properties[i])			
        local cx,cy,cz = getCameraMatrix()
		if descriptions[1] and descriptions[2] and descriptions[3] and descriptions[4] and descriptions[5] then
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= 40 then
				local px,py,pz = getScreenFromWorldPosition(x,y,z+1,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then
					dxDrawText("(PLATE: "..plate..")\n(VIN: "..vin..")\n"..descriptions[1].."\n"..descriptions[2].."\n"..descriptions[3].."\n"..descriptions[4].."\n"..descriptions[5], px, py, px, py, tocolor(0, 255, 0, 255), 1, "default-bold", "center", "center", false, false)
				end
			end
		else
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= 40 then
				local px,py,pz = getScreenFromWorldPosition(x,y,z+1,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then
					dxDrawText("(PLATE: "..plate..")\n(VIN: "..vin..")\n", px, py, px, py, tocolor(0, 255, 0, 255), 1, "default-bold", "center", "center", false, false)
				end
			end
		end
		end
		end
	end
end
]]