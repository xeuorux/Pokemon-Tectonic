BattleHandlers::TargetAbilityStartOfMove.add(:NEEDLEFUR,
  proc { |ability, user, target, move, battle|
    next unless move.damagingMove?
    battle.pbShowAbilitySplash(target, ability)
    if user.takesIndirectDamage?(true)
        battle.scene.pbDamageAnimation(user)
        upgradedNeedleFur = target.hp < target.totalhp / 2
        reduction = user.totalhp / 10
        reduction *= user.hpBasedEffectResistance if user.boss?
        reduction *= 2 if upgradedNeedleFur
        oldHP = user.hp
        user.pbReduceHP(reduction, false)
        if upgradedNeedleFur
            battle.pbDisplay(_INTL("{1}'s fur is standing sharp! {2} is hurt!", target.pbThis, user.pbThis))
        else
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
        end
        user.cleanupPreMoveDamage(user, oldHP)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityStartOfMove.add(:PRESSUREVALVE,
  proc { |ability, user, target, move, battle|
    next unless move.damagingMove?
    battle.pbShowAbilitySplash(target, ability)
    user.pbResetStatSteps
    battle.pbDisplay(_INTL("{1}'s stat changes were eliminated!", user.pbThis))
    battle.pbHideAbilitySplash(target)
  }
)