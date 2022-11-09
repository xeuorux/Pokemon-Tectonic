GameData::Status.register({
  :id        => :NONE,
  :id_number => 0,
  :name      => _INTL("None")
})

GameData::Status.register({
  :id        => :SLEEP,
  :id_number => 1,
  :name      => _INTL("Sleep"),
  :animation => "Sleep"
})

GameData::Status.register({
  :id        => :POISON,
  :id_number => 2,
  :name      => _INTL("Poison"),
  :animation => "Poison"
})

GameData::Status.register({
  :id        => :BURN,
  :id_number => 3,
  :name      => _INTL("Burn"),
  :animation => "Burn"
})

GameData::Status.register({
  :id        => :NUMB,
  :id_number => 4,
  :name      => _INTL("Numb"),
  :animation => "Paralysis"
})

GameData::Status.register({
  :id        => :FROSTBITE,
  :id_number => 5,
  :name      => _INTL("Frostbitten"),
  :animation => "Frozen"
})

GameData::Status.register({
  :id        => :DIZZY,
  :id_number => 6,
  :name      => _INTL("Dizzy"),
  :animation => "Confusion"
})

GameData::Status.register({
  :id        => :LEECHED,
  :id_number => 7,
  :name      => _INTL("Leeched"),
  :animation => "LeechSeed"
})