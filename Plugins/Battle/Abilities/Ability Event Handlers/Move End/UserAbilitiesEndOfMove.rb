BattleHandlers::UserAbilityEndOfMove.add(:BEASTBOOST,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
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
          user.tryRaiseStat(stat, user, increment: numFainted, ability: ability)
          break
      end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MOXIE,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      user.tryRaiseStat(:ATTACK, user, increment: numFainted, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      targets.each do |b|
          b.eachItem do |item|
            move.stealItem(user, b, item)
          end
      end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEICE,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user) || user.fainted?
      battle.pbShowAbilitySplash(user, :CHILLINGNEIGH)
      user.pbRaiseStatStage(:ATTACK, numFainted, user)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEGHOST,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0 || !user.pbCanRaiseStatStage?(:ATTACK, user) || user.fainted?
      battle.pbShowAbilitySplash(user, :GRIMNEIGH)
      user.pbRaiseStatStage(:SPECIAL_ATTACK, numFainted, user)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:DEEPSTING,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next unless user.takesIndirectDamage?
      totalDamageDealt = 0
      targets.each do |target|
          next if target.damageState.unaffected
          totalDamageDealt = target.damageState.totalHPLost
      end
      next if totalDamageDealt <= 0
      amt = (totalDamageDealt / 4.0).round
      amt = 1 if amt < 1
      user.pbReduceHP(amt, false)
      battle.pbDisplay(_INTL("{1} is damaged by recoil!", user.pbThis))
      user.pbItemHPHealCheck
      user.pbFaint if user.fainted?
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HUBRIS,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      user.tryRaiseStat(:SPECIAL_ATTACK, user, increment: numFainted, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.copy(:MOXIE, :CHILLINGNEIGH)

BattleHandlers::UserAbilityEndOfMove.copy(:HUBRIS, :GRIMNEIGH)

BattleHandlers::UserAbilityEndOfMove.add(:SCHADENFREUDE,
  proc { |ability, user, targets, _move, _battle|
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      user.applyFractionalHealing(1.0 / 4.0, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:GILD,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      targets.each do |b|
          next unless b.hasAnyItem?
          next unless move.knockOffItems(user, b, ability: ability) do |itemRemoved, itemName|
            battle.pbDisplay(_INTL("{1} turned {2}'s {3} into gold!", user.pbThis, b.pbThis(true), itemName))
            battle.field.incrementEffect(:PayDay, 5 * user.level) if user.pbOwnedByPlayer?
          end
          break
      end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:DAUNTLESS,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      user.pbRaiseMultipleStatStages([:ATTACK, numFainted, :SPECIAL_ATTACK, numFainted], user, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:CALAMITY,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next unless battle.pbWeather == :Eclipse
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      user.pbRaiseMultipleStatStages([:ATTACK, numFainted, :SPECIAL_ATTACK, numFainted], user, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SPACEINTERLOPER,
  proc { |ability, user, targets, _move, _battle|
    user.pbRecoverHPFromMultiDrain(targets, 0.25, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FOLLOWTHROUGH,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      user.tryRaiseStat(:SPEED, user, increment: numFainted, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SOUNDBARRIER,
  proc { |ability, user, _targets, move, _battle, _switchedBattlers|
      user.tryRaiseStat(:DEFENSE, user, ability: ability) if move.soundMove?
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:WINDBUFFER,
  proc { |ability, user, _targets, move, _battle, _switchedBattlers|
      user.tryRaiseStat(:SPECIAL_DEFENSE, user, ability: ability) if move.windMove?
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SEALORD,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next unless user.species == :GYARADOS
      next unless user.form == 0
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      battle.pbShowAbilitySplash(user, ability)
      user.pbChangeForm(1, _INTL("{1}'s anger cannot be sated! It enters its Hull Breaker form!", user.pbThis))
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:VICTORYMOLT,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      next unless user.pbHasAnyStatus? || user.hasAlteredStatStages?
      battle.pbShowAbilitySplash(user, ability)
      user.pbChangeForm(1, _INTL("{1} molts into a new shell!", user.pbThis))
      battle.pbAnimation(:REFRESH, user, nil)
      user.pbCureStatus(true)
      if user.hasAlteredStatStages?
          battle.pbDisplay(_INTL("{1}'s stat changes were removed!", user.pbThis))
          user.pbResetStatStages
      end
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:POWERLIFTER,
  proc { |ability, user, targets, move, battle, switchedBattlers|
      next if battle.futureSight
      next unless move.physicalMove?
      move.forceOutTargets(user, targets, switchedBattlers, true, false, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FLUSTERFLOCK,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      hitAnything = false
      targets.each do |b|
        next if b.damageState.unaffected
        hitAnything = true
        break
      end
      next unless hitAnything
      battle.pbShowAbilitySplash(user, ability)
      user.applyDizzy(user)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.copy(:FLUSTERFLOCK, :HEADACHE)

BattleHandlers::UserAbilityEndOfMove.add(:GENERATOR,
  proc { |ability, user, _targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next if move.pbDamagingMove?
      battle.pbShowAbilitySplash(user, ability)
      user.applyEffect(:Charge)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HEALINGHOPE,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      battle.forceUseMove(user, :WISH, user.index, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MIDNIGHTOIL,
  proc { |ability, user, _targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next if move.pbDamagingMove?
      next unless battle.pbWeather == :Moonglow
      battle.pbShowAbilitySplash(user, ability)
      battle.extendWeather(1)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ICEQUEEN,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      next unless battle.pbWeather == :Hail
      user.pbRecoverHPFromMultiDrain(targets, 0.50, ability: ability)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ETERNALWINTER,
  proc { |ability, user, targets, _move, battle, _switchedBattlers|
      next if battle.pbAllFainted?(user.idxOpposingSide)
      next unless battle.pbWeather == :Hail
      numFainted = 0
      targets.each { |b| numFainted += 1 if b.damageState.fainted }
      next if numFainted == 0
      battle.pbShowAbilitySplash(user, ability)
      battle.extendWeather(numFainted)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:EROSIONCYCLE,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if move.pbDamagingMove?
      next unless user.pbOwnSide.effectActive?(:ErodedRock)
      rockCount = user.pbOwnSide.countEffect(:ErodedRock)
      battle.pbShowAbilitySplash(user, ability)
      user.pbOwnSide.disableEffect(:ErodedRock)
      user.applyFractionalHealing(rockCount.to_f / 4.0)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FEELTHEBURN,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      next if user.burned?
      hitAnything = false
      targets.each do |b|
        next if b.damageState.unaffected
        hitAnything = true
        break
      end
      next unless hitAnything
      battle.pbShowAbilitySplash(user, ability)
      user.applyBurn(user)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:COLDCALCULATION,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      next if user.frostbitten?
      hitAnything = false
      targets.each do |b|
        next if b.damageState.unaffected
        hitAnything = true
        break
      end
      next unless hitAnything
      battle.pbShowAbilitySplash(user, ability)
      user.applyFrostbite(user)
      battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:IRREFUTABLE,
  proc { |ability, user, targets, move, battle, _switchedBattlers|
      next if battle.futureSight
      next unless move.pbDamagingMove?
      nveHits = 0
      targets.each do |b|
        next if b.damageState.unaffected
        next unless Effectiveness.not_very_effective?(b.damageState.typeMod)
        nveHits += 1
      end
      next unless nveHits > 0
      user.tryRaiseStat(:ATTACK, user, increment: nveHits, ability: ability)
  }
)