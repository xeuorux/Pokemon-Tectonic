class ItemIconSprite < SpriteWrapper
	def item=(value)
		return if @item==value && !@forceitemchange
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
			pbDrawTextPositions(self.bitmap,[[$PokemonGlobal.teamHealerCurrentUses.to_s,28,14,0,base,shadow,true]])
		  end
		  if self.bitmap.height==ANIM_ICON_SIZE
			@numframes = [(self.bitmap.width/ANIM_ICON_SIZE).floor,1].max
			self.src_rect = Rect.new(0,0,ANIM_ICON_SIZE,ANIM_ICON_SIZE)
		  else
			@numframes = 1
			self.src_rect = Rect.new(0,0,self.bitmap.width,self.bitmap.height)
		  end
		  @animframe = 0
		  @frame = 0
		else
		  self.bitmap = nil
		end
		changeOrigin
	end
end