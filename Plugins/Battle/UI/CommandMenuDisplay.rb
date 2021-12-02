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
	  @extraReminderBitmap 		= AnimatedBitmap.new(_INTL("Graphics/Pictures/Rework/extra_info_reminder_bottomless"))
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
	  # Create ball button
	  @ballButton = SpriteWrapper.new(viewport)
      @ballButton.bitmap = @ballBitmap.bitmap
      @ballButton.x = 284
      @ballButton.y = 0
      @ballButton.src_rect.width  = @ballBitmap.width
      @ballButton.src_rect.height  = @ballBitmap.height/2
      addSprite("ballButton",@ballButton)
      @ballButton.visible = false
	  
	  # Create extra info reminder
	  @extraReminder = SpriteWrapper.new(viewport)
	  @extraReminder.bitmap = @extraReminderBitmap.bitmap
	  @extraReminder.x = self.x+4
	  @extraReminder.y = self.y + 6 - @extraReminderBitmap.height
	  addSprite("extraReminder",@extraReminder)
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
	@extraReminderBitmap.dispose if @extraReminderBitmap
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
  end
  
  def visible=(value)
    super
    @ballButton.visible = false
    @ballButton.visible = true if value && @battle.wildBattle? && @battle.pbOpposingBattlerCount == 1 && !@battle.bossBattle?
  end
end