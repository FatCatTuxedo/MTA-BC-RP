local localPlayer = getLocalPlayer()
local badges = {}
masks = {}
local font =  "default-bold" 
local newfont = dxCreateFont ( "nametags0.ttf" , 12)
local moneyFont = dxCreateFont ( "old_school_united_stencil.ttf" , 16)
local moneyFloat = {}
local maxIconsPerLine = 6
function moneyUpdateFX(state, amount)
	if amount and tonumber(amount) and tonumber(amount) > 0  then
		if state then
			triggerEvent("shop:playCollectMoneySound", localPlayer)
			moneyFloat["mR"] = 20
			moneyFloat["mG"] = 255
			moneyFloat["mB"] = 20
			moneyFloat["mAlpha"] = 255
			moneyFloat["direction"] = 1
			moneyFloat["moneyYOffset"] = 60
			moneyFloat["text"] = "+$"..exports.global:formatMoney(amount)
		else
			triggerEvent("shop:playPayWageSound", localPlayer)
			moneyFloat["mR"] = 255
			moneyFloat["mG"] = 20
			moneyFloat["mB"] = 20
			moneyFloat["mAlpha"] = 255
			moneyFloat["direction"] = -1
			moneyFloat["moneyYOffset"] = 180
			moneyFloat["text"] = "-$"..exports.global:formatMoney(amount)
		end
		local money = getElementData(localPlayer, "money") or 0
		local bankmoney = getElementData(localPlayer, "bankmoney") or 0
		local info = {{"Personal finance update"},{""}}
		table.insert(info, {"   - Money: $"..exports.global:formatMoney(money).." ("..moneyFloat["text"]..")"})
		table.insert(info, {"   - Bank money: $"..exports.global:formatMoney(bankmoney)})
		triggerEvent("hudOverlay:drawOverlayTopRight", localPlayer, info ) 
	end
end
addEvent("moneyUpdateFX", true)
addEventHandler("moneyUpdateFX", root, moneyUpdateFX)

function startRes()
	for key, value in ipairs(getElementsByType("player")) do
		setPlayerNametagShowing(value, false)
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), startRes)

function initStuff(res)
	if (res == getThisResource() and getResourceFromName("item-system")) or getResourceName(res) == "item-system" then
		for key, value in pairs(exports['item-system']:getBadges()) do
			badges[value[1]] = { value[4][1], value[4][2], value[4][3], value[5] }
		end
		
		masks = exports['item-system']:getMasks()
	end
end
addEventHandler("onClientResourceStart", getRootElement(), initStuff)

local playerhp = { }
local lasthp = { }

local playerarmor = { }
local lastarmor = { }

function playerQuit()
	if (getElementType(source)=="player") then
		playerhp[source] = nil
		lasthp[source] = nil
		playerarmor[source] = nil
		lastarmor[source] = nil
	end
end
addEventHandler("onClientElementStreamOut", getRootElement(), playerQuit)
addEventHandler("onClientPlayerQuit", getRootElement(), playerQuit)


function setNametagOnJoin()
	setPlayerNametagShowing(source, false)
end
addEventHandler("onClientPlayerJoin", getRootElement(), setNametagOnJoin)

function streamIn()
	if (getElementType(source)=="player") then
		playerhp[source] = getElementHealth(source)
		lasthp[source] = playerhp[source]
		
		playerarmor[source] = getPedArmor(source)
		lastarmor[source] = playerarmor[source]
	end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamIn)

function isPlayerMoving(player)
	return (not isPedInVehicle(player) and (getPedControlState(player, "forwards") or getPedControlState(player, "backwards") or getPedControlState(player, "left") or getPedControlState(player, "right") or getPedControlState(player, "accelerate") or getPedControlState(player, "brake_reverse") or getPedControlState(player, "enter_exit") or getPedControlState(player, "enter_passenger")))
end

local lastrot = nil

function aimsSniper()
	return getPedControlState(localPlayer, "aim_weapon") and getPedWeapon(localPlayer) == 34
end

function aimsAt(player)
	return getPedTarget(localPlayer) == player and aimsSniper()
end

