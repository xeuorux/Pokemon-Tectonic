def pbMapInterpreter
    if $game_map.respond_to?("interpreter")
        return $game_map.interpreter
    elsif $game_system
        return $game_system.map_interpreter
    end
    return nil
end

def pbMapInterpreterRunning?
    interp = pbMapInterpreter
    return interp && interp.running?
end

def pbRefreshSceneMap
    if $scene && $scene.is_a?(Scene_Map)
        if $scene.respond_to?("miniupdate")
            $scene.miniupdate
        else
            $scene.updatemini
        end
    end
end

def pbUpdateSceneMap
    if $scene && $scene.is_a?(Scene_Map) && !pbIsFaded?
        if $scene.respond_to?("miniupdate")
            $scene.miniupdate
        else
            $scene.updatemini
        end
    end
end

#===============================================================================
#
#===============================================================================
def pbEventCommentInput(*args)
    parameters = []
    list = args[0].list   # Event or event page
    elements = args[1]    # Number of elements
    trigger = args[2]     # Trigger
    return nil if list.nil?
    return nil unless list.is_a?(Array)
    for item in list
        next unless item.code == 108 || item.code == 408
        next unless item.parameters[0] == trigger
        start = list.index(item) + 1
        finish = start + elements
        for id in start...finish
            next unless list[id]
            parameters.push(list[id].parameters[0])
        end
        return parameters
    end
    return nil
end

def pbCurrentEventCommentInput(elements, trigger)
    return nil unless pbMapInterpreterRunning?
    event = pbMapInterpreter.get_character(0)
    return nil unless event
    return pbEventCommentInput(event, elements, trigger)
end

#===============================================================================
#
#===============================================================================
class ChooseNumberParams
    def initialize
        @maxDigits = 0
        @minNumber = 0
        @maxNumber = 0
        @skin = nil
        @messageSkin = nil
        @negativesAllowed = false
        @initialNumber = 0
        @cancelNumber = nil
    end

    def setMessageSkin(value)
        @messageSkin = value
    end

    attr_reader :messageSkin

    def setSkin(value)
        @skin = value
    end

    attr_reader :skin

    def setNegativesAllowed(value)
        @negativeAllowed = value
    end

    def negativesAllowed
        @negativeAllowed ? true : false
    end

    def setRange(minNumber, maxNumber)
        maxNumber = minNumber if minNumber > maxNumber
        @maxDigits = 0
        @minNumber = minNumber
        @maxNumber = maxNumber
    end

    def setDefaultValue(number)
        @initialNumber = number
        @cancelNumber = nil
    end

    def setInitialValue(number)
        @initialNumber = number
    end

    def setCancelValue(number)
        @cancelNumber = number
    end

    def initialNumber
        return clamp(@initialNumber, minNumber, maxNumber)
    end

    def cancelNumber
        return @cancelNumber || initialNumber
    end

    def minNumber
        ret = 0
        if @maxDigits > 0
            ret = -((10**@maxDigits) - 1)
        else
            ret = @minNumber
        end
        ret = 0 if !@negativeAllowed && ret < 0
        return ret
    end

    def maxNumber
        ret = 0
        if @maxDigits > 0
            ret = ((10**@maxDigits) - 1)
        else
            ret = @maxNumber
        end
        ret = 0 if !@negativeAllowed && ret < 0
        return ret
    end

    def setMaxDigits(value)
        @maxDigits = [1, value].max
    end

    def maxDigits
        if @maxDigits > 0
            return @maxDigits
        else
            return [numDigits(minNumber), numDigits(maxNumber)].max
        end
    end

    private

    def clamp(v, mn, mx)
        if v < mn
            return mn
        elsif v > mx
            return mx
        else
            return v
        end
    end

    def numDigits(number)
        ans = 1
        number = number.abs
        while number >= 10
            ans += 1
            number /= 10
        end
        return ans
    end
end

