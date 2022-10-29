class PokemonDataBox < SpriteWrapper

	# Time in seconds to fully fill the Exp bar (from empty).
	EXP_BAR_FILL_TIME  = 0.5
	# Maximum time in seconds to make a change to the HP bar.
	HP_BAR_CHANGE_TIME = 0.5
	
	TYPE_ICON_HEIGHT = 18
	TYPE_ICON_THIN_HEIGHT = 20
	NAME_BASE_COLOR = Color.new(255,255,255)
	NAME_SHADOW_COLOR       = Color.new(136,136,136)

	attr_accessor :showTypes
	
	def initialize(battler,sideSize,viewport=nil,verticalShift = 0)
		super(viewport)
		@battler      = battler
		@sprites      = {}
		@spriteX      = 0
		@spriteY      = verticalShift
		@spriteBaseX  = 0
		@selected     = 0
		@frame        = 0
		@showHP       = false   # Specifically, show the HP numbers
		@animatingHP  = false
		@showExp      = false   # Specifically, show the Exp bar
		@animatingExp = false
		@expFlash     = 0
		@showTypes    = false
		@typeIcons	  = []
		@thinBox	  = false
		@hpBars		  = []
		@numHPBars = 1
		if @battler.boss
			@numHPBars = GameData::Avatar.get_from_pokemon(@battler.pokemon).num_health_bars
		end
		initializeDataBoxGraphic(sideSize)
		initializeOtherGraphics(viewport)
		refresh
	end
	
	def initializeDataBoxGraphic(sideSize)
		onPlayerSide = ((@battler.index%2)==0)
		
		# Determine the basic shape and size of the databox
		if sideSize == 1 || @numHPBars > 1
		  bgFilename = ["Graphics/Pictures/Battle/databox_normal",
						"Graphics/Pictures/Battle/databox_normal_foe"][@battler.index % 2]
		else
		  bgFilename = ["Graphics/Pictures/Battle/databox_thin",
						"Graphics/Pictures/Battle/databox_thin_foe"][@battler.index % 2]
		  @thinBox = true
		end

		# Only show HP numbers and EXP if its a player's pokemon and there's the room
		if onPlayerSide && sideSize == 1
			@showHP  = true
			@showExp = true
		end

		# Use multiple HP bars
		if !onPlayerSide && @numHPBars > 1
			bgFilename = "#{bgFilename}_#{@numHPBars}"
		end

		@databoxBitmap  = AnimatedBitmap.new(bgFilename)

		# Determine the co-ordinates of the data box and the left edge padding width
		if onPlayerSide
		  @spriteX = Graphics.width - 244
		  @spriteBaseX = 34
		else
		  @spriteX = -16
		  @spriteBaseX = 16
		  @showTypes = true
		end

		indexOnSide = @battler.index / 2
		if onPlayerSide
			case sideSize
			when 2
				@spriteX += [-12, 0][indexOnSide]
			when 3
				@spriteX += [-12, -6, 0][indexOnSide]
			end
		else
			case sideSize
			when 2
				@spriteX += [12, 0][indexOnSide]
			when 3
				@spriteX += [12, 6, 0][indexOnSide]
			end
		end
	end

	def getHeight
		return @databoxBitmap.height
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
			@hpIncPerFrame = 100
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
			pbSEPlay("Pkmn exp gain",nil,100)
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
		  shinyX = (@battler.opposes?(0)) ? 220 : -6   # Foe's/player's
		  shinyIconFileName = @battler.shiny_variant? ? "Graphics/Pictures/shiny_variant" : "Graphics/Pictures/shiny"
		  imagePos.push([shinyIconFileName,@spriteBaseX+shinyX,36])
		end

		# Draw held item icon
		if @battler.item && @battler.itemActive?
		  itemX = (@battler.opposes?(0)) ? 204 : -8   # Foe's/player's
		  itemY = 36
		  imagePos.push(["Graphics/Pictures/Party/icon_item",@spriteBaseX+itemX,itemY])
		end

		# Draw owned icon (foe Pokémon only)
		if @battler.owned? && @battler.opposes?(0) && !@battler.boss
		  imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+4,36])
		end

		# Draw status icon
		statusX = 20
		statusX -= 4 if @numHPBars > 2
		statusX -= 8 if @numHPBars > 3
		firstStatusY = 36 + (@numHPBars - 1) * 2
		statuses = @battler.getStatuses()
		statusID = GameData::Status.get(statuses[0]).id_number
		imagePos.push(["Graphics/Pictures/Battle/BattleButtonRework/icon_statuses",@spriteBaseX+statusX,firstStatusY,
			 0,statusID*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])

		# Draw status icon for bosses
		if statuses.length > 1
			statusID2 = GameData::Status.get(statuses[1]).id_number
			x = @spriteBaseX + statusX
			y = firstStatusY + STATUS_ICON_HEIGHT + 4
			imagePos.push(["Graphics/Pictures/Battle/BattleButtonRework/icon_statuses",x,y,
				 0,statusID2*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
		end

		refreshTypeIcons
		
		pbDrawImagePositions(self.bitmap,imagePos)

		refreshHP
		refreshExp
	end

	def refreshTypeIcons
		iconHeight = @thinBox ? TYPE_ICON_THIN_HEIGHT : TYPE_ICON_HEIGHT
		iconsVisible = visible && @showTypes

		@typeIcons.each_with_index do |icon, index|
			icon.visible = false
		end

		types = @battler.pbTypes(true,true)
		types.each_with_index do |type,index|
			icon = @typeIcons[index]
			if type.nil?
				icon.visible = false
			else
				icon.src_rect.y = GameData::Type.get(type).id_number * iconHeight
				icon.visible = iconsVisible
			end
		end
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
		
		updateHealthBars
	end
	
	def updateHealthBars
		healthBarTotal = @numHPBars.to_f
		@hpBars.each_with_index do |bar,index|
			oneBarsShare = (@battler.totalhp / healthBarTotal)
			w = 0
			if self.hp > oneBarsShare * index
			  w = @hpBarWidth
			  if self.hp < oneBarsShare * (index + 1)
				w = @hpBarWidth * (self.hp - index * oneBarsShare) / oneBarsShare
				w = 1 if w<1
			    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
			    #       fit in with the rest of the graphics which are doubled in size.
			    #w = ((w/2.0).round)*2
			  end
			end
			bar.src_rect.width = w
			
			hpColor = 0                                  # Green bar
			hpColor = 1 if self.hp <= @battler.totalhp * (index * 4 + 2) / (4 * healthBarTotal)
			hpColor = 2 if self.hp <= @battler.totalhp * (index * 4 + 1) / (4 * healthBarTotal)
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

    # Create sprite wrappers that displays HP bars
	@hpBarWidth = @hpBarBitmap.width.to_f
	@hpBarWidth = 72.0 if @battler.index % 2 && @thinBox && @numHPBars > 1

	hpBarNum = 0
	@numHPBars.times do
		newBar = SpriteWrapper.new(viewport)
		newBar.bitmap = @hpBarBitmap.bitmap
		newBar.src_rect.height = @hpBarBitmap.height/3
		newBar.src_rect.width = @hpBarWidth
		@sprites["hpBar_#{hpBarNum}"] = newBar
		@hpBars.push(newBar)
		hpBarNum += 1
	end
	
    # Create sprite wrapper that displays Exp bar
    @expBar = SpriteWrapper.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar

	# Create the type icons
	[1,2,3].each do |i|
		newIcon = SpriteWrapper.new(viewport)
		newIcon.bitmap = @typeBitmap.bitmap
		newIcon.src_rect.height = @thinBox ? TYPE_ICON_THIN_HEIGHT : TYPE_ICON_HEIGHT
		@sprites["type_icon_#{i}"] = newIcon
		@typeIcons.push(newIcon)
	end

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
	@hpBars.each_with_index do |bar,index|
		bar.x     = value + @spriteBaseX + 102
		if @thinBox
			bar.x += index * 76
		end
	end

    @expBar.x    = value+@spriteBaseX+2
    @hpNumbers.x = value+@spriteBaseX+80

	@typeIcons.each_with_index do |icon, index|
		icon.x = value + @spriteBaseX
		if @thinBox
			icon.x += 244
			icon.x += 48 if @numHPBars > 1
			icon.x += 34 * (index/2)
		else
			icon.x += 4
			icon.x += 48 * index
		end
	end
  end

  def y=(value)
    super

	finalBarY = 0
	@hpBars.each_with_index do |bar,index|
		bar.y     = value + 40
		if !@thinBox
			bar.y += index * 12
		end
		finalBarY = bar.y
	end

	@expBar.y    = finalBarY + 12

    @hpNumbers.y = value+52

	@typeIcons.each_with_index do |icon, index|
		icon.y = value
		if @thinBox
			icon.y += 8
			icon.y += (index % 20) * 20
		else
			icon.y += @databoxBitmap.height - TYPE_ICON_HEIGHT
		end
	end
  end

  def z=(value)
    super
	@hpBars.each_with_index do |bar,index|
		bar.z = value + 1
	end
    @expBar.z    = value+1
    @hpNumbers.z = value+2

	@typeIcons.each_with_index do |icon, index|
		icon.z = value
	end
  end
  
  def visible=(value)
    super
    for i in @sprites
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @showExp)
	
	refreshTypeIcons()
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
		pbSEPlay("Pkmn exp full",nil,100)
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
