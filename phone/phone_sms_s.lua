--MAXIME
local messageLimit = 20
local threadLimit = 100
function getOneSMSThread(fromPhone, threadIndex)
    local thread = {}
    local query = mysql:query("SELECT *, TIME_TO_SEC(TIMEDIFF(NOW(), `date`)) AS `secdiff` FROM `phone_sms` WHERE (`from`='"..fromPhone.."' AND `to`='"..threadIndex.."') OR (`from`='"..threadIndex.."' AND `to`='"..fromPhone.."') ORDER BY `date` DESC LIMIT "..messageLimit)
    while true do
        local row = mysql:fetch_assoc(query)
        if not row then break end
        table.insert(thread, row)
    end
    return thread
end

function fetchSMS(fromPhone, forceUpdate, forceUpdateContactList1, limit)
    fromPhone = tonumber(fromPhone)
    if forceUpdateContactList1 then
        forceUpdateContactList(source, fromPhone)
    end
    local SMSs = {}
    if fromPhone then
        if limit and tonumber(limit) then
            limit = "LIMIT "..limit
        else
            limit = ""
        end
        local query = mysql:query("SELECT *, TO_SECONDS(`date`) AS `datesec` FROM `phone_sms` WHERE `from`='"..fromPhone.."' OR `to`='"..fromPhone.."' ORDER BY `date` DESC "..limit)
        while true do
            local row = mysql:fetch_assoc(query)
            if not row then break end
            table.insert(SMSs, row)
        end
    end
    
    triggerClientEvent(source, "phone:receiveSMSFromServer", source, fromPhone, SMSs, forceUpdate)
    --outputChatBox("1")
end
addEvent("phone:fetchSMS", true)
addEventHandler("phone:fetchSMS", root, fetchSMS)

function fetchOneSMSThread(fetchForPhone, messageSentTo, outGoing, forceUpdateContactList1, limit)
    fetchForPhone = tonumber(fetchForPhone)
    messageSentTo = tonumber(messageSentTo)
    local SMSs = {}
    if fetchForPhone and messageSentTo then
        if forceUpdateContactList1 then
            forceUpdateContactList(source, fetchForPhone)
        end
        
        if limit and tonumber(limit) then
            limit = "LIMIT "..limit
        else
            limit = "LIMIT 10"
        end
        local query = mysql:query("SELECT *, TO_SECONDS(`date`) AS `datesec` FROM `phone_sms` WHERE (`from`='"..fetchForPhone.."' AND `to`='"..messageSentTo.."') OR (`from`='"..messageSentTo.."' AND `to`='"..fetchForPhone.."') ORDER BY `date` DESC "..limit)
        while query do
            local row = mysql:fetch_assoc(query)
            if not row then break end
            table.insert(SMSs, row)
        end
    end
    --outputDebugString("fetchOneSMSThread / "..getPlayerName(source))
    triggerClientEvent(source, "phone:receiveOneSMSThreadFromServer", source, fetchForPhone, messageSentTo, SMSs, outGoing)
end
addEvent("phone:fetchOneSMSThread", true)
addEventHandler("phone:fetchOneSMSThread", root, fetchOneSMSThread)

function sendSMS(from, to, content, private)
    from = tonumber(from)
    to = tonumber(to)
    private = tonumber(private) == 1 and 1 or 0
    if not from or not to or not content or string.len(content) < 1 then
        return false
    end
    mysql:query_insert_free("INSERT INTO `phone_sms` SET `from`='"..from.."', `to`='"..to.."', `content`='"..exports.global:toSQL(content).."', private="..private)
    if not isNumberAHotline(to) then
        local t_powerOn, t_ringtone, t_isSecret, t_isInPhonebook, t_boughtBy = getPhoneSettings(to, true)
        if not t_powerOn then --not existed
            local notExisted = "Delivery has failed to these recipients: #"..to..". Number does not exist."
            mysql:query_insert_free("INSERT INTO `phone_sms` SET `from`='"..to.."', `to`='"..from.."', `content`='"..exports.global:toSQL(notExisted).."' ")
            triggerEvent("phone:fetchOneSMSThread", source, from, to, true)
            return false
        end
    end
    local found, target = searchForPhone(to)
    if found and target then
        triggerEvent("phone:fetchOneSMSThread", target, to, from)
    end
    triggerEvent("phone:fetchOneSMSThread", source, from, to, true)
end
addEvent("phone:sendSMS", true)
addEventHandler("phone:sendSMS", root, sendSMS)

function startRingingSMS(fromPhone, smsTone, volume)
    if not smsTone then
        local phoneSettings = {getPhoneSettings(fromPhone, true)}
        smsTone = phoneSettings[8]
        volume = phoneSettings[9]
    end

    for _,nearbyPlayer in ipairs(exports.global:getNearbyElements(source, "player"), 10) do
        triggerClientEvent(nearbyPlayer, "startRinging", source, 2, smsTone, volume)
    end
    if smsTone > 1 then
        triggerEvent('sendAme', source, "'s cellphone starts to ring.")
    end
    outputChatBox("Your phone #"..fromPhone.." has received a new text message.", source)

end
addEvent("phone:startRingingSMS", true)
addEventHandler("phone:startRingingSMS", root, startRingingSMS)

function updateSMSViewedState(fromPhone, threadIndex)
    if mysql:query_free("UPDATE `phone_sms` SET `viewed`=1 WHERE `from`='"..threadIndex.."' AND `to`='"..fromPhone.."' ") then
        triggerEvent("phone:fetchOneSMSThread", source, fromPhone, threadIndex)
    end
end
addEvent("phone:updateSMSViewedState", true)
addEventHandler("phone:updateSMSViewedState", root, updateSMSViewedState)


function cleanUpOldSMS()
    mysql:query_free("DELETE FROM `phone_sms` WHERE DATEDIFF(NOW(),`date`) > 7  ")
end
addEventHandler("onResourceStart", resourceRoot, cleanUpOldSMS)