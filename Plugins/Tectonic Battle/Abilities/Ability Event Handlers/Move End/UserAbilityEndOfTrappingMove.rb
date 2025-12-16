BattleHandlers::UserAbilityEndOfTrappingMove.add(:DENTICLEDEBRIS,
    proc { |ability, user, target, move, battle|
        battle.pbShowAbilitySplash(user, ability)
        side = user.pbOpposingSide
        if side.effectAtMax?(:Spikes)
            battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!"))
            battle.pbHideAbilitySplash(user)
            next
        end
        side.incrementEffect(:Spikes)
        battle.pbAnimation(:SPIKES, user, nil)
        battle.pbDisplay(_INTL("{1} scattered debris that became Spikes!", user.pbThis))
        battle.pbHideAbilitySplash(user)
    }
)