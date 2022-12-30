BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |_ability, _battler, w|
      next w * 2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |_ability, _battler, w|
      next [w / 2, 1].max
  }
)

BattleHandlers::WeightCalcAbility.add(:ROBUST,
    proc { |_ability, _battler, weight|
        next weight * 2
    }
)
