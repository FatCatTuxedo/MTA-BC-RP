screenWidth, screenHeight = guiGetScreenSize()
requestBrowserDomains({"projectreality.site"})

function showBrowser()
	if WebBrowserGUI.instance ~= nil then return end
	WebBrowserGUI.instance = WebBrowserGUI:new()
end

function canUseNCIC()
	if isPedInVehicle( getLocalPlayer() ) then
		local vehicle = getPedOccupiedVehicle( getLocalPlayer() )
		local vehicleFaction = tonumber(getElementData(vehicle, "faction"))
		if vehicleFaction == 1 or vehicleFaction == 50 then
			return true
		end
		if exports.global:hasItem(vehicle, 143) then
			return true
		end
	end
	if exports.global:hasItem(getLocalPlayer(), 143) or exports.global:hasItem(getLocalPlayer(), 96) then
		return true
	end
	return false
end

function openNCIC()
	if canUseNCIC() then
		showBrowser()
	else
		outputChatBox( "You do not have anything to access the NCIC on.", 255, 155, 155 )
	end
end
addCommandHandler ( "ncic", openNCIC )
addCommandHandler ( "mdc", openNCIC )