local localPlayer = getLocalPlayer()
local element = nil
local wInventory, gUserItems, UIColName, gElementItems, VIColName, bCloseInventory, bGiveItem, bTakeItem
local sx, sy = guiGetScreenSize()

local function forceUpdate( )
	if not wInventory then
		return
	end

	guiGridListClear(gUserItems)
	guiGridListClear(gElementItems)
	---------------
	-- PLAYER
	---------------
	local items = getItems(localPlayer)
	for slot, item in ipairs( items ) do
		if item then
			if getElementModel( element ) ~= 2147 or getItemType( item[ 1 ] ) == 1 then
				local row = guiGridListAddRow(gUserItems)

				local name = getItemName( item[1], item[2] )
				local desc = tostring(item[1] == 114 and getItemDescription( item[1], item[2] ) or item[2] == 1 and "" or item[2])
				if name ~= desc and #desc > 0 and item[1] ~= 114 then
					name = name .. " - " .. desc
				elseif item[1] == 114 then
					name = "Upgrade" .. " - " .. desc
				end
				guiGridListSetItemText(gUserItems, row, UIColName, name, false, false)
				guiGridListSetItemData(gUserItems, row, UIColName, tostring( slot ) )
			end
		end
	end

	if getElementModel( element ) ~= 2147 then
		-- WEAPONS
		for slot = 0, 12 do
			if getPedWeapon(localPlayer, slot) and getPedWeapon(localPlayer, slot) > 0 and getPedTotalAmmo( localPlayer, slot ) > 0 then
				local row = guiGridListAddRow(gUserItems)

				guiGridListSetItemText(gUserItems, row, UIColName, getItemName( -getPedWeapon(localPlayer, slot) ) .. " - " .. getPedTotalAmmo( localPlayer, slot ), false, false)
				guiGridListSetItemData(gUserItems, row, UIColName, tostring( -slot ) )
			end
		end

		-- ARMOR
		if getPedArmor( localPlayer ) > 0 then
			local row = guiGridListAddRow(gUserItems)

			guiGridListSetItemText(gUserItems, row, UIColName, getItemName( -100  ) .. " - " .. math.ceil( getPedArmor( localPlayer ) ), false, false )
			guiGridListSetItemData(gUserItems, row, UIColName, tostring( -100 ) )
		end
	end

	---------------
	-- ELEMENTS
	---------------
	if getElementType(element)=="interior" then
		outputChatBox ( "LOL nah.")
		return
	end


	local items = getItems( element )
	for slot, item in pairs( items ) do
		if getElementType( element ) ~= "vehicle" or item[1] ~= 74 then
			local row = guiGridListAddRow(gElementItems)

			local name = getItemName( item[1], item[2] )
			local desc = tostring(item[1] == 114 and getItemDescription( item[1], item[2] ) or item[2] == 1 and "" or item[2])
			if name ~= desc and #desc > 0 and item[1] ~= 114 then
				name = name .. " - " .. desc
			elseif item[1] == 114 then
				name = desc
			end
			guiGridListSetItemText(gElementItems, row, VIColName, name, false, false)
			guiGridListSetItemData(gElementItems, row, VIColName, tostring( slot ) )
		end
	end


	if getElementType( element ) == "vehicle" then
		local mods = getVehicleUpgrades( element )
		local data = getElementData( localPlayer, "v:mods" )
		if data and data[ element ] then
			for key, value in pairs( data[ element ] ) do
				for k, v in ipairs( mods ) do
					if key == v then
						table.remove( mods, k )

						local row = guiGridListAddRow(gElementItems)

						guiGridListSetItemText(gElementItems, row, VIColName, "Upgrade " .. getItemDescription( 114, v ), false, false)
						guiGridListSetItemData(gElementItems, row, VIColName, tostring( -v ) )

						break
					end
				end
			end
		end
		if exports.integration:isPlayerTrialAdmin(getLocalPlayer()) then
			for key, value in ipairs(mods) do
				local row = guiGridListAddRow(gElementItems)

				guiGridListSetItemText(gElementItems, row, VIColName, "UPGRADE " .. getItemDescription( 114, value ), false, false)
				guiGridListSetItemData(gElementItems, row, VIColName, tostring( -value ) )
			end
		end
	end
	triggerEvent("item:updateclient", localPlayer)

