
-- WATCH

screenImage = nil
image = nil
name = ''
label = nil
local screenWidth, screenHeight = guiGetScreenSize( )
addEvent( "updateScreen", true )
addEventHandler( "updateScreen", root,
	function ( imageData, player )
		if fileExists( "temp.jpg" ) then
			fileDelete ( "temp.jpg" )
		end
		screenImage = fileCreate("temp.jpg")
		fileWrite(screenImage, imageData )            
		fileClose(screenImage)
		name = '( ' .. getElementData( player, "playerid" ) .. ' ) ' .. getPlayerName( player ):gsub("_", " ")
		if not image then
			image = guiCreateStaticImage( screenWidth - 210, 10, 200, 200, "temp.jpg", false )
			label = guiCreateLabel( screenWidth - 210, 210, 200, 30, name, false)
		end
		
	end
)

addEvent( "stopScreen", true )
addEventHandler( "stopScreen", root,
	function ( )
		if image then
			destroyElement( image )
			destroyElement( label )
		end
		image = nil
	end
)

addEventHandler( "onClientRender", root,
    function()
		if image then
			guiStaticImageLoadImage ( image, "temp.jpg" )
			guiSetText( label, name )
		end
    end
)
