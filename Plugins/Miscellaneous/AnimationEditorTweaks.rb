class Slider < UIControl
  def initialize(label,minvalue,maxvalue,curval)
    super(label)
    @minvalue = minvalue
    @maxvalue = maxvalue
    @curvalue = curval
    @label = label
    @leftarrow = Rect.new(0,0,0,0)
    @rightarrow = Rect.new(0,0,0,0)
    @labelclickable = Rect.new(0,0,0,0)
    self.minvalue = minvalue
    self.maxvalue = maxvalue
    self.curvalue = curval
    @textEnterable = true
  end

  # By how much the slider should change per frame at the given number of milliseconds of holding down the mouse
  def getChangePerRepeatTime(repeattime)
    if repeattime > 4000
      return 30
    elsif repeattime > 2500
      return 15
    elsif repeattime > 1250
      return 5
    end
    return 1
  end

  def update
    mousepos=Mouse::getMousePos
    self.changed=false
    if self.minvalue<self.maxvalue && self.curvalue<self.minvalue
      self.curvalue=self.minvalue
    end
    return false if self.disabled
    return false if !Input.repeat?(Input::MOUSELEFT)
    return false if !mousepos
    left = toAbsoluteRect(@leftarrow)
    right = toAbsoluteRect(@rightarrow)
    labelclickable = toAbsoluteRect(@labelclickable)
    oldvalue = self.curvalue
    repeattime = Input.time?(Input::MOUSELEFT) / 1000
    # Left arrow
    if left.contains(mousepos[0],mousepos[1])
      self.curvalue -= getChangePerRepeatTime(repeattime)
      self.curvalue = self.curvalue.floor
      self.changed = (self.curvalue != oldvalue)
      self.invalidate
    end
    #Right arrow
    if right.contains(mousepos[0],mousepos[1])
      self.curvalue += getChangePerRepeatTime(repeattime)
      self.curvalue = self.curvalue.floor
      self.changed = (self.curvalue != oldvalue)
      self.invalidate
    end
    #Clicking on label
    if labelclickable.contains(mousepos[0],mousepos[1])
      maxDigits = maxvalue.digits.length
      text = pbEnterText(_INTL("Enter slider value."),0,maxDigits,"",0,nil,true)
      unless text.blank?
        begin
          enteredValue = Integer(text || '')
          if enteredValue >= self.minvalue && enteredValue <= self.maxvalue
            self.curvalue = enteredValue
            self.curvalue = self.curvalue.floor
            self.changed = (self.curvalue != oldvalue)
            self.invalidate
          else
            pbMessage(_INTL("Entered value doesn't fit within the slider's bounds."))
          end
        rescue ArgumentError
          pbMessage(_INTL("Entered value is not a valid integer."))
        end
      end
    end
  end

  def refresh
    bitmap=self.bitmap
    x=self.x
    y=self.y
    width=self.width
    height=self.height
    color=Color.new(120,120,120)
    bitmap.fill_rect(x,y,width,height,Color.new(0,0,0,0))
    size=bitmap.text_size(self.label).width
    leftarrows=bitmap.text_size(_INTL(" << "))
    numbers=bitmap.text_size(" XXXX ").width
    rightarrows=bitmap.text_size(_INTL(" >> "))
    bitmap.font.color=color
    shadowtext(bitmap,x,y,size,height,self.label)
    x+=size
    shadowtext(bitmap,x,y,leftarrows.width,height,_INTL(" << "),
       self.disabled || self.curvalue==self.minvalue)
    @leftarrow=Rect.new(x,y,leftarrows.width,height)
    x+=leftarrows.width
    @labelclickable=Rect.new(x,y,numbers,height)
    if !self.disabled
      bitmap.font.color=color
      shadowtext(bitmap,x,y,numbers,height," #{self.curvalue} ",false,1)
    end
    x+=numbers
    shadowtext(bitmap,x,y,rightarrows.width,height,_INTL(" >> "),
       self.disabled || self.curvalue==self.maxvalue)
    @rightarrow=Rect.new(x,y,rightarrows.width,height)
  end
end

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

def pbSelectAnim(canvas,animwin)
  animfiles=[]
  pbRgssChdir(File.join("Graphics", "Animations")) {
     animfiles.concat(Dir.glob("*.png"))
  }
  cmdwin=pbListWindow(animfiles,320)
  cmdwin.opacity=200
  cmdwin.height=512
  bmpwin=BitmapDisplayWindow.new(320,0,320,448)
  ctlwin=ControlWindow.new(320,448,320,64)
  cmdwin.viewport=canvas.viewport
  bmpwin.viewport=canvas.viewport
  ctlwin.viewport=canvas.viewport
  ctlwin.addSlider(_INTL("Hue:"),0,359,0)
  loop do
    bmpwin.bitmapname=cmdwin.commands[cmdwin.index]
    Graphics.update
    Input.update
    cmdwin.update
    bmpwin.update
    ctlwin.update
    bmpwin.hue=ctlwin.value(0) if ctlwin.changed?(0)
    if Input.trigger?(Input::USE) && animfiles.length>0
      bitmap=AnimatedBitmap.new("Graphics/Animations/"+cmdwin.commands[cmdwin.index],ctlwin.value(0)).deanimate
      canvas.animation.graphic=cmdwin.commands[cmdwin.index]
      canvas.animation.hue=ctlwin.value(0)
      canvas.animbitmap=bitmap
      animwin.animbitmap=bitmap
      break
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
  bmpwin.dispose
  cmdwin.dispose
  ctlwin.dispose
  return
end