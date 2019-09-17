local width, height = 246,90
local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()

-- dx stuff
local jobName = ""
local jobLevel = ""
local jobProgress = ""
local jobCurrentProgress = ""
local loadedSupplies = ""
local truckCap = ""

local nextLocation = ""
local nextDropStopRequires = ""
local r,b,g = 255,255,255
local r2, b2, g2 = 0, 255, 0
local timeoutClock = 0
local showTimeoutClock = false
timerCountDown = nil
local show = false

function getJobTitleFromID(jobID)
	if (tonumber(jobID)==1) then
		return "Delivery Driver"
	elseif (tonumber(jobID)==2) then
		return "Taxi Driver"
	elseif  (tonumber(jobID)==3) then
		return "Bus Driver"
	elseif (tonumber(jobID)==4) then
		return "City Maintenance"
	elseif (tonumber(jobID)==5) then
		return "Mechanic"
	elseif (tonumber(jobID)==6) then
		return "Locksmith"
	else
		return "Unemployed"
	end
end

level = {
	[1] = 50,
	[2] = 200,
	[3] = 400,
	[4] = 700,
}

local truckerJobVehicleInfo = {
--  Model   (1)Kgs (2)Level (3)CrateWeight
	[440] = {700, 1, 20}, -- Rumpo
	[499] = {1120, 2, 40}, -- Benson
	[414] = {1400, 3, 50}, -- Mule
	[498] = {2100, 4, 75}, -- Boxville
	[456] = {2800, 5, 100}, -- Yankee
}

-- update the labels
local function updateGUI()
	if show then	
		local job = getElementData(localPlayer, "job" ) or 0
		jobName = ("                    "..getJobTitleFromID(job)) or ""
		local veh = getPedOccupiedVehicle(localPlayer) or false
		local jobVeh = 0
		
		if veh then
			jobVeh = getElementData(veh, "job" ) or 0
			--[[ Lag as fuck this one
			addEventHandler( "onClientElementDataChange", veh, 
				function (n)	
					if n == "job" or n == "job-system-trucker:loadedSupplies" then
						createGUI()
					end 
				end
			,false)
			]]
		end

		if job == 1 and jobVeh == 1 then -- RS Haul
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Driver Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Trucking runs: "..tempTruckRuns
			
			if veh and jobVeh == 1 then
				height = 175
				local model = getElementModel(veh)
				local tempTruckCap = truckerJobVehicleInfo[model][1]
				truckCap = "Truck Capacity: "..getVehicleNameFromModel(model).." - "..tempTruckCap.." kg(s)"
				local tempLoadedSupplies = getElementData(veh, "job-system-trucker:loadedSupplies" ) or 0
				loadedSupplies = "Loaded Supplies: "..tempLoadedSupplies.." kg(s) ("..math.floor(tempLoadedSupplies/tempTruckCap*100).."%)"
				local currentRoute = getElementData(localPlayer, "job-system-trucker:currentRoute") or false
				if currentRoute then
					height = 175
					nextLocation = "Target: "..currentRoute[6] or "Unknown"
					if currentRoute[4] then
						if currentRoute[4] >= tempLoadedSupplies then
							nextDropStopRequires = "Requiring Supplies: "..currentRoute[4].." kg(s) - NOT ENOUGH"
							r,b,g = 255, 0, 0
						else
							nextDropStopRequires = "Requiring Supplies: "..currentRoute[4].." kg(s) - ENOUGH"
							r,b,g = 0, 255, 0
						end
					else
						nextDropStopRequires = ""
						r,b,g = 255, 255, 255
					end
				else
					height = 130
					nextDropStopRequires = ""
					r,b,g = 255, 255,255
				end
				showTimeoutClock = true
			else
				wipeAdditionalInfo()
			end
		elseif job == 2 and jobVeh == 2 then -- Taxi
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Driver Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Served Fares: "..tempTruckRuns
		elseif job == 3 and jobVeh == 3 then -- Bus Driver
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Driver Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Served Fares: "..tempTruckRuns
		elseif job == 4 and jobVeh == 4 then -- Citi Maintenance
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Worker Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Cleaned shifts: "..tempTruckRuns
		elseif job == 5 and jobVeh == 5 then -- Mechanic
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Served Vehicles: "..tempTruckRuns
		elseif job == 6 and jobVeh == 6 then -- Locksmith
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Manipulated Keys: "..tempTruckRuns
		else
			show = false
			return false
		end
	end
end

function wipeAdditionalInfo()
	height = 90
	loadedSupplies = ""
	truckCap = ""
	nextLocation = ""
	nextDropStopRequires = ""
	showTimeoutClock = false
	timeoutClock = ""
end
addEvent( "job-system:trucker:wipeAdditionalInfo", true )
addEventHandler( "job-system:trucker:wipeAdditionalInfo", localPlayer, wipeAdditionalInfo)

-- create the gui
function createGUI()
	show = false
	local logged = getElementData(localPlayer, "loggedin")
	local job = getElementData( localPlayer, "job" ) or 0
	if logged == 1 and (job == 1 or job == 2 or job == 3 or job == 4 or job == 5 or job == 6) then
		show = true
		updateGUI()
	end
