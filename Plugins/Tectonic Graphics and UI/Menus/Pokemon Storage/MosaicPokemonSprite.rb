#===============================================================================
# Pokémon sprite
#===============================================================================
class MosaicPokemonSprite < PokemonSprite
    attr_reader :mosaic

    def initialize(*args)
        super(*args)
        @mosaic = 0
        @inrefresh = false
        @mosaicbitmap = nil
        @mosaicbitmap2 = nil
        @oldbitmap = bitmap
    end

    def dispose
        super
        @mosaicbitmap.dispose if @mosaicbitmap
        @mosaicbitmap = nil
        @mosaicbitmap2.dispose if @mosaicbitmap2
        @mosaicbitmap2 = nil
    end

    def bitmap=(value)
        super
        mosaicRefresh(value)
    end

    def mosaic=(value)
        @mosaic = value
        @mosaic = 0 if @mosaic < 0
        mosaicRefresh(@oldbitmap)
    end

    def mosaicRefresh(bitmap)
        return if @inrefresh
        @inrefresh = true
        @oldbitmap = bitmap
        if @mosaic <= 0 || !@oldbitmap
            @mosaicbitmap.dispose if @mosaicbitmap
            @mosaicbitmap = nil
            @mosaicbitmap2.dispose if @mosaicbitmap2
            @mosaicbitmap2 = nil
            self.bitmap = @oldbitmap
        else
            newWidth  = [(@oldbitmap.width / @mosaic), 1].max
            newHeight = [(@oldbitmap.height / @mosaic), 1].max
            @mosaicbitmap2.dispose if @mosaicbitmap2
            @mosaicbitmap = pbDoEnsureBitmap(@mosaicbitmap, newWidth, newHeight)
            @mosaicbitmap.clear
            @mosaicbitmap2 = pbDoEnsureBitmap(@mosaicbitmap2, @oldbitmap.width, @oldbitmap.height)
            @mosaicbitmap2.clear
            @mosaicbitmap.stretch_blt(Rect.new(0, 0, newWidth, newHeight), @oldbitmap, @oldbitmap.rect)
            @mosaicbitmap2.stretch_blt(
                Rect.new(-@mosaic / 2 + 1, -@mosaic / 2 + 1,
                @mosaicbitmap2.width, @mosaicbitmap2.height),
               @mosaicbitmap, Rect.new(0, 0, newWidth, newHeight))
            self.bitmap = @mosaicbitmap2
        end
        @inrefresh = false
    end
end

#===============================================================================
#
#===============================================================================
class AutoMosaicPokemonSprite < MosaicPokemonSprite
    def update
        super
        self.mosaic -= 1
    end
end