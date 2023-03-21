#########################################
# Weather Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Sandstorm, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:INNERLIGHT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Sun, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Rain, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Hail, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUNEATER,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Eclipse, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:LUNARLOYALTY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(:Moonglow, target, battle, false, true, aiChecking)
    }
)

#########################################
# Stat change abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPEED,1], target, user, i)
            end
            next ret
        end
        user.tryLowerStat(:SPEED, target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY, :TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPEED,1], target, user, i)
            end
            next ret
        else
            battle.pbShowAbilitySplash(target)
            target.eachOpposing do |b|
                b.tryLowerStat(:SPEED, target)
            end
            target.eachAlly do |b|
                b.tryLowerStat(:SPEED, target)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
  )

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless %i[BUG DARK GHOST].include?(move.calcType)
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPEED,1], target, user, i)
            end
            next ret
        end
        target.tryRaiseStat(:SPEED, target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:DEFENSE,1], target, user, i)
            end
            next ret
        end
        target.tryRaiseStat(:DEFENSE, target, showAbilitySplash: true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
    proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPECIAL_DEFENSE,1], target, user, i)
            end
            next ret
        end
        target.tryRaiseStat(:SPECIAL_DEFENSE, target, showAbilitySplash: true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ADAPTIVESKIN,
    proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        statToRaise = nil
        if move.physicalMove?
            statToRaise = :DEFENSE
        else
            statToRaise = :SPECIAL_DEFENSE
        end
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([statToRaise,1], target, user, i)
            end
            next ret
        end
        target.tryRaiseStat(statToRaise, target, showAbilitySplash: true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            ret = getMultiStatDownEffectScore([:DEFENSE, 1], target, user)
            ret -= getMultiStatUpEffectScore([:SPEED, 2], target, user)
            next ret
        else
            battle.pbShowAbilitySplash(target)
            target.tryLowerStat(:DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKSPIRIT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        if aiChecking
            ret = getMultiStatDownEffectScore([:SPECIAL_DEFENSE, 1], target, user)
            ret -= getMultiStatUpEffectScore([:SPEED, 2], ustargeter, user)
            next ret
        else
            battle.pbShowAbilitySplash(target)
            target.tryLowerStat(:SPECIAL_DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMENGINE,
    proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        next if move.calcType != :FIRE && move.calcType != :WATER
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPEED,6], target, user, i*6)
            end
            next ret
        end
        target.tryRaiseStat(:SPEED, target, increment: 6, showAbilitySplash: true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        if aiChecking
            expectedTypeMod = battle.battleAI.pbCalcTypeModAI(move.calcType, user, target, move)
            next 0 unless Effectiveness.resistant?(target.damageState.typeMod)
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:ATTACK, 1, :SPECIAL_ATTACK, 1], target, user, i)
            end
            next ret
        else
            next unless Effectiveness.resistant?(target.damageState.typeMod)
            target.pbRaiseMultipleStatStages([:ATTACK, 1, :SPECIAL_ATTACK, 1], target, showAbilitySplash: true)
        end
    }
)

#########################################
# Damaging abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
      next unless move.physicalMove?
      next -10 * aiNumHits if aiChecking && user.takesIndirectDamage?
      battle.pbShowAbilitySplash(target)
      if user.takesIndirectDamage?(true)
          battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
          user.applyFractionalDamage(1.0 / 8.0)
      end
      battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS, :ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:FEEDBACK,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?(user)
        next -10 * aiNumHits if aiChecking && user.takesIndirectDamage?
        battle.pbShowAbilitySplash(target)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ARCCONDUCTOR,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless battle.rainy?
        next -10 * aiNumHits if aiChecking && user.takesIndirectDamage?
        battle.pbShowAbilitySplash(target)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 6.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SPINTENSITY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless target.stages[:SPEED] > 0
        next -5 * target.stages[:SPEED] if aiChecking && user.takesIndirectDamage?
        battle.pbShowAbilitySplash(target)
        battle.pbDisplay(_INTL("#{user.pbThis} catches the full force of #{target.pbThis(true)}'s Speed!"))
        oldStage = target.stages[:SPEED]
        user.applyFractionalDamage(oldStage / 6.0)
        battle.pbCommonAnimation("StatDown", target)
        target.stages[:SPEED] = 0
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Move usage abilities
#########################################

# TODO: Make the checks here more detailed

