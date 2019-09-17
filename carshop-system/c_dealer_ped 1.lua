 -- MAXIME
 
--GROTTI PED
local localPlayer = getLocalPlayer()
local grottiPed = createPed( 147, 527.6103515625, -1293.4130859375, 17.2421875 )
setPedRotation( grottiPed, 0 )
setElementDimension( grottiPed, 0)
setElementInterior( grottiPed , 0 )
setElementData( grottiPed, "talk", 1, false )
setElementData( grottiPed, "name", "Christopher Jackson", false )
setElementData( grottiPed, "carshop", "grotti", false )
setPedAnimation ( grottiPed, "COP_AMBIENT", "Coplook_loop" , -1, true, false, false )
setElementFrozen(grottiPed, true)