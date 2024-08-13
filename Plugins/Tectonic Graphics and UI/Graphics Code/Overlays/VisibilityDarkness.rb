#===============================================================================
# Visibility circle in dark maps
#===============================================================================
class DarknessSprite < SpriteWrapper
    attr_reader :radius
  
    def initialize(viewport: nil, color: Color.new(0,0,0,255),numFades: 5, radius: radiusMin, innerRadius: 0, diminishmentMult: 0.9, opacityMult: 1.0)
      super(viewport)
      @darkness = BitmapWrapper.new(Graphics.width,Graphics.height)
      @innerRadius = innerRadius
      @radius = radius
      @color = color
      @opacityMult = opacityMult
      @numFades = numFades
      @diminishmentMult = diminishmentMult
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

    def opacityMult=(value)
        @opacityMult = value
        refresh
    end
  
    def refresh
        @darkness.fill_rect(0,0,Graphics.width,Graphics.height,@color)
        centerX = Graphics.width/2
        centerY = Graphics.height/2
        cradius = @radius + @innerRadius
        for layerIndex in 1..@numFades
            for currentX in centerX-cradius..centerX+cradius
                diff2 = (cradius ** 2) - ((currentX - centerX) ** 2)
                diff = Math.sqrt(diff2)
                newAlpha = @color.alpha*@opacityMult*(@numFades - layerIndex)/@numFades
                newColor = Color.new(@color.red,@color.green,@color.blue,newAlpha)
                @darkness.fill_rect(currentX,centerY-diff,1,diff*2,newColor)
            end
            cradius = (cradius*@diminishmentMult).floor
        end
        if @innerRadius > 0
            # Erase the center
            for currentX in centerX-@innerRadius..centerX+@innerRadius
                diff2 = (@innerRadius ** 2) - ((currentX - centerX) ** 2)
                diff = Math.sqrt(diff2)
                newColor = Color.new(0,0,0,0)
                @darkness.fill_rect(currentX,centerY-diff,1,diff*2,newColor)
            end
        end
    end
end