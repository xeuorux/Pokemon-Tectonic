#===============================================================================
# Common UI functions used in both the Bag and item storage screens.
# Displays messages and allows the user to choose a number/command.
# The window _helpwindow_ will display the _helptext_.
#===============================================================================
module UIHelper
    # Letter by letter display of the message _msg_ by the window _helpwindow_.
    def self.pbDisplay(helpwindow,msg,brief)
      cw = helpwindow
      oldvisible = cw.visible
      cw.letterbyletter = true
      cw.text           = msg+"\1"
      cw.visible        = true
      pbBottomLeftLines(cw,2)
      loop do
        Graphics.update
        Input.update
        (block_given?) ? yield : cw.update
        if !cw.busy?
          if brief || (Input.trigger?(Input::USE) && cw.resume)
            break
          end
        end
      end
      cw.visible = oldvisible
    end
  
    def self.pbDisplayStatic(msgwindow,message)
      oldvisible = msgwindow.visible
      msgwindow.visible        = true
      msgwindow.letterbyletter = false
      msgwindow.width          = Graphics.width
      msgwindow.resizeHeightToFit(message,Graphics.width)
      msgwindow.text           = message
      pbBottomRight(msgwindow)
      loop do
        Graphics.update
        Input.update
        (block_given?) ? yield : msgwindow.update
        if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
          break
        end
      end
      msgwindow.visible = oldvisible
      Input.update
    end
  
    # Letter by letter display of the message _msg_ by the window _helpwindow_,
    # used to ask questions.  Returns true if the user chose yes, false if no.
    def self.pbConfirm(helpwindow,msg)
      dw = helpwindow
      oldvisible = dw.visible
      dw.letterbyletter = true
      dw.text           = msg
      dw.visible        = true
      pbBottomLeftLines(dw,2)
      commands = [_INTL("Yes"),_INTL("No")]
      cw = Window_CommandPokemon.new(commands)
      cw.index = 0
      cw.viewport = helpwindow.viewport
      pbBottomRight(cw)
      cw.y -= dw.height
      ret = false
      loop do
        cw.visible = (!dw.busy?)
        Graphics.update
        Input.update
        cw.update
        (block_given?) ? yield : dw.update
        if !dw.busy? && dw.resume
          if Input.trigger?(Input::BACK)
            pbPlayCancelSE
            break
          elsif Input.trigger?(Input::USE)
            pbPlayDecisionSE
            ret = (cw.index==0)
            break
          end
        end
      end
      cw.dispose
      dw.visible = oldvisible
      return ret
    end
  
    def self.pbChooseNumber(helpwindow,helptext,maximum,initnum=1)
      oldvisible = helpwindow.visible
      helpwindow.visible        = true
      helpwindow.text           = helptext
      helpwindow.letterbyletter = false
      curnumber = initnum
      ret = 0
      numwindow = Window_UnformattedTextPokemon.new("x000")
      numwindow.viewport       = helpwindow.viewport
      numwindow.letterbyletter = false
      numwindow.text           = _ISPRINTF("x{1:03d}",curnumber)
      numwindow.resizeToFit(numwindow.text,Graphics.width)
      pbBottomRight(numwindow)
      helpwindow.resizeHeightToFit(helpwindow.text,Graphics.width-numwindow.width)
      pbBottomLeft(helpwindow)
      loop do
        Graphics.update
        Input.update
        numwindow.update
        helpwindow.update
        if Input.trigger?(Input::BACK)
          ret = 0
          pbPlayCancelSE
          break
        elsif Input.trigger?(Input::USE)
          ret = curnumber
          pbPlayDecisionSE
          break
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = 1 if curnumber>maximum
          numwindow.text = _ISPRINTF("x{1:03d}",curnumber)
          pbPlayCursorSE
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber<1
          numwindow.text = _ISPRINTF("x{1:03d}",curnumber)
          pbPlayCursorSE
        elsif Input.repeat?(Input::LEFT)
          curnumber -= 10
          curnumber = 1 if curnumber<1
          numwindow.text = _ISPRINTF("x{1:03d}",curnumber)
          pbPlayCursorSE
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber>maximum
          numwindow.text = _ISPRINTF("x{1:03d}",curnumber)
          pbPlayCursorSE
        end
      end
      numwindow.dispose
      helpwindow.visible = oldvisible
      return ret
    end
  
    def self.pbShowCommands(helpwindow,helptext,commands,initcmd=0)
      ret = -1
      oldvisible = helpwindow.visible
      helpwindow.visible        = helptext ? true : false
      helpwindow.letterbyletter = false
      helpwindow.text           = helptext ? helptext : ""
      cmdwindow = Window_CommandPokemon.new(commands)
      cmdwindow.index = initcmd
      begin
        cmdwindow.viewport = helpwindow.viewport
        pbBottomRight(cmdwindow)
        helpwindow.resizeHeightToFit(helpwindow.text,Graphics.width-cmdwindow.width)
        pbBottomLeft(helpwindow)
        loop do
          Graphics.update
          Input.update
          yield
          cmdwindow.update
          if Input.trigger?(Input::BACK)
            ret = -1
            pbPlayCancelSE
            break
          end
          if Input.trigger?(Input::USE)
            ret = cmdwindow.index
            pbPlayDecisionSE
            break
          end
        end
      ensure
        cmdwindow.dispose if cmdwindow
      end
      helpwindow.visible = oldvisible
      return ret
    end
  end