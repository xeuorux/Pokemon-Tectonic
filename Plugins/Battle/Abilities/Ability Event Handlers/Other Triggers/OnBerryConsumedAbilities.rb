BattleHandlers::OnBerryConsumedAbility.add(:CHEEKPOUCH,
  proc { |ability,user,berry,own_item,battle|
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user)
    recovery = user.totalhp / 3.0
    recovery /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if user.boss?
    user.pbRecoverHP(recovery)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::OnBerryConsumedAbility.add(:ROAST,
    proc { |ability,user,berry,own_item,battle|
      next if !user.pbCanRaiseStatStage?(:ATTACK,user) && !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
      battle.pbShowAbilitySplash(user)
      user.pbRaiseStatStage(:ATTACK,1,user) if user.pbCanRaiseStatStage?(:ATTACK,user)
      user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
      battle.pbHideAbilitySplash(user)
    }
)