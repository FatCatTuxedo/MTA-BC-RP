addEvent("truckerjob:playSoundFX", true)
addEventHandler("truckerjob:playSoundFX", root,
	function()
		playSound("soundFX/"..tostring(math.random(1,6))..".mp3")
	end
)