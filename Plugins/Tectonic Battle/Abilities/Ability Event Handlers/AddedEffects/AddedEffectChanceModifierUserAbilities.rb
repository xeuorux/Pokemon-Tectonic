BattleHandlers::AddedEffectChanceModifierUserAbility.add(:FUMIGATE,
    proc { |ability, user, target, move, chance|
        chance += 50 if move.windMove?
        next chance
    }
)

BattleHandlers::AddedEffectChanceModifierUserAbility.add(:GNAWING,
    proc { |ability, user, target, move, chance|
        chance += 50 if move.bitingMove?
        next chance
    }
)

BattleHandlers::AddedEffectChanceModifierUserAbility.add(:RATTLEEM,
    proc { |ability, user, target, move, chance|
        chance *= 1.5 if move.flinchingMove?
        next chance
    }
)

BattleHandlers::AddedEffectChanceModifierUserAbility.add(:TERRORIZE,
    proc { |ability, user, target, move, chance|
        chance *= 2.0 if move.flinchingMove?
        next chance
    }
)

BattleHandlers::AddedEffectChanceModifierUserAbility.add(:SERENEGRACE,
    proc { |ability, user, target, move, chance|
        chance *= 2.0
        next chance
    }
)