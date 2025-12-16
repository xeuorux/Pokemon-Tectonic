
class IntroEventScene < EventScene
  # Splash screen images that appear for a few seconds and then disappear.
  SPLASH_IMAGES         = ['splash1']
  # The main title screen background image.
  TITLE_BG_IMAGE        = 'tectonic_regigigas_title'
  TITLE_START_IMAGE     = 'start'
  TITLE_START_IMAGE_X   = 0
  TITLE_START_IMAGE_Y   = 322
  SECONDS_PER_SPLASH    = 2
  TICKS_PER_ENTER_FLASH = 40   # 20 ticks per second
  FADE_TICKS            = 8    # 20 ticks per second

  def initialize(viewport = nil)
    super(viewport)
    @pic = addImage(0, 0, "")
    @pic.setOpacity(0, 0)        # set opacity to 0 after waiting 0 frames
    @pic2 = addImage(0, 0, "")   # flashing "Press Enter" picture
    @pic2.setOpacity(0, 0)       # set opacity to 0 after waiting 0 frames
    @index = 0
    pbBGMPlay($data_system.title_bgm)
    open_splash(self, nil)
  end

  def open_splash(_scene, *args)
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + SPLASH_IMAGES[@index]
    # fade to opacity 255 in FADE_TICKS ticks after waiting 0 frames
    @pic.moveOpacity(0, FADE_TICKS, 255)
    pictureWait
    @timer = 0.0                            # reset the timer
    onUpdate.set(method(:splash_update))    # called every frame
    onCTrigger.set(method(:close_splash))   # called when C key is pressed
  end

  def close_splash(scene, args)
    onUpdate.clear
    onCTrigger.clear
    @pic.moveOpacity(0, FADE_TICKS, 0)
    pictureWait
    @index += 1   # Move to the next picture
    if @index >= SPLASH_IMAGES.length
      open_title_screen(scene, args)
    else
      open_splash(scene, args)
    end
  end

  def splash_update(scene, args)
    @timer += Graphics.delta_s
    close_splash(scene, args) if @timer > SECONDS_PER_SPLASH
  end

  def open_title_screen(_scene, *args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
    @pic.moveOpacity(0, FADE_TICKS, 255)
    @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
    @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
    @pic2.setVisible(0, true)
    @pic2.moveOpacity(0, FADE_TICKS, 255)
	  addLabel(0,220,Graphics.width,"<c3=FFFFFFFF,000000FF><ac><outln2>Version #{Settings::GAME_VERSION}</outln2></ac></c3>")

    if Settings::DISPLAY_VERSION_STATUS
      activeVersionLabel = ""
      mostRecentVersion = loadMostRecentVersionNumber
      if mostRecentVersion.nil?
        activeVersionLabel = _INTL("Version Server Error")
      else
        versionComparison = PluginManager.compare_versions(mostRecentVersion,Settings::GAME_VERSION)
        if versionComparison > 0
          activeVersionLabel = _INTL("OUT OF DATE")
        elsif versionComparison < 0
          activeVersionLabel = _INTL("AHEAD OF LIVE")
        end
      end
      addLabel(0,260,Graphics.width,"<c3=FF2211FF,DDEEEEFF><ac><outln2>#{activeVersionLabel}</outln2></ac></c3>")
    end

    pictureWait
    onUpdate.set(method(:title_screen_update))    # called every frame
    onCTrigger.set(method(:close_title_screen))   # called when C key is pressed
  end

  def fade_out_title_screen(scene)
    onUpdate.clear
    onCTrigger.clear
    # Play random cry
    Pokemon.play_cry(:REGIGIGAS)
    @pic.moveXY(0, 20, 0, 0)   # Adds 20 ticks (1 second) pause
    pictureWait
    # Fade out
    @pic.moveOpacity(0, FADE_TICKS, 0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0, FADE_TICKS, 0)
    pbBGMStop(1.0)
    pictureWait
    scene.dispose   # Close the scene
  end

  def close_title_screen(scene, *args)
    fade_out_title_screen(scene)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartLoadScreen
  end

  def close_title_screen_delete(scene, *args)
    fade_out_title_screen(scene)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartDeleteScreen
  end

  def title_screen_update(scene, args)
    # Flashing of "Press Enter" picture
    if !@pic2.running?
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH * 2 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 0)
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH * 6 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 255)
    end
    if Input.press?(Input::DOWN) &&
       Input.press?(Input::BACK) &&
       Input.press?(Input::CTRL)
      close_title_screen_delete(scene, args)
    end
  end
end

class Scene_Intro
  def main
    Graphics.transition(0)
    @eventscene = IntroEventScene.new
    @eventscene.main
    Graphics.freeze
  end
end

def loadMostRecentVersionNumber
  return nil if System.is_wine? if defined?(System.is_wine?)
  begin
    response = HTTPLite.get(Settings::VERSION_SERVER_FILE_URL)
    body = response[:body]
    latestVersion = body.split("\r\n").last
    return latestVersion
  rescue MKXPError
    return nil
  rescue NameError
    return nil
  end
end

def testIntroScene
  $scene = Scene_Intro.new
end