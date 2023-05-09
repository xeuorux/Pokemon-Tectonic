
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