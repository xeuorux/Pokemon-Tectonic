#===============================================================================
# Main message-displaying function
#===============================================================================
def pbMessageDisplay(msgwindow,message,letterbyletter=true,commandProc=nil)
  return if !msgwindow
  oldletterbyletter=msgwindow.letterbyletter
  msgwindow.letterbyletter=(letterbyletter) ? true : false
  ret=nil
  commands=nil
  facewindow=nil
  goldwindow=nil
  coinwindow=nil
  battlepointswindow=nil
  cmdvariable=0
  cmdIfCancel=0
  msgwindow.waitcount=0
  autoresume=false
  text=message.clone
  msgback=nil
  linecount=(Graphics.height>400) ? 3 : 2
  ### Text replacement
  text.gsub!(/\\sign\[([^\]]*)\]/i) {   # \sign[something] gets turned into
    next "\\op\\cl\\ts[]\\w["+$1+"]"    # \op\cl\ts[]\w[something]
  }
  text = globalMessageReplacements(text)
  text.gsub!(/\\\\/,"\5")
  text.gsub!(/\\1/,"\1")
  if $game_actors
    text.gsub!(/\\n\[([1-8])\]/i) {
      m = $1.to_i
      next $game_actors[m].name
    }
  end
  text.gsub!(/’/i,"'")
  text.gsub!(/…/i,"...")
  text.gsub!(/–/i,"-")
  text.gsub!(/\\pn/i,$Trainer.name) if $Trainer
  text.gsub!(/\\pfp/i,$Trainer.party[0].name) if $Trainer && $Trainer.party[0]
  text.gsub!(/\\pm/i,_INTL("${1}",$Trainer.money.to_s_formatted)) if $Trainer
  text.gsub!(/\\n/i,"\n")
  text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2="+$1+">" }
  text.gsub!(/\\pg/i,"\\b") if $Trainer && $Trainer.male?
  text.gsub!(/\\pg/i,"\\r") if $Trainer && $Trainer.female?
  text.gsub!(/\\pog/i,"\\r") if $Trainer && $Trainer.male?
  text.gsub!(/\\pog/i,"\\b") if $Trainer && $Trainer.female?
  text.gsub!(/\\pg/i,"")
  text.gsub!(/\\pog/i,"")
  text.gsub!(/\\b/i,"<c3=3050C8,D0D0C8>")
  text.gsub!(/\\r/i,"<c3=E00808,D0D0C8>")
  text.gsub!(/\\[Ww]\[([^\]]*)\]/) {
    w = $1.to_s
    if w==""
      msgwindow.windowskin = nil
    else
      msgwindow.setSkin("Graphics/Windowskins/#{w}",false)
    end
    next ""
  }
  isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
  text.gsub!(/\\[Cc]\[([0-9]+)\]/) {
    m = $1.to_i
    next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
  }
  loop do
    last_text = text.clone
    text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    break if text == last_text
  end
  loop do
    last_text = text.clone
    text.gsub!(/\\l\[([0-9]+)\]/i) {
      linecount = [1,$1.to_i].max
      next ""
    }
    break if text == last_text
  end
  colortag = ""
  if $game_system && $game_system.respond_to?("message_frame") &&
     $game_system.message_frame != 0
    colortag = getSkinColor(msgwindow.windowskin,0,true)
  else
    colortag = getSkinColor(msgwindow.windowskin,0,isDarkSkin)
  end
  text = colortag+text
  ### Controls
  textchunks=[]
  controls=[]
  while text[/(?:\\(f|ff|i|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|or|\.|\||\!|\^))/i]
    textchunks.push($~.pre_match)
    if $~[1]
      controls.push([$~[1].downcase,$~[2],-1])
    else
      controls.push([$~[3].downcase,"",-1])
    end
    text=$~.post_match
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/\005/,"\\")
  end
  textlen = 0
  for i in 0...controls.length
    control = controls[i][0]
    case control
    when "wt", "wtnp", ".", "|"
      textchunks[i] += "\2"
    when "!"
      textchunks[i] += "\1"
    end
    textlen += toUnformattedText(textchunks[i]).scan(/./m).length
    controls[i][2] = textlen
  end
  text = textchunks.join("")
  signWaitCount = 0
  signWaitTime = Graphics.frame_rate/2
  haveSpecialClose = false
  specialCloseSE = ""
  for i in 0...controls.length
    control = controls[i][0]
    param = controls[i][1]
    case control
    when "op"
      signWaitCount = signWaitTime+1
    when "cl"
      text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
      haveSpecialClose = true
      specialCloseSE = param
    when "f"
      facewindow.dispose if facewindow
      facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
    when "ff"
      facewindow.dispose if facewindow
      facewindow = FaceWindowVX.new(param)
	  when "i"
      facewindow.dispose if facewindow
	    icon_location = GameData::Item.icon_filename(param)
      facewindow = PictureWindow.new(icon_location)
	    facewindow.visible = false
    when "ch"
      cmds = param.clone
      cmdvariable = pbCsvPosInt!(cmds)
      cmdIfCancel = pbCsvField!(cmds).to_i
      commands = []
      while cmds.length>0
        commands.push(pbCsvField!(cmds))
      end
    when "wtnp", "^"
      text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
    when "se"
      if controls[i][2]==0
        startSE = param
        controls[i] = nil
      end
    end
  end
  if startSE!=nil
    pbSEPlay(pbStringToAudioFile(startSE))
  elsif signWaitCount==0 && letterbyletter
    pbPlayDecisionSE()
  end
  ########## Position message window  ##############
  pbRepositionMessageWindow(msgwindow,linecount)
  atTop = (msgwindow.y==0)
  if facewindow
    facewindow.viewport = msgwindow.viewport
    facewindow.z        = msgwindow.z
  end
  ########## Show text #############################
  msgwindow.text = text
  Graphics.frame_reset if Graphics.frame_rate>40
  loop do
    if signWaitCount > 0
      signWaitCount -= 1
      signWaitCount = 0 if Input.trigger?(Input::USE)
      if atTop
        msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
		    facewindow.y = -facewindow.height*signWaitCount/signWaitTime if facewindow
      else
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
		    facewindow.y = Graphics.height-facewindow.height*(signWaitTime-signWaitCount)/signWaitTime if facewindow
      end
    end
    for i in 0...controls.length
      next if !controls[i]
      next if controls[i][2]>msgwindow.position || msgwindow.waitcount!=0
      control = controls[i][0]
      param = controls[i][1]
      case control
      when "f"
        facewindow.dispose if facewindow
        facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
	    when "i"
        facewindow.dispose if facewindow
        icon_location = GameData::Item.icon_filename(param)
        facewindow = PictureWindow.new(icon_location)
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
		    facewindow.x = 0
        if signWaitCount>0
          if atTop
            facewindow.y = -facewindow.height*signWaitCount/signWaitTime if facewindow
          else
            facewindow.y = Graphics.height-facewindow.height*(signWaitTime-signWaitCount)/signWaitTime if facewindow
          end
        end
	    when "or"
        msgwindow.x			= 60
        msgwindow.width		-= 60
      when "ff"
        facewindow.dispose if facewindow
        facewindow = FaceWindowVX.new(param)
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
      when "g"      # Display gold window
        goldwindow.dispose if goldwindow
        goldwindow = pbDisplayGoldWindow(msgwindow)
      when "cn"     # Display coins window
        coinwindow.dispose if coinwindow
        coinwindow = pbDisplayCoinsWindow(msgwindow,goldwindow)
      when "pt"     # Display battle points window
        battlepointswindow.dispose if battlepointswindow
        battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
      when "wu"
        msgwindow.y = 0
        atTop = true
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
      when "wm"
        atTop = false
        msgwindow.y = (Graphics.height-msgwindow.height)/2
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
      when "wd"
        atTop = false
        msgwindow.y = Graphics.height-msgwindow.height
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
      when "ts"     # Change text speed
        msgwindow.textspeed = (param=="") ? -999 : param.to_i
      when "."      # Wait 0.25 seconds
        msgwindow.waitcount += Graphics.frame_rate/4
      when "|"      # Wait 1 second
        msgwindow.waitcount += Graphics.frame_rate
      when "wt"     # Wait X/20 seconds
        param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
        msgwindow.waitcount += param.to_i*Graphics.frame_rate/20
      when "wtnp"   # Wait X/20 seconds, no pause
        param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
        msgwindow.waitcount = param.to_i*Graphics.frame_rate/20
        autoresume = true
      when "^"      # Wait, no pause
        autoresume = true
      when "se"     # Play SE
        pbSEPlay(pbStringToAudioFile(param))
      when "me"     # Play ME
        pbMEPlay(pbStringToAudioFile(param))
      end
      controls[i] = nil
    end
    break if !letterbyletter
    Graphics.update
    Input.update
    facewindow.update if facewindow
    if autoresume && msgwindow.waitcount==0
      msgwindow.resume if msgwindow.busy?
      break if !msgwindow.busy?
    end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      if msgwindow.busy?
        pbPlayDecisionSE if msgwindow.pausing?
        msgwindow.resume
      else
        break if signWaitCount==0
      end
    end
    pbUpdateSceneMap
    msgwindow.update
    yield if block_given?
    break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
  end
  Input.update   # Must call Input.update again to avoid extra triggers
  msgwindow.letterbyletter=oldletterbyletter
  if commands
    $game_variables[cmdvariable]=pbShowCommands(msgwindow,commands,cmdIfCancel)
    $game_map.need_refresh = true if $game_map
  end
  if commandProc
    ret=commandProc.call(msgwindow)
  end
  msgback.dispose if msgback
  goldwindow.dispose if goldwindow
  coinwindow.dispose if coinwindow
  battlepointswindow.dispose if battlepointswindow
  if haveSpecialClose
    pbSEPlay(pbStringToAudioFile(specialCloseSE))
    atTop = (msgwindow.y==0)
    for i in 0..signWaitTime
      if atTop
        msgwindow.y = -msgwindow.height*i/signWaitTime
		facewindow.y = -facewindow.height*i/signWaitTime
      else
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-i)/signWaitTime
		facewindow.y = Graphics.height-facewindow.height*(signWaitTime-i)/signWaitTime
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msgwindow.update
	  facewindow.update
    end
  end
  facewindow.dispose if facewindow
  return ret
