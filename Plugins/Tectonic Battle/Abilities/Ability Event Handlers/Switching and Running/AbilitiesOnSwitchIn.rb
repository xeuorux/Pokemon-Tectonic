#######################################################
# Weather setting abilities
#######################################################

BattleHandlers::AbilityOnSwitchIn.add(:DRIZZLE,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :Rain, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DROUGHT,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :Sun, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDSTREAM,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :Sandstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SNOWWARNING,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :Hail, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HARBINGER,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :Eclipse, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOONGAZE,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :Moonglow, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :HeavyRain, battler, battle, true, baseDuration: -1)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESOLATELAND,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :HarshSun, battler, battle, true, baseDuration: -1)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DELTASTREAM,
  proc { |ability, battler, battle|
      pbBattleWeatherAbility(ability, :StrongWinds, battler, battle, true, baseDuration: -1)
  }
)

#######################################################
# Terrain setting abilities
#######################################################

BattleHandlers::AbilityOnSwitchIn.add(:GRASSYSURGE,
  proc { |ability, battler, battle|
      next if battle.field.terrain == :Grassy
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbStartTerrain(battler, :Grassy)
      # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability, battler, battle|
      next if battle.field.terrain == :Psychic
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbStartTerrain(battler, :Psychic)
      # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYSURGE,
  proc { |ability, battler, battle|
      next if battle.field.terrain == :Fairy
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbStartTerrain(battler, :Fairy)
      # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability, battler, battle|
      next if battle.field.terrain == :Electric
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbStartTerrain(battler, :Electric)
      # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

#######################################################
# Other abilities
#######################################################

BattleHandlers::AbilityOnSwitchIn.add(:AIRLOCK,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("The effects of the weather disappeared."))
      battle.pbHideAbilitySplash(battler)
      battle.field.specialTimer = 1
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:AIRLOCK, :CLOUDNINE)

BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability, battler, battle|
      next unless battler.pbOwnedByPlayer?
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
                  moveType = pbHiddenPower(b.pokemon)[0] if m.function == "090" # Hidden Power
                  eff = Effectiveness.calculate(moveType, type1, type2, type3)
                  next if Effectiveness.ineffective?(eff)
                  next if !Effectiveness.super_effective?(eff) && m.function != "070" # OHKO
              elsif m.function != "070"
                  next
              end
              found = true
              break
          end
          break if found
      end
      if found
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("{1} shuddered with anticipation!", battler.pbThis))
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AURABREAK,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is drowsing!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DARKAURA,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is radiating a dark aura!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNLOAD,
  proc { |ability, battler, battle|
      oppTotalDef = oppTotalSpDef = 0
      battle.eachOtherSideBattler(battler.index) do |b|
        oppTotalDef += b.pbDefense
        oppTotalSpDef += b.pbSpDef
      end
      stat = (oppTotalDef < oppTotalSpDef) ? :ATTACK : :SPECIAL_ATTACK
      battler.tryRaiseStat(stat, battler, ability: ability, increment: 2)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EVOARMOR,
  proc { |ability, battler, battle|
      oppTotalAttack = oppTotalSpAtk = 0
      battle.eachOtherSideBattler(battler.index) do |b|
        oppTotalAttack += b.pbAttack
        oppTotalSpAtk += b.pbSpAtk
      end
      stat = (oppTotalAttack > oppTotalSpAtk) ? :DEFENSE : :SPECIAL_DEFENSE
      battler.tryRaiseStat(stat, battler, ability: ability, increment: 2)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRIFTINGMIST,
  proc { |ability, _battler, battle|
      battle.field.applyEffect(:GreyMist, 3) unless battle.field.effectActive?(:GreyMist)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYAURA,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is radiating a fairy aura!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability, battler, battle|
      next unless battler.pbOwnedByPlayer?
      highestPower = 0
      forewarnMoves = []
      battle.eachOtherSideBattler(battler.index) do |b|
          b.eachMove do |m|
              power = m.baseDamage
              power = 160 if ["070"].include?(m.function)    # OHKO
              power = 150 if ["08B"].include?(m.function)    # Eruption
              # Counter, Mirror Coat, Metal Burst
              power = 120 if %w[071 072 073].include?(m.function)
              # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
              # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
              # Natural Gift, Trump Card, Flail, Grass Knot
              power = 80 if %w[06A 06B 06D 06E 06F
                               089 08A 08C 08D 090
                               096 097 098 09A].include?(m.function)
              next if power < highestPower
              forewarnMoves = [] if power > highestPower
              forewarnMoves.push(m.name)
              highestPower = power
          end
      end
      if forewarnMoves.length > 0
          battle.pbShowAbilitySplash(battler, ability)
          forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
          battle.pbDisplay(_INTL("{1} was alerted to {2}!", battler.pbThis, forewarnMoveName))
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability, battler, battle|
      next if battler.transformed?
      choice = battler.pbDirectOpposing
      next if choice.fainted?
      next if choice.transformed? ||
              choice.illusion? ||
              choice.substituted? ||
              choice.effectActive?(:SkyDrop) ||
              choice.semiInvulnerable?
      battle.pbShowAbilitySplash(battler, ability, true)
      battle.pbHideAbilitySplash(battler)
      battle.pbAnimation(:TRANSFORM, battler, choice)
      battle.scene.pbChangePokemon(battler, choice.pokemon)
      battler.pbTransform(choice)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTIMIDATE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.eachOtherSideBattler(battler.index) do |b|
        next unless b.near?(battler)
        next if b.blockAteAbilities(battler, ability)
        next unless b.tryLowerStat(:ATTACK, battler, increment: 2)
        b.pbItemOnIntimidatedCheck
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FASCINATE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.eachOtherSideBattler(battler.index) do |b|
        next unless b.near?(battler)
        next if b.blockAteAbilities(battler, ability)
        next unless b.tryLowerStat(:SPECIAL_ATTACK, battler, increment: 2)
        b.pbItemOnIntimidatedCheck
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRUSTRATE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.eachOtherSideBattler(battler.index) do |b|
          next unless b.near?(battler)
          next if b.blockAteAbilities(battler, ability)
          next unless b.tryLowerStat(:SPEED, battler, increment: 2)
          b.pbItemOnIntimidatedCheck
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOLDBREAKER,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} breaks the mold!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRESSURE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is exerting its pressure!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TERAVOLT,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is radiating a bursting aura!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TURBOBLAZE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is radiating a blazing aura!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UNNERVE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is too nervous to eat Berries or Leftovers!", battler.pbOpposingTeam))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:STRESSFUL,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is too stressed to use their items!", battler.pbOpposingTeam))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyEffect(:SlowStart, 3)
      battle.pbDisplay(_INTL("{1} can't get it going!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASONEICE,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} has 2 Abilities!", battler.name))
      battle.pbShowAbilitySplash(battler, :UNNERVE)
      battle.pbDisplay(_INTL("{1} is too nervous to eat Berries or Leftovers!", battler.pbOpposingTeam))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ASONEICE, :ASONEGHOST)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability, battler, _battle|
      battler.tryRaiseStat(:ATTACK, battler, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability, battler, _battle|
      battler.tryRaiseStat(:DEFENSE, battler, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability, battler, battle|
      anyScreen = false
      battle.sides.each do |side|
          side.eachEffect(true) do |_effect, _value, effectData|
              next unless effectData.is_screen?
              anyScreen = true
              break
          end
          break if anyScreen
      end
      next unless anyScreen

      battle.pbShowAbilitySplash(battler, ability)
      battle.sides.each do |side|
          side.eachEffect(true) do |effect, _value, effectData|
              next unless effectData.is_screen?
              side.disableEffect(effect)
          end
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability, battler, battle|
      battler.eachAlly do |b|
          next if b.status != :POISON
          battle.pbShowAbilitySplash(battler, ability)
          b.pbCureStatus(true)
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability, battler, battle|
      done = false
      battler.eachAlly do |b|
          next unless b.hasAlteredStatSteps?
          b.pbResetStatSteps
          done = true
      end
      if done
          battle.pbShowAbilitySplash(battler, ability)
          battle.pbDisplay(_INTL("All allies' stat changes were eliminated!"))
          battle.pbHideAbilitySplash(battler)
      end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability, battler, battle|
      next if battle.field.effectActive?(:NeutralizingGas)
      battle.pbShowAbilitySplash(battler, ability)
      battle.field.applyEffect(:NeutralizingGas)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRAMATICLIGHTING,
  proc { |ability, battler, battle|
      next unless battle.eclipsed?
      battle.pbShowAbilitySplash(battler, ability)
      battle.eachOtherSideBattler(battler.index) do |b|
          next unless b.near?(battler)
          b.pbLowerMultipleStatSteps([:ATTACK,2,:SPECIAL_ATTACK,2],battler,showFailMsg: true)
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CRAGTERROR,
  proc { |ability, battler, battle|
      next unless battle.sandy?
      battle.pbShowAbilitySplash(battler, ability)
      battle.eachOtherSideBattler(battler.index) do |b|
          next unless b.near?(battler)
          b.pbLowerMultipleStatSteps([:ATTACK,2,:SPECIAL_ATTACK,2],battler,showFailMsg: true)
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HOLIDAYCHEER,
  proc { |ability, battler, battle|
      anyHealing = false
      battle.eachSameSideBattler(battler.index) do |b|
          anyHealing = true if b.hp < b.totalhp
      end
      if anyHealing
          battle.pbShowAbilitySplash(battler, ability)
          battle.eachSameSideBattler(battler.index) do |b|
              b.pbRecoverHP(b.totalhp * 0.25)
          end
          battle.pbHideAbilitySplash(battler)
      end
  }
)

##########################################
# Screen setting abilities
##########################################

BattleHandlers::AbilityOnSwitchIn.add(:STARGUARDIAN,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      duration = battler.getScreenDuration(4)
      battler.pbOwnSide.applyEffect(:LightScreen, duration)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BARRIERMAKER,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      duration = battler.getScreenDuration(4)
      battler.pbOwnSide.applyEffect(:Reflect, duration)
      battle.pbHideAbilitySplash(battler)
  }
)

##########################################
# Room setting abilities
##########################################

BattleHandlers::AbilityOnSwitchIn.add(:PUZZLINGAURA,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battle.pbStartRoom(:PuzzleRoom, battler)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TRICKSTERAURA,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battle.pbStartRoom(:TrickRoom, battler)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ODDAURA,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battle.pbStartRoom(:OddRoom, battler)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WONDROUSAURA,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battle.pbStartRoom(:WonderRoom, battler)
    battle.pbHideAbilitySplash(battler)
  }
)

##########################################
# Totem abilities
##########################################
BattleHandlers::AbilityOnSwitchIn.add(:STORMTOTEM,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battler.pbOwnSide.applyEffect(:TurbulentSky,6)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOGTOTEM,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battler.pbOwnSide.applyEffect(:MisdirectingFog,6)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WILDTOTEM,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battler.pbOwnSide.applyEffect(:PrimalForest,6)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FLUTTERTOTEM,
  proc { |ability, battler, battle|
    battle.pbShowAbilitySplash(battler, ability)
    battler.pbOwnSide.applyEffect(:CruelCocoon,6)
    battle.pbHideAbilitySplash(battler)
  }
)

##########################################
# Misc
##########################################

BattleHandlers::AbilityOnSwitchIn.add(:GARLANDGUARDIAN,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbOwnSide.applyEffect(:Safeguard, 10)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FREERIDE,
  proc { |ability, battler, battle|
      next unless battler.hasAlly?
      battle.pbShowAbilitySplash(battler, ability)
      battler.eachAlly do |b|
          b.tryRaiseStat(:SPEED, battler, increment: 2)
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:EARTHLOCK,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("The effects of the terrain disappeared."))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:RUINOUS,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is ruinous! Everyone deals 40 percent more damage!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SEALORD,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is hungry for destruction!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HONORAURA,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} is honorable! Status moves lose priority!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CLOVERSONG,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbOwnSide.applyEffect(:LuckyChant, 10)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ARCANEFINALE,
  proc { |ability, battler, battle|
      next unless battler.isLastAlive?
      next unless battler.form == 0
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbChangeForm(1, _INTL("{1} is the team's finale!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ARCANEFINALE,:HEROICFINALE)

BattleHandlers::AbilityOnSwitchIn.add(:ONTHEWIND,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.pbOwnSide.applyEffect(:Tailwind, 4)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AQUASNEAK,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} snuck into the water!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMEVALSLOWSTART,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability, true)
      battle.pbDisplay(_INTL("{1} is burdened!", battler.pbThis))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMEVALIMPOSTER,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability, true)
      battle.pbDisplay(_INTL("{1} transforms into a stronger version of your entire team!", battler.pbThis))
      battler.boss = false
      battle.bossBattle = false

      trainerClone = NPCTrainer.cloneFromPlayer($Trainer)
      battle.opponent = [trainerClone]

      party = battle.pbParty(battler.index)
      party.clear

      # Give each cloned pokemon a stat boost to each stat
      trainerClone.party.each do |partyMember|
        party.push(partyMember)
        partyMember.ev = partyMember.ev.each_with_object({}) do |(statID, evValue), evArray|
          evArray[statID] = evValue + 10
        end
        partyMember.calc_stats   
      end

      partyOrder = battle.pbPartyOrder(battler.index)
      partyOrder.clear
      party.each do |partyMember,index|
        partyOrder.push(index)
      end

      battler.pbInitialize(party[0],0)
      if party.length > 1
        battle.addBattlerSlot(party[1],1,0)
      else
        battle.remakeDataBoxes
        battle.remakeBattleSpritesOnSide(battler.index % 2)
      end

      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:REFRESHMENTS,
  proc { |ability, battler, battle|
      next unless battle.sunny?
      lowestId = battler.index
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
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} served {2} some refreshments!", battler.pbThis, served))
      lowestIdBattler.pbRecoverHP(lowestIdBattler.totalhp / 2.0)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MENDINGTONES,
  proc { |ability, battler, battle|
      next unless battle.eclipsed?
      lowestId = battler.index
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
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} mended {2} with soothing sounds!", battler.pbThis, served))
      lowestIdBattler.pbRecoverHP(lowestIdBattler.totalhp / 2.0)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PEARLSEEKER,
  proc { |ability, battler, battle|
      next unless battle.eclipsed?
      next unless battler.canAddItem?(:PEARLOFFATE)
      battle.pbShowAbilitySplash(battler, ability)
      battler.giveItem(:PEARLOFFATE)
      battle.pbDisplay(_INTL("{1} discovers the {2}!", battler.pbThis, getItemName(:PEARLOFFATE)))
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WHIRLER,
  proc { |ability, battler, battle|
      trappingDuration = 2
      trappingDuration *= 2 if battler.hasActiveItem?(:GRIPCLAW)

      battle.pbShowAbilitySplash(battler, ability)
      battler.eachOpposing do |b|
        next if b.effectActive?(:Trapping)
        b.applyEffect(:Trapping, trappingDuration)
        b.applyEffect(:TrappingMove, :WHIRLPOOL)
        b.pointAt(:TrappingUser, battler)
        battle.pbDisplay(_INTL("{1} became trapped in the vortex!", b.pbThis))
      end
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SUSTAINABLE,
  proc { |ability, battler, battle|
    next unless battler.recyclableItem
    next unless GameData::Item.get(battler.recyclableItem).is_berry?
    next if battler.hasItem?(battler.recyclableItem)
    next unless battle.sunny?
    recyclingMsg = _INTL("{1} regrew one {2}!", battler.pbThis, getItemName(battler.recyclableItem))
    battler.recycleItem(recyclingMsg: recyclingMsg, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COTTONDECOY,
  proc { |ability, battler, battle|
    next if battler.substituted?
    next unless battler.hp > battler.totalhp / 4
    battler.createSubstitute
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:KLEPTOMANIAC,
  proc { |ability, battler, battle|
      battle.forceUseMove(battler, :SNATCH, -1, ability: ability)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASSISTANT,
  proc { |ability, battler, battle|
      battle.forceUseMove(battler, :ASSIST, -1, ability: ability)
    }
)

BattleHandlers::AbilityOnSwitchIn.add(:ROLLIN,
  proc { |ability, battler, battle|
      battle.forceUseMove(battler, :RAPIDSPIN, -1, ability: ability)
  }
)


BattleHandlers::AbilityOnSwitchIn.add(:PRECHARGED,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyEffect(:Charge)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:LOOSESHELL,
  proc { |ability, battler, battle|
      next unless battle.sandy?
      next if battler.pbOpposingSide.effectActive?(:StealthRock)
      battle.pbShowAbilitySplash(battler, ability)
      battle.pbDisplay(_INTL("{1} shoots out parts of its discarded shell!", battler.pbThis))
      battler.pbOpposingSide.applyEffect(:StealthRock)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRAVITATIONAL,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battle.field.applyEffect(:Gravity, 5)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INFECTED,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyEffect(:Type3,:GRASS)
      battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:RUSTYANCHOR,
  proc { |ability, battler, battle|
      battle.pbShowAbilitySplash(battler, ability)
      battler.applyEffect(:Type3,:STEEL)
      battle.pbHideAbilitySplash(battler)
  }
)