end
addEvent( "job-system:trucker:UpdateOverLay", true )
addEventHandler( "job-system:trucker:UpdateOverLay", localPlayer, createGUI)

addEventHandler( "onClientResourceStart", getResourceRootElement(), createGUI, false )

addEventHandler( "onClientElementDataChange", localPlayer, 
	function(n)
		if n == "job" or n == "jobProgress" or n=="jobLevel" or n == "job-system-trucker:truckruns" or n == "job-system-trucker:currentRoute" or n == "job-system:trucker:updateOverLay" then
			createGUI()
		end
	end, false
)

addEvent( "job-system:trucker:startTimeoutClock", true )
addEventHandler( "job-system:trucker:startTimeoutClock", localPlayer,
	function( seconds )
		if seconds > 0 then
			seconds = math.ceil(seconds / 4) 
			if seconds < 60 then
				seconds = 60
			end
			timerCountDown = setTimer(function()
				if seconds >=20 then
					r2, b2, g2 = 0, 255, 0
				elseif seconds >= 10 then
					r2, b2, g2 = 255, 255, 0
				elseif seconds > 0 then
					r2, b2, g2 = 255, 0, 0
				else
					r2, b2, g2 = 255, 0, 0
					killTimerCountDown()
					triggerServerEvent("job-system:trucker:spawnRoute", localPlayer, localPlayer, true)
				end
				timeoutClock = "Deadline: "..seconds.." second(s)"
				seconds = seconds - 1
			end, 1000, 0)
		end
	end, false
)

function killTimerCountDown()
	if timerCountDown then
		killTimer(timerCountDown)
		timerCountDown = nil
	end
end
addEvent( "job-system:trucker:killTimerCountDown", true )
addEventHandler("job-system:trucker:killTimerCountDown", localPlayer,killTimerCountDown)

addEvent( "addOneToCKCount", true )
addEventHandler("addOneToCKCount", localPlayer,
	function( )
		-- ckAmount = ckAmount + 1
		-- updateGUI()
	end, false
)

addEvent( "addOneToCKCountFromSpawn", true )
addEventHandler("addOneToCKCountFromSpawn", localPlayer,
	function( )
		-- if (ckAmount>=1) then
			-- return
		-- else
		-- ckAmount = ckAmount + 1
		-- updateGUI()
		-- end
	end, false
)

addEvent( "subtractOneFromCKCount", true )
addEventHandler("subtractOneFromCKCount", localPlayer,
	function( )
		-- if (ckAmount~=0) then
			-- ckAmount = ckAmount - 1
			-- updateGUI()
		-- else
			-- ckAmount = 0
		-- end
	end, false
)

addEventHandler( "onClientPlayerQuit", getRootElement(), updateGUI )

function drawText ( )
	if show then
		if ( getPedWeapon( localPlayer ) ~= 43 or not getControlState( "aim_weapon" ) ) then
			local yOffset = (getElementData(localPlayer, "hud:whereToDisplayY") or 0) + (getElementData(localPlayer, "report-system:dxBoxHeight") or 0) + (getElementData(localPlayer, "hud:overlayTopRight") or 0) + 40
			dxDrawRectangle(sx-width-5, 5+yOffset, width, height, tocolor(0, 0, 0, 150), false)
			
			dxDrawText( jobName or "" , sx-width+10, 10+yOffset, width-5, 20, tocolor ( 255, 255, 255, 255 ), 1, "default-bold" )
			
			dxDrawText( jobLevel or "" , sx-width+10, 30+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			dxDrawText( jobProgress or "" , sx-width+10, 45+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			dxDrawText( jobCurrentProgress or "" , sx-width+10, 60+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			
			dxDrawText( truckCap or "" , sx-width+10, 80+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			dxDrawText( loadedSupplies or "" , sx-width+10, 95+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			
			dxDrawText( nextLocation or "" , sx-width+10, 115+yOffset, width-5, 15, tocolor ( 0, 255, 0, 255 ), 1, "default" )
			dxDrawText( nextDropStopRequires or "" , sx-width+10, 130+yOffset, width-5, 15, tocolor ( r, b, g, 255 ), 1, "default" )
			dxDrawText( timeoutClock or "" , sx-width+10, 145+yOffset, width-5, 15, tocolor ( r2, b2, g2, 255 ), 1, "default" )
		end
	end
end
addEventHandler("onClientRender",getRootElement(), drawText)

addEvent( "addOneToChopCount", true )
addEventHandler("addOneToChopCount", localPlayer,
	function( )
		-- chopAmount = chopAmount + 1
		-- updateGUI()
	end, false
)

addEvent( "subtractOneFromChopCount", true )
addEventHandler("subtractOneFromChopCount", localPlayer,
	function( )
		-- if (chopAmount~=0) then
			-- chopAmount = chopAmount - 1
			-- updateGUI()
		-- else
			-- chopAmount = 0
		-- end
	end, false
)