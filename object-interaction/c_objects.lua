--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: Object interaction
--Last updated 23.02.2011 by Exciter
--Copyright 2008-2011, The Roleplay Project (www.roleplayproject.com)

local localPlayer = getLocalPlayer()

function takeShower(element)
	if showering[1] then
		setElementPosition(getLocalPlayer(), showering[2][1], showering[2][2], showering[2][3])
		removeEventHandler("onClientRender", element, renderShowerWater)
		--destroyElement(showering[5]) --destroy test marker
		--showering[5] = nil
		showering[4] = nil
		setElementFrozen (getLocalPlayer(), false)
		showering[1] = false
	else
		showering[1] = true
		local px,py,pz = getElementPosition(getLocalPlayer())
		showering[2] = {px, py, pz}
		local x,y,z = getElementPosition(element)
		showering[3] = {x, y, z}
		addEventHandler("onClientRender", getRootElement(), renderShowerWater)
		setElementPosition(getLocalPlayer(), x, y - 1, z + 1.5)
		setElementFrozen (getLocalPlayer(), true)
		showering[4] = element
		--showering[5] = createMarker(x, y, z, "cylinder", 0.5)
	end
end
function renderShowerWater(x,y,z)
	if showering[1] then
		fxAddWaterSplash(showering[3][1], showering[3][2] - 1, showering[3][3] + 1)
	end
end