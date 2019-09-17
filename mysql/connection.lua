-- connection settings
hostname = get( "hostname" ) 
username = get( "username" ) 
password = get( "password" ) 
database = get( "database" ) 
port = tonumber( get( "port" ) ) 

-- external mysql connection settings
externalhostname = "127.0.0.1"
externalusername = "root"
externalpassword = "FuckYouInTheEyeSocket13Inches!##@"
externaldatabase = "mybb"
externalport = 3306

-- global things
local MySQLConnection = nil
local forumConnection = nil
local resultPool = { }
local queryPool = { }
local sqllog = false
local countqueries = 0


function getMySQLUsername()
	return username
end

function getMySQLPassword()
	return password
end

function getMySQLDBName()
	return db
end

function getMySQLHost()
	return host
end

function getMySQLPort()
	return port
end

--Debug
function tellMeMySQLStates(thePlayer)
	if exports.integration:isPlayerScripter(thePlayer) then
		if forumConnection then
			if mysql_ping(forumConnection) then
				outputChatBox("Forum Connection is online.", thePlayer, 0, 255, 0)
			else
				outputChatBox("Main DB is offline.", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("Forum Connection is offline.", thePlayer, 255, 0, 0)
		end
		if MySQLConnection then
			if mysql_ping(MySQLConnection) then
				outputChatBox("Main DB is online.", thePlayer, 0, 255, 0)
			else
				outputChatBox("Main DB is offline.", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("Main DB is offline.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("testdb", tellMeMySQLStates, false, false)

--Forum settings
function openForumDatabase(res)
	outputDebugString("--FORUMS DATABASE CREDENTIALS--")
	outputDebugString("--HOST: "..(externalhostname or "Error"))
	outputDebugString("--DB: "..(externaldatabase or "Error"))
	outputDebugString("--USER: "..(externalusername or "Error"))
	outputDebugString("--PW: "..(externalpassword and "***********" or "Error"))
	outputDebugString("--PORT: "..(externalport or "Error"))
	outputDebugString("--RESULT: ")
	forumConnection = mysql_connect(externalhostname, externalusername, externalpassword, externaldatabase, externalport)
	if (not forumConnection) then
		if (res == getThisResource()) then
			outputDebugString("Cannot connect to the forum database.")
		end
		return nil
	else 
		outputDebugString("OK")
	end
	return nil
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), openForumDatabase, false)

function destroyForumConnection()
	if (not forumConnection) then
		return nil
	end
	mysql_close(forumConnection)
	return nil
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), destroyForumConnection, false)

function forumPing()
	if (mysql_ping(forumConnection) == false) then
		-- FUU, NO MOAR CONNECTION
		destroyForumConnection()
		openForumDatabase(nil)
		if (mysql_ping(forumConnection) == false) then
			logForumSQLError()
			return false
		end
		return true
	end

	return true
end

function forumQuery(str)
	if sqllog then
		exports['logs']:logMessage(str, 24)
	end
	countqueries = countqueries + 1
	
	if (forumPing()) then
		local result = mysql_query(forumConnection, str)
		if (not result) then
			logForumSQLError(str)
			return false
		end

		local resultid = getFreeResultPoolID()
		resultPool[resultid] = result
		queryPool[resultid] = str
		return resultid
	end
	return false
end

function forum_query_insert_free(str)
	local queryresult = forumQuery(str)
	if  not (queryresult == false) then
		local result = forum_insert_id()
		free_result(queryresult)
		return result
	end
	return false
end

function forum_insert_id()
	return mysql_insert_id(forumConnection) or false
end

function forum_query_free(str)
	local queryresult = forumQuery(str)
	if  not (queryresult == false) then
		free_result(queryresult)
		return true
	end
	return false
end

function forum_query_fetch_assoc(str)
	local queryresult = forumQuery(str)
	if  not (queryresult == false) then
		local result = fetch_assoc(queryresult)
		free_result(queryresult)
		return result
	end
	return false
end
--End Forum

