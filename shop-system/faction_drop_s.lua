FORUM_FACTION_DROPS = 330
FORUM_AMMUNATION = 511

--MAXIME
local purchaseLogs = {}
function factionDropCreateItem(npcID, itemID, itemValue, itemPrice, itemQuan, itemCaliber, itemDesc, itemRestock, selectedItem)
	if not npcID or not tonumber(npcID) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Could not allocate NPC ID.")
		return false
	end
	
	if not itemID or not tonumber(itemID) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Could not allocate Item ID.")
		return false
	else
		itemID = tonumber(itemID)
	end
	
	if not itemQuan or not tonumber(itemQuan) or tonumber(itemQuan) < 1 then
		triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Quantity must be numeric and greater than 0.")
		return false
	end
	itemQuan = math.floor(itemQuan)
	
	if not itemPrice or not tonumber(itemPrice) or tonumber(itemPrice) < 1 then
		triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Price must be numeric and greater than 0.")
		return false
	end
	itemPrice = math.floor(itemPrice)
	
	if not itemRestock or not tonumber(itemRestock) or tonumber(itemRestock) < 0 then
		triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Auto-restock must be numeric, equal and greater than 0.")
		return false
	end
	itemRestock = math.floor(itemRestock)
	
	if itemID == 116 then
		if not itemDesc or not tonumber(itemDesc) or tonumber(itemDesc) < 1 then
			triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Bullets/Mag must be numeric and greater than 0.")
			return false
		else
			itemDesc = math.floor(itemDesc)
		end
	else
		if string.len(itemDesc) <= 1 then
			itemDesc = weaponList[selectedItem][3] or "Unknown Weapon"
		end
	end
	
	local finalItemValue = ""
	if itemID == 115 then
		finalItemValue = itemValue..":Faction Drop Weapon:"..itemDesc..":"..itemCaliber..":Weapon from faction drop, created by "..exports.global:getAdminTitle1(source)
	else
		finalItemValue = itemValue..":"..itemDesc..":"..(weaponList[selectedItem][3] or "Ammopack")
		
	end
	finalItemValue = exports.global:toSQL(finalItemValue)
	
	if not mysql:query_free("INSERT INTO `shop_products` SET `pItemID`='"..itemID.."', `pItemValue`='"..finalItemValue.."', `pPrice`='"..itemPrice.."', `pQuantity`='"..itemQuan.."', `pSetQuantity`='"..itemQuan.."', `pRestockInterval`='"..itemRestock.."', `npcID`='"..npcID.."', `pRestockedDate`=NOW()") then
		triggerClientEvent(source, "shop:factionDropResponseFromServer", source, false, "Could not create item, database error.")
		return false
	end
	triggerClientEvent(source, "shop:factionDropResponseFromServer", source, true)
	refreshFactionDropWeaponList(source,npcID)
end
addEvent("shop:factionDropCreateItem", true )
addEventHandler("shop:factionDropCreateItem", root, factionDropCreateItem)

function refreshFactionDropWeaponList(thePlayer,id)
	local products = {}
	local shopProducts = mysql:query("SELECT `npcID`, `pItemID`, `pItemValue`, `pDesc`, `pPrice`, `pDate`, `pID`, `pQuantity`, `pSetQuantity`, `pRestockInterval`, `pRestockedDate`, DATEDIFF((`pRestockedDate` + interval `pRestockInterval` day),NOW()) AS `pRestockIn` FROM `shop_products` WHERE `npcID`='"..id.."' ORDER BY `pID` DESC")
	while true do
		local pRow = mysql:fetch_assoc(shopProducts)
		if not pRow then break end
		table.insert(products, pRow )
	end
	mysql:free_result(shopProducts) 
	triggerClientEvent(thePlayer, "shop:factionDropUpdateWeaponList", thePlayer, products)
end

