#===============================================================================
# Pokémon icons
#===============================================================================
class PokemonBoxIcon < IconSprite
    attr_reader :pokemon

    def initialize(pokemon, viewport = nil)
        super(0, 0, viewport)
        @pokemon = pokemon
        @release = Interpolator.new
        @startRelease = false
        @faded = false
        refresh
    end

    def releasing?
        return @release.tweening?
    end

    def release
        self.ox = src_rect.width / 2 # 32
        self.oy = src_rect.height / 2 # 32
        self.x += src_rect.width / 2 # 32
        self.y += src_rect.height / 2 # 32
        @release.tween(self, [
                           [Interpolator::ZOOM_X, 0],
                           [Interpolator::ZOOM_Y, 0],
                           [Interpolator::OPACITY, 0],
                       ], 100)
        @startRelease = true
    end

    def faded=(value)
        @faded = value
        self.opacity = @faded ? 100 : 255
    end

    def refresh
        return unless @pokemon
        setBitmap(GameData::Species.icon_filename_from_pokemon(@pokemon))
        self.src_rect = Rect.new(0, 0, bitmap.height, bitmap.height)
    end

    def update
        super
        @release.update
        self.color = Color.new(0, 0, 0, 0)
        self.opacity = 100 if @faded
        dispose if @startRelease && !releasing?
    end
end