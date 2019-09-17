function giveDuplicatedKey(thePlayer, itemID, value, cost)
	if thePlayer and itemID and value and cost then
		exports.global:giveItem(thePlayer, tonumber(itemID), tonumber(value))
		exports.global:takeMoney(thePlayer, cost)
	end
end
addEvent("locksmithNPC:givekey", true)
addEventHandler("locksmithNPC:givekey", resourceRoot, giveDuplicatedKey)