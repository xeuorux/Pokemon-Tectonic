BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.25 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if Effectiveness.super_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER, :SOLIDROCK)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 2 if move.calcType == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEATPROOF,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[FIRE ICE].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:final_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:GRASSPELT,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:defense_multiplier] *= 2.0 if user.battle.field.terrain == :Grassy
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PRISMARMOR,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if Effectiveness.super_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SHADOWSHIELD,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SHIELDWALL,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.5 if Effectiveness.hyper_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:STOUT,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      w = user.battle.pbWeather
      mults[:final_damage_multiplier] *= 0.80 if w != :None
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SENTRY,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if target.effectActive?(:Sentry)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:REALIST,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[DRAGON FAIRY].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TOUGH,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[FIGHTING ROCK].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TRAPPER,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbIsTrapped?(user.index)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FORTIFIED,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.80 unless target.movedThisRound?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PARANOID,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 2 if move.calcType == :PSYCHIC
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SANDSHROUD,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SNOWSHROUD,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbWeather == :Hail
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:BROODING,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      dragonCount = 0
      target.battle.eachInTeamFromBattlerIndex(target.index) do |pkmn, _i|
          dragonCount += 1 if pkmn.hasType?(:DRAGON)
      end
      mults[:final_damage_multiplier] /= (1.0 + dragonCount * 0.05)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEROICFINALE,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] /= 2 if target.isLastAlive?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:KEEPER,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.80 if target.battle.field.terrain != :None
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:COLDPROOF,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if type == :ICE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WEATHERSENSES,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      if user.battle.field.weather == :None
          next
      else
          weatherDuration = user.battle.field.weatherDuration
          damageReduction = 0.07 * weatherDuration
          damageMult = [[1.0 - damageReduction, 1].min, 0].max
          mults[:final_damage_multiplier] *= damageMult
      end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FINESUGAR,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.25 if type == :WATER
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MISTBLANKET,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.field.terrain == :Fairy
  }
)
