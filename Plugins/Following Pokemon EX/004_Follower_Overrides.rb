#-------------------------------------------------------------------------------
# Various edits to old functions to incorporate updating of Following Pokemon
#-------------------------------------------------------------------------------
def pbSurf
  return false if $game_player.pbFacingEvent
  return false if $game_player.pbHasDependentEvents?
  move = :SURF
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF,false) || (!$DEBUG && !movefinder)
    return false
  end
  if pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbCancelVehicles
    pbHiddenMoveAnimation(movefinder)
    surfbgm = GameData::Metadata.get.surf_BGM
    pbCueBGM(surfbgm,0.5) if surfbgm
    surf_anim = $PokemonTemp.dependentEvents.can_refresh?
    pbStartSurfing
    $PokemonTemp.dependentEvents.refresh_sprite(surf_anim) if !$PokemonTemp.dependentEvents.can_refresh?
    return true
  end
  return false
end

# Update after surfing
alias follow_pbEndSurf pbEndSurf
def pbEndSurf(_xOffset,_yOffset)
  hidden = !$PokemonTemp.dependentEvents.can_refresh?
  ret = follow_pbEndSurf(_xOffset,_yOffset)
  $PokemonGlobal.call_refresh = [true, hidden] if ret
end

# Update when starting diving to incorporate hiddden move animation
def pbDive
  return false if $game_player.pbFacingEvent
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  return false if !map_metadata || !map_metadata.dive_map_id
  move = :DIVE
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE,false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder,false)
    pbFadeOutIn {
       $game_temp.player_new_map_id    = map_metadata.dive_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = false
       $PokemonGlobal.diving  = true
       pbUpdateVehicle
       $scene.transfer_player(false)
       $game_map.autoplay
       $game_map.refresh
    }
    return true
  end
  return false
end

# Update when ending diving to incorporate hiddden move animation
def pbSurfacing
  return if !$PokemonGlobal.diving
  return false if $game_player.pbFacingEvent
  surface_map_id = nil
  GameData::MapMetadata.each do |map_data|
    next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
    surface_map_id = map_data.id
    break
  end
  return if !surface_map_id
  move = :DIVE
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE,false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
    return false
  end
  if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder,false)
    pbFadeOutIn {
       $game_temp.player_new_map_id    = surface_map_id
       $game_temp.player_new_x         = $game_player.x
       $game_temp.player_new_y         = $game_player.y
       $game_temp.player_new_direction = $game_player.direction
       $PokemonGlobal.surfing = true
       $PokemonGlobal.diving  = false
       pbUpdateVehicle
       $scene.transfer_player(false)
       surfbgm = GameData::Metadata.get.surf_BGM
       (surfbgm) ?  pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
       $game_map.refresh
    }
    return true
  end
  return false
end

# Update when starting Strength to incorporate hiddden move animation
HiddenMoveHandlers::UseMove.add(:STRENGTH,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon,false)
    pbMessage(_INTL("{1} used {2}!\1",pokemon.name,GameData::Move.get(move).name))
  end
  pbMessage(_INTL("{1}'s Strength made it possible to move boulders around!",pokemon.name))
  $PokemonMap.strengthUsed = true
  next true
})