end

class Window_InputNumberPokemon < SpriteWindow_Base
	def initialize(digits_max,min = nil,max = nil)
		@digits_max=digits_max
		@minumum = min
		@maximum = max
		@number=0
		@frame=0
		@sign=false
		@negative=false
		super(0,0,32,32)
		self.width=digits_max*24+8+self.borderX
		self.height=32+self.borderY
		colors=getDefaultTextColors(self.windowskin)
		@baseColor=colors[0]
		@shadowColor=colors[1]
		@index=digits_max-1
		self.active=true
		refresh
	end
	
	def update
		super
		digits=@digits_max+(@sign ? 1 : 0)
		refresh if @frame%15==0
		if self.active
		  if Input.repeat?(Input::UP) || Input.repeat?(Input::DOWN)
			if @index==0 && @sign
			  @negative=!@negative
			else
			  place = 10 ** (digits - 1 - @index)
			  newNumber = @number
			  n = newNumber / place % 10
			  newNumber -= n*place
			  higherPlaceChange = 0
			  if Input.repeat?(Input::UP)
				n = (n + 1) % 10
				# Went above 9
				if n == 0
					newNumber += 10*place
				else
					newNumber += n*place
				end
			  elsif Input.repeat?(Input::DOWN)
				n = (n + 9) % 10
				# Went below 0
				if n == 9
					newNumber -= place
				else
					newNumber += n*place
				end
			  end
			  tempMin = @minimum
			  tempMin = 0 if tempMin.nil? && !@sign
			  if @maximum && newNumber > @maximum
				if tempMin && Input.trigger?(Input::UP)
					@number = tempMin
				else
					pbPlayBuzzerSE()
				end
			  elsif tempMin && newNumber < tempMin
				if @maximum && Input.trigger?(Input::DOWN)
					@number = @maximum
				else
					pbPlayBuzzerSE()
				end
			  else
				pbPlayCursorSE()
				@number = newNumber
			  end
			end
			refresh
		  elsif Input.repeat?(Input::RIGHT)
			if digits >= 2
			  pbPlayCursorSE()
			  @index = (@index + 1) % digits
			  @frame=0
			  refresh
			end
		  elsif Input.repeat?(Input::LEFT)
			if digits >= 2
			  pbPlayCursorSE()
			  @index = (@index + digits - 1) % digits
			  @frame=0
			  refresh
			end
		  end
		end
		@frame=(@frame+1)%30
	end
end

def pbChooseNumber(msgwindow,params)
  return 0 if !params
  ret=0
  maximum=params.maxNumber
  minimum=params.minNumber
  defaultNumber=params.initialNumber
  cancelNumber=params.cancelNumber
  cmdwindow=Window_InputNumberPokemon.new(params.maxDigits,minimum,maximum)
  cmdwindow.z=99999
  cmdwindow.visible=true
  cmdwindow.setSkin(params.skin) if params.skin
  cmdwindow.sign=params.negativesAllowed # must be set before number
  cmdwindow.number=defaultNumber
  pbPositionNearMsgWindow(cmdwindow,msgwindow,:right)
  loop do
    Graphics.update
    Input.update
    pbUpdateSceneMap
    cmdwindow.update
    msgwindow.update if msgwindow
    yield if block_given?
    if Input.trigger?(Input::USE)
      ret=cmdwindow.number
      if ret>maximum
        pbPlayBuzzerSE()
      elsif ret<minimum
        pbPlayBuzzerSE()
      else
        pbPlayDecisionSE()
        break
      end
    elsif Input.trigger?(Input::BACK)
      pbPlayCancelSE()
      ret=cancelNumber
      break
    end
  end
  cmdwindow.dispose
  Input.update
  return ret
end