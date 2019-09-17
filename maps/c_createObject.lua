_c=createObject

function createObject(m,x,y,z,a,b,c,i,d,lod)
	local t
	if lod then
		t=_c(m,x,y,z,a,b,c,true)
	else
		t=_c(m,x,y,z,a,b,c)
	end
	if d then
		setElementDimension(t,d)
	end
	if i then
		setElementInterior(t,i)
	end
	--setElementData(v, "collisions", "true")
	if isElement(source) then
		setElementCollisionsEnabled(source, true)
	end
	return t
end

function cleanUp()
	removeWorldModel(4019, 50, 1777.9000244141, -1773.9000244141, 12.5) 
	removeWorldModel(4025, 50, 1777.9000244141, -1773.9000244141, 12.5)
	removeWorldModel(4215, 50, 1777.5999755859, -1775.0999755859, 36.700000762939)
end
addEventHandler("onClientResourceStart", resourceRoot, cleanUp)