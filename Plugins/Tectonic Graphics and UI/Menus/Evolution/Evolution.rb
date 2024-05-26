class PokemonEvolutionScene
    private

    def pbGenerateMetafiles(s1x,s1y,s2x,s2y)
      sprite  = SpriteMetafile.new
      sprite.ox      = s1x
      sprite.oy      = s1y
      sprite.opacity = 255
      sprite2 = SpriteMetafile.new
      sprite2.ox      = s2x
      sprite2.oy      = s2y
      sprite2.zoom    = 0.0
      sprite2.opacity = 255
      alpha = 0
      alphaDiff = 10*20/Graphics.frame_rate
      loop do
        sprite.color.red   = 255
        sprite.color.green = 255
        sprite.color.blue  = 255
        sprite.color.alpha = alpha
        sprite.color  = sprite.color
        sprite2.color = sprite.color
        sprite2.color.alpha = 255
        sprite.update
        sprite2.update
        break if alpha>=255
        alpha += alphaDiff
      end
      totaltempo   = 0
      currenttempo = 25
      maxtempo = 7*Graphics.frame_rate
      while totaltempo<maxtempo
        for j in 0...currenttempo
          if alpha<255
            sprite.color.red   = 255
            sprite.color.green = 255
            sprite.color.blue  = 255
            sprite.color.alpha = alpha
            sprite.color = sprite.color
            alpha += 10
          end
          sprite.zoom  = [1.1*(currenttempo-j-1)/currenttempo,1.0].min
          sprite2.zoom = [1.1*(j+1)/currenttempo,1.0].min
          sprite.update
          sprite2.update
        end
        totaltempo += currenttempo
        if totaltempo+currenttempo<maxtempo
          for j in 0...currenttempo
            sprite.zoom  = [1.1*(j+1)/currenttempo,1.0].min
            sprite2.zoom = [1.1*(currenttempo-j-1)/currenttempo,1.0].min
            sprite.update
            sprite2.update
          end
        end
        totaltempo += currenttempo
        currenttempo = [(currenttempo/1.5).floor,5].max
      end
      @metafile1 = sprite
      @metafile2 = sprite2
    end
  
    public
  
    def pbUpdate(animating=false)
      if animating      # Pokémon shouldn't animate during the evolution animation
        @sprites["background"].update
      else
        pbUpdateSpriteHash(@sprites)
      end
    end
  
    def pbUpdateNarrowScreen
      halfResizeDiff = 8*20/Graphics.frame_rate
      if @bgviewport.rect.y<80
        @bgviewport.rect.height -= halfResizeDiff*2
        if @bgviewport.rect.height<Graphics.height-64
          @bgviewport.rect.y += halfResizeDiff
          @sprites["background"].oy = @bgviewport.rect.y
        end
      end
    end
  
    def pbUpdateExpandScreen
      halfResizeDiff = 8*20/Graphics.frame_rate
      if @bgviewport.rect.y>0
        @bgviewport.rect.y -= halfResizeDiff
        @sprites["background"].oy = @bgviewport.rect.y
      end
      if @bgviewport.rect.height<Graphics.height
        @bgviewport.rect.height += halfResizeDiff*2
      end
    end

    def flashToFinalState(canceled = false,oldstate=nil,oldstate2=nil)
      flashInOut {
        if canceled
          pbRestoreSpriteState(@sprites["rsprite1"],oldstate)
          pbRestoreSpriteState(@sprites["rsprite2"],oldstate2)
          @sprites["rsprite1"].zoom_x      = 1.0
          @sprites["rsprite1"].zoom_y      = 1.0
          @sprites["rsprite1"].color.alpha = 0
          @sprites["rsprite1"].visible     = true
          @sprites["rsprite2"].visible     = false
        else
          @sprites["rsprite1"].visible     = false
          @sprites["rsprite2"].visible     = true
          @sprites["rsprite2"].zoom_x      = 1.0
          @sprites["rsprite2"].zoom_y      = 1.0
          @sprites["rsprite2"].color.alpha = 0
        end
      }
    end
  
    def flashInOut(&block)
      tone = 0
      toneDiff = 20*20/Graphics.frame_rate
      loop do
        Graphics.update
        pbUpdate(true)
        pbUpdateExpandScreen
        tone += toneDiff
        @viewport.tone.set(tone,tone,tone,0)
        break if tone>=255
      end
      @bgviewport.rect.y      = 0
      @bgviewport.rect.height = Graphics.height
      @sprites["background"].oy = 0
      
      block&.call

      (Graphics.frame_rate/4).times do
        Graphics.update
        pbUpdate(true)
      end
      tone = 255
      toneDiff = 40*20/Graphics.frame_rate
      loop do
        Graphics.update
        pbUpdate
        tone -= toneDiff
        @viewport.tone.set(tone,tone,tone,0)
        break if tone<=0
      end
    end
  
    def pbStartScreen(pokemon,newspecies)
      @pokemon = pokemon
      @newspecies = newspecies
      @sprites = {}
      @bgviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @bgviewport.z = 99999
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      @msgviewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @msgviewport.z = 99999
      addBackgroundOrColoredPlane(@sprites,"background","evolutionbg",
         Color.new(248,248,248),@bgviewport)

      rsprite1 = PokemonSprite.new(@viewport)
      rsprite1.setOffset(PictureOrigin::Center)
      rsprite1.setPokemonBitmap(@pokemon,false)
      rsprite1.x = Graphics.width/2
      rsprite1.y = (Graphics.height-64)/2

      rsprite2 = PokemonSprite.new(@viewport)
      rsprite2.setOffset(PictureOrigin::Center)
      rsprite2.setPokemonBitmapSpecies(@pokemon,@newspecies,false)
      rsprite2.x       = rsprite1.x
      rsprite2.y       = rsprite1.y
      rsprite2.opacity = 0
      
      @sprites["rsprite1"] = rsprite1
      @sprites["rsprite2"] = rsprite2
      pbGenerateMetafiles(rsprite1.ox,rsprite1.oy,rsprite2.ox,rsprite2.oy)
      @sprites["msgwindow"] = pbCreateMessageWindow(@msgviewport)
      pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbEndScreen
      pbDisposeMessageWindow(@sprites["msgwindow"])
      pbFadeOutAndHide(@sprites) { pbUpdate }
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      @bgviewport.dispose
      @msgviewport.dispose
      $PokemonTemp.dependentEvents.refresh_sprite(false)
    end

    # Opens the evolution screen
    def pbEvolution(cancancel = true)
        if $PokemonSystem.quick_evolution == 0
          pbBGMStop
          @pokemon.play_cry
          pbMessageDisplay(@sprites["msgwindow"],
          _INTL("\\se[]What? {1} is evolving!\\^", @pokemon.name)) { pbUpdate }
          pbMessageWaitForInput(@sprites["msgwindow"], 20, true) { pbUpdate }
          pbPlayDecisionSE
          pbMEPlay("Evolution start")
          flashInOut {
            @sprites["rsprite1"].opacity = 0
            @sprites["rsprite2"].opacity = 255
          }
        else
          metaplayer1 = SpriteMetafilePlayer.new(@metafile1, @sprites["rsprite1"])
          metaplayer2 = SpriteMetafilePlayer.new(@metafile2, @sprites["rsprite2"])
          metaplayer1.play
          metaplayer2.play
          pbBGMStop
          @pokemon.play_cry
          pbMessageDisplay(@sprites["msgwindow"],
            _INTL("\\se[]What? {1} is evolving!\\^", @pokemon.name)) { pbUpdate }
          pbMessageWaitForInput(@sprites["msgwindow"], 50, true) { pbUpdate }
          pbPlayDecisionSE
          oldstate  = pbSaveSpriteState(@sprites["rsprite1"])
          oldstate2 = pbSaveSpriteState(@sprites["rsprite2"])
          pbMEPlay("Evolution start")
          pbBGMPlay("Evolution")
          canceled = false
          begin
              pbUpdateNarrowScreen
              metaplayer1.update
              metaplayer2.update
              Graphics.update
              Input.update
              pbUpdate(true)
              if Input.trigger?(Input::BACK) && cancancel
                  pbBGMStop
                  pbPlayCancelSE
                  canceled = true
                  break
              end
          end while metaplayer1.playing? && metaplayer2.playing?
          flashToFinalState(canceled, oldstate, oldstate2)
        end
        if canceled
            pbMessageDisplay(@sprites["msgwindow"],
               _INTL("Huh? {1} stopped evolving!", @pokemon.name)) { pbUpdate }
            return false
        else
            pbEvolutionSuccess
            return true
        end
    end

    def pbEvolutionSuccess
        # Play cry of evolved species
        frames = GameData::Species.cry_length(@newspecies, @pokemon.form)
        pbBGMStop
        Pokemon.play_cry(@newspecies, @pokemon.form)
        frames.times do
            Graphics.update
            pbUpdate
        end
        # Success jingle/message
        pbMEPlay("Evolution success")
        newspeciesname = GameData::Species.get(@newspecies).name
        pbMessageDisplay(@sprites["msgwindow"],
           _INTL("\\se[]Congratulations! Your {1} evolved into {2}!\\wt[80]",
           @pokemon.name, newspeciesname)) { pbUpdate }
        @sprites["msgwindow"].text = ""
        # Check for consumed item and check if Pokémon should be duplicated
        pbEvolutionMethodAfterEvolution

        showPokemonChanges(@pokemon) do
            @pokemon.species = @newspecies
            @pokemon.form    = 0 if @pokemon.isSpecies?(:MOTHIM)
            @pokemon.calc_stats
        end

        # See and own evolved species
        $Trainer.pokedex.register(@pokemon)
        $Trainer.pokedex.set_owned(@newspecies)

        # Learn moves upon evolution for evolved species
        unless $PokemonSystem.prompt_level_moves == 1
            movelist = @pokemon.getMoveList
            for i in movelist
                next if i[0] != 0 && i[0] != @pokemon.level # 0 is "learn upon evolution"
                pbLearnMove(@pokemon, i[1], true) { pbUpdate }
            end
        end

        @pokemon.changeHappiness("evolution")
    end

    def pbEvolutionMethodAfterEvolution
        @pokemon.action_after_evolution(@newspecies)
      end

    def self.pbDuplicatePokemon(pkmn, new_species)
        new_pkmn = pkmn.clone
        new_pkmn.species   = new_species
        new_pkmn.name      = nil
        new_pkmn.markings  = 0
        new_pkmn.poke_ball = :POKEBALL
        new_pkmn.removeItems
        new_pkmn.clearAllRibbons
        new_pkmn.calc_stats
        new_pkmn.heal
        # Add duplicate Pokémon to party
        $Trainer.party.push(new_pkmn)
        # See and own duplicate Pokémon
        $Trainer.pokedex.register(new_pkmn)
        $Trainer.pokedex.set_owned(new_species)
    end
end