-- connectToDatabase - Internal function, to spawn a DB connection
function connectToDatabase(res)
	outputDebugString("--FORUMS DATABASE CREDENTIALS--")
	outputDebugString("--HOST: "..(hostname or "Error"))
	outputDebugString("--DB: "..(database or "Error"))
	outputDebugString("--USER: "..(username or "Error"))
	outputDebugString("--PW: "..(password and "***********" or "Error"))
	outputDebugString("--PORT: "..(port or "Error"))
	outputDebugString("--RESULT: ")

	MySQLConnection = mysql_connect(hostname, username, password, database, port)
	
	if (not MySQLConnection) then
		if (res == getThisResource()) then
			outputDebugString("Cannot connect to the MTA database.")
			cancelEvent(true, "Cannot connect to the database.")
		end
		return nil
	else
		outputDebugString("OK")
	end
	
	return nil
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), connectToDatabase, false)
	
-- destroyDatabaseConnection - Internal function, kill the connection if theres one.
function destroyDatabaseConnection()
	if (not MySQLConnection) then
		return nil
	end
	mysql_close(MySQLConnection)
	return nil
end
addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), destroyDatabaseConnection, false)

-- do something usefull here
function logSQLError(str)
	local message = str or 'N/A'
	outputDebugString("MYSQL ERROR "..mysql_errno(MySQLConnection) .. ": " .. mysql_error(MySQLConnection))
	exports['logs']:logMessage("MYSQL ERROR [QUERY] " .. message .. " [ERROR] " .. mysql_errno(MySQLConnection) .. ": " .. mysql_error(MySQLConnection), 24)
end

function logForumSQLError(str)
	local message = str or 'N/A'
	outputDebugString("MYSQL ERROR "..mysql_errno(forumConnection) .. ": " .. mysql_error(forumConnection))
	exports['logs']:logMessage("MYSQL ERROR [QUERY] " .. message .. " [ERROR] " .. mysql_errno(forumConnection) .. ": " .. mysql_error(forumConnection), 24)
end

function getFreeResultPoolID()
	local size = #resultPool
	if (size == 0) then
		return 1 
	end
	for index, query in ipairs(resultPool) do
		if (query == nil) then
			return index
		end
	end
	return (size + 1)
end

------------ EXPORTED FUNCTIONS ---------------

function ping()
	if (mysql_ping(MySQLConnection) == false) then
		-- FUU, NO MOAR CONNECTION
		destroyDatabaseConnection()
		connectToDatabase(nil)
		if (mysql_ping(MySQLConnection) == false) then
			logSQLError()
			return false
		end
		return true
	end

	return true
end

function escape_string(str)
	if (ping()) then
		return mysql_escape_string(MySQLConnection, str)
	end
	return false
end

function query(str)
	--outputDebugString("[mySQL]...")
	if sqllog then
		exports['logs']:logMessage(str, 24)
	end
	countqueries = countqueries + 1
	
	if (ping()) then
		local result = mysql_query(MySQLConnection, str)
		if (not result) then
			logSQLError(str)
			return false
		end

		local resultid = getFreeResultPoolID()
		resultPool[resultid] = result
		queryPool[resultid] = str
		return resultid
	end
	return false
end

function unbuffered_query(str)
	if sqllog then
		exports['logs']:logMessage(str, 24)
	end
	countqueries = countqueries + 1
	
	if (ping()) then
		local result = mysql_unbuffered_query(MySQLConnection, str)
		if (not result) then
			logSQLError(str)
			return false
		end

		local resultid = getFreeResultPoolID()
		resultPool[resultid] = result
		queryPool[resultid] = str
		return resultid
	end
	return false
end

function query_free(str)
	local queryresult = query(str)
	if  not (queryresult == false) then
		free_result(queryresult)
		return true
	end
	return false
end

function rows_assoc(resultid)
	if (not resultPool[resultid]) then
		return false
	end
	return mysql_rows_assoc(resultPool[resultid])
end

function fetch_assoc(resultid)
	if (not resultPool[resultid]) then
		return false
	end
	return mysql_fetch_assoc(resultPool[resultid])
end

function free_result(resultid)
	if (not resultPool[resultid]) then
		return false
	end
	mysql_free_result(resultPool[resultid])
	table.remove(resultPool, resultid)
	table.remove(queryPool, resultid)
	return nil
end

-- incase a nub wants to use it, FINE
function result(resultid, row_offset, field_offset)
	if (not resultPool[resultid]) then
		return false
	end
	return mysql_result(resultPool[resultid], row_offset, field_offset)
end

function num_rows(resultid)
	if (not resultPool[resultid]) then
		return false
	end
	return mysql_num_rows(resultPool[resultid])
	