def pbChooseNumber(msgwindow, params)
    return 0 unless params
    ret = 0
    maximum = params.maxNumber
    minimum = params.minNumber
    defaultNumber = params.initialNumber
    cancelNumber = params.cancelNumber
    cmdwindow = Window_InputNumberPokemon.new(params.maxDigits, minimum, maximum)
    cmdwindow.z = 99_999
    cmdwindow.visible = true
    cmdwindow.setSkin(params.skin) if params.skin
    cmdwindow.sign = params.negativesAllowed # must be set before number
    cmdwindow.number = defaultNumber
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
    loop do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        cmdwindow.update
        msgwindow.update if msgwindow
        yield if block_given?
        if Input.trigger?(Input::USE)
            ret = cmdwindow.number
            if ret > maximum
                pbPlayBuzzerSE
            elsif ret < minimum
                pbPlayBuzzerSE
            else
                pbPlayDecisionSE
                break
            end
        elsif Input.trigger?(Input::BACK)
            pbPlayCancelSE
            ret = cancelNumber
            break
        end
    end
    cmdwindow.dispose
    Input.update
    return ret
end

#===============================================================================
#
#===============================================================================
class FaceWindowVX < SpriteWindow_Base
    def initialize(face)
        super(0, 0, 128, 128)
        faceinfo = face.split(",")
        facefile = pbResolveBitmap("Graphics/Faces/" + faceinfo[0])
        facefile ||= pbResolveBitmap("Graphics/Pictures/" + faceinfo[0])
        contents.dispose if contents
        @faceIndex = faceinfo[1].to_i
        @facebitmaptmp = AnimatedBitmap.new(facefile)
        @facebitmap = BitmapWrapper.new(96, 96)
        factRect = Rect.new((@faceIndex % 4) * 96, (@faceIndex / 4) * 96, 96, 96)
        @facebitmap.blt(0, 0, @facebitmaptmp.bitmap, factRect)
        self.contents = @facebitmap
    end

    def update
        super
        if @facebitmaptmp.totalFrames > 1
            @facebitmaptmp.update
            faceRect = Rect.new((@faceIndex % 4) * 96, (@faceIndex / 4) * 96, 96, 96)
            @facebitmap.blt(0, 0, @facebitmaptmp.bitmap, factRect)
        end
    end

    def dispose
        @facebitmaptmp.dispose
        @facebitmap.dispose if @facebitmap
        super
    end
end

#===============================================================================
#
#===============================================================================
def pbGetBasicMapNameFromId(id)
    map = pbLoadMapInfos
    return "" unless map
    return map[id].name
rescue StandardError
    return ""
end

def pbGetMapNameFromId(id)
    map = pbGetBasicMapNameFromId(id)
    map.gsub!(/\\PN/, $Trainer.name) if $Trainer
    return map
end

def pbCsvField!(str)
    ret = ""
    str.sub!(/\A\s*/, "")
    if str[0, 1] == "\""
        str[0, 1] = ""
        escaped = false
        fieldbytes = 0
        str.scan(/./) do |s|
            fieldbytes += s.length
            break if s == "\"" && !escaped
            if s == "\\" && !escaped
                escaped = true
            else
                ret += s
                escaped = false
            end
        end
        str[0, fieldbytes] = ""
        raise _INTL("Invalid quoted field (in: {1})", ret) if !str[/\A\s*,/] && !str[/\A\s*$/]
        str[0, str.length] = $~.post_match
    else
        if str[/,/]
            str[0, str.length] = $~.post_match
            ret = $~.pre_match
        else
            ret = str.clone
            str[0, str.length] = ""
        end
        ret.gsub!(/\s+$/, "")
    end
    return ret
end

def pbCsvPosInt!(str)
    ret = pbCsvField!(str)
    raise _INTL("Field {1} is not a positive integer", ret) unless ret[/\A\d+$/]
    return ret.to_i
end

#===============================================================================
# Money and coins windows
#===============================================================================
def pbGetGoldString
    moneyString = ""
    begin
        moneyString = _INTL("${1}", $Trainer.money.to_s_formatted)
    rescue StandardError
        if $data_system.respond_to?("words")
            moneyString = _INTL("{1} {2}", $game_party.gold, $data_system.words.gold)
        else
            moneyString = _INTL("{1} {2}", $game_party.gold, Vocab.gold)
        end
    end
    return moneyString
