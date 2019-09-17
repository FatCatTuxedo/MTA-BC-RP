----------------------------------------------
--Resource: dynamic_lighting flashlight     --
--Author: Ren712                            --
--Contact: knoblauch700@o2.pl               --
----------------------------------------------

local flashLiTable = {flModel={}, shLight={}, shLiBul={}, shLiRay={}, isFlon={} ,isFLen={}, fLInID={} }
local isLightOn = false

---------------------------------------------------------------------------------------------------
-- editable variables
---------------------------------------------------------------------------------------------------

local disableFLTex = false -- true=makes the flashlight body not visible (useful for alter attach)
local autoEnableFL = false -- true=the player gets the flashlight without writing commands
local gLightTheta = math.rad(10) -- Theta is the inner cone angle
local gLightPhi = math.rad(40) -- Phi is the outer cone angle
local gLightFalloff = 0.5 -- light intensity attenuation between the phi and theta areas
local gAttenuation = 25 -- light attenuation (max radius)
local gWorldSelfShadow = false -- enables object self shadowing ( may be bugged for rotated objects on a custom map)
local gLightColor = {0.9,0.9,0.7,1.5} -- rgba color of the projected light, light rays and the lightbulb
local switch_key = 'l' -- define the key that switches the light effect
local objID = 15060  -- the object we are going to replace (interior building shadow in this case)

local theTikGap = 1 -- here you set how many seconds to wait after switching the flashlight on/off
local flTimerUpdate = 500 -- the effect update time interval 

local getLastTack = getTickCount ( )-(theTikGap*1000)
local shTeNul = dxCreateShader ( "shaders/shader_null.fx",0,0,false )

---------------------------------------------------------------------------------------------------
-- update the existing lights
---------------------------------------------------------------------------------------------------

addEventHandler("onClientPreRender", root, function()
	for index,this in ipairs(getElementsByType("player")) do
		if flashLiTable.shLight[this] then
			local x1, y1, z1 = getPedBonePosition ( this, 24 )
			local lx1, ly1, lz1 = getPedBonePosition ( this, 25 )
			exports.dynamic_lighting:setLightDirection(flashLiTable.shLight[this],lx1-x1,ly1-y1,lz1-z1,false)
			exports.dynamic_lighting:setLightPosition(flashLiTable.shLight[this],x1,y1,z1)	
		end
	end
end
)

---------------------------------------------------------------------------------------------------
-- create/destroy the effects for flashlight model
---------------------------------------------------------------------------------------------------

function createFlashlightModel(thisPed)
	if not flashLiTable.flModel[thisPed] then	
		flashLiTable.flModel[thisPed] = createObject(objID,0,0,0,0,0,0,true)
		if disableFLTex and shTeNul then
			engineApplyShaderToWorldTexture ( shTeNul, "flashlight_COLOR", flashLiTable.flModel[thisPed] )	
			engineApplyShaderToWorldTexture ( shTeNul, "flashlight_L", flashLiTable.flModel[thisPed] )	
		end
		setElementAlpha(flashLiTable.flModel[thisPed],254)
		exports.bone_attach:attachElementToBone(flashLiTable.flModel[thisPed],thisPed,12,0,0.015,0.2,0,0,0)
	end
end

function destroyFlashlightModel(thisPed)
	if flashLiTable.flModel[thisPed] then			
		exports.bone_attach:detachElementFromBone(flashLiTable.flModel[thisPed])
		if disableFLTex and shTeNul then
			engineRemoveShaderFromWorldTexture ( shTeNul, "*", flashLiTable.flModel[thisPed] )
		end
		destroyElement(flashLiTable.flModel[thisPed])
		flashLiTable.flModel[thisPed]=nil
	end
end

---------------------------------------------------------------------------------------------------
-- Creates / destroys  spot light
---------------------------------------------------------------------------------------------------

function createWorldLight(thisPed)
	if flashLiTable.shLight[thisPed] or ((isSynced==false) and (thisPed~=localPlayer)) then return end
	flashLiTable.shLight[thisPed] = exports.dynamic_lighting:createSpotLight(0,0,3,gLightColor[1],gLightColor[2],gLightColor[3],gLightColor[4],0,0,0,flase,gLightFalloff,gLightTheta,gLightPhi,gAttenuation,gWorldSelfShadow)
end

function destroyWorldLight(thisPed)
	if flashLiTable.shLight[thisPed] then
		flashLiTable.shLight[thisPed] = not exports.dynamic_lighting:destroyLight(flashLiTable.shLight[thisPed])
	end
end

