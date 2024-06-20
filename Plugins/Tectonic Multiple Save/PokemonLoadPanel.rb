#===============================================================================
#
#===============================================================================
class PokemonLoadPanel < SpriteWrapper
    attr_reader :selected

    TEXTCOLOR             = Color.new(232, 232, 232)
    TEXTSHADOWCOLOR       = Color.new(136, 136, 136)
    MALETEXTCOLOR         = Color.new(56, 160, 248)
    MALETEXTSHADOWCOLOR   = Color.new(56, 104, 168)
    FEMALETEXTCOLOR       = Color.new(240, 72, 88)
    FEMALETEXTSHADOWCOLOR = Color.new(160, 64, 64)

    def initialize(index, title, isContinue, trainer, framecount, mapid, viewport = nil)
        super(viewport)
        @index = index
        @title = title
        @isContinue = isContinue
        @trainer = trainer
        @totalsec = (framecount || 0) / Graphics.frame_rate
        @mapid = mapid
        @selected = (index == 0)
        @bgbitmap = AnimatedBitmap.new("Graphics/Pictures/loadPanels")
        @refreshBitmap = true
        @refreshing = false
        refresh
    end

    def dispose
        @bgbitmap.dispose
        bitmap.dispose
        super
    end

    def selected=(value)
        return if @selected == value
        @selected = value
        @refreshBitmap = true
        refresh
    end

    def pbRefresh
        @refreshBitmap = true
        refresh
    end

    def refresh
        return if @refreshing
        return if disposed?
        @refreshing = true
        if !bitmap || bitmap.disposed?
            self.bitmap = BitmapWrapper.new(@bgbitmap.width, 111 * 2)
            pbSetSystemFont(bitmap)
        end
        if @refreshBitmap
            @refreshBitmap = false
            bitmap.clear if bitmap
            if @isContinue
                bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, @selected ? 111 * 2 : 0, @bgbitmap.width, 111 * 2))
            else
                bitmap.blt(0, 0, @bgbitmap.bitmap,
  Rect.new(0, 111 * 2 * 2 + (@selected ? 23 * 2 : 0), @bgbitmap.width, 23 * 2))
            end
            textpos = []
            if @isContinue
                textpos.push([@title, 16 * 2, 2 * 2, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
                textpos.push([_INTL("Badges:"), 16 * 2, 53 * 2, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
                textpos.push([@trainer.badge_count.to_s, 103 * 2, 53 * 2, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
                textpos.push([_INTL("Pokédex:"), 16 * 2, 69 * 2, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
                textpos.push([@trainer.pokedex.seen_count.to_s, 103 * 2, 69 * 2, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
                textpos.push([_INTL("Time:"), 16 * 2, 85 * 2, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
                hour = @totalsec / 60 / 60
                min  = @totalsec / 60 % 60
                if hour > 0
                    textpos.push([_INTL("{1}h {2}m", hour, min), 103 * 2, 85 * 2, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
                else
                    textpos.push([_INTL("{1}m", min), 103 * 2, 85 * 2, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
                end
                if @trainer.male?
                    textpos.push([@trainer.name, 56 * 2, 29 * 2, 0, MALETEXTCOLOR, MALETEXTSHADOWCOLOR])
                elsif @trainer.female?
                    textpos.push([@trainer.name, 56 * 2, 29 * 2, 0, FEMALETEXTCOLOR, FEMALETEXTSHADOWCOLOR])
                else
                    textpos.push([@trainer.name, 56 * 2, 29 * 2, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
                end
                mapname = pbGetMapNameFromId(@mapid)
                mapname.gsub!(/\\PN/, @trainer.name)
                textpos.push([mapname, 193 * 2, 2 * 2, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
            else
                textpos.push([@title, 16 * 2, 1 * 2, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
            end
            pbDrawTextPositions(bitmap, textpos)
        end
        @refreshing = false
    end
end
