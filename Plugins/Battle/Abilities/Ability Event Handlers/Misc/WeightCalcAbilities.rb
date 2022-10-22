BattleHandlers::WeightCalcAbility.add(:ROBUST,
    proc { |ability,battler,weight|
      next weight * 2
    }
)