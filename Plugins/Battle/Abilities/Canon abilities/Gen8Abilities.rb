#===============================================================================
# DamageCalcUserAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSMAW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :DRAGON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRANSISTOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GORILLATACTICS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

#===============================================================================
# DamageCalcTargetAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbility.add(:ICESCALES,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if move.specialMove?
  }
)

#===============================================================================
# DamageCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAllyAbility.add(:POWERSPOT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier]*= 1.3
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:STEELYSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if type == :STEEL
  }
)
#===============================================================================
# AbilityOnSwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:ASONEICE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has 2 Abilities!",battler.name))
    battle.pbShowAbilitySplash(battler,false,true,PBAbilities.getName(getID(PBAbilities,:UNNERVE)))
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ASONEICE,:ASONEGHOST)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:ATTACK,1,battler)
  }
)	

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:DEFENSE,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability,battler,battle|
    target=battler
    battle.pbShowAbilitySplash(battler)
    if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::LightScreen]>0
      target.pbOwnSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOwnSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
    end
    if target.pbOpposingSide.effects[PBEffects::AuroraVeil]>0
      target.pbOpposingSide.effects[PBEffects::AuroraVeil] = 0
      battle.pbDisplay(_INTL("{1}'s Aurora Veil wore off!",target.pbOpposingTeam))
    end
    if target.pbOpposingSide.effects[PBEffects::LightScreen]>0
      target.pbOpposingSide.effects[PBEffects::LightScreen] = 0
      battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbOpposingTeam))
    end
    if target.pbOwnSide.effects[PBEffects::Reflect]>0
      target.pbOpposingSide.effects[PBEffects::Reflect] = 0
      battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbOpposingTeam))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability,battler,battle|
    battler.eachAlly do |b|
      next if b.status != :POISON
      battle.pbShowAbilitySplash(battler)
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured its {3}'s poison!",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability,battler,battle|
    done= false
    battler.eachAlly do |b|
      next if !b.hasAlteredStatStages?
      b.pbResetStatStages
      done = true
    end
    if done
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("All allies' stat changes were eliminated!"))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability,battler,battle|
    next if battle.field.effects[PBEffects::NeutralizingGas]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s gas nullified all abilities!",battler.pbThis))
    battle.field.effects[PBEffects::NeutralizingGas] = true
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================
BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if !user.affectedByContactEffect?
    next if user.effects[PBEffects::PerishSong]>0
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
    user.effects[PBEffects::PerishSong] = 3
    target.effects[PBEffects::PerishSong] = 3 if target.effects[PBEffects::PerishSong] == 0
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
      if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
        user.pbReduceHP(user.totalhp/4,false)
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
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = :WANDERINGSPIRIT
      target.ability = oldAbil
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        battle.pbReplaceAbilitySplash(target)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end

      battle.pbHideAbilitySplash(user)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    if oldAbil
      user.pbOnAbilityChanged(oldAbil)
      target.pbOnAbilityChanged(:WANDERINGSPIRIT)
    end

  }
)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================

BattleHandlers::UserAbilityEndOfMove.add(:ASONEICE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user) || user.fainted?
    battle.pbShowAbilitySplash(user,false,true,:CHILLINGNEIGH)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      user.pbRaiseStatStage(:ATTACK,numFainted,user)
    else
      user.pbRaiseStatStageByCause(:ATTACK,numFainted,user,:CHILLINGNEIGH)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEGHOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user) || user.fainted?
    battle.pbShowAbilitySplash(user,false,true,:GRIMNEIGH)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      user.pbRaiseStatStage(:SPECIAL_ATTACK,numFainted,user)
    else
      user.pbRaiseStatStageByCause(:SPECIAL_ATTACK,numFainted,user,:GRIMNEIGH)
    end
    battle.pbHideAbilitySplash(user)
  }
)


#===============================================================================
# EOREffectAbility handlers
#===============================================================================

BattleHandlers::EOREffectAbility.add(:BALLFETCH,
  proc { |ability,battler,battle|
    if battler.effects[PBEffects::BallFetch]!=0 && battler.item<=0
      ball=battler.effects[PBEffects::BallFetch]
      battler.item=ball
      battler.setInitialItem(battler.item)
      PBDebug.log("[Ability triggered] #{battler.pbThis}'s Ball Fetch found #{PBItems.getName(ball)}")
      battle.pbShowAbilitySplash(battler) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} found a {2}!",battler.pbThis,PBItems.getName(ball)))
      battler.effects[PBEffects::BallFetch]=0
      battle.pbHideAbilitySplash(battler) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
    end
  }
)

BattleHandlers::EOREffectAbility.add(:HUNGERSWITCH,
  proc { |ability,battler,battle|
    if battler.species == :MORPEKO
      battle.pbShowAbilitySplash(battler)
      battler.form=(battler.form==0) ? 1 : 0
      battler.pbUpdate(true)
      battle.scene.pbChangePokemon(battler,battler.pokemon)
      battle.pbDisplay(_INTL("{1} transformed!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

#===============================================================================
# PriorityBracketChangeAbility handlers
#===============================================================================
BattleHandlers::PriorityBracketChangeAbility.add(:QUICKDRAW,
  proc { |ability,battler,subPri,battle|
    next 1 if subPri<1 && battle.pbRandom(10)<3
  }
)

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================

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

#===============================================================================
# OnBerryConsumed handlers
#===============================================================================

BattleHandlers::OnBerryConsumedAbility.add(:CHEEKPOUCH,
  proc { |ability,user,berry,own_item,battle|
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user)
    recovery = user.totalhp / 3
    recovery /= 4 if user.boss?
    user.pbRecoverHP(recovery)
    battle.pbDisplay(_INTL("{1}'s HP was restored.", user.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)