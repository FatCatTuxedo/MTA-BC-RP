addEvent("fadeCameraOnSpawn", true)
addEventHandler("fadeCameraOnSpawn", getLocalPlayer(),
	function()
		start = getTickCount()
	end
)
local bRespawn = nil
function showRespawnButton(victimDropItem)
	showCursor(true)
	local width, height = 201,54
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/1.1 - (height/2)
	bRespawn = guiCreateButton(x, y, width, height,"Respawn",false)
		guiSetFont(bRespawn,"sa-header")
	addEventHandler("onClientGUIClick", bRespawn, function () 
		if bRespawn then
			destroyElement(bRespawn)
			bRespawn = nil
			showCursor(false)
			guiSetInputEnabled(false)
		end
		triggerServerEvent("es-system:acceptDeath", getLocalPlayer(), getLocalPlayer(), victimDropItem)
		showCursor(false)
	end, false)
end
addEvent("es-system:showRespawnButton", true)
addEventHandler("es-system:showRespawnButton", getLocalPlayer(),showRespawnButton)

function closeRespawnButton()
	if bRespawn then
		destroyElement(bRespawn)
		bRespawn = nil
		showCursor(false)
		guiSetInputEnabled(false)
	end
end
addEvent("es-system:closeRespawnButton", true)
addEventHandler("es-system:closeRespawnButton", getLocalPlayer(),closeRespawnButton)