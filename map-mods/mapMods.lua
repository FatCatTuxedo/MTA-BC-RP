-- DON'T FORGET TO RECOMPLE!!!
-- Place the .txd's before the .dff's, this is VERY IMPORTANT!!!
-- Add mods to the meta.xml

-- Load Map Modifications
-------------------------->>

function loadMapMods()
	--[[
	Insert Map Mods Here:

	Example (.txd files):
	txd = engineLoadTXD("data/euros.txd")
	engineImportTXD(txd, 587)

	Example (.dff files):
	dff = engineLoadDFF("data/euros.dff")
	engineReplaceModel(dff, 587)

	Example (.col files):
	col_floors = engineLoadCOL("models/office_floors.col")
	engineReplaceCOL(col_floors, 3781)
	--]]

	--Diego's Custom Objects
	col1 = engineLoadCOL('objects/wall006.col')
	dff1 = engineLoadDFF('objects/wall006.dff', 0)
	txd1 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd1,3063)
        engineReplaceCOL(col1, 3063)
	engineReplaceModel(dff1, 3063)

	col2 = engineLoadCOL('objects/wall018.col')
	dff2 = engineLoadDFF('objects/wall018.dff', 0)
	txd2 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd2,3097)
        engineReplaceCOL(col2, 3097)
	engineReplaceModel(dff2, 3097)

	col3 = engineLoadCOL('objects/wall019.col')
	dff3 = engineLoadDFF('objects/wall019.dff', 0)
	txd3 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd3,10252)
        engineReplaceCOL(col3, 10252)
	engineReplaceModel(dff3, 10252)

	col4 = engineLoadCOL('objects/wall036.col')
	dff4 = engineLoadDFF('objects/wall036.dff', 0)
	txd4 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd4,3099)
        engineReplaceCOL(col4, 3099)
	engineReplaceModel(dff4, 3099)

	col5 = engineLoadCOL('objects/wall052.col')
	dff5 = engineLoadDFF('objects/wall052.dff', 0)
	txd5 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd5,3098)
        engineReplaceCOL(col5, 3098)
	engineReplaceModel(dff5, 3098)

	col6 = engineLoadCOL('objects/wall090.col')
	dff6 = engineLoadDFF('objects/wall090.dff', 0)
	txd6 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd6,3064)
        engineReplaceCOL(col6, 3064)
	engineReplaceModel(dff6, 3064)

	col7 = engineLoadCOL('objects/wall102.col')
	dff7 = engineLoadDFF('objects/wall102.dff', 0)
	txd7 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd7,7922)
        engineReplaceCOL(col7, 7922)
	engineReplaceModel(dff7, 7922)

        dff = engineLoadDFF ('objects/wall071.dff', 0)
        col = engineLoadCOL ('objects/wall071.col')
        txd = engineLoadTXD ('objects/All_walls.txd')
        engineImportTXD(txd, 3898)
        engineReplaceCOL(col, 3898)
        engineReplaceModel(dff, 3898)


	col9 = engineLoadCOL('objects/lsmall_window01.col')
	dff9 = engineLoadDFF('objects/lsmall_window01.dff', 0)
	txd9 = engineLoadTXD('objects/lsmall_shops.txd')
        engineImportTXD(txd9,3900)
        engineReplaceCOL(col9, 3900)
	engineReplaceModel(dff9, 3900)

	col10 = engineLoadCOL('objects/mallb_laW02.col')
	dff10 = engineLoadDFF('objects/mallb_law02.dff', 0)
	txd10 = engineLoadTXD('objects/mall_law.txd')
        engineImportTXD(txd10,6130)
        engineReplaceCOL(col10, 6130)
	engineReplaceModel(dff10, 6130)

	col11 = engineLoadCOL('objects/wall041.col')
	dff11 = engineLoadDFF('objects/wall041.dff', 0)
	txd11 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd11,3917)
        engineReplaceCOL(col11, 3917)
	engineReplaceModel(dff11, 3917)

	dff12 = engineLoadDFF ('objects/wall012.dff', 0)
	col12 = engineLoadCOL ('objects/wall012.col')
	txd12 = engineLoadTXD ('objects/All_walls.txd')
        engineImportTXD(txd12, 3911)
        engineReplaceCOL(col12, 3911)
        engineReplaceModel(dff12, 3911)

	col13 = engineLoadCOL('objects/wall058.col')
	dff13 = engineLoadDFF('objects/wall058.dff', 0)
	txd13 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd13,3907)
        engineReplaceCOL(col13, 3907)
	engineReplaceModel(dff13, 3907)


	col14 = engineLoadCOL('objects/wall077.col')
	dff14 = engineLoadDFF('objects/wall077.dff', 0)
	txd14 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd14,3906)
        engineReplaceCOL(col14, 3906)
	engineReplaceModel(dff14, 3906)

	col15 = engineLoadCOL('objects/wall096.col')
	dff15 = engineLoadDFF('objects/wall096.dff', 0)
	txd15 = engineLoadTXD('objects/All_walls.txd')
        engineImportTXD(txd15,3905)
        engineReplaceCOL(col15, 3905)
	engineReplaceModel(dff15, 3905)

	dff55 = engineLoadDFF ( "objects/hospital_law.dff", 0 )
	engineReplaceModel ( dff55, 5708 )
	col55 = engineLoadCOL ( "objects/hospitalos.col")
	engineReplaceCOL ( col55, 5708 )

	col56 = engineLoadCOL ( "objects/streetbugfix.col")
	engineReplaceCOL ( col56, 5808 )
	
		col16 = engineLoadCOL('objects/AllSAMPCOLs.col')
	dff16 = engineLoadDFF('objects/LCDTV1.dff', 0)
	txd16 = engineLoadTXD('objects/SAMPLCDTVs1.txd')
        engineImportTXD(txd16,2648)
        engineReplaceCOL(col16, 2648)
	engineReplaceModel(dff16, 2648)

	dff58 = engineLoadDFF('objects/f-s.dff', 0)
	engineReplaceModel(dff58, 5810)
			col58 = engineLoadCOL('objects/fs.col')
	engineReplaceCOL(col58, 5810)
	removeWorldModel(762, 1000, 1175.3594, -1420.1875, 19.8828)
	
	dff17 = engineLoadDFF('objects/Flatgrass.dff', 0)
	txd16 = engineLoadTXD('objects/Flatgrass.txd')
	engineImportTXD(txd16,8417)
	engineReplaceModel(dff17, 8417)
	
		col17 = engineLoadCOL('objects/k_cargo4.col')
		dff18 = engineLoadDFF('objects/k_cargo4.dff', 0)
	txd17 = engineLoadTXD('objects/k_cargo4.txd')
	engineImportTXD(txd17,13725)
	engineReplaceCOL(col17, 13725)
	engineReplaceModel(dff18, 13725)

end
addEventHandler("onClientResourceStart", resourceRoot, loadMapMods)
