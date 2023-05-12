#===============================================================================
# Shadow sprite for Pokémon (used in battle)
#===============================================================================
class PokemonBattlerShadowSprite < RPG::Sprite
    attr_reader   :pkmn
    attr_accessor :index
    attr_accessor :selected
  
    def initialize(viewport,sideSize,index)
      super(viewport)
      @pkmn        = nil
      @sideSize    = sideSize
      @index       = index
      @_iconBitmap = nil
      self.visible = false
    end
  
    def dispose
      @_iconBitmap.dispose if @_iconBitmap
      @_iconBitmap = nil
      self.bitmap = nil if !self.disposed?
      super
    end
  
    def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
    def height; return (self.bitmap) ? self.bitmap.height : 0; end
  
    # Set sprite's origin to centre
    def pbSetOrigin
      return if !@_iconBitmap
      self.ox = @_iconBitmap.width/2
      self.oy = @_iconBitmap.height/2
    end
  
    def pbSetPosition
      return if !@_iconBitmap
      pbSetOrigin
      self.z = 3
      # Set original position
      p = PokeBattle_SceneConstants.pbBattlerPosition(@index,@sideSize)
      self.x = p[0]
      self.y = p[1]
      # Apply metrics
      @pkmn.species_data.apply_metrics_to_sprite(self, @index, true)
    end
  
    def setPokemonBitmap(pkmn)
      @pkmn = pkmn
      @_iconBitmap.dispose if @_iconBitmap
      @_iconBitmap = GameData::Species.shadow_bitmap_from_pokemon(@pkmn)
      self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
      pbSetPosition
    end
  
    def update(frameCounter=0)
      return if !@_iconBitmap
      # Update bitmap
      @_iconBitmap.update
      self.bitmap = @_iconBitmap.bitmap
    end
end
  