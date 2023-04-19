BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |ability, battler, battle|
      battle.eachOtherSideBattler(battler.index) do |b|
          next if !b.near?(battler) || !b.asleep?
          battle.pbShowAbilitySplash(battler, ability)
          next unless b.takesIndirectDamage?(true)
          battle.pbDisplay(_INTL("{1} is pained by its dreams!", b.pbThis))
          b.applyFractionalDamage(1.0 / 8.0, false)
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |ability, battler, battle|
      randomUp = []
      randomDown = []
      GameData::Stat.each_main_battle do |s|
          randomUp.push(s.id) if battler.pbCanRaiseStatStep?(s.id, battler)
          randomDown.push(s.id) if battler.pbCanLowerStatStep?(s.id, battler)
      end
      next if randomUp.length == 0 && randomDown.length == 0
      battle.pbShowAbilitySplash(battler, ability)
      if randomUp.length > 0
          r = battle.pbRandom(randomUp.length)
          randomUpStat = randomUp[r]
          battler.tryRaiseStat(randomUpStat, battler, increment: 3)
          randomDown.delete(randomUp[r])
      end
      if randomDown.length > 0
          r = battle.pbRandom(randomDown.length)
          randomDownStat = randomDown[r]
          battler.tryLowerStat(randomDownStat, battler)
      end
      battle.pbHideAbilitySplash(battler)
      battler.pbItemStatRestoreCheck if randomDown.length > 0
  }
)

BattleHandlers::EOREffectAbility.add(:PERSISTENTGROWTH,
  proc { |ability, battler, battle|
      next unless battler.turnCount > 0
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbRaiseMultipleStatSteps([:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1], battler)
      battler.tryLowerStat(:SPEED, battler)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |ability, battler, _battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      battler.tryRaiseStat(:SPEED, battler, ability: ability, increment: 2) if battler.turnCount > 0
  }
)

BattleHandlers::EOREffectAbility.add(:SPINTENSITY,
  proc { |ability, battler, _battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      battler.tryRaiseStat(:SPEED, battler, ability: ability) if battler.turnCount > 0
  }
)

BattleHandlers::EOREffectAbility.add(:BALLFETCH,
  proc { |ability, battler, battle|
      if battler.effectActive?(:BallFetch) && battler.item <= 0
          ball = battler.effects[:BallFetch]
          battler.item = ball
          battler.setInitialItem(battler.item)

          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1} found a {2}!", battler.pbThis, PBItems.getName(ball)))
          battler.disableEffect(:BallFetch)
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:HUNGERSWITCH,
  proc { |ability, battler, battle|
      if battler.species == :MORPEKO
          battle.pbShowAbilitySplash(battler, ability)
          battler.form = (battler.form == 0) ? 1 : 0
          battler.pbUpdate(true)
          battle.scene.pbChangePokemon(battler, battler.pokemon)
          battle.pbDisplay(_INTL("{1} transformed!", battler.pbThis))
          battler.refreshDataBox
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:LUXURYTASTE,
  proc { |ability, battler, battle|
      next unless battler.hasActiveItem?(CLOTHING_ITEMS)
      healingMessage = _INTL("{1} luxuriated in its fine clothing.", battler.pbThis)
      battler.applyFractionalHealing(1.0 / 8.0, ability: ability, customMessage: healingMessage)
  }
)

BattleHandlers::EOREffectAbility.add(:WARMTHCYCLE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      if !battler.statStepAtMax?(:SPEED)
          if battler.tryRaiseStat(:SPEED, battler, increment: 3)
              battler.applyFractionalDamage(1.0 / 8.0, false)
              battle.pbDisplay(_INTL("{1} warmed up!", battler.pbThis))
          end
      else
          battle.pbDisplay(_INTL("{1} vents its accumulated heat!", battler.pbThis))
          battler.steps[:SPEED] = 0
          battler.pbRecoverHP(battler.totalhp - battler.hp)
      end

      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:EXTREMEPOWER,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyFractionalDamage(1.0 / 10.0, false)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.copy(:EXTREMEPOWER,:EXTREMEENERGY)

BattleHandlers::EOREffectAbility.add(:TENDERIZE,
  proc { |ability, battler, _battle|
      battler.eachOther do |b|
          next unless b.numbed?
          b.pbLowerMultipleStatSteps(DEFENDING_STATS_2, battler, ability: ability)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:LIVINGARMOR,
  proc { |ability, battler, battle|
      battler.applyFractionalHealing(1.0 / 10.0, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:VITALRHYTHM,
  proc { |ability, battler, battle|
      canHealAny = false
      battler.eachAlly do |b|
        canHealAny = true if b.canHeal?
      end
      next unless canHealAny
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyFractionalHealing(1.0 / 16.0)
      battler.eachAlly do |b|
        b.applyFractionalHealing(1.0 / 16.0)
      end
      battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::EOREffectAbility.add(:GROWUP,
  proc { |ability, battler, battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      next if battler.turnCount == 0
      next unless %i[PUMPKABOO GOURGEIST].include?(battler.species)
      next if battler.form == 3
      battle.pbShowAbilitySplash(battler, ability)
      formChangeMessage = _INTL("#{battler.pbThis} grows one size bigger!")
      battler.pbChangeForm(battler.form + 1, formChangeMessage)
      battle.pbDisplay(_INTL("#{battler.pbThis} is fully grown!")) if battler.form == 3
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:FIGHTINGVIGOR,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(1.0 / 12.0, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:GROTESQUEVITALS,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(1.0 / 12.0, ability: ability)
  }
)

BattleHandlers::EOREffectAbility.add(:WELLSUPPLIED,
  proc { |ability, battler, _battle|
      battler.applyFractionalHealing(1.0 / 12.0, ability: ability)
  }
)