class AnimatedSprite
    # Shorter version of AnimationSprite.  All frames are placed on a single row
    # of the bitmap, so that the width and height need not be defined beforehand
    def initializeShort(animname,framecount,frameskip)
      @animname=pbBitmapName(animname)
      @realframes=0
      @frameskip = frameskip * Graphics.frame_rate/20
      @frameskip= 1 if @frameskip < 1
      begin
        @animbitmap=AnimatedBitmap.new(animname).deanimate
      rescue
        @animbitmap=Bitmap.new(framecount*4,32)
      end
      if @animbitmap.width%framecount!=0
        raise _INTL("Bitmap's width ({1}) is not a multiple of frame count ({2}) [Bitmap={3}]",
           @animbitmap.width,framewidth,animname)
      end
      @framecount=framecount
      @framewidth=@animbitmap.width/@framecount
      @frameheight=@animbitmap.height
      @framesperrow=framecount
      @playing=false
      self.bitmap=@animbitmap
      self.src_rect.width=@framewidth
      self.src_rect.height=@frameheight
      self.frame=0
    end
end