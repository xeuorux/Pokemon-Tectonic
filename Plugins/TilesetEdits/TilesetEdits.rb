class PokemonTilesetScene
    def pbStartScene
        open_screen
        loop do
          Graphics.update
          Input.update
          if Input.repeat?(Input::UP)
            update_cursor_position(0, -1)
          elsif Input.repeat?(Input::DOWN)
            update_cursor_position(0, 1)
          elsif Input.repeat?(Input::LEFT)
            update_cursor_position(-1, 0)
          elsif Input.repeat?(Input::RIGHT)
            update_cursor_position(1, 0)
          elsif Input.repeat?(Input::JUMPUP)
            update_cursor_position(0, -@visible_height)
          elsif Input.repeat?(Input::JUMPDOWN)
            update_cursor_position(0, @visible_height)
          elsif Input.trigger?(Input::ACTION)
            commands = [
               _INTL("Go to bottom"),
               _INTL("Go to top"),
               _INTL("Change tileset"),
               _INTL("Cancel")
            ]
            case pbShowCommands(nil, commands, -1)
            when 0
              update_cursor_position(0, 99999)
            when 1
              update_cursor_position(0, -99999)
            when 2
              choose_tileset
            end
          elsif Input.trigger?(Input::BACK)
            if pbConfirmMessage(_INTL("Save changes?"))
              save_data(@tilesets_data, "Data/Tilesets.rxdata")
              $data_tilesets = @tilesets_data
              if $game_map && $MapFactory
                $MapFactory.setup($game_map.map_id)
                $game_player.center($game_player.x, $game_player.y)
                if $scene.is_a?(Scene_Map)
                  $scene.disposeSpritesets
                  $scene.createSpritesets
                end
              end
              pbMessage(_INTL("To ensure that the changes remain, close and reopen RPG Maker XP."))
            end
            break if pbConfirmMessage(_INTL("Exit from the editor?"))
          elsif Input.trigger?(Input::USE)
            selected = tile_ID_from_coordinates(@x, @y)
            params = ChooseNumberParams.new
            params.setRange(0, 99)
            params.setDefaultValue(@tileset.terrain_tags[selected])
            set_terrain_tag_for_tile_ID(selected, pbMessageChooseNumber(_INTL("Set the terrain tag."), params))
            draw_overlay
          elsif Input.trigger?(Input::SPECIAL)
            #selected = tile_ID_from_coordinates(@x, @y)
            #@tileset.terrain_tags[selected] = 0
            #@tileset.priorities[selected] = 0
            #@tileset.passages[selected] = 0x00
            #mapData.saveTilesets
            #editTilesOnAllMaps(@tileset.id,[[49,0]])
            draw_overlay
          end
        end
        close_screen
      end

    # A changeset is an array of old tileIDs to new tileIDs
    def editTilesOnAllMaps(tileSetID,changeSet)
        pbMessage("Applying a tile changeset to all maps using tileset #{tileSetID}.")
        mapData = Compiler::MapData.new
        for id in mapData.mapinfos.keys.sort
            map = mapData.getMap(id)
            next if !map || !mapData.mapinfos[id]
            mapName = mapData.mapinfos[id].name
            next unless map.tileset_id == tileSetID
            anyChanges = false
              for x in 0..map.data.xsize
                for y in 0..map.data.ysize
                  for z in 0...map.data.zsize
                    currentID = map.data[x, y, z]
                    changeSet.each do |change|
                      next unless change[0] == currentID
                      map.data[x,y,z] = change[1]
                      anyChanges = true
                      echoln("Swapping tile #{x},#{y},#{z} on map #{mapName}")
                      break
                    end
                  end
                end
              end
            if anyChanges
              echoln("\tChanged #{mapName}")
              mapData.saveMap(id)
            end
        end
    end
end