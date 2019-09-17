-- Made with love by Shmorf
-- Copyright (c), Immersion Gaming.

mysql = exports.mysql

function SmallestID ( )
    local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM ramps AS e1 LEFT JOIN ramps AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
    if result then
        local id = tonumber(result["nextID"]) or 1
        return id
    end
    return false
end

function ramp_init ( )
    local result = mysql:query ( "SELECT * FROM ramps" )
    
    if result then
       while true do
            local row = mysql:fetch_assoc ( result )
            if not row then break end
            
            ramp_load ( row.id )
        end
        
        mysql:free_result ( result )
    else
        exports.global:sendMessageToAdmins ( "AdmWarn: Failed to select ramps from MySQL Database, please panic." )
    end
	
	removeWorldModel(2053, 10000, 0, 0, 0)
	removeWorldModel(2054, 10000, 0, 0, 0)
end

function ramp_load ( id )
    local row = mysql:query_fetch_assoc ( "SELECT * FROM ramps WHERE id = " .. id )
    
    if row then
        for k, v in pairs( row ) do
            if v == null then
                row[k] = nil
            else
                row[k] = tonumber(v) or v
            end
        end
        
        local x, y, z = unpack ( fromJSON ( row.position ) )
        local rz = row.rotation
		local int = row.interior
		local dim = row.dimension
        
        local frame = createObject ( 2052, x, y, z, 0, 0, rz )
        local lift = createObject ( 2053, x, y, z, 0, 0, rz )
		
		setElementDimension(frame, dim)
		setElementDimension(lift, dim)
		setElementInterior(frame, int)
		setElementInterior(lift, int)
        
        if tonumber ( row.state ) == 1 then
            setElementPosition ( lift, x, y, z + 2.5 )
            setElementData ( frame, "lift.up", true )
        else
            setElementPosition ( lift, x, y, z + 0.17 )
        end
        
        setElementData ( frame, "garagelift", true )
        setElementData ( frame, "lift", lift )
        setElementData ( frame, "dbid", tonumber ( id ) )
        setElementData ( frame, "creator", row.creator )
    end
end

function getNearbyRamps ( p )
	if exports.integration:isPlayerTrialAdmin(p) then
    
		local px, py, pz = getElementPosition ( p )
		local dimension = getElementDimension ( p )
		local count = 0
		
		outputChatBox ( "Nearby Ramps:", p, 255, 126, 0, false )
		
		for i,v in ipairs ( getElementsByType ( "object" ) ) do
			if getElementData ( v, "garagelift" ) and getElementDimension ( v ) == dimension then
				local x, y, z = getElementPosition ( v )
				local distance = getDistanceBetweenPoints3D ( px, py, pz, x, y, z )
				
				if distance < 11 then
					local dbid = getElementData ( v, "dbid" )
					local creator = getElementData ( v, "creator" )
					
					outputChatBox ( " ID " .. dbid .. " | Creator: " .. creator, p, 255, 126, 0, false )
					count = count + 1
				end
			end
		end
		
		if count == 0 then
			outputChatBox ( "   None.", p, 255, 126, 0, false )
		end
	end
end
addCommandHandler ( "nearbyramps", getNearbyRamps )

function gotoRamp ( p, commandName, target )
    if exports.integration:isPlayerTrialAdmin(p) then
	if not target then
		outputChatBox("SYNTAX: /" .. commandName .. " [Ramp ID]", p, 255, 194, 14)
		else
		for i,v in ipairs ( getElementsByType ( "object" ) ) do
			if getElementData ( v, "garagelift" ) then
				local dbid = getElementData ( v, "dbid" )
				if (tonumber(target) == tonumber(dbid)) then
				local x, y, z = getElementPosition ( v )
				local int = getElementInterior ( v )
				local dim = getElementDimension ( v )
					
				setElementPosition(p, x, y, z)
				setElementInterior(p, int)
				setElementDimension(p, dim)
				
				outputChatBox ( "Teleported to ramp ID " .. dbid .. ".", p, 255, 126, 0, false )
				end
			end
		end
	end
	end
end
addCommandHandler ( "gotoramp", gotoRamp )

addEventHandler ( "onResourceStart", resourceRoot, ramp_init )