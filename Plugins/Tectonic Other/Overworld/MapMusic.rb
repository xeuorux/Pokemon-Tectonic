# Returns either the map ID itself, or the ID of the lowest possible parent which has BGM settings set
def getMusicSettingPseudoParentIDOfGameMap(gameMapID)
    mapInfos = pbLoadMapInfos
    currentlyViewingMapID = gameMapID
    # Keep looping until a suitable map is found, or until there is no more parents to check
    while currentlyViewingMapID >= 1
      mapData = load_data(sprintf("Data/Map%03d.rxdata", currentlyViewingMapID))
      # If there's not the right sort of info on the map being looked at
      # Try going to its parent
      if mapData.nil? || !mapData.autoplay_bgm
        currentlyViewingMapID = mapInfos[currentlyViewingMapID].parent_id
      # Otherwise, we've found the proper pseudoparent, so return its ID
      else
        return currentlyViewingMapID
      end
    end
    # No suitable pseudoparent could be found, send the original map ID
    return gameMapID
end

class PokemonGlobalMetadata
  attr_writer :forcedBGM

  def forcedBGM
    @forcedBGM = {} if !@forcedBGM
    return @forcedBGM
  end

  def mapHasForcedBGM?(map_id = -1)
    map_id = $game_map.map_id if map_id == -1
    return forcedBGM.has_key?(map_id)
  end

  def mapForcedBGM(map_id = -1)
    map_id = $game_map.map_id if map_id == -1
    return pbResolveAudioFile(forcedBGM[map_id])
  end

  def forceMapBGM(musicName, map_id = -1)
    map_id = $game_map.map_id if map_id == -1
    forcedBGM[map_id] = musicName
  end

  def resetForcedBGM(map_id = -1)
    map_id = $game_map.map_id if map_id == -1
    forcedBGM.delete(map_id) if forcedBGM.key?(map_id)
  end
end

PRIMAL_GOOD_BGM = "Tectonic_Primal_Clay"
PRIMAL_BAD_BGM = "Tectonic_Primal_Clay_Fear"

def primalClayBGMChange()
  if $game_system.playing_bgm&.name == PRIMAL_BAD_BGM
    forceMapBGM(PRIMAL_GOOD_BGM)
  end
end

def forceMapBGM(bgmName)
  $PokemonGlobal.forceMapBGM(bgmName)
  $game_map.autoplayAsCue
end

def resetForcedBGM
  $PokemonGlobal.resetForcedBGM
  $game_map.autoplayAsCue
end