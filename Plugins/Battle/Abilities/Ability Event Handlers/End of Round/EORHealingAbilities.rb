BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
    proc { |_ability, battler, battle|
        next unless battler.poisoned? || battler.burned? || battler.numbed? || battler.frostbitten? || battler.leeched?
        battle.pbShowAbilitySplash(battler)
        battler.pbCureStatus(true, :BURN)
        battler.pbCureStatus(true, :FROSTBITE)
        battler.pbCureStatus(true, :POISON)
        battler.pbCureStatus(true, :NUMB)
        battler.pbCureStatus(true, :LEECHED)
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
    proc { |_ability, battler, battle|
        next unless battler.hasAnyStatusNoTrigger
        next unless battle.rainy?
        battle.pbShowAbilitySplash(battler)
        battler.pbCureStatus
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::EORHealingAbility.add(:HEALER,
    proc { |_ability, battler, battle|
        battler.eachAlly do |b|
            next unless b.hasAnyStatusNoTrigger
            battle.pbShowAbilitySplash(battler)
            b.pbCureStatus
            battle.pbHideAbilitySplash(battler)
        end
    }
)

BattleHandlers::EORHealingAbility.add(:OXYGENATION,
    proc { |_ability, battler, battle|
        next unless battler.hasAnyStatusNoTrigger
        next unless battle.sunny?
        battle.pbShowAbilitySplash(battler)
        battler.pbCureStatus
        battle.pbHideAbilitySplash(battler)
    }
)