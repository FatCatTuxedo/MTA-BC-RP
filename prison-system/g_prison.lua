--[[
All stored here for ease of use.

New jail system by: Chaos for OwlGaming
]]

pd_offline_jail = false -- PD Offline Jailing enabled or disabled. Reminder: Always enabled for admins.

pd_update_access = 1 -- Allows this faction ID to update/remove offline prisoners

hourLimit = 0 -- 0 is infinite, otherwise this is the max they can jail in hours

gateDim = 184
gateInt = 3
objectID = 2930

speakerDimensions = { [137] = true }
speakerInt = 6
speakerOutX, speakerOutY, speakerOutZ =   -2450.732421875, 508.783203125, 45.562507629395

-- Skins, ID = clothing:id
-- Male Skins 
bMale = 305
bMaleID = 1109
wMale = 305
wMaleID = 1110
aMale = 305
aMaleID = 1110

-- Female Skins
bFemale = 69
bFemaleID = 1111
wFemale = 69
wFemaleID = 1112
aFemale = 69
aFemaleID = 1112

cells = {
["JAIL01"] = { 3122.2219238281, 843.0341796875, 1655.2562255859, 3, 655 },
["JAIL02"] = { 3126.7053222656, 843.255859375, 1655.2562255859, 3, 655 },
["JAIL03"] = {  3130.5002441406, 843.1728515625, 1655.2562255859, 3, 655 },
["JAIL04"] = {  3134.9982910156, 843.271484375, 1655.2562255859, 3, 655 },
["JAIL05"] = {  3138.9992675781, 842.939453125, 1655.2562255859, 3, 655 },
["JAIL06"] = {  3142.9865722656, 843.4375, 1655.2562255859, 3, 655 },
["JAIL07"] = {  3147.0129394531, 843.1533203125, 1655.2562255859, 3, 655 },
["JAIL08"] = {  3151.2580566406, 843.11328125, 1655.2562255859, 3, 655 },
}

cells2 = { }

function isCloseTo( thePlayer, targetPlayer )
  if exports.integration:isPlayerTrialAdmin(thePlayer) then
    return true
  end

  local theTeam = getPlayerTeam(thePlayer)
  local factionId = tonumber(getElementData(theTeam, "id"))
  if factionId == pd_update_access then
    return true
  end

  if targetPlayer then
    local dx, dy, dz = getElementPosition(thePlayer)
    local dx1, dy1, dz1 = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(dx, dy, dz, dx1, dy1, dz1) < ( 30 ) then
      if getElementDimension(thePlayer) == getElementDimension(targetPlayer) then
        return true
      end
    end
  end
    return false
end

function isInArrestColshape( thePlayer )
    if getElementDimension(thePlayer) == 137 or  getElementDimension(thePlayer) == 655 then -- Don't forget to change this
      return true
  end
  return false
end

function cleanMath(number)
    if type(number) == "boolean" then
        return
    end
    local currenttime = getRealTime()
    local currentTime = currenttime.timestamp
    local remainingtime = tonumber(number) - currentTime
    local hours = (remainingtime /3600)
    local days = math.floor(hours/24)
    local remaininghours = hours - days*24
    local hours = ("%.1f"):format(hours - days*24)

    if remainingtime<0 then
        return "Awaiting", "Release", tonumber(remainingtime)
    end

    if days>999 then
      return "Life", "Sentence", tonumber(remainingtime)
    end
     
    return days, hours, tonumber(remainingtime)
end

-- Released
x, y, z =  637.2861328125, 1691.5673828125, 6.9921875 -- Anumaz edit this for when they get released

dim = 0
int = 0

gates = { }

--[[
----- SQL STRUCTURE -----

-- Host: 127.0.0.1
-- Generation Time: Aug 25, 2014 at 12:46 AM
-- Server version: 5.6.16
-- PHP Version: 5.5.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";

-- --------------------------------------------------------

--
-- Table structure for table `jailed`
--

CREATE TABLE IF NOT EXISTS `jailed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `charid` int(11) NOT NULL,
  `charactername` text NOT NULL,
  `jail_time` bigint(12) NOT NULL,
  `convictionDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedBy` text NOT NULL,
  `charges` text NOT NULL,
  `cell` text NOT NULL,
  `fine` int(5) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=0 ;
]]