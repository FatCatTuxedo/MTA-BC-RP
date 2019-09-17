--[[ THIS SCRIPT REMOVES SF/LV and Red County ]]-- 


for i=550,20000 do
    removeWorldModel(i,1200,1776,1710,0)
	removeWorldModel(i,500,2687,1039,0)
	removeWorldModel(i,500,616,920,0)
	removeWorldModel(i,200,914,737,0)
	removeWorldModel(i,900,-131,1291,0)
	removeWorldModel(i,90,2316,578,0)
	removeWorldModel(i,900,-2300,-49,0)
	removeWorldModel(i,200,-2868,-722,0)
	removeWorldModel(i,800,-1554,668,0) 
	removeWorldModel(i,150,-1364,-330,0)
	removeWorldModel(i,500,-795,-1103,0)
	removeWorldModel(i,620,-1606,-822,0)
	removeWorldModel(i,200,-210,-1328,0)
	removeWorldModel(i,200,-335,-1560,0)
	removeWorldModel(i,100,-82,-1565,0)
	removeWorldModel(i,40,-9.10546875,-1342.9189453125,0)
	removeWorldModel(i,200,-225.6123046875,-1045.9599609375,0)
	removeWorldModel(i,50,-44.1962890625,-1186,0)
	removeWorldModel(i,300,-635.0517578125,-612.4794921875,0)
	removeWorldModel(i,60,-413.0703125,-831.916015625,0)
	removeWorldModel(i,150,-1009.9833984375,-496.525390625,20)
	removeWorldModel(i,200,-1294.435546875,-237.9306640625,14.14396572113)
	removeWorldModel(i,30,-1952.2939453125,-1357.43359375,44.623191833496)
	removeWorldModel(i,400,-850.275390625,-1720.2431640625,75.714630126953)
	removeWorldModel(i,600,-532.7958984375,-2352.36328125,0)
	removeWorldModel(i,200,-905.79296875,-2713.06640625,50)
	removeWorldModel(i,300,-1337.8740234375,-1400.2314453125,90.85820007324)
	removeWorldModel(i,100,-33.7333984375,-2725.4423828125,60)
	restoreWorldModel(i,100,368,-1783,11)-- Restores a portion of Los Santos Beach, had error where something got deleted.
	removeWorldModel(i,50,-395,-1745,25)
	removeWorldModel(i,40,-406,-404,19)
	removeWorldModel(i,10,-1535,-1635,41)
	removeWorldModel(i,50,-1162,-2355,20)
	removeWorldModel(i,1000,-1657,1688,0)
	removeWorldModel(i,600,-2655,1002,0)
	removeWorldModel(i,30,-258,-1811,19)
	 
end


-- Problems with this SHADOW -- 
removeWorldModel(17388,10000,-1200,-1600,0,0) --lod
removeWorldModel(17385,10000,-1200,-1600,0,0) --lod
removeWorldModel(17384,10000,-1200,-1600,0,0) --lod
removeWorldModel(17414,10000,-1200,-1600,0,0) --lod

setOcclusionsEnabled( false )
	




