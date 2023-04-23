class TurnCountReminder < SpriteWrapper
	NAME_BASE_COLOR 		= Color.new(230,230,230)
	NAME_SHADOW_COLOR       = Color.new(136,136,136)

	def initialize(turnCount,viewport=nil)
		super(viewport)
		@turnCountReminderBitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/turns_counter")
		@reminderSprite = SpriteWrapper.new(viewport)
		@reminderSprite.bitmap = @turnCountReminderBitmap.bitmap
		@turnCountOverlay = BitmapSprite.new(@turnCountReminderBitmap.width,@turnCountReminderBitmap.height,viewport)
		pbSetSystemFont(@turnCountOverlay.bitmap)
		@turnCount = turnCount
		refresh
	end
	
	def visible=(value)
		super
		@reminderSprite.visible = value
		@turnCountOverlay.visible = value
	end

	def opacity=(value)
		super
		@reminderSprite.opacity = value
		@turnCountOverlay.opacity = value
	end

	def color=(value)
		super
		@reminderSprite.color = value
		@turnCountOverlay.color = value
	end

	def x=(value)
		super
		@reminderSprite.x = value
		@turnCountOverlay.x = value
	end

	def y=(value)
		super
		@reminderSprite.y = value
		@turnCountOverlay.y = value
	end

	def z=(value)
		super
		@reminderSprite.z = value
		@turnCountOverlay.z = value + 1
	end

	def dispose
		@reminderSprite.dispose
		@turnCountReminderBitmap.dispose
		@turnCountOverlay.dispose
		super
	end

	def turnCount=(value)
		@turnCount = value
		refresh
	end

	def refresh
		@turnCountOverlay.bitmap.clear
		turnCountLabel = _INTL("Turns Left: #{@turnCount}")
		x = @turnCountOverlay.bitmap.width / 2
		pbDrawTextPositions(@turnCountOverlay.bitmap,[[turnCountLabel,x,-2,2,NAME_BASE_COLOR,NAME_SHADOW_COLOR]])
	end
end