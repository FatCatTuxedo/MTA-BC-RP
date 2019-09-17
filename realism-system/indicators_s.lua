
leftkey = "["
rightkey = "]"
bothkey = "="

LightState1 = {0}
LightState2 = {0}

BlinkT = {}
BlinkS = {}

function Blinker(thePlayer,mode)
	local vehicle = getPedOccupiedVehicle(thePlayer)
		if vehicle then
			if BlinkT[vehicle] then
				killTimer(BlinkT[vehicle])
				BlinkT[vehicle] = nil
				setVehicleLightState(vehicle,0,LightState1[vehicle])
				setVehicleLightState(vehicle,1,LightState2[vehicle])
				setVehicleLightState(vehicle,3,0)
				setVehicleLightState(vehicle,2,0)
				setVehicleOverrideLights(vehicle,0)
			else
				setVehicleOverrideLights(vehicle,2)
				setElementData(vehicle,"asd","asd")
				
				local a,b = getVehicleLightState(vehicle,0),getVehicleLightState(vehicle,1)
				LightState1[vehicle] = a
				LightState2[vehicle] = b
				
				if mode == leftkey then
					setVehicleLightState ( vehicle, 1, 1 )
					setVehicleLightState ( vehicle, 2, 1 )
					if a == 0 then
						BlinkT[vehicle] = setTimer(Blink,400,0,vehicle,1,0,3)
					elseif a == 1 then
						BlinkT[vehicle] = setTimer(Blink,400,0,vehicle,2,0,3)
					end
				elseif mode == rightkey then
					setVehicleLightState ( vehicle, 0, 1 )
					setVehicleLightState ( vehicle, 3, 1 )
					if b == 0 then
						BlinkT[vehicle] = setTimer(Blink,400,0,vehicle,1,1,2)
					elseif b == 1 then
						BlinkT[vehicle] = setTimer(Blink,400,0,vehicle,2,1,2)
					end
				elseif mode == bothkey then
						BlinkT[vehicle] = setTimer(Blink,400,0,vehicle,3,0,1)
				end
			end
		end
	end

function Blink(vehicle,how,l1,l2)
		if vehicle then
			if getElementData(vehicle,"asd") then
				if not BlinkS[vehicle] and how == 1 then
					setVehicleLightState ( vehicle, l1, 1 )
					setVehicleLightState ( vehicle, l2, 1 )
					BlinkS[vehicle] = true
				elseif BlinkS[vehicle] and how == 1 then
					setVehicleLightState ( vehicle, l1, 0 )
					setVehicleLightState ( vehicle, l2, 0 )
					BlinkS[vehicle] = false
				elseif not BlinkS[vehicle] and how == 2 then
					setVehicleLightState ( vehicle, l2, 1 )
					BlinkS[vehicle] = true
				elseif BlinkS[vehicle] and how == 2 then
					setVehicleLightState ( vehicle, l2, 0 )
					BlinkS[vehicle] = false
				elseif not BlinkS[vehicle] and how == 3 then
					setVehicleLightState ( vehicle, 0, 1 )
					setVehicleLightState ( vehicle, 1, 1 )
					setVehicleLightState ( vehicle, 2, 1 )
					setVehicleLightState ( vehicle, 3, 1 )
					BlinkS[vehicle] = true
				elseif BlinkS[vehicle] and how == 3 then
					setVehicleLightState ( vehicle, 0, 0 )
					setVehicleLightState ( vehicle, 1, 0 )
					setVehicleLightState ( vehicle, 2, 0 )
					setVehicleLightState ( vehicle, 3, 0 )
					BlinkS[vehicle] = false
				end
			else
				killTimer(BlinkT[vehicle])
				BlinkT[vehicle] = nil
		end
	end
end

addEventHandler ( "onVehicleEnter", getRootElement(),
function(thePlayer)
	if getElementType( thePlayer ) == "player" then
		bindKey ( thePlayer, leftkey, "down", Blinker, thePlayer, leftkey)
		bindKey ( thePlayer, rightkey, "down", Blinker, thePlayer, rightkey)
		bindKey ( thePlayer, bothkey, "down", Blinker, thePlayer, bothkey)
	end
end)

addEventHandler ( "onVehicleExit", getRootElement(),
function(thePlayer)
	if getElementType( thePlayer ) == "player" then
		unbindKey ( thePlayer, leftkey, "down", Blinker)
		unbindKey ( thePlayer, rightkey, "down", Blinker)
		unbindKey ( thePlayer, bothkey, "down", Blinker)
	end
end)