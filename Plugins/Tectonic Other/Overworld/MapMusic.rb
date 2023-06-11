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

class Game_Map
    def musicSettingMap(id = -1)
        id = @map_id if id == -1
        mapWithRightSettingsID = getMusicSettingPseudoParentIDOfGameMap(id)
        deferredMap = load_data(sprintf("Data/Map%03d.rxdata", mapWithRightSettingsID))
        return deferredMap
    end

    def mapAutoplayBGM(id = -1)
      return true if $PokemonGlobal.mapHasForcedBGM?(id)
      return musicSettingMap(id).autoplay_bgm
    end

    def mapAutoplayBGS(id = -1)
      return musicSettingMap(id).autoplay_bgs
    end

    def mapBGM(id = -1)
      return $PokemonGlobal.mapForcedBGM(id) if $PokemonGlobal.mapHasForcedBGM?(id)
      return musicSettingMap(id).bgm
    end

    def mapBGS(id = -1)
      return musicSettingMap(id).bgs
    end

    def playingDefaultBGM?
      return mapAutoplayBGM(mapid) == $game_system.playing_bgm
    end

    def autofade(mapid)
      playingBGM = $game_system.playing_bgm
      playingBGS = $game_system.playing_bgs
      return if !playingBGM && !playingBGS
      if playingBGM && mapAutoplayBGM(mapid)
        newBGM = mapBGM(mapid)
        if (PBDayNight.isNight? rescue false)
          pbBGMFade(0.8) if playingBGM.name != newBGM.name && playingBGM.name != newBGM.name+"_n"
        else
          pbBGMFade(0.8) if playingBGM.name != newBGM.name
        end
      end
      if playingBGS && mapAutoplayBGS(mapid)
        pbBGMFade(0.8) if playingBGS.name != map.bgs.name
      end
      Graphics.frame_reset
    end

  #-----------------------------------------------------------------------------
  # * Autoplays background music
  #   Plays music called "[normal BGM]_n" if it's night time and it exists
  #-----------------------------------------------------------------------------
  def autoplayAsCue
    if mapAutoplayBGM()
      newBGM = mapBGM()
      if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + newBGM.name + "_n")
        pbCueBGM(newBGM.name+"_n",1.0,newBGM.volume,newBGM.pitch)
      else
        pbCueBGM(newBGM,1.0)
      end
    end
    if mapAutoplayBGS()
      pbBGSPlay(mapBGS())
    end
  end
  #-----------------------------------------------------------------------------
  # * Plays background music
  #   Plays music called "[normal BGM]_n" if it's night time and it exists
  #-----------------------------------------------------------------------------
  def autoplay
    if mapAutoplayBGM()
      newBGM = mapBGM()
      if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + newBGM.name + "_n")
        pbBGMPlay(newBGM.name+"_n",newBGM.volume,newBGM.pitch)
      else
        pbBGMPlay(newBGM)
      end
    end
    if mapAutoplayBGS()
      pbBGSPlay(mapBGS())
    end
  end
end