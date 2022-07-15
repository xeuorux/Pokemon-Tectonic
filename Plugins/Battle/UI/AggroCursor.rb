class AggroCursor < IconSprite
    attr_reader   :battler

    def initialize(battler,sideSize,viewport=nil)
        super(viewport)
        @battler      = battler
        @sideSize     = sideSize
        @frame        = 0
        setBitmap("Graphics/Pictures/Battle/aggro_cursor")
        refresh
    end

    def refresh
        battlerPos = PokeBattle_SceneConstants.pbBattlerPosition(@battler.index,@sideSize)
        battlerSprite = @battler.battle.scene.sprites["pokemon_#{@battler.index}"]
        self.x = battlerPos[0] - battlerSprite.width / 2 - 20
        self.y = battlerPos[1] - battlerSprite.height / 2 - 100
        self.z = 100
        echoln("Aggro cursor for index #{@battler.index} set to #{self.x},#{self.y}")
    end
end