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
            cmdRemoveUses = -1
            cmdEraseTile = -1
            cmdSwapTile = -1
            cmdInsertLine = -1
            cmdDeleteLine = -1
            

            tileEditCommands = [_INTL("Cancel")]
            tileEditCommands[cmdRemoveUses = tileEditCommands.length] = _INTL("Remove Tile Uses")
            tileEditCommands[cmdEraseTile = tileEditCommands.length] = _INTL("Erase Tile")
            tileEditCommands[cmdSwapTile = tileEditCommands.length] = _INTL("Swap Tile") if false
            tileEditCommands[cmdInsertLine = tileEditCommands.length] = _INTL("Insert Blank Line") if false
            tileEditCommands[cmdDeleteLine = tileEditCommands.length] = _INTL("Delete Line") if false
            pbMessage(_INTL("Which tileset edit would you like to perform?"))
            tileCommand = pbShowCommands(nil, tileEditCommands, -1)

            if cmdRemoveUses > -1 && tileCommand == cmdRemoveUses
              selected = tile_ID_from_coordinates(@x, @y)
              editTilesOnAllMaps(@tileset.id,[[selected,0]])
              pbMessage(_INTL("Deleted all usages of this tile on all maps which use this tileset."))
              draw_overlay
            elsif cmdEraseTile > -1 && tileCommand == cmdEraseTile
              selected = tile_ID_from_coordinates(@x, @y)
              @tileset.terrain_tags[selected] = 0
              @tileset.priorities[selected] = 0
              @tileset.passages[selected] = 0x00
              mapData.saveTilesets

              tileDrawer = TileDrawingHelper.fromTileset(@tileset)
              tileSetFileName = "Graphics/Tilesets/" + @tileset.tileset_name
              tilesetBitmap = AnimatedBitmap.new(tileSetFileName)
              bitmapTopLeftX = @x * TILE_SIZE
              bitmapTopLeftY = @y * TILE_SIZE
              bitmapBottomRightX = (@x + 1) * TILE_SIZE
              bitmapBottomRightY = (@y + 1) * TILE_SIZE
              blankColor = Color.new(0,0,0,0)
              for x in bitmapTopLeftX..bitmapBottomRightX
                for y in bitmapTopLeftY..bitmapBottomRightY
                  tilesetBitmap.set_pixel(x,y,blankColor)
                end
              end
              tilesetBitmap.to_file(tileSetFileName + '.png')
            elsif cmdInsertLine > -1 && tileCommand == cmdInsertLine
              # TODO
              # .insert()
            end
          end
        end
        close_screen
      end

    # A changeset is an array of old tileIDs to new tileIDs
    def editTilesOnAllMaps(tileSetID,changeSet)
        echoln("Applying a tile changeset to all maps using tileset #{tileSetID}.")

        # Iterate over all maps
        mapData = Compiler::MapData.new
        for id in mapData.mapinfos.keys.sort
            map = mapData.getMap(id)
            next if !map || !mapData.mapinfos[id]
            mapName = mapData.mapinfos[id].name

            # Skip the map unless it uses the tileset we're editing
            next unless map.tileset_id == tileSetID

            # Iterate over every single space and layer of the map, making all needed changes
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

            # If anything was actually changed, save the new map
            if anyChanges
              echoln("\tChanged #{mapName}")
              mapData.saveMap(id)
            end
        end
    end
end