BattleHandlers::UserAbilityEndOfMove.add(:BEASTBOOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    userStats = user.plainStats
    highestStatValue = 0
    userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
    GameData::Stat.each_main_battle do |s|
      next if userStats[s.id] < highestStatValue
      stat = s.id
      user.tryRaiseStat(stat,user, increment: numFainted, showAbilitySplash: true)
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MOXIE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    user.tryRaiseStat(:ATTACK,user,increment: numFainted, showAbilitySplash: true)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    targets.each do |b|
      break if move.stealItem(user,b,true)
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEICE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user) || user.fainted?
    battle.pbShowAbilitySplash(user,false,true,GameData::Ability.get(:CHILLINGNEIGH).name)
    user.pbRaiseStatStage(:ATTACK,numFainted,user)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEGHOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user) || user.fainted?
    battle.pbShowAbilitySplash(user,false,true,GameData::Ability.get(:GRIMNEIGH).name)
    user.pbRaiseStatStage(:SPECIAL_ATTACK,numFainted,user)
    battle.pbHideAbilitySplash(user)
  }
)

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
    next if numFainted == 0
    user.tryRaiseStat(:SPECIAL_ATTACK,user,increment: numFainted,showAbilitySplash: true)
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
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:GILD,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    targets.each do |b|
		  itemName = GameData::Item.get(b.item).name if b.item
      removeMessage = _INTL("{1} turned {2}'s {3} into gold!",user.pbThis,
        b.pbThis(true),b.itemName)
      if move.removeItem(user,b,true,removeMessage)
        if user.pbOwnedByPlayer?
          battle.field.incrementEffect(:PayDay,5 * user.level)
        end
        break
      end
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:DAUNTLESS,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    user.pbRaiseMultipleStatStages([:ATTACK,numFainted,:SPECIAL_ATTACK,numFainted],user, showAbilitySplash: true)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SPACEINTERLOPER,
  proc { |ability,battler,targets,move,battle|
    battler.pbRecoverHPFromMultiDrain(targets,0.25)
  }
)


BattleHandlers::UserAbilityEndOfMove.add(:FOLLOWTHROUGH,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    user.tryRaiseStat(:SPEED,user,increment: numFainted,showAbilitySplash: true)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SOUNDBARRIER,
  proc { |ability,user,targets,move,battle|
    user.tryRaiseStat(:DEFENSE,user, showAbilitySplash: true) if move.soundMove?
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SEALORD,
  proc { |ability,user,targets,move,battle|
    next unless user.species == :GYARADOS
    next unless user.form == 0
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    battle.pbShowAbilitySplash(user)
    user.pbChangeForm(1,_INTL("{1}'s anger cannot be sated! It enters its Hull Breaker form!",user.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:VICTORYMOLT,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    next unless user.pbHasAnyStatus? || user.hasAlteredStatStages?
    battle.pbShowAbilitySplash(user)
    user.pbChangeForm(1,_INTL("{1} molts into a new shell!",user.pbThis))
    user.pbCureStatus(true)
    if user.hasAlteredStatStages?
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!",user.pbThis))
      user.resetStatStages
    end
    battle.pbHideAbilitySplash(user)
  }
)