--MAXIME
mtaConn = nil
forumsConn = nil

function getHost()
	return hostname
end
 
function getUser()
	return username
end
 
function getPass()
	return password
end
 
function getDatabase()
	return database
end
 
function getPort()
	return port
end

function getMtaConn()
	return mtaConn
end

function getForumsConn()
	return forumsConn
end

function connectMTA()
	return dbConnect("mysql", "dbname="..database..";hostname="..hostname..";port="..port..";unix_socket=/var/lib/mysql/mysql.sock", username, password, "autoreconnect=1")
end

function connectForums()
	return dbConnect("mysql", "dbname="..externaldatabase..";hostname="..externalhostname..";port="..externalport..";unix_socket=/var/lib/mysql/mysql.sock",externalusername, externalpassword, "autoreconnect=1")
end
 
function connectTo(h, db, p, u, pass)
	return dbConnect("mysql", "dbname="..db..";hostname="..h..";port="..p, u, pass, 'autoreconnect=1')
end

function resourceStart(resource)
	if mtaConn and isElement(mtaConn) then
		destroyElement(mtaConn)
		mtaConn = nil
	end
	mtaConn = connectMTA()
	if mtaConn then
		outputDebugString("[maxSQL] Connection to MTA database established.")
	else
		outputDebugString("[maxSQL] Connection to MTA database failed.")
	end
	
	if forumsConn and isElement(forumsConn) then
		destroyElement(forumsConn)
		forumsConn = nil
	end
	forumsConn = connectForums()
	if forumsConn then
		outputDebugString("[maxSQL] Connection to Forums database established.")
	else
		outputDebugString("[maxSQL] Connection to Forums database failed.")
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), resourceStart)

function mtaQuery(query)
	if not query then
		outputDebugString("[maxSQL] Error - Empty query string.")
		return false, "[maxSQL] Error - Empty query string."
	elseif not mtaConn then
		outputDebugString("[maxSQL] Error - MTA database connection is broken.")
		return false, "[maxSQL] Error - MTA database connection is broken."
	else
		local myCallback = function(qh)
			local result, num_affected_rows, last_insert_id = dbPoll( qh, 0 )   -- Timeout doesn't matter here because the result will always be ready
			if result == nil then
				dbFree(qh)
				return false, "No result"
			else
				return result, num_affected_rows, last_insert_id
			end
		end
		dbQuery( myCallback, mtaConn, query )
	end
end

function forumsQuery(query)
	if not query then
		outputDebugString("[maxSQL] Error - Empty query string.")
		return false, "[maxSQL] Error - Empty query string."
	elseif not forumsConn then
		outputDebugString("[maxSQL] Error - Forums database connection is broken.")
		return false, "[maxSQL] Error - Forums database connection is broken."
	else
		local myCallback = function(qh)
			local result, num_affected_rows, last_insert_id = dbPoll( qh, 0 )   -- Timeout doesn't matter here because the result will always be ready
			if result == nil then
				dbFree(qh)
				return false, "No result"
			else
				return result, num_affected_rows, last_insert_id
			end
		end
		dbQuery( myCallback, forumsConn, query )
	end
end



 