BattleHandlers::TargetAbilityOnHit.add(:RELUCTANTBLADE,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        next -30 * aiNumHits if aiChecking
        battle.forceUseMove(target, :LEAFAGE, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WIBBLEWOBBLE,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        next -40 if aiChecking
        battle.forceUseMove(target, :POWERSPLIT, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CONSTRICTOR,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        next -(10 + 20 * aiNumHits) if aiChecking
        battle.forceUseMove(target, :BIND, user.index, true, nil, nil, true)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TOTALMIRROR,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        next -60 if aiChecking
        battle.forceUseMove(target, move.id, user.index, true, nil, nil, true)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ABOVEITALL,
  proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        next -40 if aiChecking
        battle.forceUseMove(target, :PARTINGSHOT, user.index, true, nil, nil, true)
  }
)

#########################################
# Status inducing abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(:NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:LIVEWIRE,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(:NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PETRIFYING,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
         randomStatusProcTargetAbility(:NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(:POISON, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
  )

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(:POISON, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUDDENCHILL,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(:FROSTBITE, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(:FROSTBITE, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILING,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(:DIZZY, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:DISORIENT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(:DIZZY, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:KELPLINK,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(:LEECHED, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PLAYVICTIM,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(:LEECHED, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(:BURN, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FIERYSPIRIT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(:BURN, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

#########################################
# Other punishment random triggers
#########################################

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.effectActive?(:Curse)
        next -10 * aiNumHits if aiChecking
        next if battle.pbRandom(100) >= 30
        battle.pbShowAbilitySplash(target)
        user.applyEffect(:Curse)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SEALINGBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if user.fainted?
        next if user.effectActive?(:Disable)
        next -15 if aiChecking
        battle.pbShowAbilitySplash(target)
        user.applyEffect(:Disable, 3) if user.canBeDisabled?(true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.effectActive?(:PerishSong)
        next -5 if aiChecking
        battle.pbShowAbilitySplash(target)
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
        user.applyEffect(:PerishSong, 3)
        target.applyEffect(:PerishSong, 3) unless target.effectActive?(:PerishSong)
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Other abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if user.dummy
        if aiChecking
            if user.takesIndirectDamage?
                next -50 / aiNumHits
            else
                next 0
            end
        end
        next unless target.fainted?
        battle.pbShowAbilitySplash(target)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            oldHP = user.hp
            damageTaken = target.damageState.hpLost
            damageTaken /= 4 if target.boss?
            user.damageState.displayedDamage = damageTaken
            battle.scene.pbDamageAnimation(user)
            user.pbReduceHP(damageTaken, false)
            user.pbHealthLossChecks(oldHP)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility? || user.ability == ability
        next -5 if aiChecking
        battle.pbShowAbilitySplash(target) if user.opposes?(target)
        oldAbil = user.ability
        battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
        user.ability = ability
        battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
        battle.pbHideAbilitySplash(user) if user.opposes?(target)
        battle.pbHideAbilitySplash(target) if user.opposes?(target)
        user.pbOnAbilityChanged(oldAbil) unless oldAbil.nil?
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:INFECTED,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility? || user.ability == ability
        next unless user.canChangeType?
        next -5 if aiChecking
        battle.pbShowAbilitySplash(target) if user.opposes?(target)
        oldAbil = user.ability
        battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
        user.ability = ability
        battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
        user.applyEffect(:Type3,:GRASS) unless user.pbHasType?(:GRASS)
        battle.pbHideAbilitySplash(user) if user.opposes?(target)
        battle.pbHideAbilitySplash(target) if user.opposes?(target)
        user.pbOnAbilityChanged(oldAbil) unless oldAbil.nil?
    }
)

BattleHandlers::TargetAbilityOnHit.add(:THUNDERSTRUCK,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        if aiChecking
            next target.pbHasAttackingType?(:ELECTRIC) ? -40 : 0
        else
            target.applyEffect(:Charge)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.form == 0
        next unless target.species == :CRAMORANT
        gulpform = target.form
        if aiChecking
            score = 0
            score -= 20 if user.takesIndirectDamage?
            if gulpform == 1
                score -= getMultiStatDownEffectScore([:DEFENSE,1], target, user)
            elsif gulpform == 2
                score -= getNumbEffectScore(target, user)
            end
            next score
        else
            battle.pbShowAbilitySplash(target)
            target.form = 0
            battle.scene.pbChangePokemon(target, target.pokemon)
            battle.scene.pbDamageAnimation(user)
            user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
            if gulpform == 1
                user.tryLowerStat(:DEFENSE, target, showAbilitySplash: true)
            elsif gulpform == 2
                msg = nil
                user.applyNumb(target, msg)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next 10 if aiChecking
        # NOTE: This intentionally doesn't show the ability splash.
        next unless target.illusion?
        target.disableEffect(:Illusion)
        battle.scene.pbChangePokemon(target, target.pokemon)
        battle.pbSetSeen(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if aiChecking
        next unless move.physicalMove?
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
            :NEUTRALIZINGGAS,
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
        battle.pbShowAbilitySplash(user, true, false) if user.opposes?(target)
        user.ability = :WANDERINGSPIRIT
        target.ability = oldAbil
        if user.opposes?(target)
            battle.pbReplaceAbilitySplash(user)
            battle.pbReplaceAbilitySplash(target)
        end
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!", user.pbThis, user.abilityName))
        battle.pbHideAbilitySplash(user)
        battle.pbHideAbilitySplash(target) if user.opposes?(target)
        if oldAbil
            user.pbOnAbilityChanged(oldAbil)
            target.pbOnAbilityChanged(:WANDERINGSPIRIT)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:EROSIONCYCLE,
    proc { |_ability, target, battler, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.pbOpposingSide.effectAtMax?(:ErodedRock)
        if aiChecking
            next (target.aboveHalfHealth? ? -10 : 0) * aiNumHits
        end
        target.pbOwnSide.incrementEffect(:ErodedRock)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:QUILLERINSTINCT,
    proc { |_ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.pbOpposingSide.effectAtMax?(:Spikes)
        if aiChecking
            layerSlots = GameData::BattleEffect.get(:Spikes).maximum - target.pbOpposingSide.countEffect(:Spikes)
            aiNumHits = [aiNumHits,layerSlots].min
            next -getHazardSettingEffectScore(target, user) * aiNumHits
        end
        battle.pbShowAbilitySplash(target)
        target.pbOpposingSide.incrementEffect(:Spikes)
        battle.pbHideAbilitySplash(target)
    }
)

# Only does stuff for the AI
BattleHandlers::TargetAbilityOnHit.add(:MULTISCALE,
    proc { |_ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless target.hp == target.totalhp
        if aiChecking
            next 20
        else
            target.aiSeesAbility
        end
    }
)