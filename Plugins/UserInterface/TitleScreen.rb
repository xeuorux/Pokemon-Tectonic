class IntroEventScene < EventScene
  TITLE_BG_IMAGE        = 'chasm title'
  
  def open_title_screen(_scene, *args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
    @pic.moveOpacity(0, FADE_TICKS, 255)
    @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
    @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
    @pic2.setVisible(0, true)
    @pic2.moveOpacity(0, FADE_TICKS, 255)
	  addLabel(320,180,800,"\r<outln>#{Settings::GAME_VERSION}</outln>")
    pictureWait
    onUpdate.set(method(:title_screen_update))    # called every frame
    onCTrigger.set(method(:close_title_screen))   # called when C key is pressed
  end
end