-- Script: elevator-system -> Lifts
-- Description: Adds a new elevator type, lift, that gives you a GUI that lets you choose what floor to go to.
-- Client-Side
-- Created by Exciter for Owl Gaming, 16.05.2014 (DD/MM/YYYY)
-- Based on the script from RPP.
-- License: BSD

local localPlayer = getLocalPlayer()
local preventEnterCar = false

function lift_pickupUse(thePlayer, matchingDimension)
	if(thePlayer == getLocalPlayer()) then
		if(getElementDimension(thePlayer) == getElementDimension(source)) then --matchingDimension
			if(getElementData(source, "rpp.lift.floor.id")) then
				preventEnterCar = true
				if (isElement(gInteriorName) and guiGetVisible(gInteriorName)) then
					if isTimer(timer) then
						killTimer(timer)
						timer = nil
					end

					destroyElement(gInteriorName)
					gInteriorName = nil

					destroyElement(gOwnerName)
					gOwnerName = nil
				end
				local px,py,pz = getElementPosition(getLocalPlayer())
				local x,y,z = getElementPosition(source)
				if(getDistanceBetweenPoints3D(px,py,pz,x,y,z) > 2) then
					unbindKey("f", "down", triggerLiftGUI)
					return
				end

				gInteriorName = guiCreateLabel(0.0, 0.85, 1.0, 0.3, "Elevator", true)
				guiSetFont(gInteriorName, "sa-header")
				guiLabelSetHorizontalAlign(gInteriorName, "center", true)
				guiSetAlpha(gInteriorName, 0.0)

				gOwnerName = guiCreateLabel(0.0, 0.90, 1.0, 0.3, "Press F to use.", true)
				guiSetFont(gOwnerName, "default-bold-small")
				guiLabelSetHorizontalAlign(gOwnerName, "center", true)
				guiSetAlpha(gOwnerName, 0.0)

				timer = setTimer(fadeMessage, 50, 20, true)

				--outputDebugString("source: "..tostring(source))
				bindKey("f", "down", triggerLiftGUI, source)

			cancelEvent()
			end
		end
	end
end
addEventHandler("onClientPickupHit", root, lift_pickupUse)
addEvent("lift:hit", true)
addEventHandler("lift:hit", getRootElement(), lift_pickupUse)

function stopVehicleEntry(vehicle, seat)
	--if preventEnterCar then
		preventEnterCar = false
		cancelEvent()
	--end
end
addEventHandler("onClientPlayerVehicleEnter", getRootElement(), stopVehicleEntry)

function lift_pickupLeave(thePlayer, matchingDimension, thePickup)
	--outputDebugString("lift_pickupLeave()")
	if(thePlayer == getLocalPlayer()) then
		if not source then
			source = thePickup
		end
		if matchingDimension then
			if(getElementData(source, "rpp.lift.floor.id")) then
				hideIntName()
				unbindKey("f", "down", triggerLiftGUI)
				--cancelEvent()
			end
		end
	end
end
addEventHandler("onClientPickupLeave", root, lift_pickupLeave)
addEvent("lift:leave", true)
addEventHandler("lift:leave", getRootElement(), lift_pickupLeave)

function fadeMessage(fadein)
	if gInteriorName and gOwnerName then
		local alpha = guiGetAlpha(gInteriorName)

		if (fadein) and (alpha) then
			local newalpha = alpha + 0.05
			guiSetAlpha(gInteriorName, newalpha)
			guiSetAlpha(gOwnerName, newalpha)

			if(newalpha>=1.0) then
				timer = setTimer(hideIntName, 4000, 1)
			end
		elseif (alpha) then
			local newalpha = alpha - 0.05
			guiSetAlpha(gInteriorName, newalpha)
			guiSetAlpha(gOwnerName, newalpha)

			if (gBuyMessage) then
				guiSetAlpha(gBuyMessage, newalpha)
			end

			if(newalpha<=0.0) then
				destroyElement(gInteriorName)
				gInteriorName = nil

				destroyElement(gOwnerName)
				gOwnerName = nil
			end
		end
	end
end

function hideIntName()
	setTimer(fadeMessage, 50, 20, false)
end

