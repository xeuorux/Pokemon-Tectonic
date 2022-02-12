class CommandMenuDisplay < BattleMenuBase
	attr_accessor   :battle

	MODES = [
		 [0,8,11,1,3,2],   # 0 = Wild Battle
		 [0,8,11,1,9,2],   # 1 = Battle with "Cancel" instead of "Run"
		 [0,8,11,1,4,2],   # 2 = Battle with "Call" instead of "Run"
		 [5,7,11,6,3,2],   # 3 = Safari Zone
		 [0,8,11,1,3,2],    # 4 = Bug Catching Contest
		 [0,8,11,1,10,2]  # 5 = Trainer Battle
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
      # Create action buttons
      @buttons = Array.new(6) do |i|   # 4 command options, therefore 4 buttons
        button = SpriteWrapper.new(viewport)
        button.bitmap = @buttonBitmap.bitmap
        button.x      = self.x+Graphics.width-490
        button.x      += (i%3) * (@buttonBitmap.width/2+4)
        button.y      = self.y+6
        button.y      += (((i/3)==0) ? 0 : BUTTON_HEIGHT-4)
		echoln("Button #{i}: #{button.x}, #{button.y}")
        button.src_rect.width  = @buttonBitmap.width/2
        button.src_rect.height = BUTTON_HEIGHT
        addSprite("button_#{i}",button)
        next button
      end
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
  end
  
  def refreshButtons
    return if !USE_GRAPHICS
    for i in 0...@buttons.length
      button = @buttons[i]
      button.src_rect.x = (i==@index) ? @buttonBitmap.width/2 : 0
      button.src_rect.y = MODES[@mode][i]*BUTTON_HEIGHT
      button.z          = self.z + ((i==@index) ? 3 : 2)
    end
  end
  
  def setTexts(value)
    @msgBox.text = value[0]
    return if USE_GRAPHICS
    commands = []
    for i in 1..6
      commands.push(value[i]) if value[i] && value[i]!=nil
    end
    @cmdWindow.commands = commands
  end
end