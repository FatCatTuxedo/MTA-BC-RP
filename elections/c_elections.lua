GUIEditor = {
    button = {},
    window = {},
    label = {},
    combobox = {}
}
function electionsGUI()
	if isElement(GUIEditor.window[1]) then return false end

	GUIEditor.window[1] = guiCreateWindow(579, 295, 316, 191, "December 2014 elections", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.button[1] = guiCreateButton(0.09, 0.68, 0.34, 0.24, "Vote", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[1], function ()
			local selection = guiGetText(GUIEditor.combobox[1])
			if selection == "Please choose" then return false end
			doVote(selection)
		end, false)
	GUIEditor.button[2] = guiCreateButton(0.55, 0.68, 0.34, 0.24, "Close", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[2], function ()
			if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
		end, false)
	GUIEditor.label[1] = guiCreateLabel(0.05, 0.12, 0.89, 0.12, "Please choose and then click 'Vote'", true, GUIEditor.window[1])
	GUIEditor.combobox[1] = guiCreateComboBox(0.05, 0.26, 0.89, 0.41, "Please choose", true, GUIEditor.window[1])
	guiComboBoxAddItem(GUIEditor.combobox[1], "Daniel Levi")
	guiComboBoxAddItem(GUIEditor.combobox[1], "Adam Price")
	guiComboBoxAddItem(GUIEditor.combobox[1], "Luca Borelli")
end
addEvent("elections:votegui", true)
addEventHandler("elections:votegui", getLocalPlayer(), electionsGUI)
--addCommandHandler("electiongui", electionsGUI)

function doVote(selection)
	local alreadyVoted = getElementData(getLocalPlayer(), "electionsvoted")

	if alreadyVoted == 1 then
		outputChatBox("You have already voted!")
		if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
		return false
	end

	local currentVotes = getElementData(resourceRoot, "elections:votes")

	local vote = nil
	for k, v in pairs(currentVotes) do
		if v["idelections"] == selection then
			vote = k
		end
	end
	currentVotes[vote]["Votes"] = tonumber(currentVotes[vote]["Votes"]) + 1
	setElementData(resourceRoot, "elections:votes", currentVotes)
	triggerServerEvent("elections:refresh", resourceRoot, selection, currentVotes[vote]["Votes"], getLocalPlayer())
end
