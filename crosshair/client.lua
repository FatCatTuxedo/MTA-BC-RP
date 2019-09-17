-- Basic code, modify how ever you need to.

crosshairShader = dxCreateShader ( "crosshair.fx" )
crosshair = dxCreateTexture("crosshair.png")
dxSetShaderValue(crosshairShader,"gTexture",crosshair)

addEventHandler('onClientRender', getRootElement(),
function()
	if getControlState('aim_weapon') and getPedTarget(localPlayer) and not active and getElementType(getPedTarget(localPlayer)) == 'player' then
		engineApplyShaderToWorldTexture(crosshairShader,"sitem16")
		active = true
	elseif getControlState('aim_weapon') and getPedTarget(localPlayer) and active then
		
	elseif active then
		engineRemoveShaderFromWorldTexture(crosshairShader,"sitem16")
		active = false
	end
end )