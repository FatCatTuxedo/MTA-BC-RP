--Maxime / 2015.2.4
addEvent("playTTS", true) -- Add the event
local function playTTS(text, lang, volume , distance, speed, effect)
	local URL = "http://translate.google.com/translate_tts?tl=" .. (lang or "en") .. "&q=" .. text
	if source and isElement(source) and getElementType(source) == "player" then
		local x, y, z = getElementPosition(source)
		local speech = playSound3D(URL, x, y, z)
		attachElements(speech, source) -- Make the sound follow the player
		setSoundMaxDistance(speech, distance or 50)
		setElementDimension(speech, getElementDimension(source))
		setElementInterior(speech, getElementInterior(source))
	    setSoundVolume(speech, volume or 1)
	    setSoundSpeed (  speech, speed or 1)
	    if effect then
	    	setSoundEffectEnabled ( speech, effect, true )
	    end

	    -- Tricky thing ahead: make the player mouth move, but without rendering him unable to move
	    if not getPedAnimation ( source ) then
		    setPedAnimation(source, "ped", "factalk", 0, true)
		    setPedAnimation(source, "ped", "factalk", 0, true)
		    -- Reset the player mouth after the speech has ended
		    setTimer(function(player)
		        if isElement(player) then
		            setPedAnimation(player) -- Clear the animation
		        end
		    end, math.max(getSoundLength(speech) * 1000, 50), 1, source)
		end

	    return speech
	else
		local speech = playSound(URL)
		setElementDimension(speech, getElementDimension(localPlayer))
		setElementInterior(speech, getElementInterior(localPlayer))
	    setSoundVolume(speech, volume or 1)
	    setSoundSpeed (  speech, speed or 1)
	    if effect then
	    	setSoundEffectEnabled ( speech, effect, true )
	    end
	    return speech
	end
end
addEventHandler("playTTS", root, playTTS)