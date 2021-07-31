class HallOfFame_Scene
	# Speed in pokémon movement in hall entry. Don't use less than 2!
	ANIMATIONSPEED = 24
	# Entry wait time (in 1/20 seconds) between showing each Pokémon (and trainer)
	ENTRYWAITTIME = 42
	
	attr_accessor :league


  def pbUpdateAnimation
    if @battlerIndex<=@hallEntry.size
      if @xmovement[@battlerIndex]!=0 || @ymovement[@battlerIndex]!=0
        spriteIndex=(@battlerIndex<@hallEntry.size) ? @battlerIndex : -1
        moveSprite(spriteIndex)
      else
        @battlerIndex+=1
        if @battlerIndex<=@hallEntry.size
          # If it is a pokémon, write the pokémon text, wait the
          # ENTRYWAITTIME and goes to the next battler
          GameData::Species.play_cry_from_pokemon(@hallEntry[@battlerIndex - 1])
          writePokemonData(@hallEntry[@battlerIndex-1])
          (ENTRYWAITTIME*Graphics.frame_rate/20).times do
            Graphics.update
            Input.update
            pbUpdate
          end
          if @battlerIndex<@hallEntry.size   # Preparates the next battler
            setPokemonSpritesOpacity(@battlerIndex,OPACITY)
            @sprites["overlay"].bitmap.clear
          else   # Show the welcome message and preparates the trainer
            setPokemonSpritesOpacity(-1)
            writeWelcome
            (ENTRYWAITTIME*2*Graphics.frame_rate/20).times do
              Graphics.update
              Input.update
              pbUpdate
            end
            setPokemonSpritesOpacity(-1,OPACITY) if !SINGLEROW
            createTrainerBattler
          end
        end
      end
    elsif @battlerIndex>@hallEntry.size
      # Write the trainer data and fade
      writeTrainerData if @league
      (ENTRYWAITTIME*Graphics.frame_rate/20).times do
        Graphics.update
        Input.update
        pbUpdate
      end
      fadeSpeed=((Math.log(2**12)-Math.log(FINALFADESPEED))/Math.log(2)).floor
      pbBGMFade((2**fadeSpeed).to_f/20) if @useMusic
      slowFadeOut(@sprites,fadeSpeed) { pbUpdate }
      @alreadyFadedInEnd=true
      @battlerIndex+=1
    end
  end
end


def pbHallOfFameEntry(league=true)
  scene=HallOfFame_Scene.new
  scene.league = league
  screen=HallOfFameScreen.new(scene)
  screen.pbStartScreenEntry
end