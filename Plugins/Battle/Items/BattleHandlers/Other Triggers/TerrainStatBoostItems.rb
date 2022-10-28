BattleHandlers::TerrainStatBoostItem.add(:ELECTRICSEED,
    proc { |item,battler,battle|
      next false if battle.field.terrain != :Electric
      next false if !battler.pbCanRaiseStatStage?(:DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem",battler)
      next battler.pbRaiseStatStageByCause(:DEFENSE,1,battler,itemName)
    }
  )
  
  BattleHandlers::TerrainStatBoostItem.add(:GRASSYSEED,
    proc { |item,battler,battle|
      next false if battle.field.terrain != :Grassy
      next false if !battler.pbCanRaiseStatStage?(:DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem",battler)
      next battler.pbRaiseStatStageByCause(:DEFENSE,1,battler,itemName)
    }
  )
  
  BattleHandlers::TerrainStatBoostItem.add(:MISTYSEED,
    proc { |item,battler,battle|
      next false if battle.field.terrain != :Misty
      next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem",battler)
      next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
    }
  )
  
  BattleHandlers::TerrainStatBoostItem.add(:PSYCHICSEED,
    proc { |item,battler,battle|
      next false if battle.field.terrain != :Psychic
      next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem",battler)
      next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
    }
  )