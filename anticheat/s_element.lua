local secretHandle = 'some_shit_that_is_really_secured'

addEventHandler("onElementDataChange", getRootElement(), 
	function (index, oldValue)
		if not client then
			return
		end
		local theElement = source
		if (index ~= "interiormarker") and (index ~= "i:left") and (index ~= "i:right") then
			local isProtected = getElementData(theElement, secretHandle.."p:"..index)
			if (isProtected) then
				-- get real source here
				-- it aint source!
				local sourceClient = client
				if (sourceClient) then
					if (getElementType(sourceClient) == "player") then
						local newData = getElementData(source, index)
						local playername = getPlayerName(source) or "Somethings"
						-- Get rid of the player
						local msg = "[AdmWarn] " .. getPlayerName(sourceClient) .. " sent illegal data. "
						local msg2 = " (victim: "..playername.." index: "..index .." newvalue:".. tostring(newData) .. " oldvalue:".. tostring(oldValue)  ..")"
						--outputConsole(msg)
						--outputConsole(msg2)
						--exports.global:sendMessageToAdmins(msg)
						exports.global:sendMessageToAdmins(msg)
						exports.global:sendMessageToAdmins(msg2)
						--exports.logs:logMessage(msg..msg2, 29)
						--exports.logs:dbLog(sourceClient, 5, sourceClient, msg..msg2 )
						
						-- uncomment this when it works
						--local ban = banPlayer(sourceClient, false, false, true, getRootElement(), "Hacked Client.", 0)
						
						-- revert data
						changeProtectedElementDataEx(source, index, oldValue, true)
					end
				end
			end
		end
	end
);

addEventHandler ( "onPlayerJoin", getRootElement(), 
	function ()
		protectElementData(source, "account:id")
		protectElementData(source, "account:username")
		protectElementData(source, "legitnamechange")
		protectElementData(source, "dbid")
	end
);

function allowElementData(thePlayer, index)
	setElementData(thePlayer, secretHandle.."p:"..index, false, false)
end

function protectElementData(thePlayer, index)
	setElementData(thePlayer, secretHandle.."p:"..index, true, false)
end

function changeProtectedElementData(thePlayer, index, newvalue)
	allowElementData(thePlayer, index)
	setElementData(thePlayer, index, newvalue)
	protectElementData(thePlayer, index)
end

function changeProtectedElementDataEx(thePlayer, index, newvalue, sync, nosyncatall)
	if (thePlayer) and (index) then
		if not newvalue then
			newvalue = nil
		end
		if not nosyncatall then
			nosyncatall = false
		end
	
		allowElementData(thePlayer, index)
		setElementData(thePlayer, index, newvalue, sync)

		if not sync then
			if not nosyncatall then
				if getElementType ( thePlayer ) == "player" then
					triggerClientEvent(thePlayer, "edu", getRootElement(), thePlayer, index, newvalue)
				end
			end
		end
		protectElementData(thePlayer, index)
		return true
	end
	return false
end

function changeEld(thePlayer, index, newvalue)
	if source then thePlayer = thePlayer end
	return changeProtectedElementData(thePlayer, index, newvalue)
end
addEvent("anticheat:changeEld", true)
addEventHandler("anticheat:changeEld", root, changeEld)

function setEld(thePlayer, index, newvalue, sync)
	if source then thePlayer = thePlayer end
	local sync2 = false
	local nosyncatall = true
	if sync == "one" then
		sync2 = false
		nosyncatall = false
	elseif sync == "all" then
		sync2 = true
		nosyncatall = false
	else
		sync2 = false
		nosyncatall = true
	end
	return changeProtectedElementDataEx(thePlayer, index, newvalue, sync2, nosyncatall)
end
addEvent("anticheat:setEld", true)
addEventHandler("anticheat:setEld", root, setEld)


function genHandle()
	local hash = ''
	for Loop = 1, math.random(5,16) do
		hash = hash .. string.char(math.random(65, 122))
	end
	return hash
end

function fetchH()
	return secretHandle
end

secretHandle = genHandle()