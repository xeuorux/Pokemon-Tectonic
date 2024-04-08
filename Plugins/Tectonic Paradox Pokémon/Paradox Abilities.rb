BattleHandlers::AbilityOnSwitchIn.add(:ROCKETHANDS,
  proc { |ability, battler, battle, aiCheck|
      next 0 if aiCheck
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is preparing its rocket hands!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::SpeedCalcAbility.add(:ROCKETHANDS,
  proc { |ability, battler, mult|
      next mult * 2 if battler.effectActive?(:RocketHands)
  }
)

BattleHandlers::TotalEclipseAbility.add(:ANCIENTDANCE,
  proc { |ability, battler, battle, aiCheck|
      next battle.forceUseMove(battler, :DRAGONDANCE, -1, ability: ability, aiCheck: aiCheck)
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:STRONGMAGNETISM,
  proc { |ability, battler, battle, aiCheck|
      next battle.forceUseMove(battler, :MAGNETRISE, -1, ability: ability, aiCheck: aiCheck)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:THUNDERSTORM,
  proc { |ability, user, _targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless battle.sandy?
      next if user.effectActive?(:Thunderstorm)
      next if user.effectActive?(:Charge)
      battle.pbShowAbilitySplash(user, ability)
      user.applyEffect(:Charge)
      user.applyEffect(:Thunderstorm)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::TypeCalcAbility.add(:BALLMIMIC,
    proc { |ability, battler, types|
        types.push(:POISON)
        next types
    }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPANEL,
    proc { |ability, _weather, battler, battle|
        next unless battle.sunny?
        healingMessage = _INTL("{1} absorbs the sunlight.", battler.pbThis)
        battler.applyFractionalHealing(WEATHER_ABILITY_HEALING_FRACTION, ability: ability, customMessage: healingMessage)
    }
)

BattleHandlers::DamageCalcTargetAbility.add(:SOLARPANEL,
  proc { |ability, user, target, _move, mults, _baseDmg, type, aiCheck|
    if user.battle.sunny?
      mults[:final_damage_multiplier] *= 0.65
      target.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:CRIMSONSKIES,
  proc { |ability, user, target, move, mults, _baseDmg, type, aiCheck|
    if user.battle.moonGlowing? && type == :DRAGON
      mults[:base_damage_multiplier] *= 1.5
      user.aiLearnsAbility(ability) unless aiCheck
    end
  }
)

BattleHandlers::SpecialAttackCalcUserAbility.add(:BANSHEESMELISMA,
  proc { |ability, _user, _battle, spAtkMult|
      spAtkMult *= 1.5
      next spAtkMult
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ORICHALCHUMPRESENCE,
  proc { |ability, battler, battle, aiCheck|
      pbBattleWeatherAbility(ability, :DarkenedSun, battler, battle, true, true, aiCheck)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PROTOINSTINCT,
  proc { |ability, battler, battle, aiCheck|
      if battle.eclipsed?
      if aiCheck
          next getMultiStatUpEffectScore([:ATTACK, 1], battler, battler)
      else
          battler.tryRaiseStat(:ATTACK, battler, ability: ability)
      if battle.sunny?
      next entryDebuffAbility(ability, battler, battle, ATTACKING_STATS_2, aiCheck: aiCheck)
      end
    end 
      elsif battle.sunny?
      next entryDebuffAbility(ability, battler, battle, ATTACKING_STATS_2, aiCheck: aiCheck) 
      end   
    }
)

BattleHandlers::AbilityOnSwitchIn.add(:HADRONSYSTEM,
  proc { |ability, battler, battle, aiCheck|
      pbBattleWeatherAbility(ability, :BrilliantRain, battler, battle, true, true, aiCheck)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:QUARKPROTOCOL,
  proc { |ability, battler, battle, aiCheck|
      if battle.rainy?
      if aiCheck
          next getMultiStatUpEffectScore([:ATTACK, 1], battler, battler)
      else
          battler.tryRaiseStat(:ATTACK, battler, ability: ability)
      if battle.moonGlowing?
      next entryDebuffAbility(ability, battler, battle, ATTACKING_STATS_2, aiCheck: aiCheck)
      end
    end 
      elsif battle.moonGlowing?
      next entryDebuffAbility(ability, battler, battle, ATTACKING_STATS_2, aiCheck: aiCheck) 
      end   
    }
)