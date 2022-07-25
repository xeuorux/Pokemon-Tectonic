def pbStorePokemon(pkmn)
  if pbBoxesFull?
    pbMessage(_INTL("There's no more room for Pokémon!\1"))
    pbMessage(_INTL("The Pokémon Boxes are full and can't accept any more!"))
    return
  end
  pkmn.record_first_moves
  if $Trainer.party_full?
    storingPokemon = pkmn
    if pbConfirmMessageSerious(_INTL("Would you like to add {1} to your party?", pkmn.name))
      pbMessage(_INTL("Choose which Pokemon will be sent back to the PC."))
      #if Y, select pokemon to store instead
      pbChoosePokemon(1,3)
      chosen = $game_variables[1]
      #Didn't cancel
      if chosen != -1
        storingPokemon = $Trainer.party[chosen]
        
        if storingPokemon.hasItem?
          itemName = GameData::Item.get(storingPokemon.item).real_name
          if pbConfirmMessageSerious(_INTL("{1} is holding an {2}. Would you like to take it before transferring?", storingPokemon.name, itemName))
            pbTakeItemFromPokemon(storingPokemon)
          end
        end
        
        $Trainer.party[chosen] = pkmn
        
        refreshFollow
      end
    end
    pbStorePokemonInPC(storingPokemon)
  else
    $Trainer.party[$Trainer.party.length] = pkmn
  end
end

def pbTakeItemFromPokemon(pkmn,scene=nil)
  ret = false
  if !pkmn.hasItem?
    pbMessage(_INTL("{1} isn't holding anything.",pkmn.name))
  elsif !$PokemonBag.pbCanStore?(pkmn.item)
    pbMessage(_INTL("The Bag is full. The Pokémon's item could not be removed."))
  elsif pkmn.mail
    if pbConfirmMessage(_INTL("Save the removed mail in your PC?"))
      if !pbMoveToMailbox(pkmn)
        pbMessage(_INTL("Your PC's Mailbox is full."))
      else
        pbMessage(_INTL("The mail was saved in your PC."))
        pkmn.item = nil
        ret = true
      end
    elsif pbConfirmMessage(_INTL("If the mail is removed, its message will be lost. OK?"))
      $PokemonBag.pbStoreItem(pkmn.item)
      pbMessage(_INTL("Received the {1} from {2}.",pkmn.item.name,pkmn.name))
      pkmn.item = nil
      pkmn.mail = nil
      ret = true
    end
  else
    $PokemonBag.pbStoreItem(pkmn.item)
    pbMessage(_INTL("Received the {1} from {2}.",pkmn.item.name,pkmn.name))
    pkmn.item = nil
    ret = true
  end
  return ret
end

def pbStorePokemonInPC(pkmn)
	oldcurbox = $PokemonStorage.currentBox
  storedbox = $PokemonStorage.pbStoreCaught(pkmn)
  curboxname = $PokemonStorage[oldcurbox].name
  boxname = $PokemonStorage[storedbox].name
  if storedbox != oldcurbox
    pbMessage(_INTL("Box \"{1}\" on the Pokémon Storage PC was full.\1", curboxname))
    pbMessage(_INTL("{1} was transferred to box \"{2}.\"", pkmn.name, boxname))
  else
    pbMessage(_INTL("{1} was transferred to the Pokémon Storage PC.\1", pkmn.name))
    pbMessage(_INTL("It was stored in box \"{1}.\"", boxname))
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
  incrementDexNavCounts(false)

  pbNickname(pkmn) if !pkmn.shadowPokemon? && (!defined?($PokemonSystem.nicknaming_prompt) || $PokemonSystem.nicknaming_prompt == 0)
  
  pbStorePokemon(pkmn)
end

def incrementDexNavCounts(caught)
	$PokemonGlobal.caughtCountsPerMap = {} if !$PokemonGlobal.caughtCountsPerMap
	if caught
		if $PokemonGlobal.caughtCountsPerMap.has_key?($game_map.map_id)
			$PokemonGlobal.caughtCountsPerMap[$game_map.map_id][0] += 1
		else
			$PokemonGlobal.caughtCountsPerMap[$game_map.map_id] = [1,0]
		end
	else
		if $PokemonGlobal.caughtCountsPerMap.has_key?($game_map.map_id)
			$PokemonGlobal.caughtCountsPerMap[$game_map.map_id][1] += 1
		else
			$PokemonGlobal.caughtCountsPerMap[$game_map.map_id] = [0,1]
		end
	end
end

module PokeBattle_BattleCommon
  #=============================================================================
  # Store caught Pokémon
  #=============================================================================
  def pbStorePokemon(pkmn)
    # Store the Pokémon
    currentBox = @peer.pbCurrentBox
    storedBox  = @peer.pbStorePokemon(pbPlayer,pkmn)
    if storedBox < 0
      pbDisplayPaused(_INTL("{1} has been added to your party.",pkmn.name))
      @initialItems[0][pbPlayer.party.length-1] = pkmn.item_id if @initialItems
      return
    end
    # Messages saying the Pokémon was stored in a PC box
    curBoxName = @peer.pbBoxName(currentBox)
    boxName    = @peer.pbBoxName(storedBox)
    if storedBox != currentBox
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
	  
	    # Increase the caught count for the global metadata
	    incrementDexNavCounts(true)

        # Nickname the Pokémon (unless it's a Shadow Pokémon)
      if !pkmn.shadowPokemon? && (!defined?($PokemonSystem.nicknaming_prompt) || $PokemonSystem.nicknaming_prompt == 0)
        if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?", pkmn.name))
          nickname = @scene.pbNameEntry(_INTL("{1}'s nickname?", pkmn.speciesName), pkmn)
          pkmn.name = nickname
        end
      end

	    #Check Party Size
      if $Trainer.party_full?
        #Y/N option to store newly caught
        if pbDisplayConfirmSerious(_INTL("Would you like to add {1} to your party?", pkmn.name))
          pbDisplay(_INTL("Choose which Pokemon will be sent back to the PC."))
		      #if Y, select pokemon to store instead
          pbChoosePokemon(1,3)
		      chosen = $game_variables[1]
          #Didn't cancel
          if chosen != -1
            chosenPokemon = $Trainer.party[chosen]
            @peer.pbOnLeavingBattle(self,chosenPokemon,@usedInBattle[0][chosen],true)   # Reset form
        
            # Find the battler which matches with the chosen pokemon	
            chosenBattler = nil
            eachSameSideBattler() do |battler|
              next unless battler.pokemon == chosenPokemon
              chosenBattler = battler
              break
            end
            # Handle the chosen pokemon leaving battle, if it was in battle
            if !chosenBattler.nil? && chosenBattler.abilityActive?
              BattleHandlers.triggerAbilityOnSwitchOut(chosenBattler.ability,chosenBattler,true,self)
            end
            
            chosenPokemon.item = @initialItems[0][chosen]
            @initialItems[0][chosen] = pkmn.item
            
            if chosenPokemon.hasItem?
              itemName = GameData::Item.get(chosenPokemon.item).real_name
              if pbConfirmMessageSerious(_INTL("{1} is holding an {2}. Would you like to take it before transferring?", chosenPokemon.name, itemName))
                pbTakeItemFromPokemon(chosenPokemon)
              end
            end
            
            pbStorePokemon(chosenPokemon)
            $Trainer.party[chosen] = pkmn
          else
            # Store caught Pokémon if cancelled
            pbStorePokemon(pkmn)
          end
        else
          # Store caught Pokémon
          pbStorePokemon(pkmn)
        end
	    else
        # Store caught Pokémon
        pbStorePokemon(pkmn)
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