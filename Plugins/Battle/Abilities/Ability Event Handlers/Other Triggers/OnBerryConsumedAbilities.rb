BattleHandlers::OnBerryConsumedAbility.add(:CHEEKPOUCH,
  proc { |ability, user, _berry, _own_item, _battle|
      user.applyFractionalHealing(1.0 / 3.0, ability: ability)
  }
)

BattleHandlers::OnBerryConsumedAbility.add(:ROAST,
    proc { |ability, user, _berry, _own_item, _battle|
        user.pbRaiseMultipleStatSteps(ATTACKING_STATS_2, user, ability: ability)
    }
)
