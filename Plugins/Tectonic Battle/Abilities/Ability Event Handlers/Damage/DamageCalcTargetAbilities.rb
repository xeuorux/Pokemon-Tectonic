BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |ability, user, target, move, mults, _baseDmg, type, aiChecking|
      if Effectiveness.super_effective?(typeModToCheck(user.battle, type, user, target, move, aiChecking))
        mults[:final_damage_multiplier] *= 0.75
      end
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER, :SOLIDROCK, :PRISMARMOR)

BattleHandlers::DamageCalcTargetAbility.add(:SHIELDWALL,
  proc { |ability, user, target, move, mults, _baseDmg, type, aiChecking|
    if Effectiveness.hyper_effective?(typeModToCheck(user.battle, type, user, target, move, aiChecking))
      mults[:final_damage_multiplier] *= 0.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:DULL,
  proc { |ability, user, target, move, mults, _baseDmg, type, aiChecking|
    if Effectiveness.normal?(typeModToCheck(user.battle, type, user, target, move, aiChecking))
      mults[:final_damage_multiplier] *= 0.8
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WELLSUITED,
  proc { |ability, user, target, move, mults, _baseDmg, type, aiChecking|
    if Effectiveness.not_very_effective?(typeModToCheck(user.battle, type, user, target, move, aiChecking))
      mults[:final_damage_multiplier] *= 0.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:base_damage_multiplier] *= 1.25 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FINESUGAR,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:base_damage_multiplier] *= 1.25 if type == :WATER
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |ability, _user, _target, move, mults, _baseDmg, type, aiChecking|
      mults[:final_damage_multiplier] *= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PARANOID,
  proc { |ability, _user, _target, move, mults, _baseDmg, type, aiChecking|
      mults[:final_damage_multiplier] *= 2 if type == :PSYCHIC
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:MULTISCALE,:ALOOF,:SHADOWSHIELD)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[FIRE ICE].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:UNAFRAID,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:base_damage_multiplier] /= 2 if %i[BUG DARK].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SUPERSTITIOUS,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:base_damage_multiplier] /= 2 if %i[GHOST PSYCHIC].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FEATHERCOAT,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:base_damage_multiplier] /= 2 if %i[ICE FLYING].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:REALIST,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:base_damage_multiplier] /= 2 if %i[DRAGON FAIRY].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TOUGH,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] /= 2 if %i[FIGHTING ROCK].include?(type)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |ability, _user, _target, _move, mults, _baseDmg, type, aiChecking|
      mults[:final_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:STEAMPOWER,
  proc { |ability, user, target, _move, mults, _baseDmg, type, aiChecking|
      mults[:final_damage_multiplier] /= 2.0 if type == :WATER
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:ACCLIMATIZE,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.80 if user.battle.pbWeather != :None
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SENTRY,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.75 if target.effectActive?(:ChoseStatus)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TRAPPER,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.pbIsTrapped?(user.index)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FORTIFIED,
  proc { |ability, user, target, _move, mults, _baseDmg, _type, aiChecking|
      if aiChecking
        mults[:final_damage_multiplier] *= 0.7 unless user.pbSpeed(true) > target.pbSpeed(true)
      else
        mults[:final_damage_multiplier] *= 0.7 unless target.movedThisRound?
      end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SANDSHROUD,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.sandy?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:DESERTSPIRIT,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.8 if user.battle.sandy?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:SNOWSHROUD,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.icy?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MISTBLANKET,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.75 if user.battle.moonGlowing?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:APPREHENSIVE,
  proc { |ability, user, _target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.7 if user.battle.partialEclipse?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:BULLY,
  proc { |ability, user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:base_damage_multiplier] *= 0.7 if target.pbHeight < user.pbHeight
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:LIMINAL,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.5 if target.effectActive?(:SwitchedIn)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PLASMABALL,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:INTROVERT,
  proc { |ability, _user, target, _move, mults, _baseDmg, type, aiChecking|
      mults[:final_damage_multiplier] *= 0.7 unless target.usedDamagingMove
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:QUARRELSOME,
  proc { |ability, user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 2 if target.firstTurn?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:RUSTYANCHOR,
  proc { |ability, user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 1.15
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:APRICORNARMOR,
  proc { |ability, user, _target, move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] /= 2 if user.pbHasAnyStatus?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:RUGGEDSCALES,
  proc { |ability, _user, target, move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.7 if move.randomEffect?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:DARTER,
  proc { |ability, _user, target, _move, mults, _baseDmg, _type, aiChecking|
      mults[:final_damage_multiplier] *= 0.7 if target.pbOwnSide.effectActive?(:Tailwind)
  }
)