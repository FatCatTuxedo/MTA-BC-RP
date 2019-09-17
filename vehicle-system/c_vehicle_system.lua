local gui = {}

function build_SaleGUI()

	if gui["_root"] and isElement(gui["_root"]) then destroyElement(gui["_root"]) end
	
	guiSetInputMode("no_binds_when_editing")
	showCursor(true)
	
	gui._placeHolders = {}
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 400, 252
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Department of Motor Vehicles", false)
	guiWindowSetSizable(gui["_root"], false)
	
	gui["label"] = guiCreateLabel(170, 25, 70, 45, "Vehicle Sale", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")
	
	gui["label_2"] = guiCreateLabel(30, 75, 331, 21, "By signing this document, I agree to grant all ownership", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")

	gui["label_3"] = guiCreateLabel(30, 95, 331, 21, "rights of this motor vehicle to this mentioned person.", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_3"], "left", false)
	guiLabelSetVerticalAlign(gui["label_3"], "center")
	
	gui["lineEdit"] = guiCreateEdit(30, 155, 231, 21, "", false, gui["_root"])
	guiEditSetMaxLength(gui["lineEdit"], 32767)
	
	gui["label_4"] = guiCreateLabel(30, 135, 150, 16, "New owner's name", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_4"], "left", false)
	guiLabelSetVerticalAlign(gui["label_4"], "center")
	
	gui["pushButton"] = guiCreateButton(180, 195, 91, 31, "Sell", false, gui["_root"])	
	addEventHandler("onClientGUIClick", gui["pushButton"], function ()
			triggerServerEvent("sellVehicle", getResourceRootElement(), localPlayer, "sell", guiGetText(gui["lineEdit"]))
		end, false)

	
	gui["pushButton_2"] = guiCreateButton(290, 195, 91, 31, "Close", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton_2"], function ()
			destroyElement(gui["_root"])
			showCursor(false)
			guiSetInputMode("allow_binds")
		end, false)
	
	return gui, windowWidth, windowHeight
end
addEvent("build_carsale_gui", true)
addEventHandler("build_carsale_gui", localPlayer, build_SaleGUI)
--addCommandHandler("sell", build_SaleGUI)
