local fireModel = 2023
local isFireOn = false

local fireTable = {
		--  { x, y, z, "Location", "Incident description", "special or regular", carID(or blank) }
        { 595.06, -535.41, 17, "Dillimore, behind the Police Building.", "There's a vehicle smoking, possibly coming on fire!", "regular", 401 },
        { 658.0908, -439.372, 16, "Dillimore, the bins behind the bar at north!", "We try to extinguish it and it doesn't work! They're on fire!" },
		{ -76.41796875, -1593.662109375, 2.6171875, "Flint Intersection, trailer park LS South-West.", "There's smoke coming from a trailer park...you guys might want to check this!" },
		{ 2351.08984375, -653.4462890625, 128.0546875, "North Rock, the shack on top of the hill!", "I'm not sure, but it's worth checking it out! There's much smoke coming out of there!", "special", 410 },
		{ 2626.9677734375, -846.2607421875, 84.179885864258, "North Rock, by a shack on the hill!", "A tree just got on fire, god damn California sun!" },
		{  2859.03515625, -598.166015625, 10.928389549255, "Interstate 425 East, by the highway.", "A car seems heavily damaged, smoking, and there's a fire next to it! Hurry!", "regular", 420 },
		{ 392.51171875, -1924.5078125, 10.25, "Santa Monica Pier.", "One of the wood building got on fire!", "special" },
		{ -104.0712890625, -331.7822265625, 1.4296875, "Red county, blueberry warehouse.", "Not sure what hit the tank, but I feel fire will come out soon!", "regular", 403 },
		{ 90.162109375, -286.1953125, 1.578125, "Red county, blueberry warehouse.", "Not sure what hit the tank, but I feel fire will come out soon!", "regular", 403 },
		{ 1368.8466796875, -291.900390625, 1.7080450057983, "Mulholland canal!", "A skimmer just crashed here by the beach!", "regular", 460 }
}

function loadthescript()
    outputDebugString("LeFire Script loaded ...")
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), loadthescript)

function fdfire()
    math.randomseed(getTickCount())
    local randomfire = math.random(1,#fireTable)
    local fX, fY, fZ = fireTable[randomfire][1],fireTable[randomfire][2],fireTable[randomfire][3]
    local fireTeam = getTeamFromName("Bone County Sheriff's Office")
        if (fireTeam) then
            local playersOnFireTeam = getPlayersInTeam ( fireTeam ) 
            for k, v in ipairs (playersOnFireTeam) do
                outputChatBox("[RADIO] This is dispatch. We received an anonymous call regarding a major incident.",v,245, 40, 135)
				outputChatBox("[RADIO] Incident is as follow: "..fireTable[randomfire][5],v,245, 40, 135)
                outputChatBox("[RADIO] Location: "..fireTable[randomfire][4].." Please report there immediately. We added a blip on your GPS.",v,245, 40, 135)
            end

            -- You can get table info like this below, i set the variable above to make it shorter to call from.
            --outputDebugString("x:"..fireTable[randomfire][1].." y:"..fireTable[randomfire][2].." z:"..fireTable[randomfire][3])
			if (fireTable[randomfire][7]) then
				local fireveh = createVehicle(fireTable[randomfire][7], fX, fY, fZ)
				setTimer( function ()
					destroyElement(fireveh)
				end, 1800000, 1)
				blowVehicle(fireveh)				
			end
			if (fireTable[randomfire][6] == "special") then
				local fireElem1 = createObject(fireModel,fX+2,fY+2,fZ)
				setElementCollisionsEnabled(fireElem,false)
				local col1 = createColSphere(fX+2,fY+2,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem1)
					destroyElement(col1)
				end, 420000, 1)

				local fireElem2 = createObject(fireModel,fX+4,fY+4,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col2 = createColSphere(fX+4,fY+4,fZ+2,2)
				setTimer ( function ()
					destroyElement(fireElem2)
					destroyElement(col2)
				end, 420000, 1)		

				local fireElem3 = createObject(fireModel,fX-2,fY-2,fZ)
				setElementCollisionsEnabled(fireElem,false)
				local col3 = createColSphere(fX-2,fY-2,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem3)
					destroyElement(col3)
				end, 420000, 1)		

				local fireElem4 = createObject(fireModel,fX-4,fY-4,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col4 = createColSphere(fX-4,fY-4,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem4)
					destroyElement(col4)
				end, 420000, 1)		

				local fireElem5 = createObject(fireModel,fX,fY-4,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col5 = createColSphere(fX,fY-4,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem5)
					destroyElement(col5)
				end, 420000, 1)		

				local fireElem6 = createObject(fireModel,fX-4,fY,fZ+2)
				setElementCollisionsEnabled(fireElem,false)
				local col6 = createColSphere(fX-4,fY,fZ+1,2)
				setTimer ( function ()
					destroyElement(fireElem6)
					destroyElement(col6)
				end, 420000, 1)						
			end
            outputDebugString(fX.." "..fY.." "..fZ)
			-- Fire sync
			local fireElem = createObject(fireModel,fX,fY,fZ)
			setElementCollisionsEnabled(fireElem,false)
			local col = createColSphere(fX,fY,fZ+1,2)
			setTimer ( function ()
				destroyElement(fireElem)
				destroyElement(col)
			end, 420000, 1)
			
	
            triggerClientEvent("startTheFire", getRootElement(),fX,fY,fZ)
            local blip = createBlip(fX,fY,fZ, 43, 0, 0, 0, 255)
            setTimer ( function ()
                destroyElement(blip)
            end, 900000, 1)
			
			isFireOn = true
			setTimer ( function ()
				isFireOn = false
			end, 900000, 1)
        end
end

-- /randomfire - Start a random fire from the table
function randomfire (thePlayer)
	if ( exports.integration:isPlayerTrialAdmin ( thePlayer ) ) then
		outputDebugString(isFireOn)
		if (isFireOn) then			
			outputChatBox ("AdmCMD: There is already a fire. Use /cancelfire or wait 30 minutes.", thePlayer,255,0,0)
		else
			fdfire()
			outputChatBox ("AdmCMD: You have random triggered a fire for FD!", thePlayer,255,0,0)
			outputChatBox ("AdmCMD: Type /cancelfire to cancel it!", thePlayer,255,0,0)
		end
	end
end
addCommandHandler("randomfire", randomfire)

-- /cancelfire - Stops the whole fire process (restarts the resource)
function cancelrandomfire (thePlayer)
	if ( exports.integration:isPlayerTrialAdmin ( thePlayer ) ) then
		outputDebugString(isFireOn)
		if (isFireOn) then	
			local thisResource = getThisResource()
			outputChatBox ("AdmCMD: You have stopped the random fire for FD!", thePlayer,255,0,0)
			outputChatBox ("AdmCMD: It may take up to five minutes before it is fully cancelled.", thePlayer,255,0,0)
			restartResource(thisResource)
			isFireOn = false
		else
			outputChatBox ("AdmCMD: There is no fire started. Use /randomfire to start it.", thePlayer,255,0,0)
		end
	end
end
addCommandHandler("cancelfire", cancelrandomfire)
