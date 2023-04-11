# Pokemon are assumed to be at this level for calculating EHP
EHP_LEVEL = 50

MAPS_AVAILABLE_BY_CAP = {
	15 =>
		[
			136,138,30,	# Casaba Villa, Scenic Trail, Windy Way
			51,38,26,	# Foreclosed Tunnel, Beach Route, Seaside Grotto
			35,27,		# Impromptu Lab, Casaba Mart
		], 
	20 =>
		[
			60,56,66,123,		# Shipping Lane, Nemeth, Nemeth Attic, Nemeth Academy
			142,140,141, 		# Starters Store Maps
			3,25,55,6,326,	 	# Savannah Route, Mining Camp, Flower Rest, LuxTech Campus, The Barrows
			301,37,7,8,53, 		# County Park, Svait, Wet Walkways, The Tangle
			117,36,10,40, 		# Ice Cave, Abandoned Mine, Jungle Temple, Gigalith's Guts
			11,122,120, 		# River Route, Sewer, Deep Layer
			121,130,129,59, 	# Skyward Ascent, Canal Desert, Barren Crater, Mainland Dock
			96,98,126, 			# Luxtech Cold Storage, LuxTech Cold Storage Basement, Sun Cave
			4,20,86,       		# Scientist's House, Lengthy Glade, Zigzagoon Nest, LuxTech Cold Storage Basement
			323,87,103,92,    	# HQ Station Backroom, LuxTech Rec Center, Ghost Town Mart, Ice Rink Lodge
			32,71,74,			# Nemeth Apartments, Nemeth Apartments Room 103, Nemeth Apartments Room 203
			91,65,85,			# Reading Ribombee Cafe, Nemeth Mart, Worried Man's House
			213,214,219,		# Velenz Menagerie, Gigalith's Guts Town, Regirock Cave
			217,49,243,			# Candy Town, Tourist's House, Chasm Base Mess Hall
			251,305,321,	    # Samorn's House, Mainland Dock Warehouse, Crater Station Backroom
		],
	25 =>
		[
			335,185			# Sauna Underground, Eleig Stretch
		],
	40 =>
		[
			155,29,47,		# Prizca West, Full Blast Records F2, Grand Hotal
			34,183,180,		# Battle Fair, Circuit Cave, Priza West Mart
			185,186,239,	# Eleig Stretch, Farm Placeholder, Ocean Fishing Zone
			187,189,202,	# Prizca East, Catacombs, Mountaineer's House
			193,196,203,	# Lapras Shore, Boiling Cave, Skeevee Eevee Pub
			211,212,216,	# Split Peaks, Ocean Fishing, Highland Lake
			218,230,232,	# Abyssal Chamber, Galarian Fan's House, Biologist's House
			234,220,228,	# Ranger Recruitment, Prizca Sewers East, Hidden Laboratory
			223,250,288,	# Prizca Sewers West, Chasm Base Lab, Underground River
		],
	60 =>
		[
			217,316,			# Sweetrock Harbor, Sandtone Estuary
			257,258,	# Cave of Hatching, Whitebloom Town
			215,		# Sky Walk
		],
  }
  
ITEMS_AVAILABLE_BY_CAP = {
	15 => [],
	20 => [],
	25 => [],
	30 => [],
	40 => [:FIRESTONE,:WATERSTONE,:LEAFSTONE,:THUNDERSTONE,:DAWNSTONE,
			:DUSKSTONE,:SUNSTONE,:SHINYSTONE,:ICESTONE,:KINGSROCK,:MOONSTONE,
			:NINJASCARF,:KNIGHTHELMET,:DIAMONDTIARA,:ALOLANWREATH,:GALARICAWREATH
			
			]
}

SURFING_LEVEL = 35

HIDDEN_MAPS = {
	193 => 52, # Volcanic Shore
	196 => 52, # Boiling Cave
	288 => 51, # Underground River
	218 => 51, # Absysal Cavern
	215 => 50, # Tempest Realm
}