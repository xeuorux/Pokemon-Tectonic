BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::SlowStart] = 3
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} can't get it going!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASONEICE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has 2 Abilities!",battler.name))
    battle.pbShowAbilitySplash(battler,false,true,PBAbilities.getName(getID(PBAbilities,:UNNERVE)))
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ASONEICE,:ASONEGHOST)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:ATTACK,1,battler)
  }
)	

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:DEFENSE,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability,battler,battle|
    target=battler
    battle.pbShowAbilitySplash(battler)
    battle.sides.each do |side|
      side.eachEffectWithData(true) do |effect,value,effectData|
        next if !effectData.is_screen?
        side.disableEffect(effect)
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability,battler,battle|
    battler.eachAlly do |b|
      next if b.status != :POISON
      battle.pbShowAbilitySplash(battler)
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured its {3}'s poison!",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability,battler,battle|
    done= false
    battler.eachAlly do |b|
      next if !b.hasAlteredStatStages?
      b.pbResetStatStages
      done = true
    end
    if done
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("All allies' stat changes were eliminated!"))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability,battler,battle|
    next if battle.field.effects[PBEffects::NeutralizingGas]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s gas nullified all abilities!",battler.pbThis))
    battle.field.effects[PBEffects::NeutralizingGas] = true
    battle.pbHideAbilitySplash(battler)
  }
)

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
    duration = battler.getScreenDuration()
    battler.pbOwnSide.applyEffect(:LightScreen,duration)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BARRIERMAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    duration = battler.getScreenDuration()
    battler.pbOwnSide.applyEffect(:Reflect,duration)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MYSTICAURA,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::MagicRoom]==0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::MagicRoom] = battler.getRoomDuration()
		battle.pbDisplay(_INTL("{1}'s aura creates a {2}!",battler.pbThis,MAGIC_ROOM_DESCRIPTION))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PUZZLINGAURA,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::PuzzleRoom] == 0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::PuzzleRoom] = battler.getRoomDuration()
		battle.pbDisplay(_INTL("{1}'s aura creates a {2}!",battler.pbThis,PUZZLE_ROOM_DESCRIPTION))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TRICKSTER,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::TrickRoom]==0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::TrickRoom] = battler.getRoomDuration()
		battle.pbDisplay(_INTL("{1} pulls a trick. It creates a {2}!",battler.pbThis, TRICK_ROOM_DESCRIPTION))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ODDAURA,
  proc { |ability,battler,battle|
	if battle.field.effects[PBEffects::OddRoom] == 0
		battle.pbShowAbilitySplash(battler)
		battle.field.effects[PBEffects::OddRoom] = battler.getRoomDuration()
		battle.pbDisplay(_INTL("{1}'s aura creates an {2}!",battler.pbThis, ODD_ROOM_DESCRIPTION))
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GARLANDGUARDIAN,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::Safeguard] = 5
    battle.pbDisplay(_INTL("{1} put up a Safeguard!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FREERIDE,
  proc { |ability,battler,battle|
    next if !battler.hasAlly?
    battle.pbShowAbilitySplash(battler)
    battler.eachAlly do |b|
		  b.pbRaiseStatStage(:SPEED,1,battler) 
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

BattleHandlers::AbilityOnSwitchIn.add(:AQUASNEAK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} snuck into the water!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CONVICTION,
  proc { |ability,battler,battle|
    battle.forceUseMove(battler,:ENDURE,battler,true,nil,nil,true)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:FAIRYSURGE,:MISTYSURGE)

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