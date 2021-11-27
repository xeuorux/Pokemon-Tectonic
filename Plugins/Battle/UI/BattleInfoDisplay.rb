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
	pbSetNarrowFont(self.bitmap)
	
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
	
	base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
	textToDraw = []
	
	textToDraw.push([_INTL("Your Side"),24,10,0,base,shadow])
	index = 0
	@battle.eachSameSideBattler do |b|
		next if !b
		textToDraw.push([b.name,24,40+32 * index,0,base,shadow])
		index += 1
	end
	index = 4
	textToDraw.push([_INTL("Their Side"),24,40+32 * index,0,base,shadow])
	index += 1
	@battle.eachOtherSideBattler do |b|
		next if !b
		textToDraw.push([b.name,24,40+32 * index,0,base,shadow])
		index += 1
	end
	
	textToDraw.push([_INTL("Weather: {1}",@battle.field.weather),24,310,0,base,shadow])
	textToDraw.push([_INTL("Terrain: {1}",@battle.field.terrain),224,310,0,base,shadow])
	pbDrawTextPositions(self.bitmap,textToDraw)
  end
  
  def update(frameCounter=0)
    super()
    pbUpdateSpriteHash(@sprites)
  end
end