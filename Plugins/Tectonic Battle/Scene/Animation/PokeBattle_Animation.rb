class PokeBattle_Animation
    def initialize(sprites,viewport)
      @sprites  = sprites
      @viewport = viewport
      @pictureEx      = []   # For all the PictureEx
      @pictureSprites = []   # For all the sprites
      @tempSprites    = []   # For sprites that exist only for this animation
      @animDone       = false
      createProcesses
    end
  
    def dispose
      @tempSprites.each { |s| s.dispose if s }
    end
  
    def createProcesses; end
    def empty?; return @pictureEx.length==0; end
    def animDone?; return @animDone; end
  
    def addSprite(s,origin=PictureOrigin::TopLeft)
      num = @pictureEx.length
      picture = PictureEx.new(s.z)
      picture.x       = s.x
      picture.y       = s.y
      picture.visible = s.visible
      picture.tone    = s.tone.clone
      picture.setOrigin(0,origin)
      @pictureEx[num] = picture
      @pictureSprites[num] = s
      return picture
    end
  
    def addNewSprite(x,y,name,origin=PictureOrigin::TopLeft)
      num = @pictureEx.length
      picture = PictureEx.new(num)
      picture.setXY(0,x,y)
      picture.setName(0,name)
      picture.setOrigin(0,origin)
      @pictureEx[num] = picture
      s = IconSprite.new(x,y,@viewport)
      s.setBitmap(name)
      @pictureSprites[num] = s
      @tempSprites.push(s)
      return picture
    end
  
    def update
      return if @animDone
      @tempSprites.each { |s| s.update if s }
      finished = true
      @pictureEx.each_with_index do |p,i|
        next if !p.running?
        finished = false
        p.update
        setPictureIconSprite(@pictureSprites[i],p)
      end
      @animDone = true if finished
    end
end