end

def pbDisplayGoldWindow(msgwindow)
    moneyString = pbGetGoldString
    goldwindow = Window_AdvancedTextPokemon.new(_INTL("Money:\n<ar>{1}</ar>", moneyString))
    goldwindow.setSkin("Graphics/Windowskins/goldskin")
    goldwindow.resizeToFit(goldwindow.text, Graphics.width)
    goldwindow.width = 160 if goldwindow.width <= 160
    if msgwindow.y == 0
        goldwindow.y = Graphics.height - goldwindow.height
    else
        goldwindow.y = 0
    end
    goldwindow.viewport = msgwindow.viewport
    goldwindow.z = msgwindow.z
    return goldwindow
end

def pbDisplayCoinsWindow(msgwindow, goldwindow)
    coinString = $Trainer ? $Trainer.coins.to_s_formatted : "0"
    coinwindow = Window_AdvancedTextPokemon.new(_INTL("Coins:\n<ar>{1}</ar>", coinString))
    coinwindow.setSkin("Graphics/Windowskins/goldskin")
    coinwindow.resizeToFit(coinwindow.text, Graphics.width)
    coinwindow.width = 160 if coinwindow.width <= 160
    if msgwindow.y == 0
        coinwindow.y = goldwindow ? goldwindow.y - coinwindow.height : Graphics.height - coinwindow.height
    else
        coinwindow.y = goldwindow ? goldwindow.height : 0
    end
    coinwindow.viewport = msgwindow.viewport
    coinwindow.z = msgwindow.z
    return coinwindow
end

def pbDisplayBattlePointsWindow(msgwindow)
    pointsString = $Trainer ? $Trainer.battle_points.to_s_formatted : "0"
    pointswindow = Window_AdvancedTextPokemon.new(_INTL("Battle Points:\n<ar>{1}</ar>", pointsString))
    pointswindow.setSkin("Graphics/Windowskins/goldskin")
    pointswindow.resizeToFit(pointswindow.text, Graphics.width)
    pointswindow.width = 160 if pointswindow.width <= 160
    if msgwindow.y == 0
        pointswindow.y = Graphics.height - pointswindow.height
    else
        pointswindow.y = 0
    end
    pointswindow.viewport = msgwindow.viewport
    pointswindow.z = msgwindow.z
    return pointswindow
end

#===============================================================================
#
#===============================================================================
def pbCreateStatusWindow(viewport = nil)
    msgwindow = Window_AdvancedTextPokemon.new("")
    if !viewport
        msgwindow.z = 99_999
    else
        msgwindow.viewport = viewport
    end
    msgwindow.visible = false
    msgwindow.letterbyletter = false
    pbBottomLeftLines(msgwindow, 2)
    skinfile = MessageConfig.pbGetSpeechFrame
    msgwindow.setSkin(skinfile)
    return msgwindow
end

def pbCreateMessageWindow(viewport = nil, skin = nil)
    msgwindow = Window_AdvancedTextPokemon.new("")
    if !viewport
        msgwindow.z = 99_999
    else
        msgwindow.viewport = viewport
    end
    msgwindow.visible = true
    msgwindow.letterbyletter = true
    msgwindow.back_opacity = MessageConfig::WINDOW_OPACITY
    pbBottomLeftLines(msgwindow, 2)
    $game_temp.message_window_showing = true if $game_temp
    skin ||= MessageConfig.pbGetSpeechFrame
    msgwindow.setSkin(skin)
    return msgwindow
end

def pbDisposeMessageWindow(msgwindow)
    $game_temp.message_window_showing = false if $game_temp
    msgwindow.dispose
end

