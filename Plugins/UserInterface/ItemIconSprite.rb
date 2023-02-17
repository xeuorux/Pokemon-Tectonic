class ItemIconSprite < SpriteWrapper
	def item=(value)
		return if @item==value && !@forceitemchange && !%i[TAROTAMULET AIDKIT].include?(value)
		@item = value
		@animbitmap.dispose if @animbitmap
		@animbitmap = nil
		if @item || !@blankzero
		  @animbitmap = AnimatedBitmap.new(GameData::Item.icon_filename(@item))
		  self.bitmap = @animbitmap.bitmap
		  pbSetSystemFont(self.bitmap)
		  if item == :AIDKIT
			base = Color.new(235,235,235)
			shadow = Color.new(50,50,50)
			pbDrawTextPositions(self.bitmap,[[$PokemonGlobal.teamHealerCurrentUses.to_s,36,14,1,base,shadow,true]])
		  end
		  establishNewBitmap
		else
		  self.bitmap = nil
		end
		changeOrigin
	end

	def establishNewBitmap
		if self.bitmap.height==ANIM_ICON_SIZE
			@numframes = [(self.bitmap.width/ANIM_ICON_SIZE).floor,1].max
			self.src_rect = Rect.new(0,0,ANIM_ICON_SIZE,ANIM_ICON_SIZE)
		else
		@numframes = 1
		self.src_rect = Rect.new(0,0,self.bitmap.width,self.bitmap.height)
		end
		@animframe = 0
		@frame = 0
	end

	# For Prismatic Plate / Memory Set
	def type=(value)
		return if @item.nil?
		return unless %i[PRISMATICPLATE MEMORYSET].include?(GameData::Item.get(@item).id)

		# Dispose current graphic
		@animbitmap.dispose if @animbitmap
		@animbitmap = nil
		self.bitmap = nil

		# Find the proper pseudo bitmap
		pretendItem = nil
		typeID = GameData::Type.get(value).id_number

		if @item == :PRISMATICPLATE
			pretendItem = PLATES_BY_TYPE_ID[typeID]
		elsif @item == :MEMORYSET
			pretendItem = MEMORIES_BY_TYPE_ID[typeID]
		end

		if pretendItem.nil?
			echoln("ERROR: Unable to find a proper pseudo item file for an item icon showing a #{@item}")
			return
		end
		@animbitmap = AnimatedBitmap.new(GameData::Item.icon_filename(pretendItem))
		self.bitmap = @animbitmap.bitmap
		establishNewBitmap
		changeOrigin
	end
end

MEMORIES_BY_TYPE_ID = {
	1  => :FIGHTINGMEMORY,
	2  => :FLYINGMEMORY,
	3  => :POISONMEMORY,
	4  => :GROUNDMEMORY,
	5  => :ROCKMEMORY,
	6  => :BUGMEMORY,
	7  => :GHOSTMEMORY,
	8  => :STEELMEMORY,
	10 => :FIREMEMORY,
	11 => :WATERMEMORY,
	12 => :GRASSMEMORY,
	13 => :ELECTRICMEMORY,
	14 => :PSYCHICMEMORY,
	15 => :ICEMEMORY,
	16 => :DRAGONMEMORY,
	17 => :DARKMEMORY,
	18 => :FAIRYMEMORY,
 }

PLATES_BY_TYPE_ID = {
	1  => :FISTPLATE,
	2  => :SKYPLATE,
	3  => :TOXICPLATE,
	4  => :EARTHPLATE,
	5  => :STONEPLATE,
	6  => :INSECTPLATE,
	7  => :SPOOKYPLATE,
	8  => :IRONPLATE,
	10 => :FLAMEPLATE,
	11 => :SPLASHPLATE,
	12 => :MEADOWPLATE,
	13 => :ZAPPLATE,
	14 => :MINDPLATE,
	15 => :ICICLEPLATE,
	16 => :DRACOPLATE,
	17 => :DREADPLATE,
	18 => :PIXIEPLATE,
}