BattleHandlers::TargetAbilityOnHit.add(:ANGERPOINT,
  proc { |ability,user,target,move,battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(:ATTACK,target)
    battle.pbShowAbilitySplash(target)
    target.pbMaximizeStatStage(:ATTACK,target)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CUTECHARM,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanAttract?(target,true) && user.affectedByContactEffect?
      user.pbAttract(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    user.pbLowerStatStageByAbility(:SPEED,1,target,true,true)
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
    target.pbRaiseStatStageByAbility(:SPEED,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :WATER
    target.pbRaiseStatStageByAbility(:DEFENSE,2,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if !target.pbCanLowerStatStage?(:DEFENSE, target) &&
            !target.pbCanRaiseStatStage?(:SPEED, target)
    battle.pbShowAbilitySplash(target)
    target.pbLowerStatStageByAbility(:DEFENSE, 1, target, false)
    target.pbRaiseStatStageByAbility(:SPEED, 2, target, false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:AFTERMATH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if !move.pbContactMove?(user)
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
    if user.takesIndirectDamage?(true) && user.affectedByContactEffect?(true)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
      b.applyFractionalDamage(1.0/4.0)
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
    next if user.paralyzed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,true) &&
       user.affectedByContactEffect?(true)
      user.pbParalyze(target)
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
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(true)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = ability
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if !oldAbil.nil?
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(true) && user.affectedByContactEffect?(true)
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      user.applyFractionalDamage(1.0/8.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS,:ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target,true) && user.affectedByContactEffect?(true)
      user.pbBurn(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EFFECTSPORE,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(true) &&
       user.affectedByContactEffect?(true)
      case r
      when 0
        if user.pbCanSleep?(target,true)
          user.pbSleep()
        end
      when 1
        if user.pbCanPoison?(target,true)
          user.pbPoison(target)
        end
      when 2
        if user.pbCanParalyze?(target,true)
          user.pbParalyze(target)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,true) && user.affectedByContactEffect?(true)
      user.pbPoison(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SANDSPIT,
  proc { |ability,target,battler,move,battle|
    pbBattleWeatherAbility(:Sandstorm,battler,battle)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMENGINE,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :FIRE && move.calcType != :WATER
    target.pbRaiseStatStageByAbility(:SPEED,6,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?
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
      b.pbLowerStatStage(:SPEED,1,target)
    }
    target.eachAlly{|b|
      b.pbLowerStatStage(:SPEED,1,target)
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
      if gulpform==1
        user.pbLowerStatStageByAbility(:DEFENSE,1,target,false)
      elsif gulpform==2
        msg = nil
        user.pbParalyze(target,msg)
      end
      battle.pbHideAbilitySplash(target)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
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
    if user.affectedByContactEffect?(true)
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
    end
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
    if user.pbCanPoison?(target,true) && user.affectedByContactEffect?(true)
      user.pbPoison(target)
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
    if user.pbCanFrostbite?(target,true) && user.affectedByContactEffect?(true)
      user.pbCanFrostbite?(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    next if user.frostbitten?
    battle.pbShowAbilitySplash(target)
    if user.pbCanFrostbite?(target,true) && user.affectedByContactEffect?(true)
      user.pbFrostbite(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.effectActive?(:Curse) || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    user.applyEffect(:Curse)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILING,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    next if user.mystified?
    battle.pbShowAbilitySplash(target)
    if user.pbCanMystify?(target,true)
      user.pbMystify(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:DISORIENT,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    next if user.flustered?
    battle.pbShowAbilitySplash(target)
    if user.pbCanFluster?(target,true) && user.affectedByContactEffect?(true)
      user.pbFluster(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ADAPTIVESKIN,
  proc { |ability,user,target,move,battle|
    if move.physicalMove?
		  target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
	  else
		  target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target)
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
    next if user.paralyzed? || battle.pbRandom(100) >= 30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,true)
      user.pbParalyze(target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
  proc { |ability,user,target,move,battle|
    next if !Effectiveness.resistant?(target.damageState.typeMod)
	if target.pbCanRaiseStatStage?(:ATTACK,target) || target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
		battle.pbShowAbilitySplash(target)
		target.pbRaiseStatStageByAbility(:ATTACK,1,target,false) if target.pbCanRaiseStatStage?(:ATTACK,target)
		target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false) if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
		battle.pbHideAbilitySplash(target)
	end
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

BattleHandlers::TargetAbilityAfterMoveUse.add(:REAWAKENEDPOWER,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
    if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      battle.pbShowAbilitySplash(target)
      target.pbMaximizeStatStage(:SPECIAL_ATTACK,user,self) if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      battle.pbHideAbilitySplash(target)
    end
  }
)


#########################################
# Weather Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Sandstorm,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:INNERLIGHT,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Sun,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Rain,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Hail,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:SWARMMOUTH,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:Swarm,battler,battle)
	}
)

BattleHandlers::TargetAbilityOnHit.add(:ACIDBODY,
	proc { |ability,target,battler,move,battle|
		pbBattleWeatherAbility(:AcidRain,battler,battle)
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