#===============================================================================
# Main message-displaying function
#===============================================================================
def pbMessageDisplay(msgwindow, message, letterbyletter = true, commandProc = nil)
    return unless msgwindow
    oldletterbyletter = msgwindow.letterbyletter
    msgwindow.letterbyletter = letterbyletter ? true : false
    ret = nil
    commands = nil
    facewindow = nil
	iconwindow = nil
    goldwindow = nil
    coinwindow = nil
    battlepointswindow = nil
    cmdvariable = 0
    cmdIfCancel = 0
    msgwindow.waitcount = 0
    autoresume = false
    text = message.clone
    msgback = nil
    linecount = (Graphics.height > 400) ? 3 : 2
    ### Text replacement
    text.gsub!(/\\sign\[([^\]]*)\]/i) do # \sign[something] gets turned into
        next "\\op\\cl\\ts[]\\w[" + Regexp.last_match(1) + "]" # \op\cl\ts[]\w[something]
    end
    text = globalMessageReplacements(text)
    text.gsub!(/\\\\/, "\5")
    text.gsub!(/\\1/, "\1")
    if $game_actors
        text.gsub!(/\\n\[([1-8])\]/i) do
            m = Regexp.last_match(1).to_i
            next $game_actors[m].name
        end
    end
    text.gsub!(/’/i, "'")
    text.gsub!(/…/i, "...")
    text.gsub!(/–/i, "-")
    text.gsub!(/\\pn/i, $Trainer.name) if $Trainer
    begin
        text.gsub!(/\\pfp/i, $Trainer.party[0].name) if $Trainer && $Trainer.party[0]
    rescue StandardError
    end
    text.gsub!(/\\pm/i, _INTL("${1}", $Trainer.money.to_s_formatted)) if $Trainer
    text.gsub!(/\\n/i, "\n")
    text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2=" + Regexp.last_match(1) + ">" }
    text.gsub!(/\\pg/i, "\\b") if $Trainer && $Trainer.male?
    text.gsub!(/\\pg/i, "\\r") if $Trainer && $Trainer.female?
    text.gsub!(/\\pog/i, "\\r") if $Trainer && $Trainer.male?
    text.gsub!(/\\pog/i, "\\b") if $Trainer && $Trainer.female?
    text.gsub!(/\\pg/i, "")
    text.gsub!(/\\pog/i, "")
    text.gsub!(/\\b/i, "<c3=3050C8,D0D0C8>")
    text.gsub!(/\\r/i, "<c3=E00808,D0D0C8>")
    text.gsub!(/<imp>/i, "\\c[2]")
    text.gsub!(%r{</imp>}i, "\\c[0]")
    text.gsub!(/\\[Ww]\[([^\]]*)\]/) do
        w = Regexp.last_match(1).to_s
        if w == ""
            msgwindow.windowskin = nil
        else
            msgwindow.setSkin("Graphics/Windowskins/#{w}", false)
        end
        next ""
    end
    isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
    text.gsub!(/\\[Cc]\[([0-9]+)\]/) do
        m = Regexp.last_match(1).to_i
        next getSkinColor(msgwindow.windowskin, m, isDarkSkin)
    end
    loop do
        last_text = text.clone
        text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[Regexp.last_match(1).to_i] }
        break if text == last_text
    end
    loop do
        last_text = text.clone
        text.gsub!(/\\l\[([0-9]+)\]/i) do
            linecount = [1, Regexp.last_match(1).to_i].max
            next ""
        end
        break if text == last_text
    end
    colortag = ""
    if $game_system && $game_system.respond_to?("message_frame") &&
       $game_system.message_frame != 0
        colortag = getSkinColor(msgwindow.windowskin, 0, true)
    else
        colortag = getSkinColor(msgwindow.windowskin, 0, isDarkSkin)
    end
    text = colortag + text
    ### Controls
    textchunks = []
    controls = []
    while text[/(?:\\(f|ff|i|db|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|wu|wl|wr|op|cl|or|ss|\.|\||!|\^))/i]
        textchunks.push($~.pre_match)
        if $~[1]
            controls.push([$~[1].downcase, $~[2], -1])
        else
            controls.push([$~[3].downcase, "", -1])
        end
        text = $~.post_match
    end
    textchunks.push(text)
    for chunk in textchunks
        chunk.gsub!(/\005/, "\\")
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
    badgeDisplayCount = 0
    begin
        textSpeedSetting = $PokemonSystem.textspeed
    rescue StandardError
        textSpeedSetting = 4
    end
    case textSpeedSetting
    when 0..2
        signWaitTime = Graphics.frame_rate / 2
    when 3
        signWaitTime = Graphics.frame_rate / 3
    when 4
        signWaitTime = Graphics.frame_rate / 4
    end
    haveSpecialClose = false
    specialCloseSE = ""
    iconFadeInTime = -1
    for i in 0...controls.length
        control = controls[i][0]
        param = controls[i][1]
        case control
        when "op"
            signWaitCount = signWaitTime + 1
        when "cl"
            text = text.sub(/\001\z/, "") # fix: '$' can match end of line as well
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
        when "db" # Display big
            iconwindow.dispose if iconwindow
            icon_location = "Graphics/#{param}"
            iconwindow = IconSprite.new(msgwindow.viewport)
			iconwindow.setBitmap(icon_location)
            iconwindow.visible = false
            iconwindow.opacity = 0
            msgwindow.visible = false
            iconFadeInTime = 20
        when "ch"
            cmds = param.clone
            cmdvariable = pbCsvPosInt!(cmds)
            cmdIfCancel = pbCsvField!(cmds).to_i
            commands = []
            commands.push(pbCsvField!(cmds)) while cmds.length > 0
        when "wtnp", "^"
            text = text.sub(/\001\z/, "") # fix: '$' can match end of line as well
        when "se"
            if controls[i][2] == 0
                startSE = param
                controls[i] = nil
            end
        end
    end
    if !startSE.nil?
        pbSEPlay(pbStringToAudioFile(startSE))
    elsif signWaitCount == 0 && letterbyletter
        pbPlayDecisionSE
    end
    ########## Position message window  ##############
    pbRepositionMessageWindow(msgwindow, linecount)
    atTop = (msgwindow.y == 0)
    if facewindow
        facewindow.viewport = msgwindow.viewport
        facewindow.z = msgwindow.z
    end
    ########## Show text #############################
    msgwindow.text = text
    Graphics.frame_reset if Graphics.frame_rate > 40
    iconFadeInCount = iconFadeInTime
    loop do
        if $SpeakerNameWindow
            pbPositionNearMsgWindow($SpeakerNameWindow, msgwindow, :left)
            $SpeakerNameWindow.y += 12
            $SpeakerNameWindow.x += 12
            $SpeakerNameWindow.z = msgwindow.z + 1
        end
        if iconFadeInCount > 0
            fadeProgress = (iconFadeInTime - iconFadeInCount) / iconFadeInTime.to_f
            iconwindow.opacity = (fadeProgress * 255).ceil
            iconwindow.y -= 1
            iconFadeInCount -= 1
            msgwindow.visible = true if iconFadeInCount <= 0
        end
        if signWaitCount > 0
            signWaitCount -= 1
            signWaitCount = 0 if Input.trigger?(Input::USE)
            if atTop
                msgwindow.y = -msgwindow.height * signWaitCount / signWaitTime
                facewindow.y = -facewindow.height * signWaitCount / signWaitTime if facewindow
            else
                msgwindow.y = Graphics.height - msgwindow.height * (signWaitTime - signWaitCount) / signWaitTime
                if facewindow
                    facewindow.y = Graphics.height - facewindow.height * (signWaitTime - signWaitCount) / signWaitTime
                end
            end
        end
        for i in 0...controls.length
            next unless controls[i]
            next if controls[i][2] > msgwindow.position || msgwindow.waitcount != 0
            control = controls[i][0]
            param = controls[i][1]
            case control
            when "f"
                facewindow.dispose if facewindow
                facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
                facewindow.viewport = msgwindow.viewport
                facewindow.z        = msgwindow.z
            when "i"
                facewindow.dispose if facewindow
                icon_location = GameData::Item.icon_filename(param)
                facewindow = PictureWindow.new(icon_location)
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
                facewindow.viewport = msgwindow.viewport
                facewindow.z        = msgwindow.z
                facewindow.x = 0
                if signWaitCount > 0
                    if atTop
                        facewindow.y = -facewindow.height * signWaitCount / signWaitTime if facewindow
                    elsif facewindow
                        facewindow.y = Graphics.height - facewindow.height * (signWaitTime - signWaitCount) / signWaitTime
                    end
                end
            when "db"
                iconwindow.dispose if facewindow
                icon_location = "Graphics/#{param}"
                iconwindow = IconSprite.new(msgwindow.viewport)
				iconwindow.setBitmap(icon_location)
				iconwindow.zoom_x 	= 4.0
                iconwindow.zoom_y 	= 4.0
                iconwindow.z        = msgwindow.z
				iconwindow.x		= (Graphics.width - iconwindow.get_display_width) / 2
                iconwindow.y 		= (Graphics.height / 2.0 - (iconwindow.get_display_height * 2) / 3.0).ceil + iconFadeInTime
                msgwindow.waitcount = iconFadeInTime
                autoresume = true
            when "or"
                msgwindow.x	= 60
                msgwindow.width	-= 60
            when "ff"
                facewindow.dispose if facewindow
                facewindow = FaceWindowVX.new(param)
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
                facewindow.viewport = msgwindow.viewport
                facewindow.z        = msgwindow.z
            when "g"      # Display gold window
                goldwindow.dispose if goldwindow
                goldwindow = pbDisplayGoldWindow(msgwindow)
            when "cn"     # Display coins window
                coinwindow.dispose if coinwindow
                coinwindow = pbDisplayCoinsWindow(msgwindow, goldwindow)
            when "pt"     # Display battle points window
                battlepointswindow.dispose if battlepointswindow
                battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
            when "wu" # Window Up
                msgwindow.y = 0
                atTop = true
                msgback.y = msgwindow.y if msgback
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
                msgwindow.y = -msgwindow.height * signWaitCount / signWaitTime
            when "wm" # Window Middle
                atTop = false
                msgwindow.y = (Graphics.height - msgwindow.height) / 2
                msgback.y = msgwindow.y if msgback
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
            when "wd" # Window Down
                atTop = false
                msgwindow.y = Graphics.height - msgwindow.height
                msgback.y = msgwindow.y if msgback
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
                msgwindow.y = Graphics.height - msgwindow.height * (signWaitTime - signWaitCount) / signWaitTime
            when "wl" # Window Left
                msgwindow.x = 0
                msgwindow.width = Graphics.width - 400
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
            when "wr" # Window Right
                msgwindow.x = 400
                msgwindow.width = Graphics.width - 400
                pbPositionNearMsgWindow(facewindow, msgwindow, :left)
            when "ts"     # Change text speed
                msgwindow.textspeed = (param == "") ? -999 : param.to_i
            when "ss"     # Slowed down display speed
                msgwindow.textspeed = MessageConfig.pbSettingToTextSpeed($PokemonSystem.textspeed, true)
            when "."      # Wait 0.25 seconds
                msgwindow.waitcount += Graphics.frame_rate / 4
            when "|"      # Wait 1 second
                msgwindow.waitcount += Graphics.frame_rate
            when "wt"     # Wait X/20 seconds
                param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
                msgwindow.waitcount += param.to_i * Graphics.frame_rate / 20
            when "wtnp"   # Wait X/20 seconds, no pause
                param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
                msgwindow.waitcount = param.to_i * Graphics.frame_rate / 20
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
        break unless letterbyletter
        Graphics.update
        Input.update
        facewindow.update if facewindow
		iconwindow.update if iconwindow
        if autoresume && msgwindow.waitcount == 0
            msgwindow.resume if msgwindow.busy?
            break unless msgwindow.busy?
        end
        if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
            if msgwindow.busy?
                pbPlayDecisionSE if msgwindow.pausing?
                msgwindow.resume
            elsif signWaitCount == 0
                break
            end
        end
        pbUpdateSceneMap
        msgwindow.update
        yield if block_given?
        break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
    end
    Input.update # Must call Input.update again to avoid extra triggers
    msgwindow.letterbyletter = oldletterbyletter
    if commands
        $game_variables[cmdvariable] = pbShowCommands(msgwindow, commands, cmdIfCancel)
        $game_map.need_refresh = true if $game_map
    end
    ret = commandProc.call(msgwindow) if commandProc
    msgback.dispose if msgback
    goldwindow.dispose if goldwindow
    coinwindow.dispose if coinwindow
    battlepointswindow.dispose if battlepointswindow
    if haveSpecialClose
        pbSEPlay(pbStringToAudioFile(specialCloseSE))
        atTop = (msgwindow.y == 0)
        for i in 0..signWaitTime
            if atTop
                msgwindow.y = -msgwindow.height * i / signWaitTime
                facewindow.y = -facewindow.height * i / signWaitTime if facewindow
            else
                msgwindow.y = Graphics.height - msgwindow.height * (signWaitTime - i) / signWaitTime
                facewindow.y = Graphics.height - facewindow.height * (signWaitTime - i) / signWaitTime if facewindow
            end
            Graphics.update
            Input.update
            pbUpdateSceneMap
            msgwindow.update
            facewindow.update if facewindow
        end
    end
    facewindow.dispose if facewindow
	iconwindow.dispose if iconwindow
    $SpeakerNameWindow.visible = false if $SpeakerNameWindow
    return ret
