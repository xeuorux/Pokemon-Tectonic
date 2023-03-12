BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
    proc { |_ability, battler, user, status|
        next if !user || user.index == battler.index
        next unless user.pbCanSynchronizeStatus?(status, battler)
        case status
        when :POISON
            battler.battle.pbShowAbilitySplash(battler)
            user.applyPoison(battler)
            battler.battle.pbHideAbilitySplash(battler)
        when :BURN
            battler.battle.pbShowAbilitySplash(battler)
            user.applyBurn(battler)
            battler.battle.pbHideAbilitySplash(battler)
        when :NUMB
            battler.battle.pbShowAbilitySplash(battler)
            user.applyNumb(battler)
            battler.battle.pbHideAbilitySplash(battler)
        when :FROSTBITE
            battler.battle.pbShowAbilitySplash(battler)
            user.applyFrostbite(battler)
            battler.battle.pbHideAbilitySplash(battler)
        end
    }
)
