--MAXIME
GUIEditor_Window = {}
GUIEditor_TabPanel = {}
GUIEditor_Tab = {}
GUIEditor_Button = {}
GUIEditor_Checkbox = {}
GUIEditor_Label = {}
local screenWidth, screenHeight = guiGetScreenSize()
settings = {}

function showSettingsWindow()
	closeSettingsWindow()
	
	if wOptions and isElement(wOptions) then
		guiSetEnabled(wOptions, false)
	else
		return false
	end
	
	if getElementData(getLocalPlayer(), "exclusiveGUI") or not isCameraOnPlayer()  then
		return false
	end
	
	setElementData(getLocalPlayer(), "exclusiveGUI", true, false)
	showCursor(true)
	
	local w, h = 740,474
	local x, y = (screenWidth-w)/2, (screenHeight-h)/2
	GUIEditor_Window.main = guiCreateWindow(x,y,w,h,"Game Settings",false)
	guiWindowSetSizable(GUIEditor_Window.main, false)
	GUIEditor_TabPanel.main = guiCreateTabPanel(0.0122,0.0401,0.9757,0.8692,true,GUIEditor_Window.main)
	GUIEditor_Tab.graphicSettings = guiCreateTab("Account Settings",GUIEditor_TabPanel.main)
	--GUIEditor_Tab.accSettings = guiCreateTab(" Settings",GUIEditor_TabPanel.main)
	GUIEditor_Tab.charSettings = guiCreateTab("Character Settings",GUIEditor_TabPanel.main)
	local lineH = 0.0515
	local posY = lineH
	
	GUIEditor_Label.graphicSettingsgeneral = guiCreateLabel(0.0222,0.0361,0.313,lineH,"General Configurations:",true,GUIEditor_Tab.graphicSettings)
	guiSetFont(GUIEditor_Label.graphicSettingsgeneral,"default-bold-small")

	GUIEditor_Checkbox.graphic_motionblur = guiCreateCheckBox(0.036,0.1005,0.2992,lineH,"Enable motion blur",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "graphic_motionblur") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,true)
	end
	
	GUIEditor_Checkbox.graphic_skyclouds = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable sky clouds",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "graphic_skyclouds") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_skyclouds,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_skyclouds,true)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.streams = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable streaming audio",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("carradio") then
		if getElementData(localPlayer, "streams") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.streams,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.streams,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.streams, false)
	end
	
	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_logs = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable client logging of chatbox",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("BoneCountyLogs") then
		if getElementData(localPlayer, "graphic_logs") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_logs,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_logs,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_logs, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.cellphone_log = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable client logging of calls & SMS",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("BoneCountyLogs") and getResourceFromName("phone") then
		if getElementData(localPlayer, "cellphone_log") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.cellphone_log,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.cellphone_log,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.cellphone_log, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_chatbub = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable chat bubbles",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("chat-system") then
		if getElementData(localPlayer, "graphic_chatbub") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_chatbub,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_chatbub,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_chatbub, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_typingicon = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable typing icons",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("chat-system") then
		if getElementData(localPlayer, "graphic_typingicon") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_typingicon,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_typingicon,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_typingicon, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_nametags = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable nametags",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("hud") then
		if getElementData(localPlayer, "graphic_nametags") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_nametags,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_nametags,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_nametags, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.settings_hud_style = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable new HUD style",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("hud") then
		if getElementData(localPlayer, "settings_hud_style") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.settings_hud_style,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.settings_hud_style,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.settings_hud_style, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_shaderradar = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable radar shader",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("shader_radar") then
		if getElementData(localPlayer, "graphic_shaderradar") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderradar,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderradar,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_shaderradar, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_shaderwater = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable water shader",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("shader_water") then
		if getElementData(localPlayer, "graphic_shaderwater") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderwater,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderwater,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_shaderwater, false)
	end
	posY = posY + lineH
	
	GUIEditor_Checkbox.graphic_shader_darker_night = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable shader darker night",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("dynamic_lighting") then
		if getElementData(localPlayer, "newnight") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shader_darker_night,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shader_darker_night,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_shader_darker_night, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.autopark = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable vehicle auto /park",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("vehicle-system") then
		if getElementData(localPlayer, "autopark") ~= "1" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.autopark,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.autopark,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.autopark, false)
	end

	posY = posY + lineH
	
	GUIEditor_Checkbox.antifalling = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable interior anti-falling",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("interior-system") then
		if getElementData(localPlayer, "antifalling") ~= "1" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.antifalling,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.antifalling,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.antifalling, false)
	end

	posY = posY + lineH

	-----------------------------------------------------------------------
	local lineW2 = 0.34
	local posX = lineW2
	posY = 0.1005
	GUIEditor_Checkbox.vehicle_hotkey = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable vehicle control hotkeys",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("vehicle-system") then
		if getElementData(localPlayer, "vehicle_hotkey") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_hotkey,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_hotkey,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.vehicle_hotkey, false)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.vehicle_rims = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable custom rim models",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("realism-system") then
		if getElementData(localPlayer, "vehicle_rims") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_rims,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_rims,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.vehicle_rims, false)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.text2speech_ic_chats = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable Local IC chats text2speech",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("text2speech") then
		if getElementData(localPlayer, "text2speech_ic_chats") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.text2speech_ic_chats,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.text2speech_ic_chats,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.text2speech_ic_chats, false)
	end

	-----------------------------------------------------------------------
	
	posX = posX + lineW2
	GUIEditor_Label.graphicSettings_desc = guiCreateLabel(0.0222+posX,0.0361,0.313,lineH,"Overlay Description Configurations:",true,GUIEditor_Tab.graphicSettings)
	guiSetFont(GUIEditor_Label.graphicSettings_desc,"default-bold-small")
	
	GUIEditor_Checkbox.enableOverlayDescription = guiCreateCheckBox(0.036+posX,0.1005,0.2992,lineH,"Toggle all overlay description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescription") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescription,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescription,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescription, false)
	end
	
	GUIEditor_Checkbox.enableOverlayDescriptionVeh = guiCreateCheckBox(0.036+posX,0.1005+lineH,0.2992,lineH,"Vehicle: Enable description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescriptionVeh") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionVeh,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionVeh,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescriptionVeh, false)
	end
	
	guiCreateLabel ( 0.036+posX,0.1005+lineH*2+0.005,0.2992,lineH ,  "Font:", true, GUIEditor_Tab.graphicSettings )
	cFontVeh = guiCreateComboBox ( 0.036+posX+0.055,0.1005+lineH*2,0.2,lineH,  getElementData(localPlayer, "cFontVeh") or "default", true, GUIEditor_Tab.graphicSettings )
	local count1 = 0 
	for key, font in pairs(fonts) do
		guiComboBoxAddItem(cFontVeh, type(font[1]) == "string" and font[1] or "BizNoteFont18")
		count1 = count1 + 1
	end
	guiComboBoxAdjustHeight ( cFontVeh, count1 )
	addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
		function ( comboBox )
			if ( comboBox == cFontVeh ) then
				local item = guiComboBoxGetSelected ( cFontVeh )
				local text = tostring ( guiComboBoxGetItemText ( cFontVeh , item ) )
				if ( text ~= "" ) then
					applyGameSettings("cFontVeh", text)
				end
			end
		end
	)
	
	GUIEditor_Checkbox.enableOverlayDescriptionPro = guiCreateCheckBox(0.036+posX,0.1005+lineH*3,0.2992,lineH,"Interior: Enable description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescriptionPro") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionPro,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionPro,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescriptionPro, false)
	end
	
	guiCreateLabel ( 0.036+posX,0.1005+lineH*4+0.005,0.2992,lineH ,  "Font:", true, GUIEditor_Tab.graphicSettings )
	cFontPro = guiCreateComboBox ( 0.036+posX+0.055,0.1005+lineH*4,0.2,lineH,  getElementData(localPlayer, "cFontPro") or "default", true, GUIEditor_Tab.graphicSettings )
	local count1 = 0 
	for key, font in pairs(fonts) do
		guiComboBoxAddItem(cFontPro, type(font[1]) == "string" and font[1] or "BizNoteFont18")
		count1 = count1 + 1
	end
	guiComboBoxAdjustHeight ( cFontPro, count1 )
	addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
		function ( comboBox )
			if ( comboBox == cFontPro ) then
				local item = guiComboBoxGetSelected ( cFontPro )
				local text = tostring ( guiComboBoxGetItemText ( cFontPro , item ) )
				if ( text ~= "" ) then
					applyGameSettings("cFontPro", text)
				end
			end
		end
	)
	
	---Character Settings------------------------------------------------------------------------------------------------------------
	local lineH = 0.0515
	local posY = lineH

	GUIEditor_Label.charSettingsgeneral = guiCreateLabel(0.0222,0.0361,0.313,lineH,"Character Configurations:",true,GUIEditor_Tab.charSettings)
	guiSetFont(GUIEditor_Label.charSettingsgeneral,"default-bold-small")

	GUIEditor_Checkbox.phone_anim = guiCreateCheckBox(0.036,0.1005,0.2992,lineH,"Enable phone animation",false,true,GUIEditor_Tab.charSettings)
	if getElementData(localPlayer, "phone_anim") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.phone_anim,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.phone_anim,true)
	end

	GUIEditor_Checkbox.talk_anim = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable /say animations",false,true,GUIEditor_Tab.charSettings)
	if not getElementData(localPlayer, "talk_anim") or getElementData(localPlayer, "talk_anim") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.talk_anim,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.talk_anim,true)
	end

	posY = posY + lineH
	--[[
	GUIEditor_Checkbox.graphic_motionblur = guiCreateCheckBox(0.036,0.1005,0.2992,lineH,"Enable vehicle auto /park",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "graphic_motionblur") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,true)
	end]]
	
	
	
	GUIEditor_Button.mainclose = guiCreateButton(0.0135,0.9135,0.9743,0.0675,"Close",true,GUIEditor_Window.main)
	addEventHandler("onClientGUIClick", GUIEditor_Window.main, options_updateGameSettings)
	--addEventHandler("onClientGUITabSwitched", GUIEditor_TabPanel.main, updateTabs)