# Update when starting Headbutt to incorporate hiddden move animation
def pbHeadbutt(event=nil)
  event = $game_player.pbFacingEvent(true)
  move = :HEADBUTT
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !$DEBUG && !movefinder
    pbMessage(_INTL("A Pokémon could be in this tree. Maybe a Pokémon could shake it."))
    return false
  end
  if pbConfirmMessage(_INTL("A Pokémon could be in this tree. Would you like to use Headbutt?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbHeadbuttEffect(event)
    return true
  end
  return false
end

# Update follower when mounting Bike
alias follow_pbDismountBike pbDismountBike
def pbDismountBike
  return if !$PokemonGlobal.bicycle
  ret = follow_pbDismountBike
  $PokemonTemp.dependentEvents.refresh_sprite(true)
  return ret
end

# Update follower when dismounting Bike
alias follow_pbMountBike pbMountBike
def pbMountBike
  ret = follow_pbMountBike
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  bike_anim = !(map_metadata && map_metadata.always_bicycle)
  $PokemonTemp.dependentEvents.refresh_sprite(bike_anim)
  return ret
end

# Update follower when any vehicle like Surf, Lava Surf etc are done
alias follow_pbCancelVehicles pbCancelVehicles
def pbCancelVehicles(destination = nil)
  $PokemonTemp.dependentEvents.refresh_sprite(false) if destination.nil?
  return follow_pbCancelVehicles(destination)
end

# Update follower after accessing TrainerPC
alias follow_pbTrainerPC pbTrainerPC
def pbTrainerPC
  follow_pbTrainerPC
  $PokemonTemp.dependentEvents.refresh_sprite(false)
end

# Update follower after accessing Poke Centre PC
alias follow_pbPokeCenterPC pbPokeCenterPC
def pbPokeCenterPC
  follow_pbPokeCenterPC
  $PokemonTemp.dependentEvents.refresh_sprite(false)
end


# Update follower after accessing Party Screen
class PokemonPartyScreen
  alias follow_pbEndScene pbEndScene
  def pbEndScene
    ret = follow_pbEndScene
    $PokemonTemp.dependentEvents.refresh_sprite(false)
    return ret
  end

  alias follow_pbPokemonScreen pbPokemonScreen
  def pbPokemonScreen
    ret = follow_pbPokemonScreen
    $PokemonTemp.dependentEvents.refresh_sprite(false)
    return ret
  end

  alias follow_pbSwitch pbSwitch
  def pbSwitch(oldid,newid)
    follow_pbSwitch(oldid,newid)
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end

  alias follow_pbRefresh pbRefresh
  def pbRefresh
    follow_pbRefresh
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end

  alias follow_pbRefreshSingle pbRefreshSingle
  def pbRefreshSingle(pkmnid)
    follow_pbRefreshSingle(pkmnid)
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

# Update follower after any kind of Evolution
class PokemonEvolutionScene
  alias follow_pbEndScreen pbEndScreen
  def pbEndScreen
    follow_pbEndScreen
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

class PokemonTrade_Scene
  alias follow_pbEndScreen pbEndScreen
  def pbEndScreen
    follow_pbEndScreen
    $PokemonTemp.dependentEvents.refresh_sprite(false)
  end
end

# Update follower after usage of Bag
class PokemonBagScreen
  alias follow_bagScene pbStartScreen
  def pbStartScreen
    ret = follow_bagScene
    $PokemonTemp.dependentEvents.refresh_sprite(false)
    return ret
  end
end

# Update follower after any Battle
class PokeBattle_Scene
  alias follow_pbEndBattle pbEndBattle
  def pbEndBattle(result)
    follow_pbEndBattle(result)
    $PokemonGlobal.call_refresh = [true,false]
  end
end

module Game
  class << self
    alias follower_load load
    def load(save_data)
      follower_load(save_data)
      $PokemonTemp.dependentEvents.refresh_sprite(false)
    end
  end
end

#-------------------------------------------------------------------------------
# Various updates to Player class to incorporate Followers
#-------------------------------------------------------------------------------
class Game_Player < Game_Character

# Edit the dependent event check to account for followers
  def pbHasDependentEvents?
    return false if pbGetFollowerDependentEvent
    return $PokemonGlobal.dependentEvents.length>0
  end

#Update follower's time_taken
  alias follow_update update
  def update
    follow_update
    $PokemonTemp.dependentEvents.add_following_time if $PokemonTemp.dependentEvents.can_refresh?
  end

# Always update follower if the player is moving
  alias follow_moveto moveto
  def moveto(x,y)
    ret = follow_moveto(x,y)
    events = $PokemonGlobal.dependentEvents
    leader = $game_player
    for i in 0...events.length
      event = $PokemonTemp.dependentEvents.realEvents[i]
      $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps(leader,event,true,i==0)
    end
    return ret
  end
end

#-------------------------------------------------------------------------------
# Various updates to Character Sprites to incorporate Reflection and Footprints
#-------------------------------------------------------------------------------

# New method to add reflection to followers
class Sprite_Character
  def setReflection(event, viewport)
    @reflection = Sprite_Reflection.new(self,event,viewport) if !@reflection
  end

  attr_accessor :steps

  # Change the initialize and update method to add Footprints
  if defined?(footsteps_initialize)
  alias follow_init footsteps_initialize

  def initialize(viewport, character = nil, is_follower = false)
    @viewport = viewport
    @is_follower = is_follower
    follow_init(@viewport, character)
    @steps = []
  end

  def update
    follow_update
    @old_x ||= @character.x
    @old_y ||= @character.y
    if (@character.x != @old_x || @character.y != @old_y) && !["", "nil"].include?(@character.character_name)
      if @character == $game_player && $PokemonTemp.dependentEvents &&
         $PokemonTemp.dependentEvents.respond_to?(:realEvents) &&
         $PokemonTemp.dependentEvents.realEvents.select { |e| !["", "nil"].include?(e.character_name) }.size > 0 &&
         !DUPLICATE_FOOTSTEPS_WITH_FOLLOWER
        if !EVENTNAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].name) &&
           !FILENAME_MAY_NOT_INCLUDE.include?($PokemonTemp.dependentEvents.realEvents[0].character_name)
          make_steps = false
        else
          make_steps = true
        end
      elsif @character.respond_to?(:name) && !(EVENTNAME_MAY_NOT_INCLUDE.include?(@character.name) && FILENAME_MAY_NOT_INCLUDE.include?(@character.character_name))
        tilesetid = @character.map.instance_eval { @map.tileset_id }
        make_steps = [2,1,0].any? do |e|
          tile_id = @character.map.data[@old_x, @old_y, e]
          next false if tile_id.nil?
          next $data_tilesets[tilesetid].terrain_tags[tile_id] == PBTerrain::Sand
        end
      end
      if make_steps
        fstep = Sprite.new(self.viewport)
        fstep.z = 0
        dirs = [nil,"DownLeft","Down","DownRight","Left","Still","Right","UpLeft",
            "Up", "UpRight"]
        if @character == $game_player && $PokemonGlobal.bicycle
          fstep.bmp("Graphics/Characters/Footprints/steps#{dirs[@character.direction]}Bike")
        else
          fstep.bmp("Graphics/Characters/Footprints/steps#{dirs[@character.direction]}")
        end
        @steps ||= []
        if @character == $game_player && $PokemonGlobal.bicycle
          x = BIKE_X_OFFSET
          y = BIKE_Y_OFFSET
        else
          x = WALK_X_OFFSET
          y = WALK_Y_OFFSET
        end
        @steps << [fstep, @character.map, @old_x + x / Game_Map::TILE_WIDTH.to_f, @old_y + y / Game_Map::TILE_HEIGHT.to_f]
      end
    end
    @old_x = @character.x
    @old_y = @character.y
    update_footsteps
  end
