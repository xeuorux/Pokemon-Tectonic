BattleHandlers::OnBerryConsumedAbility.add(:CHEEKPOUCH,
  proc { |_ability, user, _berry, _own_item, _battle|
      user.applyFractionalHealing(1.0 / 3.0, showAbilitySplash: true)
  }
)

BattleHandlers::OnBerryConsumedAbility.add(:ROAST,
    proc { |_ability, user, _berry, _own_item, _battle|
        user.pbRaiseMultipleStatStages([:ATTACK, 1, :SPECIAL_ATTACK, 1], user, showAbilitySplash: true)
    }
)
