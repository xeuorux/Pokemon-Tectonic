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
              saveTileSetChanges()
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
            # Passges goes in this order
            # Counter Flag, Bush Flag, blank, blank, [directions here in some order]
            cmdRemoveUses = -1
            cmdEraseTile = -1
            cmdSwapTile = -1
            cmdInsertLines = -1
            cmdDeleteLines = -1

            tileEditCommands = [_INTL("Cancel")]
            tileEditCommands[cmdRemoveUses = tileEditCommands.length] = _INTL("Remove Tile Uses")
            tileEditCommands[cmdEraseTile = tileEditCommands.length] = _INTL("Erase Tile")
            tileEditCommands[cmdSwapTile = tileEditCommands.length] = _INTL("Swap Tile") if false
            tileEditCommands[cmdInsertLines = tileEditCommands.length] = _INTL("Insert Lines After")
            tileEditCommands[cmdDeleteLines = tileEditCommands.length] = _INTL("Delete Lines") if false
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
              @tileset.bush_flags[selected] = 0

              # Add blank space on the tileset image file
              tileSetFileName = "Graphics/Tilesets/" + @tileset.tileset_name
              tilesetBitmap = AnimatedBitmap.new(tileSetFileName).bitmap
              bitmapTopLeftX = (@x) * TILE_SIZE
              bitmapTopLeftY = (@y - 1) * TILE_SIZE
              bitmapBottomRightX = (@x + 1) * TILE_SIZE
              bitmapBottomRightY = (@y) * TILE_SIZE
              blankColor = Color.new(0,0,0,0)
              for x in bitmapTopLeftX..bitmapBottomRightX
                for y in bitmapTopLeftY..bitmapBottomRightY
                  tilesetBitmap.set_pixel(x,y,blankColor)
                end
              end
              tilesetBitmap.to_file(tileSetFileName + '.png')

              if pbConfirmMessageSerious(_INTL("Delete all references to this tile?"))
                applyChangesetToAllMaps(@tileset.id,[[selected,0]])
              end

              saveTileSetChanges()

              draw_tiles
              draw_overlay
            elsif cmdInsertLines > -1 && tileCommand == cmdInsertLines
              rowsAdded = 1
              params = ChooseNumberParams.new
              params.setRange(0, 99)
              params.setDefaultValue(1)
              rowsAdded = pbMessageChooseNumber(_INTL("How many blank rows would you like to add after this one?"), params)
              next if rowsAdded.nil? || rowsAdded == 0

              nextLineY = @y + 1
              nextLineStartX = 0
              lineStartID = tile_ID_from_coordinates(nextLineStartX, nextLineY)

              height = ((@tileset.terrain_tags.xsize - TILESET_START_ID) / TILES_PER_ROW) + 1

              # Copy all tileset metadata some number of rows down
              minTileID = 999999
              maxTileID = 0
              [@tileset.terrain_tags,@tileset.priorities,@tileset.passages].each_with_index do |table,index|
                echoln("Editing metadata table #{index}")

                # Move down the existing rows
                (height + rowsAdded).downto(nextLineY + rowsAdded) do |y|
                  for x in 0..TILES_PER_ROW do
                    oldTileID = tile_ID_from_coordinates(x,y-rowsAdded)
                    newTildID = tile_ID_from_coordinates(x,y)
                    table[newTildID] = table[oldTileID] || 0

                    minTileID = oldTileID if oldTileID < minTileID
                    maxTileID = oldTileID if oldTileID > maxTileID
                  end
                end

                # Set the new rows to their default values
                (nextLineY + rowsAdded).downto(nextLineY) do |y|
                  for x in 0..TILES_PER_ROW do
                    table[tile_ID_from_coordinates(x,y)] = 0
                  end
                end
              end

              # Add blank space on the tileset image file
              echoln("Editing the tileset graphic file")
              tileSetFileName = "Graphics/Tilesets/" + @tileset.tileset_name
              tilesetBitmap = AnimatedBitmap.new(tileSetFileName).bitmap
              newTileSetBitmap = Bitmap.new(tilesetBitmap.width,tilesetBitmap.height + TILE_SIZE * rowsAdded)
              blankColor = Color.new(0,0,0,0)
              firstPixelOfBlankY = (nextLineY - 1) * TILE_SIZE
              lastPixelOfBlankY = firstPixelOfBlankY + TILE_SIZE * rowsAdded
              for x in 0..newTileSetBitmap.width
                for y in 0..newTileSetBitmap.height
                  if y < firstPixelOfBlankY
                    color = tilesetBitmap.get_pixel(x,y)
                    newTileSetBitmap.set_pixel(x,y,color)
                  elsif y >= firstPixelOfBlankY && y <= lastPixelOfBlankY
                    newTileSetBitmap.set_pixel(x,y,blankColor)
                  else
                    color = tilesetBitmap.get_pixel(x,y - TILE_SIZE * rowsAdded)
                    newTileSetBitmap.set_pixel(x,y,color)
                  end
                end
              end
              newTileSetBitmap.to_file(tileSetFileName + '.png')

              offsetTilesOnAllMaps(@tileset.id,TILES_PER_ROW * rowsAdded,[minTileID,maxTileID])

              saveTileSetChanges()

              draw_tiles
              draw_overlay
            end
          end
        end
        close_screen
      end

    # A changeset is an array of old tileIDs to new tileIDs
    def applyChangesetToAllMaps(tileSetID,changeSet)
        echoln("Applying a tile changeset to all maps using tileset #{tileSetID}.")

        # Iterate over all maps
        mapData = Compiler::MapData.new
        for id in mapData.mapinfos.keys.sort
            map = mapData.getMap(id)
            next if !map || !mapData.mapinfos[id]
            mapName = mapData.mapinfos[id].name

            # Skip the map unless it uses the tileset we're editing
            next unless map.tileset_id == tileSetID

            # Iterate over every change, then every single space and layer of the map, making all tile changed for each change
            anyChanges = false
            changeSet.each do |change|
              for x in 0..map.data.xsize
                for y in 0..map.data.ysize
                  for z in 0...map.data.zsize
                    currentID = map.data[x, y, z]
                    next unless change[0] == currentID
                    map.data[x,y,z] = change[1]
                    anyChanges = true
                    #echoln("Swapping tile #{x},#{y},#{z} on map #{mapName}")
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

    def offsetTilesOnAllMaps(tileSetID,offset,range)
      echoln("Applying a bounded offset to all maps using tileset #{tileSetID} and on tile ID range #{range[0]} to #{range[1]}.")

      # Iterate over all maps
      mapData = Compiler::MapData.new
      for id in mapData.mapinfos.keys.sort
          map = mapData.getMap(id)
          next if !map || !mapData.mapinfos[id]
          mapName = mapData.mapinfos[id].name

          # Skip the map unless it uses the tileset we're editing
          next unless map.tileset_id == tileSetID

          # Iterate over every change, then every single space and layer of the map, making all tile changed for each change
          anyChanges = false
          for x in 0..map.data.xsize
            for y in 0..map.data.ysize
              for z in 0...map.data.zsize
                currentID = map.data[x, y, z]
                next if currentID.nil?
                next unless currentID >= range[0] && currentID <= range[1]
                map.data[x,y,z] += offset
                anyChanges = true
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

    def saveTileSetChanges
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
end