end

def globalMessageReplacements(message)
    return message if message.frozen?
    message.gsub!("’", "'")
    message.gsub!("‘", "'")
    message.gsub!("“", "\"")
    message.gsub!("”", "\"")
    message.gsub!("…", "...")
    message.gsub!("–", "-")
    message.gsub!("—", "-")
    message.gsub!("Pokemon", "Pokémon")
    message.gsub!("Pokedex", "Pokédex")
    message.gsub!("Poke ball", "Poké Ball")
    message.gsub!("Poke Ball", "Poké Ball")
    message.gsub!("Pokeball", "Poké Ball")
    message.gsub!("PokEstate", "PokÉstate")
    return message
end

#===============================================================================
# Message-displaying functions
#===============================================================================
def pbMessage(message, commands = nil, cmdIfCancel = 0, skin = nil, defaultCmd = 0, &block)
    ret = 0
    msgwindow = pbCreateMessageWindow(nil, skin)
    if commands
        showCommandsProc = proc { |msgwindow|
            next Kernel.pbShowCommands(msgwindow, commands, cmdIfCancel, defaultCmd, &block)
        }
        ret = pbMessageDisplay(msgwindow, message, true, showCommandsProc, &block)
    else
        pbMessageDisplay(msgwindow, message, &block)
    end
    pbDisposeMessageWindow(msgwindow)
    Input.update
    return ret
