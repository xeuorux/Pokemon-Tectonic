BattleHandlers::PreventAddedEffectTargetAbility.add(:SHIELDDUST,
    proc { |ability, battle, user, target, move, showMessages|
        if showMessages
            battle.pbShowAbilitySplash(target,ability)
            battle.pbDisplay(_INTL("#{target.pbThis} prevents a random added effect!"))
            battle.pbHideAbilitySplash(target)
        end
        next true
    }
)

BattleHandlers::PreventAddedEffectTargetAbility.copy(:SHIELDDUST,:UNCONQUERABLE,:RUGGEDSCALES)
