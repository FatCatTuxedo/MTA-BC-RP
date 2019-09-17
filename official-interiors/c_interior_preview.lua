local showIntPreview = false

addEvent( "onClientGotImage", true )
addEventHandler( "onClientGotImage", resourceRoot,
    function( pixels )
        if myTexture then
            destroyElement( myTexture )
        end
        myTexture = dxCreateTexture( pixels )
    end
)
 --[[
addEventHandler("onClientRender", root, function()
	if getElementData(localPlayer, "official-interiors:showIntPreviewer") then
		local sx, sy = guiGetScreenSize()
		local w,h = 600, 187--dxGetMaterialSize( myTexture )
		local px, py = (sx-w)/2, (sy*0.80)-h
		if myTexture then
			dxDrawImage( px, py, w, h, myTexture )
		else
			dxDrawImage( px, py, w, h, ":resources/int_loading.jpg" )
		end
	end
end)
]]
function toggleInteriorPreviewer(state)
	showIntPreview = state
end