module Transitions
    class RisingSplash
      def update
        return if disposed?
        if @duration==0
          dispose
        else
          angadd = (@numframes-@duration)*@angmult
          amp = 6*angadd/8; amp = 6 if amp>6
          for i in 0...@bgsprites.length
            @bgsprites[i].x = amp*Math.sin((i+angadd)*Math::PI/10)
          end
          @bubblesprite.x = (@width-@bubblebitmap.width)/2
          @bubblesprite.x -= 32*Math.sin((@numframes-@duration)/(@numframes/50.0)*3*Math::PI/60)
          @bubblesprite.y -= @bubblesuby
          if @duration<@numframes*0.5
            @splashsprite.y -= @splashsuby
          end
          if @duration<@numframes*0.1
            @blacksprite.y -= @blacksuby
            @blacksprite.y = 0 if @blacksprite.y<0
          end
        end
        @duration -= 1
      end
    end
  end