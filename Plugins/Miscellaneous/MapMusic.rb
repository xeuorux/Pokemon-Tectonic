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

class Game_Map
    def musicSettingMap(id = -1)
        id = @map_id if id == -1
        mapWithRightSettingsID = getMusicSettingPseudoParentIDOfGameMap(id)
        currentMap = load_data(sprintf("Data/Map%03d.rxdata", mapWithRightSettingsID))
        return currentMap
    end

    def mapAutoplayBGM(id = -1)
        return musicSettingMap(id).autoplay_bgm
    end

    def mapAutoplayBGS(id = -1)
        return musicSettingMap(id).autoplay_bgs
    end

    def mapBGM(id = -1)
        return musicSettingMap(id).bgm
    end

    def mapBGS(id = -1)
        return musicSettingMap(id).bgs
    end

  def autofade(mapid)
    playingBGM = $game_system.playing_bgm
    playingBGS = $game_system.playing_bgs
    return if !playingBGM && !playingBGS
    if playingBGM && mapAutoplayBGM(mapid)
      if (PBDayNight.isNight? rescue false)
        pbBGMFade(0.8) if playingBGM.name != mapBGM(mapid).name && playingBGM.name != mapBGM(mapid).name+"_n"
      else
        pbBGMFade(0.8) if playingBGM.name!=mapBGM(mapid).name
      end
    end
    if playingBGS && mapAutoplayBGS(mapid)
      pbBGMFade(0.8) if playingBGS.name!=map.bgs.name
    end
    Graphics.frame_reset
  end

  #-----------------------------------------------------------------------------
  # * Autoplays background music
  #   Plays music called "[normal BGM]_n" if it's night time and it exists
  #-----------------------------------------------------------------------------
  def autoplayAsCue
    if mapAutoplayBGM()
      if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/"+ mapBGM().name+ "_n")
        pbCueBGM(mapBGM().name+"_n",1.0,mapBGM().volume,mapBGM().pitch)
      else
        pbCueBGM(mapBGM(),1.0)
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
      if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/"+ mapBGM().name+ "_n")
        pbBGMPlay(mapBGM().name+"_n",mapBGM().volume,mapBGM().pitch)
      else
        pbBGMPlay(mapBGM())
      end
    end
    if mapAutoplayBGS()
      pbBGSPlay(mapBGS())
    end
  end
end