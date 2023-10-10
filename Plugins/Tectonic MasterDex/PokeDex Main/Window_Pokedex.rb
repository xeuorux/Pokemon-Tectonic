#===============================================================================
#
#===============================================================================
class Window_Pokedex < Window_DrawableCommand
  def initialize(x,y,width,height,viewport)
        @commands = []
        super(x,y,width,height,viewport)
        @selarrow     = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_list")
        @pokeballOwn  = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_own")
        @pokeballSeen = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_seen")
        @star         = AnimatedBitmap.new("Graphics/Pictures/Pokedex/star")
        self.baseColor   = Color.new(88,88,80)
        self.shadowColor = Color.new(168,184,184)
        self.windowskin  = nil
    end

  def commands=(value)
    @commands = value
    refresh
  end

  def dispose
        @selarrow.dispose
        @pokeballOwn.dispose
        @pokeballSeen.dispose
        @star.dispose
        super
    end

  def species
    return (@commands.length==0) ? 0 : @commands[self.index][0]
  end

  def itemCount
    return @commands.length
  end

  def drawItem(index,_count,rect)
		return if index>=self.top_row+self.page_item_max
		rect = Rect.new(rect.x+16,rect.y,rect.width-16,rect.height)
		species     = @commands[index][0]
		indexNumber = @commands[index][4]
		indexNumber -= 1 if @commands[index][5]
        showSpecies = !isLegendary(species) || $Trainer.seen?(species) || $DEBUG
		if showSpecies
		  if $Trainer.owned?(species)
			pbCopyBitmap(self.contents,@pokeballOwn.bitmap,rect.x-6,rect.y+8)
		  else
			pbCopyBitmap(self.contents,@pokeballSeen.bitmap,rect.x-6,rect.y+8)
		  end
		  text = sprintf("%03d%s %s",indexNumber," ",@commands[index][1])
		else
		  text = sprintf("%03d  ----------",indexNumber)
		end
    pbDrawShadowText(self.contents,rect.x+36,rect.y+6,rect.width,rect.height,
    text,self.baseColor,self.shadowColor)
    if showSpecies && $PokemonGlobal.speciesStarred?(species)
        pbCopyBitmap(self.contents,@star.bitmap,rect.x+200,rect.y+12)
    end
	end

  def refresh
    @item_max = itemCount
    dwidth  = self.width-self.borderX
    dheight = self.height-self.borderY
    self.contents = pbDoEnsureBitmap(self.contents,dwidth,dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i<self.top_item || i>self.top_item+self.page_item_max
      drawItem(i,@item_max,itemRect(i))
    end
    drawCursor(self.index,itemRect(self.index))
  end

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end