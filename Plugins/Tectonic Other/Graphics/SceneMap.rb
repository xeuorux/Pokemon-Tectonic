class Scene_Map
    attr_reader :map_renderer

    def createSpritesets
        @map_renderer = TilemapRenderer.new(Spriteset_Map.viewport) if !@map_renderer || @map_renderer.disposed?
        @spritesetGlobal = Spriteset_Global.new if !@spritesetGlobal
        @spritesets = {}	
        for map in $MapFactory.maps	
          @spritesets[map.map_id] = Spriteset_Map.new(map)	
        end	
        $MapFactory.setSceneStarted(self)	
        updateSpritesets(true)	
    end

    def updateSpritesets(refresh = false)
        @spritesets = {} if !@spritesets
        $MapFactory.maps.each do |map|
            @spritesets[map.map_id] = Spriteset_Map.new(map) if !@spritesets[map.map_id]
        end
        keys = @spritesets.keys.clone
        for i in keys
          if !$MapFactory.hasMap?(i)
            @spritesets[i].dispose if @spritesets[i]
            @spritesets[i] = nil
            @spritesets.delete(i)
          else
            @spritesets[i].update
          end
        end
        @spritesetGlobal.update
        for map in $MapFactory.maps
          @spritesets[map.map_id] = Spriteset_Map.new(map) if !@spritesets[map.map_id]
        end
        @map_renderer.refresh if refresh
        @map_renderer.update
        Events.onMapUpdate.trigger(self)
    end

    def miniupdate
      if UnrealTime::ENABLED && UnrealTime::TALK_PASS && UnrealTime::TIME_STOPS
        $PokemonGlobal.addNewFrameCount
      end
      $PokemonTemp.miniupdate = true
      loop do
        updateMaps
        $game_player.update
        $game_system.update
        $game_screen.update
        break unless $game_temp.player_transferring
        transfer_player
        break if $game_temp.transition_processing
      end
      updateSpritesets
      $PokemonTemp.miniupdate = false
    end

    def update
      $PokemonGlobal.addNewFrameCount if UnrealTime::ENABLED && UnrealTime::TIME_STOPS
      loop do
        updateMaps
        pbMapInterpreter.update
        $game_player.update
        $game_system.update
        $game_screen.update
        break unless $game_temp.player_transferring
        transfer_player
        break if $game_temp.transition_processing
      end
      updateSpritesets
      if $game_temp.to_title
        $scene = pbCallTitle
        return
      end
      if $game_temp.transition_processing
        $game_temp.transition_processing = false
        if $game_temp.transition_name == ""
          Graphics.transition(20)
        else
          Graphics.transition(40, "Graphics/Transitions/" + $game_temp.transition_name)
        end
      end
      return if $game_temp.message_window_showing
      if !pbMapInterpreterRunning?
        if Input.trigger?(Input::USE)
          $PokemonTemp.hiddenMoveEventCalling = true
        elsif Input.trigger?(Input::BACK)
          unless $game_system.menu_disabled || $game_player.moving?
            $game_temp.menu_calling = true
            $game_temp.menu_beep = true
          end
        elsif Input.trigger?(Input::SPECIAL)
          unless $game_player.moving?
            $PokemonTemp.keyItemCalling = true
          end
        elsif Input.trigger?(Input::AUX2)
            #unless $game_player.moving?
              $PokemonTemp.bicycleCalling = true
            #end
        elsif Input.trigger?(Input::AUX1)
            unless $game_system.menu_disabled or $game_player.moving?
              if savingAllowed?
                $game_temp.save_calling = true
                $game_temp.menu_beep = true
              else
                showSaveBlockMessage()
              end
            end
        elsif Input.press?(Input::F9)
            $game_temp.debug_calling = true if $DEBUG
          end
        end
        unless $game_player.moving?
          if $game_temp.menu_calling
            call_menu
          elsif $game_temp.debug_calling
            call_debug
          elsif $game_temp.save_calling
            call_save
          elsif $PokemonTemp.keyItemCalling
            $PokemonTemp.keyItemCalling = false
            $game_player.straighten
            pbUseKeyItem
          elsif $PokemonTemp.hiddenMoveEventCalling
            $PokemonTemp.hiddenMoveEventCalling = false
            $game_player.straighten
            Events.onAction.trigger(self)
          end
        end
        if $PokemonTemp.bicycleCalling
          call_bike
        end
    end
    
    def call_save
      $game_temp.save_calling = false
      pbSEPlay("GUI save choice")
      if properlySave()
        pbMessage(_INTL("\\se[]{1} saved the game.\\me[GUI save game]",$Trainer.name))
      else
        pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
      end
    end
    
    def call_bike
      $PokemonTemp.bicycleCalling = false
      return unless $PokemonBag.pbHasItem?(:BICYCLE)
      pbUseKeyItemInField(:BICYCLE)
    end
end