end
end

#-------------------------------------------------------------------------------
# Various updates to DependentEventSprites Sprites to incorporate Reflection and Shadow stuff
#-------------------------------------------------------------------------------
class DependentEventSprites

  attr_accessor :sprites
# Change the refresh method to add Shadow and Footprints
  def refresh
    for sprite in @sprites
      sprite.dispose
    end
    @sprites.clear
    $PokemonTemp.dependentEvents.eachEvent {|event,data|
      if data[2] == @map.map_id # Check current map
        spr = Sprite_Character.new(@viewport,event)
        spr.setReflection(event, @viewport)
        if $PokemonTemp.dependentEvents.can_refresh?
          if defined?(EVENTNAME_MAY_NOT_INCLUDE) && spr.follower
            spr.steps = $FollowerSteps
            $FollowerSteps = nil
          end
        end
        @sprites.push(spr)
      end
    }
  end

# Change the update method to incorporate status tones and updating the follower
  def update
    if $PokemonTemp.dependentEvents.lastUpdate != @lastUpdate
      refresh
      @lastUpdate = $PokemonTemp.dependentEvents.lastUpdate
    end
    for sprite in @sprites
      sprite.update
    end
    for i in 0...@sprites.length
      pbDayNightTint(@sprites[i])
      first_pkmn = $Trainer.first_able_pokemon
      next if !$PokemonGlobal.dependentEvents[i] || !$PokemonGlobal.dependentEvents[i][8][/FollowerPkmn/i]
      if $PokemonGlobal.follower_toggled && FollowerSettings::APPLYSTATUSTONES && first_pkmn && first_pkmn.status != :NONE
        status_tone = getConst(FollowerSettings,"#{first_pkmn.status}TONE")
        @sprites[i].tone.set(@sprites[i].tone.red + status_tone[0],
                             @sprites[i].tone.green + status_tone[1],
                             @sprites[i].tone.blue + status_tone[2],
                             @sprites[i].tone.gray + status_tone[3]) if status_tone
      end
    end
  end
