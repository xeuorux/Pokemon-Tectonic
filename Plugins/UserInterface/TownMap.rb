class PokemonRegionMapScreen
  def pbStartWaypointScreen
    @scene.pbStartScene(false,2)
    ret = @scene.pbMapScene(2)
    @scene.pbEndScene
    return ret
  end
end

class PokemonRegionMap_Scene
  def pbStartScene(aseditor=false,mode=0)
    @editor = aseditor
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @mapdata = pbLoadTownMapData
    
    # Get the player position metadata of either the current map
    # Or the lowest parent map in the hierarchy, if possible
    playerpos = getDisplayedPositionOfGameMap($game_map.map_id)

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
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
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
    if mode == 1
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
    elsif mode == 2
      wayPointsUnlocked = $waypoints_tracker.activeWayPoints
      wayPointsUnlocked.each_with_index do |activeWaypoint,index|
        waypointName = activeWaypoint[0]
        waypointInfo = activeWaypoint[1]
        mapDisplayPosition = $waypoints_tracker.mapPositionHash[waypointName]
        if mapDisplayPosition.nil?
          pbMessage(_INTL("No proper map position is known for totem ID #{waypointName}. Please inform a programmer about this."))
          next
        end
        xPos = mapDisplayPosition[1]
        yPos = mapDisplayPosition[2]
        @sprites["point#{index}"] = AnimatedSprite.create("Graphics/Pictures/mapTotem",2,16)
        @sprites["point#{index}"].viewport = @viewport
        @sprites["point#{index}"].x        = -SQUAREWIDTH / 2 + (xPos * SQUAREWIDTH) + (Graphics.width - @sprites["map"].bitmap.width) / 2
        @sprites["point#{index}"].y        = -SQUAREHEIGHT / 2 + (yPos * SQUAREHEIGHT) + (Graphics.height - @sprites["map"].bitmap.height) / 2
        @sprites["point#{index}"].play
      end
    end
    @sprites["cursor"] = AnimatedSprite.create("Graphics/Pictures/mapCursor",2,5)
    @sprites["cursor"].viewport = @viewport
    @sprites["cursor"].x        = -SQUAREWIDTH / 2 + (@mapX * SQUAREWIDTH) + (Graphics.width - @sprites["map"].bitmap.width) / 2
    @sprites["cursor"].y        = -SQUAREHEIGHT / 2 + (@mapY * SQUAREHEIGHT) + (Graphics.height - @sprites["map"].bitmap.height) / 2
    @sprites["cursor"].play
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
    return true
  end

  def pbMapScene(mode=0)
    xOffset = 0
    yOffset = 0
    newX = 0
    newY = 0
    @sprites["cursor"].x = -SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y = -SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if xOffset!=0 || yOffset!=0
        distancePerFrame = 8*20/Graphics.frame_rate
        xOffset += (xOffset>0) ? -distancePerFrame : (xOffset<0) ? distancePerFrame : 0
        yOffset += (yOffset>0) ? -distancePerFrame : (yOffset<0) ? distancePerFrame : 0
        @sprites["cursor"].x = newX-xOffset
        @sprites["cursor"].y = newY-yOffset
        next
      end
      @sprites["mapbottom"].waypointName = $waypoints_tracker.getWaypointAtMapPosition(@mapX,@mapY) || ""
      @sprites["mapbottom"].maplocation = pbGetMapLocation(@mapX,@mapY)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@mapX,@mapY)
      ox = 0
      oy = 0
      case Input.dir8
      when 1   # lower left
        oy = 1 if @mapY<BOTTOM
        ox = -1 if @mapX>LEFT
      when 2   # down
        oy = 1 if @mapY<BOTTOM
      when 3   # lower right
        oy = 1 if @mapY<BOTTOM
        ox = 1 if @mapX<RIGHT
      when 4   # left
        ox = -1 if @mapX>LEFT
      when 6   # right
        ox = 1 if @mapX<RIGHT
      when 7   # upper left
        oy = -1 if @mapY>TOP
        ox = -1 if @mapX>LEFT
      when 8   # up
        oy = -1 if @mapY>TOP
      when 9   # upper right
        oy = -1 if @mapY>TOP
        ox = 1 if @mapX<RIGHT
      end
      if ox!=0 || oy!=0
        @mapX += ox
        @mapY += oy
        xOffset = ox*SQUAREWIDTH
        yOffset = oy*SQUAREHEIGHT
        newX = @sprites["cursor"].x+xOffset
        newY = @sprites["cursor"].y+yOffset
      end
      if Input.trigger?(Input::BACK)
        if @editor && @changed
          if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
            pbSaveMapData
          end
          if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
            break
          end
        else
          break
        end
      elsif Input.trigger?(Input::USE) && mode == 1   # Choosing an area to fly to
        healspot = pbGetHealingSpot(@mapX,@mapY)
        if healspot
          if $PokemonGlobal.visitedMaps[healspot[0]] || ($DEBUG && Input.press?(Input::CTRL))
            return healspot
          end
        end
      elsif Input.trigger?(Input::USE) && mode == 2  # Choosing an area to waypoint teleport to
        waypointAtSpot = $waypoints_tracker.getWaypointAtMapPosition(@mapX,@mapY)
        return waypointAtSpot if !waypointAtSpot.nil?
      elsif Input.trigger?(Input::USE) && @editor   # Intentionally after other USE input check
        pbChangeMapLocation(@mapX,@mapY)
      end
    end
    pbPlayCloseMenuSE
    return nil
  end
end

def getDisplayedPositionOfGameMap(gameMapID)
  mapInfos = pbLoadMapInfos
  displayedPosition = nil
  while gameMapID >= 1 && displayedPosition.nil?
    map_metadata = GameData::MapMetadata.try_get(gameMapID)
    if map_metadata.nil? || map_metadata.town_map_position.nil?
      gameMapID = mapInfos[gameMapID].parent_id
    else
      displayedPosition = map_metadata.town_map_position
    end
  end
  return displayedPosition
end

class MapBottomSprite < SpriteWrapper
  attr_reader :mapname
  attr_reader :maplocation
  attr_reader :waypointName

  def initialize(viewport=nil)
    super(viewport)
    @mapname     = ""
    @maplocation = ""
    @mapdetails  = ""
    @waypointName = ""
    @thisbitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
    pbSetSystemFont(@thisbitmap)
    self.x = 0
    self.y = 0
    self.bitmap = @thisbitmap
    refresh
  end

  def waypointName=(value)
    if @waypointName != value
      @waypointName = value
      refresh
    end
  end

  def refresh
    self.bitmap.clear
    textpos = [
       [@mapname,18,-8,0,Color.new(248,248,248),Color.new(0,0,0)],
       [@waypointName,Graphics.width-16,-8,1,Color.new(224,197,110),Color.new(0,0,0)],
       [@maplocation,18,348,0,Color.new(248,248,248),Color.new(0,0,0)],
       [@mapdetails,Graphics.width-16,348,1,Color.new(248,248,248),Color.new(0,0,0)]
    ]
    pbDrawTextPositions(self.bitmap,textpos)
  end
end