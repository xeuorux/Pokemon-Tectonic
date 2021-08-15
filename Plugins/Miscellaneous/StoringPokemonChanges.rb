def pbStorePokemon(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pkmn.record_first_moves
  if $Trainer.party_full?
    oldcurbox = $PokemonStorage.currentBox
    storedbox = $PokemonStorage.pbStoreCaught(pkmn)
    curboxname = $PokemonStorage[oldcurbox].name
    boxname = $PokemonStorage[storedbox].name
    creator = nil
    creator = pbGetStorageCreator if $Trainer.seen_storage_creator
    if storedbox != oldcurbox
      pbMessage(_INTL("Box \"{1}\" on the Pokémon Storage PC was full.\1", curboxname))
      pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pkmn.name, boxname))
    else
      pbMessage(_INTL("{1} was transferred to the Pokémon Storage PC.\1", pkmn.name))
      pbMessage(_INTL("It was stored in box \"{1}.\"", boxname))
    end
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
end

def pbNicknameAndStore(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  $Trainer.pokedex.set_seen(pkmn.species)
  $Trainer.pokedex.set_owned(pkmn.species)
  
  #Let the player know info about the individual pokemon they caught
  pbMessage(_INTL("You check {1}, and discover that its ability is {2}!",pkmn.name,pkmn.ability.name))
  
  if (pkmn.hasItem?)
	pbMessage(_INTL("The {1} is holding an {2}!",pkmn.name,pkmn.item.name))
  end
  
  # Increase the caught count for the global metadata
  if $PokemonGlobal.caughtCountsPerMap.has_key?($game_map.map_id)
	$PokemonGlobal.caughtCountsPerMap[$game_map.map_id][1] += 1
  else
	$PokemonGlobal.caughtCountsPerMap[$game_map.map_id] = [0,1]
  end
  
  pbStorePokemon(pkmn)
end

module PokeBattle_BattleCommon
  #=============================================================================
  # Store caught Pokémon
  #=============================================================================
  def pbStorePokemon(pkmn)
    # Store the Pokémon
    currentBox = @peer.pbCurrentBox
    storedBox  = @peer.pbStorePokemon(pbPlayer,pkmn)
    if storedBox<0
      pbDisplayPaused(_INTL("{1} has been added to your party.",pkmn.name))
      @initialItems[0][pbPlayer.party.length-1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    curBoxName = @peer.pbBoxName(currentBox)
    boxName    = @peer.pbBoxName(storedBox)
    if storedBox!=currentBox
      pbDisplayPaused(_INTL("Box \"{1}\" on the Pokémon Storage PC was full.",curBoxName))
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pkmn.name,boxName))
    else
      pbDisplayPaused(_INTL("{1} was transferred to the Pokémon Storage PC.",pkmn.name))
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxName))
    end
  end
  
  # Register all caught Pokémon in the Pokédex, and store them.
  def pbRecordAndStoreCaughtPokemon
    @caughtPokemon.each do |pkmn|
      pbPlayer.pokedex.register(pkmn)   # In case the form changed upon leaving battle
	  
	  #Let the player know info about the individual pokemon they caught
      pbDisplayPaused(_INTL("You check {1}, and discover that its ability is {2}!",pkmn.name,pkmn.ability.name))
      
      if (pkmn.hasItem?)
        pbDisplayPaused(_INTL("The {1} is holding an {2}!",pkmn.name,pkmn.item.name))
      end
	  
      # Record the Pokémon's species as owned in the Pokédex
      if !pbPlayer.owned?(pkmn.species)
        pbPlayer.pokedex.set_owned(pkmn.species)
        if $Trainer.has_pokedex
          pbDisplayPaused(_INTL("You register {1} as caught in the Pokédex.",pkmn.name))
          pbPlayer.pokedex.register_last_seen(pkmn)
          @scene.pbShowPokedex(pkmn.species)
        end
      end
      # Record a Shadow Pokémon's species as having been caught
      pbPlayer.pokedex.set_shadow_pokemon_owned(pkmn.species) if pkmn.shadowPokemon?
      # Store caught Pokémon
      pbStorePokemon(pkmn)
	  
	  # Increase the caught count for the global metadata
	  if $PokemonGlobal.caughtCountsPerMap.has_key?($game_map.map_id)
		$PokemonGlobal.caughtCountsPerMap[$game_map.map_id][0] += 1
	  else
		$PokemonGlobal.caughtCountsPerMap[$game_map.map_id] = [1,0]
	  end	  
    end
    @caughtPokemon.clear
  end
end

class StorageSystemPC
	def name
		return _INTL("Pokémon Storage PC")
	end
end

class TrainerPC
	def name
		return _INTL("Item Storage PC")
	end
end