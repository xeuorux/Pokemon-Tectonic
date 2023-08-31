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