#===============================================================================
# Fight menu (choose a move)
#===============================================================================
class FightMenuDisplay < BattleMenuBase
    attr_reader :battler
    attr_reader :shiftMode
    attr_reader :extraInfoToggled
  
    # If true, displays graphics from Graphics/Pictures/Battle/overlay_fight.png
    #     and Graphics/Pictures/Battle/cursor_fight.png.
    # If false, just displays text and the command window over the graphic
    #     Graphics/Pictures/Battle/overlay_message.png. You will need to edit def
    #     pbShowWindow to make the graphic appear while the command menu is being
    #     displayed.
    USE_GRAPHICS     = true
    TYPE_ICON_HEIGHT = 28

    # Text colours of PP of selected move
    PP_COLORS = [
       Color.new(248,72,72),Color.new(136,48,48),    # Red, zero PP
       Color.new(248,136,32),Color.new(144,72,24),   # Orange, 1/4 of total PP or less
       Color.new(248,192,0),Color.new(144,104,0),    # Yellow, 1/2 of total PP or less
       TEXT_BASE_COLOR,TEXT_SHADOW_COLOR             # Black, more than 1/2 of total PP
    ]
    EFFECTIVENESS_SHADOW_COLOR = Color.new(160, 160, 168)
  
    def initialize(viewport,z)
        super(viewport)
        self.x = 0
        self.y = Graphics.height-96
        @battler   = nil
        @shiftMode = 0
          @extraInfoToggled = false
        # NOTE: @mode is for the display of the Mega Evolution button.
        #       0=don't show, 1=show unpressed, 2=show pressed
        if USE_GRAPHICS
          # Create bitmaps
          @buttonBitmap  			    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
          @typeBitmap    			    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
          @megaEvoBitmap 			    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
          @shiftBitmap   			    = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
          @moveInfoDisplayBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/move_info_display_3x3"))
          @ppUsageUpBitmap        = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/pp_usage_up"))
          @cursorShadeBitmap      = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight_shade"))
          # Create background graphic
          background = IconSprite.new(0,Graphics.height-96,viewport)
          background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
          addSprite("background",background)
          # Create move buttons and highlighters
          @buttons = []
          @highlights = []
          @shaders = []
          for i in 0..Pokemon::MAX_MOVES do
            newButton = SpriteWrapper.new(viewport)
            newButton.bitmap = @buttonBitmap.bitmap
            buttonX = self.x + 4 + (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
            newButton.x      = buttonX
            buttonY = self.y + 6 + (((i/2)==0) ? 0 : BUTTON_HEIGHT-4)
            newButton.y      = buttonY
            newButton.src_rect.width  = @buttonBitmap.width/2
            newButton.src_rect.height = BUTTON_HEIGHT
            addSprite("button_#{i}",newButton)
            @buttons.push(newButton)
    
            newHighlighter = AnimatedSprite.new(["Graphics/Pictures/Battle/cursor_fight_highlight",37,0.5])
            newHighlighter.viewport = viewport
            newHighlighter.x = buttonX + 20
            newHighlighter.y = buttonY + 8
            newHighlighter.opacity = 80
            newHighlighter.blend_type = 1
            addSprite("highlight_#{i}",newHighlighter)
            @highlights.push(newHighlighter)
    
            newShader = SpriteWrapper.new(viewport)
            newShader.bitmap = @cursorShadeBitmap.bitmap
            newShader.x = buttonX + 20
            newShader.y = buttonY + 8
            newShader.opacity = 80
            addSprite("shader_#{i}",newShader)
            @shaders.push(newShader)
          end
          
          # Create overlay for buttons (shows move names)
          @overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
          @overlay.x = self.x
          @overlay.y = self.y
          pbSetNarrowFont(@overlay.bitmap)
          addSprite("overlay",@overlay)
          # Create overlay for selected move's info (shows move's PP)
          @infoOverlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
          @infoOverlay.x = self.x
          @infoOverlay.y = self.y
          pbSetNarrowFont(@infoOverlay.bitmap)
          addSprite("infoOverlay",@infoOverlay)
          # Create Mega Evolution button
          @megaButton = SpriteWrapper.new(viewport)
          @megaButton.bitmap = @megaEvoBitmap.bitmap
          @megaButton.x      = self.x+120
          @megaButton.y      = self.y-@megaEvoBitmap.height/2
          @megaButton.src_rect.height = @megaEvoBitmap.height/2
          addSprite("megaButton",@megaButton)
          # Create Shift button
          @shiftButton = SpriteWrapper.new(viewport)
          @shiftButton.bitmap = @shiftBitmap.bitmap
          @shiftButton.x      = self.x+4
          @shiftButton.y      = self.y-@shiftBitmap.height
          addSprite("shiftButton",@shiftButton)
          # Create extra info reminder button
          # @extraReminder = SpriteWrapper.new(viewport)
          # @extraReminder.bitmap = @extraReminderBitmap.bitmap
          # @extraReminder.x = self.x+4
          # @extraReminder.y = self.y + 6 - @extraReminderBitmap.height
          # addSprite("extraReminder",@extraReminder)
          # Create the move extra info display
          moveInfoDisplayY = self.y-@moveInfoDisplayBitmap.height
          @moveInfoDisplay = SpriteWrapper.new(viewport)
          @moveInfoDisplay.bitmap = @moveInfoDisplayBitmap.bitmap
          @moveInfoDisplay.x      = self.x
          @moveInfoDisplay.y      = moveInfoDisplayY
          addSprite("moveInfoDisplay",@moveInfoDisplay)
            # Create overlay for selected move's extra info (shows move's BP, description)
          @extraInfoOverlay = BitmapSprite.new(@moveInfoDisplayBitmap.bitmap.width,@moveInfoDisplayBitmap.height,viewport)
          @extraInfoOverlay.x = self.x
          @extraInfoOverlay.y = moveInfoDisplayY
          pbSetNarrowFont(@extraInfoOverlay.bitmap)
          addSprite("extraInfoOverlay",@extraInfoOverlay)
        else
          # Create message box (shows type and PP of selected move)
          @msgBox = Window_AdvancedTextPokemon.newWithSize("",
             self.x+320,self.y,Graphics.width-320,Graphics.height-self.y,viewport)
          @msgBox.baseColor   = TEXT_BASE_COLOR
          @msgBox.shadowColor = TEXT_SHADOW_COLOR
          pbSetNarrowFont(@msgBox.contents)
          addSprite("msgBox",@msgBox)
          # Create command window (shows moves)
          @cmdWindow = Window_CommandPokemon.newWithSize([],
             self.x,self.y,320,Graphics.height-self.y,viewport)
          @cmdWindow.columns       = 2
          @cmdWindow.columnSpacing = 4
          @cmdWindow.ignore_input  = true
          pbSetNarrowFont(@cmdWindow.contents)
          addSprite("cmdWindow",@cmdWindow)
        end
        self.z = z
    end
  
    def dispose
        super
        @buttonBitmap.dispose if @buttonBitmap
        @typeBitmap.dispose if @typeBitmap
        @megaEvoBitmap.dispose if @megaEvoBitmap
        @shiftBitmap.dispose if @shiftBitmap
          #@extraReminderBitmap if @extraReminderBitmap
          @moveInfoDisplayBitmap.dispose if @moveInfoDisplayBitmap
        @ppUsageUpBitmap.dispose if @ppUsageUpBitmap
    end
  
    def z=(value)
        super
        @msgBox.z      += 1 if @msgBox
        @cmdWindow.z   += 2 if @cmdWindow
        @overlay.z     += 5 if @overlay
        @infoOverlay.z += 6 if @infoOverlay
        @highlights.each do |highlight|
          highlight.z += 6
        end
        @shaders.each do |highlight|
          highlight.z += 7
        end
    end

    def visible=(value)
        super(value)
          @sprites["moveInfoDisplay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
          @sprites["extraInfoOverlay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
          #@sprites["extraReminder"].visible = !@extraInfoToggled && @visible if @sprites["extraReminder"]
    end
  
    def battler=(value)
      @battler = value
      refresh
      refreshButtonNames
    end
  
    def shiftMode=(value)
      oldValue = @shiftMode
      @shiftMode = value
      refreshShiftButton if @shiftMode!=oldValue
    end

    def toggleExtraInfo
        @extraInfoToggled = !@extraInfoToggled
        @sprites["moveInfoDisplay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
        @sprites["extraInfoOverlay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
        #@sprites["extraReminder"].visible = !@extraInfoToggled && @visible if @sprites["extraReminder"]
    end
  
    def refreshButtonNames
        moves = (@battler) ? @battler.moves : []
        if !USE_GRAPHICS
          # Fill in command window
          commands = []
          for i in 0...[4, moves.length].max
            commands.push((moves[i]) ? moves[i].name : "-")
          end
          @cmdWindow.commands = commands
          return
        end
        # Draw move names onto overlay
        @overlay.bitmap.clear
        textPos = []
        @buttons.each_with_index do |button,i|
          @visibility["highlight_#{i}"] = false
          @visibility["shader_#{i}"] = false
          next if !@visibility["button_#{i}"]
          move = moves[i]
          x = button.x-self.x+button.src_rect.width/2
          y = button.y-self.y+2
          moveNameBase = TEXT_BASE_COLOR
          if move.type
            # NOTE: This takes a colour from a particular pixel in the button
            #       graphic and makes the move name's base colour that same colour.
            #       The pixel is at coordinates 10,34 in the button box. If you
            #       change the graphic, you may want to change/remove the below line
            #       of code to ensure the font is an appropriate colour.
            moveNameBase = button.bitmap.get_pixel(10,button.src_rect.y+34)
          end
          textPos.push([move.name,x,y,2,moveNameBase,TEXT_SHADOW_COLOR])
          begin
            # Determine whether to shade the move
            targetingData = move.pbTarget(@battler)
            @battler.turnCount += 1 # Fake the turn count
            if targetingData.num_targets == 0 || move.worksWithNoTargets?
              shouldShade = move.shouldShade?(@battler,nil)
            else
              shouldShade = true
              @battler.battle.eachBattler do |otherBattler|
                next unless @battler.battle.pbMoveCanTarget?(@battler.index,otherBattler.index,targetingData)
                next if move.shouldShade?(@battler,otherBattler)
                shouldShade = false
                break
              end
            end
            @battler.turnCount -= 1 # Fake the turn count
    
            if shouldShade
              @visibility["shader_#{i}"] = true
            # Determine whether to highlight the move
            elsif move.damagingMove?(true)
              shouldHighlight = false
    
              if targetingData.num_targets == 0
                shouldHighlight = move.shouldHighlight?(user,nil)
              else
                @battler.eachOpposing do |opposingBattler|
                  next unless @battler.battle.pbMoveCanTarget?(@battler.index,opposingBattler.index,targetingData)
                  next unless move.shouldHighlight?(@battler,opposingBattler)
                  shouldHighlight = true
                  break
                end
              end
      
              if shouldHighlight
                @visibility["highlight_#{i}"] = true
                @sprites["highlight_#{i}"].start
              end
            end
          rescue
            echoln("Error computing shading and highlighting for move #{move.name}")
          end
        end
        pbDrawTextPositions(@overlay.bitmap,textPos)
        @buttons.each_with_index do |button,i|
          next if !@visibility["button_#{i}"]
          if PP_INCREASE_REPEAT_MOVES
            if @battler && @battler.lastMoveUsed && @battler.lastMoveUsed == moves[i].id && !@battler.lastMoveFailed
              x = button.x-self.x+button.src_rect.width - 32
              y = button.y-self.y+4
              @overlay.bitmap.blt(x,y+2,@ppUsageUpBitmap.bitmap,Rect.new(0,0,@ppUsageUpBitmap.width,@ppUsageUpBitmap.height))
            end
          end
        end
    end
  
    def refreshSelection
      moves = (@battler) ? @battler.moves : []
      if USE_GRAPHICS
        # Choose appropriate button graphics and z positions
        @buttons.each_with_index do |button,i|
          if !moves[i]
            @visibility["button_#{i}"] = false
            next
          end
          @visibility["button_#{i}"] = true
          button.src_rect.x = (i==@index) ? @buttonBitmap.width/2 : 0
          button.src_rect.y = GameData::Type.get(moves[i].type).id_number * BUTTON_HEIGHT
          button.z          = self.z + ((i==@index) ? 4 : 3)
        end
      end
      refreshMoveData(moves[@index])
    end
  
    def refreshMoveData(move)
        @infoOverlay.bitmap.clear
        return unless move

        base   = Color.new(248,248,248)
        faded_base = Color.new(110,110,110)
        shadow = Color.new(104,104,104)

        pbSetNarrowFont(@infoOverlay.bitmap)
        moveInfoToggleReminderText = []
        moveInfoToggleReminderText.push([_INTL("Toggle Info:"),448,6,2,faded_base,TEXT_SHADOW_COLOR])
        moveInfoToggleReminderText.push([_INTL("ACTION/Z"),448,26,2,faded_base,TEXT_SHADOW_COLOR])
        pbDrawTextPositions(@infoOverlay.bitmap,moveInfoToggleReminderText)
        pbSetSystemFont(@infoOverlay.bitmap)
        
        effectivenessTextPos = nil
        effectivenessTextX = 448
        effectivenessTextY = 48
        if move.damagingMove?(true)
          begin
            if move.is_a?(PokeBattle_FixedDamageMove)
              effectivenessDescription = "Neutral"
              effectivenessColor = EFFECTIVENESS_COLORS[3]
            else
              typeOfMove = move.pbCalcType(@battler)
              targetingData = move.pbTarget(@battler)
              maxEffectiveness = 0
              @battler.eachOpposing do |opposingBattler|
                  next if !@battler.battle.pbMoveCanTarget?(@battler.index,opposingBattler.index,targetingData)
                  effectiveness = move.pbCalcTypeMod(typeOfMove,@battler,opposingBattler,true)
                  maxEffectiveness = effectiveness if effectiveness > maxEffectiveness
              end

              ration = maxEffectiveness/Effectiveness::NORMAL_EFFECTIVE.to_f
              case ration
              when 0              then effectivenessCategory = 0
              when 0.00001..0.25  then effectivenessCategory = 1
              when 0.5 	          then effectivenessCategory = 2
              when 1 		    	    then effectivenessCategory = 3
              when 2 			        then effectivenessCategory = 4
              when 4.. 			      then effectivenessCategory = 5
              end

              effectivenessDescription = [_INTL("No Effect"),_INTL("Barely"),_INTL("Not Very"),_INTL("Neutral"),_INTL("Super"),_INTL("Hyper"),_INTL("Hyper")][effectivenessCategory]
              effectivenessColor = EFFECTIVENESS_COLORS[effectivenessCategory]
            end
            
            effectivenessTextPos = [effectivenessDescription,effectivenessTextX,effectivenessTextY,2,
            effectivenessColor,EFFECTIVENESS_SHADOW_COLOR]
          rescue
            effectivenessTextPos = ["ERROR",effectivenessTextX,effectivenessTextY,2,TEXT_BASE_COLOR,TEXT_SHADOW_COLOR]
          end
        # Apply a highlight to moves that are in an extra useful state
        else
          effectivenessTextPos = ["Status",effectivenessTextX,effectivenessTextY,2,TEXT_BASE_COLOR,TEXT_SHADOW_COLOR]
        end

        pbDrawTextPositions(@infoOverlay.bitmap,[effectivenessTextPos]) if !effectivenessTextPos.nil?
        
        # Extra move info display
        @extraInfoOverlay.bitmap.clear
        overlay = @extraInfoOverlay.bitmap
        moveData = GameData::Move.get(move.id)
        
        # Write power and accuracy values for selected move
        # Write various bits of text
        moveInfoColumn1LabelX = 8
        moveInfoColumn2LabelX = moveInfoColumn1LabelX + 184
        moveInfoColumn3LabelX = moveInfoColumn2LabelX + 184 - 40

        textpos = []

        # Column 1
        textpos.concat(
          [
            [_INTL("TYPE"),moveInfoColumn1LabelX,0,0,base,shadow],
            [_INTL("CATEGORY"),moveInfoColumn1LabelX,32,0,base,shadow],
            [_INTL("POWER"),moveInfoColumn1LabelX,64,0,base,shadow],
          ]
        )

        # Column 2
        textpos.concat(
          [
            [_INTL("ACC"),moveInfoColumn2LabelX,0,0,base,shadow],
            [_INTL("PP"),moveInfoColumn2LabelX,32,0,base,shadow],
            [_INTL("TAG"),moveInfoColumn2LabelX,64,0,base,shadow],
          ]
        )

        # Column 1
        textpos.concat(
          [
            [_INTL("PRIORITY"),moveInfoColumn3LabelX,0,0,base,shadow],
            [_INTL("TARGET"),moveInfoColumn3LabelX,32,0,base,shadow],
          ]
        )
        
        base = Color.new(64,64,64)
        shadow = Color.new(176,176,176)
        moveInfoColumn1ValueX = moveInfoColumn1LabelX + 134
        moveInfoColumn2ValueX = moveInfoColumn2LabelX + 134 - 40
        moveInfoColumn3ValueX = moveInfoColumn3LabelX + 134

        # Column 1
        # Draw selected move's damage category icon and type icon
        imagepos = [
          ["Graphics/Pictures/types", moveInfoColumn1ValueX - 28, 8, 0, GameData::Type.get(moveData.type).id_number * 28, 64, 28],
          ["Graphics/Pictures/category", moveInfoColumn1ValueX - 28, 32 + 8, 0, moveData.category * 28, 64, 28],
        ]
        pbDrawImagePositions(overlay, imagepos)
        # Base damage
        case moveData.base_damage
        when 0 then textpos.push(["---", moveInfoColumn1ValueX, 64, 2, faded_base, shadow])   # Status move
        when 1 then textpos.push(["???", moveInfoColumn1ValueX, 64, 2, base, shadow])   # Variable power move
        else        textpos.push([moveData.base_damage.to_s, moveInfoColumn1ValueX, 64, 2, base, shadow])
        end

        # Column 2
        # Accuracy
        if moveData.accuracy == 0
          textpos.push(["---", moveInfoColumn2ValueX, 0, 2, faded_base, shadow])
        else
          textpos.push(["#{moveData.accuracy}%", moveInfoColumn2ValueX, 0, 2, base, shadow])
        end
        # PP
        if moveData.total_pp > 0
          ppFraction = [(4.0*move.pp/move.total_pp).ceil,3].min
          textpos.push([_INTL("{1}/{2}",move.pp,move.total_pp),moveInfoColumn2ValueX, 32, 2, PP_COLORS[ppFraction*2], PP_COLORS[ppFraction*2+1]])
        else
          textpos.push(["---", moveInfoColumn2ValueX, 32, 2, faded_base, shadow])
        end
        # Tag
        moveCategoryLabel = moveData.tagLabel || "---"
        textpos.push([moveCategoryLabel, moveInfoColumn2ValueX, 64, 2, moveData.tagLabel ? base : faded_base, shadow])

        # Column 3
        # Priority
        textpos.push([moveData.priorityLabel,moveInfoColumn3ValueX + 6, 0, 2, move.priority != 0 ? base : faded_base, shadow])
        # Targeting
        targetingData = GameData::Target.get(moveData.target)
        textpos.push([targetingData.get_targeting_label,moveInfoColumn3LabelX + 4, 64, 0, base, shadow])

        # Targeting graphic
        targetingGraphicTextPos = []
        targetingGraphicColumn1X = moveInfoColumn3LabelX + 84
        targetingGraphicColumn2X = targetingGraphicColumn1X + 46
        targetingGraphicRow1Y = 38
        targetingGraphicRow2Y = targetingGraphicRow1Y + 26

        targetableColor = Color.new(120,5,5)
        untargetableColor = faded_base

        # Foes
        foeColor = targetingData.show_foe_targeting? ? targetableColor : untargetableColor
        targetingGraphicTextPos.push(["Foe",targetingGraphicColumn1X, targetingGraphicRow1Y, 0, foeColor, shadow])
        targetingGraphicTextPos.push(["Foe",targetingGraphicColumn2X, targetingGraphicRow1Y, 0, foeColor, shadow])

        # User
        userColor = targetingData.show_user_targeting? ? targetableColor : untargetableColor
        targetingGraphicTextPos.push(["User",targetingGraphicColumn1X, targetingGraphicRow2Y, 0, userColor, shadow])
        
        # Ally
        allyColor = targetingData.show_ally_targeting? ? targetableColor : untargetableColor
        targetingGraphicTextPos.push(["Ally",targetingGraphicColumn2X, targetingGraphicRow2Y, 0, allyColor, shadow])
        
        # Draw the targeting graphic text
        pbSetNarrowFont(overlay)
        overlay.font.size = 20
        pbDrawTextPositions(overlay, targetingGraphicTextPos)
        pbSetSystemFont(overlay)

        # Draw all text
        pbDrawTextPositions(overlay, textpos)

        # Draw selected move's description
        drawTextEx(overlay,8,96 + 12,500,4,moveData.description,base,shadow)
    end
  
    def refreshMegaEvolutionButton
      return if !USE_GRAPHICS
      @megaButton.src_rect.y    = (@mode - 1) * @megaEvoBitmap.height / 2
      @megaButton.x             = self.x + ((@shiftMode > 0) ? 204 : 120)
      @megaButton.z             = self.z - 1
      @visibility["megaButton"] = (@mode > 0)
    end
  
    def refreshShiftButton
      return if !USE_GRAPHICS
      @shiftButton.src_rect.y    = (@shiftMode - 1) * @shiftBitmap.height
      @shiftButton.z             = self.z - 1
      @visibility["shiftButton"] = (@shiftMode > 0)
    end
  
    def refresh
      return if !@battler
      refreshSelection
      refreshMegaEvolutionButton
      refreshShiftButton
    end
end