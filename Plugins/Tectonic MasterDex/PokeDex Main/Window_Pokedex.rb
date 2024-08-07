#===============================================================================
#
#===============================================================================
class Window_Pokedex < Window_DrawableCommand
    def initialize(x, y, width, height, viewport)
        @commands = []
        super(x, y, width, height, viewport)
        @selarrow     = AnimatedBitmap.new("Graphics/Pictures/Pokedex/cursor_list")
        @pokeballOwn  = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_own")
        @pokeballSeen = AnimatedBitmap.new("Graphics/Pictures/Pokedex/icon_seen")
        @star         = AnimatedBitmap.new("Graphics/Pictures/Pokedex/star")
        self.baseColor   = darkMode? ? Color.new(248, 248, 248) : Color.new(88, 88, 80)
        self.shadowColor = darkMode? ? Color.new(0, 0, 0) : Color.new(168, 184, 184)
        self.windowskin  = nil
    end

    def commands=(value)
        @commands = value
        refresh
    end

    def dispose
        @selarrow.dispose
        @pokeballOwn.dispose
        @pokeballSeen.dispose
        @star.dispose
        super
    end

    def species
        return (@commands.length == 0) ? 0 : @commands[index][:species]
    end

    def itemCount
        return @commands.length
    end

    def drawItem(index, _count, rect)
        return if index >= top_row + page_item_max
        rect = Rect.new(rect.x + 16, rect.y, rect.width - 16, rect.height)
        species     = @commands[index][:species]
        indexNumber = @commands[index][:index]
        indexNumber -= 1 if @commands[index][:shift]
        showSpecies = speciesInfoViewable?(species)
        if showSpecies
            if $Trainer.owned?(species)
                pbCopyBitmap(contents, @pokeballOwn.bitmap, rect.x - 6, rect.y + 8)
            else
                pbCopyBitmap(contents, @pokeballSeen.bitmap, rect.x - 6, rect.y + 8)
            end
            text = format("%03d%s %s", indexNumber, " ", @commands[index][:data].name)
        else
            text = format("%03d  ----------", indexNumber)
        end
        pbDrawShadowText(contents, rect.x + 36, rect.y + 6, rect.width, rect.height,
        text, baseColor, shadowColor)
        if showSpecies && $PokemonGlobal.speciesStarred?(species)
            pbCopyBitmap(contents, @star.bitmap, rect.x + 200, rect.y + 12)
        end
    end

    def refresh
        @item_max = itemCount
        dwidth  = width - borderX
        dheight = height - borderY
        self.contents = pbDoEnsureBitmap(contents, dwidth, dheight)
        contents.clear
        for i in 0...@item_max
            next if i < top_item || i > top_item + page_item_max
            drawItem(i, @item_max, itemRect(i))
        end
        drawCursor(index, itemRect(index))
    end

    def update
        super
        @uparrow.visible   = false
        @downarrow.visible = false
    end
end
