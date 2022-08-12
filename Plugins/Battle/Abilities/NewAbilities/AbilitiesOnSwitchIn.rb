BattleHandlers::AbilityOnSwitchIn.add(:FASCINATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpecialAttackStatStageFascinate(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRUSTRATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerSpeedStatStageFrustrate(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HOLIDAYCHEER,
  proc { |ability,battler,battle|
    anyHealing = false
    battle.eachSameSideBattler(battler.index) do |b|
      anyHealing = true if b.hp < b.totalhp
    end
    if anyHealing
      battle.pbShowAbilitySplash(battler)
      battle.eachSameSideBattler(battler.index) do |b|
        b.pbRecoverHP(b.totalhp*0.25)
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:STARGUARDIAN,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::LightScreen] = 5
    battler.pbOwnSide.effects[PBEffects::LightScreen] = 8 if battler.hasActiveItem?(:LIGHTCLAY)
    battle.pbDisplay(_INTL("{1} put up a Light Screen!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BARRIERMAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::Reflect] = 5
    battler.pbOwnSide.effects[PBEffects::Reflect] = 8 if battler.hasActiveItem?(:LIGHTCLAY)
    battle.pbDisplay(_INTL("{1} put up a Reflect!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MYSTICAURA,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::MagicRoom]==0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::MagicRoom] = getRoomDuration(battler)
		battle.pbDisplay(_INTL("{1}'s aura creates a bizarre area in which Pokemon's held items lose their effects!",battler.pbThis))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PUZZLINGAURA,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::PuzzleRoom] == 0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::PuzzleRoom] = getRoomDuration(battler)
		battle.pbDisplay(_INTL("{1}'s aura creates a puzzling area in which Pokemon's Attack and Sp. Atk are swapped!",battler.pbThis))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TRICKSTER,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::TrickRoom]==0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::TrickRoom] = getRoomDuration(battler)
		battle.pbDisplay(_INTL("{1} twisted the dimensions! Speed now functions in reverse!",battler.pbThis))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GARLANDGUARDIAN,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::Safeguard] = 5
##battler.pbOwnSide.effects[PBEffects::Safeguard] = 8 if battler.hasActiveItem?(:LIGHTCLAY) if we want to have light clay affect this, uncomment    
    battle.pbDisplay(_INTL("{1} put up a Safeguard!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FREERIDE,
  proc { |ability,battler,battle|
	done= false
	battler.eachAlly do |b|
	    battle.pbShowAbilitySplash(battler) ##for each ally it will display the ability as it raises the speed, done like this so that it has no effect in 1v1
		b.pbRaiseStatStage(:SPEED,1,b) 
		next
		end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EARTHLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} has {2}!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("The effects of the terrain disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:RUINOUS,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is ruinous! Everyone deals 20 percent more damage!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HONORAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is honorable! Status moves lose priority!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CLOVERSONG,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::LuckyChant] = 5
    battle.pbDisplay(_INTL("{1} sung a Lucky Chant!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SWARMCALL,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Swarm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:POLLUTION,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:AcidRain, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ARCANEFINALE,
  proc { |ability,battler,battle|
    next if !battler.isLastAlive?
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is the team's finale!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HEROICFINALE,
  proc { |ability,battler,battle|
    next if !battler.isLastAlive?
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is the team's finale!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ONTHEWIND,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::Tailwind] = 4
    battle.pbDisplay(_INTL("{1} flew in on a tailwind!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)