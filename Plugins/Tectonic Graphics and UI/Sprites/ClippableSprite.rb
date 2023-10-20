class ClippableSprite < Sprite_Character
    def initialize(viewport,event,tilemap)
      @tilemap = tilemap
      @_src_rect = Rect.new(0,0,0,0)
      super(viewport,event)
    end
  
    def update
      super
      @_src_rect = self.src_rect
      tmright = @tilemap.map_data.xsize*Game_Map::TILE_WIDTH-@tilemap.ox
      echoln("x=#{self.x},ox=#{self.ox},tmright=#{tmright},tmox=#{@tilemap.ox}")
      if @tilemap.ox-self.ox<-self.x
        # clipped on left
        diff = -self.x-@tilemap.ox+self.ox
        self.src_rect = Rect.new(@_src_rect.x+diff,@_src_rect.y,
                                 @_src_rect.width-diff,@_src_rect.height)
        echoln("clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
      elsif tmright-self.ox<self.x
        # clipped on right
        diff = self.x-tmright+self.ox
        self.src_rect = Rect.new(@_src_rect.x,@_src_rect.y,
                                 @_src_rect.width-diff,@_src_rect.height)
        echoln("clipped out right: #{diff} #{tmright+self.ox} #{self.x}")
      else
        echoln("-not- clipped out left: #{diff} #{@tilemap.ox-self.ox} #{self.x}")
      end
    end
  end