end
addEvent( "forceElementMoveUpdate", true )
addEventHandler( "forceElementMoveUpdate", localPlayer, forceUpdate )

local function update()
	if source == localPlayer or source == element then
		forceUpdate()
	end
end

addEventHandler("recieveItems", getRootElement(), update)

local function hideMenu()
	if wInventory then
		destroyElement( wInventory )
		wInventory = nil

		triggerServerEvent( "closeFreakinInventory", localPlayer, element )

		element = nil

		setElementData(localPlayer, "exclusiveGUI", false, false)
		showCursor( false )
	end
end

function hasKey( key, element )
	if getElementType(element)~="interior" then return end
	if exports.global:hasItem(getLocalPlayer(), 4, key) or exports.global:hasItem(getLocalPlayer(), 5,key) then
		return true, false
	elseif getElementData(getLocalPlayer(), "duty_admin") == 1 then
			return true, true
	else
		local interiorStatus = getElementData(element, "status")
		local interiorType = interiorStatus[1] or -1
		if interiorType==2 then
			local theTeam = getPlayerTeam(getLocalPlayer())
			local factionType = getElementData(theTeam, "type")
			if (factionType~=2 and factionType~=3) then
				return false, false
			else
				return true, true
			end
		end
	end
	return false, false
end

local function moveToElement( button )
	local row, col = guiGridListGetSelectedItem(gUserItems)
	if button == "left" and col ~= -1 and row ~= -1 then
		local slot = tonumber( guiGridListGetItemData(gUserItems, row, col) )
		if slot then
			guiSetVisible( wWait, true )
			guiSetEnabled( wInventory, false )
			if slot > 0 then
				triggerServerEvent( "moveToElement", localPlayer, element, slot )
			elseif slot == -100 then
				triggerServerEvent( "moveToElement", localPlayer, element, slot, true )
			else
				slot = -slot
				triggerServerEvent( "moveToElement", localPlayer, element, getPedWeapon( localPlayer, slot ), math.min( getPedTotalAmmo( localPlayer, slot ), getElementData( localPlayer, "ACweapon" .. getPedWeapon( localPlayer, slot ) ) or 0 ) )
			end
		end
	end
end

local function moveFromElement( button )
	local row, col = guiGridListGetSelectedItem(gElementItems)
	if button == "left" and col ~= -1 and row ~= -1 then
		local slot = tonumber( guiGridListGetItemData(gElementItems, row, col) )
		if not slot then return end
		if slot < 0 --[[and exports.integration:isPlayerTrialAdmin(localPlayer)]] then
			triggerServerEvent( "item:vehicle:removeUpgrade", element, -slot )
			guiSetVisible( wWait, true )
			guiSetEnabled( wInventory, false )
		elseif slot then
			local item = getItems( element )[ slot ]
			if item then
				local itemID, itemValue, itemIndex = unpack( item )
				if getElementType(element)~="interior" then
					if itemID < 0 and itemID ~= -100 then -- weapon
						local free, totalfree = exports.weaponcap:getFreeAmmo( -itemID )
						local cap = exports.weaponcap:getAmmoCap( -itemID )
						if totalfree == 0 then
							outputChatBox( "You've got all weapons you can carry.", 255, 0, 0 )
						elseif free == 0 and cap == 0 then
							local weaponName = "other weapon"
							local slot = getSlotFromWeapon( -itemID )
						if slot and slot ~= 0 and getPedTotalAmmo( getLocalPlayer(), slot ) > 0 then
							local weapon = getPedWeapon( getLocalPlayer(), slot )
							weaponName = getWeaponNameFromID( weapon )
						end
							outputChatBox( "You don't carry that weapon, please drop your " .. weaponName .. " first.", 255, 0, 0 )
						elseif free == 0 then
							outputChatBox( "You can't carry any more of that weapon.", 255, 0, 0 )
						else
							--guiSetVisible( wWait, true )
							--guiSetEnabled( wInventory, false )
							triggerServerEvent( "moveFromElement", localPlayer, element, slot, free, itemIndex )
						end
					else
						--guiSetVisible( wWait, true )
						--guiSetEnabled( wInventory, false )
						triggerServerEvent( "moveFromElement", localPlayer, element, slot, nil, itemIndex )
					end
				else
					outputChatBox("LOL nah", 255, 0, 0)
				end
			end
		end
	end
