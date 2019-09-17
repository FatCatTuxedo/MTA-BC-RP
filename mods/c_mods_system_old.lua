function applyMods()
	--Car Icon Start
	disabledIconDFF = engineLoadDFF("mods/disabledicon.dff", 1314)
	engineReplaceModel(disabledIconDFF, 1314)
	disabledIconTXD = engineLoadTXD("mods/icons.txd")
	engineImportTXD(disabledIconTXD, 1314)
	--Car Icon End
	
	--Fix interior ID 24 Start
	intCOL = engineLoadCOL("mods/fixes/interior24.col")
	engineReplaceCOL(intCOL, 14776)
	--Fix interior ID 24 End
	--[[
	--SEB Skin Start
	skinDFF = engineLoadDFF("mods/skins/seb.dff", 287)
	engineReplaceModel(skinDFF, 287)
	skinTXD = engineLoadTXD("mods/skins/seb.txd")
	engineImportTXD(skinTXD, 287)
	--SEB Skin End
	]]

	--HSU Mod Start
	
	hsuDFF = engineLoadDFF("mods/hsu.dff", 494)
	engineReplaceModel(hsuDFF, 494)
	hsuTXD = engineLoadTXD("mods/hsu.txd")
	engineImportTXD(hsuTXD, 494)
	
	hsuDFF2 = engineLoadDFF("mods/hsu.dff", 502)
	engineReplaceModel(hsuDFF2, 502)
	hsuTXD2 = engineLoadTXD("mods/hsu.txd")
	engineImportTXD(hsuTXD2, 502)
	--HSU Mod End
	
	--Leviathan Mod Start
	leviDFF = engineLoadDFF("mods/levi.dff", 417)
	engineReplaceModel(leviDFF, 417)
	leviTXD = engineLoadTXD("mods/levi.txd")
	engineImportTXD(leviTXD, 417)
	--Leviathan Mod End


	engineReplaceModel(engineLoadDFF("mods/vehicles/patriot.dff", 470), 470)
	engineImportTXD(engineLoadTXD("mods/vehicles/patriot.txd"), 470)

	-- DFT-30 mod by Adams (He has given the permission - anumaz, 13/06/2014)
	engineReplaceModel(engineLoadDFF("mods/vehicles/dft30.dff", 578), 578)
	local dftTXD = engineLoadTXD("mods/vehicles/dft30.txd")
	engineImportTXD(dftTXD, 578)


	engineReplaceModel(engineLoadDFF("mods/vehicles/trailer.dff", 611 ), 611)
	local trailerTXD = engineLoadTXD("mods/vehicles/trailer.txd")
	engineImportTXD(trailerTXD, 611)

	--[[
	--Factory object
	engineReplaceModel(engineLoadDFF("mods/factory.dff", 14584), 14584)
	engineReplaceCOL(engineLoadCOL("mods/factory.col"), 14584)
	]]

--[[
	engineReplaceModel(engineLoadDFF("mods/maps/lsmall_shop01.dff", 6048), 6048)
	engineReplaceModel(engineLoadDFF("mods/maps/lsmall_window01.dff", 6048), 6048)
	engineReplaceModel(engineLoadDFF("mods/maps/mallb_laW02.dff", 6048), 6048)
	engineImportTXD(engineLoadTXD("mods/maps/lsmall_shops.txd"), 6048)
 ]]
	-- Bus stops
	busStop = engineLoadTXD("ls/bustopm.txd")
	engineImportTXD(busStop, 1257)

	-- Retextures
	a = engineLoadTXD ( "ls/barrio1_lae.txd" )
	engineImportTXD ( a, 5489 )	
	
	b = engineLoadTXD ( "ls/idlewood6_detail.txd" )
	engineImportTXD ( b, 5489 )
	
	local sniper1 = engineLoadDFF("mods/weapons/sniper.dff", 358)
	engineReplaceModel(sniper1, 358)
	local sniper2 = engineLoadTXD("mods/weapons/sniper.txd")
	engineImportTXD(sniper2, 358)

	--Picture Frames Collisions (Exciter)
	frameCol = engineLoadCOL("mods/cols/frame_4.col")
	engineReplaceCOL(frameCol, 2287)
	
	--[[
	--Special skin for admin and supporters on-duty / MAXIME
	local admin1 = engineLoadDFF("mods/skins/admin.dff", 90)
	engineReplaceModel(admin1, 90)
	local admin2 = engineLoadTXD("mods/skins/admin.txd")
	engineImportTXD(admin2, 90)
	]]


	-----------
	-- Items --
	-----------

	--iFruit by Maxime
	local iFruit1 = engineLoadDFF("mods/items/cellphone.dff", 330)
	engineReplaceModel(iFruit1, 330)
	local iFruit2 = engineLoadTXD("mods/items/cellphone.txd")
	engineImportTXD(iFruit2, 330)

	--Cola Bottle (Exciter)
	local txd = engineLoadTXD("items/cola.txd")
	engineImportTXD(txd,2880)
	local dff = engineLoadDFF("items/cola.dff",2880)
	engineReplaceModel(dff,2880)

	----------------------------------
	-- Chistmas Only Mods (Exciter) --
	----------------------------------
	--[[
	local txd = engineLoadTXD("xmas/artict1.txd") --Trailer: artict1
	engineImportTXD(txd,591)
	local dff = engineLoadDFF("xmas/artict1.dff",591) --Trailer: artict1
	engineReplaceModel(dff,591)
	local txd = engineLoadTXD("xmas/rdtrain.txd") --Roadtrain
	engineImportTXD(txd,515)
	local dff = engineLoadDFF("xmas/rdtrain.dff",515) --Roadtrain
	engineReplaceModel(dff,515)
	--Santa
	santaSkin = engineLoadTXD("xmas/santa.txd")
	engineImportTXD(santaSkin, 245)
	santaSkin = engineLoadDFF("xmas/santa.dff")
	engineReplaceModel(santaSkin, 245)
	--]]

end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
     function()
         applyMods()
         setTimer (applyMods, 1000, 1)
end
)