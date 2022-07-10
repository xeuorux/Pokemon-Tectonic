# Pokemon are assumed to be at this level for calculating EHP
EHP_LEVEL = 50

MAPS_AVAILABLE_BY_CAP = {
	15 => [136,138,30,	# Casaba Villa, Scenic Trail, Windy Way
			51,38,26,	# Foreclosed Tunnel, Beach Route, Seaside Grotto
			35,27		# Impromptu Lab, Casaba Mart
	], 
	30 => [60,56,66,123,		# Shipping Lane, Nemeth, Nemeth Attic, Nemeth Academy
			142,140,141, 		# Starters Store Maps
			3,25,55,6,81,	 	# Savannah Route, Mining Camp, Flower Fields, LuxTech Campus, Cave Path
			301,37,7,8,53, 		# County Park, Svait, Wet Walkways, The Tangle
			117,36,10,12, 		# Ice Cave, Abandoned Mine, Jungle Temple, Gigalith's Guts
			13,11,122,120, 		# Cave Path, River Route, Sewer, Deep Layer
			121,130,129,59, 	# Mountain Climb, Canal Desert, Barren Crater, Mainland Dock
			96,98,126, 			# Luxtech Cold Storage, LuxTech Cold Storage Basement, Sun Cave
			4,20,86,       		# Scientist's House, Lengthy Glade, Zigzagoon Nest, LuxTech Cold Storage Basement
			78,87,103,92,    	# LuxTech Main, LuxTech Rec Center, Ghost Town Mart, Ice Rink Lodge
			32,71,74,			# Nemeth Apartments, Nemeth Apartments Room 103, Nemeth Apartments Room 203
			91,65,85,			# Reading Ribombee Cafe, Nemeth Mart, Worried Man's House
			213,214,219,		# Velenz Menagerie, Gigalith's Guts Town, Regirock Cave
			217,49,243,			# Candy Town, Tourist's House, Chasm Base Mess Hall
			251,305				# Samorn's House, Mainland Dock Warehouse
			],
	50 => [155,29,47,		# Prizca West, Full Blast Records F2, Grand Hotal
			34,183,180,		# Battle Fair, Circuit Cave, Priza West Mart
			185,186, 239,		# Eleig Stretch, Farm Placeholder, Ocean Fishing Zone
			187,189,202,	# Prizca East, Catacombs, Mountaineer's House
			193,196,203,	# Lapras Shore, Boiling Cave, Skeevee Eevee Pub
			211,212,216,	# Shield, Ocean Fishing, Mountain Lake
			218,230,232,	# Abyssal Chamber, Galarian Fan's House, Biologist's House
			234,220,228,         # Ranger Recruitment, Prizca Sewers East, Hidden Laboratory
			223,250				# Prizca Sewers West, Chasm Base Lab
			],
	70 => [215			# Sky
			]
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