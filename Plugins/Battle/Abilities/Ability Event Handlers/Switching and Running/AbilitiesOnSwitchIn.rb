BattleHandlers::AbilityOnSwitchIn.add(:AIRLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:AIRLOCK,:CLOUDNINE)

BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    type1 = battlerTypes[0]
    type2 = battlerTypes[1] || type1
    type3 = battlerTypes[2] || type2
    found = false
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        next if m.statusMove?
        if type1
          moveType = m.type
          if m.function == "090"   # Hidden Power
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = Effectiveness.calculate(moveType,type1,type2,type3)
          next if Effectiveness.ineffective?(eff)
          next if !Effectiveness.super_effective?(eff) && m.function != "070"   # OHKO
        else
          next if m.function != "070"   # OHKO
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AURABREAK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DARKAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DELTASTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:StrongWinds, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESOLATELAND,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HarshSun, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNLOAD,
  proc { |ability,battler,battle|
    oDef = oSpDef = 0
    battle.eachOtherSideBattler(battler.index) do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef<oSpDef) ? :ATTACK : :SPECIAL_ATTACK
    battler.tryRaiseStat(stat,battler,showAbilitySplash: true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRIZZLE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Rain, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DROUGHT,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sun, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        power = m.baseDamage
        power = 160 if ["070"].include?(m.function)    # OHKO
        power = 150 if ["08B"].include?(m.function)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(m.function)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(m.function)
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      battle.pbDisplay(_INTL("{1} was alerted to {2}!", battler.pbThis, forewarnMoveName))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item
    end
    if foes.length>0
      battle.pbShowAbilitySplash(battler)
      foes.each do |b|
        battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
            battler.pbThis,b.pbThis(true),b.itemName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.transformed?
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if choice.transformed? ||
            choice.illusion? ||
            choice.substituted? ||
            choice.effectActive?(:SkyDrop) ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(:TRANSFORM,battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTIMIDATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerAttackStatStageIntimidate(battler)
      b.pbItemOnIntimidatedCheck
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOLDBREAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} breaks the mold!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRESSURE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is exerting its pressure!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HeavyRain, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDSTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sandstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SNOWWARNING,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Hail, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TERAVOLT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TURBOBLAZE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UNNERVE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries or Leftovers!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.applyEffect(:SlowStart,3)
    battle.pbDisplay(_INTL("{1} can't get it going!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASONEICE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has 2 Abilities!",battler.name))
    battle.pbShowAbilitySplash(battler,false,true,GameData::Ability.get(:UNNERVE).name)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries or Leftovers!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ASONEICE,:ASONEGHOST)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability,battler,battle|
    battler.tryRaiseStat(:ATTACK,battler,showAbilitySplash: true)
  }
)	

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability,battler,battle|
    battler.tryRaiseStat(:DEFENSE,battler,showAbilitySplash: true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability,battler,battle|
    anyScreen = false
    battle.sides.each do |side|
      side.eachEffect(true) do |effect,value,effectData|
        next if !effectData.is_screen?
        anyScreen = true
        break
      end
      break if anyScreen
    end
    next unless anyScreen
    
    battle.pbShowAbilitySplash(battler)
    battle.sides.each do |side|
      side.eachEffect(true) do |effect,value,effectData|
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
      b.pbCureStatus(true)
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
    next if battle.field.effectActive?(:NeutralizingGas)
    battle.pbShowAbilitySplash(battler)
    battle.field.applyEffect(:NeutralizingGas)
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

##########################################
# Screen setting abilities
##########################################

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

##########################################
# Room setting abilities
##########################################

BattleHandlers::AbilityOnSwitchIn.add(:MYSTICAURA,
  proc { |ability,battler,battle|
	unless battle.field.effectActive?(:MagicRoom)
		battle.pbShowAbilitySplash(battler)
		battle.field.applyEffect(:MagicRoom,battler.getRoomDuration())
		battle.pbHideAbilitySplash(battler)
	end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PUZZLINGAURA,
  proc { |ability,battler,battle|
    unless battle.field.effectActive?(:PuzzleRoom)
      battle.pbShowAbilitySplash(battler)
      battle.field.applyEffect(:PuzzleRoom,battler.getRoomDuration())
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TRICKSTER,
  proc { |ability,battler,battle|
    unless battle.field.effectActive?(:TrickRoom)
      battle.pbShowAbilitySplash(battler)
      battle.field.applyEffect(:TrickRoom,battler.getRoomDuration())
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ODDAURA,
  proc { |ability,battler,battle|
    unless battle.field.effectActive?(:OddRoom)
      battle.pbShowAbilitySplash(battler)
      battle.field.applyEffect(:OddRoom,battler.getRoomDuration())
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GARLANDGUARDIAN,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.pbOwnSide.applyEffect(:Safeguard,5)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FREERIDE,
  proc { |ability,battler,battle|
    next if !battler.hasAlly?
    battle.pbShowAbilitySplash(battler)
    battler.eachAlly do |b|
      b.tryRaiseStat(:SPEED,battler)
		end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EARTHLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
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
    battler.pbOwnSide.applyEffect(:LuckyChant,5)
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
    battler.pbOwnSide.applyEffect(:Tailwind,4)
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
    battle.forceUseMove(battler,:ENDURE,-1,true,nil,nil,true)
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

BattleHandlers::AbilityOnSwitchIn.add(:PRIMEVALSLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler,true)
    battle.pbDisplay(_INTL("{1} is burdened!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)


BattleHandlers::AbilityOnSwitchIn.add(:REFRESHMENTS,
  proc { |ability,battler,battle|
    next unless battle.sunny?
    lowestId =  battler.index
    lowestPercent = battler.hp / battler.totalhp.to_f
    battler.eachAlly do |b|
		thisHP = b.hp / b.totalhp.to_f
		if (thisHP < lowestPercent) && b.canHeal?
			lowestId = b.index
			lowestPercent = thisHP
		end
	end
	lowestIdBattler = battle.battlers[lowestId]
	next unless lowestIdBattler.canHeal?
	served = (lowestId == battler.index ? "itself" : lowestIdBattler.pbThis)
	battle.pbShowAbilitySplash(battler)
	battle.pbDisplay(_INTL("{1} served {2} some refreshments!",battler.pbThis, served))
	lowestIdBattler.pbRecoverHP(lowestIdBattler.totalhp/2.0)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRASSYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Grassy)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Psychic)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MISTYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Misty)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:MISTYSURGE,:FAIRYSURGE)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Electric)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)