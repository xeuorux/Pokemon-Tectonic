class MoveOutcomePredictor < SpriteWrapper
    attr_reader   :battler

    def initialize(battler,sideSize,viewport=nil)
        super(viewport)
        @battler      = battler
        @sideSize     = sideSize
        @frame        = 0
        @outcomeDisplayBitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
        pbSetSystemFont(@outcomeDisplayBitmap)
        self.bitmap = @outcomeDisplayBitmap
        @outcomeDisplayBitmap.font.size = 32
        self.z = 1000 - battler.index

        @effectiveness = nil
        @basePower = nil
        @effectivenessColor = EFFECTIVENESS_COLORS[3]

        refresh
    end

    def refresh
        battlerPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,@sideSize)
        battlerSprite = @battler.battle.scene.sprites["pokemon_#{@battler.index}"]
        displayX = battlerPos[0]
        displayY = battlerPos[1] - 124

        @outcomeDisplayBitmap.clear
        
        currentDisplayY = displayY
        textpos = []
        if @effectiveness
            outline = Color.new(248, 248, 248)
            textpos.push([@effectiveness,displayX,displayY,2,@effectivenessColor,outline,true])
            currentDisplayY += 32
        end
        
        if @basePower
            color = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR_DARK
            outline = PokeBattle_SceneConstants::MESSAGE_SHADOW_COLOR_DARK
            textpos.push([@basePower,displayX,currentDisplayY,2,color,outline,true])
        end

        pbDrawTextPositions(@outcomeDisplayBitmap,textpos)
    end

    def setEffectiveness(effectiveness,effectivenessColor)
        @effectiveness = effectiveness
        @effectivenessColor = effectivenessColor
        refresh
    end

    def basePower=(value)
        @basePower = value
        refresh
    end

    def clear
        @effectiveness = nil
        @basePower = nil
        @outcomeDisplayBitmap.clear
    end

    def dispose
		super
		@outcomeDisplayBitmap.dispose if @outcomeDisplayBitmap
	end
end