#===============================================================================
# Target menu (choose a move's target)
# NOTE: Unlike the command and fight menus, this one doesn't have a textbox-only
#       version.
#===============================================================================
class TargetMenuDisplay < BattleMenuBase
    attr_accessor :mode
    attr_accessor :dexSelect
  
    # Lists of which button graphics to use in different situations/types of battle.
    MODES = [
       [0,2,1,3],   # 0 = Regular battle
       [0,2,1,9],   # 1 = Regular battle with "Cancel" instead of "Run"
       [0,2,1,4],   # 2 = Regular battle with "Call" instead of "Run"
       [5,7,6,3],   # 3 = Safari Zone
       [0,8,1,3]    # 4 = Bug Catching Contest
    ]
    CMD_BUTTON_WIDTH_SMALL = 170
    TEXT_BASE_COLOR   = Color.new(240,248,224)
    TEXT_SHADOW_COLOR = Color.new(64,64,64)
  
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
		@buttonBitmap = AnimatedBitmap.new(addLanguageSuffix(("Graphics/Pictures/Battle/cursor_target")))
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
		
		self.z = z
		refresh
	end
  
	def dispose
		super
		@buttonBitmap.dispose if @buttonBitmap
	end
  
    def z=(value)
      super
      @overlay.z += 5 if @overlay
    end
  
    def setDetails(texts,mode)
      @texts = texts
      @mode  = mode
      refresh
    end
  
    def refreshButtons
      # Choose appropriate button graphics and z positions
      @buttons.each_with_index do |button,i|
        next if !button
        sel = false
        buttonType = 0
        if @texts[i]
          sel ||= (@mode==0 && i==@index)
          sel ||= (@mode==1)
          buttonType = ((i%2)==0) ? 1 : 2
        end
        buttonType = 2*buttonType + ((@smallButtons) ? 1 : 0)
        button.src_rect.x = (sel) ? @buttonBitmap.width/2 : 0
        button.src_rect.y = buttonType*BUTTON_HEIGHT
        button.z          = self.z + ((sel) ? 3 : 2)
      end
      # Draw target names onto overlay
      @overlay.bitmap.clear
      textpos = []
      @buttons.each_with_index do |button,i|
        next if !button || nil_or_empty?(@texts[i])
        x = button.x-self.x+button.src_rect.width/2
        y = button.y-self.y+2
        textpos.push([@texts[i],x,y,2,TEXT_BASE_COLOR,TEXT_SHADOW_COLOR])
      end
      pbDrawTextPositions(@overlay.bitmap,textpos)
    end
  
    def refresh
      refreshButtons
    end
end