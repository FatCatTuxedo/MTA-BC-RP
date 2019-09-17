function dxDrawImage3D(x,y,z,w,h,m,c,r,...)
        local lx, ly, lz = x+w, y+h, (z+tonumber(r or 0)) or z
    return dxDrawMaterialLine3D(x,y,z, lx, ly, lz, m, h, c , ...)
end

local webBrowser = createBrowser(800, 600, false, false)

local cinemaVolume = getElementData(getLocalPlayer(), "cinema:volume") or 0.4

function webBrowserRender()
	local x, y = 1065, -1110.49
	setBrowserVolume(webBrowser, cinemaVolume)
	dxDrawMaterialLine3D(x, y, 2003, x, y, 1999, webBrowser, 9.4, tocolor(255, 255, 255, 255), x, y-180, 19)
end

function showBrowser()
	addEventHandler("onClientPreRender", root, webBrowserRender)
end
addEvent("cinema:show", true)
addEventHandler("cinema:show", getRootElement(), showBrowser)

function loadURL(link)
	loadBrowserURL(webBrowser, link)
end
addEvent("cinema:loadLink", true)
addEventHandler("cinema:loadLink", getRootElement(), loadURL)

function destroyBrowser()
	loadBrowserURL(webBrowser, "https://google.com/?t=1")
	removeEventHandler("onClientPreRender", root, webBrowserRender)
	setBrowserVolume(webBrowser, 0)
end
addEvent("cinema:destroyBrowser", true)
addEventHandler("cinema:destroyBrowser", getRootElement(), destroyBrowser)

function setVolume(commandname, val)
	if tonumber(val) then
		val = tonumber(val)
		if (val >= 0 and val <= 100) then
			val = val / 100
			setElementData ( getLocalPlayer(), "cinema:volume", val)
			cinemaVolume = val
			percent = val * 100
			outputChatBox ( "Cinema volume changed to: "..percent, 255, 0, 0, false )
			return
		end
	end
	outputChatBox ( "* ERROR: /cinvol 0 - 100", 255, 0, 0, false )
end
addCommandHandler("cinvol", setVolume)

local cinemaGUI = { }
local sw, sh = guiGetScreenSize()

function showGUI ()
	if not cinemaGUI["window"] then
		local width = 400
		local height = 119
		local x = ( sw - width ) / 2
		local y = ( sh - height ) / 2
		
		cinemaGUI["window"] = guiCreateWindow ( x, y, width, height, "Change YouTube Video", false )
		cinemaGUI["vid_id"] = guiCreateEdit ( 10, 25, 379, 25, "RgKAFK5djSk", false, cinemaGUI["window"] )
		cinemaGUI["save"] = guiCreateButton ( 10, 55, 379, 25, "Play", false, cinemaGUI["window"] )
		cinemaGUI["cancel"] = guiCreateButton ( 10, 85, 379, 25, "Cancel", false, cinemaGUI["window"] )
		
		guiWindowSetSizable ( cinemaGUI["window"], false )
		guiSetInputEnabled ( true )
		
		addEventHandler ( "onClientGUIClick", cinemaGUI["window"], CinemaButtonClick )
	else
		hideGUI()
	end
end
addEvent ("cinema:showGUI", true)
addEventHandler("cinema:showGUI", getRootElement(), showGUI)

function CinemaButtonClick(button, state)
	if button == "left" and state == "up" then
		if source == cinemaGUI["save"] then
			local id = guiGetText (cinemaGUI["vid_id"])
			triggerServerEvent("cinema:loadVideo", getLocalPlayer(), id)
			hideGUI()
		elseif source == cinemaGUI["vid_id"] then
			local vid_id = guiGetText(source)
			if vid_id == "RgKAFK5djSk" then
				guiSetText(source, "")
			end
		elseif source == cinemaGUI["cancel"] then
			hideGUI()
		end
	end
end

function hideGUI ( )
	if cinemaGUI["window"] then
		destroyElement (cinemaGUI["window"])
		cinemaGUI["window"] = nil
		guiSetInputEnabled (false)
	end
end

local OptionMenu = nil
local element = nil
function popupGuardPedMenu(e)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if not OptionMenu then
		local width, height = 150, 80
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		OptionMenu = guiCreateWindow(x, y, width, height, "How can I help you?", false)
		element = e
		bHelp = guiCreateButton(0.05, 0.3, 0.87, 0.25, "I need help", true, OptionMenu)
		addEventHandler("onClientGUIClick", bHelp, helpButtonFunction, false)
		bClose = guiCreateButton(0.05, 0.7, 0.87, 0.25, "Nevermind.", true, OptionMenu)
		addEventHandler("onClientGUIClick", bClose, closePedMenu, false)
		triggerServerEvent("astro:ped:start", getLocalPlayer(), getElementData(element, "rpp.npc.name"))
		showCursor(true)
	end
end
addEvent("astroguardGUI", true)
addEventHandler("astroguardGUI", getRootElement(), popupGuardPedMenu)

function closePedMenu()
	destroyElement(OptionMenu)
	OptionMenu = nil
	showCursor(false)
end

function helpButtonFunction()
	closePedMenu()
	triggerServerEvent("astro:ped:help", getLocalPlayer(), element, getElementData(element, "rpp.npc.name"))
end

local eOptionMenu = nil
local eElement = nil
function popupEnterPedMenu(e)
	if (getElementData(getPedOccupiedVehicle(getLocalPlayer()), "vehicle:windowstat") == 0) then
		outputChatBox ( "Roll your windows down if you want to talk...", 255, 0, 0, false )
		return
	end
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if not eOptionMenu then
		local width, height = 200, 80
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		eOptionMenu = guiCreateWindow(x, y, width, height, "Would you like to pass?", false)
		eElement = e
		bPay = guiCreateButton(0.05, 0.3, 0.87, 0.25, "Yes (( Pay $10 ))", true, eOptionMenu)
		addEventHandler("onClientGUIClick", bPay, payButtonFunction, false)
		bNo = guiCreateButton(0.05, 0.7, 0.87, 0.25, "No.", true, eOptionMenu)
		addEventHandler("onClientGUIClick", bNo, closePayMenu, false)
		triggerServerEvent("astro:pay:start", getLocalPlayer(), getElementData(eElement, "rpp.npc.name"))
		showCursor(true)
	end
end
addEvent("astropayGUI", true)
addEventHandler("astropayGUI", getRootElement(), popupEnterPedMenu)

function closePayMenu()
	destroyElement(eOptionMenu)
	eOptionMenu = nil
	showCursor(false)
end

function payButtonFunction()
	closePayMenu()
	triggerServerEvent("astro:ped:pay", getLocalPlayer(), eElement, getElementData(eElement, "rpp.npc.name"))
end