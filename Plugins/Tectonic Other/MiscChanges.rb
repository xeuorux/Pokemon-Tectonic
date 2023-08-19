# Always print debug messages to console
module PBDebug
	def self.log(msg)
    if $DEBUG
      echoln("#{msg}\n")
	  if $INTERNAL
		@@log.push("#{msg}\r\n")
		PBDebug.flush
	  end
    end
  end
end

def pbFadeOutAndHide(sprites)
  visiblesprites = {}
  numFrames = (Graphics.frame_rate*0.4).floor
  numFrames = 1 if $PokemonSystem.skip_fades == 0
  alphaDiff = (255.0/numFrames).ceil
  pbDeactivateWindows(sprites) {
    for j in 0..numFrames
      pbSetSpritesToColor(sprites,Color.new(0,0,0,j*alphaDiff))
      (block_given?) ? yield : pbUpdateSpriteHash(sprites)
    end
  }
  for i in sprites
    next if !i[1]
    next if pbDisposed?(i[1])
    visiblesprites[i[0]] = true if i[1].visible
    i[1].visible = false
  end
  return visiblesprites
end

def pbFadeInAndShow(sprites,visiblesprites=nil)
  if visiblesprites
    for i in visiblesprites
      if i[1] && sprites[i[0]] && !pbDisposed?(sprites[i[0]])
        sprites[i[0]].visible = true
      end
    end
  end
  numFrames = (Graphics.frame_rate*0.4).floor
  numFrames = 1 if $PokemonSystem.skip_fades == 0
  alphaDiff = (255.0/numFrames).ceil
  pbDeactivateWindows(sprites) {
    for j in 0..numFrames
      pbSetSpritesToColor(sprites,Color.new(0,0,0,((numFrames-j)*alphaDiff)))
      (block_given?) ? yield : pbUpdateSpriteHash(sprites)
    end
  }
end

def pbStartTrade(pokemonIndex,newpoke,nickname,trainerName,trainerGender=0)
  myPokemon = $Trainer.party[pokemonIndex]
  pbTakeItemsFromPokemon(myPokemon) if myPokemon.hasItem?
  opponent = NPCTrainer.new(trainerName,trainerGender)
  opponent.id = $Trainer.make_foreign_ID
  yourPokemon = nil
  resetmoves = true
  if newpoke.is_a?(Pokemon)
    newpoke.owner = Pokemon::Owner.new_from_trainer(opponent)
    yourPokemon = newpoke
    resetmoves = false
  else
    species_data = GameData::Species.try_get(newpoke)
    raise _INTL("Species does not exist ({1}).", newpoke) if !species_data
    yourPokemon = Pokemon.new(species_data.id, myPokemon.level, opponent)
  end
  yourPokemon.name          = nickname
  yourPokemon.obtain_method = 2   # traded
  yourPokemon.reset_moves if resetmoves
  yourPokemon.record_first_moves
  $Trainer.pokedex.register(yourPokemon)
  $Trainer.pokedex.set_owned(yourPokemon.species)
  pbFadeOutInWithMusic {
    evo = PokemonTrade_Scene.new
    evo.pbStartScreen(myPokemon,yourPokemon,$Trainer.name,opponent.name)
    evo.pbTrade
    evo.pbEndScreen
  }
  $Trainer.party[pokemonIndex] = yourPokemon
  refreshFollow(false)
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