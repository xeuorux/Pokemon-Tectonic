BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |ability,battler,w|
    next w*2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |ability,battler,w|
    next [w/2,1].max
  }
)

BattleHandlers::WeightCalcAbility.add(:ROBUST,
    proc { |ability,battler,weight|
      next weight * 2
    }
)