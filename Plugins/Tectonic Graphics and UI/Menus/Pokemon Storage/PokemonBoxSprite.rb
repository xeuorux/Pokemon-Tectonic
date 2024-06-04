#===============================================================================
# Box
#===============================================================================
class PokemonBoxSprite < SpriteWrapper
    attr_accessor :refreshBox
    attr_accessor :refreshSprites

    def initialize(storage, boxnumber, viewport, fadeProc = nil)
        super(viewport)
        @storage = storage
        @boxnumber = boxnumber
        @refreshBox = true
        @refreshSprites = true
        @pokemonsprites = []
        @fadeProc = fadeProc
        for i in 0...PokemonBox::BOX_SIZE
            @pokemonsprites[i] = nil
            pokemon = @storage[boxnumber, i]
            @pokemonsprites[i] = PokemonBoxIcon.new(pokemon, viewport)
            @pokemonsprites[i].faded = true if pokemon && @fadeProc && !@fadeProc.call(pokemon)
        end
        @contents = BitmapWrapper.new(324, 296)
        self.bitmap = @contents
        self.x = 184
        self.y = 18
        refresh
    end

    def dispose
        unless disposed?
            for i in 0...PokemonBox::BOX_SIZE
                @pokemonsprites[i].dispose if @pokemonsprites[i]
                @pokemonsprites[i] = nil
            end
            @boxbitmap.dispose
            @contents.dispose
            super
        end
    end

    def x=(value)
        super
        refresh
    end

    def y=(value)
        super
        refresh
    end

    def color=(value)
        super
        if @refreshSprites
            for i in 0...PokemonBox::BOX_SIZE
                @pokemonsprites[i].color = value if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
            end
        end
        refresh
    end

    def visible=(value)
        super
        for i in 0...PokemonBox::BOX_SIZE
            @pokemonsprites[i].visible = value if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        end
        refresh
    end

    def getBoxBitmap
        if !@bg || @bg != @storage[@boxnumber].background
            curbg = @storage[@boxnumber].background
            if !curbg || (curbg.is_a?(String) && curbg.length == 0)
                @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
            else
                if curbg.is_a?(String) && curbg[/^box(\d+)$/]
                    curbg = $~[1].to_i
                    @storage[@boxnumber].background = curbg
                end
                @bg = curbg
            end
            unless @storage.isAvailableWallpaper?(@bg)
                @bg = @boxnumber % PokemonStorage::BASICWALLPAPERQTY
                @storage[@boxnumber].background = @bg
            end
            @boxbitmap.dispose if @boxbitmap
            @boxbitmap = AnimatedBitmap.new("Graphics/Pictures/Storage/box_#{@bg}")
        end
    end

    def getPokemon(index)
        return @pokemonsprites[index]
    end

    def setPokemon(index, sprite)
        sprite.faded = true if @fadeProc&.call(sprite.pokemon)

        @pokemonsprites[index] = sprite
        @pokemonsprites[index].refresh
        refresh
    end

    def grabPokemon(index, arrow)
        sprite = @pokemonsprites[index]
        if sprite
            arrow.grab(sprite)
            @pokemonsprites[index] = nil
            refresh
        end
    end

    def deletePokemon(index)
        @pokemonsprites[index].dispose
        @pokemonsprites[index] = nil
        refresh
    end

    def refresh
        if @refreshBox
            boxname = @storage[@boxnumber].name
            getBoxBitmap
            @contents.blt(0, 0, @boxbitmap.bitmap, Rect.new(0, 0, 324, 296))
            pbSetSystemFont(@contents)
            widthval = @contents.text_size(boxname).width
            xval = 162 - (widthval / 2)
            pbDrawShadowText(@contents, xval, 8, widthval, 32,
               boxname, Color.new(248, 248, 248), Color.new(40, 48, 48))
            @refreshBox = false
        end
        yval = self.y + 30
        for j in 0...PokemonBox::BOX_HEIGHT
            xval = self.x + 10
            for k in 0...PokemonBox::BOX_WIDTH
                sprite = @pokemonsprites[j * PokemonBox::BOX_WIDTH + k]
                if sprite && !sprite.disposed?
                    sprite.viewport = viewport
                    sprite.x = xval
                    sprite.y = yval
                    sprite.z = 0
                end
                xval += 48
            end
            yval += 48
        end
    end

    def update
        super
        for i in 0...PokemonBox::BOX_SIZE
            @pokemonsprites[i].update if @pokemonsprites[i] && !@pokemonsprites[i].disposed?
        end
    end
end
