local possibleLicenses = {
	--[database field] = text
	gun_license = 'Firearm License - Tier 1',
	gun2_license = 'Firearm License - Tier 2',
	car_license = 'Driver\'s License - Automotive',
	bike_license = 'Driver\'s License - Motorbike',
	--pilot_license = 'San Andreas Pilot Certificate',
	fish_license = 'Fishing Permit',
	boat_license = 'Driver\'s License - Boat',
}

local PD_VEHICLES = { 427, 490, 528, 523, 598, 596, 597, 599, 601 }
local resourceName = getResourceName( getThisResource( ) )


-- CACHE (Exciter) --
mdc_users = {}
mdc_criminals = {}
mdc_faa_licenses = {}

function cacheOnStart()
	--mdc_users
	--[[
	local result = exports.mysql:query("SELECT * FROM `mdc_users`")
	if result then
		while true do
			local row = exports.mysql:fetch_assoc(result)
			if not row then break end
			table.insert(mdc_users, { id = row.id, user = row.user, pass = md5(row.pass), level = row.level, organization = row.organization })
		end
		exports.mysql:free_result(result)
	end
	--]]
	
	--mdc_faa_licenses
	local startTime = getTickCount()
	local result = exports.mysql:query("SELECT * FROM `mdc_faa_licenses`")
	if result then
		local theTable = {}
		while true do
			row = exports.mysql:fetch_assoc(result)
			if not row then break end
			local thisValues = {}
			for key,value in pairs(row) do
				thisValues[key] = value
			end
			table.insert(theTable, thisValues)
		end
		mdc_faa_licenses = theTable
		exports.mysql:free_result(result)
		outputDebugString("Loaded "..tostring(#mdc_faa_licenses).." pilot licenses in "..tostring(math.ceil(getTickCount()-startTime)).."ms.")
	else
		outputDebugString("mdc-system/mdc.lua: Failed to load pilot licenses!",2)
	end

end
addEventHandler("onResourceStart", getResourceRootElement(), cacheOnStart)

------------------------------------------
function loginMDC( user, pass )
	user = exports.mysql:escape_string( user )
	pass = exports.mysql:escape_string( pass )
	local account = exports.mysql:query( "SELECT * FROM mdc_users WHERE `user` = '"..user.."' AND `pass` = '"..pass.."'" )
	if exports.mysql:num_rows( account ) > 0 then
		local row = exports.mysql:fetch_assoc( account )
		return row
	else
		return 0
	end
end

function getMDCNameFromID( id )
	local row = nil
	local result = exports.mysql:query( "SELECT * FROM mdc_users WHERE `id` = '"..id.."'" )
	if exports.mysql:num_rows( result ) > 0 then
		row = exports.mysql:fetch_assoc( result )
		exports.mysql:free_result( result )
		return row.user
	else
		return false
	end
end

------------------------------------------
function login( user, pass )
	local account = nil
	if user == nil or pass == nil then
		outputChatBox( "SYNTAX: /".. command .." [username] [password]", source, 155, 155, 255 )
	else
		user = exports.mysql:escape_string( user )
		pass = exports.mysql:escape_string( pass )
		
		local accountQuery = exports.mysql:query( "SELECT * FROM mdc_users WHERE `user` = '"..user.."' AND `pass` = '"..pass.."'" )
		if exports.mysql:num_rows( accountQuery ) > 0 then
			account = exports.mysql:fetch_assoc( accountQuery )
			setElementData( source, "mdc_account", tonumber( account.id ) )
			setElementData( source, "mdc_admin", tonumber( account.level ) )
			setElementData( source, "mdc_org", tostring(account.organization))
			main( )
		else
			outputChatBox( "The information you entered was incorrect.", source, 255, 155, 155 )
		end
	end	
end

function main ( )
	local warrants = { }
	local apb = { }
	local calls = { }
	
	local warrantResult = exports.mysql:query( "SELECT `character`,`wanted_by`,`wanted_details` FROM `mdc_criminals` WHERE `wanted` = '1'" )
	if ( warrantResult ) then
		local count = 1
		while true do
			row = exports.mysql:fetch_assoc( warrantResult )
			if not row then break end
			warrants[count] = { }
			
			--Fetch character name from ID
			local char = nil
			local characterResult = exports.mysql:query( "SELECT `charactername` FROM `characters` WHERE `id` = '".. exports.mysql:escape_string( row.character ) .."'" )
			if exports.mysql:num_rows( characterResult ) > 0 then
				char = exports.mysql:fetch_assoc( characterResult )
			end
			warrants[count][1] = char.charactername
			
			--Fetch mdc account name from ID
			local account = nil
			local accountResult = exports.mysql:query( "SELECT `user`,`organization` FROM mdc_users WHERE `id` = '".. exports.mysql:escape_string( row.wanted_by ) .."'" )
			if exports.mysql:num_rows( accountResult ) > 0 then
				account = exports.mysql:fetch_assoc( accountResult )
			end
			warrants[count][3] = account and account.user or "Unknown"
			warrants[count][4] = account and account.organization or "Unknown"
			warrants[count][2] = row.wanted_details
			count = count + 1
		end
		exports.mysql:free_result( warrantResult )
	end
	
	local apbResult = exports.mysql:query( "SELECT * FROM `mdc_apb`" )
	if ( apbResult ) then
		local count = 1
		while true do
			row = exports.mysql:fetch_assoc( apbResult )
			if not row then break end
			apb[count] = { }
			
			apb[count][1] = row.person_involved
			
			--Fetch mdc account name from ID
			local account = nil
			local accountResult = exports.mysql:query( "SELECT `user` FROM mdc_users WHERE `id` = '".. exports.mysql:escape_string( row.doneby ) .."'" )
			if exports.mysql:num_rows( accountResult ) > 0 then
				account = exports.mysql:fetch_assoc( accountResult )
			end
			apb[count][3] = account and account.user or "Unknown"
			apb[count][2] = row and row.description or "Unknown"
			apb[count][4] = row and row.id or "Unknown"
			apb[count][5] = row and row.organization or "Unknown"
			count = count + 1
		end
		exports.mysql:free_result( apbResult )
	end
	
	local callsResult = exports.mysql:query( "SELECT m.id, m.number, m.description, m.timestamp, c.charactername FROM `mdc_calls` m LEFT OUTER JOIN `mdc_criminals` t ON m.number = t.phone LEFT OUTER JOIN characters c ON c.id = t.character ORDER BY m.id DESC LIMIT 20" )
	if ( callsResult ) then
		while true do
			row = exports.mysql:fetch_assoc( callsResult )
			if not row then break end

			table.insert(calls, { row.id, row.charactername, row.number, row.description, row.timestamp })
		end
		exports.mysql:free_result( callsResult )
	end
	
	
	triggerClientEvent( source, resourceName .. ":main", getRootElement(), warrants, apb, calls ) 
end

function search( query, queryType )
	queryType = tonumber( queryType )
	if queryType == -1 then --No type selected.
		triggerClientEvent( source, resourceName .. ":search_error", getRootElement() )
	elseif queryType == 0 then --Person
		local character = nil
		local criminal = nil
		local wantedUser = nil
		local crimesRow = nil
		
		local result = exports.mysql:query( "SELECT * FROM characters WHERE `charactername` = '".. exports.mysql:escape_string( query:gsub( " ", "_" ) ) .."'" ) --Fetch the information from the database about our character.
		
		
		if exports.mysql:num_rows( result ) > 0 then
			character = exports.mysql:fetch_assoc( result )
			local result2 = exports.mysql:query( "SELECT * FROM `mdc_criminals` WHERE `character` = '".. character.id .."'" ) --Select what the PD already knows about this character.
			
			if exports.mysql:num_rows( result2 ) > 0 then --This MDC profile has been visited before.
				criminal = exports.mysql:fetch_assoc( result2 )
			else -- Nobody has gone to this person's MDC, so lets create a template for them to add information to.
				local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_criminals` ( `character` ) VALUES ('"..character.id.."')" ) 
				local result2 = exports.mysql:query( "SELECT * FROM `mdc_criminals` WHERE `character` = '".. character.id .."'" ) --Select what the PD already knows about this character.
				if query then
					if exports.mysql:num_rows( result2 ) > 0 then --This MDC profile has been visited before.
						criminal = exports.mysql:fetch_assoc( result2 )
					end
				end
			end
			
			
			
			if tonumber( criminal.wanted ) == 1 then
				local result3 = exports.mysql:query( "SELECT `user` FROM mdc_users WHERE `id` = '".. exports.mysql:escape_string( criminal.wanted_by ) .."'" ) --We need to figure out the wanted by's name!
				if exports.mysql:num_rows( result3 ) > 0 then
					wantedUser = exports.mysql:fetch_assoc( result3 )
				end
				criminal.wanted_by = wantedUser.user
			end
			
			local vehicles = { }
			local result4 = exports.mysql:query( "SELECT v.id, v.model, `plate`, c.vehbrand, c.vehmodel, c.vehyear FROM `vehicles` v LEFT JOIN vehicles_shop c ON v.vehicle_shop_id = c.id WHERE `owner` = '".. character.id .."' AND deleted = 0 AND registered = 1" )
			if ( result4 ) then
				local count = 1
				local isFAA = getElementData(source, "mdc_org") == "FAA" or false
				while true do
					row = exports.mysql:fetch_assoc( result4 )
					if not row then break end
					vehicles[count] = { }
					if isFAA then --FAA only get aircrafts listed
						if(getVehicleType(tonumber(row.model)) == "Plane" or getVehicleType(tonumber(row.model)) == "Helicopter") then
							vehicles[count][1] = row.id
							if row.vehbrand and row.vehmodel and row.vehyear and row.vehbrand ~= mysql_null() and row.vehmodel ~= mysql_null() and row.vehyear ~= mysql_null() then
								vehicles[count][2] = row.vehyear .. " " .. row.vehbrand .. " " .. row.vehmodel
							else
								vehicles[count][2] = row.model
							end
							vehicles[count][3] = row.plate
							count = count + 1
						end
					else
						vehicles[count][1] = row.id
						if row.vehbrand and row.vehmodel and row.vehyear and row.vehbrand ~= mysql_null() and row.vehmodel ~= mysql_null() and row.vehyear ~= mysql_null() then
							vehicles[count][2] = row.vehyear .. " " .. row.vehbrand .. " " .. row.vehmodel
						else
							vehicles[count][2] = row.model
						end
						vehicles[count][3] = row.plate
						count = count + 1
					end
				end
				
				exports.mysql:free_result( result4 )
			end
			
			local properties = { }
			local result5 = exports.mysql:query( "SELECT `id`, `name` FROM `interiors` WHERE `owner` = '".. character.id .."'" )
			if ( result5 ) then
				local count = 1
				while true do
					row = exports.mysql:fetch_assoc( result5 )
					if not row then break end
					properties[count] = { }
					properties[count][1] = row.id
					properties[count][2] = row.name
					count = count + 1
					
				end
				
				exports.mysql:free_result( result5 )
			end
			
			local crimes = { }
			local result6 = exports.mysql:query( "SELECT * FROM `mdc_crimes` WHERE `character` = '".. character.id .."' ORDER BY `id` DESC" )
			if ( result6 ) then
				local count = 1
				while true do
					row = exports.mysql:fetch_assoc( result6 )
					if not row then break end
					crimes[count] = { }
					crimes[count][1] = row.id
					crimes[count][2] = row.crime
					crimes[count][3] = row.punishment
					crimes[count][4] = getMDCNameFromID( row.officer )
					crimes[count][5] = row.timestamp
					count = count + 1
					
				end
				
				exports.mysql:free_result( result5 )
			end

			local licenses = {}
			for dbfield, name in pairs(possibleLicenses) do
				local val = tonumber(character[dbfield])
				if val == 1 then
					table.insert(licenses, name)
				elseif val ~= 0 then
					outputDebugString('MDC: Database field ' .. dbfield .. ' for characters doesnt exist')
				end
			end

			local pilotEvents = { }
			local pilotLicenses = { }
			if(getElementData(source, "mdc_org") == "FAA") then
				local result7 = exports.mysql:query( "SELECT * FROM `mdc_faa_events` WHERE `character` = '".. character.id .."' ORDER BY `id` DESC" )
				if ( result7 ) then
					local count = 1
					while true do
						row = exports.mysql:fetch_assoc( result7 )
						if not row then break end
						pilotEvents[count] = { }
						pilotEvents[count][1] = row.id
						pilotEvents[count][2] = row.crime
						pilotEvents[count][3] = row.punishment
						pilotEvents[count][4] = getMDCNameFromID( row.officer )
						pilotEvents[count][5] = row.timestamp
						count = count + 1
					end

					exports.mysql:free_result( result7 )
				end

				if mdc_faa_licenses then
					local result8 = {}
					for k,v in ipairs(mdc_faa_licenses) do
						if(tonumber(v.character) == tonumber(character.id)) then
							table.insert(result8, v)
						end
					end
					local count = 1
					for k,row in ipairs(result8) do
						if not row then break end
						--outputDebugString(" id="..tostring(row.id).." license="..tostring(row.license).." value="..tostring(row.value).." officer="..tostring(row.officer).." timestamp="..tostring(row.timestamp))
						pilotLicenses[count] = { }
						pilotLicenses[count][1] = row.id
						pilotLicenses[count][2] = row.license
						pilotLicenses[count][3] = row.value
						pilotLicenses[count][4] = getMDCNameFromID( row.officer )
						pilotLicenses[count][5] = row.timestamp
						count = count + 1
					end					
				else
					local result8 = exports.mysql:query( "SELECT * FROM `mdc_faa_licenses` WHERE `character` = '".. character.id .."' ORDER BY `id` ASC" )
					if ( result8 ) then
						local count = 1
						while true do
							row = exports.mysql:fetch_assoc( result8 )
							if not row then break end
							pilotLicenses[count] = { }
							pilotLicenses[count][1] = row.id
							pilotLicenses[count][2] = row.license
							pilotLicenses[count][3] = row.value
							pilotLicenses[count][4] = getMDCNameFromID( row.officer )
							pilotLicenses[count][5] = row.timestamp
							count = count + 1
						end
						exports.mysql:free_result( result8 )
					end
				end
			end
			
			triggerClientEvent( source, resourceName .. ":display_person", getRootElement(), character.charactername, character.age, character.weight, character.height, character.gender, licenses, character.pdjail, criminal.dob, criminal.ethnicity, criminal.phone, criminal.occupation, criminal.address, criminal.photo, criminal.details, criminal.created_by, criminal.wanted, criminal.wanted_by, criminal.wanted_details, character.id, vehicles, properties, crimes, pilotEvents, criminal.pilot_details, pilotLicenses ) 
			
			exports.mysql:free_result( result )
		else
			triggerClientEvent( source, resourceName .. ":search_noresult", getRootElement() )
		end
	elseif queryType == 1 or queryType == 3 then --Vehicle
		local q = ""
		if queryType == 1 then
			q = "v.plate = '".. exports.mysql:escape_string( query ) .. "'"
		elseif queryType == 3 then
			q = "v.id = '".. exports.mysql:escape_string( query ) .. "'"
		else
			return false
		end

		local vehicle = nil
		
		local result = exports.mysql:query( "SELECT v.*, c.vehbrand, c.vehmodel, c.vehyear FROM `vehicles` v LEFT JOIN vehicles_shop c ON v.vehicle_shop_id = c.id WHERE " .. q .. " AND deleted = 0 AND registered = 1" ) --Fetch the information from the database 
		if exports.mysql:num_rows( result ) > 0 then
			vehicle = exports.mysql:fetch_assoc( result )
			
			local crimes = { }
			local result2 = exports.mysql:query( "SELECT * FROM `speedingviolations` WHERE `carID` = '".. vehicle.id .."' ORDER BY `id` DESC" )
			if ( result2 ) then
				local count = 1
				while true do
					row = exports.mysql:fetch_assoc( result2 )
					if not row then break end
					crimes[count] = { }
					crimes[count][1] = row.time
					crimes[count][2] = row.speed
					crimes[count][3] = row.area
					crimes[count][4] = exports.cache:getCharacterName(row["personVisible"]) or "Not visible"
					count = count + 1
					
				end
				exports.mysql:free_result( result2 )
			end
			
			if tonumber( vehicle.owner ) ~= -1 then
				local owner = nil
				local result3 = exports.mysql:query( "SELECT `charactername` FROM `characters` WHERE `id` = '".. exports.mysql:escape_string( vehicle.owner ).."'" )
				if exports.mysql:num_rows( result3 ) > 0 then
					owner = exports.mysql:fetch_assoc( result3 )
				end
				vehicle.owner = owner.charactername
				vehicle.owner_type = 1
			elseif tonumber( vehicle.faction ) ~= -1 then
				local owner = nil
				local result3 = exports.mysql:query( "SELECT `name` FROM `factions` WHERE `id` = '".. exports.mysql:escape_string( vehicle.faction ).."'" )
				if exports.mysql:num_rows( result3 ) > 0 then
					owner = exports.mysql:fetch_assoc( result3 )
				end
				vehicle.owner = owner.name
				vehicle.owner_type = 2
			else
				vehicle.owner = "None"
				vehicle.owner_type = 0
			end

			if vehicle.vehbrand and vehicle.vehmodel and vehicle.vehyear and vehicle.vehbrand ~= mysql_null() and vehicle.vehmodel ~= mysql_null() and vehicle.vehyear ~= mysql_null() then
				local mtamodelname = getVehicleNameFromModel(tonumber(vehicle.model))
				vehicle.model = vehicle.vehyear .. " " .. vehicle.vehbrand .. " " .. vehicle.vehmodel .. " (("..tostring(mtamodelname).."))"
			end
			triggerClientEvent( source, resourceName .. ":display_vehicle", getRootElement(), vehicle.id, vehicle.model, vehicle.color1, vehicle.color2, vehicle.color3, vehicle.color4, vehicle.plate, vehicle.faction, vehicle.owner, vehicle.owner_type, vehicle.impounded, vehicle.stolen, crimes )
		else
			triggerClientEvent( source, resourceName .. ":search_noresult", getRootElement() )
		end
	elseif queryType == 2 then --Property
		local result = exports.mysql:query( "SElECT * FROM interiors WHERE `id` = '"..exports.mysql:escape_string( query ).."'" )
		if exports.mysql:num_rows( result ) > 0 then
			interior = exports.mysql:fetch_assoc( result )
			if tonumber( interior.type ) == 0 then
				interior.type = "House"
			elseif tonumber( interior.type ) == 1 then
				interior.type = "Business"
			elseif tonumber( interior.type ) == 2 then
				interior.type = "Government"
			else
				interior.type = "Apartment"
			end
			local owner = exports.cache:getCharacterName( interior.owner ) or "N/A"
			local district = getZoneName ( interior.x, interior.y, interior.z, false ) .. ", " .. getZoneName ( interior.x, interior.y, interior.z, true )
			triggerClientEvent ( source, resourceName .. ":display_property", getRootElement(), interior.id, interior.type, owner, interior.cost, interior.name, district )
		else
			triggerClientEvent( source, resourceName .. ":search_error", getRootElement() )
		end
	else --This wasn't called by the client GUI, and therefore do nothing.
		return false
	end
end

function add_crime( charid, charactername, crime, punishment )
	local officer = getElementData( source, "mdc_account" )
	local time = getRealTime( )
	local timestamp = time.timestamp
	local addCrime = exports.mysql:query_insert_free( "INSERT INTO `mdc_crimes` ( `crime`, `punishment`, `character`, `officer`, `timestamp` ) VALUES ( '"..exports.mysql:escape_string( crime ).."','"..exports.mysql:escape_string( punishment ).."','"..charid.."','"..officer.."', '"..timestamp.."' )" )
	if addCrime and officer ~= 532 then
		search( charactername, 0 )
	end
end
	
function add_apb( description, person )
	local officer = getElementData( source, "mdc_account" )
	local time = getRealTime( )
	local timestamp = time.timestamp
	local org = getElementData( source, "mdc_org" )
	local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_apb` ( `person_involved`, `description`, `doneby`, `time`, `organization` ) VALUES ( '"..exports.mysql:escape_string( person ).."','"..exports.mysql:escape_string( description ).."','"..officer.."', '"..timestamp.."', '"..exports.mysql:escape_string( org ).."' )" )
	if query then
		main(  )
	end
end

function add_pilot_event( charid, charactername, crime, punishment )
	local officer = getElementData( source, "mdc_account" )
	local time = getRealTime( )
	local timestamp = time.timestamp
	local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_faa_events` ( `crime`, `punishment`, `character`, `officer`, `timestamp` ) VALUES ( '"..exports.mysql:escape_string( crime ).."','"..exports.mysql:escape_string( punishment ).."','"..charid.."','"..officer.."', '"..timestamp.."' )" )
	if query then
		search( charactername, 0 )
	end
end

function add_pilot_license( charid, charactername, license, aircraft )
	--outputDebugString("add_pilot_license("..tostring(charid)..", "..tostring(charactername)..", "..tostring(license)..", "..tostring(aircraft)..")")
	local officer = getElementData( source, "mdc_account" )
	local time = getRealTime( )
	local timestamp = time.timestamp
	if(license ~= 7) then
		aircraft = "NULL"
	end
	local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_faa_licenses` ( `license`, `value`, `character`, `officer`, `timestamp` ) VALUES ( '"..exports.mysql:escape_string( license ).."',"..exports.mysql:escape_string(tostring(aircraft))..",'"..charid.."','"..officer.."', '"..timestamp.."' )" )
	if query then
		if mdc_faa_licenses then
			local insert = {id = tonumber(query), license = license, value = aircraft, character = charid, officer = officer, timestamp = timestamp}
			table.insert(mdc_faa_licenses, insert)
		end
		--[[
		local targetPlayer = exports.global:getPlayerFromCharacterID(charid)
		if targetPlayer then
			getPlayerPilotLicenses(targetPlayer, true)
		end
		--]]
		search( charactername, 0 )
	end
end

function remove_crime( charactername, crime_id )

	local query = exports.mysql:query( "DELETE FROM `mdc_crimes` WHERE `id` = '"..crime_id.."'" )
	if query then
		search( charactername, 0 )
	end
end

function remove_apb( id )
	local query = exports.mysql:query( "DELETE FROM `mdc_apb` WHERE `id` = '"..id.."'" )
	if query then
		main()
	end
end

function remove_pilot_event( charactername, crime_id )
	local query = exports.mysql:query( "DELETE FROM `mdc_faa_events` WHERE `id` = '"..crime_id.."'" )
	if query then
		search( charactername, 0 )
	end
end

function remove_pilot_license( charid, charactername, license_uid, licensetext )
	local query = exports.mysql:query( "DELETE FROM `mdc_faa_licenses` WHERE `id` = '"..exports.mysql:escape_string(tostring(license_uid)).."'" )
	if query then
		local match
		if mdc_faa_licenses then
			for k,v in ipairs(mdc_faa_licenses) do
				if tonumber(v.id) == tonumber(license_uid) then
					match = k
					break
				end
			end
		end
		if match then
			table.remove(mdc_faa_licenses, match)
		end
		add_pilot_event( charid, charactername, "License Revoked (MDC)", tostring(licensetext) )
		--[[
		local targetPlayer = exports.global:getPlayerFromCharacterID(charid)
		if targetPlayer then
			getPlayerPilotLicenses(targetPlayer, true)
		end
		--]]
	end
end

function update_person( charid, charactername, dob, ethnicity, phone, occupation, address, photo )
	if tonumber( photo ) > 1 then
		photo = exports.mysql:escape_string( photo )
	else
		local qSkin = exports.mysql:query( "SELECT `skin` FROM `characters` WHERE `id` = '"..exports.mysql:escape_string( charid ).."' " )
		if exports.mysql:num_rows( qSkin ) > 0 then
			local row = exports.mysql:fetch_assoc( qSkin )
			photo = row.skin
		end
	end
	
	dob			= exports.mysql:escape_string( dob )
	ethnicity	= exports.mysql:escape_string( ethnicity )
	phone		= exports.mysql:escape_string( phone )
	occupation	= exports.mysql:escape_string( occupation )
	address		= exports.mysql:escape_string( address )
	
	
	
	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `dob` = '"..dob.."', `ethnicity` = '"..ethnicity.."', `phone` = '"..phone.."', `occupation` = '"..occupation.."', `address` = '"..address.."', `photo` = '"..photo.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function update_details( charid, charactername, details )

	details		= exports.mysql:escape_string( details )
	
	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `details` = '"..details.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function update_pilot_details( charid, charactername, pilotDetails )
	pilotDetails = exports.mysql:escape_string( pilotDetails )	
	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `pilot_details` = '"..pilotDetails.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function update_warrant( charid, charactername, wanted, details )
	
	details = exports.mysql:escape_string( details )
	local wanted_by = getElementData( source, "mdc_account" )
	
	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `wanted` = '"..wanted.."', `wanted_by` = '"..wanted_by.."', `wanted_details` = '"..details.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function tolls( )	
	local locked = { }
	locked [ 1 ] = exports.toll:isTollLocked( 1 )
	locked [ 2 ] = exports.toll:isTollLocked( 3 )
	locked [ 3 ] = exports.toll:isTollLocked( 5 )
	locked [ 4 ] = exports.toll:isTollLocked( 6 )
	locked [ 5 ] = exports.toll:isTollLocked( 7 )
	locked [ 6 ] = exports.toll:isTollLocked( 9 )
	locked [ 7 ] = exports.toll:isTollLocked( 10 )
	locked [ 8 ] = exports.toll:isTollLocked( 11 )
	locked [ 9 ] = exports.toll:isTollLocked( 12 )
	locked [ 10 ] = exports.toll:isTollLocked( 13 )
	triggerClientEvent( source, resourceName..":tolls", getRootElement(), locked )
end

function toggle_toll( id )
	--We create a system here so that both directions are blocked at once for simplicity's sake.
	if id == 1 then
		exports.toll:toggleToll( 1 )
		if exports.toll:isTollLocked( 1 ) ~= exports.toll:isTollLocked( 2 ) then exports.toll:toggleToll( 2 ) end
	elseif id == 2 then
		exports.toll:toggleToll( 3 )
		if exports.toll:isTollLocked( 3 ) ~= exports.toll:isTollLocked( 4 ) then exports.toll:toggleToll( 4 ) end
	elseif id == 3 then
		exports.toll:toggleToll( 5 )
	elseif id == 4 then
		exports.toll:toggleToll( 6 )
	elseif id == 5 then
		exports.toll:toggleToll( 7 )
		if exports.toll:isTollLocked( 7 ) ~= exports.toll:isTollLocked( 8 ) then exports.toll:toggleToll( 8 ) end
	elseif id == 6 then
		exports.toll:toggleToll( 9 )
	elseif id == 7 then
		exports.toll:toggleToll( 10 )
	elseif id == 8 then
		exports.toll:toggleToll( 11 )
	elseif id == 9 then
		exports.toll:toggleToll( 12 )
	elseif id == 10 then
		exports.toll:toggleToll( 13 )
	end
		
	tolls( )
end

function system_admin( )
	local org = tostring(getElementData(source, "mdc_org"))
	local query = exports.mysql:query( "SELECT * FROM `mdc_users` WHERE `organization`='"..exports.mysql:escape_string(org).."' ORDER BY id ASC" )
	if ( query ) then
		local rows = { }
		local count = 1
		
		while true do
			row = exports.mysql:fetch_assoc( query )
			if not row then break end
			rows[count] = { }
			rows[count][1] = row.id
			rows[count][2] = row.user
			rows[count][3] = row.level
			rows[count][4] = row.organization
			count = count + 1
			
		end
		
		exports.mysql:free_result( query )
		triggerClientEvent(source, resourceName .. ":system_admin", getRootElement(), rows, count )
	end
end

function create_account( user, pass, level, organization )
	if level == -1 then
		level = 0
	end
	
	local query = "INSERT INTO `mdc_users` ( `user`, `pass`, `level`, `organization` ) VALUES ( '"..exports.mysql:escape_string( user ).."','"..exports.mysql:escape_string( pass ).."','"..exports.mysql:escape_string( level + 1 ).."','"..exports.mysql:escape_string(organization).."' )"
	if exports.mysql:query( query ) then
		system_admin( )
	end
end

function edit_account( id, user, pass, level )
	local query = "UPDATE `mdc_users` SET `user` = '"..exports.mysql:escape_string( user ).."' "
		..( ( string.len( pass ) > 0 ) and ", `pass` = '"..exports.mysql:escape_string( pass ).."' " or " " )
		..( ( level ~= -1 ) and ", `level` = '"..exports.mysql:escape_string( level + 1 ).."' " or " " )
		.."WHERE `id` = '"..id.."' "
	
	if exports.mysql:query( query ) then
		system_admin( )
	end
end

function edit_self( pass )
	local id = getElementData( source, "mdc_account" )
	local query = "UPDATE `mdc_users` SET `pass` = '"..exports.mysql:escape_string( pass ).."' WHERE `id` = '"..id.."' "
	
	if exports.mysql:query( query ) then
		triggerClientEvent(source, resourceName .. ":edit_self_success", getRootElement() )
	end
end

function delete_account( id )
	local query = exports.mysql:query( "DELETE FROM `mdc_users` WHERE `id` = '"..id.."'" )
	if query then
		system_admin( )
	end
end

local cachedPilotLicenses = {}
pilotLicenseNames = {
	[1] = "ARC",
	[2] = "AGC",
	[3] = "ROT",
	[4] = "SER",
	[5] = "MER",
	[6] = "TER",
	[7] = "Typerating",
	[8] = "CFI",
	[9] = "CPL",
}
function getPlayerPilotLicenses(thePlayer, noCache)
	local licenses = {}
	noCache = true --because we might get issues otherwise
	--if not noCache and cachedPilotLicenses[thePlayer] then
	--	licenses = cachedPilotLicenses[thePlayer]
	--else
		local charID = tonumber(getElementData(thePlayer, "dbid")) or false
		if charID then
			if mdc_faa_licenses then
				for k,row in ipairs(mdc_faa_licenses) do
					if tonumber(row.character) == charID then
						local licenseID = tonumber(row.license) or false
						if licenseID then
							local licenseText
							if licenseID == 7 then --typerating
								local vehName = getVehicleNameFromModel(tonumber(row.value))
								if vehName then
									licenseText = "Typerating: "..tostring(vehName)
								end
							else
								licenseText = pilotLicenseNames[licenseID]
							end
							table.insert(licenses, {licenseID, tonumber(row.value) or false, licenseText or false})
						end 
					end
				end
				--cachedPilotLicenses[thePlayer] = licenses
			else
				local result8 = exports.mysql:query( "SELECT `license`, `value` FROM `mdc_faa_licenses` WHERE `character` = ".. charID .." ORDER BY `id` ASC" )
				if ( result8 ) then
					local count = 1
					while true do
						row = exports.mysql:fetch_assoc( result8 )
						if not row then break end

						local licenseID = tonumber(row.license) or false
						if licenseID then
							local licenseText
							if licenseID == 7 then --typerating
								local vehName = getVehicleNameFromModel(tonumber(row.value))
								if vehName then
									licenseText = "Typerating: "..tostring(vehName)
								end
							else
								licenseText = pilotLicenseNames[licenseID]
							end
							table.insert(licenses, {licenseID, tonumber(row.value) or false, licenseText or false})
						end
					end
					exports.mysql:free_result( result8 )
					--cachedPilotLicenses[thePlayer] = licenses
				end
			end
		end
	--end
	return licenses
end

function refreshPilotLicensesCache(thePlayer, commandName)
	if (getElementData(thePlayer, "faction") == 47 and getElementData(thePlayer, "factionleader") == 1) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		outputChatBox("Refreshing pilot licenses cache...", thePlayer, 255, 194, 14)
		local startTime = getTickCount()
		--mdc_faa_licenses
		local result = exports.mysql:query("SELECT * FROM `mdc_faa_licenses`")
		if result then
			local theTable = {}
			while true do
				row = exports.mysql:fetch_assoc(result)
				if not row then break end
				local thisValues = {}
				for key,value in pairs(row) do
					--outputDebugString("key="..tostring(key).." value="..tostring(value))
					thisValues[key] = value
				end
				table.insert(theTable, thisValues)
			end
			mdc_faa_licenses = theTable
			exports.mysql:free_result(result)
		else
			outputChatBox("ERROR! Failed to load pilot licenses!", thePlayer, 255, 0, 0)
			outputDebugString("mdc-system/mdc.lua: Failed to load pilot licenses! (/"..tostring(commandName)..")",2)
			return
		end
		outputChatBox("Loaded "..tostring(#mdc_faa_licenses).." pilot licenses in "..tostring(math.ceil(getTickCount()-startTime)).."ms.", thePlayer, 255, 194, 14)
		--[[
		for k,v in ipairs(mdc_faa_licenses) do
			local text = "["..tostring(k).."] = {"
			for k2,v2 in pairs (v) do
				text = text.." "..tostring(k2).."="..tostring(v2)..","
			end
			text = text.."}"
			outputConsole(text, thePlayer)
		end
		--]]
	end
end
addCommandHandler("refreshpilotlicenses", refreshPilotLicensesCache, false, false)

function updateVehicleStolen( vehicleID )
	exports.mysql:query_free( 'UPDATE `vehicles` SET `stolen` = 1 - `stolen` WHERE `id` = ' .. vehicleID )
end


------------------------------------------
addEvent( resourceName .. ":login", true )
addEvent( resourceName .. ":main", true )
addEvent( resourceName .. ":search", true )
addEvent( resourceName .. ":add_crime", true )
addEvent( resourceName .. ":add_pilot_event", true )
addEvent( resourceName .. ":add_pilot_license", true )
addEvent( resourceName .. ":add_apb", true )
addEvent( resourceName .. ":remove_crime", true )
addEvent( resourceName .. ":remove_pilot_event", true )
addEvent( resourceName .. ":remove_pilot_license", true )
addEvent( resourceName .. ":remove_apb", true )
addEvent( resourceName .. ":update_person", true )
addEvent( resourceName .. ":update_details", true )
addEvent( resourceName .. ":update_pilot_details", true )
addEvent( resourceName .. ":update_warrant", true )
addEvent( resourceName .. ":tolls", true )
addEvent( resourceName .. ":toggle_toll", true )
addEvent( resourceName .. ":system_admin", true )
addEvent( resourceName .. ":create_account", true )
addEvent( resourceName .. ":edit_account", true )
addEvent( resourceName .. ":edit_self", true )
addEvent( resourceName .. ":delete_account", true )
addEvent( resourceName .. ":updateVehicleStolen", true )
addEventHandler( resourceName .. ":login", getRootElement(), login )
addEventHandler( resourceName .. ":main", getRootElement(), main )
addEventHandler( resourceName .. ":search", getRootElement(), search )
addEventHandler( resourceName .. ":add_crime", getRootElement(), add_crime )
addEventHandler( resourceName .. ":add_pilot_event", getRootElement(), add_pilot_event )
addEventHandler( resourceName .. ":add_pilot_license", getRootElement(), add_pilot_license )
addEventHandler( resourceName .. ":add_apb", getRootElement(), add_apb )
addEventHandler( resourceName .. ":remove_crime", getRootElement(), remove_crime )
addEventHandler( resourceName .. ":remove_pilot_event", getRootElement(), remove_pilot_event )
addEventHandler( resourceName .. ":remove_pilot_license", getRootElement(), remove_pilot_license )
addEventHandler( resourceName .. ":remove_apb", getRootElement(), remove_apb )
addEventHandler( resourceName .. ":update_person", getRootElement(), update_person )
addEventHandler( resourceName .. ":update_details", getRootElement(), update_details )
addEventHandler( resourceName .. ":update_pilot_details", getRootElement(), update_pilot_details )
addEventHandler( resourceName .. ":update_warrant", getRootElement(), update_warrant )
addEventHandler( resourceName .. ":tolls", getRootElement(), tolls )
addEventHandler( resourceName .. ":toggle_toll", getRootElement(), toggle_toll )
addEventHandler( resourceName .. ":system_admin", getRootElement(), system_admin )
addEventHandler( resourceName .. ":create_account", getRootElement(), create_account )
addEventHandler( resourceName .. ":edit_account", getRootElement(), edit_account )
addEventHandler( resourceName .. ":edit_self", getRootElement(), edit_self )
addEventHandler( resourceName .. ":delete_account", getRootElement(), delete_account )
addEventHandler( resourceName .. ":updateVehicleStolen", getRootElement(), updateVehicleStolen )