end
addEvent("accounts:settings:fetchSettings", true)
addEventHandler("accounts:settings:fetchSettings", localPlayer, showSettingsWindow)

function updateTabs(selectedTab )
	--FETCH DATA
	if settings then
		for i, setting in pairs(settings) do
			
			if isElement(GUIEditor_Checkbox[setting[2]]) then
				guiCheckBoxSetSelected(GUIEditor_Checkbox[setting[2]],(setting[3] == "1"))
				--outputDebugString(setting[2].."-"..setting[3])
			end
		end
	else
		
	end
end

function closeSettingsWindow()
	if isElement(GUIEditor_Window.main) then
		removeEventHandler("onClientGUIClick", GUIEditor_Window.main, options_updateGameSettings)
		removeEventHandler("onClientGUITabSwitched", GUIEditor_TabPanel.main, updateTabs)
		destroyElement(GUIEditor_Window.main)
		GUIEditor_Window.main = nil
	end
	
	if wOptions and isElement(wOptions) then
		guiSetEnabled(wOptions, true)
	end
	setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
	exports.BoneCountyLogs:closeInfoBox()
end

function options_updateGameSettings()
	if source == GUIEditor_Button.mainclose then
		closeSettingsWindow()
	elseif source == GUIEditor_Checkbox.graphic_motionblur then
		local name, value = "graphic_motionblur", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_motionblur ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_skyclouds then
		local name, value = "graphic_skyclouds", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_skyclouds ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.streams then
		local name, value = "streams", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.streams ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_nametags then
		local name, value = "graphic_nametags", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_nametags ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.settings_hud_style then
		local name, value = "settings_hud_style", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.settings_hud_style ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_logs then
		local name, value = "graphic_logs", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_logs ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_chatbub then
		local name, value = "graphic_chatbub", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_chatbub ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_typingicon then
		local name, value = "graphic_typingicon", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_typingicon ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_shaderradar then
		local name, value = "graphic_shaderradar", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderradar ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_shaderwater then
		local name, value = "graphic_shaderwater", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderwater ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_shaderveh then
		local name, value = "graphic_shaderveh", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderveh ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_shaderveh_reflect then
		local name, value = "graphic_shaderveh_reflect", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderveh_reflect ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.graphic_shader_darker_night then
		local name, value = "newnight", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shader_darker_night ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.enableOverlayDescription then
		local name, value = "enableOverlayDescription", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescription ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.enableOverlayDescriptionVeh then
		local name, value = "enableOverlayDescriptionVeh", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescriptionVeh ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.enableOverlayDescriptionPro then
		local name, value = "enableOverlayDescriptionPro", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescriptionPro ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.autopark then
		local name, value = "autopark", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.autopark ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.antifalling then
		local name, value = "antifalling", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.antifalling ) then
			value = "1"
		end
		updateAccountSettings(name, value)	
	elseif source == GUIEditor_Checkbox.vehicle_hotkey then
		local name, value = "vehicle_hotkey", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.vehicle_hotkey ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.vehicle_rims then
		local name, value = "vehicle_rims", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.vehicle_rims ) then
			value = "1"
		end
		updateAccountSettings(name, value)
		triggerEvent("vehicle_rims", getRootElement(), value)
	elseif source == GUIEditor_Checkbox.text2speech_ic_chats then
		local name, value = "text2speech_ic_chats", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.text2speech_ic_chats ) then
			value = "1"
		end
		updateAccountSettings(name, value)
		triggerEvent("text2speech_ic_chats", getRootElement(), value)
	elseif source == GUIEditor_Checkbox.phone_anim then
		local name, value = "phone_anim", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.phone_anim ) then
			value = "1"
		end
		updateCharacterSettings(name, value)
	elseif source == GUIEditor_Checkbox.cellphone_log then
		local name, value = "cellphone_log", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.cellphone_log ) then
			value = "1"
			exports.BoneCountyLogs:drawInfoBox()
		end
	elseif source == GUIEditor_Checkbox.talk_anim then
		local name, value = "talk_anim", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.talk_anim ) then
			value = "1"
		end
		updateAccountSettings(name, value)		
	end
