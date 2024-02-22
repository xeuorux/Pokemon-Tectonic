#===============================================================================
# Text entry screen - arrows to select letter.
#===============================================================================
class PokemonEntryScene2
  @@Characters = [
    [("ABCDEFGHIJ ,." + "KLMNOPQRST '-" + "UVWXYZ     ♂♀" + "             " + "0123456789   ").scan(/./), _INTL("UPPER")],
    [("abcdefghij ,." + "klmnopqrst '-" + "uvwxyz     ♂♀" + "             " + "0123456789   ").scan(/./), _INTL("lower")],
    [("ÀÁÂÄÃàáâäã Ææ" + "ÈÉÊË èéêë  Çç" + "ÌÍÎÏ ìíîï  Ññ" + "ÒÓÔÖÕòóôöõ Ýý" + "ÙÚÛÜ ùúûü    ").scan(/./), _INTL("accents")],
    [(",.'\":;!?¡¿ ♂♀" + "~@#*&$µ¶§    " + "()[]{}<>«»   " + "+-×÷=±%¹²³¼½¾" + "^_/\\|        ").scan(/./), _INTL("other")]
  ]
  ROWS    = 13
  COLUMNS = 5
  MODE1   = -6
  MODE2   = -5
  MODE3   = -4
  MODE4   = -3
  BACK    = -2
  OK      = -1

  class NameEntryCursor
    def initialize(viewport)
      @sprite = SpriteWrapper.new(viewport)
      @cursortype = 0
      @cursor1 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_1")
      @cursor2 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_2")
      @cursor3 = AnimatedBitmap.new("Graphics/Pictures/Naming/cursor_3")
      @cursorPos = 0
      updateInternal
    end

    def setCursorPos(value)
      @cursorPos = value
    end

    def updateCursorPos
      value = @cursorPos
      case value
      when PokemonEntryScene2::MODE1   # Upper case
        @sprite.x = 44
        @sprite.y = 120
        @cursortype = 1
      when PokemonEntryScene2::MODE2   # Lower case
        @sprite.x = 106
        @sprite.y = 120
        @cursortype = 1
      when PokemonEntryScene2::MODE3   # Accents
        @sprite.x = 168
        @sprite.y = 120
        @cursortype = 1
      when PokemonEntryScene2::MODE4   # Other symbols
        @sprite.x = 230
        @sprite.y = 120
        @cursortype = 1
      when PokemonEntryScene2::BACK   # Back
        @sprite.x = 314
        @sprite.y = 120
        @cursortype = 2
      when PokemonEntryScene2::OK   # OK
        @sprite.x = 394
        @sprite.y = 120
        @cursortype = 2
      else
        if value >= 0
          @sprite.x = 52 + 32 * (value % PokemonEntryScene2::ROWS)
          @sprite.y = 180 + 38 * (value / PokemonEntryScene2::ROWS)
          @cursortype = 0
        end
      end
    end

    def visible=(value)
      @sprite.visible = value
    end

    def visible
      @sprite.visible
    end

    def color=(value)
      @sprite.color = value
    end

    def color
      @sprite.color
    end

    def disposed?
      @sprite.disposed?
    end

    def updateInternal
      @cursor1.update
      @cursor2.update
      @cursor3.update
      updateCursorPos
      case @cursortype
      when 0 then @sprite.bitmap = @cursor1.bitmap
      when 1 then @sprite.bitmap = @cursor2.bitmap
      when 2 then @sprite.bitmap = @cursor3.bitmap
      end
    end

    def update
      updateInternal
    end

    def dispose
      @cursor1.dispose
      @cursor2.dispose
      @cursor3.dispose
      @sprite.dispose
    end
  end



  def pbStartScene(helptext,minlength,maxlength,initialText,subject=0,pokemon=nil)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @helptext = helptext
    @helper = CharacterEntryHelper.new(initialText)
    # Create bitmaps
    @bitmaps = []
    for i in 0...@@Characters.length
      @bitmaps[i] = AnimatedBitmap.new(sprintf("Graphics/Pictures/Naming/overlay_tab_#{i + 1}"))
      b = @bitmaps[i].bitmap.clone
      pbSetSystemFont(b)
      textPos = []
      for y in 0...COLUMNS
        for x in 0...ROWS
          pos = y * ROWS + x
          textPos.push([@@Characters[i][0][pos], 44 + x * 32, 12 + y * 38, 2,
             Color.new(16, 24, 32), Color.new(160, 160, 160)])
        end
      end
      pbDrawTextPositions(b, textPos)
      @bitmaps[@@Characters.length + i] = b
    end
    underline_bitmap = BitmapWrapper.new(24, 6)
    underline_bitmap.fill_rect(2, 2, 22, 4, Color.new(168, 184, 184))
    underline_bitmap.fill_rect(0, 0, 22, 4, Color.new(16, 24, 32))
    @bitmaps.push(underline_bitmap)
    # Create sprites
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Naming/bg")
    case subject
    when 1   # Player
      meta = GameData::Metadata.get_player($Trainer.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta, 1, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - charwidth / 8
        @sprites["subject"].y = 76 - charheight / 4
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::Center)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, -6, false, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, -6, false, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/Pictures/Naming/icon_shadow")
      @sprites["shadow"].x = 66
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - charwidth / 8
      @sprites["subject"].y = 76 - charheight / 4
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/Pictures/Naming/icon_storage"
      @sprites["subject"].animspeed = 4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - charwidth / 8
      @sprites["subject"].y = 52 - charheight / 2
    end
    @sprites["bgoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay
    @blanks = []
    @mode = 0
    @minlength = minlength
    @maxlength = maxlength
    @maxlength.times { |i|
      @sprites["blank#{i}"] = SpriteWrapper.new(@viewport)
      @sprites["blank#{i}"].x = 160 + 24 * i
      @sprites["blank#{i}"].bitmap = @bitmaps[@bitmaps.length - 1]
      @blanks[i] = 0
    }
    @sprites["bottomtab"] = SpriteWrapper.new(@viewport)   # Current tab
    @sprites["bottomtab"].x = 22
    @sprites["bottomtab"].y = 162
    @sprites["bottomtab"].bitmap = @bitmaps[@@Characters.length]
    @sprites["toptab"]=SpriteWrapper.new(@viewport)   # Next tab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    @sprites["toptab"].bitmap = @bitmaps[@@Characters.length + 1]
    @sprites["controls"] = IconSprite.new(0, 0, @viewport)
    @sprites["controls"].x = 16
    @sprites["controls"].y = 96
    @sprites["controls"].setBitmap(addLanguageSuffix(("Graphics/Pictures/Naming/overlay_controls")))
    @init = true
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay2
    @sprites["cursor"] = NameEntryCursor.new(@viewport)
    @cursorpos = 0
    @refreshOverlay = true
    @sprites["cursor"].setCursorPos(@cursorpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateOverlay
    @refreshOverlay = true
  end

  def pbDoUpdateOverlay2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    modeIcon = [[addLanguageSuffix(("Graphics/Pictures/Naming/icon_mode")), 44 + @mode * 62, 120, @mode * 60, 0, 60, 44]]
    pbDrawImagePositions(overlay, modeIcon)
  end

  def pbDoUpdateOverlay
    return if !@refreshOverlay
    @refreshOverlay = false
    bgoverlay = @sprites["bgoverlay"].bitmap
    bgoverlay.clear
    pbSetSystemFont(bgoverlay)
    textPositions = [
       [@helptext, 160, 6, false, Color.new(16, 24, 32), Color.new(168, 184, 184)]
    ]
    chars = @helper.textChars
    x = 166
    for ch in chars
      textPositions.push([ch, x, 42, false, Color.new(16, 24, 32), Color.new(168, 184, 184)])
      x += 24
    end
    pbDrawTextPositions(bgoverlay, textPositions)
  end

  def pbChangeTab(newtab = @mode + 1)
    pbSEPlay("GUI naming tab swap start")
    @sprites["cursor"].visible = false
    @sprites["toptab"].bitmap = @bitmaps[(newtab % @@Characters.length) + @@Characters.length]
    # Move bottom (old) tab down off the screen, and move top (new) tab right
    # onto the screen
    deltaX = 48 * 20 / Graphics.frame_rate
    deltaY = 24 * 20 / Graphics.frame_rate
    loop do
      if @sprites["bottomtab"].y < 414
        @sprites["bottomtab"].y += deltaY
        @sprites["bottomtab"].y = 414 if @sprites["bottomtab"].y > 414
      end
      if @sprites["toptab"].x < 22
        @sprites["toptab"].x += deltaX
        @sprites["toptab"].x = 22 if @sprites["toptab"].x > 22
      end
      Graphics.update
      Input.update
      pbUpdate
      break if @sprites["toptab"].x >= 22 && @sprites["bottomtab"].y >= 414
    end
    # Swap top and bottom tab around
    @sprites["toptab"].x, @sprites["bottomtab"].x = @sprites["bottomtab"].x, @sprites["toptab"].x
    @sprites["toptab"].y, @sprites["bottomtab"].y = @sprites["bottomtab"].y, @sprites["toptab"].y
    @sprites["toptab"].bitmap, @sprites["bottomtab"].bitmap = @sprites["bottomtab"].bitmap, @sprites["toptab"].bitmap
    Graphics.update
    Input.update
    pbUpdate
    # Set the current mode
    @mode = newtab % @@Characters.length
    # Set the top tab up to be the next tab
    newtab = @bitmaps[((@mode + 1) % @@Characters.length) + @@Characters.length]
    @sprites["cursor"].visible = true
    @sprites["toptab"].bitmap = newtab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 162
    pbSEPlay("GUI naming tab swap end")
    pbDoUpdateOverlay2
  end

  def pbUpdate
    for i in 0...@@Characters.length
      @bitmaps[i].update
    end
    if @init || Graphics.frame_count % 5 == 0
      @init = false
      cursorpos = @helper.cursor
      cursorpos = @maxlength - 1 if cursorpos >= @maxlength
      cursorpos = 0 if cursorpos < 0
      @maxlength.times { |i|
        @blanks[i] = (i == cursorpos) ? 1 : 0
        @sprites["blank#{i}"].y = [78, 82][@blanks[i]]
      }
    end
    pbDoUpdateOverlay
    pbUpdateSpriteHash(@sprites)
  end

  def pbColumnEmpty?(m)
    return false if m >= ROWS - 1
    chset = @@Characters[@mode][0]
    COLUMNS.times do |i|
      return false if chset[i * ROWS + m] != " "
    end
    return true
  end

  def wrapmod(x, y)
    result = x % y
    result += y if result < 0
    return result
  end

  def pbMoveCursor
    oldcursor = @cursorpos
    cursordiv = @cursorpos / ROWS   # The row the cursor is in
    cursormod = @cursorpos % ROWS   # The column the cursor is in
    cursororigin = @cursorpos - cursormod
    if Input.repeat?(Input::LEFT)
      if @cursorpos < 0   # Controls
        @cursorpos -= 1
        @cursorpos = OK if @cursorpos < MODE1
      else
        begin
          cursormod = wrapmod(cursormod - 1, ROWS)
          @cursorpos = cursororigin + cursormod
        end while pbColumnEmpty?(cursormod)
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos < 0   # Controls
        @cursorpos += 1
        @cursorpos = MODE1 if @cursorpos > OK
      else
        begin
          cursormod = wrapmod(cursormod + 1, ROWS)
          @cursorpos = cursororigin + cursormod
        end while pbColumnEmpty?(cursormod)
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos < 0         # Controls
        case @cursorpos
        when MODE1 then @cursorpos = ROWS * (COLUMNS - 1)
        when MODE2 then @cursorpos = ROWS * (COLUMNS - 1) + 2
        when MODE3 then @cursorpos = ROWS * (COLUMNS - 1) + 4
        when MODE4 then @cursorpos = ROWS * (COLUMNS - 1) + 6
        when BACK  then @cursorpos = ROWS * (COLUMNS - 1) + 9
        when OK    then @cursorpos = ROWS * (COLUMNS - 1) + 11
        end
      elsif @cursorpos < ROWS   # Top row of letters
        case @cursorpos
        when 0, 1     then @cursorpos = MODE1
        when 2, 3     then @cursorpos = MODE2
        when 4, 5     then @cursorpos = MODE3
        when 6, 7     then @cursorpos = MODE4
        when 8, 9, 10 then @cursorpos = BACK
        when 11, 12   then @cursorpos = OK
        end
      else
        cursordiv = wrapmod(cursordiv - 1, COLUMNS)
        @cursorpos = cursordiv * ROWS + cursormod
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos < 0                      # Controls
        case @cursorpos
        when MODE1 then @cursorpos = 0
        when MODE2 then @cursorpos = 2
        when MODE3 then @cursorpos = 4
        when MODE4 then @cursorpos = 6
        when BACK  then @cursorpos = 9
        when OK    then @cursorpos = 11
        end
      elsif @cursorpos >= ROWS * (COLUMNS - 1)   # Bottom row of letters
        case cursormod
        when 0, 1     then @cursorpos = MODE1
        when 2, 3     then @cursorpos = MODE2
        when 4, 5     then @cursorpos = MODE3
        when 6, 7     then @cursorpos = MODE4
        when 8, 9, 10 then @cursorpos = BACK
        else               @cursorpos = OK
        end
      else
        cursordiv = wrapmod(cursordiv + 1, COLUMNS)
        @cursorpos = cursordiv * ROWS + cursormod
      end
    end
    if @cursorpos != oldcursor   # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
      pbPlayCursorSE
      return true
    end
    return false
  end

  def pbEntry
    ret = ""
    loop do
      Graphics.update
      Input.update
      pbUpdate
      next if pbMoveCursor
      if Input.trigger?(Input::SPECIAL)
        pbChangeTab
      elsif Input.trigger?(Input::ACTION)
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::BACK)
        @helper.delete
        pbPlayCancelSE
        pbUpdateOverlay
      elsif Input.trigger?(Input::USE)
        case @cursorpos
        when BACK   # Backspace
          @helper.delete
          pbPlayCancelSE
          pbUpdateOverlay
        when OK     # Done
          pbSEPlay("GUI naming confirm")
          if @helper.length >= @minlength
            ret = @helper.text
            break
          end
        when MODE1
          pbChangeTab(0) if @mode != 0
        when MODE2
          pbChangeTab(1) if @mode != 1
        when MODE3
          pbChangeTab(2) if @mode != 2
        when MODE4
          pbChangeTab(3) if @mode != 3
        else
          cursormod = @cursorpos % ROWS
          cursordiv = @cursorpos / ROWS
          charpos = cursordiv * ROWS + cursormod
          chset = @@Characters[@mode][0]
          if @helper.length >= @maxlength
            @helper.delete
          end
          @helper.insert(chset[charpos])
          pbPlayCursorSE
          if @helper.length >= @maxlength
            @cursorpos = OK
            @sprites["cursor"].setCursorPos(@cursorpos)
          end
          pbUpdateOverlay
        end
      end
    end
    Input.update
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    for bitmap in @bitmaps
      bitmap.dispose if bitmap
    end
    @bitmaps.clear
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end