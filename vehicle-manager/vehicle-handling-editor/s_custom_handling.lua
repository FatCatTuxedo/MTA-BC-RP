function editVehicle(thePlayer, commandName)
	if exports.integration:isPlayerVehicleConsultant(thePlayer) or exports.integration:isPlayerSeniorAdmin(thePlayer) or exports.integration:isPlayerVCTMember(thePlayer) then
		local theVehicle = getPedOccupiedVehicle(thePlayer) or false
		if not theVehicle then
			outputChatBox( "You must be in a vehicle.", thePlayer, 255, 194, 14)
			return false
		end
		
		local vehID = getElementData(theVehicle, "dbid") or false
		if not vehID or vehID < 0 then	
			outputChatBox("This vehicle can not have custom properties.", thePlayer, 255, 194, 14)
			return false
		end
		
		local veh = {}
		local row = mysql:query_fetch_assoc("SELECT * FROM `vehicles_custom` WHERE `id` = '" .. mysql:escape_string(vehID) .. "' LIMIT 1" ) or false
		if row then
			veh.id = row.id
			veh.brand = row.brand
			veh.model = row.model
			veh.price = row.price
			veh.tax = row.tax
			veh.handling = row.handling
			veh.notes = row.notes
			veh.doortype = getRealDoorType(row.doortype)
		end
		triggerClientEvent(thePlayer, "vehlib:handling:editVehicle", thePlayer, row)
		
		--exports["vehicle-system"]:reloadVehicle(tonumber(vehID))
		exports.logs:dbLog(thePlayer, 4, { theVehicle, thePlayer }, commandName)
		return true
	end
end
addCommandHandler("editvehicle", editVehicle)
addCommandHandler("editveh", editVehicle)

function createUniqueVehicle(data, existed)
	if not data then
		outputDebugString("VEHICLE MANAGER / createUniqueVehicle / NO DATA RECIEVED FROM CLIENT")
		return false
	end

	data.doortype = getRealDoorType(data.doortype) or 'NULL'
	
	local vehicle = exports.pool:getElement("vehicle", tonumber(data.id))
	local forumText = [=[
<B>[size=5]General Information:[/size]</B><br>
<b>Vehicle ID:   </b> ]=] ..tostring(data.id) ..[=[<br>
<b>Current Owner:   </b>]=] ..tostring(getVehicleOwner(vehicle)) ..[=[<br>
<b>Edited by:   </b>]=] ..tostring(getElementData(client, "account:username")) ..[=[<br>
<b>Note:   </b>]=] ..tostring(data.note) ..[=[<br>
<b>[size=5]New Vehicle Data:[/size]</b><br>
<b>Brand:   </b>]=] ..tostring(data.brand) ..[=[<br>
<b>Model:   </b>]=] ..tostring(data.model) ..[=[<br>
<b>Year:    </b>]=] ..tostring(data.year) ..[=[<br>
<b>Price:   </b>]=] ..tostring(data.price) ..[=[<br>
<b>Tax:     </b>]=] ..tostring(data.tax) ..[=[<br>
<b>Door Type: </b>]=] ..tostring(data.doortype) ..[=[<br>
<b>[size=5]Old Vehicle Data:[/size]</b>
<b>Brand:   </b>]=] ..tostring(getElementData(vehicle, "brand")) ..[=[<br>
<b>Model:   </b>]=] ..tostring(getElementData(vehicle, "maximemodel")) ..[=[<br>
<b>Year:    </b>]=] ..tostring(getElementData(vehicle, "year")) ..[=[<br>
<b>Price:   </b>]=] ..tostring(getElementData(vehicle, "carshop:cost")) ..[=[<br>
<b>Tax:     </b>]=] ..tostring(getElementData(vehicle, "carshop:taxcost")) ..[=[<br>
<b>Door Type: </b>]=] ..tostring(getElementData(vehicle, "vDoorType") or 'NULL') ..[=[<br>]=]

	if not existed then
		--outputDebugString(data.id)
		local mQuery1 = mysql:query_insert_free("INSERT INTO `vehicles_custom` SET `id`='"..toSQL(data["id"]).."', `brand`='"..toSQL(data["brand"]).."', `model`='"..toSQL(data["model"]).."', `year`='"..toSQL(data["year"]).."', `price`='"..toSQL(data["price"]).."', `tax`='"..toSQL(data["tax"]).."', `createdby`='"..toSQL(getElementData(client, "account:id")).."', `notes`='"..toSQL(data["note"]).."', `doortype` = " .. data.doortype)
		if not mQuery1 then
			outputDebugString("VEHICLE MANAGER / VEHICLE LIB / createUniqueVehicle / DATABASE ERROR")
			outputChatBox("[VEHICLE MANAGER] Failed to create unique vehicle.", client, 255,0,0)
			return false
		end
		outputChatBox("[VEHICLE MANAGER] Unique vehicle created.", client, 0,255,0)
		exports.logs:dbLog(client, 6, { client }, " Created unique vehicle #"..data.id..".")
		exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has created new unique vehicle #"..data.id..".")
		exports["vehicle-system"]:reloadVehicle(tonumber(data.id))
		local topicLink = createForumThread(getElementData(client, "account:username").." created unique vehicle #"..data.id, forumText)
		addVehicleLogs(tonumber(data.id), 'editveh: ' .. topicLink, client)
		return true
	else
		local mQuery1 = mysql:query_free("UPDATE `vehicles_custom` SET `brand`='"..toSQL(data["brand"]).."', `model`='"..toSQL(data["model"]).."', `year`='"..toSQL(data["year"]).."', `price`='"..toSQL(data["price"]).."', `tax`='"..toSQL(data["tax"]).."', `updatedby`='"..toSQL(getElementData(client, "account:id")).."', `notes`='"..toSQL(data["note"]).."', `updatedate`=NOW(), `doortype` = " .. data.doortype .. "  WHERE `id`='"..toSQL(data["id"]).."' ")
		if not mQuery1 then
			outputDebugString("VEHICLE MANAGER / VEHICLE LIB / createUniqueVehicle / DATABASE ERROR")
			outputChatBox("[VEHICLE MANAGER] Update unique vehicle #"..data.id.." failed.", client, 255,0,0)
			return false
		end
		
		outputChatBox("[VEHICLE MANAGER] You have updated unique vehicle #"..data.id..".", client, 0,255,0)
		exports.logs:dbLog(client, 6, { client }, " Updated unique vehicle #"..data.id..".")
		exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has updated unique vehicle #"..data.id..".")
		exports["vehicle-system"]:reloadVehicle(tonumber(data.id))
		local topicLink = createForumThread(getElementData(client, "account:username").." updated unique vehicle #"..data.id, forumText)
		addVehicleLogs(tonumber(data.id), 'editveh: ' .. topicLink, client)
		return true
	end