function triggerLiftGUI(key, keyState, pickup)
	if(key == "f" and keyState == "down" and not wElevator) then
		local px,py,pz = getElementPosition(getLocalPlayer())
		local x,y,z = getElementPosition(pickup)
		if(getDistanceBetweenPoints3D(px,py,pz,x,y,z) > 2) then
			unbindKey("f", "down", triggerLiftGUI)
			return
		end

		local width, height = 300, 390
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		wElevator = guiCreateWindow(x, y, width, height, "Elevator", false)

		floorList = guiCreateGridList(0.05, 0.1, 0.9, 0.74, true, wElevator)
		local columnFloor = guiGridListAddColumn(floorList, "Floor", 0.2)
		local columnName = guiGridListAddColumn(floorList, "Name", 0.7)
		
		bGoto = guiCreateButton(0.05, 0.84, 0.45, 0.1, "GO TO", true, wElevator)
		bCancel = guiCreateButton(0.5, 0.84, 0.45, 0.1, "Cancel", true, wElevator)
		
		local thisFloorNum = tonumber(getElementData(pickup, "rpp.lift.floor.floor")) or 0
		lblCurrent = guiCreateLabel(0.05, 0.05, 0.9, 0.05, "This floor: "..tostring(getElementData(pickup, "rpp.lift.floor.floor")).." - "..tostring(getElementData(pickup, "rpp.lift.floor.name")), true, wElevator)

		local liftElement = getElementParent(pickup)
		local liftID = getElementData(liftElement, "dbid")
		
		if (exports.integration:isPlayerTrialAdmin(localPlayer) or tostring(getElementData(localPlayer, "account:username")) == "Exciter") then
			lblAdmin = guiCreateLabel(0.05, 0.94, 0.9, 0.05, "Elevator ID: "..tostring(liftID), true, wElevator)
		end
		
		--local numfloors = getElementChildrenCount(liftElement)
		local floors = getElementChildren(liftElement, "pickup")
		local floorsSorted = {}
		if floors then
			for k,v in ipairs(floors) do
				local floorNum = tonumber(getElementData(v, "rpp.lift.floor.floor")) or 0
				table.insert(floorsSorted, {v, floorNum})
			end
			table.sort(floorsSorted, compare)
			for k,v in ipairs(floorsSorted) do
				local ele = v[1]
				local row = guiGridListAddRow(floorList)
				guiGridListSetItemText(floorList, row, columnFloor, tostring(getElementData(ele, "rpp.lift.floor.floor")), false, false)
				guiGridListSetItemText(floorList, row, columnName, tostring(getElementData(ele, "rpp.lift.floor.name")), false, false)
				local data = tostring(liftID)..","..tostring(getElementData(ele, "rpp.lift.floor.id"))
				guiGridListSetItemData(floorList, row, 1, data)
				if(v[2] == thisFloorNum) then
					guiGridListSetSelectedItem(floorList, row, columnName)
				end
			end

			showCursor(true)

			addEventHandler("onClientGUIClick", bGoto, gotoFloor)
			addEventHandler("onClientGUIDoubleClick", floorList, gotoFloor)
			addEventHandler("onClientGUIClick", bCancel, hideElevatorGUI)
		else
			outputChatBox("You push the elevator button, but nothing happens.", 255, 0, 0)
			hideElevatorGUI()
		end
	end
end
function compare(a,b)
	return a[2] > b[2]
end

function gotoFloor(button, state)
	if (button=="left") then
		local row, col = guiGridListGetSelectedItem(floorList)
		if (row==-1) or (col==-1) then
			outputChatBox("Please select a floor.", 255, 0, 0)
		else
			local data = guiGridListGetItemData(floorList, guiGridListGetSelectedItem(floorList), 1)
			local data = exports.global:split(data, ",")
			local liftID = tonumber(data[1])
			local floorID = tonumber(data[2])
			local floorNum = tostring(guiGridListGetItemText(floorList, row, 1))
			local floorName = tostring(guiGridListGetItemText(floorList, row, 2))
			
			local liftElement = getElementByID("lif"..tostring(liftID))
			if not liftElement then hideElevatorGUI() return false end
			local floors = getElementChildren(liftElement, "pickup")
			if not floors then hideElevatorGUI() return false end
			local pickup
			for k,v in ipairs(floors) do
				if(tonumber(getElementData(v, "rpp.lift.floor.id")) == floorID) then
					pickup = v
					break;
				end
			end
			if not pickup then
				hideElevatorGUI()
				outputChatBox("ERROR: Floor not found.", 255, 0, 0)
				return false
			end
			
			local x,y,z = getElementPosition(pickup)
			local interior = getElementInterior(pickup)
			local dimension = getElementDimension(pickup)
			local gototable = {x,y,z,interior,dimension}
			
			if(x and y and z and interior and dimension and gototable) then
				local meText = "takes the elevator to floor "..tostring(floorNum).."."
				triggerServerEvent("lift:me", getLocalPlayer(), meText)
				triggerEvent("setPlayerInsideInterior2", localPlayer, gototable, pickup)
				--triggerServerEvent("lift:use", getLocalPlayer(), floorID)
			end

			hideElevatorGUI()
		end
	end
end

function hideElevatorGUI(button, state)
	if floorList then destroyElement(floorList) end
	if bGoto then destroyElement(bGoto) end
	if bCancel then destroyElement(bCancel) end
	if lblAdmin then destroyElement(lblAdmin) end
	if lblCurrent then destroyElement(lblCurrent) end
	if wElevator then destroyElement(wElevator) end
	wElevator, floorList, bGoto, bCancel = nil, nil, nil, nil
	if isCursorShowing() then showCursor(false) end
end