local billboardZone = createColCuboid ( 1761.7845703125, -2204.3837890625, 0, 400, 750, 200 )
setElementDimension (billboardZone, 0)
setElementInterior (billboardZone, 0)
local link = "https://www.youtube.com/tv#/watch/video/idle?v=lf_wVfwpfp8"

function EnterBillboardZone(thePlayer, matchingDimension)
	if getElementType ( thePlayer ) == "player" then
		triggerClientEvent ( thePlayer, "billboard:show", thePlayer)
		triggerClientEvent ( thePlayer, "billboard:loadLink", thePlayer, link )
	end
end
addEventHandler ( "onColShapeHit", billboardZone, EnterBillboardZone )

function ExitBillboardZone(thePlayer, matchingDimension)
	if getElementType ( thePlayer ) == "player" then
		triggerClientEvent ( thePlayer, "billboard:destroyBrowser", thePlayer)
	end
end
addEventHandler ( "onColShapeLeave", billboardZone, ExitBillboardZone )