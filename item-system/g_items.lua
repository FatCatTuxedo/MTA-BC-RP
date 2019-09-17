g_items = {
	[1] = { "Hotdog", "A steamy, good looking and tasty hotdog.", 1, 2215, 205, 205, 0, 0.01, weight = 0.1 },
	[2] = { "Cellphone", "A sleek cellphone, look's like a new one too.", 7, 330, 90, 90, 0, 0, weight = 0.3 },
	[3] = { "Vehicle Key", "A vehicle key with a small manufacturers badge on it.", 2, 1581, 270, 270, 0, 0, weight = 0.1 },
	[4] = { "House Key", "A green house key.", 2, 1581, 270, 270, 0, 0, weight = 0.1 },
	[5] = { "Business Key", "A blue business key.", 2, 1581, 270, 270, 0, 0, weight = 0.1 },
	[6] = { "Radio", "A black radio.", 7, 330, 90, 90, 0, -0.05, weight = 0.2 },
	[7] = { "Phonebook", "A torn phonebook.", 5, 2824, 0, 0, 0, -0.01, weight = 2 },
	[8] = { "Sandwich", "A yummy sandwich with cheese.", 1, 2355, 205, 205, 0, 0.06, weight = 0.3 },
	[9] = { "Softdrink", "A can of Sprunk.", 1, 2647, 0, 0, 0, 0.12, weight = 0.2 },
	[10] = { "Dice", "A white dice with black dots on #v sides.", 4, 1271, 0, 0, 0, 0.285, weight = 0.1 },
	[11] = { "Taco", "A greasy mexican taco.", 1, 2215, 205, 205, 0, 0.06, weight = 0.1 },
	[12] = { "Burger", "A double cheeseburger with bacon.", 1, 2703, 265, 0, 0, 0.06, weight = 0.3 },
	[13] = { "Donut", "Hot sticky sugar covered donut.", 1, 2222, 0, 0, 0, 0.07, weight = 0.2 },
	[14] = { "Cookie", "A luxury chocolate chip cookie.", 1, 2222, 0, 0, 0, 0.07, weight = 0.1 },
	[15] = { "Water", "A bottle of mineral water.", 1, 1484, -15, 30, 0, 0.2, weight = 1 },
	[16] = { "Clothes", "A set of clean clothes. (( Skin ID ##v ))", 6, 2386, 0, 0, 0, 0.1, weight = 1 },
	[17] = { "Watch", "A smart gold watch.", 6, 1271, 0, 0, 0, 0.285, weight = 0.1 },
	[18] = { "City Guide", "A small city guide booklet.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[19] = { "MP3 Player", "A white, sleek looking MP3 Player. The brand reads EyePod.", 7, 1210, 270, 0, 0, 0.1, weight = 0.1 },
	[20] = { "Standard Fighting for Dummies", "A book on how to do standard fighting.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[21] = { "Boxing for Dummies", "A book on how to do boxing.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[22] = { "Kung Fu for Dummies", "A book on how to do kung fu.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[23] = { "Knee Head Fighting for Dummies", "A book on how to do grab kick fighting.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[24] = { "Grab Kick Fighting for Dummies", "A book on how to do elbow fighting.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[25] = { "Elbow Fighting for Dummies", "A book on how to do elbow fighting.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[26] = { "Gas Mask", "A black gas mask, blocks out the effects of gas and flashbangs.", 6, 2386, 0, 0, 0, 0.1, weight = 0.5 },
	[27] = { "Flashbang", "A small grenade canister with FB written on the side.", 4, 343, 0, 0, 0, 0.1, weight = 0.2 },
	[28] = { "Glowstick", "A green glowstick.", 4, 343, 0, 0, 0, 0.1, weight = 0.2 },
	[29] = { "Door Ram", "A red metal door ram.", 4, 1587, 90, 0, 0, 0.05, weight = 3 },
	[30] = { "Cannabis Sativa", "Cannabis Sativa, when mixed can create some strong drugs.", 3, 1279, 0, 0, 0, 0, weight = 0.1 },
	[31] = { "Cocaine Alkaloid", "Cocaine Alkaloid, when mixed can create some strong drugs.", 3, 1279, 0, 0, 0, 0, weight = 0.1 },
	[32] = { "Lysergic Acid", "Lysergic Acid, when mixed can create some strong drugs.", 3, 1279, 0, 0, 0, 0, weight = 0.1 },
	[33] = { "Unprocessed PCP", "Unprocessed PCP, when mixed can create some strong drugs.", 3, 1279, 0, 0, 0, 0, weight = 0.1 },
	[34] = { "Cocaine", "A powder-like substance giving a huge energy kick.", 3, 1575, 0, 0, 0, 0, weight = 0.1 },
	[35] = { "Morphine", "A pill or liquid substance with strong effects.", 3, 1578, 0, 0, 0, -0.02, weight = 0.1 },
	[36] = { "Ecstasy", "Pills with strong visuals and europhoria.", 3, 1576, 0, 0, 0, 0.07, weight = 0.1 },
	[37] = { "Heroin", "A powder-like or liquid substance with strong slowing effects and heavy europhoria.", 3, 1579, 0, 0, 0, 0, weight = 0.1 },
	[38] = { "Marijuana", "Green, good tasting weed.", 3, 3044, 0, 0, 0, 0.04, weight = 0.1 },
	[39] = { "Methamphetamine", "A crystal-like substance with strong energy kicking effects.", 3, 1580, 0, 0, 0, 0, weight = 0.1 },
	[40] = { "Epinephrine (Adrenaline)", "Epinephrine - a liquid substance that boosts adrenaline.", 3, 1575, 0, 0, 0, -0.02, weight = 0.1 },
	[41] = { "LSD", "Lysergic acid with diethylamide, gives funny visuals.", 3, 1576, 0, 0, 0, 0, weight = 0.1 },
	[42] = { "Shrooms", "Dry golden teacher mushrooms.", 3, 1577, 0, 0, 0, 0, weight = 0.1 },
	[43] = { "PCP", "Phencyclidine powder.", 3, 1578, 0, 0, 0, 0, weight = 0.1 },
	[44] = { "Chemistry Set", "A small chemistry set.", 4, 1210, 90, 0, 0, 0.1, weight = 3 },
	[45] = { "Handcuffs", "A pair of metal handcuffs.", 4, 2386, 0, 0, 0, 0.1, weight = 0.4 },
	[46] = { "Rope", "A long rope.", 4, 1271, 0, 0, 0, 0.285, weight = 0.3 },
	[47] = { "Handcuff Keys", "A small pair of handcuff keys.", 4, 2386, 0, 0, 0, 0.1, weight = 0.05 },
	[48] = { "Backpack", "A reasonably sized backpack.", 4, 3026, 270, 0, 0, 0, weight = 1 },
	[49] = { "Fishing Rod", "A 7 foot carbon steel fishing rod.", 4, 338, 80, 0, 0, -0.02, weight = 1.5 },
	[50] = { "Los Santos Highway Code", "The Los Santos Highway Code.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[51] = { "Chemistry 101",  "An Introduction to Useful Chemistry.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[52] = { "Police Officer's Manual", "The Police Officer's Manual.", 5, 2824, 0, 0, 0, -0.01, weight = 0.3 },
	[53] = { "Breathalizer", "A small black breathalizer.", 4, 1271, 0, 0, 0, 0.285, weight = 0.2 },
	[54] = { "Ghettoblaster", "A black Ghettoblaster.", 7, 2226, 0, 0, 0, 0, weight = 3 },
	[55] = { "Business Card", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.1 }, --Steven Pullman - L.V. Freight Depot, Tel: 12555
	[56] = { "Ski Mask", "A Ski mask.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 },
	[57] = { "Fuel Can", "A small metal fuel canister.", 4, 1650, 0, 0, 0, 0.30, weight = 1 }, -- would prolly to make sense to make it heavier if filled
	[58] = { "Ziebrand Beer", "The finest beer, imported from Holland.", 1, 1520, 0, 0, 0, 0.15, weight = 1 },
	[59] = { "Mudkip", "So i herd u liek mudkips? mabako's Favorite.", 1, 1579, 0, 0, 0, 0, weight = 0 },
	[60] = { "Safe", "A safe to store your items in.", 4, 2332, 0, 0, 0, 0, weight = 5 },
	[61] = { "Emergency Light Strobes", "An Emergency Light Strobe which you can put on you car.", 7, 1210, 270, 0, 0, 0.1, weight = 0.1 },
	[62] = { "Bastradov Vodka", "For your best friends - Bastradov Vodka.", 1, 1512, 0, 0, 0, 0.25, weight = 1 },
	[63] = { "Scottish Whiskey", "The Best Scottish Whiskey, now exclusively made from Haggis.", 1, 1512, 0, 0, 0, 0.25, weight = 1 },
	[64] = { "LSPD Badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[65] = { "Fort Carson Area EMS ID", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[66] = { "Blindfold", "A black blindfold.", 6, 2386, 0, 0, 0, 0.1, weight = 0.1 },
	[67] = { "GPS", "(( This item is currently disabled. ))", 6, 1210, 270, 0, 0, 0.1, weight = 0.8 },
	[68] = { "Lottery Ticket", "A Los Santos Lottery ticket.", 6, 2894, 0, 0, 0, -0.01, weight = 0.1 },
	[69] = { "Dictionary", "A Dictionary.", 5, 2824, 0, 0, 0, -0.01, weight = 1.5 },
	[70] = { "First Aid Kit", "Saves a Life. Can be used #v times.", 4, 1240, 90, 0, 0, 0.05, weight = function(v) return v/3 end },
	[71] = { "Notebook", "A small collection of blank papers, useful for writing notes. There are #v pages left. ((/writenote))", 4, 2894, 0, 0, 0, -0.01, weight = function(v) return v*0.01 end },
	[72] = { "Note", "The note reads: #v", 4, 2894, 0, 0, 0, -0.01, weight = 0.01 },
	[73] = { "Elevator Remote", "A small remote to change an elevator's mode.", 2, 364, 0, 0, 0, 0.05, weight = 0.3 },
	[74] = { "Bomb", "What could possibly happen when you use this?", 4, 363, 270, 0, 0, 0.05, weight = 100000 },
	[75] = { "Bomb Remote", "Has a funny red button.", 4, 364, 0, 0, 0, 0.05, weight = 100000 },
	[76] = { "Riot Shield", "A heavy riot shield.", 4, 1631, -90, 0, 0, 0.1, weight = 5 },
	[77] = { "Card Deck", "A card deck to play some games.", 4,2824, 0, 0, 0, -0.01, weight = 0.1 },
	[78] = { "San Andreas Pilot Certificate", "An official permission to fly planes and helicopters.", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[79] = { "Porn Tape", "A porn tape, #v", 4,2824, 0, 0, 0, -0.01, weight = 0.2 },
	[80] = { "Generic Item", "#v", 4, 1271, 0, 0, 0, 0, weight = 1 },
	[81] = { "Fridge", "A fridge to store food and drinks in.", 7, 2147, 0, 0, 0, 0, weight = 0.1 --[[Just here to look pretty, but fridges ain't available to easily buy]] },
	[82] = { "Global Media News Identification", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[83] = { "Coffee", "A small cup of Coffee.", 1, 2647, 0, 0, 0, 0.12, weight = 0.25 },
	[84] = { "Escort 9500ci Radar Detector", "Detects Police within a half mile.", 7, 330, 90, 90, 0, -0.05, weight = 1 },
	[85] = { "Police Siren", "An emergency siren to put in your car.", 7, 330, 90, 90, 0, -0.05, weight = 0.2 },
	[86] = { "LTC ID", "#v.", 10, 330, 90, 90, 0, -0.05, weight = 0.3 },
	[87] = { "LS Government Badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.5 },
	[88] = { "Earpiece", "A small earpiece, can be connected to a radio.", 7, 1581, 270, 270, 0, 0, weight = 0.15 },
	[89] = { "Food", "", 1, 2222, 0, 0, 0, 0.07, weight = 1 },
	[90] = { "Motocross Helmet", "Ideal for riding bikes.", 6, 2799, 0, 0, 0, 0.2, weight = 1.5, scale = 1, hideItemValue = true },
	[91] = { "Eggnog", "Yum Yum.", 1, 2647, 0, 0, 0, 0.1, weight = 0.5 }, --91
	[92] = { "Turkey", "Yum Yum.", 1, 2222, 0, 0, 0, 0.1, weight = 3.8 },
	[93] = { "Christmas Pudding", "Yum Yum.", 1, 2222, 0, 0, 0, 0.1, weight = 0.4 },
	[94] = { "Christmas Present", "I know you want one.", 4, 1220, 0, 0, 0, 0.1, weight = 1 },
	[95] = { "Drink", "", 1, 1484, -15, 30, 0, 0.2, weight = 1 },
	[96] = { "Macbook pro A1286 Core i7", "A top of the range Macbook to view e-mails and browse the internet.", 6, 2886, 0, 0, 180, 0.1, weight = function(v) return v == 1 and 0.2 or 1.5 end },
	[97] = { "LSFD Procedures Manual", "The Los Santos Emergency Service procedures handbook.", 5, 2824, 0, 0, 0, -0.01, weight = 0.5 },
	[98] = { "Garage Remote", "A small remote to open or close a Garage.", 2, 364, 0, 0, 0, 0.05, weight = 0.3 },
	[99] = { "Mixed Dinner Tray", "Lets play the guessing game.", 1, 2355, 205, 205, 0, 0.06, weight = 0.4 },
	[100] = { "Small Milk Carton", "Lumps included!", 1, 2856, 0, 0, 0, 0, weight = 0.2 },
	[101] = { "Small Juice Carton", "Thirsty?", 1, 2647, 0, 0, 0, 0.12, weight = 0.2 },
	[102] = { "Cabbage", "For those Vegi-Lovers.", 1, 1271, 0, 0, 0, 0.1, weight = 0.4 },
	[103] = { "Shelf", "A large shelf to store stuff on", 4, 3761, -0.15, 0, 85, 1.95, weight = 0.1 --[[admins onleh]] },
	[104] = { "Portable TV", "A portable TV to watch TV shows with.", 6, 1518, 0, 0, 0, 0.29, weight = 1 },
	[105] = { "Pack of cigarettes", "Pack with #v cigarettes in it.", 6, 3044 , 270, 0, 0, 0.1, weight = function(v) return 0.1 + v*0.03 end }, -- 105
	[106] = { "Cigarette", "Something you can smoke.", 6, 3044 , 270, 0, 0, 0.1, weight = 0.03 }, -- 106
	[107] = { "Lighter", "It makes fire if you use it properly.", 6, 1210, 270, 0, 0, 0.1, weight = 0.05 }, -- 107
	[108] = { "Pancake", "Yummy, a pancake!.", 1, 2222, 0, 0, 0, 0.07, weight = 0.5 }, -- 108
	[109] = { "Fruit", "Yummy, healthy food!.", 1, 2222, 0, 0, 0, 0.07, weight = 0.35 }, -- 109
	[110] = { "Vegetable", "Yummy, healthy food!.", 1, 2222, 0, 0, 0, 0.07, weight = 0.35  }, -- 110
	[111] = { "Portable GPS", "A GPS, also contains recent maps.", 6, 1210, 270, 0, 0, 0.1, weight = 0.3 }, -- 111
	[112] = { "FBI Badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 }, -- 142
	[113] = { "Pack of Glowsticks", "Pack with #v glowsticks in it, from the brand 'Friday'.", 6, 1210, 270, 0, 0, 0.1, weight = function(v) return v * 0.2 end }, -- 113
	[114] = { "Vehicle Upgrade", "#v", 4, 1271, 0, 0, 0, 0.285, weight = 1.5 }, -- 114
	[115] = { "Weapon", "#v ", 8, 2886, 270, 0, 1, 0.1, 2, weight = function( v )
																		local weaponID = tonumber( explode(":", v)[1] )
																		return weaponID and weaponweights[ weaponID ] or 1
																	end
	}, -- 115
	[116] = { "Ammopack", "Ammopack with #v bullets inside.", 9, 2040, 0, 1, 0, 0.1, 3, weight = function( v ) local weaponID = tonumber( explode(":", v)[1] ) local ammo = tonumber( explode(":", v)[2] ) return weaponID and ammo and ammoweights[ weaponID ] and ammoweights[ weaponID ] * ammo or 0.2 end }, -- 2886 / 116
	[117] = { "Ramp", "Useful for loading DFT-30s.", 4, 1210, 270, 1, 0, 0.1, 3, weight = 5 }, -- 117
	[118] = { "Toll Pass", "Put it in your car, charges you every time you drive through a toll booth.", 6, 1210, 270, 0, 0, 0.1, weight = 0.3 }, -- 118
	[119] = { "DoJ badge", "a DoJ badge", 10, 1210, 270, 0, 0, 0.1, weight = 0.2 }, -- 119
	[120] = { "Scuba Gear", "Allows you to stay under-water for quite some time", 6, 1271, 0, 0, 0, 0.285, weight = 4 }, --120
	[121] = { "Box with supplies", "Pretty large box full with supplies!", 4, 1271, 0, 0, 0, 0.285, weight = function(v) return v * 0.07 end }, --121
	[122] = { "Light Blue Bandana", "A light blue rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 122
	[123] = { "Red Bandana", "A red rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 123
	[124] = { "Black Bandana", "A black rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 124
	[125] = { "Purple Bandana", "A purple rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 125
	[126] = { "Duty Belt", "A slick black leather duty belt, with many holsters.", 4, 2386, 270, 0, 0, 0, weight = 1 }, -- 126
	[127] = { "FAA badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 }, --127
	[128] = { "Los Santos Towing & Recovery ID", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 }, --128 --MAXIME | ADD TTR FACTION BAGDE ITEM | 24.1.14
	[129] = { "Business ID", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 }, --129
	[130] = { "Vehicle Alarm System", "A vehicle alarm system.", 6, 1210, 270, 0, 0, 0.1, weight = 0.3 }, -- 130
	[131] = { "BCT&R Badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 }, -- 131
	[132] = { "Prescription Bottle", "A prescription bottle, contains prescription medicine.", 3, 1575, 0, 0, 0, 0.04, weight = 0.1 }, --132
	[133] = { "Driver's License - Automotive", "A Los Santos driving license.", 10, 1581, 270, 270, 0, 0, weight = 0.1 }, -- MAXIME
	[134] = { "Money", "Los Santos currency.", 10, 1212, 0, 0, 0, 0.04, weight = 0.3 }, -- 134
	[135] = { "Blue Bandana", "A blue rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 135
	[136] = { "Brown Bandana", "A brown rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 136
	[137] = { "Snake Cam", "A snake cam, used in SWAT operations.", 7, 330, 90, 90, 0, -0.05, weight = 0.3 }, -- 137
	[138] = { "Bait Vehicle System", "A device used in Police operations.", 4, 1271, 0, 0, 0, 0.285, weight = 0.5 }, -- 138
	--[139] = { "Vehicle Tracker", "A device used to track the vehicles position", 7, 1271, 0, 0, 0, 0.285, weight = 0.2 }, --139
	[140] = { "Orange Light Strobes", "An Orange Light Strobe which you can put on you car.", 7, 1210, 270, 0, 0, 0.1, weight = 0.1 }, --140
	[141] = { "Megaphone", "A cone-shaped device used to intensify or direct your voice.", 7, 1210, 270, 0, 0, 0.1, weight = 0.1 }, --141
	[142] = { "Los Santos Cab & Bus ID", "A Los Santos Cab & Bus Identification Card.", 10, 1210, 270, 0, 0, 0.1, weight = 0.3 }, -- 142
	[143] = { "Mobile Data Terminal", "A Mobile Data Terminal.", 7, 2886, 0, 0, 180, 0.1, weight = 0.1 }, -- 143
	[144] = { "Yellow Strobe", "A yellow strobe to put on your car.", 7, 2886, 270, 0, 0, 0.1, weight = 0.1 }, -- 144
	[145] = { "Flashlight", "Lights up the environment.", 7, 1210, 0, 0, 0, 0, weight = 1 }, --145
	[146] = { "Global Media News Identification Card", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[147] = { "Wallpaper", "For retexturing your interior.", 4, 2894, 0, 0, 0, -0.01, weight = 0.01 }, --147
	[148] = { "Open Carry Weapon License", "A firearm permit which allows a person to openly carry a firearm.", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[149] = { "Concealed Carry Weapon License", "A firearm permit which allows the concealment of a firearm.", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[150] = { "ATM Card", "A plastic card used to make transactions with a very limited amount per day from an automatic teller machine (ATM).", 10, 1581, 270, 270, 0, 0, weight = 0.1 }, -- MAXIME
	[151] = { "Lift Remote", "A remote device for a vehicle lift.", 2, 364, 0, 0, 0, 0.05, weight = 0.3 },
	[152] = { "San Andreas Identification Card", "A sleek plastic Identification Card.", 10, 1581, 270, 270, 0, 0, weight = 0.1 }, -- MAXIME
	[153] = { "Driver's License - Motorbike", "A Los Santos driving license.", 10, 1581, 270, 270, 0, 0, weight = 0.1 }, -- MAXIME
	[154] = { "Fishing Permit", "A Los Santos fishing permit", 10, 1581, 270, 270, 0, 0, weight = 0.1 }, -- MAXIME
	[155] = { "Driver's License - Boat", "A Los Santos driving license.", 10, 1581, 270, 270, 0, 0, weight = 0.1 },
	[156] = { "SANG ID", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.1 },
	[157] = { "Toolbox", "A metallic red toolbox containing various tools.", 4, 1271, 0, 0, 0, 0, weight = 0.5 },
	[158] = { "Green Bandana", "A green rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, -- 158
	[159] = { "Bone County Express ID", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3}, -- 159 | anumaz Cargo Group ID card
	[160] = { "Briefcase", "A briefcase.", 6, 1210, 90, 0, 0, 0.1, weight = 0.4}, -- Exciter
	[161] = { "BCVFD badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3}, -- 161 | anumaz Fleming Architecture and Construction ID
	[162] = { "SWAT Helmet", "Bulletproof helmet.", 6, 3916, 90, 0, 0, 0.1, weight = 4}, -- Exciter
	[163] = { "Duffle Bag", "A duffle bag.", 6, 3915, 90, 0, 0, 0.2, weight = 0.4}, -- Exciter
	[164] = { "Medical Bag", "Bag with advanced medical equipment.", 6, 3915, 0, 0, 0, 0.2, weight = 1, texture = {{":artifacts/textures/medicbag.png", "hoodyabase5"}} }, -- Exciter
	[165] = { "DVD", "A video disc.", 4, 2894, 0, 0, 0, -0.01, weight = 0.1 }, -- Exciter
	[166] = { "ClubTec VS1000", "Video System.", 4, 3388, 0, 0, 90, -0.01, weight = 5, scale = 0.6, preventSpawn = true, newPickupMethod = true }, -- Exciter
	[167] = { "Framed Picture (Golden Frame)", "Put your picture in and hang it on your wall.", 4, 2287, 0, 0, 0, 0, weight = 1, doubleSided = true, newPickupMethod = true }, -- Exciter
	[168] = { "Orange Bandana", "A orange rag.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 },
	[169] = { "Keyless Digital Door Lock", "This high-ended security system is much more secure than a traditional keyed lock because they can't be picked or bumped.", 6, 2922, 0, 0, 180, 0.2, weight = 0.5 }, --Maxime
	[170] = { "Keycard", "A swipe card for #v", 2, 1581, 270, 270, 0, 0, weight = 0.1 }, -- Exciter
	[171] = { "Biker Helmet", "Ideal for riding bikes.", 6, 3911, 0, 0, 0, 0.2, weight = 1.5, scale = 1, hideItemValue = true },
	[172] = { "Full Face Helmet", "Ideal for riding bikes.", 6, 3917, 0, 0, 0, 0.2, weight = 1.5, scale = 1, hideItemValue = true },
	[173] = { "DMV Vehicle Ownership Transfer", "Document needed to sell a vehicle to someone else.", 4, 2894, 0, 0, 0, -0.01, weight = 0.01 }, -- Anumaz
	[174] = { "FAA Electronical Map Book", "Electronic device displaying information and maps around all San Andreas.", 4, 1271, 0, 0, 0, -0.01, weight = 0.01 }, -- Anumaz
	[175] = { "Poster", "An advertising poster.", 4, 2717, 0, 0, 0, 0.7, weight = 0.01, hideItemValue = true }, -- Exciter
	[176] = { "Speaker", "Big black speaker that kicks out huge, gives you sound big enough to fill any space, clear sound at any volume.", 7, 2232, 0, 0, 0, 0.6, weight = 3 }, -- anumaz
	[177] = { "Remote Dispatch Device", "A remote dispatch device connected to Dispatch Center, powered by Tree Technology.", 7, 1581, 0, 0, 0, 0.6, weight = 0.01 }, -- anumaz
    [178] = { "Book", "#v", 5, 2824, 0, 0, 0, -0.1, weight = 0.1}, -- Chaos
    [179] = { "Car Motive", "A motive to decorate your car with.", 4, 2894, 0, 0, 0, -0.01, weight = 0.01 }, -- Exciter
    [180] = { "STC ID", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3}, -- Exciter
    [181] = { "Smoking package", "Transparent rolling papers. Pack contains #v papers.", 4, 3044 , 270, 0, 0, 0.1, weight = function(v) return 0.1 + v*0.03 end },
    [182] = { "Rolled Joint", "A rolled joint of pure marijuana.", 4, 1485, 270, 0, 0, 0.1, weight = 0.03 },
    [183] = { "Viozy Membership Card", "Viozy Businesses Exclusive Membership", 10, 1581, 270, 270, 0, 0, weight = 0.3 }, --  Chase
    [184] = { "HP Charcoal Window Film", "Viozy HP Charcoal Window Film ((50 /chance))", 4, 1271, 0, 0, 0, 0, weight = 0.6 }, -- Chase
    [185] = { "CXP70 Window Film", "Viozy CXP70 Window Film ((95 /chance))", 4, 1271, 0, 0, 0, 0, weight = 0.3 }, -- Chase
    [186] = { "Viozy Border Edge Cutter (Red Anodized)", "Border Edge Cutter for Tinting", 4, 1271, 0, 0, 0, 0, weight = 0.05 }, -- Chase
    [187] = { "Viozy Solar Spectrum Tranmission Meter", "Spectrum Meter for testing film before use", 7, 1271, 0, 0, 0, 0, weight = 2 }, -- Chase
    [188] = { "Viozy Tint Chek 2800", "Measures the Visible Light Transmission on any film/glass", 7, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase
    [189] = { "Viozy Equalizer Heatwave Heat Gun", "Easy to use heat gun perfect for shrinking back windows", 7, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase
    [190] = { "Viozy 36 Multi-Purpose Cutter Bucket", "Ideal for light cutting jobs while applying tint", 4, 1271, 0, 0, 0, 0, weight = 0.5 }, -- Chase
    [191] = { "Viozy Tint Demonstration Lamp", "Effectve presentation of tinted application", 7, 1271, 0, 0, 0, 0, weight = 0.5 }, -- Chase
    [192] = { "Viozy Triumph Angled Scraper", "6-inch Angled Scraper for applying tint", 4, 1271, 0, 0, 0, 0, weight = 0.3 }, -- Chase
    [193] = { "Viozy Performax 48oz Hand Sprayer", "Performax Hand Sprayer for tint application", 4, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase
    [194] = { "Viozy Vehicle Ignition - 2010 ((20 /chance))", "Vehicle Ignition made by Viozy for 2010", 4, 1271, 0, 0, 0, 0, weight = 1.5 }, -- Chase
    [195] = { "Viozy Vehicle Ignition - 2011 ((30 /chance))", "Vehicle Ignition made by Viozy for 2011", 4, 1271, 0, 0, 0, 0, weight = 1.3 }, -- Chase
    [196] = { "Viozy Vehicle Ignition - 2012 ((40 /chance))", "Vehicle Ignition made by Viozy for 2012", 4, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase
    [197] = { "Viozy Vehicle Ignition - 2013 ((50 /chance))", "Vehicle Ignition made by Viozy for 2013", 4, 1271, 0, 0, 0, 0, weight = 0.8 }, -- Chase
    [198] = { "Viozy Vehicle Ignition - 2014 ((70 /chance))", "Vehicle Ignition made by Viozy for 2014", 4, 1271, 0, 0, 0, 0, weight = 0.6 }, -- Chase
    [199] = { "Viozy Vehicle Ignition - 2015 ((90 /chance))", "Vehicle Ignition made by Viozy for 2015", 4, 1271, 0, 0, 0, 0, weight = 0.4 }, -- Chase
    [200] = { "Viozy Vehicle Ignition - 2016", "Vehicle Ignition not yet in production", 4, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase (not to be used)
    [201] = { "Viozy Vehicle Ignition - 2017", "Vehicle Ignition not yet in production", 4, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase (not to be used)
    [202] = { "Viozy Vehicle Ignition - 2018", "Vehicle Ignition not yet in production", 4, 1271, 0, 0, 0, 0, weight = 1 }, -- Chase (not to be used)
    [203] = { "Viozy Hidden Vehicle Tracker 315 Pro ((Undetectable))", "GPS HVT 315 Pro, easy installation ((and undetectable)), by Viozy", 7, 1271, 0, 0, 0, 0, weight = 3 }, -- Chase
    [204] = { "Viozy Hidden Vehicle Tracker 272 Micro ((30 /chance))", "GPS HVT 272 Micro, easy installation ((30 /chance to be found)), by Viozy", 7, 1271, 0, 0, 0, 0, weight = 0.5 }, -- Chase
    [205] = { "Viozy HVT 358 Portable Spark Nano 4.0 ((50 /chance))", "GPS HVT 358 Spark Nano 4.0 Portable ((50 /chance to be found)), by Viozy", 7, 1271, 0, 0, 0, 0, weight = 0.2 }, -- Chase
	[206] = { "Wheat Seed", "A nice seed with potential", 7, 1271, 0, 0, 0, 0, weight = 0.1 }, -- Chaos
	[207] = { "Barley Seed", "A nice seed with potential", 7, 1271, 0, 0, 0, 0, weight = 0.1 }, -- Chaos
	[208] = { "Oat Seed", "A nice seed with potential", 7, 1271, 0, 0, 0, 0, weight = 0.1 }, -- Chaos
	[209] = { "FLU Device", "An eletronical device by Firearms Licensing Unit", 7, 1271, 0, 0, 0, 0, weight = 0.1}, -- anumaz
	[210] = { "Coca-Cola Christmas", "A bottle of coke, christmas edition.", 1, 2880, 180, 0, 0, 0, weight = 0.2}, -- Exciter
	[211] = { "Iron", "From the FC mine.", 10, 3930, 270, 270, 0, 0, weight = 0.1}, -- Exciter
	[212] = { "Snow Tires", "Stick to the ground like velcro!", 4, 1098, 0, 0, 0, 0, weight = 1}, -- Exciter
	[213] = { "Pinnekjott", "Exciter's christmas favourite.", 1, 2215, 205, 205, 0, 0.06, weight = 0.1, preventSpawn = true}, -- Exciter
	[214] = { "Generic Drug", "#v", 3, 1576, 0, 0, 0, 0.07, weight = 0.1}, -- Chaos
	[215] = { "Emergency Light Bar", "An emergency light bar to put in your car.", 7, 3895, 90, 90, 0, -0.05, weight = 0.2 },
	[216] = { "Cinema Control", "A remote control for the cinema.", 7, 364, 0, 0, 0, 0.05, weight = 0.1 },
	[217] = { "Tactical vest", "Body armor", 6, 3916, 0, 0, 0, 0.1, weight = 1, scale = 1, hideItemValue = true}, -- Exciter
	[218] = { "Emergency Doctor Lights", "An Emergency Light Strobe which you can put on you car.", 7, 1210, 270, 0, 0, 0.1, weight = 0.1 },
	[219] = { "Funeral Lights", "An Emergency Light Strobe which you can put on you car.", 7, 1210, 270, 0, 0, 0.1, weight = 0.1 },
	[220] = { "Detective Tactical vest", "Body armor", 6, 3916, 0, 0, 0, 0.1, weight = 1, scale = 1, hideItemValue = true}, -- George
	[221] = { "BCSO Badge", "#v", 10, 1581, 270, 270, 0, 0, weight = 0.3 },
	[222] = { "KKK Hood", "a white hood with eye holes.", 6, 2386, 0, 0, 0, 0.1, weight = 0.2 }, --127
	[223] = { "Ambulance Siren", "Why do you have this in ur inv m8?", 7, 364, 0, 0, 0, 0.05, weight = 0.1 },
	[224] = { "Fire Siren", "Why do you have this in ur inv m8?", 7, 364, 0, 0, 0, 0.05, weight = 0.1 },
	
	--{ "Armor", "Kevlar-made armor.", 6, 373, 90, 90, 0, -0.05, weight = 1 }, -- 138
	--{ "Dufflebag", "LOL", 10, 2462, 0, 0, 0, 0.04, weight = 0.1 }, -- 135
}

	-- name, description, category, model, rx, ry, rz, zoffset

	-- categories:
	-- 1 = Food & Drink
	-- 2 = Keys
	-- 3 = Drugs
	-- 4 = Other
	-- 5 = Books
	-- 6 = Clothing & Accessories
	-- 7 = Electronics
	-- 8 = guns
	-- 9 = bullets
	-- 10 = wallet

weaponmodels = {
	[1]=331, [2]=333, [3]=326, [4]=335, [5]=336, [6]=337, [7]=338, [8]=339, [9]=341,
	[15]=326, [22]=346, [23]=347, [24]=348, [25]=349, [26]=350, [27]=351, [28]=352,
	[29]=353, [32]=372, [30]=355, [31]=356, [33]=357, [34]=358, [35]=359, [36]=360,
	[37]=361, [38]=362, [16]=342, [17]=343, [18]=344, [39]=363, [41]=365, [42]=366,
	[43]=367, [10]=321, [11]=322, [12]=323, [14]=325, [44]=368, [45]=369, [46]=371,
	[40]=364, [100]=373
}

-- other melee weapons?
weaponweights = {
	[22] = 1.14, [23] = 1.24, [24] = 2, [25] = 3.1, [26] = 2.1, [27] = 4.2, [28] = 3.6, [29] = 2.640, [30] = 4.3, [31] = 2.68, [32] = 3.6, [33] = 4.0, [34] = 4.3
}

ammoweights =
{
	[22] = 0.0224, [23] = 0.0224, [24] = 0.017, [25] = 0.037, [26] = 0.037, [27] = 0.037, [28] = 0.009, [29] = 0.012, [30] = 0.0165, [31] = 0.0112, [32] = 0.009, [33] = 0.0128, [34] = 0.027
}

--
-- Vehicle upgrades as names
--
vehicleupgrades = {
	"Pro Spoiler", "Win Spoiler", "Drag Spoiler", "Alpha Spoiler", "Champ Scoop Hood",
	"Fury Scoop Hood", "Roof Scoop", "Right Sideskirt", "5x Nitro", "2x Nitro",
	"10x Nitro", "Race Scoop Hood", "Worx Scoop Hood", "Round Fog Lights", "Champ Spoiler",
	"Race Spoiler", "Worx Spoiler", "Left Sideskirt", "Upswept Exhaust", "Twin Exhaust",
	"Large Exhaust", "Medium Exhaust", "Small Exhaust", "Fury Spoiler", "Square Fog Lights",
	"Offroad Wheels", "Right Alien Sideskirt (Sultan)", "Left Alien Sideskirt (Sultan)",
	"Alien Exhaust (Sultan)", "X-Flow Exhaust (Sultan)", "Left X-Flow Sideskirt (Sultan)",
	"Right X-Flow Sideskirt (Sultan)", "Alien Roof Vent (Sultan)", "X-Flow Roof Vent (Sultan)",
	"Alien Exhaust (Elegy)", "X-Flow Roof Vent (Elegy)", "Right Alien Sideskirt (Elegy)",
	"X-Flow Exhaust (Elegy)", "Alien Roof Vent (Elegy)", "Left X-Flow Sideskirt (Elegy)",
	"Left Alien Sideskirt (Elegy)", "Right X-Flow Sideskirt (Elegy)", "Right Chrome Sideskirt (Broadway)",
	"Slamin Exhaust (Chrome)", "Chrome Exhaust (Broadway)", "X-Flow Exhaust (Flash)", "Alien Exhaust (Flash)",
	"Right Alien Sideskirt (Flash)", "Right X-Flow Sideskirt (Flash)", "Alien Spoiler (Flash)",
	"X-Flow Spoiler (Flash)", "Left Alien Sideskirt (Flash)", "Left X-Flow Sideskirt (Flash)",
	"X-Flow Roof (Flash)", "Alien Roof (Flash)", "Alien Roof (Stratum)", "Right Alien Sideskirt (Stratum)",
	"Right X-Flow Sideskirt (Stratum)", "Alien Spoiler (Stratum)", "X-Flow Exhaust (Stratum)",
	"X-Flow Spoiler (Stratum)", "X-Flow Roof (Stratum)", "Left Alien Sideskirt (Stratum)",
	"Left X-Flow Sideskirt (Stratum)", "Alien Exhaust (Stratum)", "Alien Exhaust (Jester)",
	"X-FLow Exhaust (Jester)", "Alien Roof (Jester)", "X-Flow Roof (Jester)", "Right Alien Sideskirt (Jester)",
	"Right X-Flow Sideskirt (Jester)", "Left Alien Sideskirt (Jester)", "Left X-Flow Sideskirt (Jester)",
	"Shadow Wheels", "Mega Wheels", "Rimshine Wheels", "Wires Wheels", "Classic Wheels", "Twist Wheels",
	"Cutter Wheels", "Switch Wheels", "Grove Wheels", "Import Wheels", "Dollar Wheels", "Trance Wheels",
	"Atomic Wheels", "Stereo System", "Hydraulics", "Alien Roof (Uranus)", "X-Flow Exhaust (Uranus)",
	"Right Alien Sideskirt (Uranus)", "X-Flow Roof (Uranus)", "Alien Exhaust (Uranus)",
	"Right X-Flow Sideskirt (Uranus)", "Left Alien Sideskirt (Uranus)", "Left X-Flow Sideskirt (Uranus)",
	"Ahab Wheels", "Virtual Wheels", "Access Wheels", "Left Chrome Sideskirt (Broadway)",
	"Chrome Grill (Remington)", "Left 'Chrome Flames' Sideskirt (Remington)",
	"Left 'Chrome Strip' Sideskirt (Savanna)", "Covertible (Blade)", "Chrome Exhaust (Blade)",
	"Slamin Exhaust (Blade)", "Right 'Chrome Arches' Sideskirt (Remington)",
	"Left 'Chrome Strip' Sideskirt (Blade)", "Right 'Chrome Strip' Sideskirt (Blade)",
	"Chrome Rear Bullbars (Slamvan)", "Slamin Rear Bullbars (Slamvan)", false, false, "Chrome Exhaust (Slamvan)",
	"Slamin Exhaust (Slamvan)", "Chrome Front Bullbars (Slamvan)", "Slamin Front Bullbars (Slamvan)",
	"Chrome Front Bumper (Slamvan)", "Right 'Chrome Trim' Sideskirt (Slamvan)",
	"Right 'Wheelcovers' Sideskirt (Slamvan)", "Left 'Chrome Trim' Sideskirt (Slamvan)",
	"Left 'Wheelcovers' Sideskirt (Slamvan)", "Right 'Chrome Flames' Sideskirt (Remington)",
	"Bullbar Chrome Bars (Remington)", "Left 'Chrome Arches' Sideskirt (Remington)", "Bullbar Chrome Lights (Remington)",
	"Chrome Exhaust (Remington)", "Slamin Exhaust (Remington)", "Vinyl Hardtop (Blade)", "Chrome Exhaust (Savanna)",
	"Hardtop (Savanna)", "Softtop (Savanna)", "Slamin Exhaust (Savanna)", "Right 'Chrome Strip' Sideskirt (Savanna)",
	"Right 'Chrome Strip' Sideskirt (Tornado)", "Slamin Exhaust (Tornado)", "Chrome Exhaust (Tornado)",
	"Left 'Chrome Strip' Sideskirt (Tornado)", "Alien Spoiler (Sultan)", "X-Flow Spoiler (Sultan)",
	"X-Flow Rear Bumper (Sultan)", "Alien Rear Bumper (Sultan)", "Left Oval Vents", "Right Oval Vents",
	"Left Square Vents", "Right Square Vents", "X-Flow Spoiler (Elegy)", "Alien Spoiler (Elegy)",
	"X-Flow Rear Bumper (Elegy)", "Alien Rear Bumper (Elegy)", "Alien Rear Bumper (Flash)",
	"X-Flow Rear Bumper (Flash)", "X-Flow Front Bumper (Flash)", "Alien Front Bumper (Flash)",
	"Alien Rear Bumper (Stratum)", "Alien Front Bumper (Stratum)", "X-Flow Rear Bumper (Stratum)",
	"X-Flow Front Bumper (Stratum)", "X-Flow Spoiler (Jester)", "Alien Rear Bumper (Jester)",
	"Alien Front Bumper (Jester)", "X-Flow Rear Bumper (Jester)", "Alien Spoiler (Jester)",
	"X-Flow Spoiler (Uranus)", "Alien Spoiler (Uranus)", "X-Flow Front Bumper (Uranus)",
	"Alien Front Bumper (Uranus)", "X-Flow Rear Bumper (Uranus)", "Alien Rear Bumper (Uranus)",
	"Alien Front Bumper (Sultan)", "X-Flow Front Bumper (Sultan)", "Alien Front Bumper (Elegy)",
	"X-Flow Front Bumper (Elegy)", "X-Flow Front Bumper (Jester)", "Chrome Front Bumper (Broadway)",
	"Slamin Front Bumper (Broadway)", "Chrome Rear Bumper (Broadway)", "Slamin Rear Bumper (Broadway)",
	"Slamin Rear Bumper (Remington)", "Chrome Front Bumper (Remington)", "Chrome Rear Bumper (Remington)",
	"Slamin Front Bumper (Blade)", "Chrome Front Bumper (Blade)", "Slamin Rear Bumper (Blade)",
	"Chrome Rear Bumper (Blade)", "Slamin Front Bumper (Remington)", "Slamin Rear Bumper (Savanna)",
	"Chrome Rear Bumper (Savanna)", "Slamin Front Bumper (Savanna)", "Chrome Front Bumper (Savanna)",
	"Slamin Front Bumper (Tornado)", "Chrome Front Bumper (Tornado)", "Chrome Rear Bumper (Tornado)",
	"Slamin Rear Bumper (Tornado)"
}

--
-- Badges
--

function getBadges( )
	return {
		-- [itemID] = {elementData, name, factionIDs, color, iconID}
		[156]  = { "SANG ID", 		"a SANG ID",			{[50] = true},				 	 {73, 136, 245}, 1},
		[64]  = { "LSPD badge", 		"an LSPD badge",			{[-1] = true},				 	{0,100,255, true},	2},
		[221]  = { "BCSO badge", 		"a BCSO badge",			{[1] = true},				 	{13,41,131, true},	8},
		[112]  = { "FBI badge", 		"an FBI badge",			{[-1] = true},				 	{255, 194, 14, true},	4}, -- Sheriff department
		[65]  = { "Fort Carson Area EMS ID", 		"a Fort Carson Area EMS ID", {[2] = true},	    {153,223,178},	1},
		[86]  = { "LTC ID",		"a LTC ID",				{[87] = true},					{215,142,16},	1},
		[87]  = { "GOV badge",		"a Government badge",		{[3] = true},					{0, 80, 0},	1},
		[119] = { "DoJ badge",		"an DoJ badge",				{[80] = true},					{42,119,161},	7},
		[122] = { "light blue bandana", "a light blue bandana",				{[-1] = true},					{0,185,200},	122},
		[123] = { "red bandana", "a red bandana",				{[-1] = true},					{190,0,0},	123},
		[124] = { "black bandana", "a black bandana",				{[-1] = true},					{30,30,30},	124},
		[125] = { "purple bandana", "a purple bandana",				{[-1] = true},					{220,0,255},	125},
		[135] = { "blue bandana", "a blue bandana",				{[-1] = true},					{0,100,255},	135},
		[136] = { "brown bandana", "a brown bandana",				{[-1] = true},					{125,63,50},	136},
		[158] = { "green bandana", "a green bandana",				{[-1] = true},					{50,150,50},	158},
		[168] = { "orange bandana", "a orange bandana",				{[-1] = true},					{210,105,30},	168},
		[127] = { "BCAA ID",		"a BCAA ID",	{[83] = true},	{5,102,40},	1},
		[82] = { "Global Media News ID", "a Global Media News ID",	{[64] = true},	{0,185,200},	1},
		[159] = { "Bone County Express ID", "An ID from Bone County Express", {[82] = true},  {255, 76, 66}, 1},
		[180] = { "STC ID", "an STC ID", {[56] = true},  {210, 180, 140}, 1}, -- Exciter
		[161] = { "BCVFD badge", "a BCVFD badge", {[-1] = true}, {175,50,50}, 3}, -- anumaz, BCC ID
		[129] = { "Business ID",		"a Business ID",	{[-1] = true},	{88, 130, 250},	1},
		[131] = { "BCT&R badge",        "a BCT&R badge",                {[76] = true},                    {210, 180, 140},    1}, -- George added the badge 7/8/2016
		[222] = { "KKK hood", "a KKK hood",				{[-1] = true},					{255,255, 255},	222},
		--[146] = { "Global Media News",		"a Global Media News Identification Card",					{[64] = true}, 				{128,0,128},	1}
	}
end

-- badges/IDs should generally be in the wallet.
for k, v in pairs(getBadges()) do
	if not v[3][-1] and g_items[k][3] ~= 10 then
		outputDebugString('Badge/ID' .. k .. ' is not in wallet.')
	end
end

--
-- Mask Data
--
function getMasks( )
	return {
		-- [itemID] = { elementData, textWhenPuttingOn, textWhentakingOff, hideIdentity }
		[26]  = {"gasmask",			"slips a black gas mask over their face",	"slips a black gas mask off their face",	true},
		[56]  = {"mask",			"slips a mask over their face",				"slips a mask off their face",				true},
		[90]  = {"helmet",			"puts a #name over their head",				"takes a #name off their head",				false},
		[120] = {"scuba",			"puts scuba gear on",						"takes scuba gear off",						true},
		[217]  = {"vest",			"puts on their tactical vest",				"takes off their tactical vest",				false},
		[220]  = {"vest",			"puts on their tactical vest",				"takes off their tactical vest",				false},
		[162]  = {"swat",			"puts on their SWAT helmet",				"takes off their SWAT helmet",				false},
	}
end