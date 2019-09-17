mysql = exports.mysql

function awardPlayer(thePlayer, title, desc, gc)
	if gc and tonumber(gc) and tonumber(gc) >= 0 then
		if mysql:query_free("UPDATE `accounts` SET `credits`=credits+"..gc.." WHERE `id` = " .. mysql:escape_string(getElementData( thePlayer, "account:id" )) ) then
			triggerClientEvent(thePlayer, "displayAchievement", source or thePlayer, title, desc, gc)
			exports.donators:addPurchaseHistory(thePlayer, title or "ACHIEVEMENT UNLOCKED! "..(desc and ("("..desc..")") or ("")), tonumber(gc))
		else
			outputChatBox("You were supposed to be rewarded with "..gc.."GCs.", thePlayer, 255, 0, 0)
			outputChatBox("But unfortunately, a MySQL error occurred and adding GC uncompleted.", thePlayer, 255, 0, 0)
		end
	end
end
addEvent("awardPlayer", true)
addEventHandler("awardPlayer", root, awardPlayer)

function playSoundFx(thePlayer)
	triggerClientEvent(thePlayer, "playSoundFx", thePlayer)
end