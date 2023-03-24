BattleHandlers::DamageCalcUserAbility.add(:AERILATE,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, aiCheck|
      mults[:base_damage_multiplier] *= 1.2 if !aiCheck || move.type == :NORMAL
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE, :PIXILATE, :REFRIGERATE, :GALVANIZE)

BattleHandlers::DamageCalcUserAbility.add(:FROSTSONG,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, aiCheck|
      if aiCheck
          mults[:base_damage_multiplier] *= 1.5 if move.soundMove?
      elsif move.powerBoost
          mults[:base_damage_multiplier] *= 1.5
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLADETRAINED,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, aiCheck|
      if aiCheck
          mults[:base_damage_multiplier] *= 1.5 if move.slashMove?
      elsif move.powerBoost
          mults[:base_damage_multiplier] *= 1.5
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:NORMALIZE,
  proc { |_ability, _user, _target, move, mults, _baseDmg, type, aiCheck|
      if aiCheck
          mults[:base_damage_multiplier] *= 1.4 if type != :NORMAL
      elsif move.powerBoost
          mults[:base_damage_multiplier] *= 1.4
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |_ability, user, target, _move, mults, _baseDmg, _type, aiCheck|
      if aiCheck
          mults[:base_damage_multiplier] *= 1.3 if target.pbSpeed < user.pbSpeed
      elsif (target.battle.choices[target.index][0] != :UseMove &&
            target.battle.choices[target.index][0] != :Shift) ||
            target.movedThisRound?
          mults[:base_damage_multiplier] *= 1.3
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLAZE,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if user.hp <= user.totalhp / 3 && type == :FIRE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] /= 2 if user.belowHalfHealth?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLASHFIRE,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if user.effectActive?(:FlashFire) && type == :FIRE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if move.pulseMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:NEUROFORCE,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:final_damage_multiplier] *= 1.25 if Effectiveness.super_effective?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERGROW,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if user.hp <= user.totalhp / 3 && type == :GRASS
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |_ability, user, target, _move, mults, _baseDmg, _type, _aiCheck|
      if user.gender != 2 && target.gender != 2
          if user.gender == target.gender
              mults[:base_damage_multiplier] *= 1.25
          else
              mults[:base_damage_multiplier] *= 0.75
          end
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.effectChance > 0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:final_damage_multiplier] *= 1.5 if target.damageState.critical
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, aiCheck|
      mults[:attack_multiplier] *= 2 if !aiCheck && (target.battle.choices[target.index][0] == :SwitchOut)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELYSHELL,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWARM,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if user.hp <= user.totalhp / 3 && type == :BUG
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |_ability, user, target, move, mults, baseDmg, _type, _aiCheck|
      if user.index != target.index && move && move.id != :STRUGGLE &&
         baseDmg * mults[:base_damage_multiplier] <= 60
          mults[:base_damage_multiplier] *= 1.5
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:final_damage_multiplier] *= 2 if Effectiveness.resistant?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TORRENT,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if user.hp <= user.totalhp / 3 && type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 2 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSMAW,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :DRAGON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRANSISTOR,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TEMPERATURE,
  proc { |_ability, user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if user.lastMoveUsed != move.id && !user.lastMoveFailed
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXPERTISE,
  proc { |_ability, _user, target, move, mults, _baseDmg, type, aiCheck|
      if Effectiveness.super_effective?(target.typeMod(type, target, move, aiCheck))
          mults[:final_damage_multiplier] *= 1.3
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MIDNIGHTSUN,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if user.battle.pbWeather == :Sun && type == :DARK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SANDDEMON,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if user.battle.pbWeather == :Sandstorm && type == :DARK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RAINPRISM,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if user.battle.pbWeather == :Rain && type == :FAIRY
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:STEELWORKER, :PULVERIZE)

BattleHandlers::DamageCalcUserAbility.add(:SUBZERO,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :ICE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PALEOLITHIC,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :ROCK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SCALDINGSMOKE,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :POISON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LOUD,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.soundMove?
  }
)
BattleHandlers::DamageCalcUserAbility.add(:SWORDSMAN,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if move.slashMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RAZORSEDGE,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.slashMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MYSTICFIST,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STORMFRONT,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      if user.battle.pbWeather == :Rain && %i[ELECTRIC FLYING WATER].include?(type)
          mults[:base_damage_multiplier] *= 1.3
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRATAGEM,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if type == :ROCK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ARMORPIERCING,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 2.0 if target.stages[:DEFENSE] > 0 || target.stages[:SPECIAL_DEFENSE] > 0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TERRITORIAL,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 1.2 if target.battle.pbWeather != :None
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BROODING,
  proc { |_ability, user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      dragonCount = 0
      user.battle.eachInTeamFromBattlerIndex(user.index) do |pkmn, _i|
          dragonCount += 1 if pkmn.hasType?(:DRAGON)
      end
      mults[:attack_multiplier] *= (1.0 + dragonCount * 0.05)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOULREAD,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      if !target.lastMoveUsedType.nil? && !target.pbTypes(true).include?(target.lastMoveUsedType)
          mults[:attack_multiplier] *= 2.0
      end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SURFSUP,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PHASESHIFT,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if !user.lastMoveUsedType.nil? && type != user.lastMoveUsedType
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DOUBLECHECK,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if target.tookDamage
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ERUDITE,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :PSYCHIC
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSLAYER,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 2.0 if target.hasType?(:DRAGON)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PECKINGORDER,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if type == :FLYING
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TUNNELMAKER,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if type == :GROUND
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GALEFORCE,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 1.5 if move.windMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WINDY,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 1.3 if move.windMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SPACEINTERLOPER,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 0.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIMEINTERLOPER,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:attack_multiplier] *= 3.0 / 4.0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHIFTINGFIST,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELYSPIRIT,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GRASSYSPIRIT,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.5 if type == :GRASS
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOXICATTITUDE,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.5 if type == :POISON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:UNCANNYCOLD,
  proc { |_ability, _user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.5 if type == :ICE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MARINEMENACE,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type|
      mults[:base_damage_multiplier] *= 1.5 if move.function == "0CB"
  }
)

BattleHandlers::DamageCalcUserAbility.add(:LINEBACKER,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 2.0 if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WORLDQUAKE,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if user.battle.pbWeather == :Eclipse && type == :GROUND
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIDALFORCE,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if user.battle.pbWeather == :Moonglow && type == :WATER
  }
)
BattleHandlers::DamageCalcUserAbility.add(:RATTLEEM,
  proc { |_ability, _user, target, _move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.5 if target.effectActive?(:FlinchImmunity)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TAIGATRECKER,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.5 if user.battle.pbWeather == :Hail && type == :GRASS
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HOOLIGAN,
  proc { |_ability, _user, _target, move, mults, _baseDmg, _type, _aiCheck|
      mults[:base_damage_multiplier] *= 1.3 if move.recoilMove? || move.soundMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:AURORAPRISM,
  proc { |_ability, user, _target, _move, mults, _baseDmg, type|
      mults[:base_damage_multiplier] *= 1.5 unless user.pbHasType?(type)
  }
)