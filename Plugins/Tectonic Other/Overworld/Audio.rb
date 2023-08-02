def pbCueBGM(bgm,seconds,volume=nil,pitch=nil)
    return if !bgm
    bgm        = pbResolveAudioFile(bgm,volume,pitch)
    playingBGM = $game_system.playing_bgm
    if !playingBGM || playingBGM.name!=bgm.name || playingBGM.pitch!=bgm.pitch
      pbBGMFade(seconds)
      if !$PokemonTemp.cueFrames
        $PokemonTemp.cueFrames = (seconds*Graphics.frame_rate)*3/5
      end
      $PokemonTemp.cueBGM=bgm
    elsif playingBGM
      pbBGMPlay(bgm)
    end
  end
  
  def pbAutoplayOnTransition
    surfbgm = GameData::Metadata.get.surf_BGM
    if $PokemonGlobal.surfing && surfbgm
      pbBGMPlay(surfbgm)
    else
      $game_map.autoplayAsCue
    end
  end
  
  def pbAutoplayOnSave
    surfbgm = GameData::Metadata.get.surf_BGM
    if $PokemonGlobal.surfing && surfbgm
      pbBGMPlay(surfbgm)
    else
      $game_map.autoplay
    end
  end