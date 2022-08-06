GameData::TerrainTag.register({
  :id                     => :TallGrass,
  :id_number              => 10,
  :deep_bush              => true,
  :land_wild_encounters   => true,
  :battle_environment     => :TallGrass,
  :must_walk              => true
})

# Sparse Grass
GameData::TerrainTag.register({
  :id                     => :SparseGrass,
  :id_number              => 19,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :Grass
})

# Mud
GameData::TerrainTag.register({
  :id                     => :Mud,
  :id_number              => 17,
  :battle_environment     => :Mud,
  :land_wild_encounters	  => true,
  :must_walk              => true,
  :slows				  => true
})

# Puddle
GameData::TerrainTag.register({
  :id                     => :Puddle,
  :id_number              => 18,
  :battle_environment     => :Puddle,
  :land_wild_encounters	  => true,
})

# Dark Cave
GameData::TerrainTag.register({
  :id                     => :DarkCave,
  :id_number              => 20,
  :battle_environment     => :Cave,
  :land_wild_encounters	  => true,
})

# Flowery Grass
GameData::TerrainTag.register({
  :id                     => :FloweryGrass,
  :id_number              => 21,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :Grass
})

# Flowery Grass 2
GameData::TerrainTag.register({
  :id                     => :FloweryGrass2,
  :id_number              => 22,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :Grass
})

# Tinted grass
GameData::TerrainTag.register({
  :id                     => :TintedGrass,
  :id_number              => 23,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :Grass
})

# Sewer Floor
GameData::TerrainTag.register({
  :id                     => :SewerFloor,
  :id_number              => 24,
  :land_wild_encounters   => true,
  :battle_environment     => :Puddle
})

# Sewer Water
GameData::TerrainTag.register({
  :id                     => :SewerWater,
  :id_number              => 25,
  :land_wild_encounters   => true,
  :battle_environment     => :MovingWater,
  :can_surf				  => true,
})

GameData::TerrainTag.register({
  :id                     => :SewerGrate,
  :id_number              => 27,
  :land_wild_encounters   => true,
  :battle_environment     => :MovingWater
})

# Climbable Rocks
GameData::TerrainTag.register({
  :id                     => :RockClimb,
  :id_number              => 26,
  :must_walk              => true,
  :slows              	  => true,
  :rock_climbable		      => true,
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :FishingContest,
  :type                   => :contest,
  :id_number              => 28,
  :can_surf               => true,
  :battle_environment     => :MovingWater
})

GameData::TerrainTag.register({
  :id                     => :SurfBlock,
  :id_number              => 29,
  :can_surf               => false,
})

GameData::TerrainTag.register({
  :id                     => :SouthConveyor,
  :id_number              => 30,
})

GameData::TerrainTag.register({
  :id                     => :WallReplaceConcave,
  :id_number              => 31,
})

GameData::TerrainTag.register({
  :id                     => :WallReplaceConvex,
  :id_number              => 32,
})

GameData::TerrainTag.register({
  :id                     => :ActiveWater,
  :id_number              => 33,
  :battle_environment     => :Water,
  :can_surf               => true
})