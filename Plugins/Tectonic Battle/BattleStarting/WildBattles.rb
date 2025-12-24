#===============================================================================
# Start a wild battle
#===============================================================================
def pbWildBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE..."))
    skipBattle(outcomeVar)
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  sp = nil
  for arg in args
    if arg.is_a?(Pokemon)
      foeParty.push(arg)
    elsif arg.is_a?(Array)
      species = GameData::Species.get(arg[0]).id
      pkmn = pbGenerateWildPokemon(species,arg[1])
      foeParty.push(pkmn)
    elsif sp
      species = GameData::Species.get(sp).id
      pkmn = pbGenerateWildPokemon(species,arg)
      foeParty.push(pkmn)
      sp = nil
    else
      sp = arg
    end
  end
  raise _INTL("Expected a level after being given {1}, but one wasn't found.",sp) if sp

  # Check for pacifists
  pacifistCount = 0
  foeParty.each do |foePartyMember|
      next unless foePartyMember.hasAbility?(:PACIFIST)
      if foeParty.length > 1
        pbMessage(_INTL("What? One of the wild Pokémon is a pacifist!"))
      else
        pbMessage(_INTL("What? The wild Pokémon is a pacifist!"))
      end
      pbMessage(_INTL("It's a {1}.",foePartyMember.name))
      pbMessage(_INTL("It offers to join you willingly!"))
      if pbConfirmMessage(_INTL("Accept the {1}'s offer to join you?",foePartyMember.name))
        pbAddPokemon(foePartyMember)
      else
        pbMessage(_INTL("The {1} slinks away, disappointed...",foePartyMember.name))
      end
      pacifistCount += 1
  end

  if foeParty.length == pacifistCount # All wild foes are pacifists, so end the battle immediately
    skipBattle(4)
    return 4
  else
    foeParty = foeParty.delete_if {|foePartyMember| foePartyMember.hasAbility?(:PACIFIST)}
  end

  # Calculate who the trainers and their party are
  playerTrainers    = [$Trainer]
  playerParty       = $Trainer.party
  playerPartyStarts = [0]
  room_for_partner = (foeParty.length > 1)
  if !room_for_partner && $PokemonTemp.battleRules["size"] &&
      !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
    room_for_partner = true
  end
  playerParty = loadPartnerTrainer(playerTrainers,playerParty,playerPartyStarts) if room_for_partner
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_TectonicRecordedBattle.new(scene,playerParty,foeParty,playerTrainers,nil, 0)
  battle.party1starts = playerPartyStarts
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  battle.registerRules
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
    pbAfterBattle(decision,canLose)
  }
  Input.update
  # Save the result of the battle in a Game Variable (1 by default)
  #    0 - Undecided or aborted
  #    1 - Player won
  #    2 - Player lost
  #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #    4 - Wild Pokémon was caught
  #    5 - Draw
  pbSet(outcomeVar,decision)
  return decision
end

def skipBattle(outcomeVar = 1,outcome = 1)
  pbSet(outcomeVar,outcome)  # Treat it as a win by default
  $PokemonTemp.clearBattleRules
  $PokemonGlobal.nextBattleBGM       = nil
  $PokemonGlobal.nextBattleME        = nil
  $PokemonGlobal.nextBattleCaptureME = nil
  $PokemonGlobal.nextBattleBack      = nil
  pbMEStop
end

#===============================================================================
# Standard methods that start a wild battle of various sizes
#===============================================================================
# Used when walking in tall grass, hence the additional code.
def pbWildBattle(species, level, outcomeVar=1, canRun=true, canLose=false)
  # Randomize
  species = randomizeSpecies(species, !$rndx_non_static)
  species = GameData::Species.get(species).id
  # Potentially call a different pbWildBattle-type method instead (for roaming
  # Pokémon, Safari battles, Bug Contest battles)
  handled = [nil]
  Events.onWildBattleOverride.trigger(nil,species,level,handled)
  return handled[0] if handled[0]!=nil
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  # Perform the battle
  decision = pbWildBattleCore(species, level)
  # Used by the Poké Radar to update/break the chain
  Events.onWildBattleEnd.trigger(nil,species,level,decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

def pbDoubleWildBattle(species1, level1, species2, level2,
                        outcomeVar=1, canRun=true, canLose=false)
  # Randomize
  species1 = randomizeSpecies(species1, !$rndx_non_static)
  species2 = randomizeSpecies(species2, !$rndx_non_static)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("double")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end

def pbTripleWildBattle(species1, level1, species2, level2, species3, level3,
                        outcomeVar=1, canRun=true, canLose=false)
  # randomizer
  species1 = randomizeSpecies(species1, !$rndx_non_static)
  species2 = randomizeSpecies(species2, !$rndx_non_static)
  species3 = randomizeSpecies(species3, !$rndx_non_static)
  # Set some battle rules
  setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
  setBattleRule("cannotRun") if !canRun
  setBattleRule("canLose") if canLose
  setBattleRule("triple")
  # Perform the battle
  decision = pbWildBattleCore(species1, level1, species2, level2, species3, level3)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision!=2 && decision!=5)
end