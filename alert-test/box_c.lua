sx,sy = guiGetScreenSize ()
addEvent ("onNotificationWindowHide",false)
addEvent ("onNotificationWindowShow",false)
box = false

function showBox(value, str)
	-- value 1 - Info
	-- value 2 - Error
	-- value 3 - warning
	--if box == false then
	if str and type(str) == "string" and string.len(str) > 0 then
		box = true
		if value == "info" then 
			showTipBox (str,"img/info.png")
			outputConsole ("[INFO]" .. str)
		elseif value == "error" then 
			showTipBox (str,"img/error.png")
			outputConsole ("[ERROR]" .. str)
		elseif value == "warning" then 
			showTipBox (str,"img/warning.png")
			outputConsole ("[WARNING]" .. str)
		end
	end
	--else
	--	return false
	--end
end
addEvent("CreateBox", true)
addEventHandler("CreateBox", getRootElement(), showBox)

addEventHandler ("onNotificationWindowHide",getRootElement(),
	function ()
		box = false
	end
)
	
tipBox = {}
tipBox.path = ""
tipBox.show = false
tipBox.state = nil
tipBox.string = nil
tipBox.starTick = nil
tipBox.currentY = nil
tipBox.time = 800
tipBox.next = nil
tipBox.nextPath = ""
tipBox.timer = nil
tipBox.startY = -180
tipBox.stopY = 30

function showTipBox (str,path)
	if str then
		if path == nil then
			path = "img/info.png"
		end
		if fileExists (path) then
			if tipBox.show == true then
				tipBox.next = str
				tipBox.nextPath = path
			else
				local sound = playSound ("bip.mp3")
				setSoundVolume (sound,0.5)
				tipBox.path = path
				tipBox.show = true
				tipBox.state = "starting"
				tipBox.string = str
				tipBox.startTick = getTickCount()
				triggerEvent ("onNotificationWindowShow",getRootElement())
			end
		end
	end
end
addEvent("CreateTipBox", true)
addEventHandler("CreateTipBox", getRootElement(), showTipBox)

addEventHandler ("onClientRender", getRootElement(),
	function ()
		if tipBox.show == true and tipBox.string then
			local width = dxGetTextWidth (tipBox.string, 1, "default-bold")
			if width then
				if tipBox.state == "starting" then
					local progress = (getTickCount() - tipBox.startTick) / tipBox.time
					local intY = interpolateBetween (
						tipBox.startY,0,0,
						tipBox.stopY,0,0,
						progress,"OutElastic"
					)
					if intY then
						tipBox.currentY = intY
					else
						tipBox.currentY = 100
					end
					if progress > 1 then
						tipBox.state = "showing"
						tipBox.timer = setTimer (
							function ()
								tipBox.startTick = getTickCount()
								tipBox.state = "hiding"
							end
						,string.len(tipBox.string)*45+800,1)
					end
				elseif tipBox.state == "showing" then
					tipBox.currentY = tipBox.stopY
				elseif tipBox.state == "hiding" then
					local progress = (getTickCount() - tipBox.startTick) / (tipBox.time)
					local intY = interpolateBetween (
						tipBox.stopY,0,0,
						tipBox.startY,0,0,
						progress,"Linear"
					)
					if intY then
						tipBox.currentY = intY
					else
						tipBox.currentY = 100
					end
					if progress > 1 then
						triggerEvent ("onNotificationWindowHide",getRootElement())
						if tipBox.next then
							if isTimer(tipBox.timer) then
								killTimer(tipBox.timer)
							end
							tipBox.show = true
							tipBox.state = "starting"
							tipBox.string = tipBox.next
							tipBox.startTick = getTickCount()
							tipBox.next = nil
							tipBox.path = tipBox.nextPath
							return
						else
							tipBox.show = false
							tipBox.state = nil
							tipBox.string = nil
							return
						end
					end
				else
					return
				end
				local width = 512
				local x,y = sx/2 - width/2, tipBox.currentY
				local textX,textY = x+128,tipBox.currentY+44
				local textWidth,textHeight = 363,106
				dxDrawImage (x,y,width,256,tipBox.path,0,0,0,tocolor(255,255,255),true)
				dxDrawText (tipBox.string,textX,textY,textX+textWidth,textY+textHeight,tocolor(222,222,222),1,"default-bold","center","center",false,true,true)
			end
		end
	end
)


