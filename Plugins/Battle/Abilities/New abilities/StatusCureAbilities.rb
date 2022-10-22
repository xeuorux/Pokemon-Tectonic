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
    if battler.confused?
		battler.battle.pbShowAbilitySplash(battler)
		battler.disableEffect(:Charm)
		battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
		battler.battle.pbHideAbilitySplash(battler)
	end
	if battler.charmed?
		battler.battle.pbShowAbilitySplash(battler)
		battler.disableEffect(:Charm)
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

	activate = false
	battler.eachEffectWithData(true) do |effect,value,data|
		next if !data.is_mental?
		activate = true
		break
	end
	activate = true if battler.flustered? || battler.mystified?

	if activate
		battle.pbShowAbilitySplash(battler)
		# Disable all mental effects
		battler.eachEffectWithData(true) do |effect,value,data|
			next if !data.is_mental?
			battler.disableEffect(effect)
		end
		battler.pbCureStatus(true,:FLUSTERED) if battler.flustered?
		battler.pbCureStatus(true,:MYSTIFIED) if battler.mystified?
		battle.pbHideAbilitySplash(battler)
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