end

#-------------------------------------------------------------------------------
# Updating the method which controls dependent event positions
#-------------------------------------------------------------------------------
class DependentEvents
  def pbFollowEventAcrossMaps(leader,follower,instant = false,leaderIsTrueLeader = true)
    areConnectedOrSame = $MapFactory.areConnected?(leader.map.map_id,follower.map.map_id)
    # Get the rear facing tile of leader
    facingDirection = 10 - leader.direction
    if !leaderIsTrueLeader && areConnectedOrSame
      relativePos = $MapFactory.getThisAndOtherEventRelativePos(leader,follower)
      # Assumes leader and follower are both 1x1 tile in size
      if (relativePos[1] == 0 && relativePos[0] == 2)   # 2 spaces to the right of leader
        facingDirection = 6
      elsif (relativePos[1] == 0 && relativePos[0] == -2)   # 2 spaces to the left of leader
        facingDirection = 4
      elsif relativePos[1] == -2 && relativePos[0] == 0   # 2 spaces above leader
        facingDirection = 2
      elsif relativePos[1] == 2 && relativePos[0] == 0   # 2 spaces below leader
        facingDirection = 8
      end
    end
    facings = [facingDirection] # Get facing from behind
    if !leaderIsTrueLeader
      facings.push(leader.direction) # Get forward facing
    end
	
    mapTile = nil
	
    if areConnectedOrSame
      mapTile = findMapTilesForConnectedMaps(follower,leader,facings)
    else
      tile = $MapFactory.getFacingTile(facings[0],leader)
      # Assumes leader is 1x1 tile in size
      passable = tile && $MapFactory.isPassable?(tile[0],tile[1],tile[2],follower)
      mapTile = passable ? mapTile : nil
    end
	
	  moveFollower(follower,leader,mapTile,instant)
  end
  
  def findMapTilesForConnectedMaps(follower,leader,facings)
	  mapTile = nil
	  bestRelativePos = -1
      oldthrough = follower.through
      follower.through = false
      for i in 0...facings.length
        facing = facings[i]
        tile = $MapFactory.getFacingTile(facing,leader)
		    # Check for staircase shenanigans
        if GameData::TerrainTag.exists?(:StairLeft)
          currentTag = $game_player.pbTerrainTag
          if tile[1] > $game_player.x
            tile[2] -= 1 if currentTag == :StairLeft
          elsif tile[1] < $game_player.x
            tile[2] += 1 if currentTag == :StairLeft
          end
          if tile[1] > $game_player.x
            tile[2] += 1 if currentTag == :StairRight
          elsif tile[1] < $game_player.x
            tile[2] -= 1 if currentTag == :StairRight
          end
        end
        assumedTerrainTag = $MapFactory.getTerrainTag(tile[0],tile[1],tile[2])

        # Assumes leader is 1x1 tile in size
        passable = false
        if tile
          passable = true if $MapFactory.isPassable?(tile[0],tile[1],tile[2],follower)
          passable = true if assumedTerrainTag.ice
          passable = true if defined?(assumedTerrainTag.rock_climbable) && assumedTerrainTag.rock_climbable
        end
        passable = true if $PokemonGlobal.bridge > 0

        # If the tile isn't passable and the tile is a ledge,
        # get tile from further behind
        if i == 0 && !passable && tile && assumedTerrainTag.ledge
          tile = $MapFactory.getFacingTileFromPos(tile[0],tile[1],tile[2],facing)
          passable = tile && $MapFactory.isPassable?(tile[0],tile[1],tile[2],follower)
        end

        if passable
          relativePos = $MapFactory.getThisAndOtherPosRelativePos(
             follower,tile[0],tile[1],tile[2])
          # Assumes follower is 1x1 tile in size
          distance = Math.sqrt(relativePos[0] * relativePos[0] + relativePos[1] * relativePos[1])
          if bestRelativePos > distance || bestRelativePos == -1
            bestRelativePos = distance
            mapTile = tile
          end
          break if i == 0 && distance <= 1 # Prefer behind if tile can move up to 1 space
        end
      end
      follower.through = oldthrough
	  return mapTile
  end
  
  def moveFollower(follower,leader,mapTile,instant)
    if mapTile && follower.map.map_id == mapTile[0]
        moveFollowerToSameMap(follower,leader,mapTile,instant)
    else
      # Fall back on making current position into leader's position
      mapTile = [leader.map.map_id,leader.x,leader.y] if !mapTile
      if follower.map.map_id != mapTile[0]
        follower = moveFollowerToDifferentMap(follower,leader,mapTile)
      end
      moveFollowerToNearbySpot(follower,leader,mapTile)
    end
  end
  
  def moveFollowerToSameMap(follower,leader,mapTile,instant)
	  # Follower is on same map
      newX = mapTile[1]
      newY = mapTile[2]
      if defined?(leader.on_stair?) && leader.on_stair?
        newX = leader.x + (leader.direction == 4 ? 1 : leader.direction == 6 ? -1 : 0)
        if leader.on_middle_of_stair?
          newY = leader.y + (leader.direction == 8 ? 1 : leader.direction == 2 ? -1 : 0)
        else
          if follower.on_middle_of_stair?
            newY = follower.stair_start_y - follower.stair_y_position
          else
            newY = leader.y + (leader.direction == 8 ? 1 : leader.direction == 2 ? -1 : 0)
          end
        end
      end
      deltaX = (leader.direction == 6 ? -1 : leader.direction == 4 ? 1 : 0)
      deltaY = (leader.direction == 2 ? -1 : leader.direction == 8 ? 1 : 0)
      posX = newX + deltaX
      posY = newY + deltaY
      follower.move_speed = leader.move_speed # sync movespeed
      if (follower.x - newX == -1 && follower.y == newY) ||
         (follower.x - newX == 1  && follower.y == newY) ||
         (follower.y - newY == -1 && follower.x == newX) ||
         (follower.y - newY == 1  && follower.x == newX)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif (follower.x - newX == -2 && follower.y == newY) ||
            (follower.x - newX == 2  && follower.y == newY) ||
            (follower.y - newY == -2 && follower.x == newX) ||
            (follower.y - newY == 2  && follower.x == newX)
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      elsif follower.x != posX || follower.y != posY
        if instant
          follower.moveto(newX,newY)
        else
          pbFancyMoveTo(follower,posX,posY,leader)
          pbFancyMoveTo(follower,newX,newY,leader)
        end
      end
  end
  
  def moveFollowerToNearbySpot(follower,leader,mapTile)
    # Follower is on same map as leader
    newPosX = leader.x
    newPosY = leader.y
    
    # Try to find a nearby spot to place the pokemon
    # Try behind the player, then to their left, then their right, then finally ahead
    nearbySpotOffsets = nil
    case leader.direction
    when Up
      nearbySpotOffsets = [[0,1],[-1,0],[1,0],[0,-1]]
    when Left
      nearbySpotOffsets = [[1,0],[0,1],[0,-1],[0,-1]]
    when Down
      nearbySpotOffsets = [[0,-1],[1,0],[-1,0],[0,1]]
    when Right
      nearbySpotOffsets = [[-1,0],[0,-1],[0,1],[0,1]]
    end
    
    nearbySpotOffsets.each do |spot|
      passable = $MapFactory.isPassable?(leader.map.map_id,leader.x+spot[0],leader.y+spot[1],follower)
      if passable
        newPosX += spot[0]
        newPosY += spot[1]
        break
      end
    end
    pbFancyMoveTo(follower,newPosX, newPosY, leader)
    pbTurnTowardEvent(follower,leader) if !follower.move_route_forcing
  end
  
  def moveFollowerToDifferentMap(follower,leader,mapTile)
    # Follower will move to different map
    events = $PokemonGlobal.dependentEvents
    eventIndex = pbEnsureEvent(follower,mapTile[0])
    if eventIndex >= 0
      follower = @realEvents[eventIndex]
      newEventData = events[eventIndex]
      follower.moveto(mapTile[1],mapTile[2])
      pbFancyMoveTo(follower,mapTile[1], mapTile[2], leader)
      newEventData[3] = mapTile[1]
      newEventData[4] = mapTile[2]
      # if mapTile[0] == leader.map.map_id
      #   pbTurnTowardEvent(follower,leader) if !follower.move_route_forcing
      # end
    end
    return follower
  end

  #Fix follower not being in the same spot upon save
  def pbMapChangeMoveDependentEvents
    return
  end
