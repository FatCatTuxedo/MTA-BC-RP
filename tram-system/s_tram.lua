addEventHandler ("onResourceStart", resourceRoot,
function ()
	Tram01		= createVehicle (449, -2265, 548, 35)
	Tramdriver01	= createPed     (255, -2265, 548, 35)
	Tramblip01	= createBlipAttachedTo ( Tram01, 0, 2, 100, 0, 0, 255, 0, 99999.0, getRootElement())
	setTrainDerailable(Tram01, false)
	warpPedIntoVehicle (Tramdriver01, Tram01)

	Tram02		= createVehicle (449, -1990, 1308, 8)
	Tramdriver02	= createPed     (255, -1990, 1308, 8)
	Tramblip02	= createBlipAttachedTo ( Tram02, 0, 2, 100, 0, 0, 255, 0, 99999.0, getRootElement())
	setTrainDerailable(Tram02, false)
	warpPedIntoVehicle (Tramdriver02, Tram02)

	Tram03		= createVehicle (449, -1868, 597, 35)
	Tramdriver03	= createPed     (255, -1868, 597, 35)
	Tramblip03	= createBlipAttachedTo ( Tram03, 0, 2, 100, 0, 0, 255, 0, 99999.0, getRootElement())
	setTrainDerailable(Tram03, false)
	warpPedIntoVehicle (Tramdriver03, Tram03)

	setTimer ( Tramcontroler, 50, 0 )
end
)

function Tramcontroler()
	t01x, t01y, t01z	= getElementPosition ( Tram01 )
	t02x, t02y, t02z	= getElementPosition ( Tram02 )
	t03x, t03y, t03z	= getElementPosition ( Tram03 )

	t01s			= getTrainSpeed( Tram01 )
	t02s			= getTrainSpeed( Tram02 )
	t03s			= getTrainSpeed( Tram03 )

	tramdistance0102	= getDistanceBetweenPoints3D ( t01x, t01y, t01z, t02x, t02y, t02z )
	tramdistance0203	= getDistanceBetweenPoints3D ( t02x, t02y, t02z, t03x, t03y, t03z )
	tramdistance0301	= getDistanceBetweenPoints3D ( t03x, t03y, t03z, t01x, t01y, t01z )

	if tramdistance0102 > 30 then

		setTrainSpeed( Tram02, 0.3 )
	end
	if tramdistance0102 < 30 then
		setTrainSpeed( Tram02, 0.2)
	end
	if tramdistance0102 < 25 then
		setTrainSpeed( Tram02, 0.1)
	end
	if tramdistance0102 < 20 then
		setTrainSpeed( Tram02, 0.0)
	end

	if tramdistance0203 > 30 then
		setTrainSpeed( Tram03, 0.3 )
	end
	if tramdistance0203 < 30 then
		setTrainSpeed( Tram03, 0.2)
	end
	if tramdistance0203 < 25 then
		setTrainSpeed( Tram03, 0.1)
	end
	if tramdistance0203 < 20 then
		setTrainSpeed( Tram03, 0.0)
	end

	if tramdistance0301 > 30 then
		setTrainSpeed( Tram01, 0.3 )
	end
	if tramdistance0301 < 30 then
		setTrainSpeed( Tram01, 0.2)
	end
	if tramdistance0301 < 25 then
		setTrainSpeed( Tram01, 0.1)
	end
	if tramdistance0301 < 20 then
		setTrainSpeed( Tram01, 0.0)
	end
end