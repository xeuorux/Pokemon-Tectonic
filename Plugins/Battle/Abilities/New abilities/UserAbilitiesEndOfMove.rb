BattleHandlers::UserAbilityEndOfMove.add(:DEEPSTING,
  proc { |ability,user,targets,move,battle|
    next if !user.takesIndirectDamage?
    totalDamageDealt = 0
    targets.each do |target|
      next if target.damageState.unaffected
      totalDamageDealt = target.damageState.totalHPLost
    end
    next if totalDamageDealt <= 0
    amt = (totalDamageDealt/4.0).round
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
	  user.pbFaint if user.fainted?
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

BattleHandlers::UserAbilityEndOfMove.add(:SCHADENFREUDE,
  proc { |ability,battler,targets,move,battle|
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    recover = battler.totalhp/4
    recover /= BOSS_HP_BASED_EFFECT_RESISTANCE if battler.boss?
    battler.pbRecoverHP(recover)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:GILD,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if b.hasActiveAbility?(:STICKYHOLD)
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be gilded!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      itemName = b.itemName
      b.pbRemoveItem(false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} turned {2}'s {3} into gold!",user.pbThis,
           b.pbThis(true),itemName))
      else
        battle.pbDisplay(_INTL("{1} turned {2}'s {3} into gold with {4}!",user.pbThis,
           b.pbThis(true),itemName,user.abilityName))
      end
      if user.pbOwnedByPlayer?
        battle.field.effects[PBEffects::PayDay] += 5*user.level
      end
      battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
      battle.pbHideAbilitySplash(user)
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:DAUNTLESS,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user)
    user.pbRaiseStatStageByAbility(:ATTACK,numFainted,user)
	  next if numFainted==0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
	  user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SPACEINTERLOPER,
  proc { |ability,battler,targets,move,battle|
    battle.pbShowAbilitySplash(battler)
    if battler.pbRecoverHPFromMultiDrain(targets,0.5)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)