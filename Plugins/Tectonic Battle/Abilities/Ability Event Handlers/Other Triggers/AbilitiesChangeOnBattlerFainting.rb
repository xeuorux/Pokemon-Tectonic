BattleHandlers::AbilityChangeOnBattlerFainting.add(:POWEROFALCHEMY,
    proc { |ability, battler, fainted, battle|
        next if battler.opposes?(fainted)

        fainted.eachAbility do |abilityID|
            next if GameData::Ability.get(abilityID).is_uncopyable_ability?
            battler.addAbility(abilityID, true)
        end
    }
)

BattleHandlers::AbilityChangeOnBattlerFainting.add(:ALLCONSUMING,
    proc { |ability, battler, fainted, battle|
        battler.showMyAbilitySplash(ability)
        
        fainted.eachItemWithName do |item, itemName|
            next if fainted.unlosableItem?(item)
            fainted.removeItem(item)
            battle.pbDisplay(_INTL("{1} ate {2}'s {3}!", battler.pbThis, fainted.pbThis, itemName))
            battler.pbHeldItemTriggerCheck(item, false)
        end

        fainted.eachAbility do |abilityID|
            next if GameData::Ability.get(abilityID).is_uncopyable_ability?
            battler.addAbility(abilityID, true)
        end

        GameData::Stat.each_main_battle do |s|
            statValue = battler.steps[s.id]
            next if statValue == 0
            if statValue > 0
                battler.tryLowerStat(s.id, battler, increment: statValue)
            end
            if statValue < 0
                battler.tryLowerStat(s.id, battler, increment: statValue)
            end
        end

        battler.hideMyAbilitySplash
    }
)