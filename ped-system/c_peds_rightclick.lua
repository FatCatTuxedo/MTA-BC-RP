wPedRightClick = nil
bTalkToPed, bClosePedMenu = nil
ax, ay = nil
closing = nil
sent=false
localPlayer = getLocalPlayer()

function clickPed(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if not element then
		local camX, camY, camZ = getCameraMatrix()
		local cursorX, cursorY, endX, endY, endZ = getCursorPosition()

		local x = {processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, true, true, true, true, true, false, true, localPlayer, true)}
		local hit, _, _, _, _, _, _, _, mat, _, _, buildingId, bx, by, bz = unpack(x)
		if hit and isElement(buildingId) then
			element = buildingId
			outputDebugString("Used hack to get hidden element")
		end
	end
	if (element) and (getElementType(element)=="ped") and (button=="right") and (state=="down") and (sent==false) and (element~=getLocalPlayer()) then
		rcMenu = false
		row = {}
		local interact = getElementData(element, "rpp.npc.type")
		if (interact and interact ~= "false") then
			local x, y, z = getElementPosition(getLocalPlayer())

			if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
				if (wPedRightClick) then
					hidePedMenu()
				end

				ax = absX
				ay = absY
				player = element
				closing = false

				--CITY HALL: RECEPTION (aka. Jessie Smith)
				if(interact == "ch.reception") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("cityhall:jesped", getLocalPlayer())
					end, true)

				--CITY HALL: JOB PINBOARD
				elseif(interact == "ch.jobboard") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("onEmployment", getLocalPlayer())
					end, true)

				--CITY HALL: LICENSE PLATES REGISTRATION
				elseif(interact == "ch.plates") then --City Hall: License plates registration
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("cBeginPlate", getLocalPlayer(), element)
					end, true)

				--CITY HALL: BUSINESS REGISTRY
				elseif(interact == "ch.bizreg") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("onRegistryPed", getLocalPlayer())
					end, true)

				--CITY HALL: POLITICAL PARTY REGISTRY
				elseif(interact == "ch.politics") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("onPoliticsPed", element)
					end, true)

				--BANK: Banking ped
				elseif(interact == "bank.banking") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent( "bank:showGeneralServiceGUI", getLocalPlayer(), getLocalPlayer())
					end, true)
					
				elseif(interact == "bank.atmcard") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("bank-system:bankerInteraction", getLocalPlayer())
					end, true)

				--FUEL STATION PED
				elseif(interact == "fuel") then --Fuel station ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("fuel:startConvo", element)
					end, true)

				--TOLL BOOTH PED
				elseif(interact == "toll") then --Toll booth ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("toll:startConvo", element)
					end, true)

				--SAN RECEPTION PED
				elseif(interact == "san.reception") then --SAN reception ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("toll:startConvo", element)
					end, true)
					
				elseif(interact == "prison.arrival") then --SAN reception ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("startPrisonGUI", root, localPlayer)
					end, true)


				--MISSION: STEVEN PULLMAN
				elseif(interact == "mission.pullman") then --Mission: Steven Pullman
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent( "startStevieConvo", getLocalPlayer())
						if (getElementData(element, "activeConvo")~=1) then
							triggerEvent ( "stevieIntroEvent", getLocalPlayer()) -- Trigger Client side function to create GUI.
						end
					end, true)
				--MISSION: HUNTER
				elseif(interact == "mission.hunter") then --Mission: Hunter
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent( "startHunterConvo", getLocalPlayer())
					end, true)
				--MISSION: ROOK
				elseif(interact == "mission.rook") then --Mission: Rook
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent( "startRookConvo", getLocalPlayer())
					end, true)


				--DMV: GET DRIVERS LICENSE
				elseif(interact == "dmv.license") then --DMV: Get drivers license
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("onLicense", getLocalPlayer(), getElementData(element, "rpp.npc.name"))
					end, true)

				--DMV: LICENSE PLATES REGISTRATION
				elseif(interact == "dmv.plates") then --City Hall: License plates registration
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("cBeginPlate", getLocalPlayer(), element)
					end, true)
					
				--DMV: GET DRIVERS LICENSE
				elseif(interact == "dmv.lost") then --DMV: Get drivers license
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("showRecoverLicenseWindow", getLocalPlayer())
					end, true)

				--DMV: LICENSE PLATES REGISTRATION
				elseif(interact == "dmv.transfer") then --City Hall: License plates registration
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Buy DMV transaction paper - 100$")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("getPaper", getLocalPlayer(), element)
					end, true)

				--ELECTION PED
				elseif(interact == "election") then --Election ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Vote")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("electionWantVote", getLocalPlayer())
					end, true)

				--IMPOUND LOT PED
				elseif(interact == "impound") then --Impound lot ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("onTowMisterTalk", getLocalPlayer())
					end, true)

				--FAA: Theory Exams
				elseif(interact == "faa.theory") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("onLicense", getLocalPlayer(), element)
					end, true)

				--CITY HALL: GUARD
				elseif(interact == "ch.guard") then --City Hall: guard
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("gateCityHall", getLocalPlayer())
					end, true)

				--GATEANGBASE (AIRMAN CONNOR)
				elseif(interact == "gateangbase") then --gateangbase (Airman Connor)
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("gateAngBase", getLocalPlayer())
					end, true)

				--SFES RECEPTION PED
				elseif(interact == "sfes.reception") then --SFES: reception ped
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("lses:popupPedMenu", getLocalPlayer(), element)
					end, true)

				--Prison arrival
				elseif(interact == "prison.arrival") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("prison:prisonPedArrival", getLocalPlayer(), element)
					end, true)

				--Prison release
				elseif(interact == "prison.release") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("prison:prisonPedRelease", getLocalPlayer(), element)
					end, true)

				--MISSION: CLARICE
				elseif(interact == "mission.clarice") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent( "startClariceConvo", getLocalPlayer())
					end, true)
					row.util = exports.rightclick:addrow("WooHoo_clarice")
					addEventHandler("onClientGUIClick", row.util,  function (button, state)
						local x,y,z = getElementPosition(element)
						local player = getLocalPlayer()
						setElementPosition(player, x, y, z)
						--setElementRotation(player, 266, 0, 0)
						setPedAnimation(element, "SEX", "SEX_1_Cum_W", -1, false, false)
						setPedAnimation(player, "SEX", "SEX_1_Cum_P", -1, false, false)
						setTimer(setPedAnimation, 7000, 1, player)
						setTimer(setPedAnimation, 7200, 1, element, "BEACH", "bather")
					end, true)

				--MISSION: CONSTRUCTION SITE JOB
				elseif(interact == "towing.release") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerServerEvent("onTowMisterTalk", getLocalPlayer())
					end, true)

				--CHRISTMAS: SANTA
				elseif(interact == "santa") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.get = exports.rightclick:addrow("Get Coke")
					addEventHandler("onClientGUIClick", row.get,  function (button, state)
						triggerServerEvent("item-system:santaGetCoke", getLocalPlayer(), element)
					end, true)
					if exports.global:hasItem(getLocalPlayer(), 211) then --has christmas lottery ticket
						row.claim = exports.rightclick:addrow("Claim Prize")
						addEventHandler("onClientGUIClick", row.claim,  function (button, state)
							triggerServerEvent("item-system:useChristmasLotteryTicket", getLocalPlayer(), element)
						end, true)
					end

				--ELECTIONS: Ped for vote GUI (anumaz)
				elseif(interact == "electionsped") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("elections:votegui", getLocalPlayer())
					end, true)

				--SFIA: Pilot mission (anumaz)
				elseif(interact == "pilotmission") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.getlisting = exports.rightclick:addrow("Get listing")
					addEventHandler("onClientGUIClick", row.getlisting, function ()
							triggerEvent("pilotmission:startGUI", getResourceRootElement( getResourceFromName("sfia") ))
						end, false)
					local temp_table = getElementData(getResourceRootElement( getResourceFromName("sfia") ), "sfia_pilots:table")
					local name = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
					for k, v in pairs(temp_table) do
						if v["charactername"] == name then
							row.gettask = exports.rightclick:addrow("Get task")
							addEventHandler("onClientGUIClick", row.gettask, function ()
									triggerEvent("pilotmission:domission", getResourceRootElement( getResourceFromName("sfia") ))
								end, false)
							break
						end
					end
				elseif(interact == "clothing") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						setElementData(getLocalPlayer(), "rpp.npc.talking", element)
						triggerServerEvent('clothing:list', getResourceRootElement (getResourceFromName("astro-clothing")))
					end, true)
				--Locksmith
				elseif(interact == "locksmith") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("locksmithGUI", localPlayer, localPlayer)
					end, true)
				elseif(interact == "astro.guard") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("astroguardGUI", localPlayer, element)
					end, true)
				elseif(interact == "astro.pay") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						triggerEvent("astropayGUI", localPlayer, element)
					end, true)
				elseif(interact == "make.generic") then
					rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
					row.talk = exports.rightclick:addrow("Talk")
					addEventHandler("onClientGUIClick", row.talk,  function (button, state)
						if getElementData(localPlayer, "loggedin") == 1 and tostring(getTeamName(getPlayerTeam(localPlayer))) == "Los Santos Express" then
							triggerEvent("createCargoGUI", localPlayer)
						end
					end, true)

				end


				--STRETCHER SYSTEM
				local stretcherElement = getElementData(getLocalPlayer(), "realism:stretcher:hasStretcher")
				if stretcherElement then
					local stretcherPlayer =  getElementData( stretcherElement, "realism:stretcher:playerOnIt" )
					if stretcherPlayer and stretcherPlayer == player then
						if not rcMenu then
							rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
						end
						--bStabilize = guiCreateButton(0.05, y, 0.87, 0.1, "Take from stretcher", true, wRightClick)
						row.stretcher = exports.rightclick:addrow("Take from stretcher")
						addEventHandler("onClientGUIClick", row.stretcher, function (button, state)
							triggerServerEvent("stretcher:takePedFromStretcher", getLocalPlayer(), element)
						end, false)
					end
					if not stretcherPlayer then
						if not rcMenu then
							rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
						end
						--bStabilize = guiCreateButton(0.05, y, 0.87, 0.1, "Lay on stretcher", true, wRightClick)
						row.stretcher = exports.rightclick:addrow("Lay on stretcher")
						addEventHandler("onClientGUIClick", row.stretcher, function (button, state)
							triggerServerEvent("stretcher:movePedOntoStretcher", getLocalPlayer(), element)
						end, false)
					end
				end


				--HEAL SYSTEM
				if(getElementHealth(element) < 50) then
					outputDebugString("ped low health")
					local factionType = getElementData(getPlayerTeam(getLocalPlayer()), "type")
					if(factionType == 4) then --if player is in ES faction and has a first aid kit
						if not rcMenu then
							rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
						end
						row.heal = exports.rightclick:addrow("Heal")
						addEventHandler("onClientGUIClick", row.heal, function (button, state)
							triggerServerEvent("peds:healPed", getLocalPlayer(), getLocalPlayer(), element)
						end, false)
					end
				end
			end
		else --if not interact

		end

		--ADMIN CMDS
		if (getElementData(element, "rpp.npc.dbid")) then
			if (exports.integration:isPlayerAdmin(localPlayer) and exports.global:isStaffOnDuty(localPlayer)) or exports.integration:isPlayerScripter(localPlayer) then
				--outputDebugString("spawnposdata: "..tostring(getElementData(element, "rpp.npc.spawnpos")))
				--if(getElementData(element, "rpp.npc.spawnpos")) then
					if not rcMenu then
						rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name") or "NPC")
					end
					--if getElementData(element, "dbid") then
						row.admEdit = exports.rightclick:addrow("ADM: Edit")
						addEventHandler("onClientGUIClick", row.admEdit, function (button, state)
							adminEditPedGui(element)
						end, false)
					--end

					row.respawn = exports.rightclick:addrow("ADM: Respawn")
					addEventHandler("onClientGUIClick", row.respawn, function (button, state)
						triggerServerEvent("peds:respawnPed", localPlayer, localPlayer, element)
					end, false)
				--end
			end
		else
			--[[if (exports.integration:isPlayerSeniorAdmin(localPlayer) and exports.global:isStaffOnDuty(localPlayer)) or exports.integration:isPlayerScripter(localPlayer) then
				local name = getElementData(element, "rpp.npc.name")
				if not rcMenu then
					rcMenu = exports.rightclick:create(name or "NPC")
				end
				row.delete = exports.rightclick:addrow("ADM: Temporary delete ped")
				addEventHandler("onClientGUIClick", row.delete, function (button, state)
					triggerServerEvent("peds:deletePed", localPlayer, localPlayer, element)
				end, false)
			end
			--]]
		end

	end
end
addEventHandler("onClientClick", getRootElement(), clickPed, true)

function hidePedMenu()
	if (isElement(bTalkToPed)) then
		destroyElement(bTalkToPed)
	end
	bTalkToPed = nil

	if (isElement(bClosePedMenu)) then
		destroyElement(bClosePedMenu)
	end
	bClosePedMenu = nil

	if (isElement(wPedRightClick)) then
		destroyElement(wPedRightClick)
	end
	wPedRightClick = nil

	rcMenu = nil
	row = nil

	ax = nil
	ay = nil
	sent=false
	--showCursor(false)

end
