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
	
	-- Enterable Tropic (Ziggy)
	--tropicDFF = engineLoadDFF("mods/vehicles/tropic.dff", 454)
	--engineReplaceModel(tropicDFF, 454)
	--tropicTXD = engineLoadTXD("mods/vehicles/tropic.txd")
	--engineImportTXD(tropicTXD, 454)
	

	--HSU Mod Start
	
	vanDFF = engineLoadDFF("mods/vehicles/policevan.dff", 459)
	engineReplaceModel(vanDFF, 459)
	vanTXD = engineLoadTXD("mods/vehicles/policevan.txd")
	engineImportTXD(vanTXD, 459)

	--[[ DISABLED HSU
	hsuDFF2 = engineLoadDFF("mods/hsu.dff", 502)
	engineReplaceModel(hsuDFF2, 502)
	hsuTXD2 = engineLoadTXD("mods/hsu.txd")
	engineImportTXD(hsuTXD2, 502)
	]]
	
	speedbumpDFF2 = engineLoadDFF("mods/speedbump.dff", 2926)
	engineReplaceModel(speedbumpDFF2, 2926)
	speedbumpTXD2 = engineLoadTXD("mods/speedbump.txd")
	engineImportTXD(speedbumpTXD2, 2926)
	
	intCOL = engineLoadCOL("mods/speedbump.col")
	engineReplaceCOL(intCOL, 2926)
	
	stopsignDFF2 = engineLoadDFF("mods/stopsign.dff", 1352)
	engineReplaceModel(stopsignDFF2, 1352)
	stopsignTXD2 = engineLoadTXD("mods/stopsign.txd")
	engineImportTXD(stopsignTXD2, 1352)
	
	intCOL = engineLoadCOL("mods/stopsign.col")
	engineReplaceCOL(intCOL, 1352)
	
	slickDFF2 = engineLoadDFF("mods/vehicles/swat.dff", 546)
	engineReplaceModel(slickDFF2, 546)
	slickTXD2 = engineLoadTXD("mods/vehicles/swat.txd")
	engineImportTXD(slickTXD2, 546)
	
	slickDFF2 = engineLoadDFF("mods/vehicles/feltzer.dff", 533)
	engineReplaceModel(slickDFF2, 533)
	slickTXD2 = engineLoadTXD("mods/vehicles/feltzer.txd")
	engineImportTXD(slickTXD2, 533)
	
	slickDFF2 = engineLoadDFF("mods/vehicles/landstal.dff", 400)
	engineReplaceModel(slickDFF2, 400)
	slickTXD2 = engineLoadTXD("mods/vehicles/landstal.txd")
	engineImportTXD(slickTXD2, 400)
	
	sfDFF2 = engineLoadDFF("mods/vehicles/copcarsf.dff", 481)
	engineReplaceModel(sfDFF2, 597)
	sfTXD2 = engineLoadTXD("mods/vehicles/copcarsf.txd")
	engineImportTXD(sfTXD2, 597)
	
	dylanDFF = engineLoadDFF("mods/skins/dylan.dff", 231)
	engineReplaceModel(dylanDFF, 231)
	dylanTXD = engineLoadTXD("mods/skins/dylan.txd")
	engineImportTXD(dylanTXD, 231)

	ambulanceDFF = engineLoadDFF("mods/vehicles/ambulan.dff", 416)
	engineReplaceModel(ambulanceDFF, 416)
	ambulanceTXD = engineLoadTXD("mods/vehicles/ambulan.txd")
	engineImportTXD(ambulanceTXD, 416)
	
	polslsDFF = engineLoadDFF("mods/vehicles/copcarla.dff", 596)
	engineReplaceModel(polslsDFF, 596)
	polslsTXD = engineLoadTXD("mods/vehicles/copcarla.txd")
	engineImportTXD(polslsTXD, 596)
	
	polslsaDFF = engineLoadDFF("mods/vehicles/cabbie.dff", 490)
	engineReplaceModel(polslsaDFF, 490)
	polslsaTXD = engineLoadTXD("mods/vehicles/cabbie.txd")
	engineImportTXD(polslsaTXD, 490)

	polsvgDFF = engineLoadDFF("mods/vehicles/copcarvg.dff", 598)
	engineReplaceModel(polsvgDFF, 598)
	polsvgTXD = engineLoadTXD("mods/vehicles/copcarvg.txd")
	engineImportTXD(polsvgTXD, 598)
	
	expDFF = engineLoadDFF("mods/vehicles/sunrise.dff", 550)
	engineReplaceModel(expDFF, 550)
	expTXD = engineLoadTXD("mods/vehicles/sunrise.txd")
	engineImportTXD(expTXD, 550)
	
	preDFF = engineLoadDFF("mods/vehicles/premier.dff", 426)
	engineReplaceModel(preDFF, 426)
	preTXD = engineLoadTXD("mods/vehicles/premier.txd")
	engineImportTXD(preTXD, 426)
	
	
	-- hDFF2 = engineLoadDFF("mods/vehicles/h.dff", 598)
	--engineReplaceModel(hDFF2, 598)
	--hTXD2 = engineLoadTXD("mods/vehicles/h.txd")
	--engineImportTXD(hTXD2, 598)
	--HSU Mod End
	
	--Leviathan Mod Start
	leviDFF = engineLoadDFF("mods/levi.dff", 417)
	engineReplaceModel(leviDFF, 417)
	leviTXD = engineLoadTXD("mods/levi.txd")
	engineImportTXD(leviTXD, 417)
	--Leviathan Mod End

	cargoDFF = engineLoadDFF("mods/vehicles/cargo.dff", 548)
	engineReplaceModel(cargoDFF, 548)
	cargoTXD = engineLoadTXD("mods/vehicles/cargo.txd")
	engineImportTXD(cargoTXD, 548)
	
	hdDFF = engineLoadDFF("mods/vehicles/hotdog.dff", 588)
	engineReplaceModel(hdDFF, 588)
	hdTXD = engineLoadTXD("mods/vehicles/hotdog.txd")
	engineImportTXD(hdTXD, 588)
	
	cargoDFF = engineLoadDFF("mods/vehicles/patriot.dff", 470)
	engineReplaceModel(cargoDFF, 470)
	cargoTXD = engineLoadTXD("mods/vehicles/patriot.txd")
	engineImportTXD(cargoTXD, 470)
	
	cargoDFF = engineLoadDFF("mods/vehicles/firetruk.dff", 407)
	engineReplaceModel(cargoDFF, 407)
	cargoTXD = engineLoadTXD("mods/vehicles/firetruk.txd")
	engineImportTXD(cargoTXD, 407)
	
	cargoDFF = engineLoadDFF("mods/vehicles/firela.dff", 544)
	engineReplaceModel(cargoDFF, 544)
	cargoTXD = engineLoadTXD("mods/vehicles/firela.txd")
	engineImportTXD(cargoTXD, 544)
	
	cargoDFF = engineLoadDFF("mods/vehicles/banshee.dff", 429)
	engineReplaceModel(cargoDFF, 429)
	cargoTXD = engineLoadTXD("mods/vehicles/banshee.txd")
	engineImportTXD(cargoTXD, 429)
	
	cargoDFF = engineLoadDFF("mods/vehicles/raindance.dff", 563)
	engineReplaceModel(cargoDFF, 563)
	cargoTXD = engineLoadTXD("mods/vehicles/raindance.txd")
	engineImportTXD(cargoTXD, 563)

	engineReplaceModel(engineLoadDFF("mods/vehicles/copcarru.dff", 599), 599)
	engineImportTXD(engineLoadTXD("mods/vehicles/copcarru.txd"), 599)

	-- DFT-30 mod by Adams (He has given the permission - anumaz, 13/06/2014)
	engineReplaceModel(engineLoadDFF("mods/vehicles/dft30.dff", 578), 578)
	local dftTXD = engineLoadTXD("mods/vehicles/dft30.txd")
	engineImportTXD(dftTXD, 578)


	engineReplaceModel(engineLoadDFF("mods/vehicles/trailer.dff", 611 ), 611)
	local trailerTXD = engineLoadTXD("mods/vehicles/trailer.txd")
	engineImportTXD(trailerTXD, 611)

	--remove SAN logo from newsvans
	local newsvanTXD = engineLoadTXD("mods/vehicles/newsvan.txd")
	engineImportTXD(newsvanTXD, 582)
	--remove logo and tailnumber from maverick to allow custom replacement
	local vcnmavTXD = engineLoadTXD("mods/vehicles/vcnmav.txd")
	engineImportTXD(vcnmavTXD, 488)

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
	
	--[[
	local sniper1 = engineLoadDFF("mods/weapons/sniper.dff", 358)
	engineReplaceModel(sniper1, 358)
	local sniper2 = engineLoadTXD("mods/weapons/sniper.txd")
	engineImportTXD(sniper2, 358)
	]]

		local glock1 = engineLoadDFF("mods/weapons/glock.dff", 358)
	engineReplaceModel(glock1, 348)
	local glock2 = engineLoadTXD("mods/weapons/glock.txd")
	engineImportTXD(glock2, 348)
	
			local glock1 = engineLoadDFF("mods/weapons/colt.dff", 346)
	engineReplaceModel(glock1, 346)
	local glock2 = engineLoadTXD("mods/weapons/colt.txd")
	engineImportTXD(glock2, 346)
	
		local mp51 = engineLoadDFF("mods/weapons/mp5.dff", 353)
	engineReplaceModel(mp51, 353)
	local mp52 = engineLoadTXD("mods/weapons/mp5.txd")
	engineImportTXD(mp52, 353)
	
			local mp51 = engineLoadDFF("mods/weapons/cuntgun.dff", 357)
	engineReplaceModel(mp51, 357)
	local mp52 = engineLoadTXD("mods/weapons/cuntgun.txd")
	engineImportTXD(mp52, 357)
	
			local mp51 = engineLoadDFF("mods/weapons/ak47.dff", 355)
	engineReplaceModel(mp51, 355)
	local mp52 = engineLoadTXD("mods/weapons/ak47.txd")
	engineImportTXD(mp52, 355)
	
			local mp51 = engineLoadDFF("mods/weapons/mp5.dff", 353)
	engineReplaceModel(mp51, 353)
	local mp52 = engineLoadTXD("mods/weapons/mp5.txd")
	engineImportTXD(mp52, 353)
	
			local silenced1 = engineLoadDFF("mods/weapons/Silenced.dff", 347)
	engineReplaceModel(silenced1, 347)
	local silenced2 = engineLoadTXD("mods/weapons/silenced.txd")
	engineImportTXD(silenced2, 347)
	
			local silenced1 = engineLoadDFF("mods/weapons/sniper.dff", 358)
	engineReplaceModel(silenced1, 358)
	local silenced2 = engineLoadTXD("mods/weapons/sniper.txd")
	engineImportTXD(silenced2, 358)
	
			local silenced1 = engineLoadDFF("mods/weapons/Chromegun.dff", 349)
	engineReplaceModel(silenced1, 349)
	local silenced2 = engineLoadTXD("mods/weapons/Chromegun.txd")
	engineImportTXD(silenced2, 349)
	
			local silenced1 = engineLoadDFF("mods/weapons/m4.dff", 356)
	engineReplaceModel(silenced1, 356)
	local silenced2 = engineLoadTXD("mods/weapons/m4.txd")
	engineImportTXD(silenced2, 356)
	
			local silenced1 = engineLoadDFF("mods/skins/smokev.dff", 146)
	engineReplaceModel(silenced1, 146)
	local silenced2 = engineLoadTXD("mods/skins/smokev.txd")
	engineImportTXD(silenced2, 146)
	
				local silenced1 = engineLoadDFF("mods/skins/tenpen.dff", 265)
	engineReplaceModel(silenced1, 265)
	local silenced2 = engineLoadTXD("mods/skins/tenpen.txd")
	engineImportTXD(silenced2, 265)
	
				local silenced1 = engineLoadDFF("mods/skins/swfysi.dff", 10)
	engineReplaceModel(silenced1, 10)
	local silenced2 = engineLoadTXD("mods/skins/swfysi.txd")
	engineImportTXD(silenced2, 10)
	
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
	
	local txdd = engineLoadTXD("mods/skins/dog.txd")
	engineImportTXD(txdd,75)
	local dffd = engineLoadDFF("mods/skins/dog.dff",75)
	engineReplaceModel(dffd,75)

	local txdm = engineLoadTXD("mods/skins/nude.txd")
	engineImportTXD(txdm,279)
	local dffm = engineLoadDFF("mods/skins/nude.dff",279)
	engineReplaceModel(dffm,279)
	
	local coptxd = engineLoadTXD("mods/skins/femalecop.txd")
	engineImportTXD(coptxd,238)
	local copdff = engineLoadDFF("mods/skins/femalecop.dff",238)
	engineReplaceModel(copdff,238)
	
	local medtxd = engineLoadTXD("mods/skins/femalemed.txd")
	engineImportTXD(medtxd,244)
	local meddff = engineLoadDFF("mods/skins/femalemed.dff",244)
	engineReplaceModel(meddff,244)
	
	local leontxd = engineLoadTXD("mods/skins/leon.txd")
	engineImportTXD(leontxd,311)
	local leondff = engineLoadDFF("mods/skins/leon.dff",311)
	engineReplaceModel(leondff,311)
	
	local medtxd = engineLoadTXD("mods/skins/lapdciv.txd")
	engineImportTXD(medtxd,264)
	local meddff = engineLoadDFF("mods/skins/lapdciv.dff",264)
	engineReplaceModel(meddff,264)
	
	local medtxd = engineLoadTXD("mods/skins/swat.txd")
	engineImportTXD(medtxd,285)
	local meddff = engineLoadDFF("mods/skins/swat.dff",285)
	engineReplaceModel(meddff,285)
	
	local medtxd = engineLoadTXD("mods/vehicles/fbitruck.txd")
	engineImportTXD(medtxd,528)
	local meddff = engineLoadDFF("mods/vehicles/fbitruck.dff")
	engineReplaceModel(meddff,528)
		
	local medtxd = engineLoadTXD("mods/vehicles/supergt.txd")
	engineImportTXD(medtxd,506)
	local meddff = engineLoadDFF("mods/vehicles/supergt.dff")
	engineReplaceModel(meddff,506)
	
	local medtxd = engineLoadTXD("mods/vehicles/vincent.txd")
	engineImportTXD(medtxd,540)
	local meddff = engineLoadDFF("mods/vehicles/vincent.dff")
	engineReplaceModel(meddff,540)
		
	local medtxd = engineLoadTXD("mods/vehicles/Yosemite.txd")
	engineImportTXD(medtxd,540)
	local meddff = engineLoadDFF("mods/vehicles/Yosemite.dff")
	engineReplaceModel(meddff,540)
	

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