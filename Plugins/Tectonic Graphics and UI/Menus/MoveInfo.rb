module MoveInfoDisplay
    # Text colours of PP of selected 
    PP_COLORS = [
       Color.new(248,72,72),Color.new(136,48,48),    # Red, zero PP
       Color.new(248,136,32),Color.new(144,72,24),   # Orange, 1/4 of total PP or less
       Color.new(248,192,0),Color.new(144,104,0),    # Yellow, 1/2 of total PP or less
       Color.new(80,80,88),Color.new(160,160,168)    # Black, more than 1/2 of total PP
    ]
    PP_COLORS_DARK = [
      Color.new(248,72,72),Color.new(136,48,48),    # Red, zero PP
      Color.new(248,136,32),Color.new(144,72,24),   # Orange, 1/4 of total PP or less
      Color.new(248,192,0),Color.new(144,104,0),    # Yellow, 1/2 of total PP or less
      Color.new(248,248,248),Color.new(104,104,104) # White, more than 1/2 of total PP
   ]

    def writeMoveInfoToInfoOverlay3x3(overlay,move,skipTutorial = false)
        moveData = GameData::Move.get(move.id)

        base   = darkMode? ? Color.new(248, 248, 248) : MessageConfig::DARK_TEXT_MAIN_COLOR
        shadow = darkMode? ? Color.new(104, 104, 104) : MessageConfig::DARK_TEXT_SHADOW_COLOR

        overlay.clear
              
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
        
        base       = darkMode? ? Color.new(248, 248, 248) : MessageConfig::DARK_TEXT_MAIN_COLOR
        faded_base = darkMode? ? Color.new(145, 145, 145) : Color.new(110, 110, 110)
        shadow     = darkMode? ? Color.new(104, 104, 104) : MessageConfig::DARK_TEXT_SHADOW_COLOR
        moveInfoColumn1ValueX = moveInfoColumn1LabelX + 134
        moveInfoColumn2ValueX = moveInfoColumn2LabelX + 134 - 40
        moveInfoColumn3ValueX = moveInfoColumn3LabelX + 134
      
        # Column 1
        # Draw selected move's damage category icon and type icon
        imagepos = [
          [addLanguageSuffix("Graphics/Pictures/types"), moveInfoColumn1ValueX - 28, 8, 0, GameData::Type.get(moveData.type).id_number * 28, 64, 28],
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
        elsif moveData.accuracy == 100
          textpos.push(["#{moveData.accuracy}%", moveInfoColumn2ValueX, 0, 2, faded_base, shadow])
        else
          textpos.push(["#{moveData.accuracy}%", moveInfoColumn2ValueX, 0, 2, base, shadow])
        end
        # PP
        if moveData.total_pp > 0
          ppFraction = [(4.0*move.pp/move.total_pp).ceil,3].min
          color_map = darkMode? ? PP_COLORS_DARK : PP_COLORS
          textpos.push([_INTL("{1}/{2}",move.pp,move.total_pp),moveInfoColumn2ValueX, 32, 2, color_map[ppFraction*2], color_map[ppFraction*2+1]])
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
      
        targetableColor = darkMode? ? Color.new(240,5,5) : Color.new(120,5,5)
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

        playAdaptiveMovesTutorial if moveData.category == 3 && !$PokemonGlobal.adaptiveMovesTutorialized && !skipTutorial
    end

    def writeMoveInfoToInfoOverlayBackwardsL(overlay,move,drawName=true)
      # Extra move info display
      overlay.clear
      moveData = GameData::Move.get(move)

      # Prepare values
      base       = MessageConfig::LIGHT_TEXT_MAIN_COLOR # This is the same in light and dark mode
      faded_base = MessageConfig.pbDefaultFadedTextColor
      shadow     = MessageConfig.pbDefaultTextShadowColor
      column1LabelX = 262
      column2LabelX = 338
      column3LabelX = 446
      column1ValueX = 290
      column2ValueX = 384
      column3ValueX = 476
      row1LabelY = 80
      row2LabelY = 146
      row3LabelY = 210
      row1ValueY = row1LabelY + 32
      row2ValueY = row2LabelY + 32
      row3ValueY = row3LabelY + 32

      nameX = 382
      nameY = 46
      descriptionX = 8
      descriptionY = 286

      # Labels #
      textpos = []
      
      # Start with the name
      name_base = MessageConfig::pbDefaultTextMainColor
      textpos.push([moveData.name, nameX, nameY, 2, name_base, shadow]) if drawName

      # Row 1
      textpos.concat([
          [_INTL("TYPE"), column1LabelX, row1LabelY, 0, base, shadow],
          [_INTL("CATEGORY"), column2LabelX, row1LabelY, 0, base, shadow],
          [_INTL("POWER"), column3LabelX, row1LabelY, 0, base, shadow],
      ])

      # Row 1
      textpos.concat([
          [_INTL("ACC"), column1LabelX, row2LabelY, 0, base, shadow],
          [_INTL("PRIORITY"), column2LabelX, row2LabelY, 0, base, shadow],
          [_INTL("PP"), column3LabelX, row2LabelY, 0, base, shadow],
      ])

      # Row 1
      textpos.concat([
          [_INTL("TAG"), column1LabelX, row3LabelY, 0, base, shadow],
          [_INTL("TARGET"), column2LabelX, row3LabelY, 0, base, shadow],
      ])

      # Values #
      base   = MessageConfig.pbDefaultTextMainColor
      shadow = MessageConfig.pbDefaultTextShadowColor

      # Row 1
      # Draw selected move's damage category icon and type icon
      imagepos = [
          [addLanguageSuffix("Graphics/Pictures/types"), column1LabelX, row1ValueY + 8, 0, GameData::Type.get(moveData.type).id_number * 28, 64, 28],
          ["Graphics/Pictures/category", column2LabelX + 16, row1ValueY + 8, 0, moveData.category * 28, 64, 28],
      ]
      pbDrawImagePositions(overlay, imagepos)

      # Base damage
      case moveData.base_damage
      when 0 then textpos.push(["---", column3ValueX, row1ValueY, 2, faded_base, shadow])   # Status move
      when 1 then textpos.push(["???", column3ValueX, row1ValueY, 2, base, shadow])   # Variable power move
      else        textpos.push([moveData.base_damage.to_s, column3ValueX, row1ValueY, 2, base, shadow])
      end

      # Row 2
      # Accuracy
      if moveData.accuracy == 0
          textpos.push(["---", column1ValueX, row2ValueY, 2, faded_base, shadow])
      elsif moveData.accuracy == 100
          textpos.push(["#{moveData.accuracy}%", column1ValueX, row2ValueY, 2, faded_base, shadow])
      else
          textpos.push(["#{moveData.accuracy}%", column1ValueX, row2ValueY, 2, base, shadow])
      end

      # Priority
      textpos.push([moveData.priorityLabel,column2ValueX, row2ValueY, 2, moveData.priority != 0 ? base : faded_base, shadow])

      # PP
      textpos.push([moveData.total_pp.to_s,column3ValueX, row2ValueY, 2, moveData.total_pp > 0 ? base : faded_base, shadow])

      # Row 3
      moveCategoryLabel = moveData.tagLabel || "---"
      textpos.push([moveCategoryLabel, column1ValueX, row3ValueY, 2, moveData.tagLabel ? base : faded_base, shadow])
      
      # Targeting
      targetingData = GameData::Target.get(moveData.target)
      textpos.push([targetingData.get_targeting_label,column2LabelX + 4, row3ValueY, 0, base, shadow])

      # Targeting graphic
      targetingGraphicTextPos = []
      targetingGraphicColumn1X = column2LabelX + 84
      targetingGraphicColumn2X = targetingGraphicColumn1X + 46
      targetingGraphicRow1Y = row3LabelY + 4
      targetingGraphicRow2Y = targetingGraphicRow1Y + 26

      targetableColor = darkMode? ? Color.new(240,5,5) : Color.new(120,5,5)
      untargetableColor = faded_base

      # Foes
      foeColor = targetingData.show_foe_targeting? ? targetableColor : untargetableColor
      targetingGraphicTextPos.push([_INTL("Foe"),targetingGraphicColumn1X, targetingGraphicRow1Y, 0, foeColor, shadow])
      targetingGraphicTextPos.push([_INTL("Foe"),targetingGraphicColumn2X, targetingGraphicRow1Y, 0, foeColor, shadow])

      # User
      userColor = targetingData.show_user_targeting? ? targetableColor : untargetableColor
      targetingGraphicTextPos.push([_INTL("User"),targetingGraphicColumn1X, targetingGraphicRow2Y, 0, userColor, shadow])

      # Ally
      allyColor = targetingData.show_ally_targeting? ? targetableColor : untargetableColor
      targetingGraphicTextPos.push([_INTL("Ally"),targetingGraphicColumn2X, targetingGraphicRow2Y, 0, allyColor, shadow])

      # Draw the targeting graphic text
      pbSetNarrowFont(overlay)
      overlay.font.size = 20
      pbDrawTextPositions(overlay, targetingGraphicTextPos)
      pbSetSystemFont(overlay)

      # Draw all text
      pbDrawTextPositions(overlay, textpos)

      # Draw selected move's description
      drawTextEx(overlay, descriptionX, descriptionY, 496, 3, moveData.description, base, shadow)

      playAdaptiveMovesTutorial if moveData.category == 3 && !$PokemonGlobal.adaptiveMovesTutorialized
    end
end