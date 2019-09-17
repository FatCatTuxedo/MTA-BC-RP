--MAXIME 2014.12.31
local sql = exports.mysql
function makeToken(userid, action, data)
	local tail = ''
	local tailDelete = ''
	if userid and tonumber(userid) then
		tail = tail..", userid='"..userid.."'"
		tailDelete = tailDelete.." userid='"..userid.."'"
	else 
		return false
	end
	if action then
		tail = tail..", action='"..sql:escape_string(action).."'"
		tailDelete = tailDelete.." AND action='"..sql:escape_string(action).."'"
	end
	if sql:query_free("DELETE FROM tokens WHERE "..tailDelete) then
		local token = md5(tostring(math.random(1000, 9999))..tostring(math.random(1000, 9999))..tostring(math.random(1000, 9999))..tostring(math.random(1000, 9999))..tostring(math.random(1000, 9999))..tostring(math.random(1000, 9999)))
		if data then
			tail = tail..", data='"..sql:escape_string(data).."'"
		end
		if sql:query_free("INSERT INTO tokens SET token='"..string.lower(token).."' "..tail) then
			return token
		end
	end
end