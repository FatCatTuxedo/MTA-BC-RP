local debugModelOutput = false
local showering = {}

rightclick = exports.rightclick
global = exports.global
integration = exports.integration
itemworld = exports['item-world']
item = exports['item-system']
localPlayer = getLocalPlayer()

local noMenuFor = {
	[0] = true, --nothing
}
local noPickupFor = {
	[81] = true, --fridge
	[103] = true, --shelf
}
local noPropertiesFor = {
	
}

function clickObject(button, state, absX, absY, wx, wy, wz, element)
	rightclick = exports.rightclick
	global = exports.global
	integration = exports.integration
	itemworld = exports['item-world']
	item = exports['item-system']

	--outputDebugString("You clicked a "..tostring(getElementType(element)).." ("..tostring(getElementModel(element))..")")
	if getElementData(localPlayer, "exclusiveGUI") then
		return
	end
	if (element) and (getElementType(element)=="object") and (button=="right") and (state=="down") then
		local x, y, z = getElementPosition(getLocalPlayer())
		local eX, eY, eZ = getElementPosition(element)
		local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(element)
		local addDistance = 0 --compensate for object size
		if minX then
			local boundingBoxBiggestDist = 0
			if minX > boundingBoxBiggestDist then
				boundingBoxBiggestDist = minX
			end
			if minY > boundingBoxBiggestDist then
				boundingBoxBiggestDist = minY
			end
			if maxX > boundingBoxBiggestDist then
				boundingBoxBiggestDist = maxX
			end
			if maxY > boundingBoxBiggestDist then
				boundingBoxBiggestDist = maxY
			end
			addDistance = boundingBoxBiggestDist
		end
		local maxDistance = 3 + addDistance
		if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=maxDistance) then
			local rcMenu
			local row = {}

			if getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then
				local itemID = tonumber(getElementData(element, "itemID")) or 0
				if noMenuFor[itemID] then return end
				local itemValue = getElementData(element, "itemValue")
				local itemName = tostring(global:getItemName(itemID))
				
				if itemID == 81 then --fridge
					if itemworld:can(localPlayer, "use", element) then
						if not rcMenu then rcMenu = rightclick:create(itemName) end
						row.a = rightclick:addrow("Open fridge")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							if not getElementData ( localPlayer, "exclusiveGUI" ) then
								triggerServerEvent( "openFreakinInventory", getLocalPlayer(), element, absX, absY )
							end						
						end, false)
					end
				elseif itemID == 103 then --shelf
					if itemworld:can(localPlayer, "use", element) then
						if not rcMenu then rcMenu = rightclick:create(itemName) end
						row.a = rightclick:addrow("Browse shelf")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							if not getElementData ( localPlayer, "exclusiveGUI" ) then
								triggerServerEvent( "openFreakinInventory", getLocalPlayer(), element, absX, absY )
							end						
						end, false)
					end
				elseif itemID == 166 then --video system
					if itemworld:can(localPlayer, "use", element) then
						rcMenu = rightclick:create(itemName)
						if global:hasItem(element, 165) then --if disc in
							row.a = rightclick:addrow("Eject Disc")
							addEventHandler("onClientGUIClick", row.a,  function (button, state)
								triggerServerEvent("clubtec:vs1000:ejectDisc", getLocalPlayer(), element)
							end, false)
						end
						row.b = rightclick:addrow("Control")
						addEventHandler("onClientGUIClick", row.b,  function (button, state)
							triggerServerEvent("clubtec:vs1000:gui", getLocalPlayer(), element)
						end, false)
					end
				end

				--if item:getItemUseNewPickupMethod(itemID) then
					--[[
					if item:canItemBeMoved(itemID) then
						if itemworld:can(localPlayer, "move", element) then
							if not rcMenu then rcMenu = rightclick:create(itemName) end
							row.move = rightclick:addrow("Move")
						end						
					end
					--]]
				--end
				if not noPickupFor[itemID] and itemworld:can(localPlayer, "pickup", element) then
					if not rcMenu then rcMenu = rightclick:create(itemName) end
					row.pickup = rightclick:addrow("Pick Up")
					addEventHandler("onClientGUIClick", row.pickup,  function (button, state)
						triggerServerEvent("moveWorldItemToElement", localPlayer, element, localPlayer)
					end, false)
				end
				if not noPropertiesFor[itemID] and itemworld:canEditItemProperties(localPlayer, element) then
					if not rcMenu then rcMenu = rightclick:create(itemName) end
					row.properties = rightclick:addrow("Properties")
					addEventHandler("onClientGUIClick", row.properties,  function (button, state)
						triggerEvent("showItemProperties", localPlayer, element)
					end, false)						
				end
			end


			local model = getElementModel(element)
			if(model == 2517) then --SHOWERS
				rcMenu = exports.rightclick:create("Shower")
				if showering[1] then
					row.a = exports.rightclick:addrow("Stop showering")
					addEventHandler("onClientGUIClick", row.a,  function (button, state)
						takeShower(element)
					end, false)
				else
					row.a = exports.rightclick:addrow("Take a shower")
					addEventHandler("onClientGUIClick", row.a,  function (button, state)
						takeShower(element)
					end, false)
				end
			--[[elseif(model == 2964) then --Pool table / Billiard
				rcMenu = exports.rightclick:create("Pool Table")
				row.a = exports.rightclick:addrow("New Game")
				addEventHandler("onClientGUIClick", row.a,  function (button, state)
					outputDebugString("object-interaction: triggering billiard")
					--exports['minigame-billiard'].startNewGame(element, getLocalPlayer())
					triggerServerEvent("sendLocalMeAction", getLocalPlayer(), getLocalPlayer(), "test message")
					triggerServerEvent("billiardnewgame", getLocalPlayer(), getLocalPlayer(), "test message")
					local result = triggerServerEvent("newBilliardGame", getLocalPlayer(), element)
					outputDebugString("server trigger "..tostring(result)..", "..tostring(element))
					
				end, true)
			--]]
			elseif(model == 2146) then --Stretcher (ES)
				rcMenu = exports.rightclick:create("Stretcher")
				row.a = exports.rightclick:addrow("Take Stretcher")				
				addEventHandler("onClientGUIClick", row.a,  function (button, state)
					triggerServerEvent("stretcher:takeStretcher", localPlayer, element)	
				end, true)
			elseif(model == 1369) then --Wheelchair
				rcMenu = exports.rightclick:create("Wheelchair")
				row.a = exports.rightclick:addrow("Take Wheelchair")				
				addEventHandler("onClientGUIClick", row.a,  function (button, state)
					triggerServerEvent("wheelchair:takeWheelchair", localPlayer, element)	
				end, true)
			elseif(model == 962) then --Airport gate control box
				local airGateID = getElementData(element, "airport.gate.id")
				if airGateID then
					rcMenu = exports.rightclick:create("Control Box")
					row.a = exports.rightclick:addrow("Control Gate")				
					addEventHandler("onClientGUIClick", row.a,  function (button, state)
						triggerEvent("airport-gates:controlGUI", getLocalPlayer(), element)	
					end, false)			
				end
			elseif(model == 1819) then --Airport fuel
				local airFuel = getElementData(element, "airport.fuel")
				if airFuel then
					outputDebugString("Air fuel: TODO")
				end
			else
				if debugModelOutput then
					outputChatBox("Model ID "..tostring(model))
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickObject, true)

function debugToggleModelOutput(thePlayer, commandName)
	if exports.integration:isPlayerScripter(thePlayer) then
		debugModelOutput = not debugModelOutput
		outputChatBox("DBG: ModelOutput set to "..tostring(debugModelOutput))
	end
end
addCommandHandler("debugmodeloutput", debugToggleModelOutput)

function refreshCalls(res)
	rightclick = exports.rightclick
	global = exports.global
	integration = exports.integration
	itemworld = exports['item-world']
	item = exports['item-system']
end
addEventHandler("onClientResourceStart", getRootElement(), refreshCalls)