function getBadgeColor(player)
	-- if (getElementType(player) == "ped") then
		-- if (getElementData(player, "rpp.npc.type") == "astro.pay") then
			-- return 223,215,27
		-- end
	-- else
		for k, v in pairs(badges) do
			if getElementData(player, k) then
				return unpack(badges[k])
			end
		end
	--end
end

function getPlayerIcons(name, player, forTopHUD, distance)
	distance = distance or 0
	local tinted, masked = false, false
	local icons = {}

	if not forTopHUD then
		--ADMIN / GM TAGS
		if getElementData(player,"hiddenadmin") ~= 1 then
			if exports.integration:isPlayerDev(player) then
				if exports.integration:isPlayerDev(player) and getElementData(player,"duty_dev") == 1 then
					table.insert(icons, "scripter")
				else
					if getElementData(player,"admin_level") > 4 and exports.integration:isPlayerLeadAdmin(player) and getElementData(player,"duty_admin") == 1 then
						table.insert(icons, "sm")
					elseif exports.integration:isPlayerTrialAdmin(player) and getElementData(player,"duty_admin") == 1 then
						if getElementData(player,"admin_level") > 0 then
							table.insert(icons, "adm_on")
						end
					end
				end
			else
				if getElementData(player,"admin_level") > 4 and exports.integration:isPlayerLeadAdmin(player) and getElementData(player,"duty_admin") == 1 then
						table.insert(icons, "sm")
				elseif exports.integration:isPlayerTrialAdmin(player) and getElementData(player,"duty_admin") == 1 then
					if getElementData(player,"admin_level") > 0 then
						table.insert(icons, "adm_on")
					end
				end
			end
							if exports.integration:isPlayerSupporter(player) and getElementData(player,"duty_supporter") == 1 then

					table.insert(icons, "gm")
				end
			end

		-- DONATOR NAMETAGS
		if getElementData(player, "donation:nametag") and getElementData(player, "nametag_on") then
			table.insert(icons, 'donor')
		elseif getElementData(player, "donation:lifeTimeNameTag") and getElementData(player, "lifeTimeNameTag_on") then
			table.insert(icons, 'donor')
		end
		if getElementModel(player) == 75 then
			table.insert(icons, 'k9')
		end
		if getPedArmor(player) > 0 then
			table.insert(icons, 'armour')
		end
	end


	for key, value in pairs(masks) do
		if getElementData(player, value[1]) and value[1] ~= "vest" then
			table.insert(icons, value[1])
			if value[4] then
				masked = true
			end
		end
	end

	local vehicle = getPedOccupiedVehicle(player)
	local windowsDown = vehicle and getElementData(vehicle, "vehicle:windowstat") == 1

	if vehicle and not windowsDown and vehicle ~= getPedOccupiedVehicle(localPlayer) and getElementData(vehicle, "tinted") then
		local seat0 = getVehicleOccupant(vehicle, 0) == player
		local seat1 = getVehicleOccupant(vehicle, 1) == player
		--outputDebugString(toJSON(seat0, seat1))
		if seat0 or seat1 then
			if distance > 1.4 then
				if (getElementModel(player) == 75) then
					name = "Unknown Animal (Tint)"
				else
					name = "Unknown Person (Tint)"
				end
				tinted = true
			end
		else
			if (getElementModel(player) == 75) then
				name = "Unknown Animal (Tint)"
			else
				name = "Unknown Person (Tint)"
			end
			tinted = true
		end
	end

	if not tinted then
		-- pretty damn hard to see thru tint
		if getElementData(player,"seatbelt") and getPedOccupiedVehicle(player) then
			table.insert(icons, 'seatbelt')
		end


		if getElementData(player,"smoking") == true then
			table.insert(icons, 'cigarette')
		end

		if masked then
			name = "Unknown Person"
		end
		for k, v in pairs(badges) do
			local title = getElementData(player, k)
			if title then
				if v[4] == 222 then
					table.insert(icons, 'mask')
					name = "Unknown Person (KKK Hood)"
					badge = true
				elseif v[4] == 122 or v[4] == 123 or v[4] == 124 or v[4] == 125 or v[4] == 135 or v[4] == 136 or v[4] == 158 or v[4] == 168 then
					table.insert(icons, 'bandana')
					name = "Unknown Person (Bandana)"
					badge = true
				else
					table.insert(icons, "badge" .. tostring(v[4] or 1))
					name = title .. "\n" .. name
					badge = true
				end
			end
		end

		if tonumber(getElementData(player, 'cellphoneGUIStateSynced') or 0) > 0 then
			table.insert(icons, 'phone')
		end
	end

	if not tinted then
		if not forTopHUD then
			local health = getElementHealth( player )
			local tick = math.floor(getTickCount () / 1000) % 2
			if health <= 10 and tick == 0 then
				table.insert(icons, 'bleeding')
			elseif (health <= 30) then
				table.insert(icons, 'lowhp')
			end

			if getElementData(player, "restrain") == 1 then
				table.insert(icons, "handcuffs")
			end
		end
	end
		
	if not forTopHUD then
		if windowsDown then
			table.insert(icons, 'window2')
		end
	end

	return name, icons, tinted
