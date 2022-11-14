#########################################
#                                       #
# Easy Debug Terminal                   #
# by ENLS                               #
# no clue what to write here honestly   #
#                                       #
#########################################

###########################
#      Configuration      #
###########################

# Enable or disable the debug terminal
TERMINAL_ENABLED = true

# Button used to open the terminal
TERMINAL_KEYBIND = :F3
# Uses SDL scancodes, without the SDL_SCANCODE_ prefix.
# https://github.com/mkxp-z/mkxp-z/wiki/Extensions-(RGSS,-Modules)#detecting-key-states





###########################
#       Code Stuff        #
###########################

module Input
  unless defined?(update_Debug_Terminal)
    class << Input
      alias update_Debug_Terminal update
    end
  end

  def self.update
    update_Debug_Terminal
    if triggerex?(TERMINAL_KEYBIND) && $DEBUG && !$InCommandLine && TERMINAL_ENABLED
      $InCommandLine = true
      script = pbFreeTextNoWindow("",false,256,Graphics.width)
      $game_temp.lastcommand = script unless nil_or_empty?(script)
      begin
        pbMapInterpreter.execute_script(script) unless nil_or_empty?(script)
      rescue Exception
      end
      $InCommandLine = false
    end
  end
end

$InCommandLine = false

# Custom Message Input Box Stuff
def pbFreeTextNoWindow(currenttext, passwordbox, maxlength, width = 240)
  window = Window_TextEntry_Keyboard_Terminal.new(currenttext, 0, 0, width, 64)
  ret = ""
  window.maxlength = maxlength
  window.visible = true
  window.z = 99999
  window.text = currenttext
  window.passwordChar = "*" if passwordbox
  Input.text_input = true
  loop do
    Graphics.update
    Input.update
    if Input.triggerex?(:ESCAPE)
      ret = currenttext
      break
    elsif Input.triggerex?(:RETURN)
      ret = window.text
      break
    end
    window.update
    yield if block_given?
  end
  Input.text_input = false
  window.dispose
  Input.update
  return ret
end

class Window_TextEntry_Keyboard_Terminal < Window_TextEntry
  def update
    @frame += 1
    @frame %= 20
    self.refresh if (@frame % 10) == 0
    return if !self.active
    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      if @helper.cursor > 0
        @helper.cursor -= 1
        @frame = 0
        self.refresh
      end
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      if @helper.cursor < self.text.scan(/./m).length
        @helper.cursor += 1
        @frame = 0
        self.refresh
      end
      return
    elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
      self.delete if @helper.cursor > 0
      return
    elsif Input.triggerex?(:UP) && $InCommandLine && !$game_temp.lastcommand.empty?
      self.text = $game_temp.lastcommand
      @helper.cursor = self.text.scan(/./m).length
      return
    elsif Input.triggerex?(:RETURN) || Input.triggerex?(:ESCAPE)
      return
    end
    Input.gets.each_char { |c| insert(c) }
  end
end

# Saving the last executed command
class Game_Temp
  attr_accessor :lastcommand

  def lastcommand
    @lastcommand = "" if !@lastcommand
    return @lastcommand
  end
end