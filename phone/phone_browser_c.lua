--MAXIMEs
function drawBrowser(xoffset, yoffset)
	if not isPhoneGUICreated() then
		return false
	end

	if not xoffset then xoffset = 0 end
	if not yoffset then yoffset = 0 end

	if webBrowser and isElement(webBrowser) then
		return false
		--destroyElement(wHotlines)
	end

	webBrowser = guiCreateBrowser(30+xoffset, 100+yoffset, 230, 370, false, false, false, wPhoneMenu)
	loadBrowserURL(guiGetBrowser(webBrowser), "http://youtube.com")
	return webBrowser
end

function toggleBrowser(state)
	if webBrowser and isElement(webBrowser) then
		guiSetVisible(webBrowser, state)
	else
		if state then
			drawBrowser()
		end
	end
end
