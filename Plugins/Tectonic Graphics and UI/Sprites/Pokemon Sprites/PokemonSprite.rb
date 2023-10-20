#===============================================================================
# Pokémon sprite (used out of battle)
#===============================================================================
class PokemonSprite < SpriteWrapper
    attr_reader :pokemon

    def initialize(viewport = nil)
        super(viewport)
        @_iconbitmap = nil
    end

    def dispose
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = nil
        self.bitmap = nil unless disposed?
        super
    end

    def clearBitmap
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = nil
        self.bitmap = nil
    end

    def setOffset(offset = PictureOrigin::Center)
        @offset = offset
        changeOrigin
    end

    def changeOrigin
        return unless bitmap
        @offset ||= PictureOrigin::Center
        case @offset
        when PictureOrigin::TopLeft, PictureOrigin::Left, PictureOrigin::BottomLeft
            self.ox = 0
        when PictureOrigin::Top, PictureOrigin::Center, PictureOrigin::Bottom
            self.ox = bitmap.width / 2
        when PictureOrigin::TopRight, PictureOrigin::Right, PictureOrigin::BottomRight
            self.ox = bitmap.width
        end
        case @offset
        when PictureOrigin::TopLeft, PictureOrigin::Top, PictureOrigin::TopRight
            self.oy = 0
        when PictureOrigin::Left, PictureOrigin::Center, PictureOrigin::Right
            self.oy = bitmap.height / 2
        when PictureOrigin::BottomLeft, PictureOrigin::Bottom, PictureOrigin::BottomRight
            self.oy = bitmap.height
        end
    end

    def setPokemonBitmap(pokemon, back = false)
        @pokemon = pokemon
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = pokemon ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back) : nil
        self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
        self.color = Color.new(0, 0, 0, 0)
        changeOrigin
    end

    def setPokemonBitmapSpecies(pokemon, species, back = false)
        @pokemon = pokemon
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = pokemon ? GameData::Species.sprite_bitmap_from_pokemon(pokemon, back, species) : nil
        self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
        changeOrigin
    end

    def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
        self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
        changeOrigin
    end

    def setSpeciesBitmapHueShifted(species, gender = 0, form = 0, shiny = false, shadow = false, back = false,
                                   egg = false)
        @_iconbitmap.dispose if @_iconbitmap
        @_iconbitmap = GameData::Species.sprite_bitmap(species, form, gender, shiny, shadow, back, egg)
        @_iconbitmap = shiftSpeciesBitmapHue(@_iconbitmap, species)
        self.bitmap = @_iconbitmap ? @_iconbitmap.bitmap : nil
        changeOrigin
    end

    def update
        super
        if @_iconbitmap
            @_iconbitmap.update
            self.bitmap = @_iconbitmap.bitmap
        end
    end
end