function factionDropWeaponBuy(proID, theShop, reasonToBuy)
	local valid, why = isPlayerUsingThisShop(source, theShop)
	if not valid or not proID or not tonumber(proID) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, why)
		return false
	end
	
	local npcID = getElementData(theShop,"dbid")
	local pedName = getPedName(theShop)
	local playerName = exports.global:getPlayerName(source)
	
	local product = mysql:query_fetch_assoc("SELECT * FROM `shop_products` WHERE `pID`='"..proID.."' AND `npcID`='"..npcID.."' LIMIT 1")
	if not product or not product["pID"] or not tonumber(product["pID"]) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, "This product is no longer available in this shop.")
		return false
	end
	
	local pQuantity = tonumber(product["pQuantity"]) or 0
	if pQuantity <= 0 then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, "This product is out of stock.")
		return false
	end
	
	local pPrice = tonumber(product["pPrice"])
	if not pPrice or not exports.global:takeMoney(source, pPrice) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, "You can not afford to buy this item any more.")
		return false
	end
	
	local pItemID = tonumber(product["pItemID"]) 
	local pItemValueTmp = product["pItemValue"]
	local pItemValue = ""
	local serial = false
	if pItemID == 115 then --gun
		local decoded = exports.global:explode(":", pItemValueTmp)
		serial = exports.global:createWeaponSerial( 4, npcID, tonumber(getElementData(source, "account:character:id")))
		decoded[2] = serial
		for i=1, #decoded do
			pItemValue = pItemValue..decoded[i]..":"
		end
	else
		pItemValue = pItemValueTmp
	end
	
	local success, reason = exports["item-system"]:giveItem( source, pItemID, pItemValue )
	if not success then
		exports.global:giveMoney(source, pPrice)
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, reason)
		return false
	end
			
	playBuySound(theShop)
	if getElementData(source,"gender") == 0 then
		exports.global:sendLocalMeAction(source, "takes out a credit card from his wallet, hands it over to "..pedName..".")
	else
		exports.global:sendLocalMeAction(source, "takes out a credit card from her wallet, hands it over to "..pedName..".")
	end
	
	local itemName = exports["item-system"]:getItemName( pItemID, pItemValue )
	local itemValue = exports["item-system"]:getItemValue( pItemID, pItemValue )
	
	exports.global:sendLocalText(source, "✪ "..pedName.." gives "..playerName.." a "..itemName..".", 255, 51, 102, 30, {}, true)
	local prepared = "UPDATE `shop_products` SET `pQuantity`=`pQuantity`-1 WHERE `pID`='"..proID.."' AND `npcID`='"..npcID.."' "
	if tonumber(product["pRestockInterval"]) < 1 and pQuantity <= 1 then
		prepared = "DELETE FROM `shop_products` WHERE `pID`='"..proID.."' AND `npcID`='"..npcID.."'"
	end
	if not mysql:query_free(prepared) then
		destroyElement(theShop)
		exports.global:sendWrnToStaffOnDuty("Exploit detected in faction drop NPC ID#"..npcID.." and with "..exports.global:getPlayerFullIdentity(source)..". Please notify a scripter ASAP!", "SHOP")
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, "Exploit detected in faction drop NPC ID#"..npcID.." and with "..exports.global:getPlayerFullIdentity(source)..". Staff have been alerted." )
		return false
	end
	
	addPurchaseLogs(npcID, source, itemName, itemValue, exports.global:formatMoney(pPrice), serial , reasonToBuy, FORUM_FACTION_DROPS)
	
	triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, true, "Purchased successfully!" )
	refreshFactionDropWeaponList(source,npcID)
	return true
end
addEvent("shop:factionDropWeaponBuy", true )
addEventHandler("shop:factionDropWeaponBuy", getRootElement(), factionDropWeaponBuy)

function addPurchaseLogs(npcID, thePlayer, itemName, itemValue, price, serial, reason, forum)
	local r = getRealTime()
	local timeString = ("%02d/%02d/%04d %02d:%02d"):format(r.monthday, r.month + 1, r.year+1900, r.hour, r.minute)
	if not purchaseLogs[npcID] then 
		purchaseLogs[npcID] = { forum = forum }
	end
	local buyerUsername = getElementData(thePlayer, "account:username")
	local buyerCharacter = exports.global:getPlayerName(thePlayer)
	local buyerFaction = getTeamName(getPlayerTeam(thePlayer))
	table.insert(purchaseLogs[npcID], {timeString, buyerUsername, buyerCharacter, buyerFaction, itemName, itemValue, price, serial, reason} )
end

function makePurchaseForumReports()
	local shops = getElementsByType("ped", getResourceRootElement ())
	local counter = 0
	for i, shop in pairs(shops) do
		local shoptype = getElementData(shop, "shoptype") 
		if shoptype == 19 or shoptype == 2 then
			local npcID = getElementData(shop,"dbid")
			local npcName = getPedName(shop)
			if purchaseLogs[npcID] then
				local logs = purchaseLogs[npcID]
				createForumThread(logs, npcID, npcName, logs.forum)
				counter = counter + 1
				purchaseLogs[npcID] = nil
			end
		end
	end 
	outputDebugString("[SHOP] A forum report has made for "..counter.." Faction Drop NPC(s).")
end

