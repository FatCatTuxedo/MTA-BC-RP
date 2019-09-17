local sx, sy = guiGetScreenSize()
local scrSrc = dxCreateScreenSource(sx, sy)

local shaderFX = dxCreateShader("tinted_windows.fx", 1, 200, true)

function goodWindowTint()
	for key,veh in ipairs(getElementsByType("vehicle")) do
		if (getElementData(veh, "tinted") == true) then
			engineApplyShaderToWorldTexture(shaderFX, "vehiclegeneric256", veh)
			engineApplyShaderToWorldTexture(shaderFX, "hotdog92glass128", veh)
			engineApplyShaderToWorldTexture(shaderFX, "okoshko", veh)
			engineApplyShaderToWorldTexture(shaderFX, "@hite", veh)
		else
			engineRemoveShaderFromWorldTexture( shaderFX, "vehiclegeneric256", veh )
			engineRemoveShaderFromWorldTexture( shaderFX, "hotdog92glass128", veh )
			engineRemoveShaderFromWorldTexture( shaderFX, "okoshko", veh )
			engineRemoveShaderFromWorldTexture( shaderFX, "@hite", veh )
		end
	end
end
addEvent("legitimateResponceRecived", true)
addEventHandler("legitimateResponceRecived", getRootElement(), goodWindowTint)

function startTheRes()
	triggerServerEvent("tintDemWindows", getLocalPlayer())
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), startTheRes)
addEventHandler("onVehicleRespawn", getResourceRootElement(getThisResource()), startTheRes)
addEvent("tintWindows", true)
addEventHandler("tintWindows", getRootElement(), startTheRes)