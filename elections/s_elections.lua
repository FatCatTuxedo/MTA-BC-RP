--[[

*** TO DO BEFORE RUNNING !!!!READ ME!!!!

** RUN SQL QUERIES
CREATE TABLE `owl_mta`.`elections` (
  `idelections` VARCHAR(45) NOT NULL,
  `Votes` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`idelections`));

INSERT INTO `owl_mta`.`elections` (`idelections`, `Votes`) VALUES ('Daniel Levi', '0');
INSERT INTO `owl_mta`.`elections` (`idelections`, `Votes`) VALUES ('Adam Price', '0');
INSERT INTO `owl_mta`.`elections` (`idelections`, `Votes`) VALUES ('Luca Borelli', '0');

ALTER TABLE `owl_mta`.`accounts`
ADD COLUMN `electionsvoted` INT NOT NULL DEFAULT '0' AFTER `cpa_earned`;

** ADD LINE TO
server.lua in account-system/login-panel/server.lua: setElementDataEx(client, "electionsvoted", accountData["electionsvoted"], true)
Around lines 140, just under setElementDataEx(client, "account:username", fixedUsername, true)

** ADD LINE TO
c_peds_rightclick in ped-system
around line 240;

elseif(interact == "electionsped") then
	rcMenu = exports.rightclick:create(getElementData(element, "rpp.npc.name"))
	row.talk = exports.rightclick:addrow("Talk")
	addEventHandler("onClientGUIClick", row.talk,  function (button, state)
		triggerEvent("elections:votegui", getLocalPlayer())
	end, true)

]]

addEventHandler("onResourceStart", resourceRoot,
	function()
		local result = exports.mysql:query( "SELECT * FROM `owl_mta`.`elections`" )
		local result_table = { }
		while true do
			local row = exports.mysql:fetch_assoc( result )
			if not row then
				break
			end
			table.insert(result_table, row)
		end
		exports.mysql:free_result( result )
		setElementData(resourceRoot, "elections:votes", result_table)

		local ped = createPed(240, 1473.283203125, -1936.6259765625, 290.70001220703)
		setElementFrozen(ped, true)
		setElementRotation(ped, 0, 0, 0.6619)
		setElementDimension(ped, 9)
		setElementInterior(ped, 1)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.name", "Officer Dupont")
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.gender", 0)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.nametag", true)
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.behav", 0)

		--owl specifics
		exports.anticheat:changeProtectedElementDataEx(ped, "nametag", true)
		exports.anticheat:changeProtectedElementDataEx(ped, "name", "Officer Dupont")
		exports.anticheat:changeProtectedElementDataEx(ped, "rpp.npc.type", "electionsped")

		--setElementData(ped, "talk", 1, true)

		addEventHandler( 'onClientPedWasted', ped,
			function()
				setTimer(
					function()
						destroyElement(ped)
						createPed()
					end, 20000, 1)
			end, false)

		addEventHandler( 'onClientPedDamage', ped, cancelEvent, false )
	end)


function sqlAddVote(who, votes, client)
	exports.mysql:query_free("UPDATE elections SET `Votes`='"..votes.."' WHERE `idelections`='"..who.."'")
	setElementData(client, "electionsvoted", 1, true)
	local accountname = getElementData(client, "account:username")
	exports.mysql:query_free("UPDATE accounts SET `electionsvoted`='1' WHERE `username`='"..accountname.."'")

	outputChatBox("You have voted for: "..who, client)
end
addEvent("elections:refresh", true)
addEventHandler("elections:refresh", resourceRoot, sqlAddVote)

function displayVotes(thePlayer)
	if exports.integration:isPlayerLeadAdmin(thePlayer) then
		local t = getElementData(resourceRoot, "elections:votes")
		outputChatBox("CURRENT VOTES:", thePlayer)
		for k, v in pairs(t) do
			outputChatBox(v["idelections"]..": "..v["Votes"].." votes.", thePlayer)
		end
	end
end
addCommandHandler("electionvotes", displayVotes)
