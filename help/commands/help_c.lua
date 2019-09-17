--MAXIME
local myWindow = nil
local loading = nil
local tab, grid, col = {}, {}, {}
local currentCate = "Chat"
function bindKeys()
	bindKey("F1", "down", F1RPhelp)
	triggerServerEvent("sendCmdsHelpToClient", localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, bindKeys)

local cmds = {}
function getCmdsHelpFromServer(cmds1, forceOpen)
	if cmds1 and type(cmds1) == "table" then
		cmds = cmds1
	end
	if forceOpen then
		F1RPhelp()
	end
end
addEvent("getCmdsHelpFromServer", true)
addEventHandler("getCmdsHelpFromServer", root, getCmdsHelpFromServer)

local categories = {
	[1] = "Chat",
	[2] = "Factions",
	[3] = "Vehicles",
	[4] = "Properties",
	[5] = "Items",
	[6] = "Jobs",
	[7] = "Misc",
}

function getCateIDFromName(name)
	for i, cate in pairs(categories) do
		if cate == name then
			return i
		end
	end
	return 1
end

local perms = {
	[0] = "Player",
	[1] = "Trial Admin",
	[2] = "Admin",
	[3] = "Senior Admin",
	[4] = "Lead Admin",
	[11] = "Helper",
	[21] = "Vehicle Access",
	[31] = "Mapper",
	[41] = "Developer",
}

function getPermIDFromName(name)
	for i, perm in pairs(perms) do
		if perm == name then
			return i
		end
	end
	return 0
end

function F1RPhelp( key, keyState )
	if not myWindow then
		showCursor( true )
		local xmlExplained = xmlLoadFile( "commands/whatisroleplaying.xml" )
		local xmlOverview = xmlLoadFile( "commands/overview.xml" )
		local xmlRules = xmlLoadFile( "commands/rules.xml" )

		myWindow = guiCreateWindow ( 0, 0, 800, 600, "Bone County Roleplay - Help", false )
		exports.global:centerWindow(myWindow)
		guiWindowSetSizable(myWindow, false)
		local tabPanel = guiCreateTabPanel ( 0, 0.04, 1, 1, true, myWindow )

		--[[local tabPatchNotes = guiCreateTab( "MTA Patch Notes & Information", tabPanel )
		local memoPatchNotes = guiCreateMemo (  0.02, 0.02, 0.96, 0.96, getElementData(getResourceRootElement(getResourceFromName("account-system")), "patchnotes:text") or "Error fetching patch notes...", true, tabPatchNotes )
		guiMemoSetReadOnly(memoPatchNotes, true)
		]]
		local tabRules = guiCreateTab( "Server Rules and Roleplay Overview", tabPanel )
		--[[local memoRules = guiCreateMemo (  0.02, 0.02, 0.96, 0.96, getElementData(getResourceRootElement(getResourceFromName("account-system")), "rules:text") or "Error fetching rules...", true, tabRules )
		guiMemoSetReadOnly(memoRules, true)]]
		local memoRules = guiCreateMemo ( 0.02, 0.02, 0.96, 0.96, xmlNodeGetValue( xmlRules  ), true, tabRules )
		guiMemoSetReadOnly(memoRules, true)

		xmlUnloadFile( xmlRules )

		local tabCommands = guiCreateTab( "Commands & Controls Help", tabPanel )
		local tabCommands2, newCmdBtn = nil, nil

		if canEditCmds() then
			tabCommands2 = guiCreateTabPanel ( 0, 0, 1, 0.95, true, tabCommands )
			newCmdBtn = guiCreateButton(0, 0.95, 1 , 0.05, "Create a new command",true,tabCommands)
			guiSetFont(newCmdBtn, "default-bold-small")
			addEventHandler("onClientGUIClick", newCmdBtn, function()
				if source == newCmdBtn then
					openNewCommand()
				end
			end)
		else
			tabCommands2 = guiCreateTabPanel ( 0, 0, 1, 1, true, tabCommands )
		end

		for i, cateName in ipairs(categories) do
			tab[i] = guiCreateTab( cateName, tabCommands2 )
		end

		addEventHandler("onClientGUITabSwitched", root, tabSwitch)

		for category = 1, 7 do
			grid[category] = guiCreateGridList(0, 0, 1, 1, true, tab[category])
			col[category] = {}
			col[category][1] = guiGridListAddColumn (grid[category], "ID", 0.06)
			col[category][2] = guiGridListAddColumn (grid[category], "Command", 0.15)
			col[category][3] = guiGridListAddColumn (grid[category], "Hotkey", 0.15)
			col[category][4] = guiGridListAddColumn (grid[category], "Explanation", 0.5)
			col[category][5] = guiGridListAddColumn (grid[category], "Permission", 0.1)
			if canEditCmds() then
				addEventHandler( "onClientGUIDoubleClick", grid[category],
					function( button )
						if button == "left" then
							local row, col = -1, -1
							local row, col = guiGridListGetSelectedItem(grid[category])
							if row ~= -1 and col ~= -1 then
								local id = guiGridListGetItemText( grid[category] , row, 1 )
								local cmd = guiGridListGetItemText( grid[category] , row, 2 )
								local key = guiGridListGetItemText( grid[category] , row, 3 )
								local ex = guiGridListGetItemText( grid[category] , row, 4 )
								local perm = guiGridListGetItemText( grid[category] , row, 5 )
								openNewCommand(id, perm, cmd, key, ex)
							else
								exports.global:playSoundError()
							end
						end
					end,
				false)
			end
		end
		updateCmdList()
	else
		if loading then
			updateCmdList()
			loading = nil
		else
			closeF1RPhelp()
		end
	end
