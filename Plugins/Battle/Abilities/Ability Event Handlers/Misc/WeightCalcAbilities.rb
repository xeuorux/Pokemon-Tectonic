BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |ability, _battler, w|
      next w * 2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |ability, _battler, w|
      next [w / 2, 1].max
  }
)

BattleHandlers::WeightCalcAbility.add(:ROBUST,
    proc { |ability, _battler, weight|
        next weight * 2
    }
)
