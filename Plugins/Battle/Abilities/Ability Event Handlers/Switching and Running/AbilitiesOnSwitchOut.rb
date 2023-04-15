BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability, battler, endOfBattle, _battle = nil|
      next if endOfBattle
      battler.pbRecoverHP(battler.totalhp / 3.0, false, false, false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability, battler, _endOfBattle|
      battler.pbCureStatus(false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:FLYBY,
  proc { |ability, battler, battle, endOfBattle|
      next if endOfBattle
      battle.forceUseMove(battler, :GUST, -1, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REFUGE,
  proc { |ability, battler, battle, endOfBattle|
      next if endOfBattle
      battler.position.applyEffect(:Refuge, battler.pokemonIndex)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:POORCONDUCT,
  proc { |ability, battler, battle, endOfBattle|
      next if endOfBattle
      battle.pbShowAbilitySplash(battler, ability)
      battle.eachOtherSideBattler(battler.index) do |b|
          next unless b.near?(battler)
          b.pbLowerMultipleStatStages([:ATTACK,1,:SPECIAL_ATTACK,1],battler,showFailMsg: true)
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:INFINITESOURCE,
  proc { |ability, battler, battle, endOfBattle|
      next if endOfBattle
      battler.position.applyEffect(:InfiniteSource, battler.pokemonIndex)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:MOTHBURGLAR,
  proc { |ability, battler, battle, endOfBattle|
      next if endOfBattle
      battle.forceUseMove(battler, :THIEF, -1, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:KLUMSYKINESIS,
  proc { |ability, battler, battle, endOfBattle|
      next if endOfBattle
      next unless battler.losableItemCount > 0
      battle.pbShowAbilitySplash(battler,ability)
      if battler.losableItemCount == 1
          chosenItem = battler.loseableItems[0]
      elsif battler.losableItemCount > 1
          if battle.autoTesting
              chosenItem = battler.loseableItems.sample
          elsif !battler.pbOwnedByPlayer? # Trainer AI
              chosenItem = battler.loseableItems[0]
          else
              itemNames = []
              battler.loseableItems.each do |itemID|
                  itemNames.push(getItemName(itemID))
              end
              chosenIndex = battle.scene.pbShowCommands(_INTL("Which item should #{battler.pbThis(true)} drop?"),itemNames,0)
              chosenItem = battler.loseableItems[chosenIndex]
          end
      end
      battler.removeItem(chosenItem)
      battle.pbDisplay(_INTL("{1} dropped its {2}!",battler.pbThis,getItemName(chosenItem)))
      battle.pbHideAbilitySplash(battler)
  }
)