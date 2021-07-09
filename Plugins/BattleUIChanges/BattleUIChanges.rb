module Input
  BALL	   = B
end

class CommandMenuDisplay < BattleMenuBase
	attr_accessor   :battle

	MODES = [
		 [0,11,1,3],   # 0 = Wild Battle
		 [0,11,1,9],   # 1 = Battle with "Cancel" instead of "Run"
		 [0,11,1,4],   # 2 = Battle with "Call" instead of "Run"
		 [5,7,6,3],   # 3 = Safari Zone
		 [0,8,1,3],    # 4 = Bug Catching Contest
		 [0,11,1,10]  # 5 = Trainer Battle
	  ]
  def initialize(viewport,z,battle)
    super(viewport)
    self.x = 0
    self.y = Graphics.height-96
	self.battle = battle
    # Create message box (shows "What will X do?")
    @msgBox = Window_UnformattedTextPokemon.newWithSize("",
       self.x+16,self.y+2,220,Graphics.height-self.y,viewport)
    @msgBox.baseColor   = TEXT_BASE_COLOR
    @msgBox.shadowColor = TEXT_SHADOW_COLOR
    @msgBox.windowskin  = nil
    addSprite("msgBox",@msgBox)
    if USE_GRAPHICS
      # Create background graphic
      background = IconSprite.new(self.x,self.y,viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_command")
      addSprite("background",background)
      # Create bitmaps
      @buttonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/BattleButtonRework/cursor_command"))
	  @ballBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/BattleButtonRework/cursor_ball"))
	  @dexBitmap   	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/BattleButtonRework/cursor_pokedex"))
      # Create action buttons
      @buttons = Array.new(4) do |i|   # 4 command options, therefore 4 buttons
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+Graphics.width-260
        button.x      += (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
        button.y      = self.y+6
        button.y      += (((i/2)==0) ? 0 : BUTTON_HEIGHT-4)
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
      end
	  @ballButton = SpriteWrapper.new(viewport)
      @ballButton.bitmap = @ballBitmap.bitmap
      @ballButton.x = 300
      @ballButton.y = 0
      @ballButton.src_rect.width  = @ballBitmap.width
      @ballButton.src_rect.height  = @ballBitmap.height/2
      addSprite("ballButton",@ballButton)
      @ballButton.visible = false
	  
	  # Create Dex button
      @dexButton = SpriteWrapper.new(viewport)
      @dexButton.bitmap = @dexBitmap.bitmap
      @dexButton.x      = self.x+4
      @dexButton.y      = self.y-@dexBitmap.height
      addSprite("dexButton",@dexButton)
    else
      # Create command window (shows Fight/Bag/Pokémon/Run)
      @cmdWindow = Window_CommandPokemon.newWithSize([],
         self.x+Graphics.width-240,self.y,240,Graphics.height-self.y,viewport)
      @cmdWindow.columns       = 2
      @cmdWindow.columnSpacing = 4
      @cmdWindow.ignore_input  = true
      addSprite("cmdWindow",@cmdWindow)
    end
    self.z = z
    refresh
  end
  
  def dispose
    super
    @buttonBitmap.dispose if @buttonBitmap
    @ballBitmap.dispose if @ballBitmap
	@dexBitmap.dispose if @dexBitmap
  end
  
  def refreshButtons
    return if !USE_GRAPHICS
    for i in 0...@buttons.length
      button = @buttons[i]
      button.src_rect.x = (i==@index) ? @buttonBitmap.width/2 : 0
      button.src_rect.y = MODES[@mode][i]*BUTTON_HEIGHT
      button.z          = self.z + ((i==@index) ? 3 : 2)
    end
	# Refresh the ball button
	if $PokemonBag.pockets()[3].any?{|itemrecord| itemrecord[1] > 0}
      @ballButton.src_rect.y = 0
    else
      @ballButton.src_rect.y = 46
    end
	# Refresh the dex button
    @dexButton.z             = self.z - 1
  end
  
  def visible=(value)
    super
    @ballButton.visible = false
    @ballButton.visible = true if value && @battle.wildBattle? && !$game_switches[95]
  end
end

class PokeBattle_Scene
	def pbInitSprites
		@sprites = {}
		# The background image and each side's base graphic
		pbCreateBackdropSprites
		# Create message box graphic
		messageBox = pbAddSprite("messageBox",0,Graphics.height-96,
		   "Graphics/Pictures/Battle/overlay_message",@viewport)
		messageBox.z = 195
		# Create message window (displays the message)
		msgWindow = Window_AdvancedTextPokemon.newWithSize("",
		   16,Graphics.height-96+2,Graphics.width-32,96,@viewport)
		msgWindow.z              = 200
		msgWindow.opacity        = 0
		msgWindow.baseColor      = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
		msgWindow.shadowColor    = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR
		msgWindow.letterbyletter = true
		@sprites["messageWindow"] = msgWindow
		# Create command window
		@sprites["commandWindow"] = CommandMenuDisplay.new(@viewport,200,@battle)
		# Create fight window
		@sprites["fightWindow"] = FightMenuDisplay.new(@viewport,200)
		# Create targeting window
		@sprites["targetWindow"] = TargetMenuDisplay.new(@viewport,200,@battle.sideSizes)
		pbShowWindow(MESSAGE_BOX)
		# The party lineup graphics (bar and balls) for both sides
		for side in 0...2
		  partyBar = pbAddSprite("partyBar_#{side}",0,0,
			 "Graphics/Pictures/Battle/overlay_lineup",@viewport)
		  partyBar.z       = 120
		  partyBar.mirror  = true if side==0   # Player's lineup bar only
		  partyBar.visible = false
		  for i in 0...PokeBattle_SceneConstants::NUM_BALLS
			ball = pbAddSprite("partyBall_#{side}_#{i}",0,0,nil,@viewport)
			ball.z       = 121
			ball.visible = false
		  end
		  # Ability splash bars
		  if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
			@sprites["abilityBar_#{side}"] = AbilitySplashBar.new(side,@viewport)
		  end
		end
		# Player's and partner trainer's back sprite
		@battle.player.each_with_index do |p,i|
		  pbCreateTrainerBackSprite(i,p.trainer_type,@battle.player.length)
		end
		# Opposing trainer(s) sprites
		if @battle.trainerBattle?
		  @battle.opponent.each_with_index do |p,i|
			pbCreateTrainerFrontSprite(i,p.trainer_type,@battle.opponent.length)
		  end
		end
		# Data boxes and Pokémon sprites
		@battle.battlers.each_with_index do |b,i|
		  next if !b
		  @sprites["dataBox_#{i}"] = PokemonDataBox.new(b,@battle.pbSideSize(i),@viewport)
		  pbCreatePokemonSprite(i)
		end
		# Wild battle, so set up the Pokémon sprite(s) accordingly
		if @battle.wildBattle?
		  @battle.pbParty(1).each_with_index do |pkmn,i|
			index = i*2+1
			pbChangePokemon(index,pkmn)
			pkmnSprite = @sprites["pokemon_#{index}"]
			pkmnSprite.tone    = Tone.new(-80,-80,-80)
			pkmnSprite.visible = true
		  end
		end
    end
	
	def pbChangePokemon(idxBattler,pkmn)
		idxBattler = idxBattler.index if idxBattler.respond_to?("index")
		pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
		shadowSprite = @sprites["shadow_#{idxBattler}"]
		back = !@battle.opposes?(idxBattler)
		pkmnSprite.setPokemonBitmap(pkmn,back)
		shadowSprite.setPokemonBitmap(pkmn)
		# Set visibility of battler's shadow
		shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
		shadowSprite.visible = false if pkmn.boss
	  end

  #=============================================================================
  # The player chooses a main command for a Pokémon
  # Return values: -1=Cancel, 0=Fight, 1=Bag, 2=Pokémon, 3=Run, 4=Call
  #=============================================================================
  def pbCommandMenu(idxBattler,firstAction)
    shadowTrainer = (GameData::Type.exists?(:SHADOW) && @battle.trainerBattle?)
    cmds = [
       _INTL("What will\n{1} do?",@battle.battlers[idxBattler].name),
       _INTL("Fight"),
       _INTL("Bag"),
       _INTL("Pokémon"),
       (shadowTrainer) ? _INTL("Call") : (firstAction) ? _INTL("Run") : _INTL("Cancel")
    ]
    wildBattle = !@battle.trainerBattle? && !$game_switches[95]
    mode = 0
    if shadowTrainer
      mode = 2
    elsif firstAction
      if !wildBattle
        mode = 5
      else
        mode = 0
      end
    else
      mode = 1
    end
    ret = pbCommandMenuEx(idxBattler,cmds,mode,wildBattle)
    ret = 4 if ret==3 && shadowTrainer   # Convert "Run" to "Call"
    ret = -1 if ret==3 && !firstAction   # Convert "Run" to "Cancel"
    ret = 5 if ret==1 # Convert "Bag" to "Info"
    ret = 1 if ret==6
    return ret
  end
  
  # Mode: 0 = regular battle with "Run" (first choosable action in the round only)
  #       1 = regular battle with "Cancel"
  #       2 = regular battle with "Call" (for Shadow Pokémon battles)
  #       3 = Safari Zone
  #       4 = Bug Catching Contest
  #       5 = regular battle with "Forfeit" and "Info"
  def pbCommandMenuEx(idxBattler,texts,mode=0,wildbattle = false)
    pbShowWindow(COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler],mode)
    pbSelectBattler(idxBattler)
    hasPokeballs = $PokemonBag.pockets()[3].any?{|itemrecord| itemrecord[1] > 0}
    ret = -1
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index&1)==0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index&2)==0
      end
      pbPlayCursorSE if cw.index!=oldIndex
      
      # Actions
      if Input.trigger?(Input::C)                 # Confirm choice
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      elsif Input.trigger?(Input::B) && mode==1   # Cancel
        pbPlayCancelSE
        break
      elsif Input.trigger?(Input::F9) && $DEBUG    # Debug menu
        pbPlayDecisionSE
        ret = -2
        break
      elsif Input.trigger?(Input::SPECIAL) && wildbattle && hasPokeballs   # Throw Ball
        pbPlayDecisionSE
        ret = 6
        break
	  elsif Input.trigger?(Input::ACTION) # Open Pokedex
		pbPlayDecisionSE
        ret = 7
		break
      end
    end
    return ret
  end
  
  #=============================================================================
  # The player chooses a move for a Pokémon to use
  #=============================================================================
  def pbFightMenu(idxBattler,megaEvoPossible=false)
    battler = @battle.battlers[idxBattler]
    cw = @sprites["fightWindow"]
    cw.battler = battler
    moveIndex = 0
    if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
      moveIndex = @lastMove[idxBattler]
    end
    cw.shiftMode = 0
    cw.setIndexAndMode(moveIndex,(megaEvoPossible) ? 1 : 0)
    needFullRefresh = true
    needRefresh = false
    loop do
      # Refresh view if necessary
      if needFullRefresh
        pbShowWindow(FIGHT_BOX)
        pbSelectBattler(idxBattler)
        needFullRefresh = false
      end
      if needRefresh
        if megaEvoPossible
          newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
          cw.mode = newMode if newMode!=cw.mode
        end
        needRefresh = false
      end
      oldIndex = cw.index
      # General update
      pbUpdate(cw)
      # Update selected command
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index&1)==1
      elsif Input.trigger?(Input::RIGHT)
        if battler.moves[cw.index+1] && battler.moves[cw.index+1].id
          cw.index += 1 if (cw.index&1)==0
        end
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index&2)==2
      elsif Input.trigger?(Input::DOWN)
        if battler.moves[cw.index+2] && battler.moves[cw.index+2].id
          cw.index += 2 if (cw.index&2)==0
        end
      end
      pbPlayCursorSE if cw.index!=oldIndex
      # Actions
      if Input.trigger?(Input::USE)      # Confirm choice
        pbPlayDecisionSE
        break if yield cw.index
        needFullRefresh = true
        needRefresh = true
      elsif Input.trigger?(Input::BACK)   # Cancel fight menu
        pbPlayCancelSE
        break if yield -1
        needRefresh = true
      elsif Input.trigger?(Input::ACTION)   # Toggle Extra Move Info
        pbPlayDecisionSE
		cw.toggleExtraInfo()
        needRefresh = true
      end
    end
    @lastMove[idxBattler] = cw.index
  end
