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
    battler.pbCureStatus(true,:SLEEP)
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:COLDPROOF,
  proc { |ability,battler|
    next if !battler.hasStatusNoTrigger(:FROZEN)
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(true,:FROZEN)
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