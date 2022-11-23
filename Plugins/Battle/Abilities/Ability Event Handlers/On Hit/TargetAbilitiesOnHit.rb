BattleHandlers::TargetAbilityOnHit.add(:ANGERPOINT,
  proc { |ability,user,target,move,battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(:ATTACK,target)
    battle.pbShowAbilitySplash(target)
    target.pbMaximizeStatStage(:ATTACK,target)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    user.tryLowerStat(:SPEED,target,showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY,:TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
  proc { |ability,user,target,move,battle|
    # NOTE: This intentionally doesn't show the ability splash.
    next if !target.illusion?
    target.disableEffect(:Illusion)
    battle.scene.pbChangePokemon(target,target.pokemon)
    battle.pbSetSeen(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |ability,user,target,move,battle|
    next if ![:BUG, :DARK, :GHOST].include?(move.calcType)
    target.tryRaiseStat(:SPEED,target,showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability,user,target,move,battle|
    target.tryRaiseStat(:DEFENSE,target,showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :WATER
    target.tryRaiseStat(:DEFENSE,target,increment: 2, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next unless target.pbCanLowerAnyOfStats?([:DEFENSE,:SPEED],target)
    battle.pbShowAbilitySplash(target)
    target.tryLowerStat(:DEFENSE,target)
    target.tryRaiseStat(:SPEED,target, increment: 2)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:AFTERMATH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if !move.physicalMove?
    battle.pbShowAbilitySplash(target)
    if !battle.moldBreaker
      dampBattler = battle.pbCheckGlobalAbility(:DAMP)
      if dampBattler
        battle.pbShowAbilitySplash(dampBattler)
        battle.pbDisplay(_INTL("{1} cannot use {2}!",target.pbThis,target.abilityName))
        battle.pbHideAbilitySplash(dampBattler)
        battle.pbHideAbilitySplash(target)
        next
      end
    end
    if user.takesIndirectDamage?(true)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
      user.applyFractionalDamage(1.0/4.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
  proc { |ability,user,target,move,battle|
    next if !target.fainted? || user.dummy
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(true)
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      oldHP = user.hp
      damageTaken = target.damageState.hpLost
      damageTaken /= 4 if target.boss?
      user.damageState.displayedDamage = damageTaken
	    battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(damageTaken,false)
      user.pbHealthLossChecks(oldHP)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
  proc { |ability,user,target,move,battle|
    next if user.numbed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.canNumb?(target,true)
      user.applyNumb(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted?
    next if user.effectActive?(:Disable)
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.total_pp>0)
    next if battle.pbRandom(100)>=60
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,true)
      user.applyEffect(:Disable,3)
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    oldAbil = user.ability
    battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
    user.ability = ability
    battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
    battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
    battle.pbHideAbilitySplash(user) if user.opposes?(target)
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if !oldAbil.nil?
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(true)
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      user.applyFractionalDamage(1.0/8.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS,:ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.canBurn?(target,true)
      user.applyBurn(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EFFECTSPORE,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.physicalMove?
    next if battle.pbRandom(100)>=30
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.numbed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(true)
      case r
      when 0
        if user.canSleep?(target,true)
          user.applySleep()
        end
      when 1
        if user.canPoison?(target,true)
          user.applyPoison(target)
        end
      when 2
        if user.canNumb?(target,true)
          user.applyNumb(target)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.canPoison?(target,true)
      user.applyPoison(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMENGINE,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :FIRE && move.calcType != :WATER
    target.tryRaiseStat(:SPEED,target,increment: 6, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if user.effectActive?(:PerishSong)
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
    user.applyEffect(:PerishSong,3)
    target.applyEffect(:PerishSong,3) if !target.effectActive?(:PerishSong)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
  proc { |ability,user,target,move,battle|
    battle.pbShowAbilitySplash(target)
    target.eachOpposing{|b|
      b.tryLowerStat(:SPEED,target)
    }
    target.eachAlly{|b|
      b.tryLowerStat(:SPEED,target)
    }
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
  proc { |ability,user,target,move,battle|
    next if target.form==0
    if target.species == :CRAMORANT
      battle.pbShowAbilitySplash(target)
      gulpform=target.form
      target.form = 0
      battle.scene.pbChangePokemon(target,target.pokemon)
      battle.scene.pbDamageAnimation(user)
      if user.takesIndirectDamage?(true)
        user.applyFractionalDamage(1.0/4.0)
      end
      if gulpform == 1
        user.tryLowerStat(:DEFENSE, target, showAbilitySplash: true)
      elsif gulpform==2
        msg = nil
        user.applyNumb(target,msg)
      end
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if user.fainted?
    abilityBlacklist = [
       :DISGUISE,
       :FLOWERGIFT,
       :GULPMISSILE,
       :ICEFACE,
       :IMPOSTER,
       :RECEIVER,
       :RKSSYSTEM,
       :SCHOOLING,
       :STANCECHANGE,
       :WONDERGUARD,
       :ZENMODE,
       # Abilities that are plain old blocked.
       :NEUTRALIZINGGAS
    ]
    failed = false
    abilityBlacklist.each do |abil|
      next if user.ability != abil
      failed = true
      break
    end
    next if failed
    oldAbil = -1
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    oldAbil = user.ability
    battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
    user.ability = :WANDERINGSPIRIT
    target.ability = oldAbil
    if user.opposes?(target)
      battle.pbReplaceAbilitySplash(user)
      battle.pbReplaceAbilitySplash(target)
    end
    battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
    battle.pbHideAbilitySplash(user)
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    if oldAbil
      user.pbOnAbilityChanged(oldAbil)
      target.pbOnAbilityChanged(:WANDERINGSPIRIT)
    end

  }
)

BattleHandlers::TargetAbilityOnHit.add(:FEEDBACK,
  proc { |ability,user,target,move,battle|
    next if !move.specialMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(true)
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      user.applyFractionalDamage(1.0/8.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
  proc { |ability,user,target,move,battle|
    next unless move.specialMove?
    next if battle.pbRandom(100)>=30
    next if user.poisoned?
    battle.pbShowAbilitySplash(target)
    if user.canPoison?(target,true)
      user.applyPoison(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SUDDENCHILL,
  proc { |ability,user,target,move,battle|
    next if !move.specialMove?
    next if battle.pbRandom(100)>=30
    next if user.frostbitten?
    battle.pbShowAbilitySplash(target)
    if user.canFrostbite?(target,true)
      user.applyFrostbite(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if battle.pbRandom(100)>=30
    next if user.frostbitten?
    battle.pbShowAbilitySplash(target)
    if user.canFrostbite?(target,true)
      user.applyFrostbite(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if user.effectActive?(:Curse) || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    user.applyEffect(:Curse)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILING,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if move.physicalMove?
    next if battle.pbRandom(100)>=30
    next if user.dizzy?
    battle.pbShowAbilitySplash(target)
    if user.canDizzy?(target,true)
      user.applyDizzy(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:DISORIENT,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.physicalMove?
    next if battle.pbRandom(100)>=30
    next if user.dizzy?
    battle.pbShowAbilitySplash(target)
    if user.canDizzy?(target,true)
      user.applyDizzy(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
  proc { |ability,user,target,move,battle|
    target.tryRaiseStat(:SPECIAL_DEFENSE,target,showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ADAPTIVESKIN,
  proc { |ability,user,target,move,battle|
    if move.physicalMove?
		  target.tryRaiseStat(:DEFENSE,target,showAbilitySplash: true)
	  else
		  target.tryRaiseStat(:SPECIAL_DEFENSE,target,showAbilitySplash: true)
	  end
  }
)


BattleHandlers::TargetAbilityOnHit.add(:QUILLERINSTINCT,
  proc { |ability,user,target,move,battle|
    next if target.pbOpposingSide.effectAtMax?(:Spikes)
    battle.pbShowAbilitySplash(target)
    target.pbOpposingSide.incrementEffect(:Spikes)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ELECTRICFENCE,
  proc { |ability,user,target,move,battle|
	echoln target.battle.field.terrain == :Electric
    next unless target.battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(true)
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      user.applyFractionalDamage(1.0/6.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PETRIFYING,
  proc { |ability,user,target,move,battle|
    next if user.numbed? || battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if user.canNumb?(target,true)
      user.applyNumb(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
  proc { |ability,user,target,move,battle|
    next if !Effectiveness.resistant?(target.damageState.typeMod)
    target.pbRaiseMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1], target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:RELUCTANTBLADE,
  proc { |ability,user,target,move,battle|
    if move.physicalMove? && !target.fainted?
      battle.forceUseMove(target,:LEAFAGE,user.index,true,nil,nil,true)
	  end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WIBBLEWOBBLE,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    battle.forceUseMove(target,:POWERSPLIT,user.index,true,nil,nil,true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CONSTRICTOR,
  proc { |ability,user,target,move,battle|
    if move.physicalMove? && !target.fainted?
      battle.forceUseMove(target,:BIND,user.index,true,nil,nil,true)
	  end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:KELPLINK,
  proc { |ability,user,target,move,battle|
    next unless move.physicalMove?
    next if user.leeched? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.canLeech?(target,true)
      user.applyLeeched(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PLAYVICTIM,
  proc { |ability,user,target,move,battle|
    next unless move.specialMove?
    next if user.leeched? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.canLeech?(target,true)
      user.applyLeeched(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)


#########################################
# Weather Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Sandstorm,battler,battle,false,true)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:INNERLIGHT,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Sun,battler,battle,false,true)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Rain,battler,battle,false,true)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Hail,battler,battle,false,true)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:SWARMMOUTH,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Swarm,battler,battle,false,true)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:ACIDBODY,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:AcidRain,battler,battle,false,true)
	}
)


#########################################
# Terrain Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SEEDSCATTER,
	proc { |ability,target,battler,move,battle|
    terrainSetAbility(:Grassy,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:THUNDERSTRUCK,
	proc { |ability,target,battler,move,battle|
    terrainSetAbility(:Electric,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:MISTCRAFT,
	proc { |ability,target,battler,move,battle|
		terrainSetAbility(:Misty,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:CLEVERRESPONSE,
	proc { |ability,target,battler,move,battle|
    terrainSetAbility(:Psychic,battler,battle)
	}
)