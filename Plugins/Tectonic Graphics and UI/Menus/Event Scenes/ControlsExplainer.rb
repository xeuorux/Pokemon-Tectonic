#==============================================================================
# * Scene_Controls
#------------------------------------------------------------------------------
# Shows a help screen listing the keyboard controls.
# Display with:
#      pbEventScreen(ButtonEventScene)
#==============================================================================
class ButtonEventScene < EventScene
    def initialize(viewport = nil)
      super
      Graphics.freeze
      @current_screen = 1
      addImage(0, 0, "Graphics/Pictures/Controls help/help_bg")
      @labels = []
      @label_screens = []
      @keys = []
      @key_screens = []   
  
      addImageForScreen(1, 16, 158, "Graphics/Pictures/Controls help/help_arrows")
      addLabelForScreen(1, 134, 100, 352, _INTL("Use the Arrow keys to move the main character.\r\n\r\nYou can also use the Arrow keys to select entries and navigate menus."))
  
      addImageForScreen(2, 16, 106, addLanguageSuffix("Graphics/Pictures/Controls help/help_usekey"))
      addImageForScreen(2, 16, 236, addLanguageSuffix("Graphics/Pictures/Controls help/help_backkey"))
      addLabelForScreen(2, 134, 84, 352, _INTL("Used to confirm a choice, interact with people and things, and move through text. (Default: C)"))
      addLabelForScreen(2, 134, 212, 352, _INTL("Used to exit, cancel a choice, and cancel a mode. Also used to open the Pause Menu. (Default: X)"))
  
      addImageForScreen(3, 16, 90, addLanguageSuffix("Graphics/Pictures/Controls help/help_actionkey"))
      addImageForScreen(3, 16, 252, addLanguageSuffix("Graphics/Pictures/Controls help/help_specialkey"))
      addLabelForScreen(3, 134, 52, 352, _INTL("Has various functions depending on context. While moving around, hold to move at a different speed. (Default: Z)"))
      addLabelForScreen(3, 134, 212, 352, _INTL("Press to open the Ready Menu, where registered items and available field moves can be used. (Default: D)"))
  
      addImageForScreen(4, 44, 90, "Graphics/Pictures/Controls help/help_q")
      addImageForScreen(4, 24, 252, "Graphics/Pictures/Controls help/help_space")
      addLabelForScreen(4, 134, 84, 352, _INTL("Press to quicksave while in the overworld."))
      addLabelForScreen(4, 134, 244, 352, _INTL("Press to instantly mount the Bicycle while in the overworld."))

      addImageForScreen(5, 44, 122, "Graphics/Pictures/Controls help/help_f1")
      addLabelForScreen(5, 134, 84, 352, _INTL("Opens the Key Bindings window, where you can choose which keyboard keys to use for each control."))

      addImageForScreen(6, 44, 90, "Graphics/Pictures/Controls help/help_f12")
      addImageForScreen(6, 44, 252, "Graphics/Pictures/Controls help/help_f8")
      addLabelForScreen(6, 134, 100, 352, _INTL("Press to reset to the main menu."))
      addLabelForScreen(6, 134, 236, 352, _INTL("Take a screenshot. It is put in the Screenshots folder, near your Save Game folder."))
      
      set_up_screen(@current_screen)
      Graphics.transition(20)
      # Go to next screen when user presses USE
      onCTrigger.set(method(:pbOnScreenEnd))
    end
  
    def addLabelForScreen(number, x, y, width, text)
      @labels.push(addLabel(x, y, width, text))
      @label_screens.push(number)
      @picturesprites[@picturesprites.length - 1].opacity = 0
    end
  
    def addImageForScreen(number, x, y, filename)
      @keys.push(addImage(x, y, filename))
      @key_screens.push(number)
      @picturesprites[@picturesprites.length - 1].opacity = 0
    end
  
    def set_up_screen(number)
      @label_screens.each_with_index do |screen, i|
        @labels[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
      end
      @key_screens.each_with_index do |screen, i|
        @keys[i].moveOpacity((screen == number) ? 10 : 0, 10, (screen == number) ? 255 : 0)
      end
      pictureWait   # Update event scene with the changes
    end
  
    def pbOnScreenEnd(scene, *args)
      last_screen = [@label_screens.max, @key_screens.max].max
      if @current_screen >= last_screen
        # End scene
        Graphics.freeze
        Graphics.transition(20, "fadetoblack")
        scene.dispose
      else
        # Next screen
        @current_screen += 1
        onCTrigger.clear
        set_up_screen(@current_screen)
        onCTrigger.set(method(:pbOnScreenEnd))
      end
    end
end

def showControlsHelper
  pbEventScreen(ButtonEventScene)
end