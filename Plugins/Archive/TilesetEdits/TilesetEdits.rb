DebugMenuCommands.register("terraintags", {
  "parent"      => "editorsmenu",
  "name"        => _INTL("Edit Tileset"),
  "description" => _INTL("Edit tilesets by changing terrain tags, adding whitespace, swapping tiles around, etc."),
  "always_show" => true,
  "effect"      => proc {
    pbFadeOutIn { pbTilesetScreen }
  }
})

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
            tileEditCommands[cmdSwapTile = tileEditCommands.length] = _INTL("Swap Tiles")
            tileEditCommands[cmdInsertLines = tileEditCommands.length] = _INTL("Insert Lines After")
            tileEditCommands[cmdDeleteLines = tileEditCommands.length] = _INTL("Delete Lines Starting From")
            while true
              pbMessage(_INTL("Which tileset edit would you like to perform?"))
              tileCommand = pbShowCommands(nil, tileEditCommands, -1)

              if cmdRemoveUses > -1 && tileCommand == cmdRemoveUses
                selected = tile_ID_from_coordinates(@x, @y)
                applyChangeSetToAllMaps(@tileset.id,[[selected,0]])
                pbMessage(_INTL("Deleted all usages of this tile on all maps which use this tileset."))
              elsif cmdEraseTile > -1 && tileCommand == cmdEraseTile
                eraseTile()
              elsif cmdSwapTile > -1 && tileCommand == cmdSwapTile
                next if !swapTiles()
              elsif cmdInsertLines > -1 && tileCommand == cmdInsertLines
                next if !insertBlankLines()
              elsif cmdDeleteLines > -1 && tileCommand == cmdDeleteLines
                next if !deleteLines()
              end
              reload_tileset()
              break
            end
          end
        end
        close_screen
    end

    def reload_tileset()
      currentX = @x
      currentY = @y
      load_tileset(@tileset.id)
      @x = currentX
      @y = currentY
      draw_tiles
      draw_overlay
    end

    def draw_tile_details
      overlay = @sprites["overlay"].bitmap
      tile_x = Graphics.width * 3 / 4 - TILE_SIZE
      tile_y = Graphics.height / 2 - TILE_SIZE
      tile_id = tile_ID_from_coordinates(@x, @y) || 0
      # Draw tile (at 200% size)
      @tilehelper.bltSmallTile(overlay, tile_x, tile_y, TILE_SIZE * 2, TILE_SIZE * 2, tile_id)
      # Draw box around tile image
      overlay.fill_rect(tile_x - 1,             tile_y - 1,             TILE_SIZE * 2 + 2, 1, Color.new(255, 255, 255))
      overlay.fill_rect(tile_x - 1,             tile_y - 1,             1, TILE_SIZE * 2 + 2, Color.new(255, 255, 255))
      overlay.fill_rect(tile_x - 1,             tile_y + TILE_SIZE * 2, TILE_SIZE * 2 + 2, 1, Color.new(255, 255, 255))
      overlay.fill_rect(tile_x + TILE_SIZE * 2, tile_y - 1,             1, TILE_SIZE * 2 + 2, Color.new(255, 255, 255))
      # Write terrain tag info about selected tile
      terrain_tag = @tileset.terrain_tags[tile_id] || 0
      if GameData::TerrainTag.exists?(terrain_tag)
        terrain_tag_name = sprintf("%d: %s", terrain_tag, GameData::TerrainTag.get(terrain_tag).real_name)
      else
        terrain_tag_name = terrain_tag.to_s
      end
      textpos = [
        [_INTL("Terrain Tag:"), tile_x + TILE_SIZE, tile_y + TILE_SIZE * 2 + 10, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)],
        [terrain_tag_name, tile_x + TILE_SIZE, tile_y + TILE_SIZE * 2 + 42, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)],
        [_INTL("Tile ID:"), tile_x + TILE_SIZE, tile_y + TILE_SIZE * 2 + 70, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)],
        [tile_id.to_s, tile_x + TILE_SIZE, tile_y + TILE_SIZE * 2 + 102, 2, Color.new(248, 248, 248), Color.new(40, 40, 40)],
      ]
      # Draw all text
      pbDrawTextPositions(overlay, textpos)
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
    end

    def swapTiles()
      # Select the opposite corners of the first selection area
      selectedA1 = [@x,@y,tile_ID_from_coordinates(@x, @y)]
      
      pbMessage(_INTL("Select the bottom right tile of the first selection."))
      selectedA2 = selectTile()
      return if selectedA2.nil?

      # Calculate information about the first selection
      selectionAFirstPixel = [(selectedA1[0]) * TILE_SIZE,(selectedA1[1] - 1) * TILE_SIZE]
      selectionAWidth = selectedA2[0] - selectedA1[0] + 1
      selectionAHeight = selectedA2[1] - selectedA1[1] + 1

      if selectionAWidth <= 0 || selectionAHeight <= 0
        pbMessage(_INTL("Do not make selections with a negative height or width."))
        return
      end

      # Select the opposite corners of the second selection area
      selectedB1 = nil
      selectedB2 = nil
      selectionBFirstPixel = -1
      loop do
        pbMessage(_INTL("Select the top left tile of the second selection."))
        selectedB1 = selectTile()
        return if selectedB1.nil?

        pbMessage(_INTL("Select the bottom right tile of the second selection."))
        selectedB2 = selectTile()
        return if selectedB2.nil?

        # Calculate information about the second selection
        selectionBWidth = selectedB2[0] - selectedB1[0] + 1
        selectionBHeight = selectedB2[1] - selectedB1[1] + 1

        if selectionBWidth != selectionAWidth
          pbMessage(_INTL("The second selection must be the same width as the first (#{selectionAWidth})."))
        elsif selectionBHeight != selectionAHeight
          pbMessage(_INTL("The second selection must be the same height as the first (#{selectionAHeight})."))
        else
          selectionBFirstPixel = [(selectedB1[0]) * TILE_SIZE,(selectedB1[1] - 1) * TILE_SIZE]
          break
        end
      end

      selectionWidth = selectionAWidth
      selectionHeight = selectionAHeight
      selectionPixelWidth = selectionWidth * TILE_SIZE
      selectionPixelHeight = selectionHeight * TILE_SIZE

      echoln("Attempting to begin swap from SelectionA (#{selectedA1[0]},#{selectedA1[1]} to " +
        "#{selectedA2[0]},#{selectedA2[1]}) to SelectionB (#{selectedB1[0]},#{selectedB1[1]} to " +
        "#{selectedB2[0]},#{selectedB2[1]}) which should both be width (#{selectionWidth} and height #{selectionHeight}")

      # Edit the tileset metadata, and edit each map per tile changed
      for localX in 0..selectionWidth
        for localY in 0..selectionHeight
          firstX = selectedA1[0] + localX
          firstY = selectedA1[1] + localY
          firstId = tile_ID_from_coordinates(firstX,firstY)
          secondX = selectedB1[0] + localX
          secondY = selectedB1[1] + localY
          secondId = tile_ID_from_coordinates(firstX,firstY)

          tempTerrainTag = @tileset.terrain_tags[firstId]
          tempPriority = @tileset.priorities[firstId]
          tempPassages = @tileset.passages[firstId]

          @tileset.terrain_tags[firstId] = @tileset.terrain_tags[secondId]
          @tileset.priorities[firstId] = @tileset.priorities[secondId]
          @tileset.passages[firstId] = @tileset.passages[secondId]

          @tileset.terrain_tags[secondId] = tempTerrainTag
          @tileset.priorities[secondId] = tempPriority
          @tileset.passages[secondId] = tempPassages

          swapTilesOnAllMaps(@tileset.id,firstId,secondId)
        end
      end

      # Edit the tileset image file
      tilesetBitmap = RPG::Cache.load_bitmap("Graphics/Tilesets/", @tileset.tileset_name, 0)
      for localPixelX in 0..selectionPixelWidth-1
        for localPixelY in 0..selectionPixelHeight-1
          firstPixelX = selectionAFirstPixel[0] + localPixelX
          firstPixelY = selectionAFirstPixel[1] + localPixelY
          secondPixelX = selectionBFirstPixel[0] + localPixelX
          secondPixelY = selectionBFirstPixel[1] + localPixelY
          tempPixel = tilesetBitmap.get_pixel(firstPixelX,firstPixelY)
          tilesetBitmap.set_pixel(firstPixelX,firstPixelY,tilesetBitmap.get_pixel(secondPixelX,secondPixelY))
          tilesetBitmap.set_pixel(secondPixelX,secondPixelY,tempPixel)
        end
      end
      tilesetBitmap.to_file("Graphics/Tilesets/" + @tileset.tileset_name + '.png')

      saveTileSetChanges()
    end

    def selectTile()
      selectedTileInfo = nil
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
          selectedTileInfo = [@x,@y,tile_ID_from_coordinates(@x, @y)]
          break
        elsif Input.trigger?(Input::BACK)
          pbMessage(_INTL("Cancelling."))
          return nil
        end
      end
      return selectedTileInfo
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