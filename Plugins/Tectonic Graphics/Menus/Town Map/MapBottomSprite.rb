class MapBottomSprite < SpriteWrapper
    attr_reader :mapname
    attr_reader :maplocation
    attr_reader :waypointName
  
    def initialize(viewport=nil)
      super(viewport)
      @mapname     = ""
      @maplocation = ""
      @mapdetails  = ""
      @waypointName = ""
      @thisbitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
      pbSetSystemFont(@thisbitmap)
      self.x = 0
      self.y = 0
      self.bitmap = @thisbitmap
      refresh
    end

    def dispose
        @thisbitmap.dispose
        super
      end
    
      def mapname=(value)
        if @mapname!=value
          @mapname = value
          refresh
        end
      end
    
      def maplocation=(value)
        if @maplocation!=value
          @maplocation = value
          refresh
        end
      end
    
      def mapdetails=(value)  # From Wichu
        if @mapdetails!=value
          @mapdetails = value
          refresh
        end
      end
  
    def waypointName=(value)
      if @waypointName != value
        @waypointName = value
        refresh
      end
    end
  
    def refresh
      self.bitmap.clear
      textpos = [
         [@mapname,18,-8,0,Color.new(248,248,248),Color.new(0,0,0)],
         [@waypointName,Graphics.width-16,-8,1,Color.new(224,197,110),Color.new(0,0,0)],
         [@maplocation,18,348,0,Color.new(248,248,248),Color.new(0,0,0)],
         [@mapdetails,Graphics.width-16,348,1,Color.new(248,248,248),Color.new(0,0,0)]
      ]
      pbDrawTextPositions(self.bitmap,textpos)
    end
  end