function createForumThread(logs, npcID, npcName, createInForumID)
	exports.global:sendWrnToStaff(tostring(#logs).." items were purchased from NPC "..tostring(npcName).." (ID #"..tostring(npcID)..")", "NPC")	
	return 1
end

function factionDropTakeDown(proID, theShop)
	local valid, why = isPlayerUsingThisShop(source, theShop)
	if not valid or not proID or not tonumber(proID) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, why)
		return false
	end
	
	local npcID = getElementData(theShop,"dbid")
	local pedName = getPedName(theShop)
	local playerName = exports.global:getPlayerName(source)
	
	local product = mysql:query_fetch_assoc("SELECT * FROM `shop_products` WHERE `pID`='"..proID.."' AND `npcID`='"..npcID.."' LIMIT 1")
	if not product or not product["pID"] or not tonumber(product["pID"]) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, "This product is no longer available in this shop.")
		return false
	end
	
	local prepared = "DELETE FROM `shop_products` WHERE `pID`='"..proID.."' AND `npcID`='"..npcID.."'"
	if not mysql:query_free(prepared) then
		triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, false, "Could not take down item. Exploit detected in faction drop NPC ID#"..npcID.." and with "..exports.global:getPlayerFullIdentity(source).."." )
		return false
	end
	
	triggerClientEvent(source, "shop:factionDropResponseFromServer:2", source, true, "Item taken down successfully!" )
	refreshFactionDropWeaponList(source,npcID)
	return true
end
addEvent("shop:factionDropTakeDown", true )
addEventHandler("shop:factionDropTakeDown", root, factionDropTakeDown)

function saveFactionDropNPCConfigs(theShop, faction_belong, faction_access)
	if exports.anticheat:changeProtectedElementDataEx(theShop, "faction_belong", faction_belong, true) and exports.anticheat:changeProtectedElementDataEx(theShop, "faction_access", faction_access, true) then
		outputChatBox("Faction Drop NPC's Configurations have been saved successfully.", source)
	else
		outputChatBox("Faction Drop NPC's Configurations saving has failed.", source)
	end
end
addEvent("saveFactionDropNPCConfigs", true )
addEventHandler("saveFactionDropNPCConfigs", root, saveFactionDropNPCConfigs)

function saveShopChangesToSQL()
	local shops = getElementsByType("ped", getResourceRootElement ())
	local counter = 0
	for i, shop in pairs(shops) do
		local shoptype = getElementData(shop, "shoptype") 
		if shoptype == 18 or shoptype == 19 then
			local faction_belong = getElementData(shop, "faction_belong") or 0
			local faction_access = getElementData(shop, "faction_access") or 0
			local shopID = getElementData(shop, "dbid")
			if shopID and exports.mysql:query_free("UPDATE `shops` SET `faction_belong`='"..exports.global:toSQL(faction_belong).."', `faction_access`='"..exports.global:toSQL(faction_access).."' WHERE `id`='"..exports.global:toSQL(shopID).."' ") then
				counter = counter + 1
			else
				outputDebugString("[SHOP] Could not save configs for a shop because no ID found or database error ("..tostring(shopID)..")")
			end
		end
	end
	outputDebugString("[SHOP] Saved "..counter.." shops configs to SQL successfully.")
	if mysql:query_free("UPDATE `shop_products` SET `pQuantity`=`pSetQuantity`, `pRestockedDate`=NOW() WHERE `pRestockedDate` IS NOT NULL AND `pRestockInterval`>0 AND (DATEDIFF((`pRestockedDate` + interval `pRestockInterval` day),NOW())=0)") then
		outputDebugString("[SHOP] Faction Drop - Restocked products")
	else
		outputDebugString("[SHOP] Faction Drop - Failed to Restock products")
	end
	exports.data:savePurchaseLogs(purchaseLogs)
end
addEventHandler("onResourceStop",resourceRoot,saveShopChangesToSQL)
addEventHandler("onResourceStart",resourceRoot,function()
	purchaseLogs = exports.data:loadPurchaseLogs()
	
	setTimer(function()
		saveShopChangesToSQL()
	end, 60*1000*60, 0) -- every 60 minutes
	
	setTimer(function()
		makePurchaseForumReports()
	end, 60*1000*30, 0) -- every 30 minutes
end)

function adminSaveShopChangesToSQL(thePlayer, cmd)
	if exports.integration:isPlayerAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		saveShopChangesToSQL()
		outputChatBox("Saving started..", thePlayer)
	end
end
addCommandHandler("saveshopconfigs", adminSaveShopChangesToSQL)
