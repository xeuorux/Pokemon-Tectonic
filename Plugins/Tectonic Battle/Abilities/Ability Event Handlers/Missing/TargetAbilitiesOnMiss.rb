BattleHandlers::TargetAbilityOnMiss.add(:SPINYRUSE,
  proc { |ability, user, target, move, battle|
    if target.semiInvulnerable?
        target.showMyAbilitySplash(ability)
        if target.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is pierced by spines hidden near {2}!", user.pbThis, target.pbThis(true)))
            user.applyFractionalDamage(1.0/4.0)
        end
        target.hideMyAbilitySplash
    end
  }
)