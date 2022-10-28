class PokemonDataBox < SpriteWrapper

	# Time in seconds to fully fill the Exp bar (from empty).
	EXP_BAR_FILL_TIME  = 0.5
	# Maximum time in seconds to make a change to the HP bar.
	HP_BAR_CHANGE_TIME = 0.5
	PokemonDataBox
	TYPE_ICON_HEIGHT = 18
	TYPE_ICON_THIN_HEIGHT = 20
	NAME_BASE_COLOR = Color.new(255,255,255)
	NAME_SHADOW_COLOR       = Color.new(136,136,136)

	attr_accessor :showTypes
	
	def initialize(battler,sideSize,viewport=nil)
		super(viewport)
		@battler      = battler
		@sprites      = {}
		@spriteX      = 0
		@spriteY      = 0
		@spriteBaseX  = 0
		@selected     = 0
		@frame        = 0
		@showHP       = false   # Specifically, show the HP numbers
		@animatingHP  = false
		@showExp      = false   # Specifically, show the Exp bar
		@animatingExp = false
		@expFlash     = 0
		@showTypes    = false
		@halvedStatus = false
		@thinBox	  = false
		@bossGraphics = @battler.boss && sideSize == 1
		@legendary = isLegendary(@battler.species)
		initializeDataBoxGraphic(sideSize)
		initializeOtherGraphics(viewport)
		refresh
	end
	
	def initializeDataBoxGraphic(sideSize)
		onPlayerSide = ((@battler.index%2)==0)
		# Get the data box graphic and set whether the HP numbers/Exp bar are shown
		if sideSize==1   # One Pokémon on side, use the regular data box BG
		  bgFilename = ["Graphics/Pictures/Battle/databox_normal",
						"Graphics/Pictures/Battle/databox_normal_foe"][@battler.index%2]
		  if @bossGraphics
			bgFilename += "_boss" 
			bgFilename += "_legend" if @legendary
		  end
		  if onPlayerSide
			@showHP  = true
			@showExp = true
		  end
		else   # Multiple Pokémon on side, use the thin data box BG
		  bgFilename = ["Graphics/Pictures/Battle/databox_thin",
						"Graphics/Pictures/Battle/databox_thin_foe"][@battler.index%2]
		  @halvedStatus = true if @battler.boss
		  @thinBox = true
		end
		@showTypes = true if !onPlayerSide
		@databoxBitmap  = AnimatedBitmap.new(bgFilename)
		# Determine the co-ordinates of the data box and the left edge padding width
		if onPlayerSide
		  @spriteX = Graphics.width - 244
		  @spriteY = Graphics.height - 192
		  @spriteBaseX = 34
		else
		  @spriteX = -16
		  @spriteY = 36
		  @spriteBaseX = 16
		end
		case sideSize
		when 1
			@spriteY -= 20 if @bossGraphics && @legendary
		when 2
		  @spriteX += [-12,  12,  0,  0][@battler.index]
		  @spriteY += [-20, -34, 34, 20][@battler.index]
		when 3
		  @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
		  @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
		end
	  end
	  
	def animateHP(oldHP,newHP,rangeHP,fastAnimation=false)
		@currentHP   = oldHP
		@endHP       = newHP
		@rangeHP     = rangeHP
		fastAnimation = true if @battler.battle.autoTesting
		if !fastAnimation
			# NOTE: A change in HP takes the same amount of time to animate, no matter
			#       how big a change it is.
			@hpIncPerFrame = (newHP-oldHP).abs/(HP_BAR_CHANGE_TIME*Graphics.frame_rate)
			# minInc is the smallest amount that HP is allowed to change per frame.
			# This avoids a tiny change in HP still taking HP_BAR_CHANGE_TIME seconds.
			minInc = (rangeHP*4)/(@hpBarBitmap.width*HP_BAR_CHANGE_TIME*Graphics.frame_rate)
			@hpIncPerFrame = [@hpIncPerFrame,minInc].max
		else
			@hpIncPerFrame = 999
		end
		@animatingHP   = true
	end
	
	def animateExp(oldExp,newExp,rangeExp)
		@currentExp     = oldExp
		@endExp         = newExp
		@rangeExp       = rangeExp
		# NOTE: Filling the Exp bar from empty to full takes EXP_BAR_FILL_TIME
		#       seconds no matter what. Filling half of it takes half as long, etc.
		@expIncPerFrame = rangeExp/(EXP_BAR_FILL_TIME*Graphics.frame_rate)
		@animatingExp   = true
		if @showExp
			if (@bossGraphics || !@battler.battle.wildBattle?)
				pbSEPlay("Pkmn exp gain",nil,100)
			else
				pbSEPlay("Pkmn exp gain",nil,85)
			end
		end
	end

	def refresh
		self.bitmap.clear
		return if !@battler.pokemon
		textPos = []
		imagePos = []
		# Draw background panel
		self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
		# Draw Pokémon's name
		nameWidth = self.bitmap.text_size(@battler.name).width
		nameOffset = 0
		nameOffset = nameWidth-116 if nameWidth>116
		nameColor = @battler.empowered? ? Color.new(221,207, 115) : NAME_BASE_COLOR
		textPos.push([@battler.name,@spriteBaseX+8-nameOffset,0,false,nameColor,NAME_SHADOW_COLOR])
		# Draw Pokémon's gender symbol
		case @battler.displayGender
		when 0   # Male
		  textPos.push([_INTL("♂"),@spriteBaseX+126,0,false,MALE_BASE_COLOR,MALE_SHADOW_COLOR])
		when 1   # Female
		  textPos.push([_INTL("♀"),@spriteBaseX+126,0,false,FEMALE_BASE_COLOR,FEMALE_SHADOW_COLOR])
		end
		pbDrawTextPositions(self.bitmap,textPos)
		# Draw Pokémon's level
		imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16])
		pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16)
		# Draw shiny icon
		if @battler.shiny?
		  shinyX = (@battler.opposes?(0)) ? 214 : -6   # Foe's/player's
		  shinyIconFileName = @battler.shiny_variant? ? "Graphics/Pictures/shiny_variant" : "Graphics/Pictures/shiny"
		  imagePos.push([shinyIconFileName,@spriteBaseX+shinyX,36])
		end
		# Draw Mega Evolution/Primal Reversion icon
		if @battler.mega?
		  imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
		elsif @battler.primal?
		  primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
		  if @battler.isSpecies?(:KYOGRE)
			imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+primalX,4])
		  elsif @battler.isSpecies?(:GROUDON)
			imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+primalX,4])
		  end
		# Draw held item icon
		elsif @battler.item && @battler.itemActive?
		  itemX = (@battler.opposes?(0)) ? 204 : 0   # Foe's/player's
		  itemY = 36
		  imagePos.push(["Graphics/Pictures/Party/icon_item",@spriteBaseX+itemX,itemY])
		end
		# Draw owned icon (foe Pokémon only)
		if @battler.owned? && @battler.opposes?(0) && !@battler.boss
		  imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
		end
		firstStatusY = 36
		# Draw status icon
		statuses = @battler.getStatuses()
		statusID = GameData::Status.get(statuses[0]).id_number
		statusWidth = @halvedStatus ? 22 : -1
		imagePos.push(["Graphics/Pictures/Battle/BattleButtonRework/icon_statuses",@spriteBaseX+24,firstStatusY,
			 0,statusID*STATUS_ICON_HEIGHT,statusWidth,STATUS_ICON_HEIGHT])
		# Draw status icon for bosses
		if statuses.length > 1
			statusID2 = GameData::Status.get(statuses[1]).id_number
			x = @spriteBaseX + 24
			x += 22 if @halvedStatus
			y = firstStatusY
			y += 4 + STATUS_ICON_HEIGHT if !@halvedStatus
			statusXRect = @halvedStatus ? 22 : 0
			statusWidth = @halvedStatus ? 22 : -1
			imagePos.push(["Graphics/Pictures/Battle/BattleButtonRework/icon_statuses",x,y,
				 statusXRect,statusID2*STATUS_ICON_HEIGHT,statusWidth,STATUS_ICON_HEIGHT])
		end
		# Refresh type bars
		types = @battler.pbTypes(true,true)
		iconHeight = @thinBox ? TYPE_ICON_THIN_HEIGHT : TYPE_ICON_HEIGHT
		iconsVisible = visible && @showTypes
		if types[0]
			@type1Icon.src_rect.y = GameData::Type.get(types[0]).id_number * iconHeight
			@type1Icon.visible = iconsVisible
		else
			@type1Icon.visible = false
		end
		if types[1]
			@type2Icon.src_rect.y = GameData::Type.get(types[1]).id_number * iconHeight
			@type2Icon.visible = iconsVisible
		else
			@type2Icon.visible = false
		end
		if types[2]
			@type3Icon.src_rect.y = GameData::Type.get(types[2]).id_number * iconHeight
			@type3Icon.visible = iconsVisible
		else
			@type3Icon.visible = false
		end
		pbDrawImagePositions(self.bitmap,imagePos)
		#self.update
		refreshHP
		refreshExp
	end
	
	def refreshHP
		@hpNumbers.bitmap.clear
		return if !@battler.pokemon
		# Show HP numbers
		if @showHP
		  pbDrawNumber(self.hp,@hpNumbers.bitmap,54,2,1)
		  pbDrawNumber(-1,@hpNumbers.bitmap,54,2)   # / char
		  pbDrawNumber(@battler.totalhp,@hpNumbers.bitmap,70,2)
		end
		
		numHPBars = 1
		if @bossGraphics
			numHPBars = isLegendary(@battler.species) ? 3 : 2
		end
		updateHealthBars(numHPBars)
	end
	
	def updateHealthBars(numHealthBars)	
		hpBars = [@hpBar,@hpBar2,@hpBar3]
		numHealthBars = numHealthBars.to_f
		hpBars.each_with_index do |bar,index|
			break if index==numHealthBars
			oneBarsShare = (@battler.totalhp / numHealthBars)
			w = 0
			if self.hp > oneBarsShare * index
			  w = @hpBarBitmap.width.to_f
			  if self.hp < oneBarsShare * (index + 1)
				w = @hpBarBitmap.width.to_f * (self.hp - index * oneBarsShare) / oneBarsShare
				w = 1 if w<1
			    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
			    #       fit in with the rest of the graphics which are doubled in size.
			    w = ((w/2.0).round)*2
			  end
			end
			bar.src_rect.width = w
			
			hpColor = 0                                  # Green bar
			hpColor = 1 if self.hp <= @battler.totalhp * (index * 4 + 2) / (4 * numHealthBars)
			hpColor = 2 if self.hp <= @battler.totalhp * (index * 4 + 1) / (4 * numHealthBars)
			bar.src_rect.y = hpColor*@hpBarBitmap.height/3
		end
	end
	  
  def initializeOtherGraphics(viewport)
    # Create other bitmaps
    @numbersBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/icon_numbers_white"))
    @hpBarBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_hp"))
    @expBarBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_exp"))
	typeIconFileName = @thinBox ? "Graphics/Pictures/Battle/icon_types_thin" : "Graphics/Pictures/Battle/icon_types"
	@typeBitmap    = AnimatedBitmap.new(_INTL(typeIconFileName))
    # Create sprite to draw HP numbers on
    @hpNumbers = BitmapSprite.new(124,16,viewport)
    pbSetSmallFont(@hpNumbers.bitmap)
    @sprites["hpNumbers"] = @hpNumbers
    # Create sprite wrapper that displays HP bar
    @hpBar = SpriteWrapper.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height/3
    @sprites["hpBar"] = @hpBar
	
	# Create sprite wrappers that displays the 2nd and 3rd HP bars for bosses
    @hpBar2 = SpriteWrapper.new(viewport)
    @hpBar2.bitmap = @hpBarBitmap.bitmap
    @hpBar2.src_rect.height = @hpBarBitmap.height/3
    @sprites["hpBar2"] = @hpBar2
	@hpBar3 = SpriteWrapper.new(viewport)
    @hpBar3.bitmap = @hpBarBitmap.bitmap
    @hpBar3.src_rect.height = @hpBarBitmap.height/3
    @sprites["hpBar3"] = @hpBar3
	
    # Create sprite wrapper that displays Exp bar
    @expBar = SpriteWrapper.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
	# Create type 1 icon
    @type1Icon = SpriteWrapper.new(viewport)
    @type1Icon.bitmap = @typeBitmap.bitmap
    @type1Icon.src_rect.height = @thinBox ? TYPE_ICON_THIN_HEIGHT : TYPE_ICON_HEIGHT
    @sprites["type1Icon"] = @type1Icon
    # Create type 2 icon
    @type2Icon = SpriteWrapper.new(viewport)
    @type2Icon.bitmap = @typeBitmap.bitmap
    @type2Icon.src_rect.height = @thinBox ? TYPE_ICON_THIN_HEIGHT : TYPE_ICON_HEIGHT
    @sprites["type2Icon"] = @type2Icon
    # Create type 3 icon
    @type3Icon = SpriteWrapper.new(viewport)
    @type3Icon.bitmap = @typeBitmap.bitmap
    @type3Icon.src_rect.height = @thinBox ? TYPE_ICON_THIN_HEIGHT : TYPE_ICON_HEIGHT
    @sprites["type3Icon"] = @type3Icon
    # Create sprite wrapper that displays everything except the above
    @contents = BitmapWrapper.new(@databoxBitmap.width,@databoxBitmap.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150+((@battler.index)/2)*5
    pbSetSystemFont(self.bitmap)
	
  end
  
  def disposeBitmaps()
	@databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @expBarBitmap.dispose
	@typeBitmap.dispose
    @contents.dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    disposeBitmaps
    super
  end
  
  def x=(value)
    super
    @hpBar.x     = value+@spriteBaseX+102
	@hpBar2.x    = value+@spriteBaseX+102
	@hpBar3.x    = value+@spriteBaseX+102
    @expBar.x    = value+@spriteBaseX+2
    @hpNumbers.x = value+@spriteBaseX+80
    if @thinBox
		@type1Icon.x = value+@spriteBaseX+244
		@type2Icon.x = value+@spriteBaseX+244
		@type3Icon.x = value+@spriteBaseX+244+34
	else
		@type1Icon.x = value+@spriteBaseX+4
		@type2Icon.x = value+@spriteBaseX+4+48
		@type3Icon.x = value+@spriteBaseX+4+48+48
	end
  end

  def y=(value)
    super
    @hpBar.y     = value+40
	@hpBar2.y     = value+52
	@hpBar3.y     = value+64
    @expBar.y    = value+74
    @hpNumbers.y = value+52
	iconDepth = 60
	if @bossGraphics
		iconDepth = @legendary ? 100 : 80
	end
	if @thinBox
		@type1Icon.y = value+12
		@type2Icon.y = value+32
		@type3Icon.y = value+22
	else
		@type1Icon.y = value+iconDepth
		@type2Icon.y = value+iconDepth
		@type3Icon.y = value+iconDepth
	end
  end

  def z=(value)
    super
    @hpBar.z     = value+1
	@hpBar2.z     = value+1
	@hpBar3.z     = value+1
    @expBar.z    = value+1
    @hpNumbers.z = value+2
    @type1Icon.z = value+0
    @type2Icon.z = value+0
    @type3Icon.z = value+0
  end
  
  def visible=(value)
    super
    for i in @sprites
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @showExp)
	
	types = @battler.pbTypes(true)
	
	@type1Icon.visible = false
	@type2Icon.visible = false
	@type3Icon.visible = false
	
	if value && @showTypes
		types = @battler.pbTypes(true)
		types = @battler.disguisedAs.types if @battler.illusion?
		@type1Icon.visible = types[0] != nil
		@type2Icon.visible = types[1] != nil && types[1] != types[0]
		@type3Icon.visible = types[2] != nil && types[2] != types[1] && types[2] != types[0]
	end
	
	@hpBar2.visible = value && @bossGraphics
	@hpBar3.visible = value && @bossGraphics && isLegendary(@battler.species)
  end
  
  def updateExpAnimation
    return if !@animatingExp
    if !@showExp   # Not showing the Exp bar, no need to waste time animating it
      @currentExp = @endExp
      @animatingExp = false
      return
    end
    if @currentExp<@endExp   # Gaining Exp
      @currentExp += @expIncPerFrame
      @currentExp = @endExp if @currentExp>=@endExp
    elsif @currentExp>@endExp   # Losing Exp
      @currentExp -= @expIncPerFrame
      @currentExp = @endExp if @currentExp<=@endExp
    end
    # Refresh the Exp bar
    refreshExp
    return if @currentExp!=@endExp   # Exp bar still has more to animate
    # Exp bar is completely filled, level up with a flash and sound effect
    if @currentExp>=@rangeExp
      if @expFlash==0
        pbSEStop
        @expFlash = Graphics.frame_rate/5
		if (@bossGraphics || !@battler.battle.wildBattle?)
			pbSEPlay("Pkmn exp full",nil,100)
		else
			pbSEPlay("Pkmn exp full",nil,85)
		end
        self.flash(Color.new(64,200,248,192),@expFlash)
        for i in @sprites
          i[1].flash(Color.new(64,200,248,192),@expFlash) if !i[1].disposed?
        end
      else
        @expFlash -= 1
        @animatingExp = false if @expFlash==0
      end
    else
      pbSEStop
      # Exp bar has finished filling, end animation
      @animatingExp = false
    end
  end
end
