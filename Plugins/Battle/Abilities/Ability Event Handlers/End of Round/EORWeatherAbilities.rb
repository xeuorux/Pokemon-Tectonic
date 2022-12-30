BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |_ability, weather, battler, battle|
      next unless weather == :Hail
      healingMessage = battle.pbDisplay(_INTL("{1} incorporates hail into its body.", battler.pbThis))
      battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |_ability, _weather, battler, battle|
      next unless battle.rainy?
      healingMessage = battle.pbDisplay(_INTL("{1} soaks up the rain.", battler.pbThis))
      battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true)
  }
)

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |_ability, _weather, battler, battle|
      if battle.sunny?
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1} was hurt by the sunlight!", battler.pbThis))
          battler.applyFractionalDamage(1.0 / 8.0)
          battle.pbHideAbilitySplash(battler)
      end

      if battle.rainy?
          healingMessage = battle.pbDisplay(_INTL("{1} soaks up the rain.", battler.pbThis))
          battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true, customMessage: healingMessage)
      end
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |_ability, _weather, battler, battle|
      next unless battle.sunny?
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!", battler.pbThis))
      battler.applyFractionalDamage(1.0 / 8.0)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:HEATSAVOR,
    proc { |_ability, _weather, battler, battle|
        next unless battle.sunny?
        healingMessage = battle.pbDisplay(_INTL("{1} soaks up the heat.", battler.pbThis))
        battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true, customMessage: healingMessage)
    }
)

BattleHandlers::EORWeatherAbility.add(:FINESUGAR,
    proc { |_ability, _weather, battler, battle|
        if battle.rainy?
            battle.pbShowAbilitySplash(battler)
            battle.pbDisplay(_INTL("{1} was hurt by the rain!", battler.pbThis))
            battler.applyFractionalDamage(1.0 / 8.0)
            battle.pbHideAbilitySplash(battler)
        end
        if battle.sunny?
            healingMessage = battle.pbDisplay(_INTL("{1} caramlizes slightly in the heat.", battler.pbThis))
            battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true, customMessage: healingMessage)
        end
    }
)