end

local function adminCheck( button )
	local row, col = guiGridListGetSelectedItem(gElementItems)
	if button == "right" and col ~= -1 and row ~= -1 then
		local slot = tonumber( guiGridListGetItemData(gElementItems, row, col) )
		if not slot then return end
		local item = getItems( element )[ slot ]
		if not item then return end
			-- don't pick it up otherwise
		if exports.global:isStaffOnDuty(getLocalPlayer()) then
			triggerServerEvent("protectItem", element, fp, item, slot)
			return
		end
	end
end

local function openElementInventory( ax, ay )
	if not getElementData(localPlayer, "exclusiveGUI") or (getElementType(source) == "interior") then
		hideMenu()

		element = source
		
		local w, h = 500, 500
		local type = getElementModel(source) == 2147 and "Fridge" or getElementModel(source) == 3761 and "Shelf" or (( getElementType(source) == "vehicle" and "Vehicle" ) or "Safe" )
		setElementData(localPlayer, "exclusiveGUI", true, false)

		ax = math.max( 10, math.min( sx - 410, ax ) )
		ay = math.max( 10, math.min( sy - 310, ay ) )

		wInventory = guiCreateStaticImage(ax-w/2, ay-h/2, w, h, ":resources/window_body.png",false)--type .. " Inventory", false)
		--guiWindowSetSizable(wInventory, false)
		lYou = guiCreateLabel(0.25, 0.1, 0.87, 0.05, "YOU", true, wInventory)
		guiSetFont(lYou, "default-bold-small")

		lVehicle = guiCreateLabel(0.675, 0.1, 0.87, 0.05, type:upper(), true, wInventory)
		guiSetFont(lVehicle, "default-bold-small")

		gUserItems = guiCreateGridList(0.05, 0.15, 0.45, 0.65+0.075, true, wInventory)
		UIColName = guiGridListAddColumn(gUserItems, "Name", 0.9)

		gElementItems = guiCreateGridList(0.5, 0.15, 0.45, 0.65+0.075, true, wInventory)
		VIColName = guiGridListAddColumn(gElementItems, "Name", 0.9)

		bCloseInventory = guiCreateButton(0.05, 0.9, 0.9, 0.075, "Close Inventory", true, wInventory)
		addEventHandler("onClientGUIClick", bCloseInventory, hideMenu, false)

		--bGiveItem = guiCreateButton(0.05, 0.81, 0.45, 0.075, "Move ---->", true, wInventory)
		--addEventHandler("onClientGUIClick", bGiveItem, moveToElement, false)
		addEventHandler("onClientGUIDoubleClick", gUserItems, moveToElement, false)

		--bTakeItem = guiCreateButton(0.5, 0.81, 0.45, 0.075, "<---- Move ", true, wInventory)
		--addEventHandler("onClientGUIClick", bTakeItem, moveFromElement, false)
		addEventHandler("onClientGUIDoubleClick", gElementItems, moveFromElement, false)
		addEventHandler("onClientGUIClick", gElementItems, adminCheck, false)

		forceUpdate()

		showCursor( true )
	else
		outputChatBox("You can't access that inventory at the moment.", 255, 0, 0)
	end
end

addEvent( "openElementInventory", true )
addEventHandler( "openElementInventory", getRootElement(), openElementInventory )
addEventHandler( "onClientChangeChar", getRootElement(), hideMenu )

addEvent( "finishItemMove", true )
addEventHandler( "finishItemMove", getLocalPlayer(),
	function( )
		guiSetEnabled( wInventory, true )
		guiSetVisible( wWait, false )
	end
)

function collisionFix()
	for key, value in pairs( getElementsByType( "object", getResourceRootElement( getResourceFromName("item-world") ) ) ) do
		if isElement( value ) then
			local modelid = getElementModel(value)
			if modelid == 1271 then
				setElementCollisionsEnabled(value, false)
			end
		end
	end
end
setTimer(collisionFix, 5000, 0)
--addEventHandler( "onClientPreRender", getRootElement(), collisionFix )
