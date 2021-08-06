#===============================================================================
# PriorityChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityChangeAbility.add(:MAESTRO,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if move.soundMove?
  }
)

BattleHandlers::PriorityChangeAbility.add(:FAUXLIAGE,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if battler.battle.field.terrain==:Grassy
  }
)

BattleHandlers::PriorityChangeAbility.add(:LIGHTTRICK,
  proc { |ability,battler,move,pri,targets=nil|
    next pri+1 if targets && targets.length == 1 && targets[0].status != :None
  }
)

#===============================================================================
# MoveImmunityTargetAbility handlers
#===============================================================================
BattleHandlers::MoveImmunityTargetAbility.add(:AERODYNAMIC,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:FLYING,:SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLYTRAP,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:BUG,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MAGMAARMOR,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ICE,:SPECIAL_DEFENSE,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:POISONABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:POISON,battle)
  }
)

#===============================================================================
# StatusCureAbility handlers
#===============================================================================
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE,:ROYALSCALES)


#===============================================================================
# DamageCalcUserAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:AUDACITY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.pbHasAnyStatus? && move.specialMove?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HEADACHE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mods[:attack_multiplier] *= 2.0 if user.effects[PBEffects::Confusion]>0 && move.specialMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUGEENERGY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.specialMove?
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:HUGEENERGY,:PUREENERGY)

BattleHandlers::DamageCalcUserAbility.add(:DEEPSTING,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TEMPERATURE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if user.lastMoveUsed!=move.id && !user.lastMoveFailed
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SPECIALIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod) && user.pbHasType?(type)
      mults[:final_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MIDNIGHTSUN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Sun && type == :DARK
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SUNCHASER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Sun && move.physicalMove?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:STEELWORKER,:PULVERIZE)

BattleHandlers::DamageCalcUserAbility.add(:SUBZERO,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :ICE
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PALEOLITHIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :ROCK
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SCALDINGSMOKE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :POISON
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:PUNKROCK,:LOUD)

BattleHandlers::DamageCalcUserAbility.add(:SUNCHASER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Rain && move.specialMove?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MYSTICFIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.3 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BIGTHORNS,
  proc { |ability,user,target,move,mults,baseDmg,type|
	if move.physicalMove? && user.battle.terrain == :Grassy
		mults[:base_damage_multiplier] *= 1.3
	end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STORMFRONT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather==:Rain && [:Electric,:Flying,:Water].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

#===============================================================================
# DamageCalcTargetAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbility.add(:SHIELDWALL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.hyper_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:STOUT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    mults[:final_damage_multiplier] *= 0.80 if w!=:None
  }
)


BattleHandlers::DamageCalcTargetAbility.add(:SENTRY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 0.75 if target.effects[PBEffects::Sentry] == true
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:DESERTARMOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    w = user.battle.pbWeather
    if w==:Sandstorm && move.physicalMove?
      mults[:defense_multiplier] *= 2
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:REALIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if type == :DRAGON || type == :FAIRY
      mults[:base_damage_multiplier] /= 2
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:TRAPPER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbCanSwitch?(user.index)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
  proc { |ability,user,target,move,battle|
    next if move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}! Its Sp. Atk is reduced!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbPoison(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.frozen? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanFreeze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} chilled {3}! It's slower and takes more damage!!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbFreeze(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.effects[PBEffects::Curse] = true || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("{1} laid a curse on {2}!",target.pbThis(true),user.pbThis))
    user.effects[PBEffects::Curse] = true
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILEING,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
	next if target.effects[PBEffects::Charm] > 0
    battle.pbShowAbilitySplash(target)
    if user.pbCanCharm?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} charmed {3}!",target.pbThis,
           target.abilityName,user.pbThis(true))
      end
      user.pbCharm
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
		target.pbRaiseStatStageByAbility(:SDEFENSE,1,target)
	else
		target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target)
	end
  }
)

#===============================================================================
# UserAbilityOnHit handlers
#===============================================================================
BattleHandlers::UserAbilityOnHit.add(:SHOCKSTYLE,
  proc { |ability,user,target,move,battle|
    next if target.paralyzed? || battle.pbRandom(100)>=50
    next if move.type != :FIGHTING
    battle.pbShowAbilitySplash(user)
    if target.pbCanParalyze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbParalyze(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FROSTWINGS,
  proc { |ability,user,target,move,battle|
    next if target.frozen? || battle.pbRandom(100)>=20
    next if move.type != :FLYING
    battle.pbShowAbilitySplash(user)
    if target.pbCanFreeze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} chilled {3}! Its speed and evasion are massively lowered!!",
           user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbFreeze(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKWINGS,
  proc { |ability,user,target,move,battle|
    next if target.paralyzed? || battle.pbRandom(100)>=20
    next if move.type != :FLYING
    battle.pbShowAbilitySplash(user)
    if target.pbCanParalyze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbParalyze(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLAMEWINGS,
  proc { |ability,user,target,move,battle|
    next if target.burned? || battle.pbRandom(100)>=20
    next if move.type != :FLYING
    battle.pbShowAbilitySplash(user)
    if target.pbCanFreeze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}! Its Attack is reduced!",
           user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbFreeze(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================
BattleHandlers::UserAbilityEndOfMove.add(:DEEPSTING,
  proc { |ability,user,targets,move,battle|
    next if !user.takesIndirectDamage?
    
    totalDamageDealt = 0
    targets.each do |target|
      next if target.damageState.unaffected
      totalDamageDealt = target.damageState.totalHPLost
    end
    next if totalDamageDealt <= 0
    amt = (totalDamageDealt/2.0).round
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HUBRIS,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.copy(:MOXIE,:CHILLINGNEIGH)

BattleHandlers::UserAbilityEndOfMove.copy(:HUBRIS,:GRIMNEIGH)


#===============================================================================
# AbilityOnSwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:DAZZLE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpecialAttackStatStageDazzle(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HOLIDAYCHEER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachSameSideBattler(battler.index) do |b|
      b.pbRecoverHP(b.totalhp/3)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# AbilityOnEnemySwitchIn handlers
#===============================================================================
BattleHandlers::AbilityOnEnemySwitchIn.add(:PROUDFIRE,
  proc { |ability,switcher,bearer,battle|
    PBDebug.log("[Ability triggered] #{bearer.pbThis}'s #{bearer.abilityName}")
    battle.pbShowAbilitySplash(bearer)
    if switcher.pbCanBurn?(bearer,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}! Its Attack is reduced!",
           bearer.pbThis,bearer.abilityName,switcher.pbThis(true))
      end
      switcher.pbBurn(bearer,msg)
    end
    battle.pbHideAbilitySplash(bearer)
  }
)


#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:SANDSNIPER,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if user.battle.pbWeather == :Sandstorm
  }
)

#===============================================================================
# CriticalCalcUserAbility handlers
#===============================================================================
BattleHandlers::CriticalCalcUserAbility.add(:STAMPEDE,
  proc { |ability,user,target,c|
    next c+user.stages[:SPEED]
  }
)

#===============================================================================
# EOREffectAbility handlers
#===============================================================================
BattleHandlers::EOREffectAbility.add(:ASTRALBODY,
  proc { |ability,battler,battle|
	next unless battle.field.terrain==:Misty
    next if !battler.canHeal?
	battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================
BattleHandlers::MoveBlockingAbility.add(:KILLJOY,
  proc { |ability,bearer,user,targets,move,battle|
    next move.danceMove?
  }
)

BattleHandlers::MoveBlockingAbility.add(:BADINFLUENCE,
  proc { |ability,bearer,user,targets,move,battle|
    next move.healingMove?
  }
)