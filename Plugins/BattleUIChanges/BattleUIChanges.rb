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
      @ballButton.x = 350
      @ballButton.y = 0
      @ballButton.src_rect.width  = @ballBitmap.width
      @ballButton.src_rect.height  = @ballBitmap.height/2
      addSprite("ballButton",@ballButton)
      @ballButton.visible = false
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
  end
  
  def refreshButtons
    return if !USE_GRAPHICS
    for i in 0...@buttons.length
      button = @buttons[i]
      button.src_rect.x = (i==@index) ? @buttonBitmap.width/2 : 0
      button.src_rect.y = MODES[@mode][i]*BUTTON_HEIGHT
      button.z          = self.z + ((i==@index) ? 3 : 2)
    end
	if $PokemonBag.pockets()[3].any?{|itemrecord| itemrecord[1] > 0}
      @ballButton.src_rect.y = 0
    else
      @ballButton.src_rect.y = 46
    end
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
      end
    end
    return ret
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
		elsif @battler.item != 0 && @battler.itemActive?(true)
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
		  if s == :POISON && @battler.statusCount > 0   # Badly poisoned
			s = GameData::Status::DATA.keys.length / 2
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
    @expBar.x    = value+@spriteBaseX+6
    @hpNumbers.x = value+@spriteBaseX+80
    @type1Icon.x = value+@spriteBaseX+10
    @type2Icon.x = value+@spriteBaseX+80
    @type3Icon.x = value+@spriteBaseX+150
  end

  def y=(value)
    super
    @hpBar.y     = value+40
    @expBar.y    = value+74
    @hpNumbers.y = value+52
    @type1Icon.y = value-30
    @type2Icon.y = value-30
    @type3Icon.y = value-30
  end

  def z=(value)
    super
    @hpBar.z     = value+1
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
    @type2Icon.visible = (value && @showTypes && !!types[1])
    @type3Icon.visible = (value && @showTypes && !!types[2])
  end
end

GameData::Target.register({
  :id               => :UserOrOther,
  :id_number        => 500,
  :name             => _INTL("User Or Other"),
  :targets_foe      => true,
  :long_range       => true,
  :num_targets      => 1
})

class PokeBattle_Battle
	def pbGoAfterInfo(battler)
		idxTarget = @scene.pbChooseTarget(battler.index,GameData::Target.get(:UserOrOther))
		return if idxTarget<0
		species = @battlers[idxTarget].species
		$Trainer.pokedex.register_last_seen(@battlers[idxTarget].pokemon)
		scene = PokemonPokedexInfo_Scene.new
		screen = PokemonPokedexInfoScreen.new(scene)
		screen.pbStartSceneSingle(species)
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