end

#-------------------------------------------------------------------------------
# Various updates to the Map scene for followers
#-------------------------------------------------------------------------------
class Scene_Map

# Check for Toggle input and update the stepping animation
  alias follow_update update
  def update
    follow_update
    for i in 0...$PokemonGlobal.dependentEvents.length
      event = $PokemonTemp.dependentEvents.realEvents[i]
      return if event.move_route_forcing
      event.move_speed = $game_player.move_speed
    end
    if Input.trigger?(getConst(Input,FollowerSettings::TOGGLEFOLLOWERKEY)) &&
        FollowerSettings::ALLOWTOGGLEFOLLOW
      pbToggleFollowingPokemon
    end
    if $PokemonGlobal.follower_toggled
      # Stop stepping animation if on Ice
      if $game_player.pbTerrainTag.ice
        $PokemonTemp.dependentEvents.stop_stepping
      else
        $PokemonTemp.dependentEvents.start_stepping
      end
    end
  end

  alias follow_transfer transfer_player
  def transfer_player(cancelVehicles = true)
    follow_transfer(cancelVehicles)
    events = $PokemonGlobal.dependentEvents
    $PokemonTemp.dependentEvents.updateDependentEvents
    leader = $game_player
    for i in 0...events.length
      event = $PokemonTemp.dependentEvents.realEvents[i]
      $PokemonTemp.dependentEvents.refresh_sprite(false)
      $PokemonTemp.dependentEvents.pbFollowEventAcrossMaps(leader,event,false,i == 0)
    end
  end
end

# Tiny fix for emote Animations not playing in v19
class SpriteAnimation

  alias follower_effect effect?
  def effect?
    @_animation_duration if !@_animation_duration
    return follower_effect
  end
end

#Fix for followers having animations (grass, etc) when toggled off
#Treats followers as if they are under a bridge when toggled
class PokemonMapFactory

  alias follow_getTerrainTag getTerrainTag
  def getTerrainTag(mapid,x,y,countBridge = false)
    ret = follow_getTerrainTag(mapid,x,y,countBridge)
    return ret if $PokemonTemp.dependentEvents.can_refresh?
    for devent in $PokemonGlobal.dependentEvents
      if devent && devent[8][/FollowerPkmn/i] && devent[3] == x && devent[4] == y && ret.shows_grass_rustle
        ret = GameData::TerrainTag.try_get(:Bridge)
        ret = GameData::TerrainTag.get(:None) if !ret
        break
      end
    end
    return ret
  end
end

class Game_Character
	attr_accessor :floats
	
	def bush_depth
		return 0 if floats
		return @bush_depth || 0
	end
end