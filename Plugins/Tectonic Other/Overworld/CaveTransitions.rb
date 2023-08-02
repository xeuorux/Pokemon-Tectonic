#===============================================================================
# Entering/exiting cave animations
#===============================================================================
def pbCaveEntranceEx(exiting)
    # Create bitmap
    sprite = BitmapSprite.new(Graphics.width,Graphics.height)
    sprite.z = 100000
    # Define values used for the animation
    totalFrames = (Graphics.frame_rate*0.4).floor
    increment = (255.0/totalFrames).ceil
    totalBands = 15
    bandheight = ((Graphics.height/2.0)-10)/totalBands
    bandwidth  = ((Graphics.width/2.0)-12)/totalBands
    # Create initial array of band colors (black if exiting, white if entering)
    grays = Array.new(totalBands) { |i| (exiting) ? 0 : 255 }
    # Animate bands changing color
    totalFrames.times do |j|
      x = 0
      y = 0
      # Calculate color of each band
      for k in 0...totalBands
        next if k>=totalBands*j/totalFrames
        inc = increment
        inc *= -1 if exiting
        grays[k] -= inc
        grays[k] = 0 if grays[k]<0
      end
      # Draw gray rectangles
      rectwidth  = Graphics.width
      rectheight = Graphics.height
      for i in 0...totalBands
        currentGray = grays[i]
        sprite.bitmap.fill_rect(Rect.new(x,y,rectwidth,rectheight),
           Color.new(currentGray,currentGray,currentGray))
        x += bandwidth
        y += bandheight
        rectwidth  -= bandwidth*2
        rectheight -= bandheight*2
      end
      Graphics.update
      Input.update
    end
    # Set the tone at end of band animation
    if exiting
      pbToneChangeAll(Tone.new(255,255,255),0)
    else
      pbToneChangeAll(Tone.new(-255,-255,-255),0)
    end
    # Animate fade to white (if exiting) or black (if entering)
    for j in 0...totalFrames
      if exiting
        sprite.color = Color.new(255,255,255,j*increment)
      else
        sprite.color = Color.new(0,0,0,j*increment)
      end
      Graphics.update
      Input.update
    end
    # Set the tone at end of fading animation
    pbToneChangeAll(Tone.new(0,0,0),8)
    # Pause briefly
    (Graphics.frame_rate/10).times do
      Graphics.update
      Input.update
    end
    sprite.dispose
  end
  
  def pbCaveEntrance
    pbSetEscapePoint
    pbCaveEntranceEx(false)
  end
  
  def pbCaveExit
    pbEraseEscapePoint
    pbCaveEntranceEx(true)
  end
  