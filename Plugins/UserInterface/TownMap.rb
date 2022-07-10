class PokemonRegionMap_Scene
  def pbStartScene(aseditor=false,mode=0)
    @editor = aseditor
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @mapdata = pbLoadTownMapData
    
    # Get the player position metadata of either the current map
    # Or the lowest parent map in the hierarchy, if possible
    mapInfos = pbLoadMapInfos
    mapIDChecking = $game_map.map_id
    playerpos = nil
    while mapIDChecking >= 1 && playerpos.nil?
      map_metadata = GameData::MapMetadata.try_get(mapIDChecking)
      if map_metadata.nil? || map_metadata.town_map_position.nil?
        mapIDChecking = mapInfos[mapIDChecking].parent_id
      else
        playerpos = map_metadata.town_map_position
      end
    end

    if !playerpos
      mapindex = 0
      @map     = @mapdata[0]
      @mapX    = LEFT
      @mapY    = TOP
    elsif @region>=0 && @region!=playerpos[0] && @mapdata[@region]
      mapindex = @region
      @map     = @mapdata[@region]
      @mapX    = LEFT
      @mapY    = TOP
    else
      mapindex = playerpos[0]
      @map     = @mapdata[playerpos[0]]
      @mapX    = playerpos[1]
      @mapY    = playerpos[2]
      mapsize = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0]>0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length*1.0/mapsize[0]).ceil
        if sqwidth>1
          @mapX += ($game_player.x*sqwidth/$game_map.width).floor
        end
        if sqheight>1
          @mapY += ($game_player.y*sqheight/$game_map.height).floor
        end
      end
    end
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    addBackgroundOrColoredPlane(@sprites,"background","mapbg",Color.new(0,0,0),@viewport)
    @sprites["map"] = IconSprite.new(0,0,@viewport)
    @sprites["map"].setBitmap("Graphics/Pictures/#{@map[1]}")
    @sprites["map"].x += (Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["map"].y += (Graphics.height-@sprites["map"].bitmap.height)/2
    for hidden in Settings::REGION_MAP_EXTRAS
      if hidden[0]==mapindex && ((@wallmap && hidden[5]) ||
         (!@wallmap && hidden[1]>0 && $game_switches[hidden[1]]))
        if !@sprites["map2"]
          @sprites["map2"] = BitmapSprite.new(480,320,@viewport)
          @sprites["map2"].x = @sprites["map"].x
          @sprites["map2"].y = @sprites["map"].y
        end
        pbDrawImagePositions(@sprites["map2"].bitmap,[
           ["Graphics/Pictures/#{hidden[4]}",hidden[2]*SQUAREWIDTH,hidden[3]*SQUAREHEIGHT]
        ])
      end
    end
    @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].mapname     = pbGetMessage(MessageTypes::RegionNames,mapindex)
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX,@mapY)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX,@mapY)
    if playerpos && mapindex==playerpos[0]
      @sprites["player"] = IconSprite.new(0,0,@viewport)
      @sprites["player"].setBitmap(GameData::TrainerType.player_map_icon_filename($Trainer.trainer_type))
      @sprites["player"].x = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
      @sprites["player"].y = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    end
    if mode>0
      k = 0
      for i in LEFT..RIGHT
        for j in TOP..BOTTOM
          healspot = pbGetHealingSpot(i,j)
          if healspot && $PokemonGlobal.visitedMaps[healspot[0]]
            @sprites["point#{k}"] = AnimatedSprite.create("Graphics/Pictures/mapFly",2,16)
            @sprites["point#{k}"].viewport = @viewport
            @sprites["point#{k}"].x        = -SQUAREWIDTH/2+(i*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
            @sprites["point#{k}"].y        = -SQUAREHEIGHT/2+(j*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
            @sprites["point#{k}"].play
            k += 1
          end
        end
      end
    end
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/mapCursor",2,5)
    @sprites["cursor"].viewport = @viewport
    @sprites["cursor"].x        = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y        = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    @sprites["cursor"].play
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
    return true
  end
end