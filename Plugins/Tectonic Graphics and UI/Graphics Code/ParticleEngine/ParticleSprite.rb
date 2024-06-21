class ParticleSprite
    attr_accessor :x, :y, :z, :ox, :oy, :opacity, :blend_type, :state, :angle, :zoom_x, :zoom_y
    attr_reader :bitmap
    attr_reader :sprite
  
    def initialize(viewport)
      @viewport   = viewport
      @sprite     = nil
      @x          = 0
      @y          = 0
      @z          = 0
      @ox         = 0
      @oy         = 0
      @opacity    = 255
      @bitmap     = nil
      @blend_type = 0
      @minleft    = 0
      @mintop     = 0
      @state      = 0
      @angle      = 0
      @zoom_x     = 1.0
      @zoom_y     = 1.0
    end
  
    def dispose
      @sprite.dispose if @sprite
    end
  
    def bitmap=(value)
      @bitmap = value
      if value
        @minleft = -value.width
        @mintop  = -value.height
      else
        @minleft = 0
        @mintop  = 0
      end
    end
  
    def update
      w = Graphics.width + @bitmap.width
      h = Graphics.height + @bitmap.height
      if !@sprite && @x >= @minleft && @y >= @mintop && @x < w && @y < h
        @sprite = Sprite.new(@viewport)
      elsif @sprite && (@x < @minleft || @y < @mintop || @x >= w || @y >= h)
        @sprite.dispose
        @sprite = nil
      end
      if @sprite
        @sprite.x          = @x if @sprite.x != @x
        @sprite.ox         = @ox if @sprite.ox != @ox
        @sprite.y          = @y if @sprite.y != @y
        @sprite.oy         = @oy if @sprite.oy != @oy
        @sprite.z          = @z if @sprite.z != @z
        @sprite.zoom_x     = @zoom_x if @sprite.zoom_x != @zoom_x
        @sprite.zoom_y     = @zoom_y if @sprite.zoom_y != @zoom_y
        @sprite.angle      = @angle if @sprite.angle != @angle
        @sprite.opacity    = @opacity if @sprite.opacity != @opacity
        @sprite.blend_type = @blend_type if @sprite.blend_type != @blend_type
        @sprite.bitmap     = @bitmap if @sprite.bitmap != @bitmap
      end
    end
end