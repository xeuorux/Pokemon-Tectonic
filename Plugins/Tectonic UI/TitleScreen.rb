class IntroEventScene < EventScene
  TITLE_BG_IMAGE        = 'tectonic_regigigas_title'
  
  def open_title_screen(_scene, *args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
    @pic.moveOpacity(0, FADE_TICKS, 255)
    @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
    @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
    @pic2.setVisible(0, true)
    @pic2.moveOpacity(0, FADE_TICKS, 255)
	  addLabel(0,260,Graphics.width,"<c3=FFFFFFFF,000000FF><ac><outln2>Version #{Settings::GAME_VERSION}</outln2></ac></c3>")
    pictureWait
    onUpdate.set(method(:title_screen_update))    # called every frame
    onCTrigger.set(method(:close_title_screen))   # called when C key is pressed
  end
end