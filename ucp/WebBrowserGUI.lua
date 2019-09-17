WebBrowserGUI = {}
WebBrowserGUI.instance = nil
function WebBrowserGUI:new() local o=setmetatable({},{__index=WebBrowserGUI}) o:constructor() return o end

function WebBrowserGUI:constructor()
	local sizeX, sizeY = 0.75, 0.75
	self.m_Window = GuiWindow(0, 0, sizeX, sizeY, "User Control Panel", true)
	exports.global:centerWindow(self.m_Window)
	self.m_Window:setSizable(false)
	self.m_ButtonClose = GuiButton(0.25, 0.9, 0.5, 0.1, "Exit", true, self.m_Window)
	self.m_ButtonClose:setProperty("NormalTextColour", "FFFF2929")
	self.m_ButtonClose:setProperty("HoverTextColour", "FF990909")
	self.m_ButtonClose:setFont("default-bold-small")
	
	self.m_Browser = GuiBrowser(0, 0.05, 1, 0.85, false, false, true, self.m_Window)
	
	local browser = self.m_Browser:getBrowser()
	addEventHandler("onClientBrowserCreated", browser, function(...) self:Browser_Created(...) end)
	addEventHandler("onClientBrowserNavigate", browser, function(...) self:Browser_Navigate(...) end)
	addEventHandler("onClientBrowserWhitelistChange", root, function(...) self:Browser_WhitelistChange(...) end)

	self.m_RequestedURL = ""
	
	showCursor(true)
	guiSetInputEnabled(true)
end

function WebBrowserGUI:Browser_Created()
	addEventHandler("onClientGUIClick", self.m_ButtonClose, function(...) self:CloseButton_Click(...) end, false)

	self:loadURL("https://projectreality.site/ucp")
end

function WebBrowserGUI:Browser_Navigate(targetURL, isBlocked)
	if isBlocked then
		self.m_RequestedURL = targetURL
		Browser.requestDomains({targetURL}, true)
		return
	end
end

function WebBrowserGUI:Browser_WhitelistChange(whitelistedURLs)
	for i, v in pairs(whitelistedURLs) do
		if self.m_RequestedURL:find(v) then
			self.m_Browser:getBrowser():loadURL(self.m_RequestedURL)
			self.m_RequestedURL = ""
		end
	end
end

function WebBrowserGUI:CloseButton_Click(button, state)
	if button == "left" and state == "up" then
		self.m_Window:destroy()
		showCursor(false)
		guiSetInputEnabled(false)
		WebBrowserGUI.instance = nil
	end
end
-- \\ GUI Navigation

function WebBrowserGUI:loadURL(url)
	if url == "" then
		self.m_Browser:getBrowser():loadURL("about:blank")
		return
	elseif url:sub(0, 6)  == "about:" then
		self.m_Browser:getBrowser():loadURL(url)
		return
	elseif url:sub(0, 7)  ~= "http://" and url:sub(0, 8) ~= "https://" then
		url = "http://"..url	
	end
	
	if Browser.isDomainBlocked(url, true) then
		self.m_RequestedURL = url
		Browser.requestDomains({url}, true)
		return
	end
	
	self.m_Browser:getBrowser():loadURL(url)
end