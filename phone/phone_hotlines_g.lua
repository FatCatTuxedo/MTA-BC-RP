--MAXIME

hotlines = {
	[911] = "Emergency Services", 
	[311] = "BCSO Non-Emergency",
	[411] = "AMR Hotline",
	[611] = "DoJ Non-Emergency",
	[4700] = "BCT&R Hotline",
	[5555] = "BCAA",
	[8294] = "Carson Transit",
	[711] = "Report Stolen Vehicle",
	[511] = "Fort Carson Municipal Government",
}

function isNumberAHotline(theNumber)
	local challengeNumber = tonumber(theNumber)
	return hotlines[challengeNumber]
end