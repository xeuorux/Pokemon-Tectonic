BattleHandlers::OnBerryConsumedAbility.add(:CHEEKPOUCH,
  proc { |ability,user,berry,own_item,battle|
    user.applyFractionalHealing(1.0/3.0, showAbilitySplash: true)
  }
)

BattleHandlers::OnBerryConsumedAbility.add(:ROAST,
    proc { |ability,user,berry,own_item,battle|
      user.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],user,showAbilitySplash: true)
    }
)