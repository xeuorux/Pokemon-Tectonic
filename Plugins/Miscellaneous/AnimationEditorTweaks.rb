def pbAnimList(animations,canvas,animwin)
    commands=[]
    for i in 0...animations.length
      animations[i]=PBAnimation.new if !animations[i]
      commands[commands.length]=_INTL("{1} {2}",i,animations[i].name)
    end
    cmdwin=pbListWindow(commands,320)
    cmdwin.height=416
    cmdwin.opacity=224
    cmdwin.index=animations.selected
    cmdwin.viewport=canvas.viewport
    helpwindow=Window_UnformattedTextPokemon.newWithSize(
       _INTL("Enter: Load/rename an animation\nEsc: Cancel"),
       320,0,320,128,canvas.viewport)
    maxsizewindow=ControlWindow.new(0,416,320,32*3)
    maxsizewindow.addSlider(_INTL("Total Animations:"),1,2000,animations.length)
    maxsizewindow.addButton(_INTL("Resize Animation List"))
    maxsizewindow.opacity=224
    maxsizewindow.viewport=canvas.viewport
    loop do
      Graphics.update
      Input.update
      cmdwin.update
      maxsizewindow.update
      helpwindow.update
      if maxsizewindow.changed?(1)
        newsize=maxsizewindow.value(0)
        animations.resize(newsize)
        commands.clear
        for i in 0...animations.length
          commands[commands.length]=_INTL("{1} {2}",i,animations[i].name)
        end
        cmdwin.commands=commands
        cmdwin.index=animations.selected
        next
      end
      if Input.trigger?(Input::USE) && animations.length>0
        cmd2=pbShowCommands(helpwindow,[
           _INTL("Load Animation"),
           _INTL("Rename"),
           _INTL("Delete")
        ],-1)
        if cmd2==0 # Load Animation
          canvas.loadAnimation(animations[cmdwin.index])
          animwin.animbitmap=canvas.animbitmap
          animations.selected=cmdwin.index
          break
        elsif cmd2==1 # Rename
          pbAnimName(animations[cmdwin.index],cmdwin)
          cmdwin.refresh
        elsif cmd2==2 # Delete
          if pbConfirmMessage(_INTL("Are you sure you want to delete this animation?"))
            animations[cmdwin.index]=PBAnimation.new
            cmdwin.commands[cmdwin.index]=_INTL("{1} {2}",cmdwin.index,animations[cmdwin.index].name)
            cmdwin.refresh
          end
        end
      end
      if Input.trigger?(Input::SPECIAL)
        text = pbEnterText("Enter selection.",0,20).downcase
        if text.blank?
            next
        end
        newIndex = -1
        cmdwin.commands.each_with_index { |command, i|
            next if i == cmdwin.index
            if command.downcase.include?(text)
                newIndex = i
                break
            end
        }
        if newIndex < 0
            pbMessage(_INTL("Could not find a command entry matching that input."))
        else
            cmdwin.index = newIndex
        end
      end
      if Input.trigger?(Input::BACK)
        break
      end
    end
    helpwindow.dispose
    maxsizewindow.dispose
    cmdwin.dispose
  end