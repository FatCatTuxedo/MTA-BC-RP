local bannedAnimations = { ["FIN_Cop1_ClimbOut2"]=true, ["FIN_Jump_on"]=true }

addEvent("AnimationSet",true)
addEventHandler("AnimationSet",getRootElement(), 
	function (block, ani, loop)
		if bannedAnimations[ani] then
			outputChatBox("This animation is currently banned.", source, 255, 0, 0)
			return 
		end

		if(source)then
			if(block)then
				if loop then
					setPedAnimation(source,block,ani,-1,loop)
				else
					setPedAnimation(source,block,ani,1,false)
				end
			else
				setPedAnimation(source)
			end
		end
	end)
	
--[[ addCommandHandler("anim",
	function (player, command, block, anim, loop)
		if(block and ani)then
			triggerEvent("AnimationSet",player, tostring(block),tostring(anim), tonumber(loop) == 1)
		else
			triggerEvent("AnimationSet",player)
		end
	end)]]--

--Adam's below
addCommandHandler("anim",
	function (player, command, block, anim, loop)
	 	if(block and anim and loop) then
			if loop == 1 then loop = true else loop = false end
	 			triggerEvent("AnimationSet",player, tostring(block),tostring(anim), loop)
	 	else
	 	triggerEvent("AnimationSet",player)
	 end
end)
