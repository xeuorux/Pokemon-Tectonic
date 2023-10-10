# pbFadeOutIn(z) { block }
# Fades out the screen before a block is run and fades it back in after the
# block exits.  z indicates the z-coordinate of the viewport used for this effect
def pbFadeOutIn(z=99999,nofadeout=false)
  col=Color.new(0,0,0,0)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=z
  numFrames = (Graphics.frame_rate*0.25).floor
  alphaDiff = (255.0/numFrames).ceil
  for j in 0..numFrames
    col.set(0,0,0,j*alphaDiff)
    viewport.color=col
    Graphics.update
    Input.update
  end
  pbPushFade
  begin
    yield if block_given?
  ensure
    pbPopFade
    if !nofadeout
      for j in 0..numFrames
        col.set(0,0,0,(numFrames-j)*alphaDiff)
        viewport.color=col
        Graphics.update
        Input.update
      end
    end
    viewport.dispose
  end
end