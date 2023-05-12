#===============================================================================
# Pokémon sprite (used in battle)
#===============================================================================
class PokemonBattlerSprite < RPG::Sprite
    attr_reader   :pkmn
    attr_accessor :index
    attr_accessor :selected
    attr_reader   :sideSize
  
    def initialize(viewport,sideSize,index,battleAnimations)
      super(viewport)
      @pkmn             = nil
      @sideSize         = sideSize
      @index            = index
      @battleAnimations = battleAnimations
      # @selected: 0 = not selected, 1 = choosing action bobbing for this Pokémon,
      #            2 = flashing when targeted
      @selected         = 0
      @frame            = 0
      @updating         = false
      @spriteX          = 0   # Actual x coordinate
      @spriteY          = 0   # Actual y coordinate
      @spriteXExtra     = 0   # Offset due to "bobbing" animation
      @spriteYExtra     = 0   # Offset due to "bobbing" animation
      @_iconBitmap      = nil
      self.visible      = false
    end
  
    def dispose
      @_iconBitmap.dispose if @_iconBitmap
      @_iconBitmap = nil
      self.bitmap = nil if !self.disposed?
      super
    end
  
    def x; return @spriteX; end
    def y; return @spriteY; end
  
    def x=(value)
      @spriteX = value
      super(value+@spriteXExtra)
    end
  
    def y=(value)
      @spriteY = value
      super(value+@spriteYExtra)
    end
  
    def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
    def height; return (self.bitmap) ? self.bitmap.height : 0; end
  
    def visible=(value)
      @spriteVisible = value if !@updating   # For selection/targeting flashing
      super
    end
  
    # Set sprite's origin to bottom middle
    def pbSetOrigin
      return if !@_iconBitmap
      self.ox = @_iconBitmap.width/2
      self.oy = @_iconBitmap.height
    end
  
    def pbSetPosition
        return if !@_iconBitmap
        pbSetOrigin
        if (@index%2)==0
        self.z = 50+5*@index/2
        else
        self.z = 50-5*(@index+1)/2
        end
        # Set original position
        p = PokeBattle_SceneConstants.pbBattlerPosition(@index,@sideSize,@pkmn.boss?)
        @spriteX = p[0]
        @spriteY = p[1]
        # Apply metrics
        @pkmn.species_data.apply_metrics_to_sprite(self, @index)
    end
  
    def setPokemonBitmap(pkmn,back=false)
      @pkmn = pkmn
      @_iconBitmap.dispose if @_iconBitmap
      @_iconBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pkmn, back)
      self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
      pbSetPosition
    end
  
    # This method plays the battle entrance animation of a Pokémon. By default
    # this is just playing the Pokémon's cry, but you can expand on it. The
    # recommendation is to create a PictureEx animation and push it into
    # the @battleAnimations array.
    def pbPlayIntroAnimation(pictureEx=nil)
      @pkmn.play_cry if @pkmn
    end
  
    QUARTER_ANIM_PERIOD = Graphics.frame_rate*3/20
    SIXTH_ANIM_PERIOD   = Graphics.frame_rate*2/20
  
    def update(frameCounter=0)
      return if !@_iconBitmap
      @updating = true
      # Update bitmap
      @_iconBitmap.update
      self.bitmap = @_iconBitmap.bitmap
      # Pokémon sprite bobbing while Pokémon is selected
      @spriteYExtra = 0
      if @selected==1    # When choosing commands for this Pokémon
        case (frameCounter/QUARTER_ANIM_PERIOD).floor
        when 1 then @spriteYExtra = 2
        when 3 then @spriteYExtra = -2
        end
      end
      self.x       = self.x
      self.y       = self.y
      self.visible = @spriteVisible
      # Pokémon sprite blinking when targeted
      if @selected==2 && @spriteVisible
        case (frameCounter/SIXTH_ANIM_PERIOD).floor
        when 2, 5 then self.visible = false
        else           self.visible = true
        end
      end
      @updating = false
    end
end