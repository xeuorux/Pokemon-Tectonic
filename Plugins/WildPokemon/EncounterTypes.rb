# Tall Grass
GameData::EncounterType.register({
  :id             => :LandTall,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :LandSparse,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :Mud,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

# Active Water
GameData::EncounterType.register({
  :id             => :ActiveWater,
  :type           => :water,
  :trigger_chance => 15,
  :old_slots      => [60, 30, 5, 4, 1]
})

GameData::EncounterType.register({
  :id             => :Puddle,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :DarkCave,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :FloweryGrass,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :FloweryGrass2,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :LandTinted,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :SewerFloor,
  :type           => :land,
  :trigger_chance => 21,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

GameData::EncounterType.register({
  :id             => :SewerWater,
  :type           => :land,
  :trigger_chance => 1,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

# A special encounter type only used to mark other items
GameData::EncounterType.register({
  :id             => :Special,
  :type           => :none,
  :trigger_chance => 0,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

# Fishing Contest Water
GameData::EncounterType.register({
  :id             => :FishingContest,
  :type           => :water,
  :trigger_chance => 30,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})

# Dangerous Clouds
GameData::EncounterType.register({
  :id             => :Cloud,
  :type           => :land,
  :trigger_chance => 1,
  :old_slots      => [20, 20, 10, 10, 10, 10, 5, 5, 4, 4, 1, 1]
})