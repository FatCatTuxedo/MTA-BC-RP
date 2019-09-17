--MAXIME

function updatePhoneSetting(fromPhone, index, value)
	fromPhone = tonumber(fromPhone)
	if fromPhone and index and value then
		outputDebugString("[Phone] updatePhoneSetting / "..fromPhone.." / "..index.." / "..value)
		return mysql:query_free("UPDATE `phones` SET `"..index.."`='"..exports.global:toSQL(value).."' WHERE `phonenumber`='"..fromPhone.."' ")
	end
end
addEvent("phone:updatePhoneSetting", true)
addEventHandler("phone:updatePhoneSetting", root, updatePhoneSetting)

function activatePrivateNumber(fromPhone, cost)
	fromPhone = tonumber(fromPhone)
	cost = tonumber(cost)
	if fromPhone and cost then
		local took, reason = exports.donators:takeGC(source, cost)
		if not took then
			outputChatBox("You have failed to activate this Premium Feature. Reason: "..reason, source, 255, 0, 0)
			return false
		end
		exports.donators:addPurchaseHistory(source, "Cellphone Private Number on #"..fromPhone, -cost)
		if updatePhoneSetting(fromPhone, "secretnumber", 1) then
			outputChatBox("You have successfully activated Cellphone Private Number on #"..fromPhone.."!", source, 0, 255, 0)
			return true
		end
	end
end
addEvent("phone:activatePrivateNumber", true)
addEventHandler("phone:activatePrivateNumber", root, activatePrivateNumber)

function requestPhoneSettingsFromServer(fromPhone)
	outputDebugString("[Phone] requestPhoneSettingsFromServer / "..getPlayerName(source).." / "..fromPhone)
	triggerClientEvent(source, "phone:updateClientPhoneSettingsFromServer", source, fromPhone, {fromPhone, getPhoneSettings(fromPhone, true)})
end
addEvent("phone:requestPhoneSettingsFromServer", true)
addEventHandler("phone:requestPhoneSettingsFromServer", root, requestPhoneSettingsFromServer)

