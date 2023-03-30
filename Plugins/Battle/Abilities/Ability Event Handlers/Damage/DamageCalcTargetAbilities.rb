BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.25 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if Effectiveness.super_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER, :SOLIDROCK)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |ability, _user, _target, move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 2 if move.calcType == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEATPROOF,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[FIRE ICE].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:UNAFRAID,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[BUG DARK].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:final_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:GRASSPELT,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:defense_multiplier] *= 2.0 if user.battle.field.terrain == :Grassy
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PRISMARMOR,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if Effectiveness.super_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SHADOWSHIELD,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SHIELDWALL,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.5 if Effectiveness.hyper_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:STOUT,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      w = user.battle.pbWeather
      mults[:final_damage_multiplier] *= 0.80 if w != :None
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SENTRY,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if target.effectActive?(:ChoseStatus)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:REALIST,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[DRAGON FAIRY].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TOUGH,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[FIGHTING ROCK].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TRAPPER,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbIsTrapped?(user.index)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FORTIFIED,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.80 unless target.movedThisRound?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PARANOID,
  proc { |ability, _user, _target, move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 2 if move.calcType == :PSYCHIC
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SANDSHROUD,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SNOWSHROUD,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbWeather == :Hail
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:BROODING,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      dragonCount = 0
      target.battle.eachInTeamFromBattlerIndex(target.index) do |pkmn, _i|
          dragonCount += 1 if pkmn.hasType?(:DRAGON)
      end
      mults[:final_damage_multiplier] /= (1.0 + dragonCount * 0.05)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEROICFINALE,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] /= 2 if target.isLastAlive?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:KEEPER,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.80 if target.battle.field.terrain != :None
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:COLDPROOF,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if type == :ICE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WEATHERSENSES,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
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
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.25 if type == :WATER
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MISTBLANKET,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbWeather == :Moonglow
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:APPREHENSIVE,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.7 if user.battle.partialEclipse?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SUPERSTITIOUS,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[GHOST PSYCHIC].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FEATHERCOAT,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[ICE FLYING].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:UNCONCERED,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:final_damage_multiplier] *= 0.8 if Effectiveness.normal?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:BULLY,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type|
      mults[:base_damage_multiplier] *= 0.7 if target.pbHeight < user.pbHeight
  }
)
