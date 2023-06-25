BattleHandlers::TargetAbilityKnockedBelowHalf.add(:VENGEANCE,
    proc { |ability, target, user, move, _switched, battle|
        battle.pbShowAbilitySplash(target, ability)
        user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:BRILLIANTFLURRY,
    proc { |ability, target, user, move, _switched, _battle|
        user.pbLowerMultipleStatSteps(ALL_STATS_1, target, ability: ability)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:STICKYMOLD,
    proc { |ability, target, user, move, _switched, battle|
        next if user.leeched?
        battle.pbShowAbilitySplash(target, ability)
        user.applyLeeched(target) if user.canLeech?(target, true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:WRATHINSTINCT,
    proc { |ability, target, user, move, _switched, battle|
        battle.forceUseMove(target, :DRAGONDANCE, user.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:BATTERYBREAK,
    proc { |ability, target, user, move, _switched, battle|
        battle.forceUseMove(target, :LIGHTNINGDANCE, user.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:MALICE,
    proc { |ability, target, user, move, _switched, battle|
        next if user.effectActive?(:Curse)
        battle.pbShowAbilitySplash(target, ability)
        user.applyEffect(:Curse)
        battle.pbHideAbilitySplash(target)
    }
)