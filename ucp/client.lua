screenWidth, screenHeight = guiGetScreenSize()
requestBrowserDomains({"projectreality.site","fonts.gstatic.com", "fonts.googleapis.com"})

function showBrowser()
	if WebBrowserGUI.instance ~= nil then return end
	WebBrowserGUI.instance = WebBrowserGUI:new()
end

function openNCIC()
	showBrowser()
end
addCommandHandler ( "ucp", openNCIC )
addCommandHandler ( "scp", openNCIC )