--[[ //Chaos
~=~=~=~=~=~= ORGANIZED REPORTS FOR OWL INFO =~=~=~=~=~=~
Name: The name to show once the report is submitted and in the F2 menu
Staff to send to: The Usergroup ID on the forums that you are sending the report to
Abbreviation: Used in the report identifier for the staff
r, g, b: The color for the report

I used the strings as the values instead of the keys, this way its easier for us to organize. 
{NAME, { Staff to send to }, Abbreviation, r, g, b}
1 = helpers 2 = admins 3 = smt only]]

reportTypes = {
 	{"Report another player", {2}, "PLY", 14,194,255, "Use this type if you are reporting a player about a issue that has occured." },
 	{"CK Request", {2}, "CK", 14,194,255, "Use this type if you requesting a CK on someone." },
	{"Help", {1,2}, "HLP", 255, 126, 0, "Use this type if you are having an issue, need advice or have a question." },
	{"Vehicle, Interiors or Items", {1,2}, "VII", 255, 126, 0, "Use this type if you are having an issue with vehicles, interiors or items." },
	{"SMT Contact", {3}, "SMT", 255, 0, 0, "Use this type if you wan to talk to the SMT." },
	{"Vehicle Handling/Imports", {3}, "HND", 255, 0, 0, "Use this type if you want to talk to the SMT about vehicles." },
	{"Bugs/Glitches", {3}, "DEV", 138,43,226, "Use this type if you want to talk to the Development Team." },
}

adminTeams = exports.integration:getAdminStaffNumbers()
auxiliaryTeams = "10,9,11"
SUPPORTER = 1

function getReportInfo(row, element)
	if not isElement(element) then
		element = nil
	end

	local staff = reportTypes[row][2]
	local players = getElementsByType("player")

	local name = reportTypes[row][1]
	local abrv = reportTypes[row][3]
	local red = reportTypes[row][4]
	local green = reportTypes[row][5]
	local blue = reportTypes[row][6]

	return staff, false, name, abrv, red, green, blue
end

function isSupporterReport(row)
	local staff = reportTypes[row][2]

	for k, v in ipairs(staff) do
		if v == 1 then
			return true
		end
	end
	return false
end

function isAdminReport(row)
	local staff = reportTypes[row][2]

	for k, v in ipairs(staff) do
		if v == 2 then
			return true
		end
	end
	return false
end

function isSMTReport(row)
	local staff = reportTypes[row][2]

	for k, v in ipairs(staff) do
		if v == 3 then
			return true
		end
	end
	return false
end

function isAuxiliaryReport(row)
	return false
end

function showExternalReportBox(thePlayer)
	if not thePlayer then return false end
	return (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) and (getElementData(thePlayer, "report_panel_mod") == "2" or getElementData(thePlayer, "report_panel_mod") == "3")
end

function showTopRightReportBox(thePlayer)
	if not thePlayer then return false end
	return (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) and (getElementData(thePlayer, "report_panel_mod") == "1" or getElementData(thePlayer, "report_panel_mod") == "3")
end