end

function renderNametags()
	if (getElementData(localPlayer, "graphic_nametags") ~= "0") and not isPlayerMapVisible() and isActive() then
		local players = { }
		local distances = { }
		--local lx, ly, lz = getCameraMatrix()
		local lx, ly, lz = getElementPosition(localPlayer)
		local dim = getElementDimension(localPlayer)
		local isNewtyle = (getElementData(localPlayer, "settings_hud_style") ~= "0") 
		if isNewtyle then
			font = newfont
		else
			font = "default-bold"
		end
		
		for key, player in ipairs(getElementsByType("player")) do
			if (isElement(player)) and getElementDimension(player) == dim then
				local logged = getElementData(player, "account:loggedin")
				
				if (logged == true) then
					
					local rx, ry, rz = getElementPosition(player)
					local distance = getDistanceBetweenPoints3D(lx, ly, lz, rx, ry, rz)
					local limitdistance = 20
					local reconx = getElementData(localPlayer, "reconx") and exports.integration:isPlayerTrialAdmin(localPlayer)
					
					if isElementOnScreen(player) and (player~=localPlayer or isNewtyle) then
						if (aimsAt(player) or distance<limitdistance or reconx) then
							if not getElementData(player, "reconx") and not getElementData(player, "freecam:state") and not (getElementAlpha(player) < 255) then
								--local lx, ly, lz = getPedBonePosition(localPlayer, 7)
								local lx, ly, lz = getCameraMatrix()
								local vehicle = getPedOccupiedVehicle(player) or nil
								local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, rx, ry, rz+1, true, true, true, true, false, false, true, false, vehicle)

								if not (collision) or aimsSniper() or (reconx) then
									local x, y, z = getElementPosition(player)
									
									if not (isPedDucked(player)) then
										z = z + 1
									else
										z = z + 0.5
									end
									
									if (getElementModel(player) == 75) then
										z = z - 0.6
									end
									
									local sx, sy = getScreenFromWorldPosition(x, y, z+0.30, 100, false)
									local oldsy = nil
									local badge = false
									local tinted = false
									-- HP
									
									local name = getElementData(player, "fakename") or getPlayerName(player):gsub("_", " ")

									if (sx) and (sy) then
										distance = distance / 5
										
										if (reconx or aimsAt(player)) then distance = 1
										elseif (distance<1) then distance = 1
										elseif (distance>2) then distance = 2 end
										
										--DRAW BG
										--dxDrawRectangle(sx-offset-5, sy, 95 / distance, 20 / distance, tocolor(0, 0, 0, 100), false)
										oldsy = sy

										local picxsize = 64 / 1 --/distance
										local picysize = 64 / 1 --/distance
										local xpos, ypos = 0, 45

										name, icons, tinted = getPlayerIcons(name, player, false, distance)
										local expectedIcons = math.min(#icons, maxIconsPerLine)
										local iconsThisLine = 0
										local offset = 16 * expectedIcons
										for k, v in ipairs(icons) do
											dxDrawImage(sx-offset+xpos,oldsy+ypos,picxsize,picysize,"images/hud/" .. v .. ".png")

											iconsThisLine = iconsThisLine + 1
											if iconsThisLine == expectedIcons then
												expectedIcons = math.min(#icons - k, maxIconsPerLine)
												offset = 16 * expectedIcons
												iconsThisLine = 0
												xpos = 0
												ypos = ypos + 32
											else
												xpos = xpos + 32
											end
										end
										



										if (distance<=2) then
											sy = math.ceil( sy + ( 2 - distance ) * 20 )
										end
										sy = sy + 10
										
										
										if (sx) and (sy) then

											
											if (6>5) then
												local offset = 45 / distance
											end
										end
																			
										if (distance<=2) then
											sy = math.ceil( sy - ( 2 - distance ) * 40 )
										end
										sy = sy - 20
											
										if (sx) and (sy) and oldsy then
											if (distance < 1) then distance = 1 end
											if (distance > 2) then distance = 2 end
											local offset = 75 / distance
											local scale = 1 --/ distance
											local r, g, b = getBadgeColor(player)
											if not r or tinted then
												r, g, b = getPlayerNametagColor(player)
											end
											local id = getElementData(player, "playerid")
											
											if badge then
												sy = sy - dxGetFontHeight(scale, font) * scale + 2.5
											end
											
											if not isNewtyle then
												name = name.." ("..id..")"
											else
												if getKeyState("lctrl") or getKeyState("rctrl") then
													name = id
												end
											end
																			
											dxDrawText(name, sx-offset+2, sy+2, (sx-offset)+130 / distance, sy+120 / distance, tocolor(0, 0, 0, 255), scale, font, "center", "center", false, false, false, false, false)
											dxDrawText(name, sx-offset, sy, (sx-offset)+130 / distance, sy+120 / distance, tocolor(r, g, b, 255), scale, font, "center", "center", false, false, false, false, false)
											
											
											if moneyFloat and moneyFloat["mAlpha"] and moneyFloat["mAlpha"] > 1 and player == localPlayer then
												if moneyFloat["mAlpha"] > 0 then
													dxDrawText(moneyFloat["text"], sx-offset, sy+moneyFloat["moneyYOffset"], (sx-offset)+130 / distance, sy+120 / distance, tocolor(moneyFloat["mR"], moneyFloat["mG"], moneyFloat["mB"], moneyFloat["mAlpha"]), scale, moneyFont, "center", "center", false, false, false, false, false)
													moneyFloat["moneyYOffset"] = moneyFloat["moneyYOffset"] + moneyFloat["direction"]
													moneyFloat["mAlpha"] = moneyFloat["mAlpha"] - 2
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		for key, player in ipairs(getElementsByType("ped")) do
			if (isElement(player) and  (player~=localPlayer) and (isElementOnScreen(player)))then
				
				if (getElementData(player,"talk") == 1) or (getElementData(player, "nametag")) then
					local lx, ly, lz = getElementPosition(localPlayer)
					local rx, ry, rz = getElementPosition(player)
					local distance = getDistanceBetweenPoints3D(lx, ly, lz, rx, ry, rz)
					local limitdistance = 8
					local reconx = getElementData(localPlayer, "reconx")
					
					-- smoothing
					playerhp[player] = getElementHealth(player)
					
					if (lasthp[player] == nil) then
						lasthp[player] = playerhp[player]
					end
					
					playerarmor[player] = getPedArmor(player)
					
					if (lastarmor[player] == nil) then
						lastarmor[player] = playerarmor[player]
					end
				
					if (aimsAt(player) or distance<limitdistance or reconx) then
						if not getElementData(player, "reconx") and not getElementData(player, "freecam:state") then
							local lx, ly, lz = getCameraMatrix()
							local vehicle = getPedOccupiedVehicle(player) or nil
							local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, rx, ry, rz+1, true, true, true, true, false, false, true, false, vehicle)
								if not (collision) or aimsSniper() or (reconx) then
								local x, y, z = getElementPosition(player)
								
								if not (isPedDucked(player)) then
									z = z + 1
								else
									z = z + 0.5
								end
								if (getElementModel(player) == 75) then
									z = z - 0.6
								end
								local sx, sy = getScreenFromWorldPosition(x, y, z+0.1, 100, false)
								local oldsy = nil
								-- HP
								if (sx) and (sy) then
																		
									if (1>0) then
										distance = distance / 5
										
										if (reconx or aimsAt(player)) then distance = 1
										elseif (distance<1) then distance = 1
										elseif (distance>2) then distance = 2 end
										
										local offset = 45 / distance

										oldsy = sy 
									end
								end
								

								if (sx) and (sy) then
									if (distance<=2) then
										sy = math.ceil( sy + ( 2 - distance ) * 20 )
									end
									sy = sy + 10
									
									
									if (sx) and (sy) then
										
										if (4>5) then
											local offset = 45 / distance
											
											-- DRAW BG
											dxDrawRectangle(sx-offset-5, sy, 95 / distance, 20 / distance, tocolor(0, 0, 0, 100), false)
											
											-- DRAW HEALTH
											local width = 85
											local armorsize = (width / 100) * armor
											local barsize = (width / 100) * (100-armor)
											
											
											if (distance<1.2) then
												dxDrawRectangle(sx-offset, sy+5, armorsize/distance, 10 / distance, tocolor(197, 197, 197, 130), false)
												dxDrawRectangle((sx-offset)+(armorsize/distance), sy+5, barsize/distance, 10 / distance, tocolor(162, 162, 162, 100), false)
											else
												dxDrawRectangle(sx-offset, sy+5, armorsize/distance-5, 10 / distance-3, tocolor(197, 197, 197, 130), false)
												dxDrawRectangle((sx-offset)+(armorsize/distance-5), sy+5, barsize/distance-2, 10 / distance-3, tocolor(162, 162, 162, 100), false)
											end
										end
									end
									
									if (distance<=2) then
										sy = math.ceil( sy - ( 2 - distance ) * 40 )
									end
									sy = sy - 20
										
									if (sx) and (sy) then
										if (distance < 1) then distance = 1 end
										if (distance > 2) then distance = 2 end
										local offset = 75 / distance
										local scale = 1
										local r,g,b
										r, g, b = getBadgeColor(player)
										if not r or tinted then
											r = 255
											g = 255
											b = 255--getPlayerNametagColor(player)
										end
										local pedName = getElementData(player,"name") and tostring(getElementData(player,"name")):gsub("_", " ") or "The Storekeeper"
										dxDrawText(pedName, sx-offset+2, sy+2, (sx-offset)+130 / distance, sy+20 / distance, tocolor(0, 0, 0, 255), scale, font, "center", "center", false, false, false)
										dxDrawText(pedName, sx-offset, sy, (sx-offset)+130 / distance, sy+20 / distance, tocolor(r, g, b, 255), scale, font, "center", "center", false, false, false)
										local offset = 65 / distance
										--- DRAW ids
										sy = sy - 20
										scale = 0.75
										dxDrawText("NPC", sx-offset+2, sy+2, (sx-offset)+110 / distance, sy+20 / distance, tocolor(0, 0, 0, 255), scale, font, "center", "center", false, false, false)
										dxDrawText("NPC", sx-offset, sy, (sx-offset)+110 / distance, sy+20 / distance, tocolor(255,0,0, 255), scale, font, "center", "center", false, false, false)	
										
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", getRootElement(), renderNametags)

										-- DRAW BG
											--[[sxs, sys = getScreenFromWorldPosition(x, y, z, 100, false)
											dxDrawRectangle(sxs+15, sys+67, 95, 20, tocolor(0, 0, 0, 100), false)
											local health = getElementHealth(player)
											-- DRAW HEALTH
											local width = 85
											local healthsize = (width / 100) * health
											local barsize = (width / 100) * (100-health)
											local rh, gh, bh = 0, 0, 0
											if tonumber(health) <= 30 then
												rh, gh, bh = 255, 0, 0
											else
												rh, gh, bh = 0, 255, 0
											end
											dxDrawRectangle(sxs+20, sys+72, healthsize, 10, tocolor(rh, gh, bh, 255), false)]]
--[[

function bindLeftControl()
	bindKey ( "lctrl", "down", toggleOnID )
	bindKey ( "lctrl", "up", toggleOffID )
end
addEventHandler ( "onClientResourceStart", resourceRoot, bindLeftControl )

function toggleOnID()
	showIDInstead = true
end

function toggleOffID()
	showIDInstead = false
end

]]