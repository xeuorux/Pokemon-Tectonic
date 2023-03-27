BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability, weather, battler, battle|
      next unless weather == :Hail
      healingMessage = _INTL("{1} incorporates hail into its body.", battler.pbThis)
      battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability, _weather, battler, battle|
      next unless battle.rainy?
      healingMessage = _INTL("{1} soaks up the rain.", battler.pbThis)
      battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
  }
)

BattleHandlers::EORWeatherAbility.add(:ROCKBODY,
    proc { |ability, weather, battler, battle|
        next unless weather == :Sandstorm
        healingMessage = _INTL("{1} incorporates sand into its body.", battler.pbThis)
        battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
    }
  )

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability, _weather, battler, battle|
      if battle.sunny?
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1} was hurt by the sunlight!", battler.pbThis))
          battler.applyFractionalDamage(1.0 / 8.0)
          battle.pbHideAbilitySplash(battler)
      end

      if battle.rainy?
          healingMessage = _INTL("{1} soaks up the rain.", battler.pbThis)
          battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
      end
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |ability, _weather, battler, battle|
      next unless battle.sunny?
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!", battler.pbThis))
      battler.applyFractionalDamage(1.0 / 8.0)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:NIGHTSTALKER,
    proc { |ability, _weather, battler, battle|
        next unless battle.pbWeather == :Moonglow
        battle.pbShowAbilitySplash(battler, ability)
        battle.pbDisplay(_INTL("{1} was hurt by the moonlight!", battler.pbThis))
        battler.applyFractionalDamage(1.0 / 8.0)
        battle.pbHideAbilitySplash(battler)
    }
  )

BattleHandlers::EORWeatherAbility.add(:HEATSAVOR,
    proc { |ability, _weather, battler, battle|
        next unless battle.sunny?
        healingMessage = _INTL("{1} soaks up the heat.", battler.pbThis)
        battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
    }
)

BattleHandlers::EORWeatherAbility.add(:FINESUGAR,
    proc { |ability, _weather, battler, battle|
        if battle.rainy?
            battle.pbShowAbilitySplash(battler, ability)
            battle.pbDisplay(_INTL("{1} was hurt by the rain!", battler.pbThis))
            battler.applyFractionalDamage(1.0 / 8.0)
            battle.pbHideAbilitySplash(battler)
        end
        if battle.sunny?
            healingMessage = _INTL("{1} caramlizes slightly in the heat.", battler.pbThis)
            battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
        end
    }
)

BattleHandlers::EORWeatherAbility.add(:EXTREMOPHILE,
    proc { |ability, _weather, battler, battle|
        next unless battle.pbWeather == :Eclipse
        healingMessage = _INTL("{1} revels in the unusual conditions.", battler.pbThis)
        battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
    }
)

BattleHandlers::EORWeatherAbility.add(:NESTING,
    proc { |ability, _weather, battler, battle|
        next if battle.pbWeather == :None
        healingMessage = _INTL("{1} rests in safety.", battler.pbThis)
        battler.applyFractionalHealing(1.0 / 12.0, ability: ability, customMessage: healingMessage)
    }
)

BattleHandlers::EORWeatherAbility.add(:MOONBASKING,
    proc { |ability, _weather, battler, battle|
        next unless battle.pbWeather == :Moonglow
        healingMessage = _INTL("{1} absorbs the moonlight.", battler.pbThis)
        battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
    }
)

BattleHandlers::EORWeatherAbility.add(:NIGHTLINE,
    proc { |ability, _weather, battler, battle|
        next unless battle.pbWeather == :Moonglow
        healingMessage = _INTL("{1} absorbs the moonlight.", battler.pbThis)
        healingAmount = battler.applyFractionalHealing(1.0 / 12.0, ability: ability, customMessage: healingMessage)

        if healingAmount > 0
            potentialHeals = []
            battle.pbParty(battler.index).each_with_index do |pkmn,_index|
                next if pkmn.fainted?
                next if pkmn.hp == pkmn.totalhp
                potentialHeals.push(pkmn)
            end
            unless potentialHeals.empty?
                healTarget = potentialHeals.sample
                battle.pbDisplay(_INTL("{1} sends out a signal, healing #{healTarget.name}!"))
                newHP = pkmn.hp + healingAmount
                newHP = pkmn.totalhp if newHP > pkmn.totalhp
                pkmn.hp = newHP
            end
        end
    }
)