---------------------------------------------------------------------------------------------------
-- Creates / destroys  light bulb and rays effects
---------------------------------------------------------------------------------------------------

function createFlashLightShader(thisPed)
	if not flashLiTable.flModel[thisPed] then return false end
	if not flashLiTable.shLiBul[thisPed] or flashLiTable.shLiRay[thisPed] then
		flashLiTable.shLiBul[thisPed]=dxCreateShader("shaders/shader_lightBulb.fx",1,0,false)
		flashLiTable.shLiRay[thisPed]=dxCreateShader("shaders/shader_lightRays.fx",1,0,true)
		if not flashLiTable.shLiBul[thisPed] or not flashLiTable.shLiRay[thisPed] then
			return
		end		
		engineApplyShaderToWorldTexture ( flashLiTable.shLiBul[thisPed],"flashlight_L", flashLiTable.flModel[thisPed] )
		engineApplyShaderToWorldTexture ( flashLiTable.shLiRay[thisPed], "flashlight_R", flashLiTable.flModel[thisPed] )	
		dxSetShaderValue (flashLiTable.shLiBul[thisPed],"gLightColor",gLightColor)
		dxSetShaderValue (flashLiTable.shLiRay[thisPed],"gLightColor",gLightColor)
	end
end

function destroyFlashLightShader(thisPed)
	if flashLiTable.shLiBul[thisPed] or flashLiTable.shLiRay[thisPed] then
		destroyElement(flashLiTable.shLiBul[thisPed])
		destroyElement(flashLiTable.shLiRay[thisPed])
		flashLiTable.shLiBul[thisPed]=nil
		flashLiTable.shLiRay[thisPed]=nil
	end
end

---------------------------------------------------------------------------------------------------
-- enabling and switching on the flashlight
---------------------------------------------------------------------------------------------------

function playSwitchSound(thisPed)
	pos_x,pos_y,pos_z=getElementPosition (thisPed)
	local flSound = playSound3D("sounds/switch.wav", pos_x, pos_y, pos_z, false) 
	setSoundMaxDistance(flSound,40)
	setSoundVolume(flSound,0.6)
end

function flashLightEnable(isEN,thisPed)
if isEN==true then
		flashLiTable.isFLen[thisPed]=isEN	
	else
		flashLiTable.isFLen[thisPed]=isEN	
	end
end

function flashLightSwitch(isON,thisPed)
if isElementStreamedIn(thisPed) and flashLiTable.isFLen[thisPed] then  playSwitchSound(thisPed) end
if isON then
		flashLiTable.isFlon[thisPed]=true
	else
		flashLiTable.isFlon[thisPed]=false
	end
end


function whenPlayerQuits(thisPed)
	destroyWorldLight(thisPed) 
	destroyFlashlightModel(thisPed) 
	destroyFlashLightShader(thisPed)  
end

---------------------------------------------------------------------------------------------------
-- streaming in/out the flashlight model
---------------------------------------------------------------------------------------------------

addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	if FLenTimer then return end
	FLenTimer = setTimer(	function()
		for index,thisPed in ipairs(getElementsByType("player")) do
			if flashLiTable.fLInID[thisPed]==nil then flashLiTable.fLInID[thisPed]=0 end
			if isElementStreamedIn(thisPed) and flashLiTable.isFLen[thisPed]==true and flashLiTable.fLInID[thisPed]~=getElementInterior(thisPed) then
			triggerServerEvent("onPlayerGetInter",thisPed)
		end
		if  isElementStreamedIn(thisPed) and not flashLiTable.flModel[thisPed] and flashLiTable.isFLen[thisPed]==true then
			createFlashlightModel(thisPed)
			if flashLiTable.fLInID[thisPed]~=nil then setElementInterior ( flashLiTable.flModel[thisPed], flashLiTable.fLInID[thisPed]) end
			end
		if  isElementStreamedIn(thisPed) and flashLiTable.flModel[thisPed] and flashLiTable.isFLen[thisPed]==false then
			destroyFlashlightModel(thisPed)
			end
		if isElementStreamedIn(thisPed) and not flashLiTable.shLiRay[thisPed] and flashLiTable.isFlon[thisPed]==true then 
			createFlashLightShader(thisPed) 
			createWorldLight(thisPed)
			end
		if (isElementStreamedIn(thisPed) or not isElementStreamedIn(thisPed)) and flashLiTable.shLiRay[thisPed] and flashLiTable.isFlon[thisPed]==false then 
			destroyFlashLightShader(thisPed) 
			destroyWorldLight(thisPed)			
			end
		end
	end
	,flTimerUpdate,0 )
