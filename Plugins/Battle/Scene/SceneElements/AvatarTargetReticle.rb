class AvatarTargetReticle < IconSprite
    attr_reader   :battler
    attr_reader   :extraAggro

    def initialize(battler,sideSize,viewport=nil)
        super(viewport)
        @battler      = battler
        @sideSize     = sideSize
        @frame        = 0
        @extraAggro   = false
        @xOffset = 0
        @yOffset = 0
        setBitmap("Graphics/Pictures/Battle/aggro_cursor")
        refresh
    end

    def extraAggro=(val)
        @extraAggro = val
        if @extraAggro
            setBitmap("Graphics/Pictures/Battle/extra_aggro_cursor")
        else
            setBitmap("Graphics/Pictures/Battle/aggro_cursor")
        end
    end

    def refresh
        battlerPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,@sideSize)
        battlerSprite = @battler.battle.scene.sprites["pokemon_#{@battler.index}"]
        @battlerX = battlerPos[0] - battlerSprite.width / 2 - 20
        @battlerY = battlerPos[1] - battlerSprite.height / 2 - 100
        self.x = @battlerX
        self.y = @battlerY
        self.z = 10_000
    end

    def update(frameCounter=0)
        if frameCounter % 3 == 0
            if frameCounter < 12
                @yOffset += 1
            else
                @yOffset -= 1
            end
        end
        self.x = @battlerX + @xOffset
        self.y = @battlerY + @yOffset
    end
end