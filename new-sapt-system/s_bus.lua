local routes = { }
mysql = exports.mysql
function startBus(player, seat)
	local model = getElementModel(source)
	if ((model == 431 or model == 437) and seat == 0) then
		triggerClientEvent(player, "bus:start", source)
		setElementData(source, "bus.routes", routes)
	end
end
addEventHandler("onVehicleEnter", getRootElement(), startBus)

function fetchRoutes()
	local count = 0
	local routesSQL = mysql:query("SELECT * FROM `bus_routes`") or false
	while true do
		local row = mysql:fetch_assoc(routesSQL) or false
		if not row then 
			break 
		end
		table.insert(routes, { tonumber(row["id"]), fromJSON(row["stops"])} )
	end
	mysql:free_result(routesSQL)
	
	for key, order in pairs(routes) do
		count = count + 1
	end

	outputDebugString("[sapt-system] Fetched "..count.." bus routes successfully from SQL")
end

addEventHandler ( "onResourceStart", getRootElement(), fetchRoutes )