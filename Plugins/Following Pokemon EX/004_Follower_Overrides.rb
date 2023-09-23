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