end
)

function getPlayerInteriorFromServer(thisPed,interiorID)
	if flashLiTable.flModel[thisPed] then
		flashLiTable.fLInID[thisPed]=interiorID
		if flashLiTable.flModel[thisPed] then setElementInterior ( flashLiTable.flModel[thisPed], flashLiTable.fLInID[thisPed]) end
	end
end

---------------------------------------------------------------------------------------------------
-- switching on / off the flashlight
---------------------------------------------------------------------------------------------------

function toggleLight()
	if (getTickCount ( ) - getLastTack < theTikGap*1000) then outputChatBox('FlashLight: Wait '..theTikGap..' seconds.',255,0,0) return end
	isLightOn = not isLightOn
	triggerServerEvent("onSwitchLight",getLocalPlayer(),isLightOn)
	triggerEvent( "switchFlashLight",resourceRoot,isLightOn)
	getLastTack = getTickCount ( )
end

function toggleFlashLight()
	if flashLiTable.flModel[getLocalPlayer()] then 
		--outputChatBox('You have disabled the flashlight',0,255,0)
		triggerServerEvent("onSwitchLight",getLocalPlayer(),false)
		triggerServerEvent("onSwitchEffect",getLocalPlayer(),false)
		isLightOn = false
		triggerServerEvent('sendAme', getLocalPlayer(), "turns off their flashlight and puts it away")
		triggerServerEvent('realism:tempWalkingStyle', getLocalPlayer(), getElementData(getLocalPlayer(), "walkingstyle"))
	else
		if getPedOccupiedVehicle ( localPlayer ) then
			playSoundFrontEnd(4)
			exports.hud:sendBottomNotification(localPlayer, "Flashlight", "You can not use your flashlight inside vehicles.", 255, 194, 14)
		elseif getPedWeaponSlot ( localPlayer ) ~= 0 then
			playSoundFrontEnd(4)
			exports.hud:sendBottomNotification(localPlayer, "Flashlight", "Your hands are all busy and can't hold your flashlight at the moment.", 255, 194, 14)
		else
			--outputChatBox('You have enabled the flashlight',0,255,0)
			triggerServerEvent("onSwitchLight",getLocalPlayer(),false)
			triggerServerEvent("onSwitchEffect",getLocalPlayer(),true)
			isLightOn = true
			triggerServerEvent("onSwitchLight",getLocalPlayer(),true)
			triggerEvent( "switchFlashLight",resourceRoot,true)
			triggerServerEvent('sendAme', getLocalPlayer(), "takes out their flashlight and turns it on")
			exports.anticheat:changeProtectedElementDataEx(getLocalPlayer(), "walkingstyle", getPedWalkingStyle(getLocalPlayer()), true)
			triggerServerEvent('realism:tempWalkingStyle', getLocalPlayer(), 57)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- events
---------------------------------------------------------------------------------------------------

function weaponSwitch ( prevSlot, newSlot )
	if isLightOn and newSlot ~= 0 then
		playSoundFrontEnd(4)
		exports.hud:sendBottomNotification(localPlayer, "Weapon", "You can not use weapons while holding a flashlight.", 255, 194, 14)
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerWeaponSwitch", localPlayer, weaponSwitch )
	
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	engineImportTXD( engineLoadTXD( "objects/flashlight.txd" ), objID ) 
	engineReplaceModel ( engineLoadDFF( "objects/flashlight.dff", 0 ), objID,true)
	triggerServerEvent("onPlayerStartRes",getLocalPlayer())
	exports.dynamic_lighting:setWorldNormalShading(false)
end
)

addEventHandler("onClientResourceStop", getResourceRootElement( getThisResource()), function()
	for index,this in ipairs(getElementsByType("player")) do
		if flashLiTable.shLight[this] then
			destroyWorldLight(this)
		end
	end
end
)

addEvent( "flashOnPlayerEnable", true )
addEvent( "flashOnPlayerQuit", true )
addEvent( "flashOnPlayerSwitch", true )
addEvent( "flashOnPlayerInter", true)
addEventHandler( "flashOnPlayerQuit", getResourceRootElement( getThisResource()), whenPlayerQuits)
addEventHandler( "flashOnPlayerSwitch", getResourceRootElement( getThisResource()), flashLightSwitch)
addEventHandler( "flashOnPlayerEnable", getResourceRootElement( getThisResource()), flashLightEnable)
addEventHandler( "flashOnPlayerInter", getResourceRootElement( getThisResource()), getPlayerInteriorFromServer)