end

def pbConfirmMessage(message, &block)
    return (pbMessage(message, [_INTL("Yes"), _INTL("No")], 2, &block) == 0)
end

def pbConfirmMessageSerious(message, &block)
    return (pbMessage(message, [_INTL("No"), _INTL("Yes")], 1, &block) == 1)
end

def pbConfirmMessageGated(message, &block)
    loop do
        result = pbMessage(message, [_INTL("Not sure"), _INTL("No"), _INTL("Yes")], 1, &block)
        next if result == 0
        return result == 2
    end
end

def pbMessageChooseNumber(message, params, &block)
    msgwindow = pbCreateMessageWindow(nil, params.messageSkin)
    ret = pbMessageDisplay(msgwindow, message, true,
       proc { |msgwindow|
           next pbChooseNumber(msgwindow, params, &block)
       }, &block)
    pbDisposeMessageWindow(msgwindow)
    return ret
end

def pbShowCommands(msgwindow, commands = nil, cmdIfCancel = 0, defaultCmd = 0)
    return 0 unless commands
    cmdwindow = Window_CommandPokemonEx.new(commands)
    cmdwindow.z = 99_999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    pbPositionNearMsgWindow(cmdwindow, msgwindow, :right)
    cmdwindow.index = defaultCmd
    command = 0
    loop do
        Graphics.update
        Input.update
        cmdwindow.update
        msgwindow.update if msgwindow
        yield if block_given?
        if Input.trigger?(Input::BACK)
            if cmdIfCancel > 0
                command = cmdIfCancel - 1
                break
            elsif cmdIfCancel < 0
                command = cmdIfCancel
                break
            end
        end
        if Input.trigger?(Input::USE)
            command = cmdwindow.index
            break
        end
        pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
    return ret
