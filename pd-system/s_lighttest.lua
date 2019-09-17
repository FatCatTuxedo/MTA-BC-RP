l_bar = {}
vehOffsets = {[560]= {0, 0.13, 0.82}, [459]= {0, 0.5, 1.12}, [554]= {0, 0.13, 1.05}, [490]= {0, 0.5, 1.1}}
addEvent("police:addLightBar", true)
function addLightBar()
	if getElementType( source ) == "vehicle" then
		local id = getElementModel(source)
		if vehOffsets[id] ~= nil then
			if exports.global:hasItem(source, 215) then
				if l_bar[source] ~= nil then
					destroyElement(l_bar[source])
					l_bar[source] = nil
				end
				if l_bar[source] == nil then
					local x, y, z =  getElementPosition(source)
					local light = createObject (3895, x, y, z)
					attachElements(light, source, unpack(vehOffsets[id]))
					l_bar[source] = light
				end
			else
				if l_bar[source] ~= nil then
					destroyElement(l_bar[source])
					l_bar[source] = nil
				end
			end
		end
	end
end
addEventHandler("police:addLightBar", getRootElement(), addLightBar)
addEventHandler("onVehicleRespawn", getRootElement(), addLightBar)

function addLightBarOnStart()
	local vehicles = exports.pool:getPoolElementsByType("vehicle")
	for k, arrayVehicle in ipairs(vehicles) do
	local id = getElementModel(arrayVehicle)
	if vehOffsets[id] ~= nil then
		if exports.global:hasItem(arrayVehicle, 215) then
			if l_bar[arrayVehicle] ~= nil then
				destroyElement(l_bar[arrayVehicle])
				l_bar[arrayVehicle] = nil
			end
			if l_bar[arrayVehicle] == nil then
				local x, y, z =  getElementPosition(arrayVehicle)
				local light = createObject (3895, x, y, z)
				attachElements(light, arrayVehicle, unpack(vehOffsets[id]))
				l_bar[arrayVehicle] = light
			end
		end
	end
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), addLightBarOnStart)

function destroyLightOnVehicleDestroy()
        if (getElementType(source) == "vehicle") then
                if l_bar[source] ~= nil then
                        destroyElement(l_bar[source])
                        l_bar[source] = nil
                end
        end
end
addEventHandler("onElementDestroy", getRootElement(), destroyLightOnVehicleDestroy)

function destroyLightOnVehicleExplode()
        if l_bar[source] ~= nil then
                destroyElement(l_bar[source])
                l_bar[source] = nil
        end
end
addEventHandler("onVehicleExplode", getRootElement(), destroyLightOnVehicleExplode)
