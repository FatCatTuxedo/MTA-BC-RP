local mysql = exports.mysql

function refreshPdCodes()
   local content = {}
   content.codes = mysql:query_fetch_assoc("SELECT `value` FROM `settings` WHERE `name`='pdcodes' ")["value"]
   content.procedures = mysql:query_fetch_assoc("SELECT `value` FROM `settings` WHERE `name`='pdprocedures' ")["value"]
   triggerClientEvent(client, "displayPdCodes", client, content)
end
addEvent("refreshPdCodes", true)
addEventHandler("refreshPdCodes", root, refreshPdCodes)

function updatePdCodes(contentFromClient)
	if contentFromClient then
		if contentFromClient.codes then
			if mysql:query_free("UPDATE `settings` SET `value`= '"..exports.global:toSQL(contentFromClient.codes).."' WHERE `name`='pdcodes' ") then
				outputChatBox("Codes saved successfully!", client)
			end
		end
		if contentFromClient.procedures then
			if mysql:query_free("UPDATE `settings` SET `value`= '"..exports.global:toSQL(contentFromClient.procedures).."' WHERE `name`='pdprocedures' ") then
				outputChatBox("Procedures saved successfully!", client)
			end
		end
	end
end
addEvent("updatePdCodes", true)
addEventHandler("updatePdCodes", getRootElement(), updatePdCodes)