end

def pbShowCommandsWithHelp(msgwindow, commands, help, cmdIfCancel = 0, defaultCmd = 0)
    msgwin = msgwindow
    msgwin = pbCreateMessageWindow(nil) unless msgwindow
    oldlbl = msgwin.letterbyletter
    msgwin.letterbyletter = false
    if commands
        cmdwindow = Window_CommandPokemonEx.new(commands)
        cmdwindow.z = 99_999
        cmdwindow.visible = true
        cmdwindow.resizeToFit(cmdwindow.commands)
        cmdwindow.height = msgwin.y if cmdwindow.height > msgwin.y
        cmdwindow.index = defaultCmd
        command = 0
        msgwin.text = help[cmdwindow.index]
        msgwin.width = msgwin.width # Necessary evil to make it use the proper margins
        loop do
            Graphics.update
            Input.update
            oldindex = cmdwindow.index
            cmdwindow.update
            msgwin.text = help[cmdwindow.index] if oldindex != cmdwindow.index
            msgwin.update
            yield if block_given?
            if Input.trigger?(Input::BACK)
                if cmdIfCancel > 0
                    command = cmdIfCancel - 1
                    break
                elsif cmdIfCancel < 0
                    command = cmdIfCancel
                    break
                end
            end
            if Input.trigger?(Input::USE)
                command = cmdwindow.index
                break
            end
            pbUpdateSceneMap
        end
        ret = command
        cmdwindow.dispose
        Input.update
    end
    msgwin.letterbyletter = oldlbl
    msgwin.dispose unless msgwindow
    return ret
