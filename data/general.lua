--MAXIME
local general = {}
function save(data, accessKey)
	if data then
		general[accessKey] = data
		return true
	else
		return false
	end
end

function load(accessKey)
	if general[accessKey] then
		local tmp = general[accessKey]
		general[accessKey] = nil
		return tmp
	else
		return false
	end
end
