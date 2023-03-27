BattleHandlers::MoveImmunityAllyAbility.add(:GARGANTUAN,
    proc { |ability, user, target, move, _type, battle, ally, showMessages|
        next false unless move.pbTarget(user).num_targets > 1
        next false unless user.opposes?(target)
        if showMessages
            battle.pbShowAbilitySplash(ally, ability)
            battle.pbDisplay(_INTL("{1} was shielded from {2} by {3}'s huge size!", target.pbThis, move.name,
    ally.pbThis(false)))
            battle.pbHideAbilitySplash(ally)
        end
        next true
    }
)
