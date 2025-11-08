BattleHandlers::UserAbilityEndOfTrappingMove.add(:DENTICLEDEBRIS,
    proc { |ability, user, target, move, battle|
        battle.pbShowAbilitySplash(user, ability)
        side = user.pbOpposingSide
        next if side.effectAtMax?(:Spikes)
        side.incrementEffect(:Spikes)
        battle.pbDisplay(_INTL("{1} scattered debris that became Spikes!", user.pbThis))
        battle.pbHideAbilitySplash(user)
    }
)