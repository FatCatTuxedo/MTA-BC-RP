--MAXIME
function sendCmdsHelpToClient(player, forceOpen)
	if player then
		client = player
	end
	local cmSQL = exports.mysql:query("SELECT * FROM `commands` ORDER BY `command`")
	local cmds = {}
	while true do
		local row = exports.mysql:fetch_assoc(cmSQL) or false 
		if not row then 
			break 
		end
		table.insert(cmds, row)
	end
	exports.mysql:free_result(cmSQL)
	triggerClientEvent(client, "getCmdsHelpFromServer", client, cmds, forceOpen)
end
addEvent("sendCmdsHelpToClient", true)
addEventHandler("sendCmdsHelpToClient", root, sendCmdsHelpToClient)

function toSQL(txt)
	return exports.global:toSQL(txt)
end

function saveCommand(cmd)
	if cmd[1] then 
		--outputDebugString("UPDATE `commands` SET `command`='"..toSQL(cmd[4]).."', `hotkey`='"..toSQL(cmd[5]).."', `explanation`='"..toSQL(cmd[6]).."' WHERE `id`='"..cmd[1].."' ")
		if exports.mysql:query_free("UPDATE `commands` SET `category`='"..toSQL(cmd[2]).."', `permission`='"..toSQL(cmd[3]).."', `command`='"..toSQL(cmd[4]).."', `hotkey`='"..toSQL(cmd[5]).."', `explanation`='"..toSQL(cmd[6]).."' WHERE `id`='"..cmd[1].."' ") then
			sendCmdsHelpToClient(client, true)
		end
	else
		if exports.mysql:query_free("INSERT INTO `commands` SET `category`='"..toSQL(cmd[2]).."', `permission`='"..toSQL(cmd[3]).."', `command`='"..toSQL(cmd[4]).."', `hotkey`='"..toSQL(cmd[5]).."', `explanation`='"..toSQL(cmd[6]).."' ") then
			sendCmdsHelpToClient(client, true)
		end
	end
end
addEvent("saveCommand", true)
addEventHandler("saveCommand", root, saveCommand)

function deleteCommand(id)
	if id then
		if exports.mysql:query_free("DELETE FROM `commands` WHERE `id`='"..id.."' ") then
			sendCmdsHelpToClient(client, true)
		end
	end
end
addEvent("deleteCommand", true)
addEventHandler("deleteCommand", root, deleteCommand)