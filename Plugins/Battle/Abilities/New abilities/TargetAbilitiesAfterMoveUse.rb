class PokeBattle_Battler
    def knockedBelowHalf?
        return @damageState.initialHP >= @totalhp/2 && @hp < @totalhp/2
    end
end

BattleHandlers::TargetAbilityAfterMoveUse.add(:ADRENALINERUSH,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
	target.pbRaiseStatStageByAbility(:SPEED,2,target) if target.pbCanRaiseStatStage?(:SPEED,target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:VENGEANCE,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.applyFractionalDamage(1.0/4.0)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:BRILLIANTFLURRY,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    next if !user.pbCanLowerStatStage?(:ATTACK,target) && !user.pbCanLowerStatStage?(:SPECIAL_ATTACK,target) && !user.pbCanLowerStatStage?(:SPEED,target)
    battle.pbShowAbilitySplash(target)
    if user.pbCanLowerStatStage?(:ATTACK,target,nil,true)
      user.pbLowerStatStage(:ATTACK,1,target)
    end
    if user.pbCanLowerStatStage?(:SPECIAL_ATTACK,target,nil,true)
      user.pbLowerStatStage(:SPECIAL_ATTACK,1,target)
    end
    if user.pbCanLowerStatStage?(:SPEED,target,nil,true)
      user.pbLowerStatStage(:SPEED,1,target)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:BOULDERNEST,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if !target.knockedBelowHalf?
    battle.pbShowAbilitySplash(target)
	  if target.pbOpposingSide.effectActive?(:StealthRock)
        battle.pbDisplay(_INTL("But there were already pointed stones floating around {1}!",target.pbOpposingTeam(true)))
    else
        target.pbOpposingSide.applyEffect(:StealthRock)
    end
    battle.pbHideAbilitySplash(target)
  }
)