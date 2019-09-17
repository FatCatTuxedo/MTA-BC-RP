--Support for custom vehicle sirens, by Exciter.

local localPlayer = getLocalPlayer()

function clientUpdateSirens()
	if(source == localPlayer) then
		local vehicles = getElementsByType("vehicle")
		for k,v in ipairs(vehicles) do
			local model = getElementModel(v)
			--stage 1: Check models
			if(model == 525) then --towtruck
				addVehicleSirens(veh, 3, 4, true, true, true, true)
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 1, -0.7, -0.35, -0.7, 255, 0, 0)
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 2, 0, -0.35, -0.7)
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 3, 0.7, -0.35, -0.7, 255, 0, 0)
				return true
			--stage 2: Check items
			elseif(exports.global:hasItem(v, 144) and model == 560) then --sultan strobe
				addVehicleSirens ( veh, 5, 3, true, true, true, true ) 
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 1, -0.225, 2.672, 0.092, 0, 0, 255 )
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 2, 0.272, 2.679, 0.081, 0, 0, 255 )
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 3, 0.030, 1.106, 0.405, 0, 0, 255 )
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 4, -0.339, -1.626, 0.426, 0, 0, 255 )
				triggerEvent("sirens:setroofsiren", localPlayer, veh, 5, 0.440, -1.625, 0.426, 0, 0, 255 )
			end
		end
	end
end
addEventHandler("onClientPlayerJoin", getRootElement(), clientUpdateSirens)