end
addEvent("viewF1Help", true)
addEventHandler("viewF1Help", getRootElement(), F1RPhelp)

function updateCmdList()
	for i, cateName in ipairs(categories) do
		guiGridListClear(grid[i])
	end

	for i, cmd in ipairs(cmds) do
		local canAccess, requiredRank = getCmdPerms(tonumber(cmd["permission"]))
		if canAccess or exports.integration:isPlayerScripter(localPlayer) then
			local category = tonumber(cmd["category"]) or 0
			local row = guiGridListAddRow ( grid[category] )
			guiGridListSetItemText ( grid[category], row, 1, cmd["id"], false, true)
			guiGridListSetItemText ( grid[category], row, 2, cmd["command"], false, false)
			guiGridListSetItemText ( grid[category], row, 3, cmd["hotkey"] or "N/A", false, false)
			guiGridListSetItemText ( grid[category], row, 4, cmd["explanation"] or "N/A", false, false)
			guiGridListSetItemText ( grid[category], row, 5, requiredRank , false, false)
		end
	end
end

function togF1Menu(state)
	if myWindow and isElement(myWindow) then
		guiSetEnabled(myWindow, state)
	end
end

function closeF1RPhelp()
	if myWindow and isElement(myWindow) and not loading then
		removeEventHandler("onClientGUITabSwitched", root, tabSwitch)
		destroyElement(myWindow)
		myWindow = nil
		showCursor(false)
		closeNewCommand()
	end
end

function getCmdPerms(perm)
	if perm >=0 and perm <=10 then --Admins
		local adminLevel = getElementData(localPlayer, "admin_level") or 0
		if adminLevel >= perm then
			return true, exports.global:getAdminTitles()[perm] or "Player"
		else
			return false, exports.global:getAdminTitles()[perm] or "Player"
		end
	elseif perm >=11 and perm <=20 then --Supporters
		return exports.integration:isPlayerSupporter(localPlayer) or exports.integration:isPlayerTrialAdmin(localPlayer), "Supporter"
	elseif perm >=21 and perm <=30 then --VCTs
		return exports.integration:isPlayerVCTMember(localPlayer) or exports.integration:isPlayerAdmin(localPlayer), "VCT Member"
	elseif perm >=31 and perm <=40 then --Mappers
		return exports.integration:isPlayerMappingTeamMember(localPlayer) or exports.integration:isPlayerTrialAdmin(localPlayer), "Mapper"
	elseif perm >=41 and perm <=50 then --Scripter
		return exports.integration:isPlayerScripter(localPlayer), "Scripter"
	else
		return false, "Player"
	end
end