end

class PokemonDataBox < SpriteWrapper

	# Time in seconds to fully fill the Exp bar (from empty).
	EXP_BAR_FILL_TIME  = 0.5
	# Maximum time in seconds to make a change to the HP bar.
	HP_BAR_CHANGE_TIME = 0.5
	
	TYPE_ICON_HEIGHT = 28
	
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
		@boss = @battler.boss && sideSize == 1
		initializeDataBoxGraphic(sideSize)
		initializeOtherGraphics(viewport)
		refresh
	  end
	
	  def initializeDataBoxGraphic(sideSize)
		onPlayerSide = ((@battler.index%2)==0)
		# Get the data box graphic and set whether the HP numbers/Exp bar are shown
		if sideSize==1   # One Pokémon on side, use the regular dara box BG
		  bgFilename = ["Graphics/Pictures/Battle/databox_normal",
						"Graphics/Pictures/Battle/databox_normal_foe"][@battler.index%2]
		  bgFilename += "_boss" if @boss
		  if onPlayerSide
			@showHP  = true
			@showExp = true
		  else
			@showTypes = true
		  end
		else   # Multiple Pokémon on side, use the thin dara box BG
		  bgFilename = ["Graphics/Pictures/Battle/databox_thin",
						"Graphics/Pictures/Battle/databox_thin_foe"][@battler.index%2]
		end
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
		when 2
		  @spriteX += [-12,  12,  0,  0][@battler.index]
		  @spriteY += [-20, -34, 34, 20][@battler.index]
		when 3
		  @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
		  @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
		end
	  end
	  
	def animateHP(oldHP,newHP,rangeHP)
		@currentHP   = oldHP
		@endHP       = newHP
		@rangeHP     = rangeHP
		# NOTE: A change in HP takes the same amount of time to animate, no matter
		#       how big a change it is.
		changeTime = @boss ? HP_BAR_CHANGE_TIME : HP_BAR_CHANGE_TIME * 1
		@hpIncPerFrame = (newHP-oldHP).abs/(HP_BAR_CHANGE_TIME*Graphics.frame_rate)
		# minInc is the smallest amount that HP is allowed to change per frame.
		# This avoids a tiny change in HP still taking HP_BAR_CHANGE_TIME seconds.
		minInc = (rangeHP*4)/(@hpBarBitmap.width*changeTime*Graphics.frame_rate)
		@hpIncPerFrame = minInc if @hpIncPerFrame<minInc
		@animatingHP   = true
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
		textPos.push([@battler.name,@spriteBaseX+8-nameOffset,0,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
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
		  shinyX = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
		  imagePos.push(["Graphics/Pictures/shiny",@spriteBaseX+shinyX,36])
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
		if @battler.owned? && @battler.opposes?(0)
		  imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
		end
		# Draw status icon
		if @battler.status != :NONE
		  s = GameData::Status.get(@battler.status).id_number
		  if @battler.status == :POISON && @battler.statusCount > 0   # Badly poisoned
			s = 6
		  end
		  imagePos.push(["Graphics/Pictures/Battle/BattleButtonRework/icon_statuses",@spriteBaseX+24,36,
			 0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
		end
		# Refresh type bars
		types = @battler.pbTypes(true)

		if types[0]
		  @type1Icon.src_rect.y = GameData::Type.get(types[0]).id_number*TYPE_ICON_HEIGHT
		end
		
		if types[1]
		  @type2Icon.src_rect.y = GameData::Type.get(types[1]).id_number*TYPE_ICON_HEIGHT
		end
		
		if types[2]
		  @type3Icon.src_rect.y = GameData::Type.get(types[2]).id_number*TYPE_ICON_HEIGHT
		end
		
		pbDrawImagePositions(self.bitmap,imagePos)
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
		
		if !@boss
			# Resize HP bar
			w = 0
			if self.hp>0
			  w = @hpBarBitmap.width.to_f*self.hp/@battler.totalhp
			  w = 1 if w<1
			  # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
			  #       fit in with the rest of the graphics which are doubled in size.
			  w = ((w/2.0).round)*2
			end
			@hpBar.src_rect.width = w
			hpColor = 0                                  # Green bar
			hpColor = 1 if self.hp<=@battler.totalhp/2   # Yellow bar
			hpColor = 2 if self.hp<=@battler.totalhp/4   # Red bar
			@hpBar.src_rect.y = hpColor*@hpBarBitmap.height/3
		else
			# Resize HP bar 1
			w = 0
			if self.hp>0
			  w = @hpBarBitmap.width.to_f
			  if self.hp < @battler.totalhp / 3.0
				w = @hpBarBitmap.width.to_f*self.hp/(@battler.totalhp / 3.0)
				w = 1 if w<1
			    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
			    #       fit in with the rest of the graphics which are doubled in size.
			    w = ((w/2.0).round)*2
			  end
			end
			@hpBar.src_rect.width = w
			
			hpColor = 0                                  # Green bar
			hpColor = 1 if self.hp<=@battler.totalhp/6.0   # Yellow bar
			hpColor = 2 if self.hp<=@battler.totalhp/12.0   # Red bar
			@hpBar.src_rect.y = hpColor*@hpBarBitmap.height/3
			
			# Resize HP bar 2
			w2 = 0
			if self.hp > (@battler.totalhp / 3.0)
			  w2 = @hpBarBitmap.width.to_f
			  if self.hp < (2.0 * @battler.totalhp / 3.0)
				w2 = @hpBarBitmap.width.to_f * (self.hp - (@battler.totalhp / 3.0)) / (@battler.totalhp / 3.0)
				w2 = 1 if w2<1
			    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
			    #       fit in with the rest of the graphics which are doubled in size.
			    w2 = ((w2/2.0).round)*2
			  end
			end
			@hpBar2.src_rect.width = w2
			
			hpColor = 0                                  # Green bar
			hpColor = 1 if self.hp<=@battler.totalhp/2.0   # Yellow bar
			hpColor = 2 if self.hp<=@battler.totalhp * 5.0/12.0   # Red bar
			@hpBar2.src_rect.y = hpColor*@hpBarBitmap.height/3
			
			# Resize HP bar 3
			w3 = 0
			if self.hp > (2.0 * @battler.totalhp / 3.0)
			  w3 = @hpBarBitmap.width.to_f
			  if self.hp < @battler.totalhp
				w3 = @hpBarBitmap.width.to_f * (self.hp - (2.0 * @battler.totalhp / 3.0)) / (@battler.totalhp / 3.0)
				w3 = 1 if w3<1
			    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
			    #       fit in with the rest of the graphics which are doubled in size.
			    w3 = ((w3/2.0).round)*2
			  end
			end
			@hpBar3.src_rect.width = w3
			
			hpColor = 0                                  # Green bar
			hpColor = 1 if self.hp<=@battler.totalhp * 10.0/12.0   # Yellow bar
			hpColor = 2 if self.hp<=@battler.totalhp * 3.0/4.0   # Red bar
			@hpBar3.src_rect.y = hpColor*@hpBarBitmap.height/3
		end
	end
	  
  def initializeOtherGraphics(viewport)
    # Create other bitmaps
    @numbersBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/icon_numbers"))
    @hpBarBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_hp"))
    @expBarBitmap  = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_exp"))
	@typeBitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
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
    @type1Icon.src_rect.height = TYPE_ICON_HEIGHT
    @sprites["type1Icon"] = @type1Icon
    # Create type 2 icon
    @type2Icon = SpriteWrapper.new(viewport)
    @type2Icon.bitmap = @typeBitmap.bitmap
    @type2Icon.src_rect.height = TYPE_ICON_HEIGHT
    @sprites["type2Icon"] = @type2Icon
    # Create type 3 icon
    @type3Icon = SpriteWrapper.new(viewport)
    @type3Icon.bitmap = @typeBitmap.bitmap
    @type3Icon.src_rect.height = TYPE_ICON_HEIGHT
    @sprites["type3Icon"] = @type3Icon
    # Create sprite wrapper that displays everything except the above
    @contents = BitmapWrapper.new(@databoxBitmap.width,@databoxBitmap.height)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150+((@battler.index)/2)*5
    pbSetSystemFont(self.bitmap)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @expBarBitmap.dispose
	@typeBitmap.dispose
    @contents.dispose
    super
  end
  
  def x=(value)
    super
    @hpBar.x     = value+@spriteBaseX+102
	@hpBar2.x    = value+@spriteBaseX+102
	@hpBar3.x    = value+@spriteBaseX+102
    @expBar.x    = value+@spriteBaseX+6
    @hpNumbers.x = value+@spriteBaseX+80
    @type1Icon.x = value+@spriteBaseX+10
    @type2Icon.x = value+@spriteBaseX+80
    @type3Icon.x = value+@spriteBaseX+150
  end

  def y=(value)
    super
    @hpBar.y     = value+40
	@hpBar2.y     = value+60
	@hpBar3.y     = value+80
    @expBar.y    = value+74
    @hpNumbers.y = value+52
    @type1Icon.y = value-30
    @type2Icon.y = value-30
    @type3Icon.y = value-30
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
	
	@type1Icon.visible = (value && @showTypes && !!types[0])
    @type2Icon.visible = (value && @showTypes && !!types[1] && types[1] != types[0])
    @type3Icon.visible = (value && @showTypes && !!types[2] && types[2] != types[0] && types[2] != types[1])
	
	@hpBar2.visible = value && @boss
	@hpBar3.visible = value && @boss
  end
end

# Create the targeting category used for the Info button
GameData::Target.register({
  :id               => :UserOrOther,
  :id_number        => 500,
  :name             => _INTL("User Or Other"),
  :targets_foe      => true,
  :long_range       => true,
  :num_targets      => 1
})

class PokeBattle_Battle
	  #=============================================================================
  # Learning a move
  #=============================================================================
  def pbLearnMove(idxParty,newMove)
    pkmn = pbParty(0)[idxParty]
    return if !pkmn
    pkmnName = pkmn.name
    battler = pbFindBattler(idxParty)
    moveName = GameData::Move.get(newMove).name
    # Pokémon already knows the move
    return if pkmn.moves.any? { |m| m && m.id == newMove }
    # Pokémon has space for the new move; just learn it
    if pkmn.moves.length < Pokemon::MAX_MOVES
      pkmn.moves.push(Pokemon::Move.new(newMove))
      pbDisplay(_INTL("{1} learned {2}!",pkmnName,moveName)) { pbSEPlay("Pkmn move learnt") }
      if battler
        battler.moves.push(PokeBattle_Move.from_pokemon_move(self, pkmn.moves.last))
        battler.pbCheckFormOnMovesetChange
      end
      return
    end
    # Pokémon already knows the maximum number of moves; try to forget one to learn the new move
    loop do
        pbDisplayPaused(_INTL("{1} wants to learn {2}, but it already knows {3} moves.",
        pkmnName, moveName, pkmn.moves.length.to_word))
        pbDisplayPaused(_INTL("Which move should be forgotten?"))
        forgetMove = @scene.pbForgetMove(pkmn,newMove)
        if forgetMove>=0
          oldMoveName = pkmn.moves[forgetMove].name
          pkmn.moves[forgetMove] = Pokemon::Move.new(newMove)   # Replaces current/total PP
          battler.moves[forgetMove] = PokeBattle_Move.from_pokemon_move(self, pkmn.moves[forgetMove]) if battler
          pbDisplayPaused(_INTL("1, 2, and... ... ... Ta-da!"))
          pbDisplayPaused(_INTL("{1} forgot how to use {2}. And...",pkmnName,oldMoveName))
          pbDisplay(_INTL("{1} learned {2}!",pkmnName,moveName)) { pbSEPlay("Pkmn move learnt") }
          battler.pbCheckFormOnMovesetChange if battler
          break
        elsif pbDisplayConfirm(_INTL("Give up on learning {1}?",moveName))
          pbDisplay(_INTL("{1} did not learn {2}.",pkmnName,moveName))
          break
        end
    end
  end


	def pbGoAfterInfo(battler)
		idxTarget = @scene.pbChooseTarget(battler.index,GameData::Target.get(:UserOrOther))
		return if idxTarget<0
		species = @battlers[idxTarget].species
		$Trainer.pokedex.register_last_seen(@battlers[idxTarget].pokemon)
		scene = PokemonPokedexInfo_Scene.new
		screen = PokemonPokedexInfoScreen.new(scene)
		screen.pbStartSceneSingle(species,true)
    end

	def pbCommandPhaseLoop(isPlayer)
    # NOTE: Doing some things (e.g. running, throwing a Poké Ball) takes up all
    #       your actions in a round.
    actioned = []
    idxBattler = -1
    loop do
      break if @decision!=0   # Battle ended, stop choosing actions
      idxBattler += 1
      break if idxBattler>=@battlers.length
      next if !@battlers[idxBattler] || pbOwnedByPlayer?(idxBattler)!=isPlayer
      next if @choices[idxBattler][0]!=:None    # Action is forced, can't choose one
      next if !pbCanShowCommands?(idxBattler)   # Action is forced, can't choose one
      # AI controls this battler
      if @controlPlayer || !pbOwnedByPlayer?(idxBattler)
        @battleAI.pbDefaultChooseEnemyCommand(idxBattler)
        next
      end
      # Player chooses an action
      actioned.push(idxBattler)
      commandsEnd = false   # Whether to cancel choosing all other actions this round
      loop do
        cmd = pbCommandMenu(idxBattler,actioned.length==1)
        # If being Sky Dropped, can't do anything except use a move
        if cmd>0 && @battlers[idxBattler].effects[PBEffects::SkyDrop]>=0
          pbDisplay(_INTL("Sky Drop won't let {1} go!",@battlers[idxBattler].pbThis(true)))
          next
        end
        case cmd
        when 0    # Fight
          break if pbFightMenu(idxBattler)
        when 1    # Bag
          if pbItemMenu(idxBattler,actioned.length==1)
            commandsEnd = true if pbItemUsesAllActions?(@choices[idxBattler][1])
            break
          end
        when 2    # Pokémon
          break if pbPartyMenu(idxBattler)
        when 3    # Run
          # NOTE: "Run" is only an available option for the first battler the
          #       player chooses an action for in a round. Attempting to run
          #       from battle prevents you from choosing any other actions in
          #       that round.
          if pbRunMenu(idxBattler)
            commandsEnd = true
            break
          end
        when 4    # Call
          break if pbCallMenu(idxBattler)
		when 5	  # Info
			pbGoAfterInfo(@battlers[idxBattler])
		when 7 # Pokedex
			pbFadeOutIn {
					scene = PokemonPokedex_Scene.new
					screen = PokemonPokedexScreen.new(scene)
					screen.pbStartScreen
				}
        when -2   # Debug
          pbDebugMenu
          next
        when -1   # Go back to previous battler's action choice
          next if actioned.length<=1
          actioned.pop   # Forget this battler was done
          idxBattler = actioned.last-1
          pbCancelChoice(idxBattler+1)   # Clear the previous battler's choice
          actioned.pop   # Forget the previous battler was done
          break
        end
        pbCancelChoice(idxBattler)
      end
      break if commandsEnd
    end
  end
end

class PokeBattle_Scene
  # Returns the initial position of the cursor when choosing a target for a move
  # in a non-single battle.
  def pbFirstTarget(idxBattler,target_data)
    case target_data.id
    when :NearAlly
      @battle.eachSameSideBattler(idxBattler) do |b|
        next if b.index==idxBattler || !@battle.nearBattlers?(b,idxBattler)
        next if b.fainted?
        return b.index
      end
      @battle.eachSameSideBattler(idxBattler) do |b|
        next if b.index==idxBattler || !@battle.nearBattlers?(b,idxBattler)
        return b.index
      end
    when :NearFoe, :NearOther
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.each { |i| return i if @battle.nearBattlers?(i,idxBattler) && !@battle.battlers[i].fainted? }
      indices.each { |i| return i if @battle.nearBattlers?(i,idxBattler) }
    when :Foe, :Other, :UserOrOther
      indices = @battle.pbGetOpposingIndicesInOrder(idxBattler)
      indices.each { |i| return i if !@battle.battlers[i].fainted? }
      indices.each { |i| return i }
    end
    return idxBattler   # Target the user initially
  end
end

#===============================================================================
# Fight menu (choose a move)
#===============================================================================
class FightMenuDisplay < BattleMenuBase
  attr_reader :extraInfoToggled

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
      @buttonBitmap  			= AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_fight"))
      @typeBitmap    			= AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
      @megaEvoBitmap 			= AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_mega"))
      @shiftBitmap   			= AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_shift"))
	  @moveInfoDisplayBitmap   	= AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/BattleButtonRework/move_info_display"))
      # Create background graphic
      background = IconSprite.new(0,Graphics.height-96,viewport)
      background.setBitmap("Graphics/Pictures/Battle/overlay_fight")
      addSprite("background",background)
      # Create move buttons
      @buttons = Array.new(Pokemon::MAX_MOVES) do |i|
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+4
        button.x      += (((i%2)==0) ? 0 : @buttonBitmap.width/2-4)
        button.y      = self.y+6
        button.y      += (((i/2)==0) ? 0 : BUTTON_HEIGHT-4)
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
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
      # Create type icon
      @typeIcon = SpriteWrapper.new(viewport)
      @typeIcon.bitmap = @typeBitmap.bitmap
      @typeIcon.x      = self.x+416
      @typeIcon.y      = self.y+20
      @typeIcon.src_rect.height = TYPE_ICON_HEIGHT
      addSprite("typeIcon",@typeIcon)
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
	  # Create the move extra info display
	  @moveInfoDisplay = SpriteWrapper.new(viewport)
      @moveInfoDisplay.bitmap = @moveInfoDisplayBitmap.bitmap
      @moveInfoDisplay.x      = self.x
      @moveInfoDisplay.y      = self.y-@moveInfoDisplayBitmap.height
      addSprite("moveInfoDisplay",@moveInfoDisplay)
	  # Create overlay for selected move's extra info (shows move's BP, description)
      @extraInfoOverlay = BitmapSprite.new(@moveInfoDisplayBitmap.bitmap.width,@moveInfoDisplayBitmap.height,viewport)
      @extraInfoOverlay.x = self.x
      @extraInfoOverlay.y = self.y-@moveInfoDisplayBitmap.height
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
	@moveInfoDisplayBitmap.dispose if @moveInfoDisplayBitmap
  end
  
  def visible=(value)
    super(value)
	@sprites["moveInfoDisplay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
	@sprites["extraInfoOverlay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
  end
  
  def toggleExtraInfo
	@extraInfoToggled = !@extraInfoToggled
	
	@sprites["moveInfoDisplay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
	@sprites["extraInfoOverlay"].visible = @extraInfoToggled && @visible if @sprites["moveInfoDisplay"]
  end

  def refreshMoveData(move)
    # Write PP and type of the selected move
    if !USE_GRAPHICS
      moveType = GameData::Type.get(move.type).name
      if move.total_pp<=0
        @msgBox.text = _INTL("PP: ---<br>TYPE/{1}",moveType)
      else
        @msgBox.text = _ISPRINTF("PP: {1: 2d}/{2: 2d}<br>TYPE/{3:s}",
           move.pp,move.total_pp,moveType)
      end
      return
    end
    @infoOverlay.bitmap.clear
    if !move
      @visibility["typeIcon"] = false
      return
    end
    @visibility["typeIcon"] = true
    # Type icon
    type_number = GameData::Type.get(move.type).id_number
    @typeIcon.src_rect.y = type_number * TYPE_ICON_HEIGHT
    # PP text
    if move.total_pp>0
      ppFraction = [(4.0*move.pp/move.total_pp).ceil,3].min
      textPosPP = []
      textPosPP.push([_INTL("PP: {1}/{2}",move.pp,move.total_pp),
         448,44,2,PP_COLORS[ppFraction*2],PP_COLORS[ppFraction*2+1]])
      pbDrawTextPositions(@infoOverlay.bitmap,textPosPP)
    end
	
	# Extra move info display
	@extraInfoOverlay.bitmap.clear
	overlay = @extraInfoOverlay.bitmap
	selected_move = GameData::Move.get(move.id)
	
	# Write power and accuracy values for selected move
	# Write various bits of text
	base   = Color.new(248,248,248)
    shadow = Color.new(104,104,104)
    textpos = [
       [_INTL("CATEGORY"),20,0,0,base,shadow],
       [_INTL("POWER"),20,32,0,base,shadow],
       [_INTL("ACCURACY"),20,64,0,base,shadow]
    ]
	
	base = Color.new(64,64,64)
	shadow = Color.new(176,176,176)
    case selected_move.base_damage
    when 0 then textpos.push(["---", 220, 32, 1, base, shadow])   # Status move
    when 1 then textpos.push(["???", 220, 32, 1, base, shadow])   # Variable power move
    else        textpos.push([selected_move.base_damage.to_s, 220, 32, 1, base, shadow])
    end
    if selected_move.accuracy == 0
      textpos.push(["---", 220, 64, 1, base, shadow])
    else
      textpos.push(["#{selected_move.accuracy}%", 220 + overlay.text_size("%").width, 64, 1, base, shadow])
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw selected move's damage category icon
    imagepos = [["Graphics/Pictures/category", 170, 8, 0, selected_move.category * 28, 64, 28]]
    pbDrawImagePositions(overlay, imagepos)
	# Draw selected move's description
	drawTextEx(overlay,8,108,210,5,selected_move.description,base,shadow)
  end
end