end
addEvent("vehlib:handling:createUniqueVehicle", true)
addEventHandler("vehlib:handling:createUniqueVehicle", getRootElement(), createUniqueVehicle)

function resetUniqueVehicle(vehID)
	if not vehID or not tonumber(vehID) then
		outputDebugString("VEHICLE MANAGER / resetUniqueVehicle / NO DATA RECIEVED FROM CLIENT")
		return false
	end
	
	local mQuery1 = mysql:query_free("DELETE FROM `vehicles_custom` WHERE `id`='"..toSQL(vehID).."' ")
	if not mQuery1 then
		outputDebugString("VEHICLE MANAGER / VEHICLE LIB / resetUniqueVehicle / DATABASE ERROR")
		outputChatBox("[VEHICLE MANAGER] Remove unique vehicle #"..vehID.." failed.", client, 255,0,0)
		return false
	end
	outputChatBox("[VEHICLE MANAGER] You have removed unique vehicle #"..vehID..".", client, 0,255,0)
	exports.logs:dbLog(client, 6, { client }, " Removed unique vehicle #"..vehID..".")
	exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has removed unique vehicle #"..vehID..".")
	exports["vehicle-system"]:reloadVehicle(tonumber(vehID))

	local vehicle = exports.pool:getElement("vehicle", tonumber(vehID))
	local forumText = [=[
		<b>Vehicle ID:   </b>]=] ..tostring(vehID) ..[=[<br>
		<b>Current Owner:   </b>]=] ..tostring(getVehicleOwner(vehicle)) ..[=[<br>
		<b>Edited by:   </b>]=] ..tostring(getElementData(client, "account:username")) ..[=[<br>]=]
	local topicLink = createForumThread(getElementData(client, "account:username").." reset unique vehicle #"..vehID, forumText)
	addVehicleLogs(tonumber(vehID), 'editveh reset: ' .. topicLink, client)
	return true
end
addEvent("vehlib:handling:resetUniqueVehicle", true)
addEventHandler("vehlib:handling:resetUniqueVehicle", getRootElement(), resetUniqueVehicle)

---HANDLINGS
function openUniqueHandling(vehdbid, existed)
	if exports.integration:isPlayerVehicleConsultant(client) or exports.integration:isPlayerSeniorAdmin(client) then
		local theVehicle = getPedOccupiedVehicle(client) or false
		if not theVehicle then
			outputChatBox( "You must be in a vehicle.", client, 255, 194, 14)
			return false
		end
		
		local vehID = getElementData(theVehicle, "dbid") or false
		if not vehID or vehID < 0 then	
			outputChatBox("This vehicle can not have custom properties.", client, 255, 194, 14)
			return false
		end
		
		if existed then
			local row = mysql:query_fetch_assoc("SELECT `handling` FROM `vehicles_custom` WHERE `id` = '" .. mysql:escape_string(vehdbid) .. "' LIMIT 1" ) or false
			if not row then
				outputChatBox( "[VEHICLE-MANAGER] Failed to retrieve current handlings from SQL.", client, 255, 194, 14)
				outputDebugString("VEHICLE MANAGER / openUniqueHandling / DATABASE ERROR")
				return false
			end
			triggerClientEvent(client, "veh-manager:handling:edithandling", client, 1)
		else
			triggerClientEvent(client, "veh-manager:handling:edithandling", client, 1)
		end
		
		return true
	end
end
addEvent("vehlib:handling:openUniqueHandling", true)
addEventHandler("vehlib:handling:openUniqueHandling", getRootElement(), openUniqueHandling)
