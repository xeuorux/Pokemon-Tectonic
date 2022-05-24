class PokemonTilesetScene
  def initialize
    @tilesets_data = load_data("Data/Tilesets.rxdata")
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Tileset Editor\r\nA/S: SCROLL\r\nZ: MENU\r\nD: ADV. EDITS"),
       TILESET_WIDTH, 0, Graphics.width - TILESET_WIDTH, 160, @viewport)
    @sprites["tileset"] = BitmapSprite.new(TILESET_WIDTH, Graphics.height, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @visible_height = @sprites["tileset"].bitmap.height / TILE_SIZE
    load_tileset(1)
  end

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
            tileEditCommands[cmdSwapTile = tileEditCommands.length] = _INTL("Swap Tile")
            tileEditCommands[cmdInsertLines = tileEditCommands.length] = _INTL("Insert Lines After")
            tileEditCommands[cmdDeleteLines = tileEditCommands.length] = _INTL("Delete Lines Starting From")
            while true
              pbMessage(_INTL("Which tileset edit would you like to perform?"))
              tileCommand = pbShowCommands(nil, tileEditCommands, -1)

              if cmdRemoveUses > -1 && tileCommand == cmdRemoveUses
                selected = tile_ID_from_coordinates(@x, @y)
                applyChangeSetToAllMaps(@tileset.id,[[selected,0]])
                pbMessage(_INTL("Deleted all usages of this tile on all maps which use this tileset."))
                draw_overlay
              elsif cmdEraseTile > -1 && tileCommand == cmdEraseTile
                eraseTile()
              elsif cmdSwapTile > -1 && tileCommand == cmdSwapTile
                next if !swapTiles()
              elsif cmdInsertLines > -1 && tileCommand == cmdInsertLines
                next if !insertBlankLines()
              elsif cmdDeleteLines > -1 && tileCommand == cmdDeleteLines
                next if !deleteLines()
              end
              break
            end
          end
        end
        close_screen
    end

    def eraseTile()
      selected = tile_ID_from_coordinates(@x, @y)
      @tileset.terrain_tags[selected] = 0
      @tileset.priorities[selected] = 0
      @tileset.passages[selected] = 0x00

      # Add blank space on the tileset image file
      tilesetBitmap = RPG::Cache.load_bitmap("Graphics/Tilesets/", @tileset.tileset_name, 0)
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
      tilesetBitmap.to_file("Graphics/Tilesets/" + @tileset.tileset_name + '.png')

      if pbConfirmMessageSerious(_INTL("Delete all references to this tile?"))
        applyChangeSetToAllMaps(@tileset.id,[[selected,0]])
      end

      saveTileSetChanges()

      draw_tiles
      draw_overlay
    end

    def swapTiles()
      selectedA = tile_ID_from_coordinates(@x, @y)

      # Top left x, y
      firstPosition = [(@x) * TILE_SIZE,(@y - 1) * TILE_SIZE]

      # Width, height
      selectedWidth = TILE_SIZE
      selectedHeight = TILE_SIZE

      pbMessage(_INTL("Choose the tile to swap it with."))

      selectedB = nil
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
        elsif Input.trigger?(Input::USE)
          selectedB = tile_ID_from_coordinates(@x, @y)
          break
        elsif Input.trigger?(Input::BACK)
          pbMessage(_INTL("Cancelling swap."))
          return
        end
      end

      if selectedB.nil?
        echoln("Unable to perform swap for some reason.")
        return
      end

      secondPosition = [(@x) * TILE_SIZE,(@y - 1) * TILE_SIZE]

      tempTerrainTag = @tileset.terrain_tags[selectedA]
      tempPriority = @tileset.priorities[selectedA]
      tempPassages = @tileset.passages[selectedA]

      @tileset.terrain_tags[selectedA] = @tileset.terrain_tags[selectedB]
      @tileset.priorities[selectedA] = @tileset.priorities[selectedB]
      @tileset.passages[selectedA] = @tileset.passages[selectedB]

      @tileset.terrain_tags[selectedB] = tempTerrainTag
      @tileset.priorities[selectedB] = tempPriority
      @tileset.passages[selectedB] = tempPassages

      # Edit the tileset image file
      tilesetBitmap = RPG::Cache.load_bitmap("Graphics/Tilesets/", @tileset.tileset_name, 0)
      for localX in 0..selectedWidth
        for localY in 0..selectedHeight
          firstX = firstPosition[0] + localX
          firstY = firstPosition[1] + localY - 2
          secondX = secondPosition[0] + localX
          secondY = secondPosition[1] + localY - 2
          tempPixel = tilesetBitmap.get_pixel(firstX,firstY)
          tilesetBitmap.set_pixel(firstX,firstY,tilesetBitmap.get_pixel(secondX,secondY))
          tilesetBitmap.set_pixel(secondX,secondY,tempPixel)
        end
      end
      tilesetBitmap.to_file("Graphics/Tilesets/" + @tileset.tileset_name + '.png')

      swapTilesOnAllMaps(@tileset.id,selectedA,selectedB)

      saveTileSetChanges()
    end

    def insertBlankLines
      rowsToAdd = 1
      params = ChooseNumberParams.new
      params.setRange(0, 99)
      params.setDefaultValue(0)
      rowsToAdd = pbMessageChooseNumber(_INTL("How many blank rows would you like to add after this one?"), params)
      return false if rowsToAdd.nil? || rowsToAdd == 0

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
        (height + rowsToAdd).downto(nextLineY + rowsToAdd) do |y|
          for x in 0..TILES_PER_ROW do
            oldTileID = tile_ID_from_coordinates(x,y-rowsToAdd)
            newTildID = tile_ID_from_coordinates(x,y)
            table[newTildID] = table[oldTileID] || 0

            minTileID = oldTileID if oldTileID < minTileID
            maxTileID = oldTileID if oldTileID > maxTileID
          end
        end

        # Set the new rows to their default values
        (nextLineY + rowsToAdd).downto(nextLineY) do |y|
          for x in 0..TILES_PER_ROW do
            table[tile_ID_from_coordinates(x,y)] = 0
          end
        end
      end

      # Add blank space on the tileset image file
      echoln("Editing the tileset graphic file")
      tilesetBitmap = RPG::Cache.load_bitmap("Graphics/Tilesets/", @tileset.tileset_name, 0)
      offsetPixelsY = TILE_SIZE * rowsToAdd
      newTileSetBitmap = Bitmap.new(tilesetBitmap.width,tilesetBitmap.height + offsetPixelsY)
      blankColor = Color.new(0,0,0,0)
      firstPixelOfBlankY = (nextLineY - 1) * TILE_SIZE
      lastPixelOfBlankY = firstPixelOfBlankY + offsetPixelsY
      for x in 0..newTileSetBitmap.width
        for y in 0..newTileSetBitmap.height
          if y < firstPixelOfBlankY
            color = tilesetBitmap.get_pixel(x,y)
            newTileSetBitmap.set_pixel(x,y,color)
          elsif y >= firstPixelOfBlankY && y <= lastPixelOfBlankY
            newTileSetBitmap.set_pixel(x,y,blankColor)
          else
            color = tilesetBitmap.get_pixel(x,y - offsetPixelsY)
            newTileSetBitmap.set_pixel(x,y,color)
          end
        end
      end
      newTileSetBitmap.to_file("Graphics/Tilesets/" + @tileset.tileset_name + '.png')

      offsetTilesOnAllMaps(@tileset.id,TILES_PER_ROW * rowsToAdd,[minTileID,maxTileID])

      saveTileSetChanges()

      draw_tiles
      draw_overlay
      return true
    end

    def deleteLines
      rowsToDelete = 1
      params = ChooseNumberParams.new
      params.setRange(0, 99)
      params.setDefaultValue(0)
      rowsToDelete = pbMessageChooseNumber(_INTL("How many rows would you like to delete, starting with this one?"), params)
      return false if rowsToDelete.nil? || rowsToDelete == 0

      lineStartID = tile_ID_from_coordinates(0, @y)

      height = ((@tileset.terrain_tags.xsize - TILESET_START_ID) / TILES_PER_ROW) + 1

      # Copy all tileset metadata some number of rows down
      minTileID = 999999
      maxTileID = 0
      [@tileset.terrain_tags,@tileset.priorities,@tileset.passages].each_with_index do |table,index|
        echoln("Editing metadata table #{index}")

        # Move down the existing rows
        for y in @y..(height - rowsToDelete)
          for x in 0..TILES_PER_ROW do
            newTildID = tile_ID_from_coordinates(x,y)
            oldTileID = tile_ID_from_coordinates(x,y+rowsToDelete)
            table[newTildID] = table[oldTileID] || 0

            minTileID = oldTileID if oldTileID < minTileID
            maxTileID = oldTileID if oldTileID > maxTileID
          end
        end

        # Delete the last rows
        #table.slice!(0,height-rowsToDelete)
      end

      # Remove rows on the tileset image file
      echoln("Editing the tileset graphic file")
      tilesetBitmap = RPG::Cache.load_bitmap("Graphics/Tilesets/", @tileset.tileset_name, 0)
      offsetPixelsY = TILE_SIZE * rowsToDelete
      newTileSetBitmap = Bitmap.new(tilesetBitmap.width,tilesetBitmap.height - offsetPixelsY)
      firstPixelOfRemovedY = (@y - 1) * TILE_SIZE
      for x in 0..newTileSetBitmap.width
        for y in 0..newTileSetBitmap.height
          if y < firstPixelOfRemovedY
            color = tilesetBitmap.get_pixel(x,y)
            newTileSetBitmap.set_pixel(x,y,color)
          elsif y >= firstPixelOfRemovedY
            color = tilesetBitmap.get_pixel(x,y + offsetPixelsY)
            newTileSetBitmap.set_pixel(x,y,color)
          end
        end
      end
      newTileSetBitmap.to_file("Graphics/Tilesets/" + @tileset.tileset_name + '.png')

      offsetTilesOnAllMaps(@tileset.id,-TILES_PER_ROW * rowsToDelete,[minTileID,maxTileID])

      saveTileSetChanges()

      draw_tiles
      draw_overlay
      return true
    end

    # A changeset is an array of old tileIDs to new tileIDs
    def applyChangeSetToAllMaps(tileSetID,changeSet)
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

          # For single space and layer of the map, apply the offset if the existing tile is within the given range
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

    def swapTilesOnAllMaps(tileSetID,firstTile,secondTile)
      echoln("Swapping tiles #{firstTile} and #{secondTile} to all maps using tileset #{tileSetID}.")

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
                if currentID == firstTile
                  map.data[x,y,z] = secondTile
                  anyChanges = true
                elsif currentID == secondTile
                  map.data[x,y,z] = firstTile
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