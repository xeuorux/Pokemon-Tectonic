BattleHandlers::AbilityChangeOnBattlerFainting.add(:POWEROFALCHEMY,
    proc { |_ability, battler, fainted, battle|
        next if battler.opposes?(fainted)
        next if fainted.ungainableAbility? ||
           %i[POWEROFALCHEMY RECEIVER TRACE WONDERGUARD].include?(fainted.ability_id)
        battle.pbShowAbilitySplash(battler, true)
        battler.ability = fainted.ability
        battle.pbReplaceAbilitySplash(battler)
        battle.pbDisplay(_INTL("{1}'s {2} was taken over!", fainted.pbThis, fainted.abilityName))
        battle.pbHideAbilitySplash(battler)
    }
)

BattleHandlers::AbilityChangeOnBattlerFainting.copy(:POWEROFALCHEMY, :RECEIVER)
