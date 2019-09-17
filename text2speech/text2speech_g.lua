--Maxime / 2015.2.4
function convertTextToSpeech(broadcastTo, text, lang, sourceOfSpeech , volume, distance, speed, effect)
    if #text > 100 then
        return false
    end
    if triggerClientEvent then
        -- Tell the client to play the speech
        return triggerClientEvent(broadcastTo or root, "playTTS", sourceOfSpeech or root, text, lang or "en" , volume, distance, speed, effect)
    else
        local lang = broadcastTo
        return playTTS(text, lang or "en", volume, distance, speed, effect)
    end
end