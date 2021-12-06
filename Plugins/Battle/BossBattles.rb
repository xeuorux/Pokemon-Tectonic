def pbBigAvatarBattle(*args)
	rule = "3v#{args.length}"
	setBattleRule(rule)
	pbAvatarBattleCore(*args)
end

def pbSmallAvatarBattle(*args)
	rule = "2v#{args.length}"
	setBattleRule(rule)
	pbAvatarBattleCore(*args)
end

def pbAvatarBattleCore(*args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
  if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
    pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemon_count > 0
    pbSet(outcomeVar,1)   # Treat it as a win
    $PokemonTemp.clearBattleRules
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    pbMEStop
    return 1   # Treat it as a win
  end
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  Events.onStartBattle.trigger(nil)
  # Generate wild Pokémon based on the species and level
  foeParty = []
  numTurns = 0
  
  respawnFollower = false
  for arg in args
    if arg.is_a?(Array)
		for i in 0...arg.length/2
			species = GameData::Species.get(arg[i*2]).id
			pkmn = pbGenerateWildPokemon(species,arg[i*2+1])
			pkmn.boss = true
			newNumTurns = setAvatarProperties(pkmn)
			numTurns = [newNumTurns,numTurns].max
			foeParty.push(pkmn)
		end
	end
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
  if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && room_for_partner
    ally = NPCTrainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
    ally.id    = $PokemonGlobal.partner[2]
    ally.party = $PokemonGlobal.partner[3]
    playerTrainers.push(ally)
    playerParty = []
    $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
    playerPartyStarts.push(playerParty.length)
    ally.party.each { |pkmn| playerParty.push(pkmn) }
    setBattleRule("double") if !$PokemonTemp.battleRules["size"]
  end
  # Create the battle scene (the visual side of it)
  scene = pbNewBattleScene
  # Create the battle class (the mechanics side of it)
  battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,nil)
  battle.party1starts = playerPartyStarts
  battle.numBossOnlyTurns = numTurns - 1
  battle.bossBattle = true
  # Set various other properties in the battle class
  pbPrepareBattle(battle)
  $PokemonTemp.clearBattleRules
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetAvatarBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
    pbSceneStandby {
      decision = battle.pbStartBattle
    }
	pbPokemonFollow(1) if decision != 1 && $game_switches[59] # In cave with Yezera
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
  return (decision==1)
end

def setAvatarProperties(pkmn)
	avatar_data = GameData::Avatar.get(pkmn.species.to_sym)

	pkmn.forced_form = avatar_data.form

	pkmn.forget_all_moves()
	avatar_data.moves.each do |move|
		pkmn.learn_move(move)
	end
	
	pkmn.item = avatar_data.item
	pkmn.ability = avatar_data.ability
	pkmn.hpMult = avatar_data.hp_mult
	pkmn.dmgMult = avatar_data.dmg_mult
	pkmn.scaleFactor = avatar_data.size_mult
	
	pkmn.calc_stats()
	
	return avatar_data.num_turns
end


def calcHPMult(pkmn)
	hpMult = 1
	if pkmn.boss
		avatar_data = GameData::Avatar.get(pkmn.species.to_sym)
		hpMult = avatar_data.hp_mult
	end
	return hpMult
end
		

def pbPlayCrySpecies(species, form = 0, volume = 90, pitch = nil)
  GameData::Species.play_cry_from_species(species, form, volume, pitch)
end

class Pokemon
	attr_accessor :boss
	
	# @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
	  def gender
		return 2 if boss?
		if !@gender
		  gender_ratio = species_data.gender_ratio
		  case gender_ratio
		  when :AlwaysMale   then @gender = 0
		  when :AlwaysFemale then @gender = 1
		  when :Genderless   then @gender = 2
		  else
			female_chance = GameData::GenderRatio.get(gender_ratio).female_chance
			@gender = ((@personalID & 0xFF) < female_chance) ? 1 : 0
		  end
		end
		return @gender
	  end
	  
	def boss?
		return boss
	end
end

class PokeBattle_Battle 
  def pbExtraBossCommandPhase()
    @scene.pbBeginCommandPhase
    # Reset choices if commands can be shown
    @battlers.each_with_index do |b,i|
      next if !b
      pbClearChoice(i) if pbCanShowCommands?(i)
    end
    # Reset choices to perform Mega Evolution if it wasn't done somehow
    for side in 0...2
      @megaEvolution[side].each_with_index do |megaEvo,i|
        @megaEvolution[side][i] = -1 if megaEvo>=0
      end
    end
    pbCommandPhaseLoop(false)
  end
  
  #=============================================================================
  # Attack phase
  #=============================================================================
  def pbExtraBossAttackPhase
    @scene.pbBeginAttackPhase
    # Reset certain effects
    @battlers.each_with_index do |b,i|
      next if !b
      b.turnCount += 1 if !b.fainted?
      @successStates[i].clear
      if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
        b.effects[PBEffects::DestinyBond] = false
        b.effects[PBEffects::Grudge]      = false
      end
      b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")   # Rage
    end
    PBDebug.log("")
    # Calculate move order for this round
    pbCalculatePriority(true)
    # Perform actions
    pbAttackPhasePriorityChangeMessages
    pbAttackPhaseCall
    pbAttackPhaseSwitch
    return if @decision>0
    pbAttackPhaseItems
    return if @decision>0
    pbAttackPhaseMegaEvolution
    
	
	pbPriority.each do |b|
        next if b.fainted?
        next unless @choices[b.index][0]==:UseMove
        if b.boss
          b.pbProcessTurn(@choices[b.index])
        end
      end
  end
end

def pbPlayerPartyMaxLevel(countFainted = false)
  maxPlayerLevel = -100
  $Trainer.party.each do |pkmn|
    maxPlayerLevel = pkmn.level if pkmn.level > maxPlayerLevel && (!pkmn.fainted? || countFainted)
  end
  return maxPlayerLevel
end

def pbGetAvatarBattleBGM(_wildParty)   # wildParty is an array of Pokémon objects
	if $PokemonGlobal.nextBattleBGM
		return $PokemonGlobal.nextBattleBGM.clone
	end
	ret = nil
=begin
	if !ret
	# Check map metadata
	map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
	music = (map_metadata) ? map_metadata.wild_battle_BGM : nil
	ret = pbStringToAudioFile(music) if music && music != ""
	end
=end
	legend = false
	_wildParty.each do |p|
		legend = true if isLegendary?(p.species)
	end

	# Check global metadata
	music = legend ? GameData::Metadata.get.legendary_avatar_battle_BGM : GameData::Metadata.get.avatar_battle_BGM
	ret = pbStringToAudioFile(music) if music && music!=""
	ret = pbStringToAudioFile("Battle wild") if !ret
	
	echoln("Avatar music selection for Legendary = #{legend} : #{music}")
	return ret
end