end

function applyGameSettings(name, value)
	if name and value then
		if name == "duty_admin" or name == "duty_supporter" or name == "duty_script" or name == "wrn:style" then
			value = tonumber(value) or value
		end
		setElementData(localPlayer, name, value)
		outputDebugString("applyAccountSettings".." "..name.." "..value)
		if name == "graphic_motionblur" then
			if (value == "0") then
				setBlurLevel(0)
			else
				setBlurLevel(40)
			end
			--setElementData(localPlayer, name, value, false)
		elseif name == "graphic_skyclouds" then
			if (value == "0") then
				setCloudsEnabled ( false )
			else
				setCloudsEnabled ( true )
			end
			--setElementData(localPlayer, name, value, false)
		elseif name == "streams" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:updateCarRadio", localPlayer)
		--[[elseif name == "graphic_chatbub" then
			setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:updateChatBubbleState", localPlayer)]]
		elseif name == "graphic_typingicon" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_typingicon", localPlayer)
		elseif name == "graphic_shaderradar" then
			--setElementData(localPlayer, name, value, false)
			--triggerEvent("accounts:settings:graphic_shaderradar", localPlayer)
		elseif name == "graphic_shaderwater" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_shaderwater", localPlayer)
		elseif name == "graphic_shaderveh" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_shaderveh", localPlayer)
		elseif name == "graphic_shaderveh_reflect" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_shaderveh_reflect", localPlayer)
		elseif name == "nightnew" then
			setElementData(localPlayer, name, value, false)
		end
	end
end
addEvent("accounts:settings:applyGameSettings", true)
addEventHandler("accounts:settings:applyGameSettings", localPlayer, applyGameSettings)

function updateAccountSettings(name, value)
	applyGameSettings(name, value)
	triggerServerEvent("saveClientAccountSettingsOnServer", localPlayer, name, value)
end
addEvent("accounts:settings:updateAccountSettings", true)
addEventHandler("accounts:settings:updateAccountSettings", localPlayer, updateAccountSettings)

function applyCharacterSettings(name, value)
	if name and value then
		setElementData(localPlayer, name, value)
		outputDebugString("applyCharacterSettings".." "..name.." "..value)
		if name == "head_turning" then
			triggerEvent("realism:updateLookAt", localPlayer)
		end
	end
end
addEvent("accounts:settings:applyCharacterSettings", true)
addEventHandler("accounts:settings:applyCharacterSettings", localPlayer, applyCharacterSettings)

function updateCharacterSettings(name, value)
	applyCharacterSettings(name, value)
	triggerServerEvent("saveClientCharacterSettingsOnServer", localPlayer, name, value)
end
addEvent("accounts:settings:updateCharacterSettings", true)
addEventHandler("accounts:settings:updateCharacterSettings", localPlayer, updateCharacterSettings)

function loadAccountSettings(settingsFromServer) 
	if settingsFromServer then
		for i = 1, #settingsFromServer do
			if settingsFromServer[i][1] and settingsFromServer[i][2] then
				applyGameSettings(settingsFromServer[i][1], settingsFromServer[i][2])
			end
		end
	end
end
addEvent("accounts:settings:loadAccountSettings", true)
addEventHandler("accounts:settings:loadAccountSettings", localPlayer, loadAccountSettings)


function loadCharacterSettings(settingsFromServer) 
	if settingsFromServer then
		for i = 1, #settingsFromServer do
			if settingsFromServer[i][1] and settingsFromServer[i][2] then
				applyCharacterSettings(settingsFromServer[i][1], settingsFromServer[i][2])
			end
		end
	end
end
addEvent("accounts:settings:loadCharacterSettings", true)
addEventHandler("accounts:settings:loadCharacterSettings", localPlayer, loadCharacterSettings)

function cleanUp()
	setElementData(localPlayer, "exclusiveGUI", false, false)
end
addEventHandler("onClientResourceStart", resourceRoot, cleanUp)