def pbBattleAnimation(bgm=nil,battletype=0,foe=nil)
  $game_temp.in_battle = true
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  # Set up audio
  playingBGS = nil
  playingBGM = nil
  if $game_system && $game_system.is_a?(Game_System)
    playingBGS = $game_system.getPlayingBGS
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgs_pause
  end
  pbMEFade(0.25)
  pbWait(Graphics.frame_rate/4)
  pbMEStop
  # Play battle music
  bgm = pbGetWildBattleBGM([]) if !bgm
  pbBGMPlay(bgm)
  # Take screenshot of game, for use in some animations
  $game_temp.background_bitmap.dispose if $game_temp.background_bitmap
  $game_temp.background_bitmap = Graphics.snap_to_bitmap
  # Check for custom battle intro animations
  handled = pbBattleAnimationOverride(viewport,battletype,foe)
  # Default battle intro animation
  if !handled
    # Determine which animation is played
    location = 0   # 0=outside, 1=inside, 2=cave, 3=water
    if $PokemonGlobal.surfing || $PokemonGlobal.diving
      location = 3
    elsif $PokemonTemp.encounterType &&
       GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
      location = 3
    elsif $PokemonEncounters.has_cave_encounters?
      location = 2
    elsif !GameData::MapMetadata.exists?($game_map.map_id) ||
          !GameData::MapMetadata.get($game_map.map_id).outdoor_map
      location = 1
    end
    anim = ""
    if PBDayNight.isDay?
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares","DiagonalBubbleTL","DiagonalBubbleBR","RisingSplash"][location]
      when 1      # Trainer
        anim = ["TwoBallPass","ThreeBallDown","BallDown","WavyThreeBallUp"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    else
      case battletype
      when 0, 2   # Wild, double wild
        anim = ["SnakeSquares","DiagonalBubbleBR","DiagonalBubbleBR","RisingSplash"][location]
      when 1      # Trainer
        anim = ["SpinBallSplit","BallDown","BallDown","WavySpinBall"][location]
      when 3      # Double trainer
        anim = "FourBallBurst"
      end
    end
    unless fastTransitions?
      # Initial screen flashing
      if location==2 || PBDayNight.isNight?
        viewport.color = Color.new(0,0,0)         # Fade to black a few times
      else
        viewport.color = Color.new(255,255,255)   # Fade to white a few times
      end
      halfFlashTime = Graphics.frame_rate*2/10   # 0.2 seconds, 8 frames
      alphaDiff = (255.0/halfFlashTime).ceil
      2.times do
        viewport.color.alpha = 0
        for i in 0...halfFlashTime*2
          if i<halfFlashTime; viewport.color.alpha += alphaDiff
          else;               viewport.color.alpha -= alphaDiff
          end
          Graphics.update
          pbUpdateSceneMap
        end
      end
    end
    # Play main animation
    Graphics.freeze
	  rate = location == 3 ? 1.25 : 1.0
    rate /= 1.5 if fastTransitions?
    Graphics.transition(Graphics.frame_rate*rate,sprintf("Graphics/Transitions/%s",anim))
    viewport.color = Color.new(0,0,0,255)   # Ensure screen is black
    # Slight pause after animation before starting up the battle scene
    (Graphics.frame_rate/10).times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  pbPushFade
  # Yield to the battle scene
  yield if block_given?
  # After the battle
  pbPopFade
  if $game_system && $game_system.is_a?(Game_System)
    $game_system.bgm_resume(playingBGM)
    $game_system.bgs_resume(playingBGS)
  end
  $PokemonGlobal.nextBattleBGM       = nil
  $PokemonGlobal.nextBattleME        = nil
  $PokemonGlobal.nextBattleCaptureME = nil
  $PokemonGlobal.nextBattleBack      = nil
  $PokemonEncounters.reset_step_count
  # Fade back to the overworld
  viewport.color = Color.new(0,0,0,255)
  numFrames = Graphics.frame_rate*4/10   # 0.4 seconds, 16 frames
  numFrames /= 2 if fastTransitions?
  alphaDiff = (255.0/numFrames).ceil
  numFrames.times do
    viewport.color.alpha -= alphaDiff
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  viewport.dispose
  $game_temp.in_battle = false
end