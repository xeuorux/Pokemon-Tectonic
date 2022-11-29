BattleHandlers::DamageCalcUserAbility.add(:AERILATE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.2 if !aiCheck || move.type == :NORMAL
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE)

BattleHandlers::DamageCalcUserAbility.add(:FROSTSONG,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if aiCheck
      mults[:base_damage_multiplier] *= 1.5 if move.soundMove?
    else
      mults[:base_damage_multiplier] *= 1.5 if move.powerBoost
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLADETRAINED,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if aiCheck
      mults[:base_damage_multiplier] *= 1.5 if move.slashMove?
    else
      mults[:base_damage_multiplier] *= 1.5 if move.powerBoost
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if aiCheck
      mults[:base_damage_multiplier] *= 1.3 if target.pbSpeed < user.pbSpeed
    else
      if (target.battle.choices[target.index][0] != :UseMove &&
        target.battle.choices[target.index][0] != :Shift) ||
        target.movedThisRound?
       mults[:base_damage_multiplier] *= 1.3
     end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLAZE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.hp <= user.totalhp / 3 && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] /= 2 if user.hp <= user.totalhp / 2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.effectActive?(:FlashFire) && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.5 if move.pulseMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:NEUROFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.25
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERGROW,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.hp <= user.totalhp / 3 && type == :GRASS
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.2 if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.gender!=2 && target.gender!=2
      if user.gender==target.gender
        mults[:base_damage_multiplier] *= 1.25
      else
        mults[:base_damage_multiplier] *= 0.75
      end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SANDFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.battle.pbWeather == :Sandstorm &&
       [:ROCK, :GROUND, :STEEL].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.3 if move.effectChance > 0
  }
)



BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if target.damageState.critical
      mults[:final_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    unless aiCheck
      mults[:attack_multiplier] *= 2 if target.battle.choices[target.index][0] == :SwitchOut
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWARM,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.hp <= user.totalhp / 3 && type == :BUG
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.index != target.index && move && move.id != :STRUGGLE &&
       baseDmg * mults[:base_damage_multiplier] <= 60
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:final_damage_multiplier] *= 2 if Effectiveness.resistant?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TORRENT,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.hp <= user.totalhp / 3 && type == :WATER
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 2 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSMAW,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :DRAGON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRANSISTOR,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TEMPERATURE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if user.lastMoveUsed != move.id && !user.lastMoveFailed
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXPERTISE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    effectivenessToCheck = nil
    if aiCheck
      effectivenessToCheck = user.battle.battleAI.pbCalcTypeModAI(type,user,target,move)
    else
      effectivenessToCheck = target.damageState.typeMod
    end
    if Effectiveness.super_effective?(effectivenessToCheck)
      mults[:final_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MIDNIGHTSUN,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.battle.pbWeather==:Sun && type == :DARK
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RAINPRISM,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.battle.pbWeather==:Rain && type == :FAIRY
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:STEELWORKER,:PULVERIZE)

BattleHandlers::DamageCalcUserAbility.add(:SUBZERO,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :ICE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PALEOLITHIC,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :ROCK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SCALDINGSMOKE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :POISON
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:PUNKROCK,:LOUD)

BattleHandlers::DamageCalcUserAbility.add(:SWORDSMAN,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.5 if move.slashMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MYSTICFIST,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STORMFRONT,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if user.battle.pbWeather==:Rain && [:ELECTRIC,:FLYING,:WATER].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRATAGEM,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if type == :ROCK
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ARMORPIERCING,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if target.stages[:DEFENSE] > 0 || target.stages[:SPECIAL_DEFENSE] > 0
      mults[:base_damage_multiplier] *= 2.0
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TERRITORIAL,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    if target.battle.field.terrain != :None
      mults[:attack_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BROODING,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
	dragonCount = 0
	user.battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
		dragonCount += 1 if pkmn.hasType?(:DRAGON)
	end
	mults[:attack_multiplier] *= (1.0 + dragonCount * 0.05) 
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOULREAD,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
	if !target.lastMoveUsedType.nil?
		if !target.pbTypes(true).include?(target.lastMoveUsedType)
			mults[:attack_multiplier] *= 2.0
		end
	end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SURFSUP,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PHASESHIFT,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.5 if !user.lastMoveUsedType.nil? && type != user.lastMoveUsedType
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DOUBLECHECK,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.5 if target.tookDamage
  }
)

BattleHandlers::DamageCalcUserAbility.add(:ERUDITE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :PSYCHIC
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSLAYER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 2.0 if target.hasType?(:DRAGON)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PECKINGORDER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.5 if type == :FLYING
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TUNNELMAKER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if type == :GROUND
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GALEFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5 if move.windMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:EXTREMEHEAT,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 1.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SPACEINTERLOPER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 0.5
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIMEINTERLOPER,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:attack_multiplier] *= 3.0/4.0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHIFTINGFIST,
  proc { |ability,user,target,move,mults,baseDmg,type,aiCheck|
    mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)