#===============================================================================
# Cursor
#===============================================================================
class PokemonBoxArrow < SpriteWrapper
    attr_accessor :quickswap

    def initialize(viewport = nil)
        super(viewport)
        @frame         = 0
        @holding       = false
        @updating      = false
        @quickswap     = false
        @grabbingState = 0
        @placingState  = 0
        @heldpkmn      = nil
        @handsprite    = ChangelingSprite.new(0, 0, viewport)
        @handsprite.addBitmap("point1", "Graphics/Pictures/Storage/cursor_point_1")
        @handsprite.addBitmap("point2", "Graphics/Pictures/Storage/cursor_point_2")
        @handsprite.addBitmap("grab", "Graphics/Pictures/Storage/cursor_grab")
        @handsprite.addBitmap("fist", "Graphics/Pictures/Storage/cursor_fist")
        @handsprite.addBitmap("point1q", "Graphics/Pictures/Storage/cursor_point_1_q")
        @handsprite.addBitmap("point2q", "Graphics/Pictures/Storage/cursor_point_2_q")
        @handsprite.addBitmap("grabq", "Graphics/Pictures/Storage/cursor_grab_q")
        @handsprite.addBitmap("fistq", "Graphics/Pictures/Storage/cursor_fist_q")
        @handsprite.changeBitmap("fist")
        @spriteX = self.x
        @spriteY = self.y
    end

    def dispose
        @handsprite.dispose
        @heldpkmn.dispose if @heldpkmn
        super
    end

    def heldPokemon
        @heldpkmn = nil if @heldpkmn && @heldpkmn.disposed?
        @holding = false unless @heldpkmn
        return @heldpkmn
    end

    def visible=(value)
        super
        @handsprite.visible = value
        sprite = heldPokemon
        sprite.visible = value if sprite
    end

    def color=(value)
        super
        @handsprite.color = value
        sprite = heldPokemon
        sprite.color = value if sprite
    end

    def holding?
        return heldPokemon && @holding
    end

    def grabbing?
        return @grabbingState > 0
    end

    def placing?
        return @placingState > 0
    end

    def x=(value)
        super
        @handsprite.x = self.x
        @spriteX = x unless @updating
        heldPokemon.x = self.x if holding?
    end

    def y=(value)
        super
        @handsprite.y = self.y
        @spriteY = y unless @updating
        heldPokemon.y = self.y + 16 if holding?
    end

    def z=(value)
        super
        @handsprite.z = value
    end

    def setSprite(sprite)
        if holding?
            @heldpkmn = sprite
            @heldpkmn.viewport = viewport if @heldpkmn
            @heldpkmn.z = 1 if @heldpkmn
            @holding = false unless @heldpkmn
            self.z = 2
        end
    end

    def deleteSprite
        @holding = false
        if @heldpkmn
            @heldpkmn.dispose
            @heldpkmn = nil
        end
    end

    def grab(sprite)
        @grabbingState = 1
        @heldpkmn = sprite
        @heldpkmn.viewport = viewport
        @heldpkmn.z = 1
        self.z = 2
    end

    def place
        @placingState = 1
    end

    def release
        @heldpkmn.release if @heldpkmn
    end

    def update
        @updating = true
        super
        heldpkmn = heldPokemon
        heldpkmn.update if heldpkmn
        @handsprite.update
        @holding = false unless heldpkmn
        if @grabbingState > 0
            if @grabbingState <= 4 * Graphics.frame_rate / 20
                @handsprite.changeBitmap(@quickswap ? "grabq" : "grab")
                self.y = @spriteY + 4.0 * @grabbingState * 20 / Graphics.frame_rate
                @grabbingState += 1
            elsif @grabbingState <= 8 * Graphics.frame_rate / 20
                @holding = true
                @handsprite.changeBitmap(@quickswap ? "fistq" : "fist")
                self.y = @spriteY + 4 * (8 * Graphics.frame_rate / 20 - @grabbingState) * 20 / Graphics.frame_rate
                @grabbingState += 1
            else
                @grabbingState = 0
            end
        elsif @placingState > 0
            if @placingState <= 4 * Graphics.frame_rate / 20
                @handsprite.changeBitmap(@quickswap ? "fistq" : "fist")
                self.y = @spriteY + 4.0 * @placingState * 20 / Graphics.frame_rate
                @placingState += 1
            elsif @placingState <= 8 * Graphics.frame_rate / 20
                @holding = false
                @heldpkmn = nil
                @handsprite.changeBitmap(@quickswap ? "grabq" : "grab")
                self.y = @spriteY + 4 * (8 * Graphics.frame_rate / 20 - @placingState) * 20 / Graphics.frame_rate
                @placingState += 1
            else
                @placingState = 0
            end
        elsif holding?
            @handsprite.changeBitmap(@quickswap ? "fistq" : "fist")
        else
            self.x = @spriteX
            self.y = @spriteY
            if @frame < Graphics.frame_rate / 2
                @handsprite.changeBitmap(@quickswap ? "point1q" : "point1")
            else
                @handsprite.changeBitmap(@quickswap ? "point2q" : "point2")
            end
        end
        @frame += 1
        @frame = 0 if @frame >= Graphics.frame_rate
        @updating = false
    end
end