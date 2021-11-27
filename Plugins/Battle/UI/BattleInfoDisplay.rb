class BattleInfoDisplay < SpriteWrapper
	attr_accessor   :battle
	
  def initialize(viewport,z,battle)
	super(viewport)
    self.x = 0
    self.y = 0
	self.battle = battle
	
	@sprites      = {}
    @spriteX      = 0
    @spriteY      = 0
	@backgroundBitmap  = AnimatedBitmap.new("Graphics/Pictures/Battle/BattleButtonRework/battle_info")
	
	@contents = BitmapWrapper.new(@backgroundBitmap.width,@backgroundBitmap.height)
    self.bitmap  = @contents
	
	self.z = z
    refresh
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @backgroundBitmap.dispose
    super
  end
  
  def visible=(value)
    super
    for i in @sprites
      i[1].visible = value if !i[1].disposed?
    end
  end
  
  def refresh
    self.bitmap.clear
	# Draw background panel
    self.bitmap.blt(0,0,@backgroundBitmap.bitmap,Rect.new(0,0,@backgroundBitmap.width,@backgroundBitmap.height))
  end
  
  def update(frameCounter=0)
    super()
    pbUpdateSpriteHash(@sprites)
  end
end