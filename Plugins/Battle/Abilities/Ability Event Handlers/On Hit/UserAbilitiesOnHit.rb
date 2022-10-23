BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability,user,target,move,battle|
    next if !move.contactMove?
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
	elsif target.effects[PBEffects::Enlightened]
	  battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
    elsif target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}! Its Sp. Atk is reduced!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbPoison(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKSTYLE,
  proc { |ability,user,target,move,battle|
    next if battle.pbRandom(100)>=50
    next if move.type != :FIGHTING
    next if target.paralyzed?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanParalyze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} numbed {3}! {4}!",
           user.pbThis,user.abilityName,target.pbThis(true),NUMBED_EXPLANATION)
      end
      target.pbParalyze(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FROSTWINGS,
  proc { |ability,user,target,move,battle|
    next if battle.pbRandom(100)>=20
    next if move.type != :FLYING
    next if target.frostbitten?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanFrostbite?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} frostbit {3}! {4}!",
           user.pbThis,user.abilityName,target.pbThis(true), CHILLED_EXPLANATION)
      end
      target.pbFrostbite(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SHOCKWINGS,
  proc { |ability,user,target,move,battle|
    next if battle.pbRandom(100)>=20
    next if move.type != :FLYING
    next if target.paralyzed?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanParalyze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} numbed {3}! {4}}!",
           user.pbThis,user.abilityName,target.pbThis(true),NUMBED_EXPLANATION)
      end
      target.pbParalyze(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:FLAMEWINGS,
  proc { |ability,user,target,move,battle|
    next if battle.pbRandom(100)>=20
    next if move.type != :FLYING
    next if target.burned?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}! {4}!",
           user.pbThis,user.abilityName,target.pbThis(true), BURNED_EXPLANATION)
      end
      target.pbBurn(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)
BattleHandlers::UserAbilityOnHit.add(:BURNSKILL,
  proc { |ability,user,target,move,battle|
    next if !move.specialMove?
    next if battle.pbRandom(100)>=30
    next if target.burned?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanBurn?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}! {4}}!",user.pbThis,user.abilityName,target.pbThis(true), BURNED_EXPLANATION)
      end
      target.pbBurn(user,msg)
    end
    battle.pbHideAbilitySplash(user)
	}
)

BattleHandlers::UserAbilityOnHit.add(:CHILLOUT,
  proc { |ability,user,target,move,battle|
    next if !move.specialMove?
    next if battle.pbRandom(100)>=30
    next if target.frostbitten?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanFrostbite?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} frostbit {3}! {4}!",user.pbThis,user.abilityName,target.pbThis(true), CHILLED_EXPLANATION)
      end
      target.pbFrostbite(msg)
    end
    battle.pbHideAbilitySplash(user)
	}
)

BattleHandlers::UserAbilityOnHit.add(:NUMBINGTOUCH,
  proc { |ability,user,target,move,battle|
    next if !move.contactMove?
    next if battle.pbRandom(100)>=30
    next if target.paralyzed?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanParalyze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} numbed {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbParalyze(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:NERVENUMBER,
  proc { |ability,user,target,move,battle|
    next if move.contactMove?
    next if battle.pbRandom(100)>=30
    next if target.paralyzed?
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanParalyze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} numbed {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbParalyze(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SOUNDBARRIER,
  proc { |ability,user,target,move,battle|
    next if !move.soundMove?
    if user.pbCanRaiseStatStage?(:DEFENSE,user)
      user.pbRaiseStatStageByAbility(:DEFENSE,1,user)
    end
  }
)

BattleHandlers::UserAbilityOnHit.add(:DAWNBURST,
  proc { |ability,user,target,move,battle|
    next if target.burned?
    next if user.turnCount > 1
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}! {4}!",
           user.pbThis,user.abilityName,target.pbThis(true), BURNED_EXPLANATION)
      end
      target.pbBurn(msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)