#===============================================================================
# Shows a single wild Pokémon fading back to its normal color, and triggers their intro
# animation
#===============================================================================
class BattleIntroAnimationSolo < PokeBattle_Animation
    def initialize(sprites, viewport, idxBattler)
        @idxBattler = idxBattler
        super(sprites, viewport)
    end

    def createProcesses
        battler = addSprite(@sprites["pokemon_#{@idxBattler}"], PictureOrigin::Bottom)
        battler.moveTone(0, 4, Tone.new(0, 0, 0, 0))
        battler.setCallback(0, [@sprites["pokemon_#{@idxBattler}"], :pbPlayIntroAnimation])
    end
end