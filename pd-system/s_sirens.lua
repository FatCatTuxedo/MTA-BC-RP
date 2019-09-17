function vehicleBlown()
	setElementData(source, "lspd:siren", 0)
	setVehicleSirensOn ( source , false )
end
addEventHandler("onVehicleRespawn", getRootElement(), vehicleBlown)

function setSirenState(player)
	local installedStrobes = getPreInstalledStrobes()
	local veh_model = getVehicleName(source)
	if (exports.global:hasItem(source, 85)) then -- sirens
		local curState = getElementData(source, "lspd:siren")
		if curState == false then
			curState = 0
		end
		if (curState ~= 0) then
			setElementData(source, "lspd:siren", 0)
		else
		setElementData(source, "lspd:siren", 1)
		end
	elseif (exports.global:hasItem(source, 223)) then -- sirens
		local curState = getElementData(source, "lspd:siren")
		if curState == false then
			curState = 0
		end
		if (curState ~= 0) then
			setElementData(source, "lspd:siren", 0)
		else
		setElementData(source, "lspd:siren", 4)
		end
	elseif (exports.global:hasItem(source, 224)) then -- sirens
		local curState = getElementData(source, "lspd:siren")
		if curState == false then
			curState = 0
		end
		if (curState ~= 0) then
			setElementData(source, "lspd:siren", 0)
		else
		setElementData(source, "lspd:siren", 7)
		end
	end
end
addEvent( "lspd:setSirenState", true )
addEventHandler( "lspd:setSirenState", getRootElement(), setSirenState )

function cycleSirenState(player)
	local installedStrobes = getPreInstalledStrobes()
	local veh_model = getVehicleName(source)
	if (exports.global:hasItem(source, 85)) then -- sirens
		local curState = getElementData(source, "lspd:siren")
		if curState == false then
			curState = 0
		end
		if (curState == 3) then
			setElementData(source, "lspd:siren", 1)
		else
		setElementData(source, "lspd:siren", curState + 1)
		end
	elseif (exports.global:hasItem(source, 223)) then -- sirens
		local curState = getElementData(source, "lspd:siren")
		if curState == false then
			curState = 0
		end
		if (curState == 6) then
			setElementData(source, "lspd:siren", 4)
		else
		setElementData(source, "lspd:siren", curState + 1)
		end
	elseif (exports.global:hasItem(source, 224)) then -- sirens
		local curState = getElementData(source, "lspd:siren")
		if curState == false then
			curState = 0
		end
		if (curState == 9) then
			setElementData(source, "lspd:siren", 7)
		else
		setElementData(source, "lspd:siren", curState + 1)
		end
	end
end
addEvent( "lspd:cycleSirenState", true )
addEventHandler( "lspd:cycleSirenState", getRootElement(), cycleSirenState )

local function getFactionType(vehicle)
	local vehicleFactionID = getElementData(vehicle, "faction")
	local vehicleFactionElement = exports.pool:getElement("team", vehicleFactionID)
	if vehicleFactionElement then
		local type = getElementData(vehicleFactionElement, "type")
		if tonumber(type) then
			return getElementData(vehicleFactionElement, "type"), vehicleFactionID
		end
	end
	return 100, 100
end

function addSirens (player, seat)
	local veh_model = getVehicleName(source)
	local installedStrobes = getPreInstalledStrobes()
    if player and (seat==0) then
		if (exports.global:hasItem(source, 140)) then -- Emergency siren lights
			local orangeStrobes = getOrangeStrobes()

			if (orangeStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = orangeStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(orangeStrobes[veh_model]) do
					if (id~="total") then
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		elseif (exports.global:hasItem(source, 218))then
			local emergencyStrobes = getEmergencyStrobes()
			if (emergencyStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = emergencyStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(emergencyStrobes[veh_model]) do
					if (id~="total") then
						if (desc[4] == 0 and desc[5] == 0 and desc[6] == 255) then
								desc[4] = 255
								desc[5] = 0
								desc[6] = 0
						elseif (desc[4] == 11 and desc[5] == 12 and desc[6] == 13) then	
								desc[4] = 255
								desc[5] = 0
								desc[6] = 0
						end
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		elseif (exports.global:hasItem(source, 219))then
			local emergencyStrobes = getEmergencyStrobes()
			if (emergencyStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = emergencyStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(emergencyStrobes[veh_model]) do
					if (id~="total") then
						if (desc[4] == 0 and desc[5] == 0 and desc[6] == 255) then
								desc[4] = 255
								desc[5] = 0
								desc[6] = 255
						elseif (desc[4] == 11 and desc[5] == 12 and desc[6] == 13) then	
								desc[4] = 255
								desc[5] = 0
								desc[6] = 255
						end
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		elseif (exports.global:hasItem(source, 61)) and (installedStrobes[veh_model] == nil or veh_model == "FBI Rancher") then -- Emergency siren lights
			local emergencyStrobes = getEmergencyStrobes()

			if (emergencyStrobes[veh_model] == nil) then
				--vehicle doesn't have strobes scripted
			else
				local total = emergencyStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(emergencyStrobes[veh_model]) do
					if (id~="total") then
						if (desc[4] == 11 and desc[5] == 12 and desc[6] == 13) then
							if (getElementData(source, "faction") ~= 1) then
								desc[4] = 255
								desc[5] = 0
								desc[6] = 0
							else
								desc[4] = 0
								desc[5] = 0
								desc[6] = 255
							end
						end
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
			end
		elseif (installedStrobes[veh_model]) then -- PreInstalled sirens such as police cruisers, fire engines and ambulances.
				local total = installedStrobes[veh_model]["total"]
				addVehicleSirens(source,total,2, false, true, true, true)
				for id, desc in pairs(installedStrobes[veh_model]) do
					if (id~="total") then
						if (desc[4] == 11 and desc[5] == 12 and desc[6] == 13) then
						if (getElementData(source, "faction") ~= 1) then
							desc[4] = 255
							desc[5] = 0
							desc[6] = 0
						else
							desc[4] = 0
							desc[5] = 0
							desc[6] = 255
						end
						end
						setVehicleSirens(source, id, desc[1], desc[2], desc[3], desc[4], desc[5], desc[6], desc[7], desc[8])
					end
				end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), addSirens)
addEvent( "lspd:addSirens", true )
addEventHandler( "lspd:addSirens", getRootElement(), addSirens )