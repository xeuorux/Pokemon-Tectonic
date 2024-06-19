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
            script = pbFreeTextNoWindow("", false, 256, Graphics.width)
            unless nil_or_empty?(script)
                $game_temp.debug_commands_history.unshift(script)
                $game_temp.debug_commands_index = -1
            end
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
    window.z = 99_999
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
            pbPlayDecisionSE
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
    def mainText
        return text.scan(/./m)
    end

    def update
        @frame += 1
        @frame %= 20
        refresh if (@frame % 10) == 0
        return unless active
        # Moving cursor
        if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
            if @helper.cursor > 0
                @helper.cursor -= 1
                @frame = 0
                refresh
            end
            return
        elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
            if @helper.cursor < mainText.length
                @helper.cursor += 1
                @frame = 0
                refresh
            end
            return
        elsif Input.triggerex?(:HOME)
            # Move cursor to beginning
            @helper.cursor = 0
            @frame = 0
            refresh
            return
        elsif Input.triggerex?(:END)
            # Move cursor to end
            @helper.cursor = mainText.length
            @frame = 0
            refresh
            return
        elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
            delete if @helper.cursor > 0
            return
        elsif Input.triggerex?(:UP) && $InCommandLine
            if $game_temp.debug_commands_history.length > $game_temp.debug_commands_index + 1
                $game_temp.debug_commands_index += 1
                self.text = $game_temp.debug_commands_history[$game_temp.debug_commands_index]
                @helper.cursor = mainText.length
                pbPlayCursorSE
                return
            else
                pbPlayBuzzerSE
            end
        elsif Input.triggerex?(:DOWN) && $InCommandLine
            if $game_temp.debug_commands_index > -1
                $game_temp.debug_commands_index -= 1
                if $game_temp.debug_commands_index < 0
                    self.text = ""
                else
                    self.text = $game_temp.debug_commands_history[$game_temp.debug_commands_index]
                end
                @helper.cursor = mainText.length
                pbPlayCursorSE
                return
            else
                pbPlayBuzzerSE
            end
        elsif Input.triggerex?(:RETURN) || Input.triggerex?(:ESCAPE)
            return
        end
        Input.gets.each_char { |c| insert(c) }
    end
end