local gui = {}
function openNewCommand(id, perm, cmd, key, ex)
	closeNewCommand()
	togF1Menu(false)
	exports.global:playSoundSuccess()
	local w, h = 500, 225
	gui.wNewStation = guiCreateStaticImage(0, 0, w, h, ":resources/window_body.png", false)
	exports.global:centerWindow(gui.wNewStation)
	local margin = 20
	local lineH = 25
	local lineH2 = lineH
	local col1 = 100
	gui.l1 = guiCreateLabel(margin, margin, w-margin*2, lineH, "CREATE A NEW COMMAND", false, gui.wNewStation)
	guiSetFont(gui.l1, "default-bold-small")
	guiLabelSetHorizontalAlign(gui.l1, "center", true)
	guiLabelSetVerticalAlign(gui.l1, "center", true)

	gui.l5 = guiCreateLabel(margin, margin+lineH2, col1, lineH, "Category:", false, gui.wNewStation)
	guiSetFont(gui.l5, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l5, "center", true)
	gui.eCate = guiCreateComboBox(margin+col1, margin+lineH2, w-margin*2-col1, lineH, currentCate or "Chat", false, gui.wNewStation)
	for i, cateName in ipairs(categories) do
		guiComboBoxAddItem(gui.eCate, cateName)
	end
	exports.global:guiComboBoxAdjustHeight(gui.eCate, #categories)

	lineH2 = lineH2 + lineH

	gui.l6 = guiCreateLabel(margin, margin+lineH2, col1, lineH, "Permission:", false, gui.wNewStation)
	guiSetFont(gui.l6, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l6, "center", true)
	gui.ePerm = guiCreateComboBox(margin+col1, margin+lineH2, w-margin*2-col1, lineH, perm or "Player", false, gui.wNewStation)
	local count = 0
	for i, permName in pairs(perms) do
		guiComboBoxAddItem(gui.ePerm, permName)
		count = count + 1
	end
	exports.global:guiComboBoxAdjustHeight(gui.ePerm, count)

	lineH2 = lineH2 + lineH

	gui.l2 = guiCreateLabel(margin, margin+lineH2, col1, lineH, "Command Name:", false, gui.wNewStation)
	guiSetFont(gui.l2, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l2, "center", true)
	gui.eName = guiCreateEdit(margin+col1, margin+lineH2, w-margin*2-col1, lineH, cmd or "", false, gui.wNewStation)

	lineH2 = lineH2 + lineH

	gui.l3 = guiCreateLabel(margin, margin+lineH2, col1, lineH, "Hotkey (if any):", false, gui.wNewStation)
	guiSetFont(gui.l3, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l3, "center", true)
	gui.eKey = guiCreateEdit(margin+col1, margin+lineH2, w-margin*2-col1, lineH, key or "", false, gui.wNewStation)

	lineH2 = lineH2 + lineH

	gui.l4 = guiCreateLabel(margin, margin+lineH2, col1, lineH, "Explanation:", false, gui.wNewStation)
	guiSetFont(gui.l4, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l4, "center", true)
	gui.eEx = guiCreateEdit(margin+col1, margin+lineH2, w-margin*2-col1, lineH, ex or "", false, gui.wNewStation)

	lineH2 = lineH2 + lineH



	local buttons = 3
	local buttonW = (w-margin*2)/buttons
	gui.bOk = guiCreateButton(margin, margin+lineH/2+lineH2, buttonW , lineH, id and "Save" or "Create",false,gui.wNewStation)
	guiSetFont(gui.bOk, buyNew and "default-small" or "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bOk, function()
		if source == gui.bOk then
			exports.global:playSoundCreate()
			local cate1 = guiComboBoxGetItemText(gui.eCate, guiComboBoxGetSelected ( gui.eCate )) or currentCate or "Chat"
			cate1 = getCateIDFromName(cate1)
			local perm1 = guiComboBoxGetItemText(gui.ePerm, guiComboBoxGetSelected ( gui.ePerm )) or perm or "Player"
			perm1 = getPermIDFromName(perm1)
			local cmd1 = guiGetText(gui.eName)
			local key1 = guiGetText(gui.eKey)
			local ex1 = guiGetText(gui.eEx)
			triggerServerEvent("saveCommand", localPlayer, {id, cate1, perm1, cmd1, key1, ex1})
			loading = true
			closeNewCommand()
		end
	end)

	gui.bDel = guiCreateButton(margin+buttonW, margin+lineH/2+lineH2, buttonW , lineH, "Delete",false,gui.wNewStation)
	guiSetFont(gui.bDel, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bDel, function()
		if source == gui.bDel then
			triggerServerEvent("deleteCommand", localPlayer, id)
			loading = true
			closeNewCommand()
		end
	end)
	if not id then
		guiSetEnabled(gui.bDel, false)
	end

	gui.bClose1 = guiCreateButton(margin+buttonW*2, margin+lineH/2+lineH2, buttonW , lineH, "Cancel",false,gui.wNewStation)
	guiSetFont(gui.bClose1, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bClose1, function()
		if source == gui.bClose1 then
			closeNewCommand()
		end
	end)

	showCursor(true)
	guiSetInputEnabled(true)
end


function closeNewCommand()
	if gui.wNewStation and isElement(gui.wNewStation) then
		destroyElement(gui.wNewStation)
		gui.wNewStation = nil
		togF1Menu(true)
		--showCursor(true)
		guiSetInputEnabled(false)
	end
end

function tabSwitch(theTab)
	for i, cateName in ipairs(categories) do
		if theTab == tab[i] then
			currentCate = cateName
			break
		end
	end
end

function canEditCmds()
	return exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer)
end
