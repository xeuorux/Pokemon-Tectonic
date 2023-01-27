BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |_ability, battler, battle|
      battle.eachOtherSideBattler(battler.index) do |b|
          next if !b.near?(battler) || !b.asleep?
          battle.pbShowAbilitySplash(battler)
          next unless b.takesIndirectDamage?(true)
          battle.pbDisplay(_INTL("{1} is pained by its dreams!", b.pbThis))
          b.applyFractionalDamage(1.0 / 8.0, false)
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |_ability, battler, battle|
      randomUp = []
      randomDown = []
      GameData::Stat.each_main_battle do |s|
          randomUp.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
          randomDown.push(s.id) if battler.pbCanLowerStatStage?(s.id, battler)
      end
      next if randomUp.length == 0 && randomDown.length == 0
      battle.pbShowAbilitySplash(battler)
      if randomUp.length > 0
          r = battle.pbRandom(randomUp.length)
          randomUpStat = randomUp[r]
          battler.tryRaiseStat(randomUpStat, battler, increment: 2)
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

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |_ability, battler, _battle|
      # A Pokémon's turnCount is 0 if it became active after the beginning of a
      # round
      battler.tryRaiseStat(:SPEED, battler, showAbilitySplash: true) if battler.turnCount > 0
  }
)

BattleHandlers::EOREffectAbility.copy(:SPEEDBOOST, :SPINTENSITY)

BattleHandlers::EOREffectAbility.add(:BALLFETCH,
  proc { |_ability, battler, battle|
      if battler.effectActive?(:BallFetch) && battler.item <= 0
          ball = battler.effects[:BallFetch]
          battler.item = ball
          battler.setInitialItem(battler.item)
          PBDebug.log("[Ability triggered] #{battler.pbThis}'s Ball Fetch found #{PBItems.getName(ball)}")
          battle.pbShowAbilitySplash(battler)
          battle.pbDisplay(_INTL("{1} found a {2}!", battler.pbThis, PBItems.getName(ball)))
          battler.disableEffect(:BallFetch)
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:HUNGERSWITCH,
  proc { |_ability, battler, battle|
      if battler.species == :MORPEKO
          battle.pbShowAbilitySplash(battler)
          battler.form = (battler.form == 0) ? 1 : 0
          battler.pbUpdate(true)
          battle.scene.pbChangePokemon(battler, battler.pokemon)
          battle.pbDisplay(_INTL("{1} transformed!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::EOREffectAbility.add(:ASTRALBODY,
  proc { |_ability, battler, battle|
      next unless battle.field.terrain == :Fairy
      healingMessage = battle.pbDisplay(_INTL("{1} absorbs magic from the fae mist.", battler.pbThis))
      battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true, customMessage: healingMessage)
  }
)

BattleHandlers::EOREffectAbility.add(:LUXURYTASTE,
  proc { |_ability, battler, battle|
      next unless battler.hasActiveItem?(CLOTHING_ITEMS)
      healingMessage = battle.pbDisplay(_INTL("{1} luxuriated in its fine clothing.", battler.pbThis))
      battler.applyFractionalHealing(1.0 / 8.0, showAbilitySplash: true, customMessage: healingMessage)
  }
)

BattleHandlers::EOREffectAbility.add(:WARMTHCYCLE,
  proc { |_ability, battler, battle|
      battle.pbShowAbilitySplash(battler)
      if !battler.statStageAtMax?(:SPEED)
          if battler.tryRaiseStat(:SPEED, battler, increment: 2)
              battler.applyFractionalDamage(1.0 / 8.0, false)
              battle.pbDisplay(_INTL("{1} warmed up!", battler.pbThis))
          end
      else
          battle.pbDisplay(_INTL("{1} vents its accumulated heat!", battler.pbThis))
          battler.tryLowerStat(:SPEED, battler, increment: 6)
          battler.pbRecoverHP(battler.totalhp - battler.hp)
      end

      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:EXTREMEHEAT,
  proc { |_ability, battler, battle|
      battle.pbShowAbilitySplash(battler)
      battler.applyFractionalDamage(1.0 / 10.0, false)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EOREffectAbility.add(:TENDERIZE,
  proc { |_ability, battler, _battle|
      battler.eachOther do |b|
          next unless b.numbed?
          b.pbLowerMultipleStatStages([:DEFENSE, 1, :SPECIAL_DEFENSE, 1], battler, showAbilitySplash: true)
      end
  }
)
