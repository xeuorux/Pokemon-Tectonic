BattleHandlers::StatusCureAbility.add(:MAGMAARMOR,
  proc { |ability,battler|
    next if battler.status != :FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} unchilled it!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
  proc { |ability,battler,user,status|
    next if !user || user.index==battler.index
    case status
    when :POISON
      if user.pbCanPoisonSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} poisoned {3}! Its Sp. Atk is reduced!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbPoison(nil,msg,(battler.statusCount>0))
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :BURN
      if user.pbCanBurnSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} burned {3}! Its Attack is reduced!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbBurn(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :PARALYSIS
      if user.pbCanParalyzeSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbParalyze(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}! Its Attack is reduced!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbBurn(target,msg)
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
    if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}! Its Sp. Atk is reduced!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbPoison(target,msg)
        end
      when 2
        if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,target.abilityName,user.pbThis(true))
          end
          user.pbParalyze(target,msg)
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