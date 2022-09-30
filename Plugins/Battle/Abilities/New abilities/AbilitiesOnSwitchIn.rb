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
    battler.pbOwnSide.effects[PBEffects::LightScreen] = battler.getScreenDuration()
    battle.pbDisplay(_INTL("{1}'s Special Defense is raised!",battler.pbTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BARRIERMAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.effects[PBEffects::Reflect] = battler.getScreenDuration()
    battle.pbDisplay(_INTL("{1}'s Defense is raised!",battler.pbTeam))
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