BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability,weather,battler,battle|
    next unless weather == :Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability,weather,battler,battle|
    next unless battle.rainy?
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability,weather,battler,battle|
    if battle.sunny?
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
      battler.applyFractionalDamage(1.0/8.0)
      battle.pbHideAbilitySplash(battler)
    end

    if battle.rainy?
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      healAmount = battler.totalhp / 8.0
      healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
      healingMessage = battle.pbDisplay(_INTL("{1} soaks up the rain.",battler.pbThis))
      battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |ability,weather,battler,battle|
    next unless battle.sunny?
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
    battler.applyFractionalDamage(1.0/8.0)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:HEATSAVOR,
    proc { |ability,weather,battler,battle|
      next unless battle.sunny?
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      healAmount = battler.totalhp / 16.0
      healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
      healingMessage = battle.pbDisplay(_INTL("{1} soaks up the heat.",battler.pbThis))
      battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
      battle.pbHideAbilitySplash(battler)
    }
)
  
BattleHandlers::EORWeatherAbility.add(:FINESUGAR,
    proc { |ability,weather,battler,battle|
      if battle.rainy?
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} was hurt by the rain!",battler.pbThis))
        battler.applyFractionalDamage(1.0/8.0)
        battle.pbHideAbilitySplash(battler)
      end
      if battle.sunny?
        next if !battler.canHeal?
        battle.pbShowAbilitySplash(battler)
        healAmount = battler.totalhp / 8.0
        healAmount /= BOSS_HP_BASED_EFFECT_RESISTANCE.to_f if battler.boss?
        healingMessage = battle.pbDisplay(_INTL("{1} caramlizes slightly in the heat.",battler.pbThis))
        battler.pbRecoverHP(healAmount,true,true,true,healingMessage)
        battle.pbHideAbilitySplash(battler)
      end
    }
)