end

function insert_id()
	return mysql_insert_id(MySQLConnection) or false
end

function query_fetch_assoc(str)
	local queryresult = query(str)
	if  not (queryresult == false) then
		local result = fetch_assoc(queryresult)
		free_result(queryresult)
		return result
	end
	return false
end

function query_rows_assoc(str)
	local queryresult = query(str)
	if  not (queryresult == false) then
		local result = rows_assoc(queryresult)
		free_result(queryresult)
		return result
	end
	return false
end

function query_insert_free(str)
	local queryresult = query(str)
	if  not (queryresult == false) then
		local result = insert_id()
		free_result(queryresult)
		return result
	end
	return false
end

function escape_string(str)
	if not (str) then return false end
	return mysql_escape_string(MySQLConnection, str)
end

function debugMode()
	if (sqllog) then
		sqllog = false
	else
		sqllog = true
	end
	return sqllog
end

function returnQueryStats()
	return countqueries
	-- maybe later more
end

function getOpenQueryStr( resultid )
	if (not queryPool[resultid]) then
		return false
	end
	
	return queryPool[resultid]
end

local resources = {
	["mysql"] = getResourceFromName("mysql"),
	["shop-system"] = getResourceFromName("shop-system"),
	["vehicle-manager"] = getResourceFromName("vehicle-manager"),
}

addCommandHandler( 'mysqlleaky',
	function(thePlayer)
		if exports.integration:isPlayerScripter(thePlayer) then
			outputDebugString("queryPool="..tostring(#queryPool))
			outputChatBox("#queryPool="..tostring(#queryPool), thePlayer)
			--[[
			local count = 0
			local res = {}
			local pretty = {}
			for k, v in pairs( resources ) do
				if not res[v] then
					res[v] = {}
				end
				table.insert(res[v], queryPool[k])
				count = count + 1
			end

			if count == 0 then
				outputDebugString('Not leaking anything.')
				return
			end

			outputDebugString('Only leaking a mere ' .. count .. ' result handles.')

			for k, v in pairs( res ) do
				outputDebugString(tostring(k) .. ': ' .. tostring(#v) .. "\n\t" .. table.concat(v, "\n\t"))
			end
			--]]
		end
	end
)

--Custom functions
local function createWhereClause( array, required )
	if not array then
		-- will cause an error if it's required and we wanna concat it.
		return not required and '' or nil
	end
	local strings = { }
	for i, k in pairs( array ) do
		table.insert( strings, "`" .. i .. "` = '" .. ( tonumber( k ) or escape_string( k ) ) .. "'" )
	end
	return ' WHERE ' .. table.concat(strings, ' AND ')
end

function select( tableName, clause )
	local array = {}
	local result = query( "SELECT * FROM " .. tableName .. createWhereClause( clause ) )
	if result then
		while true do
			local a = fetch_assoc( result )
			if not a then break end
			table.insert(array, a)
		end
		free_result( result )
		return array
	end
	return false
end

function select_one( tableName, clause )
	local a
	local result = query( "SELECT * FROM " .. tableName .. createWhereClause( clause ) .. ' LIMIT 1' )
	if result then
		a = fetch_assoc( result )
		free_result( result )
		return a
	end
	return false
end

function insert( tableName, array )
	local keyNames = { }
	local values = { }
	for i, k in pairs( array ) do
		table.insert( keyNames, i )
		table.insert( values, tonumber( k ) or escape_string( k ) )
	end
	
	local q = "INSERT INTO `"..tableName.."` (`" .. table.concat( keyNames, "`, `" ) .. "`) VALUES ('" .. table.concat( values, "', '" ) .. "')"
	
	return query_insert_free( q )
end

function update( tableName, array, clause )
	
	local strings = { }
	for i, k in pairs( array ) do
		table.insert( strings, "`" .. i .. "` = " .. ( k == mysql_null() and "NULL" or ( "'" .. ( tonumber( k ) or escape_string( k ) ) .. "'" ) ) )
	end
	local q = "UPDATE `" .. tableName .. "` SET " .. table.concat( strings, ", " ) .. createWhereClause( clause, true )
	
	return query_free( q )
end

function delete( tableName, clause )
	return query_free( "DELETE FROM " .. tableName .. createWhereClause( clause, true ) )
end