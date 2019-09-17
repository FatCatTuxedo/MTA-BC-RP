local notes = {}

function bindND()
  bindKey ( "ralt", "down", showNearbyNoteDescriptions )
  bindKey ( "lalt", "down", showNearbyNoteDescriptions )
  bindKey ( "ralt", "up", removeND )
  bindKey ( "lalt", "up", removeND )
end
addEventHandler ( "onClientResourceStart", resourceRoot, bindND )

function removeND( key, keyState )
	removeEventHandler ( "onClientRender", getRootElement(), showText )
end

function showNearbyNoteDescriptions()
	for index, nearbyVehicle in ipairs( exports.global:getNearbyElements(getLocalPlayer(), "object") ) do
		if isElement(nearbyVehicle) then
			if (getElementData(nearbyVehicle, "itemID")==72) then
				local itemValue = getElementData(nearbyVehicle, "itemValue")
				--outputChatBox("haha")
				--outputChatBox(itemValue)
				notes[index] = nearbyVehicle
				
			end
		end
	end
	addEventHandler("onClientRender", getRootElement(), showText)
end

function checkCheck()
	outputDebugString(notes)
end
addCommandHandler("checkcheck", checkCheck)


function showText()
	for i = 1, #notes, 1 do
		local theObject = notes[i]
		if isElement(theObject) then
			local x,y,z = getElementPosition(theObject)
			local cx, cy, cz = getCameraMatrix()
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= 15 then
				local px,py,pz = getScreenFromWorldPosition(x,y,z+1,0.05)
				--outputDebugString("px: " ..px)
				--outputDebugString("py: " ..py)
				--outputDebugString("pz: " ..pz)
				--outputDebugString("x: " ..x)
				--outputDebugString("y: " ..y)
				--outputDebugString("z: " ..z)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, false, false, false, true, true, false, false) then
					local lines = 0
					local toBeShowed = ""
					local itemValue = getElementData(theObject, "itemValue")
					if itemValue then
						toBeShowed = toBeShowed.."The note reads:\n"..itemValue
						lines = lines + 2
						-- description shit + size, I guess.
						local font = "default-bold"
						local fontWidth = 50
						for j = 1, 1 do
							local desc = toBeShowed
							if desc and desc ~= "" then
								len = dxGetTextWidth(desc)
								--outputDebugString("Len 1: "..len)
								if len > fontWidth then
									fontWidth = len
								end
								--toBeShowed = toBeShowed.."\n"..desc
								--lines = lines + 1
							end
							if fontWidth < 75 then
								fontWidth = 75
							end
						end
						--[[if string.len(toBeShowed) > 50 then
							local content1 = string.sub(content,1,55)
							local content2 = string.sub(content,56)
							toBeShowed = content1.."\n"..content2
							lines = lines + 1
						end]]
						local fucker = false
						if string.len(toBeShowed) > 75 then
							local content1 = string.sub(toBeShowed,1,85)
							local content2 = string.sub(toBeShowed,86)
							fontWidth = len - 229
							toBeShowed = content1.."\n"..content2
							lines = lines + 1
							if string.len(content2) > 75 then
								fucker = true
								content3 = string.sub(content2,1,85)
								content4 = string.sub(content2,86)
								toBeShowed = content1.."\n"..content3.."\n"..content4
								lines = lines + 2
								fontWidth = len - 229
							end
						end
						--outputDebugString("fWidth: "..fontWidth)
						-- start teh drawing, my friend.
						local marg = 5
						local oneLineHeight = dxGetFontHeight(1, toBeShowed)
						local fontHeight = oneLineHeight * lines
						px = px-(fontWidth/2)
						if not fucker then
						dxDrawRectangle(px-marg, py-marg, fontWidth+(marg*2), fontHeight+(marg*2), tocolor(0, 0, 0, 100))
						dxDrawRectangleBorder(px-marg, py-marg, fontWidth+(marg*2), fontHeight+(marg*2), 1, tocolor(255, 255, 255, 100), true)
						end
						dxDrawText(toBeShowed, px, py, px + fontWidth, (py + fontHeight), tocolor(255, 255, 255, 255), 1, "bold", "left")
					end
				end
			end
		end
	end
end
function dxDrawRectangleBorder(x, y, width, height, borderWidth, color, out, postGUI)
	if out then
		--[[Left]]	dxDrawRectangle(x - borderWidth, y, borderWidth, height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width, y, borderWidth, height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x - borderWidth, y - borderWidth, width + (borderWidth * 2), borderWidth, color, postGUI)
		--[[Botm]]	dxDrawRectangle(x - borderWidth, y + height, width + (borderWidth * 2), borderWidth, color, postGUI)
	else
		local halfW = width / 2
		local halfH = height / 2
		--[[Left]]	dxDrawRectangle(x, y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width - math.clip(0, borderWidth, halfW), y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y, width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
		--[[Botm]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y + height - math.clip(0, borderWidth, halfH), width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
	end
end