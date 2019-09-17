--MAXIME
ods = outputDebugString
function outputDebugString(str)
	local resourceRoot = getResourceRootElement(getThisResource()) 
	if getElementData(resourceRoot, "debug_enabled") then
		str = tostring(str)
		ods(str)
	end
end