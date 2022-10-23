BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability,weather,battler,battle|
    next unless weather == :Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability,weather,battler,battle|
    next unless [:Rain, :HeavyRain].include?(weather)
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability,weather,battler,battle|
    case weather
    when :Sun, :HarshSun
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
      battler.applyFractionalDamage(1.0/8.0)
      battle.pbHideAbilitySplash(battler)
    when :Rain, :HeavyRain
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
    next unless [:Sun, :HarshSun].include?(weather)
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
    battler.applyFractionalDamage(1.0/8.0)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:HEATSAVOR,
    proc { |ability,weather,battler,battle|
      next if ![:Sun, :HarshSun].include?(weather)
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
      case weather
      when :Rain, :HeavyRain
        battle.pbShowAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1} was hurt by the rain!",battler.pbThis))
        battler.applyFractionalDamage(1.0/8.0)
        battle.pbHideAbilitySplash(battler)
      when :Sun, :HarshSun
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