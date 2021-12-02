class TargetMenuDisplay < BattleMenuBase
	attr_accessor :dexSelect
	
	def dexSelect=(value)
		dexSelect = value
		@dexReminder.visible = value
	end
	
	def initialize(viewport,z,sideSizes)
		super(viewport)
		@dexSelext = false
		@sideSizes = sideSizes
		maxIndex = (@sideSizes[0]>@sideSizes[1]) ? (@sideSizes[0]-1)*2 : @sideSizes[1]*2-1
		@smallButtons = (@sideSizes.max>2)
		self.x = 0
		self.y = Graphics.height-96
		@texts = []
		# NOTE: @mode is for which buttons are shown as selected.
		#       0=select 1 button (@index), 1=select all buttons with text
		# Create bitmaps
		@buttonBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/cursor_target"))
		@dexReminderBitmap 		= AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/BattleButtonRework/pokedex_reminder"))
		# Create target buttons
		@buttons = Array.new(maxIndex+1) do |i|
		  numButtons = @sideSizes[i%2]
		  next if numButtons<=i/2
		  # NOTE: Battler indexes go from left to right from the perspective of
		  #       that side's trainer, so inc is different for each side for the
		  #       same value of i/2.
		  inc = ((i%2)==0) ? i/2 : numButtons-1-i/2
		  button = SpriteWrapper.new(viewport)
		  button.bitmap = @buttonBitmap.bitmap
		  button.src_rect.width  = (@smallButtons) ? CMD_BUTTON_WIDTH_SMALL : @buttonBitmap.width/2
		  button.src_rect.height = BUTTON_HEIGHT
		  if @smallButtons
			button.x    = self.x+170-[0,82,166][numButtons-1]
		  else
			button.x    = self.x+138-[0,116][numButtons-1]
		  end
		  button.x      += (button.src_rect.width-4)*inc
		  button.y      = self.y+6
		  button.y      += (BUTTON_HEIGHT-4)*((i+1)%2)
		  addSprite("button_#{i}",button)
		  next button
		end
		# Create overlay (shows target names)
		@overlay = BitmapSprite.new(Graphics.width,Graphics.height-self.y,viewport)
		@overlay.x = self.x
		@overlay.y = self.y
		pbSetNarrowFont(@overlay.bitmap)
		addSprite("overlay",@overlay)
		
		# Create dex reminder
		@dexReminder = SpriteWrapper.new(viewport)
		@dexReminder.bitmap = @dexReminderBitmap.bitmap
		@dexReminder.x = self.x + 4
		@dexReminder.y = self.y - @dexReminderBitmap.height
		@dexReminder.visible = false
		addSprite("dexReminder",@dexReminder)
		
		self.z = z
		refresh
	end

	def dispose
		super
		@buttonBitmap.dispose if @buttonBitmap
		@dexReminderBitmap.dispose if @dexReminderBitmap
	end
end