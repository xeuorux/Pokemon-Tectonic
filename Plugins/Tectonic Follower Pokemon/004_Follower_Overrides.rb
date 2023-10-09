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