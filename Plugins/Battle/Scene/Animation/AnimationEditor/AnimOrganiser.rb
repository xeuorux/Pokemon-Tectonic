
def pbAnimationsOrganiser
  list = pbLoadBattleAnimations
  if !list || !list[0]
    pbMessage(_INTL("No animations exist."))
    return
  end
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  cmdwin = pbListWindow([])
  cmdwin.viewport = viewport
  cmdwin.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(_INTL("Animations Organiser"),
     Graphics.width / 2, 0, Graphics.width / 2, 64, viewport)
  title.z = 2
  info = Window_AdvancedTextPokemon.newWithSize(_INTL("Z+Up/Down: Swap\nZ+Left: Delete\nZ+Right: Insert"),
     Graphics.width / 2, 64, Graphics.width / 2, Graphics.height - 64, viewport)
  info.z = 2
  commands = []
  refreshlist = true; oldsel = -1
  cmd = [0,0]
  loop do
    if refreshlist
      commands = []
      for i in 0...list.length
        commands.push(sprintf("%d: %s",i,(list[i]) ? list[i].name : "???"))
      end
    end
    refreshlist = false; oldsel = -1
    cmd = pbCommands3(cmdwin,commands,-1,cmd[1],true)
    if cmd[0]==1   # Swap animation up
      if cmd[1]>=0 && cmd[1]<commands.length-1
        list[cmd[1]+1],list[cmd[1]] = list[cmd[1]],list[cmd[1]+1]
        refreshlist = true
      end
    elsif cmd[0]==2   # Swap animation down
      if cmd[1]>0
        list[cmd[1]-1],list[cmd[1]] = list[cmd[1]],list[cmd[1]-1]
        refreshlist = true
      end
    elsif cmd[0]==3   # Delete spot
      list.delete_at(cmd[1])
      cmd[1] = [cmd[1],list.length-1].min
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==4   # Insert spot
      list.insert(cmd[1],PBAnimation.new)
      refreshlist = true
      pbWait(Graphics.frame_rate*2/10)
    elsif cmd[0]==0
      cmd2 = pbMessage(_INTL("Save changes?"),
          [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd2==0 || cmd2==1
        if cmd2==0
          # Save animations here
          save_data(list,"Data/PkmnAnimations.rxdata")
          $PokemonTemp.battleAnims = nil
          pbMessage(_INTL("Data saved."))
        end
        break
      end
    end
  end
  title.dispose
  info.dispose
  cmdwin.dispose
  viewport.dispose
end


def pbCommands3(cmdwindow,commands,cmdIfCancel,defaultindex=-1,noresize=false)
  cmdwindow.commands = commands
  cmdwindow.index    = defaultindex if defaultindex>=0
  cmdwindow.x        = 0
  cmdwindow.y        = 0
  if noresize
    cmdwindow.height = Graphics.height
  else
    cmdwindow.width  = Graphics.width/2
  end
  cmdwindow.height   = Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.z        = 99999
  cmdwindow.visible  = true
  cmdwindow.active   = true
  command = 0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::SPECIAL)
		searchListWindow(cmdwindow)
		command = [5,cmdwindow.index]
		break
    elsif Input.press?(Input::ACTION)
      if Input.repeat?(Input::UP)
        command = [1,cmdwindow.index]
        break
      elsif Input.repeat?(Input::DOWN)
        command = [2,cmdwindow.index]
        break
      elsif Input.trigger?(Input::LEFT)
        command = [3,cmdwindow.index]
        break
      elsif Input.trigger?(Input::RIGHT)
        command = [4,cmdwindow.index]
        break
      end
    elsif Input.trigger?(Input::BACK)
      if cmdIfCancel>0
        command = [0,cmdIfCancel-1]
        break
      elsif cmdIfCancel<0
        command = [0,cmdIfCancel]
        break
      end
    elsif Input.trigger?(Input::USE)
      command = [0,cmdwindow.index]
      break
    end
  end
  ret = command
  cmdwindow.active = false
  return ret
end

def searchListWindow(cmdwin)
  text = pbEnterText("Enter selection.",0,30).downcase
  return if text.blank?
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