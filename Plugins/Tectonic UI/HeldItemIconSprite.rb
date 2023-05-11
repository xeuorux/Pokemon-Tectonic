#===============================================================================
# Item held icon (used in the party screen)
#===============================================================================
class HeldItemIconSprite < SpriteWrapper
    def initialize(x,y,item,viewport=nil)
      super(viewport)
      self.x = x
      self.y = y
      @item = nil
      self.item = item
    end
  
    def dispose
      @animbitmap.dispose if @animbitmap
      super
    end
  
    def item=(value)
      return if @item==value
      @item = value
      @animbitmap.dispose if @animbitmap
      @animbitmap = nil
      if @item
        @animbitmap = AnimatedBitmap.new(GameData::Item.held_icon_filename(@item))
        self.bitmap = @animbitmap.bitmap
      else
        self.bitmap = nil
      end
    end
  
    def update
      super
      if @animbitmap
        @animbitmap.update
        self.bitmap = @animbitmap.bitmap
      end
    end
  end