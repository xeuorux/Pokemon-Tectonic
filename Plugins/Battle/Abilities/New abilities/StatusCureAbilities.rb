#===============================================================================
# StatusCureAbility handlers
#===============================================================================
BattleHandlers::StatusCureAbility.add(:IMMUNITY,
  proc { |ability,battler|
    next if !battler.hasStatusNoTrigger(:POISON)
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(true,:POISON)
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:INSOMNIA,
  proc { |ability,battler|
    next if !battler.hasStatusNoTrigger(:SLEEP)
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(true,:SLEEP)
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:INSOMNIA,:VITALSPIRIT)

BattleHandlers::StatusCureAbility.add(:LIMBER,
  proc { |ability,battler|
    next if !battler.hasStatusNoTrigger(:SLEEP)
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(true,:PARALYSIS)
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OWNTEMPO,
  proc { |ability,battler|
    if battler.effects[PBEffects::Confusion]!=0
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureConfusion
		battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::Charm]!=0
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureCharm
		battler.battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis))
		battler.battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::StatusCureAbility.add(:WATERVEIL,
  proc { |ability,battler|
    next if !battler.hasStatusNoTrigger(:BURN)
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(true,:BURN)
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:WATERVEIL,:WATERBUBBLE)

BattleHandlers::StatusCureAbility.add(:MENTALBLOCK,
  proc { |ability,battler|
		battle = battler.battle
    if battler.effects[PBEffects::Confusion]!=0
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureConfusion
		battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::Charm]!=0
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureCharm
		battle.pbDisplay(_INTL("{1} was released from the charm.",battler.pbThis))
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::Taunt]  > 0
		battler.battle.pbShowAbilitySplash(battler)
		battle.pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis)) if battler.effects[PBEffects::Taunt]>0
		battler.effects[PBEffects::Taunt]      = 0
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::Encore] > 0
		battler.battle.pbShowAbilitySplash(battler)
		battle.pbDisplay(_INTL("{1}'s encore ended!",battler.pbThis)) if battler.effects[PBEffects::Encore]>0
		battler.effects[PBEffects::Encore]     = 0
		battler.effects[PBEffects::EncoreMove] = nil
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::Torment]
		battler.battle.pbShowAbilitySplash(battler)
		battle.pbDisplay(_INTL("{1}'s torment wore off!",battler.pbThis)) if battler.effects[PBEffects::Torment]
		battler.effects[PBEffects::Torment]    = false
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::Disable] > 0
		battler.battle.pbShowAbilitySplash(battler)
		battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis)) if battler.effects[PBEffects::Disable]>0
		battler.effects[PBEffects::Disable]    = 0
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.effects[PBEffects::HealBlock] > 0
		battler.battle.pbShowAbilitySplash(battler)
		battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis)) if battler.effects[PBEffects::HealBlock]>0
		battler.effects[PBEffects::HealBlock]  = 0
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.flustered?
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:FLUSTERED)
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.mystified?
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:MYSTIFIED)
		battler.battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::StatusCureAbility.add(:ENERGETIC,
  proc { |ability,battler|
	if battler.hasStatusNoTrigger(:POISON)
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:POISON)
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.hasStatusNoTrigger(:PARALYSIS)
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:PARALYSIS)
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.hasStatusNoTrigger(:FROZEN)
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:FROZEN)
		battler.battle.pbHideAbilitySplash(battler)
	end
  }	
)

BattleHandlers::StatusCureAbility.add(:STABILITY,
  proc { |ability,battler|
	if battler.hasStatusNoTrigger(:POISON)
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:POISON)
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.hasStatusNoTrigger(:BURN)
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:BURN)
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.hasStatusNoTrigger(:FROSTBITE)
		battler.battle.pbShowAbilitySplash(battler)
		battler.pbCureStatus(true,:FROSTBITE)
		battler.battle.pbHideAbilitySplash(battler)
	end
  }	
)