end

# frames is the number of 1/20 seconds to wait for
def pbMessageWaitForInput(msgwindow, frames, showPause = false)
    return if !frames || frames <= 0
    msgwindow.startPause if msgwindow && showPause
    frames = frames * Graphics.frame_rate / 20
    frames.times do
        Graphics.update
        Input.update
        msgwindow.update if msgwindow
        pbUpdateSceneMap
        break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        yield if block_given?
    end
    msgwindow.stopPause if msgwindow && showPause
end

def pbFreeText(msgwindow, currenttext, passwordbox, maxlength, width = 240)
    window = Window_TextEntry_Keyboard.new(currenttext, 0, 0, width, 64)
    ret = ""
    window.maxlength = maxlength
    window.visible = true
    window.z = 99_999
    pbPositionNearMsgWindow(window, msgwindow, :right)
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
        msgwindow.update if msgwindow
        yield if block_given?
    end
    Input.text_input = false
    window.dispose
    Input.update
    return ret
end

def pbMessageFreeText(message, currenttext, passwordbox, maxlength, width = 240, &block)
    msgwindow = pbCreateMessageWindow
    retval = pbMessageDisplay(msgwindow, message, true,
       proc { |msgwindow|
           next pbFreeText(msgwindow, currenttext, passwordbox, maxlength, width, &block)
       }, &block)
    pbDisposeMessageWindow(msgwindow)
    return retval
end

def break_string(str, character_count)
    arr = []
    pos = 0     
    loop do
        break arr if pos == str.size
        if str[pos] == ' '
            pos += 1
        end
        m = str.match(/.{1,#{character_count}}(?=[ ]|\z)|.{,#{character_count-1}}[ ]/, pos)
        return nil if m.nil?
        arr << m[0]
        pos += m[0].size
    end
end