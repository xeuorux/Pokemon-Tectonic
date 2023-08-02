#===============================================================================
# Visibility circle in dark maps
#===============================================================================
class DarknessSprite < SpriteWrapper
    attr_reader :radius
  
    def initialize(viewport=nil)
      super(viewport)
      @darkness = BitmapWrapper.new(Graphics.width,Graphics.height)
      @radius = radiusMin
      self.bitmap = @darkness
      self.z      = 99998
      refresh
    end
  
    def dispose
      @darkness.dispose
      super
    end
  
    def radiusMin; return 64;  end   # Before using Flash
    def radiusMax; return 176; end   # After using Flash
  
    def radius=(value)
      @radius = value
      refresh
    end
  
    def refresh
      @darkness.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,255))
      cx = Graphics.width/2
      cy = Graphics.height/2
      cradius = @radius
      numfades = 5
      for i in 1..numfades
        for j in cx-cradius..cx+cradius
          diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
          diff = Math.sqrt(diff2)
          @darkness.fill_rect(j,cy-diff,1,diff*2,Color.new(0,0,0,255.0*(numfades-i)/numfades))
        end
        cradius = (cradius*0.9).floor
      end
    end
  end