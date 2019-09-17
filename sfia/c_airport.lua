local pedDialogWindow

local thePed
function pedDialog_FAA(ped)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	thePed = ped
	local width, height = 250, 135
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	pedDialogWindow = guiCreateWindow(x, y, width, height, "FAA Receptionist", false)

	b1 = guiCreateButton(10, 30, width-20, 20, "I want to leave a message", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b1, pedDialog_FAA_leaveMessage, false)

	b2 = guiCreateButton(10, 55, width-20, 20, "What licenses are registered on me?", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b2, pedDialog_FAA_myInfo, false)
	
	b3 = guiCreateButton(10, 80, width-20, 20, "I want a pilot license", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b3, pedDialog_FAA_wantLicense, false)

	b4 = guiCreateButton(10, 105, width-20, 20, "No thanks, I'm just looking", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b4, endDialog, false)

	--showCursor(true)

	triggerServerEvent("airport:ped:outputchat", getResourceRootElement(), thePed, "local", "Welcome to the FAA reception. Can I help you?")
end
addEvent("airport:ped:receptionistFAA", true)
addEventHandler("airport:ped:receptionistFAA", getRootElement(), pedDialog_FAA)

function endDialog()
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
		pedDialogWindow = nil
	end
end

function pedDialog_FAA_myInfo()
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	local width, height = 200, 250
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	pedDialogWindow = guiCreateWindow(x, y, width, height, "FAA Receptionist - My Licenses", false)

	myInfoGridlist = guiCreateGridList(10, 30, width-20, height-65, false, pedDialogWindow)

	b1 = guiCreateButton(10, (height-65)+35, width-20, 20, "Close", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b1, endDialog, false)

	triggerServerEvent("airport:getLicenses", getResourceRootElement(), thePed)
end

function pedDialog_FAA_myInfoCallback(licenses)
	if pedDialogWindow and isElement(pedDialogWindow) and myInfoGridlist and isElement(myInfoGridlist) then
		if #licenses > 0 then
			local column = guiGridListAddColumn(myInfoGridlist, "License", 0.9)
			for k,v in ipairs(licenses) do
				local row = guiGridListAddRow(myInfoGridlist)
				guiGridListSetItemText(myInfoGridlist, row, column, tostring(v[3]), false, false)
			end
		else
			local column = guiGridListAddColumn(myInfoGridlist, "You have no pilot licenses", 0.9)
		end
	end
end
addEvent("airport:getLicensesCallback", true)
addEventHandler("airport:getLicensesCallback", getResourceRootElement(), pedDialog_FAA_myInfoCallback)

function pedDialog_FAA_leaveMessage()
	guiSetInputMode("no_binds_when_editing")
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	local width, height = 300, 150
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	pedDialogWindow = guiCreateWindow(x, y, width, height, "FAA Receptionist - Leave Message", false)

	leaveMessageMemo = guiCreateMemo(10, 30, width-20, height-90, "", false, pedDialogWindow)

	b1 = guiCreateButton(10, (height-90)+35, width-20, 20, "Leave Message", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b1, pedDialog_FAA_leaveMessage_send, false)

	b2 = guiCreateButton(10, (height-90)+60, width-20, 20, "Close", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b2, endDialog, false)
end

function pedDialog_FAA_leaveMessage_send()
	if pedDialogWindow and isElement(pedDialogWindow) and leaveMessageMemo and isElement(leaveMessageMemo) then
		local message = guiGetText(leaveMessageMemo)
		if message and string.len(message) > 5 then
			destroyElement(pedDialogWindow)
			pedDialogWindow = nil
			triggerServerEvent("airport:ped:receptionistFAA:sendMessage", getResourceRootElement(), thePed, message)
		end
	end
	guiSetInputMode("allow_binds")
end

function pedDialog_FAA_wantLicense()
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	local width, height = 400, 160
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	pedDialogWindow = guiCreateWindow(x, y, width, height, "FAA Receptionist - Flight School Info", false)

	local label1 = guiCreateLabel(10, 30, width-20, 40, "You can apply to the flight school at our websites.\nYou'll also find more information there.", false, pedDialogWindow)

	local label2 = guiCreateLabel(10, 70, width-20, 20, "(( Copy the following URL and paste it into your browser:", false, pedDialogWindow)

	local edit1 = guiCreateEdit(10, 90, width-20, 20, "http://forums.owlgaming.net/showthread.php?9645#post62036", false, pedDialogWindow)
		guiEditSetReadOnly(edit1, true)

	local label3 = guiCreateLabel(10, 110, width-20, 20, "))", false, pedDialogWindow)

	b1 = guiCreateButton(10, 130, width-20, 20, "OK", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b1, endDialog, false)
end