BattleHandlers::ItemOnIntimidated.add(:ADRENALINEORB,
    proc { |item,battler,battle|
      next false if !battler.pbCanRaiseStatStage?(:SPEED,battler)
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem",battler)
      next battler.pbRaiseStatStageByCause(:SPEED,1,battler,itemName)
    }
  )