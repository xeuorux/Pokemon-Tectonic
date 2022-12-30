BattleHandlers::TerrainStatBoostItem.add(:ELECTRICSEED,
    proc { |item, battler, battle|
        next false if battle.field.terrain != :Electric
        next battler.tryRaiseStat(:DEFENSE, battler, item: item)
    }
)

BattleHandlers::TerrainStatBoostItem.add(:GRASSYSEED,
  proc { |item, battler, battle|
      next false if battle.field.terrain != :Grassy
      next battler.tryRaiseStat(:DEFENSE, battler, item: item)
  }
)

BattleHandlers::TerrainStatBoostItem.add(:FairySEED,
  proc { |item, battler, battle|
      next false if battle.field.terrain != :Fairy
      next battler.tryRaiseStat(:SPECIAL_DEFENSE, battler, item: item)
  }
)

BattleHandlers::TerrainStatBoostItem.add(:PSYCHICSEED,
  proc { |item, battler, battle|
      next false if battle.field.terrain != :Psychic
      next battler.tryRaiseStat(:SPECIAL_DEFENSE, battler, item: item)
  }
)
