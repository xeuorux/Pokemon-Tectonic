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
        battle.forceUseMove(target, :DRAGONDANCE, ability: ability)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:EMERGENCYPOWER,
    proc { |ability, target, user, move, _switched, battle|
        battle.forceUseMove(target, :LIGHTNINGDANCE, ability: ability)
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

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:DREAMYHAZE,
    proc { |ability, target, user, move, _switched, battle|
        next unless user.canSleep?(target, true)
        next if user.effectActive?(:Yawn)
        battle.pbShowAbilitySplash(target, ability)
        user.applyEffect(:Yawn, 2)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityKnockedBelowHalf.add(:AROMATIC,
    proc { |ability, target, user, move, _switched, battle|
        battle.forceUseMove(target, :AROMATHERAPY, ability: ability)
    }
)